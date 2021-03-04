/*
* Autor: [Cintia Sousa e Vitor Araújo] + Squad V360 - Deloitte
* Data: [16/12/2019]
* Descrição: [Nome do projeto/ID: CEC FASE Extensão 1 ] 
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
public class CEC_360_ShowProtocolController {

	@AuraEnabled
	public static String getContracBusinessUnit(String contractId) {
		Account acc = [SELECT BusinessUnit__c
					   FROM Account
					   WHERE Id = :contractId LIMIT 1];

		return acc.BusinessUnit__c;
	}

	@AuraEnabled
    public static List<String> getAssetsByBillingAccount(String billingAcountId) {
        
        Set<String> setMSISDNId = new Set<String>();
        List<Asset> lstAssets = [SELECT msisdn__c
                                 FROM Asset 
                                 WHERE vlocity_cmt__BillingAccountId__c = :billingAcountId
                                 AND businessunit__c != 'Net'];
        
        for(Asset varAsset : lstAssets)
            setMSISDNId.add(varAsset.msisdn__c);
        
        return new List<String>(setMSISDNId);
    }
    
	@AuraEnabled
	public static List<CEC_RestObjects.attendences> integrationMobileProtocols(String startDate, String endDate, String msisdn) {
        
        system.debug('MOVEL: ' + msisdn + '|' + startDate + '|' + endDate);

		List<CEC_RestObjects.attendences> lstProtocols = 
            CEC_360_IntegrationMobileProtocols.getProtocols(msisdn, startDate, endDate);

		if(lstProtocols != null) {
			for (CEC_RestObjects.attendences objProtocol :lstProtocols) {
                system.debug(objProtocol);
				objProtocol.solicitationDateOpening = CEC_360_IntegrationMobileProtocols.formatData(objProtocol.solicitationDateOpening);
				objProtocol.solicitationDateClosing = CEC_360_IntegrationMobileProtocols.formatData(objProtocol.solicitationDateClosing);
			}
		}
        system.debug('Protocolos list > ' + lstProtocols);
		return lstProtocols;
	}


	@AuraEnabled
	public static List<CEC_RestObjects.attendences> integrationProtocolsResidential(String startDate, String endDate, String contractId) 
    {
        system.debug('contractId: ' + contractId);
        String contractNumber = [SELECT ContractNumber__c FROM Account WHERE Id = :contractId].ContractNumber__c;
		String operatorCode = contractNumber.substringBefore('/');
        contractNumber = contractNumber.substringAfter('/');
        
        system.debug('RESIDENCIAL: ' + contractNumber + '|' + operatorCode + '|' + startDate + '|' + endDate);

		List<CEC_RestObjects.attendences> lstProtocols = 
            CEC_360_Integration_ProtocolsResidential.getProtocols(contractNumber, operatorCode, startDate, endDate);

		if(lstProtocols != null) {
			for (CEC_RestObjects.attendences objProtocol :lstProtocols) {
                system.debug(objProtocol);
				objProtocol.solicitationDateOpening = CEC_360_Integration_ProtocolsResidential.formatData(objProtocol.solicitationDateOpening);
				objProtocol.solicitationDateClosing = CEC_360_Integration_ProtocolsResidential.formatData(objProtocol.solicitationDateClosing);
			}
		}
        system.debug('Protocolos list > ' + lstProtocols);
		return lstProtocols;
	}
}