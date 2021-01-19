/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Batch Class to purge expirated Call Center Alerts Data
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-11-02      Jean Sganzerla          class created 
**************************************************************************************************************/
global class Solar_Cross_CallCenterAlertsPurgeBatch implements Schedulable, Database.Batchable<SObject>{
    
    //CRON configurado para rodar todos os dias à 1:00 da manhã    
    /* Solar_Cross_CallCenterAlertsPurgeBatch lSb = new Solar_Cross_CallCenterAlertsPurgeBatch();
    String lSch = '0 0 1 * * ? *';
    String jobID = system.schedule('Call Center Alert Purge', lSch, lSb);*/
    
    private static final Id SEGMENTED_ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Alerts').getRecordTypeId();
    private static final Id GENERAL_ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('GeneralAlerts').getRecordTypeId();
    
    global void execute(SchedulableContext sc) {
        Solar_Cross_CallCenterAlertsPurgeBatch lBatch = new Solar_Cross_CallCenterAlertsPurgeBatch();
        Database.executeBatch(lBatch);
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Parameters__c> lAlertsToPurgeLst = new List<Parameters__c>();
        //utiliza a Custom Label CallCenterAlertsExpirationDays para armazernar um valor inteiro com a quantidade de dias além da data fim do alerta, que será usado como critério para excluir os alertas. Por padrão, o valor armazenado na label é -3.
        Date lExpirationDate =  system.today().addDays(Integer.valueOf(Label.CallCenterAlertsExpirationDays)); 
        system.debug('Expiration Date ' + lExpirationDate);

        for(Parameters__c lAlert :[SELECT Id FROM Parameters__c WHERE RecordTypeId = :SEGMENTED_ALERTS_RECTYPE AND (EndDate__c <= :lExpirationDate OR EndDate__c = null)]){
            lAlertsToPurgeLst.add(lAlert);
        }

        return Database.getQueryLocator([SELECT Id, Alert__c, Name FROM ParametersJunction__c WHERE Alert__c IN :lAlertsToPurgeLst OR (Alert__c = null OR Account__c = null)]);
    }

    global void execute(Database.BatchableContext BC, List<ParametersJunction__c> aParametersJunctionLst) { 
        Set<Id> lAlertToPurgeSet = new Set<Id>();
        for(ParametersJunction__c lJunction :aParametersJunctionLst){
            lAlertToPurgeSet.add(lJunction.Alert__c);
        }

        system.debug('Junction Alerts to purge ' + aParametersJunctionLst);
        Database.delete(aParametersJunctionLst, false);
                
        // TRECHO ABAIXO COMENTADO POIS NÃO SERÁ NECESSÁRIA A EXCLUSÃO DOS ALERTAS NESSE MOMENTO
        // Date lExpirationDate = system.today().addDays(Integer.valueOf(Label.CallCenterAlertsExpirationDays));         
        // List<Parameters__c> lAlertsToPurgeLst = [SELECT Id FROM Parameters__c WHERE (Id IN :lAlertToPurgeSet AND (EndDate__c <= :lExpirationDate OR EndDate__c = null)) OR ((EndDate__c <= :lExpirationDate OR EndDate__c = null) AND RecordTypeId = :GENERAL_ALERTS_RECTYPE)];
        
        // system.debug('Alerts to purge ' + lAlertsToPurgeLst);
        // if(!lAlertsToPurgeLst.isEmpty()) Database.delete(lAlertsToPurgeLst, false);
    }

    global void finish(Database.BatchableContext BC) {} 
}