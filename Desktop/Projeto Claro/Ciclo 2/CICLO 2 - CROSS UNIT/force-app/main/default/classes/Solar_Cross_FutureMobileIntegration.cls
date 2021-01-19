public class Solar_Cross_FutureMobileIntegration {

    public static Map<String,Object> makeCalloutMobile(Case objCase, Integer period){
        Map<String, Object> data = new Map<String, Object>();

        Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
        Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
        System.debug('objCase.ContractNumber__c: ' + objCase.ContractBillingAccount__r.ContractNumber__c);

        String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
        String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
        String signatureType = 'CLARO_CONTA';
        ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('mobileCallHistoricals');
        System.debug('metaParameter: ' + metaParameter.Token__c);

        Map<String, String> headers = new Map<String, String>();
		headers.put('X-QueryString', 'msisdn=' + objCase.ContractBillingAccount__r.ContractNumber__c);
        headers.put('X-Client-Auth', metaParameter.Token__c);
        headers.put('Content-Type', 'application/json');

        Map<String,String> queryParams = getQueryParams(startDateText,endDateText, signatureType);

        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(null, queryParams, headers, 'mobileCallHistoricals');

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			ResponseFutureMobile releaseJson = (ResponseFutureMobile) JSON.deserialize(calloutResponse.get('response'), ResponseFutureMobile.class);

			List<EventsHistoryWrapper.BillDocumentList> history = processHistory(releaseJson);

			data.put('success', true);
			data.put('events', history);
		} else {
			data.put('success', false);
			//data.put('message', setErrorMessage(calloutResponse.get('response')));
		}
		return data;
        

    }

    @TestVisible
    private static List<EventsHistoryWrapper.BillDocumentList> processHistory(ResponseFutureMobile futureRelease){
        List<EventsHistoryWrapper.BillDocumentList> lstHistory = new List<EventsHistoryWrapper.BillDocumentList>();

		for (Historicals historic : futureRelease.data.Historicals) {
			EventsHistoryWrapper.BillDocumentList billDoc = new EventsHistoryWrapper.BillDocumentList();

			//billDoc.id = historic.200;
			billDoc.billNo = null;
			billDoc.billId = null;
			billDoc.paymentDueDate = historic.dateBill;
			billDoc.billDate = historic.dateBill;
			billDoc.description = historic.typeEvent;
			billDoc.name = null;
			billDoc.installments = null;
		//	billDoc.extractItemTypeId = install.idExtractItemType;
			billDoc.extractItemTypeDescription = historic.typeEvent;
			billDoc.amountDue = historic.totalValue;
			billDoc.isContestation = null;
			billDoc.complement = null;
			billDoc.reasonId = null;
			billDoc.partnerId = '1';
			//billDoc.partnerName = 'NET';
		/*	billDoc.reasonDescription = null;
			billDoc.formattedAmount = null;
			billDoc.invoiceItemGroupDemoId = install.idInvoiceGroupDemo;
			billDoc.invoiceItemGroupDemoDescription = install.descriptionInvoiceGroupDemo;
			billDoc.extractItensDetails = null;
			billDoc.hasElegibility = install.allowContestation;
			billDoc.contestationOptions = install.contestationReasonTypes;
			billDoc.amountContested = install.value;*/
			lstHistory.add(billDoc);
		}

		return lstHistory;
	}

    public static Map<String,String> getQueryParams(String startDate, String endDate, String signatureType){
        Map<String,String> mapReturn = new Map<String,String>();
        mapReturn.put('signatureType',signatureType);
        mapReturn.put('startDate',startDate);
        mapReturn.put('endDate',endDate);

        return mapReturn;

    }

    public class ResponseFutureMobile{
        public Data data;
    }


    public class Data{
        public List<Historicals> historicals;
        public String totalRecords;
        public String backPage;
    }

    public class Historicals{
        public String callId;
        public String dateBill;
        public String dateCall;
        public String destinationNumber;
        public String operator;
        public Decimal durationCall;
        public String measuredUnit;
        public String callType;
        public String chargingType;
        public Decimal priceValue;
        public Decimal value;
        public Decimal icmsValue;
        public Decimal totalValue;
        public String typeEvent;
        public String destiny;
        public String source;
        public String mobileBan;
        public String accountDate;
    }
}