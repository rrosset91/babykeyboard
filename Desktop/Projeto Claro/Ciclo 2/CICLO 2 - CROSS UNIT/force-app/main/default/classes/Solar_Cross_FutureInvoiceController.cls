/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-30-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-29-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Solar_Cross_FutureInvoiceController {
	
	
	@AuraEnabled
	public static Map<String,Object> callCorrectIntegration(Case objCase, Boolean isMobile){
		Map<String,Object> mapReturn = new Map<String,Object>();
		if(isMobile){
			System.debug('Chamou integração Mobile');
			mapReturn =  Solar_Cross_FutureMobileIntegration.makeCalloutMobile(objCase,6);
		}else if(!isMobile){
			system.debug('Chamou integração Residencial');
			mapReturn =  getHistoryByPeriod(objCase.ContractBillingAccount__r.ContractNumber__c,'FUTURE_RELEASE', 6);
		}
		return mapReturn;
	}

    @AuraEnabled
    public static Case getContractId(Id strId){
		System.debug('strId ' + strId);
        List<Case> lstCase = [SELECT Id,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.BusinessUnit__c FROM CASE WHERE Id =: strId];
		System.debug('lstCase: ' + lstCase[0].ContractBillingAccount__r.ContractNumber__c);
		if(lstCase.isEmpty() || lstCase[0].ContractBillingAccount__c == null){ 
            return null;
		}
		System.debug('lstCase'+ lstCase);
        return lstCase[0];
    }
    @AuraEnabled
    public static Map<String, Object> getHistoryByPeriod(String contractId, String extractItemStatus, Integer period){
		List<String> contractOperatorId = contractId.split('/');

        Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
		Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
        return getHistoryEvents(contractOperatorId[1], contractOperatorId[0], extractItemStatus, startDate, endDate);    
    }
    
	private static Map<String, Object> getHistoryEvents(String contractId, String operatorId, String extractItemStatus, Date startDate, Date endDate) {
		Map<String, Object> data = new Map<String, Object>();
        System.debug('Teste::: ' + contractId + ' / ' +operatorId );
		String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
		String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
		
		Map<String, String> params = setParamsHistory(contractId, operatorId, extractItemStatus, startDateText, endDateText);

		ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('historyEvents');

		Map<String, String> headers = new Map<String, String>();
		headers.put('X-QueryString', 'customeraccountid=' + operatorId + contractId.leftPad(9,'0'));
		headers.put('X-Client-Auth', metaParameter.Token__c);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'historyEvents');

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
		}else {
			data.put('success', false);
			data.put('message', setErrorMessage(calloutResponse.get('response')));
		}
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
	private static Map<String, String> setParamsHistory(String contractId, String operatorId, String extractItemStatus, String dateFrom, String dateTo){
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