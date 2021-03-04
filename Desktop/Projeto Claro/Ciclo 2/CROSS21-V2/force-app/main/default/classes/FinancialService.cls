/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 23-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-01-2021   Joao Neves   Initial Version
 **/
public with sharing class FinancialService {
	public static CEC_DisputeInvoice.DisputeInvoiceResponse createDispute(CEC_DisputeInvoice.DisputeInvoiceRequest invoice, String username, Boolean createCase, Boolean hasAuthority, Boolean createItens) {
		System.debug('@@@ createCase -> ' + createCase);
		System.debug('@@@ createItens -> ' + createItens);
		System.debug('@@@ hasAuthority -> ' + hasAuthority);
		System.debug('@@@ invoice -> ' + JSON.serializePretty(invoice));

		username = InvoicesUtils.getCalloutUser('ContestItem');
		Map<String, String> params = setParamsDispute(invoice.contractNumber, invoice.operatorCode, invoice.idInvoice, username);
		System.debug('@@@ params -> ' + JSON.serializePretty(params));
		String body = setBodyDispute(invoice, username);
		Map<String, String> headers = setHeaders();
		System.debug('@@@ body -> ' + JSON.serializePretty(body));
		Integer statusCode = 200;
		Boolean hasError = false;
		String errorMessage = '';
		String newBillId = '';

		if (hasAuthority) {
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(body, params, headers, 'ContestItem');
			statusCode = Integer.valueOf(calloutResponse.get('statusCode'));

			if (statusCode >= 400) {
				hasError = true;
				errorMessage = 'Claro API Erro: ' + getErrorMessage(calloutResponse.get('response'));
			} else {
				ContestationResult constResult = processContestationResult(calloutResponse.get('response'));
				System.debug('@@@ constResult -> ' + JSON.serializePretty(constResult));
				newBillId = getNewBillId(constResult);
			}
		}

		if (!createCase) {
			//Fluxo de contestacao
			if (hasError) {
				if (statusCode >= 500) {
					//
					// @note 92819 Fechamento do Caso de Contestação em caso de falha de API - callerror 500
					//get  if current User is a N2Operator, if not the case will be closed
					errorMessage = FinancialCaseManagement.updateCaseAPIErrorContestation(invoice);
				}
				return new CEC_DisputeInvoice.DisputeInvoiceResponse('500', errorMessage, null);
			} else {
				return new CEC_DisputeInvoice.DisputeInvoiceResponse(newBillId);
			}
		}

		//Somente CRM
		Solar_Cross_CasesController.SolarCaseResponseWrapper cs = crmCrossCaseProvider(invoice, hasAuthority);
		System.debug('@@@ cs -> ' + JSON.serializePretty(cs));

		if (cs == null || cs.casoId == null)
			return new CEC_DisputeInvoice.DisputeInvoiceResponse('500', 'contrato com esse numero não encontrado', new CEC_DisputeInvoice.Caso());

		if (createItens)
			createPaymentItems(hasAuthority, invoice, cs.casoId, cs.contratoId, 'Itens_Contestados');

		if (hasError) {
			return new CEC_DisputeInvoice.DisputeInvoiceResponse('200', errorMessage, new CEC_DisputeInvoice.Caso(invoice.contractNumber, cs.protocolo, cs.status, cs.casoId, invoice.invoiceItems));
		} else {
			return new CEC_DisputeInvoice.DisputeInvoiceResponse(new CEC_DisputeInvoice.Caso(invoice.contractNumber, cs.protocolo, cs.status, cs.casoId, invoice.invoiceItems));
		}
	}

	private static String getNewBillId(ContestationResult res) {
		ContestationResult.ContestationBillItems bi = new ContestationResult.ContestationBillItems();

		for (ContestationResult.ContestationBillItems itemInst : res.data.contestationBillItems)
			if (itemInst.status == 'Em Aberto') {
				bi = itemInst;
				break;
			}

		if (bi.billId != null)
			return String.valueOf(bi.billId);

		return null;
	}

	private static ContestationResult processContestationResult(String jsonString) {
		ContestationResult response = (ContestationResult) JSON.deserialize(jsonString, ContestationResult.class);
		return response;
	}

	public static Map<String, Object> getElegibility(String contract, String operatorCode, String billId, String userName) {
		Map<String, Object> data = new Map<String, Object>();

		try {
			username = InvoicesUtils.getCalloutUser('InvoiceElegibility');
			Map<String, String> params = setParamsElegibility(contract, operatorCode, billId, userName);
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoiceElegibility');
			//MOCK
			System.debug('response pre' + calloutResponse.get('response'));

			// calloutResponse.put('statusCode','200');
			// calloutResponse.put('response', stringMock);
			System.debug('response pos' + calloutResponse.get('response'));
			//End Mock
			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				data.put('success', true);
				data.put('items', processElegibility(calloutResponse.get('response')));
			} else {
				data.put('success', false);
				data.put('message', getErrorMessage(calloutResponse.get('response')));
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

		return data;
	}

	public static Map<String, Object> getAuthority(CEC_DisputeInvoice.DisputeInvoiceRequest req, String operator, String contract, String username, Decimal amount, Integer partnerId, String billId) {
		if (operator == null || contract == null || amount == null || billId == null)
			return null;

		if (partnerId == null)
			partnerId = 1;

		if (username == null)
			username = InvoicesUtils.getCalloutUser('InvoiceAuthority');

		return FinancialHierarchy.getAuthority(req, operator, contract, username, amount, partnerId, billId);
	}

	@TestVisible
	private static InvoiceDetailsWrapper processInvoiceDetails(String jsonString) {
		JSONInvoiceDetails response = (JSONInvoiceDetails) JSON.deserialize(jsonString, JSONInvoiceDetails.class);
		InvoiceDetailsWrapper invoiceDetailsWrp = new InvoiceDetailsWrapper();
		invoiceDetailsWrp.tipoFatura = 'Fatura';
		invoiceDetailsWrp.produto = 'TV + Virtua + Telefone'; //Claro está levantando quais nome de itens da fatura eles irão mostrar para nós processarmos
		invoiceDetailsWrp.status = response.data.status;
		invoiceDetailsWrp.valor = (response.data.amount != null) ? 'R$' + response.data.amount : 'R$0,00';

		if (response.data.dueDay != null)
			invoiceDetailsWrp.dataVencimento = InvoicesUtils.setFormattedDate(response.data.dueDate);

		if (response.data.paymentDate != null)
			invoiceDetailsWrp.dataPagamento = InvoicesUtils.setFormattedDate(response.data.paymentDate);

		if (response.data.executeDate != null)
			invoiceDetailsWrp.dataBaixa = InvoicesUtils.setFormattedDate(response.data.executeDate);

		List<InvoiceDetailsWrapper.InvoiceProducts> products = new List<InvoiceDetailsWrapper.InvoiceProducts>();

		for (JSONInvoiceDetails.InvoiceItem instItem : response.data.invoiceItems) {
			InvoiceDetailsWrapper.InvoiceProducts product = new InvoiceDetailsWrapper.InvoiceProducts();
			product.invoiceItem = instItem.name;
			product.descricao = instItem.description;
			product.valor = (instItem.amount != null) ? 'R$' + instItem.amount : 'R$0,00';
			products.add(product);
		}

		invoiceDetailsWrp.detalheProdutos = products;
		return invoiceDetailsWrp;
	}

	@TestVisible
	private static List<ElegibilityWrapper> processElegibility(String jsonString) {
		JSONElegibility response = JSONElegibility.parse(jsonString);
		List<ElegibilityWrapper> invoiceDetailsWrp = new List<ElegibilityWrapper>();
		JSONElegibility.Data instItem = response.data;

		if (instItem == null)
			return invoiceDetailsWrp;

		for (JSONElegibility.Charges instCharg : instItem.charges) {
			System.debug('instCharg: ' + JSON.serialize(instCharg));
			// if(instCharg.partnerId != '1')
			// 	continue;

			Double amountAgainsDeparture = instCharg.amountAgainstDeparture;

			for (JSONElegibility.Installments installment : instCharg.installments) {
				System.debug('installment: ' + installment);
				ElegibilityWrapper elegibility = new ElegibilityWrapper();
				if (instCharg.partnerId == '1') {
					if (installment.itemGrouper != null)
						continue;

					elegibility.allowOnlyRecalculate = response.data.allowOnlyRecalculate;
					elegibility.billId = instItem.billId;
					elegibility.partnerId = instCharg.partnerId;
					elegibility.extractItemId = installment.idExtractItem != null ? installment.idExtractItem : null;
					elegibility.allowContestation = installment.allowContestation;
					elegibility.dueDate = installment.dueDate;
					elegibility.amountAgainstDeparture = amountAgainsDeparture;

					List<Integer> reasons = new List<Integer>();
					for (JSONElegibility.ContestationTypes tp : installment.contestationTypes) {
						reasons.add(tp.idReasonDisputes);
					}
					elegibility.contestationReasons = reasons;
				} else {
					elegibility.allowOnlyRecalculate = response.data.allowOnlyRecalculate;
					elegibility.billId = instItem.billId;
					elegibility.partnerId = instCharg.partnerId;
					elegibility.extractItemId = installment.idPartnerStatement != null ? installment.idPartnerStatement : null;
					System.debug(installment.idDetExtractItem);
					// elegibility.partnerStatementId = installment.idPartnerStatement != null ? Integer.valueOf(installment.idPartnerStatement) : null;
					elegibility.detExtractItemId = installment.idDetExtractItem != null ? installment.idDetExtractItem : null;
					elegibility.allowContestation = installment.allowContestation;
					elegibility.dueDate = installment.dueDate;
					elegibility.amountAgainstDeparture = amountAgainsDeparture;

					List<Integer> reasons = new List<Integer>();
					for (JSONElegibility.ContestationTypes tp : installment.contestationTypes) {
						reasons.add(tp.idReasonDisputes);
					}
					elegibility.contestationReasons = reasons;
				}

				invoiceDetailsWrp.add(elegibility);
			}
		}

		return invoiceDetailsWrp;
	}

	@TestVisible
	private static String setErrorMessage(String jsonString) {
		String errorMessage = '';
		JSONEvents errorResponse = (JSONEvents) JSON.deserialize(jsonString, JSONEvents.class);
		if (errorResponse != null) {
			if (errorResponse.error != null) {
				errorMessage = errorResponse.error.errorCode + ' - ' + errorResponse.error.detailedMessage;
			} else {
				errorMessage = 'Unknown error';
			}
		} else {
			errorMessage = 'Unknown error';
		}
		return errorMessage;
	}

	@TestVisible
	private static List<vlocity_cmt__PaymentAdjustment__c> createPaymentItems(Boolean hasAuthority, CEC_DisputeInvoice.DisputeInvoiceRequest invoice, Id caseId, Id accountId, String recordType) {
		return FinancialCaseManagement.createPaymentItems(hasAuthority, invoice, caseId, accountId, recordType);
	}

	@TestVisible
	private static Map<String, String> setParamsDispute(String contractNumber, String operatorCode, String billId, String username) {
		Map<String, String> params = new Map<String, String>();

		return params;
	}

	@TestVisible
	private static Map<String, String> setParamsElegibility(String contract, String operatorCode, String billId, String userName) {
		Map<String, String> params = new Map<String, String>();

		params.put('contractNumber', contract);
		params.put('operatorCode', operatorCode);
		params.put('billId', billId);
		params.put('userName', userName);
		params.put('page', '1');
		params.put('limit', '1000');

		return params;
	}

	@TestVisible
	private static Solar_Cross_CasesController.SolarCaseResponseWrapper crmCrossCaseProvider(CEC_DisputeInvoice.DisputeInvoiceRequest req, Boolean hasAuth) {
		System.debug('crmCrossCaseProvider.req ==>'+ JSON.serializePretty(req));
		List<Account> contractList = [SELECT Id, ExternalId__c FROM Account WHERE ContractReferenceNumber__c = :req.contractNumber AND ContractReferenceNumber__c != NULL];

		if (contractList.isEmpty())
			return null;

		//SolarCaseRequestWrapper wrapper = new SolarCaseRequestWrapper();
		//Solar_Cross_CasesController
		Solar_Cross_CasesController.SolarCaseRequestWrapper wrapper = new Solar_Cross_CasesController.SolarCaseRequestWrapper();
		wrapper.idExterno = contractList[0].ExternalId__c;
		wrapper.codigoProcesso = 'RealizarContestacao';
		wrapper.canal = 'Digital';
		wrapper.idContrato = req.contractNumber;
		wrapper.contractNumber = req.contractNumber;
		wrapper.fluxo = ''; //FALTA DEFINICAO
		wrapper.idCliente = contractList[0].Id;
		//wrapper.contractNumber = contractList[0].Id;
		wrapper.modalidadeServico = ''; //FALTA DEFINICAO
		wrapper.operatorCode = req.operatorCode;
		wrapper.origem = ''; //FALTA DEFINICAO
		wrapper.protocolo = ''; //FALTA DEFINICAO
		//wrapper.servico = assets[0].Id; //FALTA DEFINICAO
		wrapper.subCategoria = ''; //FALTA DEFINICAO
		wrapper.subMotivo = ''; //FALTA DEFINICAO
		wrapper.tipoAtendimento = ''; //FALTA DEFINICAO
		wrapper.idFatura = req.idInvoice;
		wrapper.status = hasAuth ? 'Closed' : 'New';
		wrapper.scritpPointDetail = req.descricaoSolicitacao;
		if (hasAuth) {
			wrapper.motivoEntrada = 'Validação de Contestação de Valores';
			wrapper.motivoSaida = 'Contestação Realizada';
		} else {
			wrapper.motivoEntrada = 'Validação de Contestação de Valores';
			wrapper.motivoEncaminhamento = 'Fora da alçada';
		}
		return Solar_Cross_CasesController.SolarCreateCase(wrapper);
	}

	@TestVisible
	private static String getErrorMessage(Object responseData) {
		if (responseData == null)
			return 'erro de integracao. A mensagem retornada é nula.';

		String errorKey = 'error';

		Map<String, Object> untypedResponse = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(responseData));
		Map<String, Object> untypedError = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedResponse.get(errorKey)));

		return String.valueOf(untypedError.get('message'));
	}

	@TestVisible
	private static String setBodyDispute(CEC_DisputeInvoice.DisputeInvoiceRequest invoiceObject, String username) {
		List<Account> acc = [SELECT ParentId, Parent.Name, Parent.CellPhone__c, Parent.vlocity_cmt__BillingEmailAddress__c FROM Account WHERE ContractReferenceNumber__c = :invoiceObject.contractNumber AND Parent.RecordType.Name = 'Consumer'];

		String phone = '999999999';
		String email = 'naotem@naotem.com';
		String ddd = '11';
		String name = 'Nao tem';
		phone = '999999999';
		email = 'naotem@naotem.com';
		ddd = '11';
		name = 'Nao tem';
		phone = '999999999';
		email = 'naotem@naotem.com';
		ddd = '11';
		name = 'Nao tem';

		if (!acc.isEmpty() && acc[0].ParentId != null) {
			if (acc[0].Parent.CellPhone__c != null) {
				ddd = acc[0].Parent.CellPhone__c.left(2);
				phone = acc[0].Parent.CellPhone__c.right(9).trim();
			}

			email = acc[0].Parent.vlocity_cmt__BillingEmailAddress__c;
			name = acc[0].Parent.Name;
		}

		System.debug('Valor da conta -> ' + JSON.serializePretty(acc));

		List<JSONDisputeBody.ContestationStatements> contestationItems = new List<JSONDisputeBody.ContestationStatements>();
		JSONDisputeBody body = new JSONDisputeBody();
		JSONDisputeBody.Data data = new JSONDisputeBody.Data();

		data.operatorCode = invoiceObject.operatorCode;
		data.contractNumber = invoiceObject.contractNumber.replaceFirst('^0+(?!$)', '');
		data.userName = username;
		data.billId = invoiceObject.idInvoice;
		data.name = name;
		data.ddd = ddd;
		data.phoneNumber = phone;
		data.email = email;
		data.contestactionOrigin = invoiceObject.source;
		data.contestactionType = invoiceObject.type;
		//NAO DESMOCAR O L
		data.sendMethod = 'L';
		//NAO DESMOCAR O L
		//data.sendMethod = invoiceObject.channel;

		for (CEC_DisputeInvoice.InvoiceItem item : invoiceObject.invoiceItems) {
			JSONDisputeBody.ContestationStatements constItem = new JSONDisputeBody.ContestationStatements();
			if (item.partnerId == '1') {
				constItem.idExtractItem = Long.valueOf(item.idInvoiceItem); //Isso ta correto?
				constItem.hashAuthority = item.approvationHash;
			}
			if (item.partnerId == '2') {
				constItem.idDetExtractItem = Long.valueOf(item.idDetExtractItem);
				constItem.idPartnerStatement = Long.valueOf(item.idPartnerStatement);
				constItem.hashAuthority = item.approvationHash;
			}
			if (item.partnerId == '16') {
				constItem.idDetExtractItem = Long.valueOf(item.idDetExtractItem);
				constItem.idPartnerStatement = Long.valueOf(item.idPartnerStatement);
			}
			if (item.groupDeparture == null)
				item.groupDeparture = 0;

			constItem.amont = (item.originalValue - item.wishedValue) + item.groupDeparture;
			constItem.contestationreasonid = Integer.valueOf(item.reason); //Verificar tipos
			//Bug 10309669
			//constItem.note = item.notes;
			constItem.note = item.notes.abbreviate(100);
			//fim bug
			constItem.partnerid = Integer.valueOf(item.partnerId); //Nao temos partner

			contestationItems.add(constItem);
		}

		data.contestationStatements = contestationItems;
		System.debug('!!!!!!!!!!!!!!!!!!!!!!>>>>> data: ' + data);

		body.data = data;

		System.debug('body: ' + JSON.serializePretty(body));

		return JSON.serialize(body);
	}

	@TestVisible
	private static Map<String, String> setheaders() {
		Map<String, String> retMap = new Map<String, String>();
		retMap.put('Content-Type', 'application/json');
		return retMap;
	}

	public class ElegibilityWrapper {
		@AuraEnabled
		public String billId;
		@AuraEnabled
		public String partnerId;
		@AuraEnabled
		public Long extractItemId;
		@AuraEnabled
		public Long partnerStatementId;
		@AuraEnabled
		public Long detExtractItemId;
		@AuraEnabled
		public String dueDate;
		@AuraEnabled
		public boolean allowOnlyRecalculate;
		@AuraEnabled
		public Boolean allowContestation;
		@AuraEnabled
		public Double amountAgainstDeparture;
		@AuraEnabled
		public List<Integer> contestationReasons;
	}

	public class EventsControllerException extends Exception {
	}
}