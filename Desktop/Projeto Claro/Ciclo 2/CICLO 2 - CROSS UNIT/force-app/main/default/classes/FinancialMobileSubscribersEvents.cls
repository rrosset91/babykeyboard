/**
 * @description       : Classe responsável pelas chamadas / requests do agrupamento de Agregadores
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos-Agregadores
 * @last modified on  : 31-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialMobileSubscribersEvents {
    /**
    * --------------------------------- @MÉTODOS DE REQUEST  --------------------------------
    **/

    /**
    * @description Recebe o wrapper do accordion e retorna os parametros necessários para chamadas de api
    * @author Roger Rosset | 23-10-2020 
    * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
    * @return Map<String, String> 
    **/
    public static Map<String,String> getParams(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion , FinancialMobileGeneralService.EntryPointWrapper baseAttributes, FinancialMobileFiltersWrapper.filterValues filterParams) {
        Map<String,String> params = new Map<String,String>();
        Integer period = filterParams.periodFilter;
        if(period != null){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
             String startDateText = InvoicesUtils.formatDateToIntegration(startDate,false);
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
             String endDateText = InvoicesUtils.formatDateToIntegration(endDate,false);
             //params.put('effectiveDate',startDateText);
             //params.put('effectiveEndDate',endDateText);
        }else if (filterParams.startDateFilter!=null && filterParams.endDateFilter!=null){
            String startDateText = InvoicesUtils.formatDateToIntegration(filterParams.startDateFilter,false);
            String endDateText = InvoicesUtils.formatDateToIntegration(filterParams.endDateFilter,false);
            //params.put('effectiveDate',startDateText);
            //params.put('effectiveEndDate',endDateText);
        }
        params.put('msisdn',baseAttributes.msisdn); //mudar para msisdn
        return params;

    }
    /**
    * @description Recebe o wrapper do accordion e retorna os headers necessários para chamadas de api
    * @author Roger Rosset | 23-10-2020 
    * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
    * @return Map<String, String> 
    **/
    public static Map<String,String> getHeaders(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        Map<String,String> headers = new Map<String,String>();
        String token = FinancialMobileUtils.getAuth('GetSubscriberVas');
        headers.put('Authorization', token);
        return headers;
    }
    /**
    * @description Recebe o wrapper do accordion e retorna o body necessário para chamadas de api
    * @author Roger Rosset | 23-10-2020 
    * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
    * @return Map<String, String> 
    **/
    public static String getBody(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion) {
        String body = '';
        return body;
    }

    /**
    * --------------------------------- @MÉTODOS DE RESPONSE  --------------------------------
    /**
    * @description Retorna uma lista tratada para o map
    * @author Roger Rosset | 23-10-2020 
    * @param String responseJSON 
    * @param String responseJSON, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion
    * @return Object 
    **/
    public static Object processJSON(String responseJSON, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion){
        List<JSONSubscribersEventsWrapper.SubscribersVas> subscribersVas = new List<JSONSubscribersEventsWrapper.SubscribersVas>();
        JSONSubscribersEventsWrapper response = (JSONSubscribersEventsWrapper)JSON.deserialize(responseJSON, JSONSubscribersEventsWrapper.class);
            for(JSONSubscribersEventsWrapper.SubscribersVas item : response.data.subscribersVas){
                    if(item.solicitationDate != null){
                        item.formattedSolicitationDateSubscribers = FinancialMobileUtils.formatResponseDate(item.solicitationDate, false);
                        Date solicitationDate = FinancialMobileUtils.getRealDateInstance(item.formattedSolicitationDateSubscribers);
                        item.realSolicitationDateSubscribers = solicitationDate;
                    }
                    if(item.expirationDate != null){
                        item.formattedExpirationDateSubscribers = FinancialMobileUtils.formatResponseDate(item.expirationDate, false);
                        Date expirationDate = FinancialMobileUtils.getRealDateInstance(item.formattedExpirationDateSubscribers);
                        item.realExpirationDateSubscribers = expirationDate;
                    } 
                    item.statusSubscribers = item.status;
                    item.serviceAggregatorNameSubscribers = item.serviceAggregatorName;

                    item.relatedAccordion = requesterAccordion.accordionId;
                subscribersVas.add(item);
            }
        system.debug('@@Response Tratado -->'+JSON.serializePretty(subscribersVas));
        return JSON.serializePretty(subscribersVas);
}

    /**
    * @description Retorna um JSON com as colunas do Datatable
    * @author Roger Rosset | 23-10-2020 
    * @return Object 
    **/
    public static Object getColumns(){
        List<FinancialDataTableUtils.Columns> columnsData = new List<FinancialDataTableUtils.Columns>();
        FinancialDataTableUtils.Columns column1 = new FinancialDataTableUtils.Columns();
            column1.label = 'Nome';
            column1.fieldName = 'serviceAggregatorNameSubscribers';
            column1.sortable = true;
            column1.type = 'text';
                columnsData.add(column1);
        FinancialDataTableUtils.Columns column2 = new FinancialDataTableUtils.Columns();
            column2.label = 'Data Adesão';
            column2.fieldName = 'formattedSolicitationDateSubscribers';
            column2.sortable = true;
            column2.type = 'text';
                columnsData.add(column2);
        FinancialDataTableUtils.Columns column3 = new FinancialDataTableUtils.Columns();
            column3.label = 'Data Expiração';
            column3.fieldName = 'formattedExpirationDateSubscribers';
            column3.sortable = true;
            column3.type = 'text';
                columnsData.add(column3);
        FinancialDataTableUtils.Columns column4 = new FinancialDataTableUtils.Columns();
            column4.label = 'Status';
            column4.fieldName = 'statusSubscribers';
            column4.sortable = true;
            column4.type = 'text';
                columnsData.add(column4);

        system.debug('@@Colunas -->'+JSON.serializePretty(columnsData));
        return JSON.serializePretty(columnsData);
    }
    /**
    * @description Retorna um JSON com os campos do modal (Se houver)
    * @author Roger Rosset | 23-10-2020 
    * @return Object 
    **/
    public static Object getModalFields(){
        return null;
    }
}