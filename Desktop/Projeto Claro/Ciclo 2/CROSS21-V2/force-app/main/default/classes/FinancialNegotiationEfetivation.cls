/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 29-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
 **/
public without sharing class FinancialNegotiationEfetivation {
	private static final string AUTHORITY_API_SETTINGS = 'InvoiceAuthority';
	private static final string NEGOTIATION_API_SETTINGS = 'AuthorityNegotiation';

	@AuraEnabled
	public static void performNegotiation(String negotiationDetail, String baseAttributes) {
		if (String.isEmpty(negotiationDetail) || String.isEmpty(baseAttributes))
			throw new AuraHandledException('Wrapper/caso não enviado.');

		FinancialNegotiationEfetivationWrapper negotiationWrapper = (FinancialNegotiationEfetivationWrapper) JSON.deserialize(negotiationDetail, FinancialNegotiationEfetivationWrapper.class);
		negotiationWrapper.base = (FinancialNegotiationEfetivationWrapper.FinancialNegotiationEfetivationBase) JSON.deserialize(
			baseAttributes,
			FinancialNegotiationEfetivationWrapper.FinancialNegotiationEfetivationBase.class
		);

		System.debug('negotiationWrapper -> ' + JSON.serializePretty(negotiationWrapper));

		String hashAuthorization = getAuthorization(negotiationWrapper);
		if (hashAuthorization == null)
			throw new AuraHandledException('O operador não tem permissão no legado para realizar essa ação.');

		FinancialNegotiationEfetivationJSON efetivationJson = createEfetivationBody(negotiationWrapper, hashAuthorization);
		System.debug('efetivationJson -> ' + JSON.serializePretty(efetivationJson));
		try {
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(
				JSON.serialize(efetivationJson),
				new Map<String, String>(),
				new Map<String, String>{ 'Content-Type' => 'application/json' },
				NEGOTIATION_API_SETTINGS
			);
			FinancialNegotiationEfetivationResponse resp = new FinancialNegotiationEfetivationResponse('FinancialNegotiationEfetivationResponse', calloutResponse);

			System.debug('FinancialMobileAdjustmentRespJSON -> ' + JSON.serializePretty(resp));

			if (resp.isSuccessfull) {
				raiseCheckException(resp);
				commitItems(resp, efetivationJson, negotiationWrapper);
			} else {
				throw new NegotiationException(resp.getErrorMessage());
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static void commitItems(FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationJSON efetivationJson, FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		if (negotiationWrapper == null || negotiationWrapper.base == null || String.isEmpty(negotiationWrapper.base.caseId))
			return;

		if (isNegotiationEfetivation(resp)) {
			updateCase(resp, negotiationWrapper);
			updatePaymentAdjustment(resp, efetivationJson, negotiationWrapper);

			return;
		}

		updateCaseError(negotiationWrapper);
	}

	private static void updateCase(FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		Case cs = new Case();
		System.debug('negotiationWrapper.base.caseId:' + negotiationWrapper.base.caseId);
		cs.id = negotiationWrapper.base.caseId;
		cs.LeavingReason__c = getLeavingReason(negotiationWrapper);
		cs.Authorization__c = negotiationWrapper.alcadaAprovada;
		cs.Resolution__c = negotiationWrapper.base.comment;
		cs.Status = 'Closed';
		cs.Category__c = 'Negociação de dívida';
		cs.Modalidade__c = 'Renegociação de Valores';
		cs.EntryReason__c = 'Negociação de Dívidas -Até 45 dias';

		update cs;
	}

	private static String getLeavingReason(FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		if (negotiationWrapper.selectedInstallment.descontoParcelamento.equals('Sem desconto')) {
			if (negotiationWrapper.selectedInstallment.quantidadeParcelamento == 1)
				return 'Negociação Realizada -à vista sem desconto';

			return 'Parcelamento sem desconto';
		}

		if (negotiationWrapper.selectedInstallment.quantidadeParcelamento == 1)
			return 'Negociação Realizada -à vista com desconto';

		return 'Parcelamento com desconto';
	}

	private static void updateCaseError(FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		Case cs = new Case();

		cs.id = negotiationWrapper.base.caseId;
		cs.status = 'Closed';
		cs.leavingReason__c = 'Negociação não realizada -Erro ao tentar negociar';

		update cs;
	}

	private static void updatePaymentAdjustment(
		FinancialNegotiationEfetivationResponse resp,
		FinancialNegotiationEfetivationJSON efetivationJson,
		FinancialNegotiationEfetivationWrapper negotiationWrapper
	) {
		Vlocity_cmt__PaymentAdjustment__c paymentAdjustment = new Vlocity_cmt__PaymentAdjustment__c();

		Case cs = [SELECT Id, AccountId FROM Case WHERE id = :negotiationWrapper.base.caseId LIMIT 1];

		Id recordTypeId = Schema.SObjectType.Vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByName().get('Negociação').getRecordTypeId();

		paymentAdjustment.vlocity_cmt__DisputeId__c = negotiationWrapper.base.caseId;
		paymentAdjustment.vlocity_cmt__AccountId__c = cs.AccountId;
		paymentAdjustment.idExtractItem__c = String.valueOf(resp.termRenegotiationId);
		paymentAdjustment.vlocity_cmt__Amount__c = resp.paymentsinglebill;
		paymentAdjustment.totalamounttraded__c = Decimal.valueOf(negotiationWrapper.apiData.total);
		paymentAdjustment.discountamountgranted__c = negotiationWrapper.apiData.discountValue;
		paymentAdjustment.vlocity_cmt__Status__c = 'Negociação Efetivada';
		paymentAdjustment.itemType__c = 'Itens negociados';
		paymentAdjustment.totaldebtvalue__c = efetivationJson.data.total;
		paymentAdjustment.discount__c = efetivationJson.data.discountvalue;
		paymentAdjustment.recordTypeId = recordTypeId;
		paymentAdjustment.installments__c = String.valueOf(efetivationJson.data.amountinstallments);
		paymentAdjustment.totalamountfirstInstallment__c = efetivationJson.data.firstInstallmentvalue;
		paymentAdjustment.totalamountlastInstallment__c = efetivationJson.data.lastinstallmentvalue;

		upsert paymentAdjustment;
	}

	private static Boolean isNegotiationEfetivation(FinancialNegotiationEfetivationResponse resp) {
		FinancialNegotiationEfetivationResponse val = (FinancialNegotiationEfetivationResponse) resp.getData();

		if (resp == null)
			return false;

		// if (String.isNotEmpty(val.errorMessageRDCC))
		// 	return false;

		if (String.isNotEmpty(resp.errorMessageRollback))
			return false;

		if (String.isNotEmpty(resp.messageRenegotiation))
			return false;

		return true;
	}

	private static void raiseCheckException(FinancialNegotiationEfetivationResponse resp) {
		FinancialNegotiationEfetivationResponse val = (FinancialNegotiationEfetivationResponse) resp.getData();
		System.debug('val ->' + JSON.serializePretty(val));

		if (val == null)
			throw new NegotiationException('API Error: Corpo recebido é nulo.');

		// if (String.isNotEmpty(val.errorMessageRDCC))
		// 	throw new NegotiationException('API Error: ' + val.errorMessageRDCC);

		if (String.isNotEmpty(val.errorMessageRollback))
			throw new NegotiationException('API Error: ' + val.errorMessageRollback);

		if (String.isNotEmpty(val.messageRenegotiation))
			throw new NegotiationException('API Error: ' + val.messageRenegotiation);
	}

	private static FinancialNegotiationEfetivationJSON createEfetivationBody(FinancialNegotiationEfetivationWrapper efetivationWrapper, String authHash) {
		FinancialNegotiationEfetivationJSON jsonEfetivation = new FinancialNegotiationEfetivationJSON();
		FinancialNegotiationEfetivationJSON.Data dataObject = new FinancialNegotiationEfetivationJSON.Data();

		dataObject.username = InvoicesUtils.getCalloutUser(NEGOTIATION_API_SETTINGS);
		dataObject.totalTicket = Decimal.valueOf(efetivationWrapper.apiData.totalTicket);
		dataObject.totalInterest = Decimal.valueOf(efetivationWrapper.apiData.totalInterest);
		dataObject.total = Decimal.valueOf(efetivationWrapper.apiData.total);
		dataObject.operatorcode = efetivationWrapper.base.operatorId;
		dataObject.negociationReasonId = 1; //FALTA MAPEAR A RAZÃO
		if (efetivationWrapper.apiData.amount == 2) {
			dataObject.lastInstallmentValue = efetivationWrapper.apiData.lastInstallmentValue;
			dataObject.lastInstallmentTicket = efetivationWrapper.apiData.lastInstallmentTicket;
			dataObject.lastInstallmentInterest = efetivationWrapper.apiData.lastInstallmentInterest;
		} else if (efetivationWrapper.apiData.amount > 2) {
			dataObject.lastInstallmentValue = efetivationWrapper.apiData.lastInstallmentValue;
			dataObject.lastInstallmentTicket = efetivationWrapper.apiData.lastInstallmentTicket;
			dataObject.lastInstallmentInterest = efetivationWrapper.apiData.lastInstallmentInterest;
			dataObject.intermediaryInstallmentValue = efetivationWrapper.apiData.intermediaryInstallmentValue;
			dataObject.intermediaryInstallmenTicket = efetivationWrapper.apiData.intermediaryInstallmenTicket;
			dataObject.intermediaryInstallmenInterest = efetivationWrapper.apiData.intermediaryInstallmenInterest;
		}
		dataObject.hashAuthority = authHash;
		dataObject.firstInstallmentValue = efetivationWrapper.apiData.firstInstallmentValue;
		dataObject.firstInstallmentTicket = efetivationWrapper.apiData.firstInstallmentTicket;
		dataObject.firstInstallmentInterest = efetivationWrapper.apiData.firstInstallmentInterest;
		dataObject.exemptInterestticket = efetivationWrapper.apiData.exemptInterestTicket;
		dataObject.discountvalue = efetivationWrapper.apiData.discountValue;
		dataObject.discountType = 'P';
		dataObject.contractnumber = Long.valueOf(efetivationWrapper.base.contractId);
		dataObject.checkUseitemrenegotiation = 'N'; //N OU S
		dataObject.bills = efetivationWrapper.selectedBills;
		dataObject.statements = efetivationWrapper.statementsIdsString;
		dataObject.amountinstallments = efetivationWrapper.apiData.amount;
		// dataObject.checkChargeNegativity = null; //FALTA VERIFICAR ESSE PARAMETRO
		// dataObject.checkChargeApart = null; //FALTA VERIFICAR ESSE PARAMETRO
		// dataObject.paymentMethodCode = null; //Falta definir
		// dataObject.typeShippingCode = 'E';
		// //"description": "Forma de envio (C - CORREIOS / E - EMAIL)",
		// dataObject.bankCode = null;
		// dataObject.agencyNumber = null;
		// dataObject.accountNumber = null;
		// //"description": "Descrição do Tipo de desconto P -> PORCENTAGEM / V -> VALOR",
		// dataObject.typeNumber = null;
		// dataObject.cardOperatorCode = null;
		// //dataObject.nrip = null;

		jsonEfetivation.data = dataObject;
		return jsonEfetivation;
	}

	private static String getAuthorization(FinancialNegotiationEfetivationWrapper efetivationWrapper) {
		try {
			Map<String, String> authParams = getAuthorizationParams(efetivationWrapper);
			System.debug('authParams -> ' + JSON.serializePretty(authParams));

			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(null, authParams, AUTHORITY_API_SETTINGS);
			AuthorityResponse resp = new AuthorityResponse('FinancialNegotiationEfetivation.AuthorityResponse', calloutResponse);

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

	private static Map<String, String> getAuthorizationParams(FinancialNegotiationEfetivationWrapper wrapper) {
		Map<String, String> params = new Map<String, String>();
		params.put('operatorCode', wrapper.base.operatorId);
		params.put('contractNumber', wrapper.base.contractId);
		params.put('userName', InvoicesUtils.getCalloutUser(AUTHORITY_API_SETTINGS));
		params.put('amount', wrapper.apiData.total.replaceAll(',', '.'));
		params.put('amountTela', wrapper.apiData.total.replaceAll(',', '.'));
		params.put('partnerId', '1');
		params.put('functionalityRuleId', '10');
		return params;
	}

	private static String processAuthorization(AuthorityResponse resp) {
		if (resp != null && resp.authorized != null)
			return resp.hashAuthority;

		if (resp != null && resp.authorized == null && resp.returnMessage != null)
			throw new NegotiationException(resp.returnMessage);

		return null;
	}

	public class NegotiationException extends Exception {
	}

	public class AuthorityResponse extends ClaroAPIBaseResponse {
		public AuthorityResponse() {
		}

		public AuthorityResponse(String specificClassType, Map<String, String> initMap) {
			super(specificClassType, initMap);
		}

		public boolean authorized;
		public string hashAuthority;
		public string returnMessage;
		public string returnCode;
	}
}