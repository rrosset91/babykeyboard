/*
 * Autor: João Neves
 * Data: 03/07/2020
 * Descrição: API to Dispute Invoice with case creation
 */
@RestResource(urlMapping='/api/DisputeInvoice/*')
global with sharing class CEC_DisputeInvoice {
	private static final List<String> REQUIRED_FIELDS_INVOICE = new List<String>{ 'contractNumber', 'operatorCode', 'channel', 'idInvoice', 'invoiceItems', 'userName', 'source' };
	private static final List<String> REQUIRED_FIELDS_ITEM = new List<String>{ 'idGroupItem', 'reason', 'originalValue', 'status', 'wishedValue' };

	@HttpPost
	global static DisputeInvoiceResponse disputeInvoice(DisputeInvoiceRequest entrada) {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		if (entrada == null)
			return new DisputeInvoiceResponse('400', 'dispute object is nul');

		List<String> missingFields = checkRequiredFieldsInvoice(entrada);
		if (!missingFields.isEmpty())
			return new DisputeInvoiceResponse('400', 'missing fields: ' + String.join(missingFields, ','));

		if (entrada.invoiceItems == null)
			return new DisputeInvoiceResponse('400', 'dispute items are empty');

		Map<Integer, List<String>> missingItems = checkRequiredFieldsItem(entrada.invoiceItems);

		if (!missingItems.isEmpty()) {
			String missingText = '';

			for (Integer currPos : missingItems.keySet())
				missingText = missingText + ' item position: ' + currPos + ' fields: ' + String.join(missingItems.get(currPos), ',');

			return new DisputeInvoiceResponse('400', 'dispute items are missing propertiess:' + missingText);
		}

		Set<String> groupIds = new Set<String>();
		Map<String, Decimal> valuesByGroup = new Map<String, Decimal>();

		for (InvoiceItem invItem : entrada.invoiceItems) {
			groupIds.add(invItem.partnerId);

			if (valuesByGroup.containsKey(invItem.partnerId)) {
				Decimal val = valuesByGroup.get(invItem.partnerId);
				val = val + (invItem.originalValue - invItem.wishedValue);

				valuesByGroup.put(invItem.partnerId, val);
			} else {
				valuesByGroup.put(invItem.partnerId, invItem.originalValue - invItem.wishedValue);
			}
		}

		Map<String, Decimal> stgDecimal = new Map<String, Decimal>();

		for (InvoiceItem invItem : entrada.invoiceItems) {
			if (!stgDecimal.containsKey(invItem.partnerId)) {
				Decimal total = valuesByGroup.get(invItem.partnerId);
				Decimal gpValue = invItem.groupDeparture;

				if (gpValue == null)
					gpValue = 0;

				valuesByGroup.put(invItem.partnerId, total + gpValue);
				stgDecimal.put(invItem.partnerId, total + gpValue);
			}
		}

		Boolean hasAuth = true;
		Map<String, String> hashMap = new Map<String, String>();

		for (String groupId : groupIds) {
			if (groupId == '16') {
				hashMap.put(groupId, null);
				continue;
			}

			String authHash = null;
			Decimal totalValue = valuesByGroup.get(groupId);

			Map<String, Object> authorityMap = FinancialService.getAuthority(
				entrada,
				entrada.operatorCode,
				entrada.contractNumber,
				entrada.userName,
				totalValue,
				Integer.valueOf(groupId),
				entrada.idInvoice
			);
			if (Boolean.valueOf(authorityMap.get('success'))) {
				HierarchyLimitWrapper response = (HierarchyLimitWrapper) JSON.deserialize(JSON.serialize(authorityMap.get('authority')), HierarchyLimitWrapper.class);
				if (response.autorizado != null && response.autorizado)
					authHash = response.hashAutoridade;
			}

			if (authHash == null || authHash == '')
				hasAuth = false;

			hashMap.put(groupId, authHash);
		}

		for (CEC_DisputeInvoice.InvoiceItem constItem : entrada.invoiceItems) {
			constItem.approvationHash = hashMap.get(constItem.partnerId);
			constItem.groupDeparture = 0;
		}

		System.debug('@@@@@@ auth hash dispute invoice ' + hasAuth);

		DisputeInvoiceResponse resp = FinancialService.createDispute(entrada, entrada.userName, true, hasAuth, true);

		if (res != null) {
			res.statusCode = Integer.valueOf(resp.code);
			return resp;
		}

		return null;
	}

	public static List<String> checkRequiredFieldsInvoice(DisputeInvoiceRequest invoice) {
		List<String> missingFields = new List<String>();
		Map<String, Object> keyObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(invoice));

		for (String field : REQUIRED_FIELDS_INVOICE)
			if (invoice.getField(field, keyObject) == null)
				missingFields.add(field);

		return missingFields;
	}

	public static Map<Integer, List<String>> checkRequiredFieldsItem(List<InvoiceItem> items) {
		Map<Integer, List<String>> missingItems = new Map<Integer, List<String>>();

		Integer mapIdx = 0;

		for (InvoiceItem instItem : items) {
			List<String> missingItemFields = checkRequiredFieldsItem(instItem);

			if (missingItemFields.isEmpty()) {
				++mapIdx;
				continue;
			}

			missingItems.put(mapIdx, missingItemFields);
			++mapIdx;
		}

		return missingItems;
	}

	public static List<String> checkRequiredFieldsItem(InvoiceItem items) {
		List<String> missingFields = new List<String>();

		for (String field : REQUIRED_FIELDS_ITEM)
			if (items.getField(field) == null)
				missingFields.add(field);

		return missingFields;
	}

	@Description('Request de entrada')
	global virtual class DisputeInvoiceRequest {
		global String contractNumber { get; set; }
		global String operatorCode { get; set; }
		global String channel { get; set; }
		global String idInvoice { get; set; }
		global String idPartner { get; set; }
		global String idPartnerStatement { get; set; }
		global String idDetExtractItem { get; set; }
		global String userName { get; set; }
		global Integer source { get; set; }
		global String type { get; set; }
		global String descricaoSolicitacao { get; set; }
		// @note 92819 Fechamento do Caso de Contestação em caso de falha de API - caseId
		global String caseId { get; set; }
		global List<InvoiceItem> invoiceItems { get; set; }

		public Object getField(String fieldName, Map<String, Object> untypedObject) {
			Map<String, Object> objectUntyped = untypedObject;

			if (untypedObject == null) {
				String jsonObject = JSON.serialize(this);
				objectUntyped = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
			}

			return objectUntyped.get(fieldName);
		}
	}

	@Description('Response inicial')
	global virtual class DisputeInvoiceResponse {
		@AuraEnabled
		global String code { get; set; }
		@AuraEnabled
		global String message { get; set; }
		@AuraEnabled
		global String errorMessage { get; set; }
		@AuraEnabled
		global String newBillId { get; set; }
		@AuraEnabled
		global Caso caseData { get; set; }

		public DisputeInvoiceResponse() {
		}

		public DisputeInvoiceResponse(String newBillId) {
			this.code = '200';
			this.message = 'success';
			this.newBillId = newBillId;
		}

		public DisputeInvoiceResponse(String code, String message) {
			this.code = code;
			this.message = message;
		}

		public DisputeInvoiceResponse(Caso caseData) {
			this.code = '200';
			this.message = 'success';
			this.caseData = caseData;
		}

		public DisputeInvoiceResponse(String code, String errorMessage, Caso caseData) {
			this.code = code;
			this.message = 'warning';
			this.errorMessage = errorMessage;
			this.caseData = caseData;
		}
	}

	@Description('Response de caso')
	global class Caso {
		global String contractNumber { get; set; }
		global String protocol { get; set; }
		global String caseId { get; set; }
		global String status { get; set; }
		global List<InvoiceItem> invoiceItems { get; set; }

		public Caso() {
		}

		public Caso(String contract, String protocol, String status, String caseId, List<InvoiceItem> invoiceItems) {
			this.contractNumber = contract;
			this.protocol = protocol;
			this.status = status;
			this.caseId = caseId;
			this.invoiceItems = invoiceItems;
		}
	}

	@Description('Estrutura de Itens de Fatura')
	global class InvoiceItem {
		global String idInvoiceItem { get; set; }
		global String idGroupItem { get; set; }
		global String reason { get; set; }
		global Double originalValue { get; set; }
		global Double wishedValue { get; set; }
		global Double disputePercentage { get; set; }
		global String status { get; set; }
		global String approvationHash { get; set; }
		global String notes { get; set; }
		global String itemDescription { get; set; }
		global String partnerId { get; set; }
		global String idDetExtractItem { get; set; }
		global String idPartnerStatement { get; set; }
		global Decimal groupDeparture { get; set; }

		public Object getField(String fieldName) {
			String jsonObject = JSON.serialize(this);
			Map<String, Object> objectUntyped = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);

			return objectUntyped.get(fieldName);
		}
	}
}