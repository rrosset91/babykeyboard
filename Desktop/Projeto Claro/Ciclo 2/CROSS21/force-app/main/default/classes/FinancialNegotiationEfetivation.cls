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
	private static final string AUTHORITY_API_SETTINGS = 'Criar e preencher';
	private static final string NEGOTIATION_API_SETTINGS = 'Criar e preencher';

	@AuraEnabled
	public static EfetivationWrapper performNegotiation(String negotitiationBody, String caseId) {
		if (String.isEmpty(negotitiationBody) || String.isEmpty(caseId))
			throw new AuraHandledException('Wrapper/caso não enviado.');

		FinancialNegotiationEfetivationWrapper negotiationWrapper = (FinancialNegotiationEfetivationWrapper) JSON.deserialize(negotitiationBody, FinancialNegotiationEfetivationWrapper.class);

		System.debug('FinancialNegotiationEfetivationWrapper -> ' + JSON.serializePretty(negotiationWrapper));

		if (!negotiationWrapper.hasAuthority)
			throw new AuraHandledException('Operação não permitida.');

		String hashAuthorization = getAuthorization(negotiationWrapper);
		if (hashAuthorization == null)
			throw new AuraHandledException('O operador não tem permissão no legado para realizar essa ação.');

		FinancialNegotiationEfetivationJSON efetivationJson = createEfetivationBody(negotiationWrapper, hashAuthorization);
		EfetivationWrapper lwcResponse = new EfetivationWrapper();
		try {
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(JSON.serialize(efetivationJson), null, null, NEGOTIATION_API_SETTINGS);
			FinancialNegotiationEfetivationResponse resp = new FinancialNegotiationEfetivationResponse('FinancialNegotiationEfetivationResponse', calloutResponse);

			System.debug('FinancialMobileAdjustmentRespJSON -> ' + JSON.serializePretty(resp));

			if (resp.isSuccessfull) {
				raiseCheckException(resp);
				lwcResponse = commitItems(resp, efetivationJson);
			} else {
				throw new NegotiationException(resp.getErrorMessage());
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

		return lwcResponse;
	}

	private static EfetivationWrapper commitItems(FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationJSON efetivationJson) {
		return null;
	}

	private static void raiseCheckException(FinancialNegotiationEfetivationResponse resp) {
		if (resp.data == null)
			throw new NegotiationException('API Error: Corpo recebido é nulo.');

		if (String.isNotEmpty(resp.data.errorMessageRDCC))
			throw new NegotiationException('API Error: ' + resp.data.errorMessageRDCC);

		if (String.isNotEmpty(resp.data.errorMessageRollback))
			throw new NegotiationException('API Error: ' + resp.data.errorMessageRollback);

		if (String.isNotEmpty(resp.data.messageRenegotiation))
			throw new NegotiationException('API Error: ' + resp.data.messageRenegotiation);
	}

	private static FinancialNegotiationEfetivationJSON createEfetivationBody(FinancialNegotiationEfetivationWrapper efetivationWrapper, String authHash) {
		FinancialNegotiationEfetivationJSON jsonEfetivation = new FinancialNegotiationEfetivationJSON();

		return jsonEfetivation;
	}

	private static String getAuthorization(FinancialNegotiationEfetivationWrapper efetivationWrapper) {
		try {
			Map<String, String> authParams = getAuthorizationParams(efetivationWrapper);
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(null, authParams, AUTHORITY_API_SETTINGS);

			AuthorityResponse resp = new AuthorityResponse('AuthorityResponse', calloutResponse);

			System.debug('AuthorityResponse -> ' + JSON.serializePretty(resp));

			if (resp.isSuccessfull) {
				return processAuthorization((AuthorityResponse) resp.getData());
			} else {
				throw new NegotiationException(resp.getErrorMessage());
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static Map<String, String> getAuthorizationParams(FinancialNegotiationEfetivationWrapper efetivationWrapper) {
		Map<String, String> params = new Map<String, String>();
		params.put('operatorCode', efetivationWrapper.operatorCode);
		params.put('contractNumber', efetivationWrapper.contractNumber);
		params.put('userName', InvoicesUtils.getCalloutUser(AUTHORITY_API_SETTINGS));
		params.put('amount', efetivationWrapper.amount);
		params.put('amountTela', efetivationWrapper.amountTela);
		params.put('partnerId', efetivationWrapper.partnerId);
		params.put('functionalityRuleId', efetivationWrapper.functionalityRuleId);
		params.put('billId', efetivationWrapper.billId);
		params.put('itemGroupId', efetivationWrapper.itemGroupId);
		return params;
	}

	private static String processAuthorization(AuthorityResponse resp) {
		if (resp.data != null && resp.data.authorized)
			return resp.data.hashAuthority;

		return null;
	}

	public class NegotiationException extends Exception {
	}

	public class EfetivationWrapper {
	}

	public class AuthorityResponse extends ClaroAPIBaseResponse {
		public AuthorityResponse() {
		}

		public AuthorityResponse(String specificClassType, Map<String, String> initMap) {
			super(specificClassType, initMap);
		}

		public Data data;
	}

	public class Data {
		public boolean authorized;
		public string hashAuthority;
	}
}
