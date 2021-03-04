/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Classe com regras de negócio para consumo das integrações de abrir envelope na docusign e de pegar url de envelope
*  ---------------------------------------------------------------
*/
public class CEC_PME_ServiceEnvelope {
    
    private AccountContactRelation embeddedAccountContactRelation;
    
    public SaveResult open(String orderId, Boolean isSigningRequired, Boolean isEmbedded, String accountId, String templateId) 
    {     
        SaveResult result = new SaveResult();
        
        Order objOrder = [SELECT Id, 
                          DocuSignEnvelopeID__c, 
                          DocuSignRetornoIntegracao__c, 
                          DocuSignStatusDatetime__c, 
                          Related_Contacts__c,
                          Status,
                          AccountId,
                          OwnerId
                          FROM Order 
                          WHERE Id =: orderId];
        
        List<ContentDocumentLink> lstCDL = [SELECT ContentDocumentId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =: objOrder.Id];
        
        if(lstCDL.isEmpty()) {
            return buildSaveResult(true, 'Não há termos para assinar relacionados a este pedido.', null, null);
        }
        
        CEC_PME_IntegrationDocuSignEnvelope.SendParameters envelopeParam = new CEC_PME_IntegrationDocuSignEnvelope.SendParameters();
        envelopeParam.listClients = builderListClients(objOrder); 
        envelopeParam.listClients.addAll(builderListDonors(objOrder));    
        envelopeParam.listUsersBackOffice = builderlistUsersBackOffice(objOrder);
        envelopeParam.owner = new CEC_PME_IntegrationDocuSignEnvelope.Recipient(UserInfo.getName(), UserInfo.getUserEmail());
        envelopeParam.accountId = accountId;
        envelopeParam.templateId = templateId;
        envelopeParam.isSigningRequired = isSigningRequired;
        envelopeParam.orderId = orderId;
        envelopeParam.isEmbedded = isEmbedded;
        CEC_PME_IntegrationDocuSignEnvelope integrationEnvelope = new CEC_PME_IntegrationDocuSignEnvelope();      
        CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope responseEnvelope = integrationEnvelope.send(envelopeParam);

    	Set<String> setRecipientsId = integrationEnvelope.setRequiredRecipientsId();  
        
        return processEnvelopeStatus(responseEnvelope , objOrder, isSigningRequired, isEmbedded, accountId, templateId, setRecipientsId);       
    }
    
