/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe do tipo controller do componente "Eventos"
* @revision: 19-08-2020 Organizaçao do codigo
*/
 
public class EventsController{

// @@@@ CLASSES PÚBLICAS COM PARAMETRIZAÇOES DE DATA E/OU PERÍODO @@@@
        @AuraEnabled
        public static Map<String, Object> getEvents(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getEventsByDate(contractId, operatorId, startDate, endDate);
        }
    
        @AuraEnabled
        public static Map<String, Object> getHistoryEventsByPeriod(String contractId, String operatorId, String extractItemStatus, Integer period){
            return getHistoryByPeriod(contractId, operatorId, extractItemStatus, period);
        }
        
        @AuraEnabled
        public static Map<String, Object> getHistoryByPeriod(String contractId, String operatorId, String extractItemStatus, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getHistoryEvents(contractId, operatorId, extractItemStatus, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getHistoryByDate(String contractId, String operatorId, String extractItemStatus, Date startDate, Date endDate){
            system.debug('@@@PREPROCESSStartDATE:'+startDate);
            system.debug('@@@PREPROCESSEndDATE:'+endDate);
            return getHistoryEvents(contractId, operatorId, extractItemStatus, startDate, endDate);
        }
    
        @AuraEnabled
        public static Map<String, Object> getNewProductsByPeriod(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getNewProducts(contractId, operatorId, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getNewProductsByDate(String contractId, String operatorId, Date startDate, Date endDate){
            return getNewProducts(contractId, operatorId, startDate, endDate);
        }
    
        @AuraEnabled
        public static Map<String, Object> getOccurrencesByPeriod(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getOccurrences(contractId, operatorId, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getOccurrencesByDate(String contractId, String operatorId, Date startDate, Date endDate){
            return getOccurrences(contractId, operatorId, startDate, endDate);
        }
    
        @AuraEnabled
        public static Map<String, Object> getRequestFeesByPeriod(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getRequestFees(contractId, operatorId, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getRequestFeesByDate(String contractId, String operatorId, Date startDate, Date endDate){
            return getRequestFees(contractId, operatorId, startDate, endDate);
        }
    
        @AuraEnabled
        public static Map<String, Object> getPpvByPeriod(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getCustomerPpv(contractId, operatorId, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getPpvByDate(String contractId, String operatorId, Date startDate, Date endDate){
            return getCustomerPpv(contractId, operatorId, startDate, endDate);
        }

        @AuraEnabled
        public static Map<String, Object> getOutageByPeriod(String contractId, String operatorId, Integer period){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
            return getOutage(contractId, operatorId, startDate, endDate);
        }
        
        @AuraEnabled
        public static Map<String, Object> getOutageByDate(String contractId, String operatorId, Date startDate, Date endDate){
            return getOutage(contractId, operatorId, startDate, endDate);
        }
    
// @@@@ CLASSES PÚBLICAS SEM PARAMETRIZAÇOES DE DATA E/OU PERÍODO @@@@
        
        @AuraEnabled
        public static Map<String, Object> getEventsByDate(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String txtStartDate = formatDateToIntegration(startDate, false);
                String txtEndDate = formatDateToIntegration(endDate, false);
                Map<String, String> params = setParams(contractId, operatorId, txtStartDate, txtEndDate);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'Events');
    
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    data.put('success', true);
                    data.put('events', processEvents(calloutResponse.get('response')));
                }else{
                    data.put('success', false);
                    data.put('message', setErrorMessage(calloutResponse.get('response')));
                }
            }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
            }
            return data;
        }
    
        @AuraEnabled
        public static Map<String, Object> getHistoryEvents(String contractId, String operatorId, String extractItemStatus, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
                String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
                system.debug('@@@@PostProcessStartDate: '+startDateText);
                system.debug('@@@@PostProcessEndDate: '+endDateText);
                Map<String, String> params = setParamsHistory(contractId, operatorId, extractItemStatus, startDateText, endDateText);
                system.debug('@@@@@PARAMS: '+params);
                String authToken = getAuth('historyEvents');
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                headers.put('X-QueryString', 'customeraccountid='+ operatorId+contractId);
                headers.put('X-Client-Auth', authToken);
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
        
        @AuraEnabled
        public static Map<String, Object> getEventDetails(String contractId, String operatorId, String requestId){
            Map<String, Object> data = new Map<String, Object>();
    
            try{
                Map<String, String> params = setParamsDetails(contractId, operatorId, requestId);
                Map<String, String> calloutResponseConfiguration = OutboundCalloutHandler.sendRequest('', params, 'EventsConfigurationOrders');
                Map<String, String> calloutResponseWork = OutboundCalloutHandler.sendRequest('', params, 'EventsWorkOrders');
    
                if(Integer.valueOf(calloutResponseConfiguration.get('statusCode')) < 400 && Integer.valueOf(calloutResponseWork.get('statusCode')) < 400){
                    data.put('success', true);
                    data.put('configurations', processConfigurations(calloutResponseConfiguration.get('response')));
                    data.put('orders', processOrders(calloutResponseWork.get('response')));
                }else{
                    data.put('success', false);
                    if(Integer.valueOf(calloutResponseConfiguration.get('statusCode')) > 400){
                        data.put('message', setErrorMessage(calloutResponseConfiguration.get('response')));
                    }else{
                        data.put('message', setErrorMessage(calloutResponseWork.get('response')));
                    }
                }
            }catch(Exception e){
            System.debug('e.getMessage: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
            }
            return data;
        }
    
        @AuraEnabled
        public static Map<String, Object> getNewProducts(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
                String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
                system.debug('@@@@PostProcessStartDate: '+startDateText);
                system.debug('@@@@PostProcessEndDate: '+endDateText);
                Map<String, String> params = setParamsNewProducts(contractId, operatorId, startDateText, endDateText);
                system.debug('@@@@@PARAMS: '+params);
                String authToken = getAuth('GetNewProducts');
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                headers.put('X-QueryString', 'customeraccountid='+operatorId+contractId);
                headers.put('X-Client-Auth', authToken);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetNewProducts');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('newProducts', processNewProducts(jsonResponse));
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
    
        @AuraEnabled
        public static Map<String, Object> getReadjustments(String contractId, String operatorId){
            Map<String, Object> data = new Map<String, Object>();
            try{
                Map<String, String> params = new Map<String ,String>();
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                String authToken = getAuth('GetReadjustments');
                headers.put('X-Client-Auth', authToken);
                headers.put('X-QueryString', 'operatorCode='+operatorId+'&contractNumber='+contractId);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetReadjustments');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('readjustments', processAdjustment(jsonResponse));
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
    
        @AuraEnabled
        public static Map<String, Object> getOccurrences(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = formatDateToIntegration(startDate, false);
                String endDateText = formatDateToIntegration(endDate, false);
                system.debug('@@@@PostProcessStartDate: '+startDateText);
                system.debug('@@@@PostProcessEndDate: '+endDateText);
                Map<String, String> params = setParamsOccurrences(contractId, operatorId, startDateText, endDateText);
                system.debug('@@@@@PARAMS: '+params);
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                String authToken = getAuth('GetOccurrence');
                headers.put('Authorization', authToken);
                system.debug('@@HEADERS: '+headers);
                system.debug('@@AUTHCODE: '+authToken);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetOccurrence');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('occurrences',processOccurrences(jsonResponse));
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
    
        @AuraEnabled
        public static Map<String, Object> getRequestFees(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
                String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
                system.debug('@@@@PostProcessStartDate: '+startDateText);
                system.debug('@@@@PostProcessEndDate: '+endDateText);
                Map<String, String> params = setParamsNewProducts(contractId, operatorId, startDateText, endDateText);
                system.debug('@@@@@PARAMS: '+params);
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                String authToken = getAuth('GetRequestFees');
                headers.put('X-Client-Auth', authToken);
                headers.put('X-QueryString', 'customeraccountid='+ operatorId+contractId);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetRequestFees');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('requestFees', processRequestFees(jsonResponse));
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
    
        @AuraEnabled
        public static Map<String, Object> getCustomerPpv(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
                String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
                system.debug('@@@@PostProcessStartDate: '+startDateText);
                system.debug('@@@@PostProcessEndDate: '+endDateText);
                Map<String, String> params = setParamsPpv(contractId, operatorId, startDateText, endDateText);
                system.debug('@@@@@PARAMS: '+params);
                Map<String, String> headers = new Map<String, String>();
                String authToken = getAuth('GetCustomerPpv');
                headers.put('X-Client-Auth', authToken);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetCustomerPpv');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('ppvs', processCustomerPpv(jsonResponse));
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

        @AuraEnabled
        public static Map<String, Object> getOutage(String contractId, String operatorId, Date startDate, Date endDate){
            Map<String, Object> data = new Map<String, Object>();
            try{
                String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
                startDateText = startDateText.split('-')[2]+'/'+startDateText.split('-')[1]+'/'+startDateText.split('-')[0];
                String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);
                endDateText = endDateText.split('-')[2]+'/'+endDateText.split('-')[1]+'/'+endDateText.split('-')[0];
                Map<String, String> params = setParamsOutage(startDateText, endDateText);
                Map<String, String> headers = new Map<String, String>();
                contractId = contractId.leftPad(9,'0');
                String authToken = getAuth('GetOutage');
                headers.put('X-Client-Auth', authToken);
                headers.put('X-QueryString', 'operatorCode='+operatorId+'&contractNumber='+contractId);
                Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'GetOutage');
                System.debug('@@@@@RESPONSEJSON: '+ calloutResponse.get('response'));
                if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                    String jsonResponse = calloutResponse.get('response');
                    data.put('success', true);
                    data.put('outage', processOutage(jsonResponse));
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
    
// @@@@ CLASSES PRIVADAS PARA AJUSTE DE PARAMETROS E/OU HEADERS @@@@
    
        @TestVisible
        private static Map<String, String> setParams(String contractId, String operatorId, String startDate, String endDate){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
                params.put('contractNumber', contractId);
                params.put('operatorCode', operatorId);
                params.put('startDate' , startDate);
                params.put('endDate' , endDate);
            }
            return params;
        }
        @TestVisible
        private static Map<String, String> setParamsDetails(String contractId, String operatorId, String requestId){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId)
            || String.isEmpty(requestId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
                emptyFields += (String.isEmpty(requestId)) ? ', requestId' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
                params.put('contractNumber', contractId);
                params.put('operatorCode', operatorId);
                params.put('requestID', requestId);
            }
            return params;
        }
    
        private static Map<String, String> setParamsNewProducts(String contractId, String operatorId, String dateFrom, String dateTo){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
                emptyFields += (String.isEmpty(dateFrom)) ? ', dateFrom' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
                params.put('calldateOf', dateFrom);
                params.put('calldateFor', dateTo);
            }
            return params;
        }

        private static Map<String, String> setParamsOccurrences(String contractId, String operatorId, String dateFrom, String dateTo){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
				params.put('startDate', dateFrom);
					//@@ bug em que a API retorna timeout ao enviar endDate.
                params.put('endDate', dateTo);
                params.put('contractNumber', contractId);
                params.put('operatorCode', operatorId);
            }
            return params;
        }
    
        @TestVisible
            private static Map<String, String> setParamsHistory(String contractId, String operatorId, String extractItemStatus, String dateFrom, String dateTo){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
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

        private static Map<String, String> setParamsPpv(String contractId, String operatorId, String dateFrom, String dateTo){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(contractId) 
            || String.isEmpty(operatorId))
            {
                String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
                emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';
                emptyFields += (String.isEmpty(dateFrom)) ? ', dateFrom' : '';
                emptyFields += (String.isEmpty(dateTo)) ? ', dateTo' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
                params.put('startDate', dateFrom);
                params.put('endDate', dateTo);
                params.put('operatorCode', operatorId);
                params.put('contractNumber', contractId);
                params.put('page', '1');
                params.put('limit', '1');
            }
            return params;
        }

        private static Map<String, String> setParamsOutage(String dateFrom, String dateTo){
            Map<String, String> params = new Map<String, String>();
            if(String.isEmpty(dateFrom) 
            || String.isEmpty(dateTo))
            {
                String emptyFields = (String.isEmpty(dateFrom)) ? ', dateFrom' : '';
                emptyFields += (String.isEmpty(dateTo)) ? ', dateTo' : '';
                throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
            }else{
                params.put('startDate', dateFrom);
                params.put('endDate', dateTo);
            }
            return params;
        }
    
// @@@@ CLASSES PRIVADAS PARA TRATAMENTO DE DADOS RETORNADOS DAS CHAMADAS @@@@
    
        private static List<EventsWrapper> processEvents(String jsonString){
            System.debug('processEvents jsonString: ' + jsonString);
            List<EventsWrapper> events = new List<EventsWrapper>();
            JSONEvents response = (JSONEvents)JSON.deserialize(jsonString, JSONEvents.class);
            System.debug('processEvents response: ' + response);
            
            for(JSONEvents.Event instEvent : response.data.requests){
                events.add(getWrapperEvent(instEvent, groupTypes.get(instEvent.requestTypeID)));
            }
    
            return events;
        }
        
        private static List<WorkOrdersWrapper> processOrders(String jsonString){
            List<WorkOrdersWrapper> orders = new List<WorkOrdersWrapper>();
            JSONWorkOrders response = (JSONWorkOrders)JSON.deserialize(jsonString, JSONWorkOrders.class);
        
            for(JSONWorkOrders.WorkOrders instOrder : response.data.workorders)
                orders.add(getWrapperOrders(instOrder));
            
            return orders;
        }
    
        private static List<ConfigurationsWrapper> processConfigurations(String jsonString){
            List<ConfigurationsWrapper> configurations = new List<ConfigurationsWrapper>();
            JSONConfigurationOrders response = (JSONConfigurationOrders)JSON.deserialize(jsonString, JSONConfigurationOrders.class);
            
            
            for(JSONConfigurationOrders.ConfigurationOrders instEvent : response.data.configurationorders)
                configurations.add(getWrapperConfiguration(instEvent));
            
            return configurations;
        }
    
        private static EventsWrapper getWrapperEvent(JSONEvents.Event event, String groupType){
            EventsWrapper eventWrp = new EventsWrapper();
            eventWrp.groupType = groupType;
            eventWrp.cityId = event.cityId;
            eventWrp.operatorCode = event.operatorCode;
            eventWrp.contractNumber = event.contractNumber;
            if(event.requestID != null)
                eventWrp.requestID = Integer.ValueOf(event.requestID);
                
            if(event.requestTypeID != null)
                eventWrp.requestTypeID = Integer.ValueOf(event.requestTypeID);
    
            eventWrp.requestTypeDescription = event.requestTypeDescription;
            if(event.status != null)
                eventWrp.status = Integer.ValueOf(event.status);
                
            eventWrp.statusDescription = event.statusDescription;
            eventWrp.closeDate = event.closeDate;
            eventWrp.closeUser = event.closeUser;
            eventWrp.openUser = event.openUser;
            eventWrp.obs = event.obs;
            if(event.cancelReasonID != null)
                eventWrp.cancelReasonID = Integer.ValueOf(event.cancelReasonID);
                
            eventWrp.cancelReasonDescription = event.cancelReasonDescription;
            return eventWrp;
        }
    
        private static ConfigurationsWrapper getWrapperConfiguration(JSONConfigurationOrders.ConfigurationOrders config){
            ConfigurationsWrapper configWrp = new ConfigurationsWrapper();
            configWrp.executionDate = config.terminationDate;
            configWrp.type = config.configurationorderTypeDescription;
            configWrp.id = config.configurationOrderID;
            configWrp.productDescription = config.productDescription;
            return configWrp;
        }
    
        private static WorkOrdersWrapper getWrapperOrders(JSONWorkOrders.WorkOrders order){
            WorkOrdersWrapper orderWrp = new WorkOrdersWrapper();
            orderWrp.note = order.note;
            return orderWrp;
        }
    
        private static Map<Integer, String> getGroupTypes(){
            List<Tipos_de_Solicitacao__mdt> solicitationTypes = [SELECT Agrupamento__c, ID_TIPO_SOLIC__c FROM Tipos_de_Solicitacao__mdt];
            Map<Integer, String> retMap = new Map<Integer, String>();
    
            for(Tipos_de_Solicitacao__mdt instSolic : solicitationTypes)
                retMap.put(Integer.valueOf(instSolic.ID_TIPO_SOLIC__c), instSolic.Agrupamento__c);
    
            return retMap;
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
                doc.formattedAmount = formatBRL(String.valueOf(doc.amountDue));
                if (doc.reasonId != null)
                    lstHistory.add(doc);
            }
    
            return lstHistory;
        }

        private static List<JSONContactRecords.Contactrecord> processOccurrences(String jsonString){
            jsonString = jsonString.ReplaceAll('"number"', '"stringNumber"');
            List<JSONContactRecords.Contactrecord> lstOccurrence = new List<JSONContactRecords.Contactrecord>();
            List<String> lstEventIds = new List<String>();
            Map<String, String> occurrencesMap = new Map<String, String>();
            jsonString = jsonString.replace('"data": {"data"','"data": {"contactrecords"');
            JSONContactRecords response = (JSONContactRecords)JSON.deserialize(jsonString, JSONContactRecords.class);
            system.debug(response);
            
            for(JSONContactRecords.Contactrecord item : response.data.contactrecords){
                lstEventIds.add(item.typeId);
            }

            List<Occurrences_Subgroup__mdt> occSubgroups = [SELECT MasterLabel, typeId__c, EventName__c, SubGroup__c FROM Occurrences_Subgroup__mdt WHERE typeId__c IN: lstEventIds];

            for (Occurrences_Subgroup__mdt occ : occSubgroups) {
                occurrencesMap.put(occ.typeId__c,occ.SubGroup__c);
            }
            for(JSONContactRecords.Contactrecord item : response.data.contactrecords){
                item.groupType = occurrencesMap.get(item.typeId);
                if(item.status == '1'){
                    item.status = 'Fechada';
                }else item.status = 'Aberta';
                //Melhoria: adiciona o agrupamento Outros em ocorrências nao marcadas no de-para
                if(item.groupType == null)
                    item.groupType = 'Ocorrências - Outros';
                    lstOccurrence.add(item);
            }
            return lstOccurrence;
        }

        private static List<JSONResidentialCustomersLastReadjustment.LastReadjustment> processAdjustment(String jsonString){
            List<JSONResidentialCustomersLastReadjustment.LastReadjustment> lstAdjustment = new List<JSONResidentialCustomersLastReadjustment.LastReadjustment>();
            JSONResidentialCustomersLastReadjustment response = (JSONResidentialCustomersLastReadjustment)JSON.deserialize(jsonString, JSONResidentialCustomersLastReadjustment.class);
            system.debug(response);

            for(JSONResidentialCustomersLastReadjustment.LastReadjustment item : response.data.lastReadjustments){
                if(item.previousPrice !=null && item.readjustmentPrice != null){
                    String difference = String.valueOf(Double.valueOf(item.readjustmentPrice) - Double.valueOf(item.previousPrice));
                    item.formattedAmount = formatBRL(String.valueOf(difference)); //valor do reajuste
                    item.realValue = Double.valueOf(difference);
                }

                if(item.previousPrice !=null)
                    item.formattedPreviousPrice = formatBRL(String.valueOf(item.previousPrice)); //Preço anterior
                
                if(item.readjustmentPrice !=null)
                    item.formattedReadjustmentPrice = formatBRL(String.valueOf(item.readjustmentPrice)); //preço novo
                
                if(item.amount!=null){
                    item.percentAdjusted = item.amount+'%';
                    item.percentValue = Decimal.valueOf(item.amount);
                }
                
                if(item.readjustmentType !=null && item.readjustmentDate !=null)
                lstAdjustment.add(item);
            }
            return lstAdjustment;
        }

        private static List<JSONResidentialCustomerPpv.Consumptions> processCustomerPpv(String jsonString){
            List<JSONResidentialCustomerPpv.Consumptions> lstPpv = new List<JSONResidentialCustomerPpv.Consumptions>();
            List<JSONResidentialCustomerPpv.Pages> lstPages = new List<JSONResidentialCustomerPpv.Pages>();
            JSONResidentialCustomerPpv response = (JSONResidentialCustomerPpv)JSON.deserialize(jsonString, JSONResidentialCustomerPpv.class);
            system.debug(response);

            for(JSONResidentialCustomerPpv.Consumptions item : response.data.consumption){
                item.formattedPrice = formatBRL(String.valueOf(item.price));
                lstPpv.add(item);
            }
            return lstPpv;
        }

        private static List<JSONOutage.Installments> processOutage(String jsonString){
            List<JSONOutage.Installments> lstOutage = new List<JSONOutage.Installments>();
            JSONOutage response = (JSONOutage)JSON.deserialize(jsonString, JSONOutage.class);

			if (response.data == null || response.data.installments == null)
				return lstOutage;

            for(JSONOutage.Installments item : response.data.installments){
                if(item.products[0].nature != null && item.products[0].startDate != null && item.returnCode != null )
                lstOutage.add(item);
            }
            return lstOutage;
        }

        private static List<JSONResidentialRequestFees.RequestFee> processRequestFees (String jsonString){
            List<JSONResidentialRequestFees.RequestFee> lstRequestFees = new List<JSONResidentialRequestFees.RequestFee>();
            JSONResidentialRequestFees response = (JSONResidentialRequestFees)JSON.deserialize(jsonString, JSONResidentialRequestFees.class);
            system.debug(response);

            for(JSONResidentialRequestFees.RequestFee item : response.data.technicalRequestFees){
                System.debug(item);
                item.formattedAmount = formatBRL(String.valueOf(item.amount));
                lstRequestFees.add(item);
            }
            return lstRequestFees;
        }

        private static List<JSONResidentialCustomersNewProducts.NewProduct> processNewProducts (String jsonString){
            List<JSONResidentialCustomersNewProducts.NewProduct> lstNewProducts = new List<JSONResidentialCustomersNewProducts.NewProduct>();
            JSONResidentialCustomersNewProducts response = (JSONResidentialCustomersNewProducts)JSON.deserialize(jsonString, JSONResidentialCustomersNewProducts.class);
            system.debug(response);

            for(JSONResidentialCustomersNewProducts.NewProduct item : response.data.newProducts){
                System.debug(item);
                item.formattedAmount = formatBRL(String.valueOf(item.amount));
                if(item != null  && String.isNotEmpty(item.productDescription) && String.isNotEmpty(item.effectiveDate))
                lstNewProducts.add(item);
            }
            return lstNewProducts;
        }
    
// @@@@ DEMAIS CLASSES AUXILIARES PRIVADAS @@@@

        public static Map<Integer, String> groupTypes = getGroupTypes();
    
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
        //Retorna a data no padrão AAAA-DD-MM INVERTIDA PARA CONTORNAR ERRO DA API
        private static String formatDateToIntegration(Date formatDate, Boolean appendHours){
            if(formatDate == null)
                formatDate = System.today();
    
            String month = formatDate.month() < 10 ? '0' + formatDate.month() : String.valueOf(formatDate.month());
            String day = formatDate.day() < 10 ? '0' + formatDate.day() : String.valueOf(formatDate.day());
    
            String dt = formatDate.year() + '-' + day + '-' + month;
            if(appendHours)
                dt = dt + '-00:00';
    
            return dt;
        }
        
        private static String getAuth(String customSetting){
            ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
            String token = setting.Token__c;
            return token;
        }

        public class EventsControllerException extends Exception {}

        private static String formatBRL(String stringValue) {
            String formattedCurrency = ( Decimal.valueOf(stringValue==null||stringValue.trim()==''?'0':stringValue).setScale(2) + 0.001 ).format();
            return 'R$ '+formattedCurrency.substring(0,formattedCurrency.length()-1);
        }
}