/*
 * Autor: João Neves
 * Data: 03/07/2020
 * Descrição: API to Dispute Invoice with case creation
 */
@RestResource(urlMapping='/api/AuthorityInvoice/*')
global with sharing class CEC_AuthorityInvoice {
	private static final List<String> REQUIRED_FIELDS_INVOICE = new List<String>{ 'contractNumber', 'operatorCode', 'channel', 'idInvoice', 'invoiceItems', 'userName', 'source', 'type' };
	private static final List<String> REQUIRED_FIELDS_ITEM_GENERAL = new List<String>{ 'idGroupItem', 'reason', 'originalValue', 'status', 'wishedValue', 'partnerId' };
	private static final List<String> REQUIRED_FIELDS_ITEM_PARTNER = new List<String>{ 'idGroupItem', 'reason', 'originalValue', 'status', 'wishedValue', 'partnerId' };

	@HttpPost
	global static void authorityInvoice(CEC_DisputeInvoice.DisputeInvoiceRequest entrada) {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		if (entrada == null) {
			createResponse(res, new AuthorityResponse('400', 'dispute object is null'));
			return;
		}

		List<String> missingFields = checkRequiredFieldsInvoice(entrada);
		if (!missingFields.isEmpty()) {
			createResponse(res, new AuthorityResponse('400', 'missing fields: ' + String.join(missingFields, ', ')));
			return;
		}

		if (entrada.invoiceItems == null) {
			createResponse(res, new AuthorityResponse('400', 'dispute items are empty'));
			return;
		}

		Map<Integer, List<String>> missingItems = checkRequiredFieldsItem(entrada.invoiceItems);

		if (!missingItems.isEmpty()) {
			String missingText = '';

			for (Integer currPos : missingItems.keySet())
				missingText = missingText + ' item position: ' + currPos + ' fields: ' + String.join(missingItems.get(currPos), ', ');

			createResponse(res, new AuthorityResponse('400', 'dispute items are missing properties:' + missingText));
			return;
		}

		if (checkInvalidContract(entrada)) {
			createResponse(res, new AuthorityResponse('400', 'invalid contract'));
			return;
		}

		Decimal totalValue = 0;

		for (CEC_DisputeInvoice.InvoiceItem invItem : entrada.invoiceItems) {
			Decimal diffVal = invItem.originalValue - invItem.wishedValue;
			totalValue = totalValue + diffVal;
		}

		Boolean hasSfAuth = FinancialHierarchy.hasSalesforceAuthority(entrada, totalValue);
		if (!hasSfAuth) {
			createResponse(res, new AuthorityResponse('200', 'missing salesforce auth', false));
			return;
		}

		entrada.userName = InvoicesUtils.getCalloutUser('InvoiceAuthority');

		Map<String, String> paramsLegacy = FinancialHierarchy.setParamsAuthority(
			entrada.operatorCode,
			entrada.contractNumber,
			entrada.userName,
			totalValue,
			Integer.valueOf(entrada.invoiceItems[0].idGroupItem),
			entrada.idInvoice
		);

		Map<String, Object> authorityMap = FinancialHierarchy.performLegacyAuthCall(paramsLegacy);

		if (Boolean.valueOf(authorityMap.get('success'))) {
			HierarchyLimitWrapper response = (HierarchyLimitWrapper) JSON.deserialize(JSON.serialize(authorityMap.get('authority')), HierarchyLimitWrapper.class);
			string msgReturn = response.autorizado ? 'ok' : 'missing legacy auth';
			createResponse(res, new AuthorityResponse('200', msgReturn, response.autorizado));
			return;
		} else {
			createResponse(res, new AuthorityResponse('500', 'Legacy API Error: ' + authorityMap.get('message').toString()));
			return;
		}
	}

	private static List<String> checkRequiredFieldsInvoice(CEC_DisputeInvoice.DisputeInvoiceRequest invoice) {
		List<String> missingFields = new List<String>();
		Map<String, Object> keyObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(invoice));

		for (String field : REQUIRED_FIELDS_INVOICE) {
			try {
				Object fieldObject = invoice.getField(field, keyObject);

				if (fieldObject == null) {
					missingFields.add(field);
				} else if (String.isEmpty(String.valueOf(fieldObject)) || String.isBlank(String.valueOf(fieldObject))) {
					missingFields.add(field);
				}
			} catch (Exception e) {
				throw e;
			}
		}

		return missingFields;
	}

	private static Map<Integer, List<String>> checkRequiredFieldsItem(List<CEC_DisputeInvoice.InvoiceItem> items) {
		Map<Integer, List<String>> missingItems = new Map<Integer, List<String>>();

		Integer mapIdx = 0;

		for (CEC_DisputeInvoice.InvoiceItem instItem : items) {
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

	private static List<String> checkRequiredFieldsItem(CEC_DisputeInvoice.InvoiceItem items) {
		List<String> missingFields = new List<String>();

		List<String> requiredFields = items.partnerId == '2' || items.partnerId == '16' ? REQUIRED_FIELDS_ITEM_PARTNER : REQUIRED_FIELDS_ITEM_GENERAL;

		for (String field : requiredFields) {
			try {
				Object fieldObject = items.getField(field);

				if (fieldObject == null) {
					missingFields.add(field);
				} else if (String.isEmpty(String.valueOf(fieldObject)) || String.isBlank(String.valueOf(fieldObject))) {
					missingFields.add(field);
				}
			} catch (Exception e) {
				throw e;
			}
		}

		return missingFields;
	}

	private static RestResponse createResponse(RestResponse res, AuthorityResponse authResp) {
		res.statusCode = Integer.valueOf(authResp.code);
		res.responseBody = Blob.valueOf(Json.serialize(authResp));
		return res;
	}

	private static Boolean checkInvalidContract(CEC_DisputeInvoice.DisputeInvoiceRequest entrada) {
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		List<Account> contratoList = new List<Account>(
			[SELECT Id FROM Account WHERE ContractReferenceNumber__c = :entrada.contractNumber AND RecordTypeId = :recordTypeIdAccount AND CityCode__c = :entrada.operatorCode]
		);

		return contratoList.isEmpty();
	}

	global virtual class AuthorityResponse {
		public String code = '200';
		public String message = '';
		public Boolean authority = false;

		public AuthorityResponse(String code, String message) {
			this.code = code;
			this.message = message;
			this.authority = false;
		}

		public AuthorityResponse(String code, String message, Boolean auth) {
			this.code = code;
			this.message = message;
			this.authority = auth;
		}
	}
}