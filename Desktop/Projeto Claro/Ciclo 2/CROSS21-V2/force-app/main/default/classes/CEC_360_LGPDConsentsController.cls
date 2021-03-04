/* 	Autor: Rennê Silva - Sysmap
   	Criação: 25/03/2020
   	Descrição: Classe controller para o componente CEC_360_IntegrationLGPDConsents.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_LGPDConsentsController {
    
	@AuraEnabled
	public static CEC_360_IntegrationConsents.ConsentsData getConsents(String recordId) {
        
        CEC_360_IntegrationConsents.ConsentsData consents = new CEC_360_IntegrationConsents.ConsentsData();
        
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            
            consents = CEC_360_IntegrationConsents.getConsents(acc.DocumentNumber__c); 
		} 

		return consents;
	}
    
    @AuraEnabled
	public static String saveConsents(String recordId, String consents ) { 
        
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        String returnValue = '';
        
        if(acc.DocumentNumber__c != null) {
            returnValue = CEC_360_IntegrationConsents.putConsents(acc.DocumentNumber__c, consents);
		}
        
		return returnValue;
    }

    @AuraEnabled
	public static String getProtocolNumber(String recordId) {
        String ProtocolNumber = '';
        
        System.debug('getProtocolNumber recordId => ' + recordId);
        
        Account acc = [SELECT Id, Name, DocumentType__c, DocumentNumber__c, Phone, Email__c, CustomerTypeList__c 
                         FROM Account 
                        WHERE Id =: recordId];
        
        System.debug('acc => ' + acc );
        
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse response = CEC_LGPD_ProtocolController.integrateLGPDProtocol(acc, 'Consentimento', 'Salesforce');
        
        System.debug('LGPDProtocolControllerResponse response => ' + response);
        
        if(response.data != null && response.data.protocol != ''){
        	ProtocolNumber = response.data.protocol;
        } 
        return ProtocolNumber;
	}
    
    @AuraEnabled
    public static Boolean getPermissionToEditConsents() {
        return FeatureManagement.checkPermission('PermissionToEditConsents');
    }
    
}