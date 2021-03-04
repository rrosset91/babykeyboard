/* 	Autor: Rennê Silva - Sysmap
   	Criação: 21/08/2020
   	Descrição: Classe controller para o componente Aura CEC_360_LGPDConsentsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular / Consentimento
    Alterado por: Guilherme Cuencas 02/09/2020 - 15:11pm
	Time: SQUAD CEC */

public class CEC_360_LGPDConsentsHistoryController {
    
	@AuraEnabled
	public static CEC_360_LGPDIntegrationObjects.GetConsentsHistory getConsentsHistory(String recordId) {
        System.debug('recordId: ' + recordId);
		CEC_360_LGPDIntegrationObjects.GetConsentsHistory consentsHistory = new CEC_360_LGPDIntegrationObjects.GetConsentsHistory();
		Account acc = [SELECT Id, DocumentNumber__c FROM Account WHERE Id =: recordId];
        
        if(acc.DocumentNumber__c != null) {
            consentsHistory = CEC_360_IntegrationConsentsHistory.consentsHistory(acc.DocumentNumber__c);
		}
        system.debug ('API return: ' + consentsHistory);
		return consentsHistory;
	}
    
}