/**
 * @description       : 
 * @author            : Joao Neves
 * @group             : 
 * @last modified on  : 19-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
**/
public class FinancialNegotiationEfetivation {
	
	@AuraEnabled
	public static NegotiationEfetivationWrapper performNegotiation(String negotitiationBody, String caseId){
		if (caseId == null || negotitiationBody == null || String.isEmpty(negotitiationBody) || String.isEmpty(caseId))
			throw new AuraHandledException('Wrapper/caso não enviado.');



		return null;
	}

	public class NegotationException extends Exception{}

	public class NegotiationEfetivationWrapper{

	}
}