    private List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> builderlistUsersBackOffice(Order objOrder) {
        List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> listRecipients = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        
        List<Member__c> listMembers = [SELECT Hierarchy__r.ParentHierarchy__c 
                                       FROM Member__c 
                                       WHERE User__c = :UserInfo.getUserId()];
        
        List<Id> listParentHierarchysId = new List<Id>();
        
        for(Member__c member : listMembers) {
            listParentHierarchysId.add(member.Hierarchy__r.ParentHierarchy__c);
        }
        
        List<Member__c> listBackOffice = [SELECT id,  
                                          User__r.Name,
                                          User__r.Email
                                          FROM Member__c 
                                          WHERE Hierarchy__c IN :listParentHierarchysId];
        
        for(Member__c member : listBackOffice) {
            if(member.User__r.Name != null && member.User__r.Email != null) {
                listRecipients.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient(member.User__r.Name, member.User__r.Email));
            }
        }
        return listRecipients;
    }
    
    private List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> builderListDonors(Order objOrder) {
        List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> recipients = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        
        List<OrderItem> listOrderIntems = [SELECT Id,
                                           DonatorEmail__c,
                                           DonatorName__c
                                           FROM OrderItem
                                           WHERE Order.Id = :objOrder.Id
                                           AND DonatorName__c != null
                                           AND DonatorEmail__c != null];
        
        Set<String> donorCreated = new Set<String>();
        Integer count = 1;
        for(OrderItem orderItem : listOrderIntems ) {
            if(!donorCreated.contains(orderItem.DonatorEmail__c + orderItem.DonatorName__c)) {
                donorCreated.add(orderItem.DonatorEmail__c + orderItem.DonatorName__c);
                recipients.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient(orderItem.DonatorName__c, orderItem.DonatorEmail__c, 'TTSF#00' + (count)));
                count++;
            }
        }
        return recipients;
    }
    
    private List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> builderListClients(Order objOrder) {
        List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> recipients = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        List<String> listAccContId = new List<String>();
        if(String.isNotBlank(objOrder.Related_Contacts__c) && objOrder.Related_Contacts__c.contains(';')) {
            listAccContId = objOrder.Related_Contacts__c.split(';');
        }
        
        List<AccountContactRelation> listContacts = [SELECT Id,
                                                     Email__c, 
                                                     Contact.Name,
                                                     ContactId 
                                                     FROM AccountContactRelation 
                                                     WHERE AccountId =: objOrder.AccountId 
                                                     AND ResponsibleForTheSignature__c = TRUE
                                                     AND Id IN :listAccContId];
        
        if (listContacts.size() > 0) {
            embeddedAccountContactRelation = listContacts.get(0);
            for(Integer i = 0; i < listContacts.size(); i++) {
                AccountContactRelation varContact = listContacts.get(i);
                recipients.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient(varContact.Contact.Name ,varContact.Email__c, 'RLSF#00' + (i + 1)));
            } 
        }
        return recipients;
    }
    
    private SaveResult processEnvelopeStatus(CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope responseEnvelope, Order objOrder, Boolean isSigningRequired, Boolean isEmbedded, String accountId, String templateId, Set<String> setRecipientsId)  {        
        if(String.isBlank(responseEnvelope.status) || !responseEnvelope.status.equalsIgnoreCase('sent')) {
            return buildSaveResult(true, JSON.serialize(responseEnvelope), null, null); 
        } else {
            try {
                String urlEmbedded; 
                if(isEmbedded) {
                    urlEmbedded  = new CEC_PME_IntegrationDocuSignEmbedded().send(accountId, responseEnvelope.envelopeId, embeddedAccountContactRelation);
                    system.debug('urlEmbedded ' + urlEmbedded);
                }
                
                // Utilizado no controle de assinadores obrigatórios
                List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> lstSigners = getDocuSignRecipients(responseEnvelope.envelopeId);
                
                objOrder.DocuSignRetornoIntegracao__c = JSON.serialize(responseEnvelope);
                objOrder.DocuSignEnvelopeID__c = responseEnvelope.envelopeId;
                objOrder.DocuSignStatusDatetime__c = Datetime.newInstanceGmt(responseEnvelope.statusDateTime.date(), 
                                                                             responseEnvelope.statusDateTime.time());
                
                if(isSigningRequired || isEmbedded) {
                    objOrder.Status = 'Aguardando Assinatura';
                } else {
                    setTerritory(objOrder);
                }

                update objOrder;

                String statusId = insertStatusObject(responseEnvelope.envelopeId, objOrder);
               
                insertRecipientsStatus(lstSigners, setRecipientsId, responseEnvelope.envelopeId, statusId);
                
                return buildSaveResult(false, 'Termos enviados para assinatura com sucesso', urlEmbedded, objOrder);
            } catch(Exception ex){
                return buildSaveResult(true, ex.getMessage(), null, null);
            }
        }
    }
    
    private void setTerritory(Order objOrder) {
        Map<Id, List<Id>> mapOwnerIdLstHierId = CEC_PME_HierarchyUtil.getMapOwnerIdLstHierId(new List<Order>{objOrder});
        
        if(mapOwnerIdLstHierId.containsKey(objOrder.OwnerId) && mapOwnerIdLstHierId.get(objOrder.OwnerId).size() == 1) {
            Account upAccount = new Account();
            upAccount.Id = objOrder.AccountId;
            upAccount.Hierarchy__c = mapOwnerIdLstHierId.get(objOrder.OwnerId).get(0);
            update upAccount;
            
            objOrder.Status = 'Território Associado';
        } else {
            objOrder.Status = 'Contrato Assinado';
        }
    }
    
    private void insertRecipientsStatus(List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> signers, Set<String> setRecipientsId, String envelopeId, String statusId) {
                            
        List<dsfs__DocuSign_Recipient_Status__c> lstDocuRecStatus = new List<dsfs__DocuSign_Recipient_Status__c>();
        dsfs__DocuSign_Recipient_Status__c DocuRecStatus;
                      
        for(CEC_PME_IntegrationDocuSignObjectFactory.Signer signer : signers) {                     
            DocuRecStatus = new dsfs__DocuSign_Recipient_Status__c();

            DocuRecStatus.dsfs__Parent_Status_Record__c = (Id)statusId;
            DocuRecStatus.dsfs__DocuSign_Recipient_Id__c = signer.recipientIdGuid;            
            DocuRecStatus.dsfs__Envelope_Id__c = envelopeId;        
            DocuRecStatus.AssinaturaObrigatoria__c = setRecipientsId.contains(signer.recipientId);             
            DocuRecStatus.Name = signer.name;
            DocuRecStatus.dsfs__DocuSign_Recipient_Email__c = signer.email;
            DocuRecStatus.dsfs__Recipient_Status__c = signer.status;
            DocuRecStatus.dsfs__DocuSign_Routing_Order__c = Decimal.valueOf(signer.routingOrder); 
            lstDocuRecStatus.Add(DocuRecStatus);
        }
     
        upsert lstDocuRecStatus;       
    }
    
    private String insertStatusObject(String envelopeId, Order varOrder) {
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c();
        docuSignStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        docuSignStatus.Order__c = varOrder.Id;
        insert docuSignStatus;

        return (String)docuSignStatus.Id;
    }
    
    public SaveResult buildSaveResult(Boolean isError, String message, String urlEmbedded, Order objOrder) {      
        SaveResult result = new SaveResult();
        result.isError = isError;
        result.message = message;
        result.urlEmbedded = urlEmbedded;
        result.statusOrder = objOrder == null ? null : objOrder.Status;
        return result;
    } 
    
    public class SaveResult {
        @AuraEnabled
        public Boolean isError {get; set;}
        @AuraEnabled
        public String message {get; set;}      
        @AuraEnabled
        public String urlEmbedded {get; set;}     
        @AuraEnabled
        public String statusOrder {get; set;}  
    }
    
    public static List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> getDocuSignRecipients(String docuSignEnvelopeId) {  
       
        String docuSignAccountId = getDocuSignAccountId();

        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients;        
        
        if (String.isNotBlank(docuSignEnvelopeId)) {
            envelopeRecipients = new CEC_PME_IntegrationDocuSignRecipient(docuSignAccountId, docuSignEnvelopeId).listRecipients();
            system.debug('envelopeRecipients ' + envelopeRecipients.signers);            
        	
            return envelopeRecipients.signers;              
        } else {       	            
            return null;
        }      
    } 

	private static String getDocuSignAccountId() {
        Integration_Flow__c integrationFlow = Integration_Flow__c.getInstance(UserInfo.getProfileId());
        return integrationFlow.AccountId__c;
    }   
}