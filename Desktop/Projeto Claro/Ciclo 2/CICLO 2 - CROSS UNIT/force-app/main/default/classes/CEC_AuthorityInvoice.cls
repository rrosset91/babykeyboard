/*
* Autor: João Neves
* Data: 03/07/2020
* Descrição: API to Dispute Invoice with case creation
*/
@RestResource(urlMapping='/api/AuthorityInvoice/*')
global with sharing class CEC_AuthorityInvoice {

	@HttpPost
	global static AuthorityResponse authorityInvoice(CEC_DisputeInvoice.DisputeInvoiceRequest entrada){
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		if(entrada == null)
			return new AuthorityResponse('400', 'dispute object is null');

		List<String> missingFields = CEC_DisputeInvoice.checkRequiredFieldsInvoice(entrada);
		if(!missingFields.isEmpty())
			return new AuthorityResponse('400', 'missing fields: ' + String.join(missingFields, ','));

		if(entrada.invoiceItems == null)
			return new AuthorityResponse('400', 'dispute items are empty');

		Map<Integer, List<String>> missingItems = CEC_DisputeInvoice.checkRequiredFieldsItem(entrada.invoiceItems);
		
		if(!missingItems.isEmpty())
        {
			String missingText = '';

			for(Integer currPos : missingItems.keySet())
				missingText = missingText + ' item position: ' + currPos + ' fields: ' + String.join(missingItems.get(currPos), ',');

			return new AuthorityResponse('400', 'dispute items are missing propertiess:' + missingText);
		}

		Decimal totalValue = 0;

		for(CEC_DisputeInvoice.InvoiceItem invItem : entrada.invoiceItems){
			Decimal diffVal = invItem.originalValue - invItem.wishedValue;
			totalValue = totalValue + diffVal;
		}

		Boolean hasSfAuth = FinancialHierarchy.hasSalesforceAuthority(entrada, totalValue);
		if(!hasSfAuth)
			return new AuthorityResponse('200', 'missing salesforce auth', false);

		entrada.userName = InvoicesUtils.getCalloutUser('InvoiceAuthority');
		
		Map<String, String> paramsLegacy = FinancialHierarchy.setParamsAuthority(entrada.operatorCode, entrada.contractNumber, entrada.userName, totalValue, Integer.valueOf(entrada.invoiceItems[0].idGroupItem), entrada.idInvoice);

		Map<String, Object> authorityMap = FinancialHierarchy.performLegacyAuthCall(paramsLegacy);

		if(Boolean.valueOf(authorityMap.get('success'))){
			HierarchyLimitWrapper response = (HierarchyLimitWrapper)JSON.deserialize(JSON.serialize(authorityMap.get('authority')), HierarchyLimitWrapper.class);
			string msgReturn = response.autorizado ? 'ok' : 'missing legacy auth';
			return new AuthorityResponse('200', msgReturn, response.autorizado);
		}else{
			return new AuthorityResponse('500', 'Legacy API Error: ' + authorityMap.get('message').toString());
		}
	}

	global virtual class AuthorityResponse{
		public String code;
		public String message;
		public Boolean authority;

		public AuthorityResponse(String code, String message){
			this.code = code;
			this.message = message;
			this.authority = false;
		}

		public AuthorityResponse(String code, String message, Boolean auth){
			this.code = code;
			this.message = message;
			this.authority = auth;
		} 
	}
}