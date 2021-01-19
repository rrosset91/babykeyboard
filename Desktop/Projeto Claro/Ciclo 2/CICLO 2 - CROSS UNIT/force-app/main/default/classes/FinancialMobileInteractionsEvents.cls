/**
 * @description       : Classe responsável pelas chamadas / requests do agrupamento de Atendimentos (Registros)
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos-Atendimentos

 * @last modified on  : 03-11-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public without sharing class FinancialMobileInteractionsEvents {
    /**
    * --------------------------------- @MÉTODOS DE REQUEST  --------------------------------
    **/

    /**
    * @description Recebe o wrapper do accordion e retorna os parametros necessários para chamadas de api
    * @author Roger Rosset | 23-10-2020 
    * @param FinancialMobileEventsWrapper.EventRequestAttributes baseAttributes 
    * @return Map<String, String> 
    **/
    public static Map<String,String> getParams(FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion , FinancialMobileGeneralService.EntryPointWrapper baseAttributes, FinancialMobileFiltersWrapper.filterValues filterParams) {
        Map<String,String> params = new Map<String,String>();
        Integer period = filterParams.periodFilter;

    params.put('customerCrmID', baseAttributes.customerCrmId);
    params.put('page', '1');
    params.put('limit', '999');
    params.put('companyId', 'Movel');

        if(period != null){
            Date startDate = InvoicesUtils.toStartOfMonth(Date.today().addMonths(-period));
             String startDateText = InvoicesUtils.formatDateToIntegration(startDate,false);
            Date endDate = InvoicesUtils.toEndOfMonth(Date.today());
             String endDateText = InvoicesUtils.formatDateToIntegration(endDate,false);
             params.put('startDate',startDateText);
             params.put('endDate',endDateText);

    } else if (
      filterParams.startDateFilter != null &&
      filterParams.endDateFilter != null
    ) {

            String startDateText = InvoicesUtils.formatDateToIntegration(filterParams.startDateFilter , false);
            String endDateText = InvoicesUtils.formatDateToIntegration(filterParams.endDateFilter , false);
            params.put('startDate',startDateText);
            params.put('endDate',endDateText);
        }


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
        String token = FinancialMobileUtils.getAuth('GetInteractions');
        headers.put('Authorization', token);
        return headers;
    }

    /**
    * @description Recebe o wrapper do accordion e retorna o body necessário para chamadas de api
    * @author Roger Rosset | 23-10-2020 
    * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion 
    * @return String 
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
    * @param FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion 
    * @return Object 
    **/
    public static Object processJSON(String responseJSON, FinancialMobileEventsWrapper.EventRequestAttributes requesterAccordion){

    system.debug('@@ACCORDION ---->' + requesterAccordion);

        List<JSONInteractionsEventsWrapper.Attendances> attendancesList = new List<JSONInteractionsEventsWrapper.Attendances>();
        JSONInteractionsEventsWrapper response = (JSONInteractionsEventsWrapper)JSON.deserialize(responseJSON, JSONInteractionsEventsWrapper.class);
        Boolean hasMultipleGroups = requesterAccordion.hasMultipleGroups;
        String groupBy = requesterAccordion.groupBy;

        for(JSONInteractionsEventsWrapper.Attendances item : response.data.attendances){

      if (item.solicitationDateOpening != null) {
        //TRATAMENTO DA COLUNA DATA DE ABERTURA
        item.solicitationDateOpening = FinancialMobileUtils.formatResponseDate(item.solicitationDateOpening,true);
        String stringDate = item.solicitationDateOpening.split('-')[0];
        stringDate = stringDate.replace(' ', '');
        item.formattedSolicitationDate = stringDate;
        String stringTime = item.solicitationDateOpening.split('-')[1];
        stringTime = stringTime.replace(' ', '');

        item.formattedSolicitationDateTimeInteractions = item.solicitationDateOpening;
        item.realSolicitationDateTimeInteractions = FinancialMobileUtils.getRealDateTimeInstance(stringDate,stringTime);
        item.formattedSolicitationTime = stringTime;
        item.formattedSolicitationDate = stringDate;
        item.protocolNumberInteractions = item.protocolNumber;
        item.situationInteractions = item.situation;
      }
      item.relatedAccordion = requesterAccordion.accordionId;
      attendancesList.add(item);
    }
    system.debug(
      '@@Response Tratado -->' + JSON.serializePretty(attendancesList)
    );

        return JSON.serializePretty(attendancesList);
    }

    /**
    * @description Retorna um JSON com as colunas do Datatable
    * @author Roger Rosset | 23-10-2020 
    * @return Object 
    **/
    public static Object getColumns(){
        List<FinancialDataTableUtils.Columns> columnsData = new List<FinancialDataTableUtils.Columns>();
            //Definindo as colunas e adicionando à listagem
            FinancialDataTableUtils.Columns column1 = new FinancialDataTableUtils.Columns();
                column1.label = 'Protocolo Único';

    column1.fieldName = 'protocolNumberInteractions';

                column1.sortable = true;
                column1.type = 'text';
                    columnsData.add(column1);
            FinancialDataTableUtils.Columns column2 = new FinancialDataTableUtils.Columns();
                column2.label = 'Encaminhamento';

    column2.fieldName = 'protocolNumberInteractions'; //SEM CAMPO EXATO NA API

                column2.sortable = true;
                column2.type = 'text';
                    columnsData.add(column2);
            FinancialDataTableUtils.Columns column3 = new FinancialDataTableUtils.Columns();
                column3.label = 'Fechamento';

    column3.fieldName = 'protocolNumberInteractions'; //SEM CAMPO EXATO NA API

                column3.sortable = true;
                column3.type = 'text';
                    columnsData.add(column3);
            FinancialDataTableUtils.Columns column4 = new FinancialDataTableUtils.Columns();
                column4.label = 'Data de Abertura';

    column4.fieldName = 'formattedSolicitationDateTimeInteractions';

                column4.sortable = true;
                column4.type = 'text';
                    columnsData.add(column4);
            FinancialDataTableUtils.Columns column5 = new FinancialDataTableUtils.Columns();

    column5.label = 'Status';
    column5.fieldName = 'situationInteractions'; //SEM CAMPO EXATO NA API

                column5.sortable = true;
                column5.type = 'text';
                    columnsData.add(column5);
            FinancialDataTableUtils.Columns column6 = new FinancialDataTableUtils.Columns();

    column6 = FinancialDataTableUtils.generateButton(
      'showDetail',
      'utility:preview'
    );
    columnsData.add(column6);

        system.debug('@@Colunas -->'+JSON.serializePretty(columnsData));
        return JSON.serializePretty(columnsData);
    }

    /**
    * @description - Retorna um JSON com todos os campos que serao exibidos no modal
    * @author Roger Rosset | 23-10-2020 
    * @return Object 
    **/
    public static Object getModalFields(){
        List<FinancialDataTableUtils.ModalFields> modalFieldsData = new List<FinancialDataTableUtils.ModalFields>();
        
        FinancialDataTableUtils.ModalFields modalField1 = new FinancialDataTableUtils.ModalFields();
            modalField1.label = 'Motivo 1';
            modalField1.fieldName = 'reasonCode1';
                modalFieldsData.add(modalField1);
        FinancialDataTableUtils.ModalFields modalField2 = new FinancialDataTableUtils.ModalFields();
            modalField2.label = 'Motivo 2';
            modalField2.fieldName = 'reasonCode2';
                modalFieldsData.add(modalField2);  
        FinancialDataTableUtils.ModalFields modalField3 = new FinancialDataTableUtils.ModalFields();
            modalField3.label = 'Motivo 3';
            modalField3.fieldName = 'reasonCode3';
                modalFieldsData.add(modalField3);
        FinancialDataTableUtils.ModalFields modalField4 = new FinancialDataTableUtils.ModalFields();
            modalField4.label = 'Motivo 4';
            modalField4.fieldName = 'reasonCode4';
                modalFieldsData.add(modalField4);   
        FinancialDataTableUtils.ModalFields modalField5 = new FinancialDataTableUtils.ModalFields();
            modalField5.label = 'Motivo 5';
            modalField5.fieldName = 'Sem valor na API'; 
                modalFieldsData.add(modalField5);
        FinancialDataTableUtils.ModalFields modalField6 = new FinancialDataTableUtils.ModalFields();
            modalField6.label = 'ID de alteração';
            modalField6.fieldName = 'Sem valor na API';
                modalFieldsData.add(modalField6);  
        FinancialDataTableUtils.ModalFields modalField7 = new FinancialDataTableUtils.ModalFields();
            modalField7.label = 'Hora do Registro';

    modalField7.fieldName = 'formattedSolicitationTime';

                modalFieldsData.add(modalField7);
        FinancialDataTableUtils.ModalFields modalField8 = new FinancialDataTableUtils.ModalFields();
            modalField8.label = 'ID do Usuário de Abertura';
            modalField8.fieldName = 'Sem valor na API';
                modalFieldsData.add(modalField8);   
        FinancialDataTableUtils.ModalFields modalField9 = new FinancialDataTableUtils.ModalFields();
            modalField9.label = 'Área Solucionadora';
            modalField9.fieldName = 'Sem valor na API';
                modalFieldsData.add(modalField9);  

    FinancialDataTableUtils.ModalFields modalField12 = new FinancialDataTableUtils.ModalFields();
    modalField9.label = 'Registro do Atendimento';
    modalField9.fieldName = 'Sem valor na API';
    modalFieldsData.add(modalField12);
    FinancialDataTableUtils.ModalFields modalField10 = new FinancialDataTableUtils.ModalFields();
    modalField10.label = 'Data do Registro';
    modalField10.fieldName = 'formattedSolicitationDate';

                modalFieldsData.add(modalField10);
        FinancialDataTableUtils.ModalFields modalField11 = new FinancialDataTableUtils.ModalFields();
            modalField11.label = 'Observação';
            modalField11.fieldName = 'description';
                modalFieldsData.add(modalField11);     
                
        system.debug('@@Campos do Modal -->'+JSON.serializePretty(modalFieldsData));
        return JSON.serializePretty(modalFieldsData);
    }


  @AuraEnabled
  public static Map<String, Object> rowActionRequestPerformer(String serviceToCall, String param){
    Map<String, Object> data = new Map<String, Object>();
    String body = '';
    Map<String, String> params = new Map<String, String>();
    Map<String, String> headers = new Map<String, String>();

    params.put('companyId','Movel');
    params.put('protocolNumber', param);
    headers.put('Authorization', FinancialMobileUtils.getAuth(serviceToCall));

    try {
      Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(body, params, headers, serviceToCall);
      String responseJSON = calloutResponse.get('response');
      Boolean validResponse = FinancialMobileEventsController.checkValidResponse(responseJSON, Integer.valueOf(calloutResponse.get('statusCode')));
      Integer responseCode = Integer.valueOf(calloutResponse.get('statusCode'));

      if (responseCode < 400 && validResponse == true) {
        data.put('success', true);
        data.put('apiRowCallResponseData', processRowActionResponse(responseJSON));
      } else if (validResponse == false) {
        throw new FinancialMobileEventsController.FinancialMobileEventsException('Retorno 200 - Data: null');
      } else if (responseCode == 401) {
        throw new FinancialMobileEventsController.FinancialMobileEventsException('Erro de Autenticação. Verifique os tokens e credenciais');
      } else {
        data.put('success', false);
        data.put('message', FinancialMobileUtils.setErrorMessage(calloutResponse.get('response')));
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    system.debug('@@DADOS RETORNADOS :' + data);
    return data;
  }

  @AuraEnabled
  public static Object processRowActionResponse(String responseJSON){
    List<JSONMobileInteractionsProtocol.Attendances> attendancesList = new List<JSONMobileInteractionsProtocol.Attendances>();
    JSONMobileInteractionsProtocol response = (JSONMobileInteractionsProtocol) JSON.deserialize(responseJSON,JSONMobileInteractionsProtocol.class);
    List<List<JSONPaginationModalData.Data>> listToDisplay = new List<List<JSONPaginationModalData.Data>>();
    
    for (JSONMobileInteractionsProtocol.Attendances item : response.data.attendances) {
      for(JSONMobileInteractionsProtocol.UpdateInteraction interactionUpdate : item.updateInteraction){
          JSONPaginationModalData.Data field1 = new JSONPaginationModalData.Data();
          List<JSONPaginationModalData.Data> fieldList = new List<JSONPaginationModalData.Data>();
          field1.label = 'Resumo da Atualização';
          field1.fieldName = interactionUpdate.updateResume;
          fieldList.add(field1);
          
          JSONPaginationModalData.Data field2 = new JSONPaginationModalData.Data();
          field2.label = 'Detalhes da Atualização';
          field2.fieldName = interactionUpdate.updateDetail;
          fieldList.add(field2);

          JSONPaginationModalData.Data field3 = new JSONPaginationModalData.Data();
          field3.label = 'Data da Atualização';
          field3.fieldName = FinancialMobileUtils.formatResponseDate(interactionUpdate.updateDate[0], true);
          fieldList.add(field3);
          
          listToDisplay.add(fieldList);
      }
    }
    system.debug('DADOS DE PROTOCOLO PARA O MODAL ---->'+JSON.serialize(listToDisplay));
    return JSON.serialize(listToDisplay);
  }

}