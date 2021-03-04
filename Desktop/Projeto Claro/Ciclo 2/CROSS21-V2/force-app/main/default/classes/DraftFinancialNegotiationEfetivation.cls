/**
 * @description       :
 * @author            : Felipe Ducheiko
 * @group             :
 * @last modified on  : 26-01-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   22-01-2021   Felipe Ducheiko   Initial Version
 **/
public class DraftFinancialNegotiationEfetivation {

	private static void saveNegotiationData(FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationJSON efetivationJson, FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		
		if (isEffectiveNegotiation(resp)) {
			updateCase(resp, negotiationWrapper);
			updatePaymentAdjustment(resp, efetivationJson);

			return;
		}

		updateCaseError(negotiationWrapper);
	}

	private static void updateCase (FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		Case cs = new Case();

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
			 
			if (negotiationWrapper.selectedInstallment.quantidadeParcelamento == 1) {
				return 'Negociação Realizada -à vista sem desconto';
			} else {
				return 'Parcelamento sem desconto';
			}

		} else {

			if (negotiationWrapper.selectedInstallment.quantidadeParcelamento == 1) {
				return 'Negociação Realizada -à vista com desconto';
			} else {
				return 'Parcelamento com desconto';
			}
		}
	}

	private static void updateCaseError (FinancialNegotiationEfetivationWrapper negotiationWrapper) {
		Case cs = new Case();

		cs.id = negotiationWrapper.base.caseId;
		cs.status = 'Closed';
		cs.leavingReason__c = 'Negociação não realizada -Erro ao tentar negociar';

		update cs;
	}
	
	private static void updatePaymentAdjustment (FinancialNegotiationEfetivationResponse resp, FinancialNegotiationEfetivationJSON efetivationJson) {
		
		Vlocity_cmt__PaymentAdjustment__c paymentAdjustment = new Vlocity_cmt__PaymentAdjustment__c();

		paymentAdjustment.idExtractItem__c = String.valueOf(resp.termRenegotiationId); //confimar se está correto
		paymentAdjustment.vlocity_cmt__Amount__c = resp.paymentsinglebill; //confimar se está correto
		paymentAdjustment.vlocity_cmt__DisputeId__c = ''; // Verificar, a principio ID do caso
		paymentAdjustment.totalamounttraded__c = 0; //verificar
		paymentAdjustment.discountamountgranted__c = 0; //verificar

		paymentAdjustment.vlocity_cmt__Status__c = 'Negociação Efetivada';
		paymentAdjustment.itemType__c = 'Itens negociados';
		paymentAdjustment.totaldebtvalue__c = efetivationJson.data.total;
		paymentAdjustment.discount__c = efetivationJson.data.discountvalue;
		paymentAdjustment.recordTypeId = Schema.SObjectType.Vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByName().get('Negociação').getRecordTypeId();
		paymentAdjustment.installments__c = String.valueOf(efetivationJson.data.amountinstallments);
		paymentAdjustment.totalamountfirstInstallment__c = efetivationJson.data.firstInstallmentvalue;
		paymentAdjustment.totalamountlastInstallment__c = efetivationJson.data.lastinstallmentvalue;

		update paymentAdjustment;
	}

	private static Boolean isEffectiveNegotiation(FinancialNegotiationEfetivationResponse resp) {
		if (resp == null)
			return false;

		// if (String.isNotEmpty(resp.errorMessageRDCC))
		// 	return false;

		if (String.isNotEmpty(resp.errorMessageRollback))
			return false;

		if (String.isNotEmpty(resp.messageRenegotiation))
			return false;

		return true;
	}
}