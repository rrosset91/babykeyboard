/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Controlador do Aura Component CEC_CallCenter_Alerts
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-04      Jean Sganzerla          class created 
**************************************************************************************************************/
public with sharing class CEC_CallCenter_Alerts_Controller {

    private static final Id ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Alerts').getRecordTypeId();
    private static final Id JUNCTION_RECTYPE = SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('Alert').getRecordTypeId();
    
    @AuraEnabled
    public static List<Parameters__c> getAlerts(String aCaseId){

        Case lCase = [SELECT AccountId, ContractBillingAccount__c FROM Case WHERE Id = :aCaseId];
        Set<Id> lParametersSet = new Set<Id>();
        
        for(vlocity_cmt__CustomerInteraction__c lJunction :[SELECT vlocity_cmt__AccountId__c, Alert__c FROM vlocity_cmt__CustomerInteraction__c WHERE RecordTypeId = :JUNCTION_RECTYPE AND Done__c = false AND(vlocity_cmt__AccountId__c = :lCase.AccountId OR vlocity_cmt__AccountId__c = :lCase.ContractBillingAccount__c)]){
            lParametersSet.add(lJunction.Alert__c);
        }
        system.debug('lParametersSet' + lParametersSet);
        if(lParametersSet.isEmpty()) return null;

        Date lToday = system.today();
        List<Parameters__c> lParametersToReturn = [SELECT Id, StartDate__c, EndDate__c, Reason__c, FeedbackToCustomer__c 
            FROM Parameters__c WHERE Id IN :lParametersSet AND RecordTypeId = :ALERTS_RECTYPE AND (StartDate__c <= :lToday AND EndDate__c >= :lToday)];

        return lParametersToReturn;
    }

    @AuraEnabled
    public static String concludeAlertApex(String aAlertId, String aCaseId){
        String lLogerUserId = UserInfo.getUserId();
        List<User> lCommunityField = [SELECT CommunityNickname FROM User WHERE Id = :lLogerUserId];
        Case lCase = [SELECT AccountId, ContractBillingAccount__c FROM Case WHERE Id = :aCaseId];
        List<vlocity_cmt__CustomerInteraction__c> lJunctionToUpdate = [SELECT Done__c, DoneByClaro__c FROM vlocity_cmt__CustomerInteraction__c WHERE RecordTypeId = :JUNCTION_RECTYPE AND Done__c = false AND Alert__c = :aAlertId AND(vlocity_cmt__AccountId__c = :lCase.AccountId OR vlocity_cmt__AccountId__c = :lCase.ContractBillingAccount__c)];

        for(vlocity_cmt__CustomerInteraction__c lJunction :lJunctionToUpdate){
            if(!lCommunityField.isEmpty()) lJunction.DoneByClaro__c = lCommunityField[0].CommunityNickname;
            lJunction.Done__c = true;
        }
        system.debug('lJunctionToUpdate ' + lJunctionToUpdate);
        
        update lJunctionToUpdate;
        return 'Success';
        
    }
}