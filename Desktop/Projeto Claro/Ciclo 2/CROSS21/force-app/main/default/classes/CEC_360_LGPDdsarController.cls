/* 	Autor: Rennê Silva - Sysmap
   	Criação:16/06/2020
   	Descrição: Classe controller para o componente CEC_360_IntegrationLGPDdsar.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_LGPDdsarController { 

	@AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.GetDsarByStatus getDsarByType(String recordId, String requestType) {
        System.debug('recordId: ' + recordId);
        
		CEC_360_LGPDIntegrationObjects.GetDsarByStatus responseDsar = new CEC_360_LGPDIntegrationObjects.GetDsarByStatus();
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            //responseDsar = CEC_360_Integrationdsar.generateMock();
            responseDsar = CEC_360_Integrationdsar.getDsarByTypeAndStatusNotClosed(acc.DocumentNumber__c, requestType);
		}
        
		return responseDsar;
	}
    
    @AuraEnabled
	public static Map<String,String> getProtocolNumber(String recordId, String requestType) {
        String ProtocolNumber = '';
        Map<String,String> responseMap = new Map<String,String>();
        System.debug('getProtocolNumber -> AccountId(String): ' + recordId);
        //Id accId = Id.valueOf(recordId);
        Account acc = [SELECT Id, Name, DocumentType__c, DocumentNumber__c, Phone, Email__c, CustomerTypeList__c FROM Account WHERE Id =: recordId];
        //System.debug('getProtocolNumber -> AccountId(Id): ' + accId);
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse response = CEC_LGPD_ProtocolController.integrateLGPDProtocol(acc, requestType, 'Salesforce');
        if(response.data != null && response.data.protocol != ''){
        	//ProtocolNumber = response.data.protocol;
            responseMap.put('protocol', response.data.protocol);
            responseMap.put('caseId', response.data.caseId);
        }
        //MOCKS
        //String ProtocolNumber = '10101010';
        //String ProtocolNumber = '';
        System.debug('ROD LIST' + responseMap);
        return responseMap;
	}
    
    @AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.PostDsar saveDsar(String jsonBody) {
        //System.debug('jsonBody: '+jsonBody);
    	CEC_360_LGPDIntegrationObjects.PostDsar postDsar = new CEC_360_LGPDIntegrationObjects.PostDsar();
		postDsar = CEC_360_Integrationdsar.postDsar(jsonBody);
        //postDsar = CEC_360_Integrationdsar.generateMockPost();
		return postDsar;
    } 
    
    @AuraEnabled
	public static List<CEC_LGPDdsar__mdt> getCustomMetadatadsar() {
		return [SELECT DeveloperName, rightId__c, rightIcon__c, rightName__c, rightDescription__c, hasNotesVisibility__c, isRecordUnique__c, screenSuccessMessage__c, reasons__c
                  FROM CEC_LGPDdsar__mdt
                 WHERE isVisible__c = true
              ORDER BY rightId__c];
	}

	@AuraEnabled
	public static List<CEC_LGPDdsar_AdditionalFields__mdt> getCustomMetadataDsarAdditionalFields() {
		return [SELECT DeveloperName,fieldLabel__c, fixedValue__c, fieldValue__c
                  FROM CEC_LGPDdsar_AdditionalFields__mdt];
	}
    
    @AuraEnabled
	public static Account getCustomerData(String recordId) {
    	return [SELECT Id, vlocity_cmt__BillingEmailAddress__c, DocumentNumber__c, CustomerTypeList__c, 
                (SELECT Id, Email, Phone, MobilePhone, DocumentType__c, DocumentNumber__c FROM Contacts)
                FROM Account WHERE Id =: recordId];
	}
    
    @AuraEnabled
    public static User getUserName() {
        return [SELECT UserName,FederationIdentifier
                  FROM User
                 WHERE UserName = : userinfo.getUserName()];
    }
    
    @AuraEnabled
	public static void updateIdCase(String idDsar, String caseId) {
    	  case caseList = [SELECT id, LGPD_ID__c FROM case  WHERE id =: caseId  LIMIT 1];
        caseList.LGPD_ID__c = idDsar;
        update caseList;

    } 
    
}