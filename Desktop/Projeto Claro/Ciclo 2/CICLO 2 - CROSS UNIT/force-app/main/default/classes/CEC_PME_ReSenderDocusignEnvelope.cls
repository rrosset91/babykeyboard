public class CEC_PME_ReSenderDocusignEnvelope {
    public class ReSenderDocusignEnvelopeException extends Exception {}
    
    private String getDocuSignAccountId() {
        Integration_Flow__c integrationFlow = Integration_Flow__c.getInstance(UserInfo.getProfileId());
        return integrationFlow.AccountId__c;
    }
    
    private String getDocuSignEnvelopeId(Id orderId) {
        List<dsfs__DocuSign_Status__c> listStatusEnvelope = [SELECT Id, dsfs__DocuSign_Envelope_ID__c
                                                             FROM dsfs__DocuSign_Status__c
                                                             WHERE Order__c = :orderId
                                                             ORDER BY CreatedDate DESC];
        
        if(listStatusEnvelope.isEmpty()) {
            throw new ReSenderDocusignEnvelopeException('Envelope Id não encontrado!');
        }
        system.debug('listStatusEnvelope ' + listStatusEnvelope);
        return listStatusEnvelope.get(0).dsfs__DocuSign_Envelope_ID__c;
    }
    
    private Set<String> getContactsDocIds(Id orderId) {
        /* Alterado para exibir dados de recipients com assinatura obrigatória */
        Id DocuStatusId;
        Set<String> setContactsIds = new Set<String>();
        
        List<dsfs__DocuSign_Status__c> lstDocuStatus = [SELECT Id 
                                                        FROM dsfs__DocuSign_Status__c 
                                                        WHERE Order__c = :orderId
                                                        Order BY CreatedDate DESC];
        
        DocuStatusId = lstDocuStatus.get(0).Id;
        
        List<dsfs__DocuSign_Recipient_Status__c> lstDocuRecipientStatus = [SELECT Id, Name, dsfs__DocuSign_Recipient_Id__c
                                                                           FROM dsfs__DocuSign_Recipient_Status__c
                                                                           WHERE AssinaturaObrigatoria__c = true
                                                                           AND dsfs__Parent_Status_Record__c = :DocuStatusId]; 
        
        for(dsfs__DocuSign_Recipient_Status__c DocuRecipientStatus : lstDocuRecipientStatus) {
            setContactsIds.add(DocuRecipientStatus.dsfs__DocuSign_Recipient_Id__c.toUpperCase());
        }        
        System.Debug(setContactsIds);
        
        return setContactsIds;
    }
    
    public String getSignatureContacts(Id orderId) {
        String docuSignAccountId = getDocuSignAccountId();
        String docuSignEnvelopeId = getDocuSignEnvelopeId(orderId);
        Set<String> setContactsIds = getContactsDocIds(orderId);
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients;
        envelopeRecipients = new CEC_PME_IntegrationDocuSignRecipient(docuSignAccountId, docuSignEnvelopeId).listRecipients();
        system.debug('envelopeRecipients ' + envelopeRecipients.signers);
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> listSeparetedSigners = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        
        for(CEC_PME_IntegrationDocuSignObjectFactory.Signer signer : envelopeRecipients.signers) {             
            if(!'completed'.equalsIgnoreCase(signer.status) && setContactsIds.contains(signer.recipientIdGuid.toUpperCase())) {
                listSeparetedSigners.add(signer);
            }
        }
        
        return JSON.serialize(listSeparetedSigners);
    }   
    
    public void reSendDocusignEnvelope(String signers, Id orderId) {
        String docuSignAccountId = getDocuSignAccountId();
        String docuSignEnvelopeId = getDocuSignEnvelopeId(orderId);
        
        System.debug('signers ' + signers);
        List<object> listObjects = (List<object>) JSON.deserializeUntyped(signers);
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> listSigners = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        for(Object varObject : listObjects) {
            CEC_PME_IntegrationDocuSignObjectFactory.Signer signer = new CEC_PME_IntegrationDocuSignObjectFactory.Signer();
            Map<String, Object> mapObject = (Map<String, Object>) varObject;
            signer.recipientId = (String) mapObject.get('clientId');
            signer.email = (String) mapObject.get('clientEmail');
            listSigners.add(signer);
        }
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients();
        envelopeRecipients.signers = listSigners;
        
        new CEC_PME_IntegrationDocuSignRecipient(docuSignAccountId, docuSignEnvelopeId).updateRecipients(envelopeRecipients);
        
        Order updateOrder = new Order();
        updateOrder.Id = orderId;
        updateOrder.DocuSignReenviarAssinatura__c = false;
        update updateOrder;
    }
}