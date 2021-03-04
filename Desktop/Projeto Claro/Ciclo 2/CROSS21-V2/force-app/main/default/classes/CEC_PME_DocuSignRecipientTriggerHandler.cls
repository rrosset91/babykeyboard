/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Trigger Handler de dsfs__DocuSign_Recipient_Status__c
*  ---------------------------------------------------------------
*/
public class CEC_PME_DocuSignRecipientTriggerHandler extends TriggerHandler {
    
    //constantes
    private final String REC_STATUS_COMPLETED = 'Completed';
    private final String REC_STATUS_DECLINED = 'Declined';
    private final String PED_STATUS_CONTR_CRIADO = 'Contrato Criado';
    private final String PED_STATUS_CONTR_ASSINADO = 'Contrato Assinado';
    private final String PED_STATUS_ASSINATURA = 'Aguardando Assinatura';
    private final String PED_STATUS_TERR = 'Território Associado';
    private final String PED_STATUS_CANCELADO = 'Cancelado';
    private final String AUTORESPONDED = 'AutoResponded';
    
    
    List<dsfs__DocuSign_Recipient_Status__c> triggerNewPME; 
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: Construtor
	*/ 
    public CEC_PME_DocuSignRecipientTriggerHandler() {
        triggerNewPME = (List<dsfs__DocuSign_Recipient_Status__c>) getTriggerNew();
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Atualizar o status do pedido e habilitar o reenvio para o DocuSign
    */    
    public override void afterInsert() {
        updateOrder();
        enableDocusignResubmit();
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Atualizar o status do pedido e habilitar o reenvio para o DocuSign
    */    
    public override void afterUpdate() {
        updateOrder();     
        enableDocusignResubmit();
    } 
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Recalcular e atualizar o status do pedido se necessário
    */    
    private void updateOrder() {
        system.debug('updateOrder ');
        List<String> listStatusId = new List<String>();
        Set<Id> setCompletedRecipientStatusId = new Set<Id>();
        
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus : triggerNewPME) {
            Boolean isToList = REC_STATUS_COMPLETED.equalsIgnoreCase(varRecipientStatus.dsfs__Recipient_Status__c);
            isToList = isToList || REC_STATUS_DECLINED.equalsIgnoreCase(varRecipientStatus.dsfs__Recipient_Status__c);
            
            if(isToList) {
                listStatusId.add(varRecipientStatus.dsfs__Parent_Status_Record__c);
            }
        }
        
        List<dsfs__DocuSign_Status__c> listStatus = [SELECT Id, 
                                                     Order__c,
                                                     Order__r.AccountId,
                                                     Order__r.Status,
                                                     (SELECT Id,
                                                      Name,
                                                      dsfs__Recipient_Status__c,
                                                      dsfs__DocuSign_Recipient_Email__c,
                                                      AssinaturaObrigatoria__c 
                                                      FROM R00NS0000000WUO2MAO__r
                                                      WHERE dsfs__Recipient_Status__c <> :REC_STATUS_COMPLETED)
                                                     FROM dsfs__DocuSign_Status__c
                                                     WHERE Id IN :listStatusId];
        
        Map<Id, Account> mapAccount = getMapAccount(listStatus);
        Map<Id, Order> mapOrder = getMapOrder(listStatus);
        Map<Id, List<Id>> mapOwnerIdLstHierId = CEC_PME_HierarchyUtil.getMapOwnerIdLstHierId(mapOrder.values());
        
        List<Order> listOrderUp = new List<Order>();
        List<Order> listOrderToShare = new List<Order>();
        List<Account> listAccountUp = new List<Account>();

        for(dsfs__DocuSign_Status__c varStatus : listStatus) {                
            Account varAccount = mapAccount.get(varStatus.Order__r.AccountId);
            Order varOrder = mapOrder.get(varStatus.Order__c);

            Boolean isClose = true;
            Boolean isDeclined = false;
            if(varStatus.R00NS0000000WUO2MAO__r != null) {
                for(dsfs__DocuSign_Recipient_Status__c recipient : varStatus.R00NS0000000WUO2MAO__r) {
                    isClose = isClose && !recipient.AssinaturaObrigatoria__c;
                    isClose = isClose && PED_STATUS_ASSINATURA.equalsIgnoreCase(varStatus.Order__r.Status);
                    isDeclined = isDeclined || REC_STATUS_DECLINED.equalsIgnoreCase(recipient.dsfs__Recipient_Status__c);
                }
            }
                      
            if((isClose || isDeclined) && varOrder.Id != null) {
                Order orderUp = new Order();
                orderUp.Id = varOrder.Id;
                
                if(isDeclined) {
                    orderUp.Status = PED_STATUS_CANCELADO;
                } else if(isClose) {
                    if(mapOwnerIdLstHierId.containsKey(varOrder.OwnerId) && mapOwnerIdLstHierId.get(varOrder.OwnerId).size() == 1) {
                        Account upAccount = new Account();
                        upAccount.Id = varOrder.AccountId;
                        upAccount.Hierarchy__c = mapOwnerIdLstHierId.get(varOrder.OwnerId).get(0);
                        listAccountUp.add(upAccount);
                        
                        orderUp.Status = PED_STATUS_TERR;
                    } else {
                        orderUp.Status = PED_STATUS_CONTR_ASSINADO;
                    }
                }
                
                listOrderToShare.add(varOrder);
                listOrderUp.add(orderUp);
            }
        }
        
        if(!listOrderToShare.isEmpty()) {
            new CEC_PME_SharerRecord().sharingRecordOrder(listOrderToShare);
        }

        if(!listOrderUp.isEmpty()) {
            update listOrderUp;
        }
        
        if(!listAccountUp.isEmpty()) {
            update listAccountUp;
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Retorna um map com os dados do pedido e itens do pedido
    */    
    private Map<Id, Order> getMapOrder(List<dsfs__DocuSign_Status__c> listStatus) {
        List<Id> listOrdersId = new List<Id>();
        for(dsfs__DocuSign_Status__c varStatus : listStatus) {
            listOrdersId.add(varStatus.Order__c);
        }
        
        List<Order> listOrders = [SELECT Id,
                                  Owner.Profile.Name,
                                  OwnerId,
                                  AccountId,
                                  (SELECT Id,
                                   DonatorEmail__c,
                                   DonatorName__c
                                   FROM OrderItems
                                   WHERE DonatorEmail__c != null
                                   AND DonatorName__c != null)
                                  FROM Order
                                  WHERE Id IN :listOrdersId];
        
        return new Map<Id, Order>(listOrders);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Retorna um map com os dados do cliente
    */    
    private Map<Id, Account> getMapAccount(List<dsfs__DocuSign_Status__c> listStatus) {

        List<Id> listAccountId = new List<Id>();
        for(dsfs__DocuSign_Status__c envelopeStatus : listStatus) {
            listAccountId.add(envelopeStatus.Order__r.AccountId);
        }
        
        List<Account> listAccount = [SELECT Id,
                                     (SELECT Id,
                                      Email__c, 
                                      Contact.Name
                                      FROM AccountContactRelations
                                      WHERE ResponsibleForTheSignature__c = TRUE)
                                     FROM Account 
                                     WHERE Id IN :listAccountId];
        
        return new Map<Id, Account>(listAccount);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Habilitar a atualização do e-mail do assinador, quando o DocuSign não reconhece o e-mail inicial
    */    
    private void enableDocusignResubmit() {
        
        Map<Id, dsfs__DocuSign_Status__c> mapStatus = getMapStatus();
        
        List<Order> listOrdersToEnable = new List<Order>();
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus : triggerNewPME) {
            if(AUTORESPONDED.equalsIgnoreCase(varRecipientStatus.dsfs__Recipient_Status__c) 
               && !mapStatus.get(varRecipientStatus.dsfs__Parent_Status_Record__c).Order__r.DocuSignReenviarAssinatura__c) {
                   Order updateOrder = new Order();
                   updateOrder.Id = mapStatus.get(varRecipientStatus.dsfs__Parent_Status_Record__c).Order__c;
                   updateOrder.DocuSignReenviarAssinatura__c = true;
                   listOrdersToEnable.add(updateOrder);
               }
        }
        update listOrdersToEnable;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Retorna um map com os status dos assinadores
    */    
    private Map<Id, dsfs__DocuSign_Status__c> getMapStatus() {
        
        List<String> listStatusId = new List<String>();
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus : triggerNewPME) {
            listStatusId.add(varRecipientStatus.dsfs__Parent_Status_Record__c);
        }
        
        List<dsfs__DocuSign_Status__c> listStatus = [SELECT Id,
                                                     Order__c,
                                                     Order__r.DocuSignReenviarAssinatura__c
                                                     FROM dsfs__DocuSign_Status__c
                                                     WHERE Id IN :listStatusId];
        
        return new Map<Id, dsfs__DocuSign_Status__c>(listStatus);
    }
}