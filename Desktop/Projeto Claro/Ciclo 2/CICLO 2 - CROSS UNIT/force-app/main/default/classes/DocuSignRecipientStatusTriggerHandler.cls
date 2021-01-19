/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Trigger Handler de dsfs__DocuSign_Recipient_Status__c
*  ---------------------------------------------------------------
*/
public class DocuSignRecipientStatusTriggerHandler {
    
    public List<dsfs__DocuSign_Recipient_Status__c> listNew {get;set;}
        
    public void onAfterInsert() {
        updateOrder();
        enableDocusignResubmit();
    }
    
    public void onAfterUpdate() {
        updateOrder();     
        enableDocusignResubmit();
    } 
    
    private void updateOrder() {
        List<String> listStatusId = new List<String>();
        Set<Id> setCompletedRecipientStatusId = new Set<Id>();
        
        // Preencher set de recipients que foram marcados como Completed
        // Preencher lista de DocuStatus de recipients que foram marcados como Completed
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus: listNew) {
            if(String.isNotBlank(varRecipientStatus.dsfs__Recipient_Status__c) && varRecipientStatus.dsfs__Recipient_Status__c.equalsIgnoreCase('Completed')) {
                setCompletedRecipientStatusId.add(varRecipientStatus.Id);
                listStatusId.add(varRecipientStatus.dsfs__Parent_Status_Record__c);
            }
        }
        
        List<dsfs__DocuSign_Status__c> listStatus = [SELECT Id,
                                                     Order__c,
                                                     Order__r.AccountId,
                                                     (SELECT Id,
                                                      Name,
                                                      dsfs__Recipient_Status__c,
                                                      dsfs__DocuSign_Recipient_Email__c
                                                      FROM R00NS0000000WUO2MAO__r
                                                      WHERE AssinaturaObrigatoria__c = true
                                                      AND dsfs__Recipient_Status__c <> 'Completed')
                                                      //Trigger é onAfter, logo todos já estão como Completed na base
                                                      //AND Id NOT IN :setCompletedRecipientStatusId)
                                                     FROM dsfs__DocuSign_Status__c
                                                     WHERE Id IN :listStatusId
                                                     AND (Order__r.Status = 'Contrato Criado'
                                                          OR Order__r.Status = 'Aguardando Assinatura')];
        
        Map<Id, Account> mapAccount = getMapAccount(listStatus);
        Map<Id, Order> mapOrder = getMapOrder(listStatus);
        Map<Id, List<Id>> mapOwnerIdLstHierId = CEC_PME_HierarchyUtil.getMapOwnerIdLstHierId(mapOrder.values());
        
        List<Order> listOrderUp = new List<Order>();
        List<Account> listAccountUp = new List<Account>();

        for(dsfs__DocuSign_Status__c varStatus : listStatus) {
            Account varAccount = mapAccount.get(varStatus.Order__r.AccountId);
            Order varOrder = mapOrder.get(varStatus.Order__c);

            Boolean isClose = varStatus.R00NS0000000WUO2MAO__r == null || varStatus.R00NS0000000WUO2MAO__r.isEmpty();
                      
            if(isClose && varOrder.Id != null) {
                
                Order orderUp = new Order();
                orderUp.Id = varOrder.Id;
                
                system.debug('mapOwnerIdLstHierId ' + mapOwnerIdLstHierId);
                system.debug('mapOwnerIdLstHierId.get(varOrder.OwnerId) ' + mapOwnerIdLstHierId.get(varOrder.OwnerId));
                if(mapOwnerIdLstHierId.containsKey(varOrder.OwnerId) && mapOwnerIdLstHierId.get(varOrder.OwnerId).size() == 1) {
                    Account upAccount = new Account();
                    upAccount.Id = varOrder.AccountId;
                    upAccount.Hierarchy__c = mapOwnerIdLstHierId.get(varOrder.OwnerId).get(0);
                    listAccountUp.add(upAccount);
                    
                    orderUp.Status = 'Território Associado';
                } else {
                    orderUp.Status = 'Contrato Assinado';
                }
                
                listOrderUp.add(orderUp);
            }
        }

        if(!listOrderUp.isEmpty()) {
            update listOrderUp;
        }
        
        if(!listAccountUp.isEmpty()) {
            update listAccountUp;
        }
    }
    
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
    
    private void enableDocusignResubmit() {
        
        Map<Id, dsfs__DocuSign_Status__c> mapStatus = getMapStatus();
        
        List<Order> listOrdersToEnable = new List<Order>();
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus: listNew) {
            if('AutoResponded'.equalsIgnoreCase(varRecipientStatus.dsfs__Recipient_Status__c) 
               && !mapStatus.get(varRecipientStatus.dsfs__Parent_Status_Record__c).Order__r.DocuSignReenviarAssinatura__c) {
                   Order updateOrder = new Order();
                   updateOrder.Id = mapStatus.get(varRecipientStatus.dsfs__Parent_Status_Record__c).Order__c;
                   updateOrder.DocuSignReenviarAssinatura__c = true;
                   listOrdersToEnable.add(updateOrder);
               }
        }
        update listOrdersToEnable;
    }
    
    private Map<Id, dsfs__DocuSign_Status__c> getMapStatus() {
        
        List<String> listStatusId = new List<String>();
        for(dsfs__DocuSign_Recipient_Status__c varRecipientStatus: listNew) {
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