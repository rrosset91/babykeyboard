public class Solar_Cross_FutureInvoiceController {
    
    @AuraEnabled
    public static string getContractId(Id strId){
        List<Case> lstCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM CASE WHERE Id =: strId];
        String retContractId;
        String contractId;
        String operatorId;
        List<String> contractOpperatorId;
        if(lstCase.isEmpty() || lstCase[0].ContractBillingAccount__c == null){ 
            return null;
        }else{
            contractOpperatorId = lstCase[0].ContractBillingAccount__r.ContractNumber__c.split('/');
            if(!contractOpperatorId.isEmpty()){
                operatorId = contractOpperatorId[0];                
                contractId = contractOpperatorId[1].leftPad(9,'0');
                retContractId = operatorId+contractId;
            }
        }  
        return retContractId;
    }
    @AuraEnabled
    public static Map<String, Object> getHistoryByPeriod(String contractId, String extractItemStatus, Integer period){
        return getReleasesByPeriod(contractId, extractItemStatus, period);
    }
    
    @AuraEnabled    
    public static Map<String, Object> getReleasesByPeriod(String contractId, String extractItemStatus, Integer period){
		Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
		return getHistoryEvents(contractId, extractItemStatus, startDate, endDate);
	}
    
    @AuraEnabled
    public static Map<String, Object> getHistoryEvents(String contractId, String extractItemStatus, Date startDate, Date endDate){
        Map<String, Object> data = new Map<String, Object>();
        try{
			String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
            String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
            Map<String, String> params = setParamsHistory(contractId,extractItemStatus, startDateText, endDateText);
            system.debug('@@@@@PARAMS: '+params);
            System.debug('contractId: ' + contractId);
           	Map<String, String> headers = new Map<String, String>();
            ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('historyEvents');
			headers.put('X-QueryString', 'customeraccountid='+ contractId);
            headers.put('X-Client-Auth', serviceParam.token__c);
            Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'historyEvents');
            System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
            if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                String jsonResponse = calloutResponse.get('response');
                if(jsonResponse.contains('["billDocumentList",')){
                    jsonResponse = jsonResponse.replace('["billDocumentList",', '{"billDocumentList":');
                    jsonResponse = jsonResponse.removeEnd(']');
                    jsonResponse += '}';
                    System.debug('jsonResponse: '+ jsonResponse);
                }

                data.put('success', true);
                data.put('events', processHistory(jsonResponse));
            }else{
                data.put('success', false);
                data.put('message', setErrorMessage(calloutResponse.get('response')));
            }
        }catch(Exception e){
           throw new AuraHandledException(e.getMessage());
        }
        system.debug('@@@DATA RETORNADA :'+ data);
        return data;
	}
    
    @TestVisible
    private static List<EventsHistoryWrapper.BillDocumentList> processHistory(String jsonString){
        System.debug('processHistory: '+jsonString);
        List<EventsHistoryWrapper.BillDocumentList> lstHistory = new List<EventsHistoryWrapper.BillDocumentList>();
        EventsHistoryWrapper.HistoryData response = (EventsHistoryWrapper.HistoryData)JSON.deserialize(jsonString, EventsHistoryWrapper.HistoryData.class);

        System.debug(response);
        System.debug(JSON.serializePretty(response));
        for(EventsHistoryWrapper.BillDocumentList doc : response.billDocumentList){
            System.debug(doc);
            lstHistory.add(doc);
        }

        return lstHistory;
	}
    
        @TestVisible
	private static Map<String, String> setParamsHistory(String contractId, String extractItemStatus, String dateFrom, String dateTo){
        Map<String, String> params = new Map<String, String>();
        if(String.isEmpty(contractId)){
            String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
            throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
        }else{
			if(extractItemStatus == 'FUTURE_RELEASE')
				dateFrom = '2000-01-01';
			params.put('calldateOf', dateFrom);
			params.put('calldateFor', dateTo);
			params.put('infoDetailLevel', 'DETAILS');
			params.put('extractItemStatus', extractItemStatus);
        }
        return params;
    }
    @TestVisible
    private static String setErrorMessage(String jsonString){
        String errorMessage = '';
        JSONEvents errorResponse = (JSONEvents)JSON.deserialize(jsonString, JSONEvents.class);
        if(errorResponse != null){
            if(errorResponse.error != null){
                errorMessage = errorResponse.error.errorCode + ' - ' + errorResponse.error.detailedMessage;
            }else{
                errorMessage = 'Unknown error';
            }
        }else{
            errorMessage = 'Unknown error';
        }
        return errorMessage;
	}
        public class EventsControllerException extends Exception {}
}