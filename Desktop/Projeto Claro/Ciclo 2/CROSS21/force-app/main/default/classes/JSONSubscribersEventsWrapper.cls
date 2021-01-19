/**
 * @description       : Classe wrapper para tratamento do retorno da API
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos-Agregadores

 * @last modified on  : 31-10-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public class JSONSubscribersEventsWrapper {
    @AuraEnabled public String apiVersion;
	@AuraEnabled public String transactionId;
	@AuraEnabled public Data data;

	public class SubscribersVas {
		@AuraEnabled public String serviceName;

		@AuraEnabled public String serviceAggregatorNameSubscribers;

		@AuraEnabled public String serviceAggregatorName;
		@AuraEnabled public String aggregatorName;
		@AuraEnabled public String msisdn;
		@AuraEnabled public String serviceTypeId;
		@AuraEnabled public String serviceType;
		@AuraEnabled public String status;

		@AuraEnabled public String statusSubscribers;
		@AuraEnabled public String statusDate;
		@AuraEnabled public String effectiveDate;
		@AuraEnabled public String expirationDate;
		@AuraEnabled public String formattedExpirationDateSubscribers;
		@AuraEnabled public Date realExpirationDateSubscribers;

		@AuraEnabled public String amount;
		@AuraEnabled public String amountType;
		@AuraEnabled public String cancellationDate;
		@AuraEnabled public String cancellationCode;
		@AuraEnabled public String requestTypeId;
		@AuraEnabled public String requestDescription;
		@AuraEnabled public String statusReasonDescription;
		@AuraEnabled public String confirmationDate;
		@AuraEnabled public String confirmationCode;
		@AuraEnabled public String lastRateDate;
		@AuraEnabled public String rateCode;
		@AuraEnabled public String solicitationDate;

		@AuraEnabled public String formattedSolicitationDateSubscribers;
		@AuraEnabled public Date realSolicitationDateSubscribers;
		@AuraEnabled public String aggregatorDateRequest;
		@AuraEnabled public String id;
		@AuraEnabled public String relatedAccordion;

	}

	public class Data {
		@AuraEnabled public List<SubscribersVas> subscribersVas;
		@AuraEnabled public Object totalRecords;
	}
}