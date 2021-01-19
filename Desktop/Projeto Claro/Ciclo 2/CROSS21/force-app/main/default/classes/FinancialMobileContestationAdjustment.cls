/**
 * @description       :
 * @author            : Caio Cesar
 * @group             :
 * @last modified on  : 29-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   22-12-2020   Caio Cesar   	  Initial version
 **/
public without sharing class FinancialMobileContestationAdjustment {
	private static final string ADUSTMENT_SETTINGS = 'MobileContestationAdjustment';

	//Método para POST na API adjustmentcontestations
	@AuraEnabled
	public static AdjustmentReturnWrapper postContestationAdjustment(String ajustmentString, String caseId) {
		if (caseId == null)
			throw new AdjustmentException('Caso relacionado não enviado.');

		AdjustmentReceiveWrapper contestationAdjustment = (AdjustmentReceiveWrapper) JSON.deserialize(ajustmentString, AdjustmentReceiveWrapper.class);
		AdjustmentReturnWrapper response;

		try {
			Map<String, String> headers = new Map<String, String>{ 'X-Client-Auth' => FinancialMobileUtils.getAuth(ADUSTMENT_SETTINGS) };

			//Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(setBodyAdjustment(contestationAdjustment, caseId), new Map<String, String>(), headers, ADUSTMENT_SETTINGS);
			//MOCK
			Map<String, String> calloutResponse = new Map<String, String>{
				'response' => '{"apiVersion":"1;2020-09-28","transactionId":"96dd1a35-6a3d-49d0-9121-c169ee1c25ce","data":{"data":{"accountIdInfo": "123456","adjustmentSequenceNumber": "456789"}}}',
				'statusCode' => '200'
			};
			//MOCK
			FinancialMobileAdjustmentRespJSON resp = new FinancialMobileAdjustmentRespJSON('FinancialMobileAdjustmentRespJSON', calloutResponse);

			System.debug(JSON.serializePretty(resp));

			if (resp.isSuccessfull) {
				response = processAdjustmentResponse((FinancialMobileAdjustmentRespJSON) resp.getData());
			} else {
				throw new AdjustmentException(resp.getErrorMessage());
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

		return response;
	}

	private static AdjustmentReturnWrapper processAdjustmentResponse(FinancialMobileAdjustmentRespJSON responseObject) {
		AdjustmentReturnWrapper adjust = new AdjustmentReturnWrapper();
		adjust.accountIdInfo = responseObject.data.accountIdInfo;
		adjust.adjustmentSequenceNumber = responseObject.data.adjustmentSequenceNumber;
		return adjust;
	}

	private static String setBodyAdjustment(AdjustmentReceiveWrapper contestationAdjustment, String caseId) {
		List<Case> csList = [SELECT ContractBillingAccount__r.ContractReferenceNumber__c, LegacyProtocol__c FROM Case WHERE id = :caseId];

		if (csList.isEmpty())
			throw new AdjustmentException('Caso relacionado não encontrado.');

		Case cs = csList[0];

		if (cs.ContractBillingAccount__r == null || cs.ContractBillingAccount__r.ContractReferenceNumber__c == null || cs.LegacyProtocol__c == null)
			throw new AdjustmentException('Caso relacionado não contém todas as informações obrigatórias.');

		FinancialMobileAdjustmentWrapper.Data contestationAdjustmentBody = new FinancialMobileAdjustmentWrapper.Data();
		FinancialMobileAdjustmentWrapper.AdjustmentItem contestationAdjustmentBodyData = new FinancialMobileAdjustmentWrapper.AdjustmentItem();
		contestationAdjustmentBodyData.accountIdInfo = cs.ContractBillingAccount__r.ContractReferenceNumber__c;
		contestationAdjustmentBodyData.charged = contestationAdjustment.charged;
		contestationAdjustmentBodyData.adjustmentAmount = contestationAdjustment.adjustmentAmount;
		contestationAdjustmentBodyData.adjustmentReasonCode = contestationAdjustment.adjustmentReasonCode;
		contestationAdjustmentBodyData.subscriberNo = contestationAdjustment.subscriberNo;
		contestationAdjustmentBodyData.billSeqNo = contestationAdjustment.billSeqNo;
		contestationAdjustmentBodyData.externalProtocol = cs.LegacyProtocol__c;
		contestationAdjustmentBodyData.userMemo = contestationAdjustment.userMemo;

		contestationAdjustmentBody.data = contestationAdjustmentBodyData;

		return JSON.serialize(contestationAdjustmentBody);
	}

	public class AdjustmentException extends Exception {
	}

	public class AdjustmentReturnWrapper {
		@AuraEnabled
		public String accountIdInfo;
		@AuraEnabled
		public Long adjustmentSequenceNumber;
	}

	public class AdjustmentReceiveWrapper {
		public String accountIdInfo;
		public String charged;
		public String adjustmentAmount;
		public String adjustmentReasonCode;
		public String subscriberNo;
		public String billSeqNo;
		public String externalProtocol;
		public String userMemo;
		public String adjustmentSequenceNumber;
	}
}