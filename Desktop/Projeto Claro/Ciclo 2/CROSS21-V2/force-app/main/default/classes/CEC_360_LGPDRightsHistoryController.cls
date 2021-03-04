/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 09/07/2020
   	Descrição: Classe controller para o componente CEC_360_LGPDRightsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */

public class CEC_360_LGPDRightsHistoryController {
     
	@AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.getRightsHistory getOrdersRightsHistory(String recordId) {
        System.debug('recordId: ' + recordId);
        
		CEC_360_LGPDIntegrationObjects.getRightsHistory ordersHistoric = new CEC_360_LGPDIntegrationObjects.getRightsHistory();
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            ordersHistoric = CEC_360_IntegrationRightsHistory.OrdersRightsHistory(acc.DocumentNumber__c);
            
		}
        system.debug ('REtornooo' + ordersHistoric);
        
       
        
		return ordersHistoric;
	}
    
    
    
    
    @AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails getOrdersDetailsRightsHistory(String recordId) {
        System.debug('recordId: ' + recordId);
        
		CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails ordersHistoricDetails = new CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails();
	
        
        if(recordId != null) {
            //consents = CEC_360_IntegrationConsents.generateMock();
            ordersHistoricDetails = CEC_360_IntegrationHistoryDetails.GetHistoryOrdersDetails(recordId);
		}
        system.debug ('REtornooo' + ordersHistoricDetails);
        
       
        
		return ordersHistoricDetails;
	}
    
        @AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract  getExtractRightsHistory(String recordId) {
  //      System.debug('recordId: ' + recordId);
        
		CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract  extract = new CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract();
	
        
        if(recordId != null) {
            //consents = CEC_360_IntegrationConsents.generateMock();
            extract = CEC_360_IntegrationHistoryExtract.getHistoryExtract(recordId);
		}
        system.debug ('REtornooo' + extract);
        
       
        
		return extract;
	}
   @AuraEnabled
    public static Boolean getPermissonToExtract() {
        return FeatureManagement.checkPermission('PermissonToExtract');
    }
    
}