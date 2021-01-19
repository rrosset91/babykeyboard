/* 	Autor: Danilo Fucuhara - Deloitte
   	Criação: 20/05/2019
   	Descrição: Classe controller para o componente CEC_360_IntegrationAlerts.
   	Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

public class CEC_360_AlertsController {
	@AuraEnabled
	public static CEC_RestObjects.AlertsMain getAlerts(String recordId) {
		CEC_RestObjects.AlertsMain alerts = new CEC_RestObjects.AlertsMain();
		Asset ass = [SELECT Id, MSISDN__c, RecordTypeId, AccountId FROM Asset WHERE Id =: recordId];
        Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: ass.AccountId];
        String recordType = Schema.SObjectType.Asset.getRecordTypeInfosById().get(ass.RecordTypeId).getDeveloperName();
        
        if(ass.MSISDN__c != null) {
            //alerts = CEC_360_IntegrationAlerts.generateMock();
            alerts = CEC_360_IntegrationAlerts.getAlerts(ass.MSISDN__c, acc.DocumentNumber__c, recordType);
		}
		return alerts;
	}
}