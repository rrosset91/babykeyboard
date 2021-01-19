/* 	Autor: Rennê Silva - Sysmap
   	Criação: 25/03/2020
   	Descrição: Classe controller para o componente CEC_360_IntegrationLGPDConsents.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_LGPDConsentsController {
    
	@AuraEnabled
	public static CEC_RestObjects.GetConsents getConsents(String recordId) {
        System.debug('recordId: ' + recordId);
        
		CEC_RestObjects.GetConsents consents = new CEC_RestObjects.GetConsents();
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            //consents = CEC_360_IntegrationConsents.generateMock();
            consents = CEC_360_IntegrationConsents.getConsents(acc.DocumentNumber__c);
		}
        
		return consents;
	}
    
    @AuraEnabled
	public static CEC_RestObjects.PutConsents saveConsents(String recordId,String jsonBody,String purposeId) {
    	System.debug('recordId: ' + recordId);
        
		CEC_RestObjects.PutConsents putConsents = new CEC_RestObjects.PutConsents();
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            //putConsents = CEC_360_IntegrationConsents.generateMockPut();
            putConsents = CEC_360_IntegrationConsents.putConsents(acc.DocumentNumber__c,jsonBody,purposeId);
		}
        
		return putConsents;
    }

    @AuraEnabled
	public static String getProtocolNumber(String recordId) {
        String ProtocolNumber = '';
        
        System.debug('getProtocolNumber -> AccountId(String): ' + recordId);
        Account acc = [SELECT Id, Name, DocumentType__c, DocumentNumber__c, Phone, Email__c, CustomerTypeList__c FROM Account WHERE Id =: recordId];
        
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse response = CEC_LGPD_ProtocolController.integrateLGPDProtocol(acc, 'Consentimento', 'Salesforce');
        if(response.data != null && response.data.protocol != ''){
        	ProtocolNumber = response.data.protocol;
        }
        //MOCKS
        //String ProtocolNumber = '10101010';
        //String ProtocolNumber = '';
        return ProtocolNumber;
	}
    
    @AuraEnabled
    public static Boolean getPermissionToEditConsents() {
        return FeatureManagement.checkPermission('PermissionToEditConsents');
    }
    
}