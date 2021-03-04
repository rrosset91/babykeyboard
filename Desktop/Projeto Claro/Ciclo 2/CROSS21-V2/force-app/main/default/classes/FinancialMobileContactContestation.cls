/**
 * @author: Ricardo Alves
 * @company: IBM
 * @description: Classe do componente LWC "SolarFinanceiroContatoCliente"
 */
public class FinancialMobileContactContestation {
	/*
	 * @description: Método para retornar os dados de contato do cliente
	 */
	@AuraEnabled(cacheable=true)
	public static Case getContactInformation(String caseId) {
		return [SELECT contactEmail, contactMobile FROM Case WHERE Id = :caseId];
		//System.debug('Id: ' + caseId);
	}
	@AuraEnabled
	public static String saveContactInformation(String caseId, String ContactPreference, String email, String returnPhone) {
		try {
			Case caso = new Case(Id = caseId);
			caso.ContactPreference__c = ContactPreference;
			caso.Email__c = email;
			caso.Returnphone__c = returnPhone;

			update caso;
			return 'success';
		} catch (Exception ex) {
			return ex.getMessage();
		}
	}
}