/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Controlador dos Aura Components Solar_Cross_ProtocolHistory e Solar_Cross_ProtocolHistoryDetail
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-07-31      Jean Sganzerla          class created 
* @version   1.1    2020-08-17      Jean Sganzerla          Enabling call getHistory() from Account Record
* @version   1.2    2020-09-04      Jean Sganzerla          Added getOCAndOS() method
* @version   1.3    2020-10-09      Jean Sganzerla          change on PS8 mobile call. Line 84
**************************************************************************************************************/
global class Solar_Cross_ProtocolHistoryController{     

    @AuraEnabled
    public static ComponentDataWrapper getHistory(String aRecordId, String aStartDate, String aEndDate){
        system.debug('######################## Demandas');
        Date formattedStartDate = Date.ValueOf(aStartDate);
        Date formattedEndDate = Date.ValueOf(aEndDate);

        if(formattedStartDate.addMonths(6) < formattedEndDate) {
            throw new AuraHandledException('O período máximo permitido para consulta é de 6 meses');
        }
        
        if(formattedStartDate > formattedEndDate) {
            throw new AuraHandledException('Data início não pode ser maior que a data fim');
        }
        
        ComponentDataWrapper dataToReturn = new ComponentDataWrapper();

        String lContractNumber;
        String lContractReferenceNumber;
        String lBusinessUnit;
        String lCityCode;
        String lAccountId;

        if(aRecordId.startsWithIgnoreCase('500')){ // Componente do caso
            Case lCase = [SELECT ContractBillingAccount__r.ContractNumber__c, ContractBillingAccount__r.ContractReferenceNumber__c, 
                        ContractBillingAccount__r.BusinessUnit__c, ContractBillingAccount__r.CityCode__c, ContractBillingAccount__c
                            FROM Case 
                            WHERE Id =:aRecordId];

            lContractNumber = lCase.ContractBillingAccount__r.ContractNumber__c;
            lContractReferenceNumber = lCase.ContractBillingAccount__r.ContractReferenceNumber__c;
            lBusinessUnit = lCase.ContractBillingAccount__r.BusinessUnit__c;
            lCityCode = lCase.ContractBillingAccount__r.CityCode__c;
            lAccountId = lCase.ContractBillingAccount__c;          
        }
        else{ //Componente da conta
            Account lAccount = [SELECT ContractNumber__c, ContractReferenceNumber__c, BusinessUnit__c, CityCode__c, Id FROM Account WHERE Id =: aRecordId];
            
            lContractNumber = lAccount.ContractNumber__c;
            lContractReferenceNumber = lAccount.ContractReferenceNumber__c;
            lBusinessUnit = lAccount.BusinessUnit__c;
            lCityCode = lAccount.CityCode__c;
            lAccountId = lAccount.Id;          
        }

        //Map utlizado para evitar que os protocolos do NETSMS e PS8 que tenham sido criados no solar, e retornem por integração, sejam exibidos em tela. Exibindo apenas os Casos de dentro do Solar
        Map<String,DataFields> lFilterMap = new Map<String,DataFields>();                        
        
        //Teste que verifica se será feita integração OU se será utilizado um MOCK salvo no metadado personalizado, a fim de testar via MOCK
        List<SolarMockData__mdt> lMock = [SELECT MockData__c, Activate__c FROM SolarMockData__mdt WHERE DeveloperName = :System.Label.Solar_Cross_ProtocolHistoryDetail LIMIT 1];
        if(!lMock.isEmpty() && lMock[0].Activate__c == true && !Test.isRunningTest()){
            dataToReturn = (ComponentDataWrapper)JSON.deserialize(lMock[0].MockData__c, ComponentDataWrapper.class);
            // return dataToReturn;
        }
        else{    
            ProtocolWrapper protocolPs8Netsms = new ProtocolWrapper();
            if(lBusinessUnit == 'Net'){
                //Integração com ProtocolosPS8 ou ProtocolosNETSMS
                protocolPs8Netsms = getProtocols(lContractReferenceNumber, aStartDate, aEndDate, lContractNumber, lCityCode, lBusinessUnit);
                system.debug('protocolPs8Netsms.response.getStatusCode() ' + protocolPs8Netsms.response.getStatusCode());
                system.debug('protocolPs8Netsms.lstAttendences ' + protocolPs8Netsms.lstAttendences);
                //Se ocorreu algum erro de integração, já devolve para o componente o erro, para ser exibida a mensagem em tela
                if(protocolPs8Netsms.response.getStatusCode() != 200 && protocolPs8Netsms.response.getStatusCode() != 201){
                    dataToReturn.StatusCode = protocolPs8Netsms.response.getStatusCode();
                    system.debug('saiu protocolPs8Netsms ' + dataToReturn.StatusCode);
                    return dataToReturn;
                }
            }
            else{
                // Entra nessa condição caso seja Móvel
                Set<String> lMSISDNSet = new Set<String>();
                //coloca os MSISDN's relacionados ao contrato dentro de um SET, pois o LAKE pode inserir registros duplicados
                for(Asset lAsset :[SELECT Id, MSISDN__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c = :lAccountId AND Status = 'Ativo' AND MSISDN__c != null]){
                    lMSISDNSet.add(lAsset.MSISDN__c);
                }   
                system.debug('lMSISDNSet -----------> ' + lMSISDNSet);
                //Este callout está dentro de um for, MAS, há a garantia do time de negócio que só existem até 10 MSISDN por contrato. Sendo assim, a volumetria não estoura os limites de callout.
                //Já existe um Try Catch dentro do método da integração
                for(String lMsisdn :lMSISDNSet){                    
                    protocolPs8Netsms = getProtocols(lMsisdn, aStartDate, aEndDate, lContractNumber, lCityCode, lBusinessUnit);
                    system.debug('protocolPs8Netsms.response.getStatusCode() ' + protocolPs8Netsms.response.getStatusCode());
                    system.debug('protocolPs8Netsms.lstAttendences ' + protocolPs8Netsms.lstAttendences);
                    //Se ocorreu algum erro de integração, já devolve para o componente o erro, para ser exibida a mensagem em tela
                    if(protocolPs8Netsms.response.getStatusCode() != 200 && protocolPs8Netsms.response.getStatusCode() != 201){
                        dataToReturn.StatusCode = protocolPs8Netsms.response.getStatusCode();
                        system.debug('saiu protocolPs8 na chamada do MSISDN ' + lMsisdn + dataToReturn.StatusCode);
                        return dataToReturn;
                    }
                }
            }
            
            //só chama as solics e ocorrencias caso o contrato seja do tipo "Net"
            ProtocolWrapper protocolOcorrencias = new ProtocolWrapper();
            if(lBusinessUnit == 'Net'){
                // Integração com Ocorrencias
                protocolOcorrencias = getOcurrences(lContractNumber, lCityCode, aStartDate, aEndDate);
                system.debug('protocolOcorrencias.response.getStatusCode() ' + protocolOcorrencias.response.getStatusCode());
                system.debug('protocolOcorrencias.lstOcr ' + protocolOcorrencias.lstOcr);

                //Se ocorreu algum erro de integração, já devolve para o componente o erro, para ser exibida a mensagem em tela
                if(protocolOcorrencias.response.getStatusCode() != 200 && protocolOcorrencias.response.getStatusCode() != 201){
                    dataToReturn.StatusCode = protocolOcorrencias.response.getStatusCode();
                    system.debug('saiu protocolOcorrencias ' + dataToReturn.StatusCode);
                    return dataToReturn;
                }
                //metadado utilizado para a chamada das SOLICS
                CEC_360_serviceName__mdt serviceName = [SELECT ServiceName__c FROM CEC_360_serviceName__mdt WHERE MasterLabel = 'CEC_360_OrderRequest_GET'];
        
                //chama as solics com status 'EXECUTADA'
                ProtocolWrapper solics1 = getSolics(lContractReferenceNumber, lCityCode, aStartDate, aEndDate, '1', serviceName);
                //chama as solics com status 'ABERTA'
                system.debug('solics1.response.getStatusCode() ' + solics1.response.getStatusCode());
                system.debug('solics1.lstSolic ' + solics1.lstSolic);
                ProtocolWrapper solics2 = getSolics(lContractReferenceNumber, lCityCode, aStartDate, aEndDate, '2', serviceName);
                //chama as solics com status 'CANCELADA'
                system.debug('solics2.response.getStatusCode() ' + solics2.response.getStatusCode());
                system.debug('solics2.lstSolic ' + solics2.lstSolic);
                ProtocolWrapper solics3 = getSolics(lContractReferenceNumber, lCityCode, aStartDate, aEndDate, '3', serviceName);
                system.debug('solics3.response.getStatusCode() ' + solics3.response.getStatusCode());
                system.debug('solics3.lstSolic ' + solics3.lstSolic);
                
                if(solics1.response.getStatusCode() != 200 && solics1.response.getStatusCode() != 201){
                    dataToReturn.StatusCode = solics1.response.getStatusCode();
                    system.debug('saiu solics1 ' + dataToReturn.StatusCode);
                    return dataToReturn;
                }
                else if(solics2.response.getStatusCode() != 200 && solics2.response.getStatusCode() != 201){
                    dataToReturn.StatusCode = solics2.response.getStatusCode();
                    system.debug('saiu solics2 ' + dataToReturn.StatusCode);
                    return dataToReturn;
                }
                else if(solics3.response.getStatusCode() != 200 && solics3.response.getStatusCode() != 201){
                    dataToReturn.StatusCode = solics3.response.getStatusCode();
                    system.debug('saiu solics3 ' + dataToReturn.StatusCode);
                    return dataToReturn;
                }

                //adiciona as solics dos 3 status em uma lista só, para iterar apenas uma vez
                solics1.lstSolic.addAll(solics2.lstSolic);
                solics1.lstSolic.addAll(solics3.lstSolic);
                for(CEC_360_IntegrationsOrderRequest.OrderReq solic :solics1.lstSolic){            
                    DataFields fields = new DataFields();
                    
                    fields.ProtocolNumber = solic.requestTypeID;
                    fields.OccurrenceNumber = solic.contractNumber;
                    List<String> lJsonFormatedDate = solic.closeDate != null ? solic.closeDate.split('/') : null;
                    fields.StartDate = lJsonFormatedDate?.size() == 3 ? lJsonFormatedDate[0] + '-' + lJsonFormatedDate[1] + '-' + lJsonFormatedDate[2] : null;
                    fields.comparableStartDate = lJsonFormatedDate?.size() == 3 ? Date.valueOf(lJsonFormatedDate[2] + '-' + lJsonFormatedDate[1] + '-' + lJsonFormatedDate[0]) : null;
                    fields.EndDate = solic.closeDate != null ? lJsonFormatedDate[0] + '-' + lJsonFormatedDate[1] + '-' + lJsonFormatedDate[2] : null;
                    fields.Status = solic.status == '1' || solic.status == '3' ? 'Fechado' : 'Aberto';
                    fields.Situation = solic.status;
                    fields.Base = 'NET SMS';
                    fields.Description = solic.statusDescription;
                    fields.Type = 'Solicitações';
                    fields.Resolution = solic.cancelReasonDescription;
                    fields.DescriptionLabel = solic.statusDescription != null && solic.statusDescription.length() > 50 ? solic.statusDescription.abbreviate(50) : solic.statusDescription;
                    fields.ResolutionLabel = solic.cancelReasonDescription != null && solic.cancelReasonDescription.length() > 50 ? solic.cancelReasonDescription.abbreviate(50) : solic.cancelReasonDescription;
                    fields.RequestID = solic.requestID;
                    fields.OperatorCode = solic.operatorCode;
                    // dataToReturn.dataFieldsLst.add(fields);
                    lFilterMap.put(fields.ProtocolNumber,fields);
                }
            }

            for(attendences attendence :protocolPs8Netsms.lstAttendences){
                DataFields fields = new DataFields();
                String lDescription;
                // String teste = 'null';
                // Boolean result = teste.equals(attendence.memo);
                // system.debug('attendence.memo ------------------------------------------------------------> ' + attendence.memo + ' - ' + result);
                lDescription = attendence.reasonCode1 != 'null' && attendence.reasonCode1 != null ? attendence.reasonCode1 : '';
                lDescription = attendence.reasonCode2 != 'null' && attendence.reasonCode2 != null ? lDescription + ' - '  + attendence.reasonCode2 : lDescription;
                lDescription = attendence.reasonCode3 != 'null' && attendence.reasonCode3 != null ? lDescription + ' - '  + attendence.reasonCode3 : lDescription;
                lDescription = attendence.reasonCode4 != 'null' && attendence.reasonCode4 != null ? lDescription + ' - '  + attendence.reasonCode4 : lDescription;
                lDescription = attendence.reasonCode5 != 'null' && attendence.reasonCode5 != null ? lDescription + ' - '  + attendence.reasonCode5 : lDescription;
                lDescription = attendence.memo != 'null' && attendence.memo != null ? lDescription + ' - '  + attendence.memo : lDescription;

                String lResolution;
                lResolution = attendence.updateResume != 'null' && attendence.updateResume != null ? attendence.updateResume : '';
                lResolution = attendence.updateDetail != 'null' && attendence.updateDetail != null ? ' - ' + attendence.updateDetail : lResolution;

                fields.ProtocolNumber = attendence.protocolNumber;
                fields.OccurrenceNumber = attendence.interactionNumber;
                fields.StartDate = attendence.solicitationDateOpening != null ? Date.valueOf(attendence.solicitationDateOpening).day() + '-' + Date.valueOf(attendence.solicitationDateOpening).month() + '-' + Date.valueOf(attendence.solicitationDateOpening).year() : null;
                fields.EndDate = attendence.solicitationDateClosing != null ? Date.valueOf(attendence.solicitationDateClosing).day() + '-' + Date.valueOf(attendence.solicitationDateClosing).month() + '-' + Date.valueOf(attendence.solicitationDateClosing).year() : null;
                fields.comparableStartDate = attendence.solicitationDateOpening != null ? Date.valueOf(attendence.solicitationDateOpening) : null;
                fields.Status = attendence.solicitationStatus;
                fields.Situation = attendence.solicitationStatus;
                fields.Base = lBusinessUnit == 'Net' ? 'NET SMS' : 'PS8';
                if(fields.Base == 'PS8'){
                    fields.Description = lDescription;
                    fields.Resolution = lResolution;
                }
                else{
                    fields.Description = attendence.solicitationType;
                }
                fields.Type = 'Protocolo';
                fields.DescriptionLabel = fields.Description != null && fields.Description.length() > 50 ?  fields.Description.abbreviate(50) : fields.Description;
                fields.ResolutionLabel = fields.Resolution != null && fields.Resolution.length() > 50 ? fields.Resolution.abbreviate(50) : fields.Resolution;
                // dataToReturn.dataFieldsLst.add(fields);
                lFilterMap.put(fields.ProtocolNumber,fields);
            }

            for(CEC_RestObjects.ocurrencesObj ocurrence :protocolOcorrencias.lstOcr){
                DataFields fields = new DataFields();
                
                fields.ProtocolNumber = ocurrence.protocolNumber;
                fields.OccurrenceNumber = ocurrence.attendanceNumber;
                fields.StartDate = ocurrence.creationDate != null ? Date.valueOf(ocurrence.creationDate).day() + '-' + Date.valueOf(ocurrence.creationDate).month() + '-' + Date.valueOf(ocurrence.creationDate).year() : null;
                fields.EndDate = ocurrence.resolutionDate != null ? Date.valueOf(ocurrence.resolutionDate).day() + '-' + Date.valueOf(ocurrence.resolutionDate).month() + '-' + Date.valueOf(ocurrence.resolutionDate).year() : null;
                fields.comparableStartDate =  ocurrence.creationDate != null ? Date.valueOf(ocurrence.creationDate) : null;
                fields.Status = ocurrence.status;
                fields.Situation = ocurrence.status;
                fields.Base = 'NET SMS';
                fields.Description = ocurrence.description;
                fields.Type = 'Ocorrência';
                fields.Resolution = ocurrence.note;
                fields.DescriptionLabel = ocurrence.description != null && ocurrence.description.length() > 50 ? ocurrence.description.abbreviate(50) : ocurrence.description;
                fields.ResolutionLabel = ocurrence.note != null && ocurrence.note.length() > 50 ? ocurrence.note.abbreviate(50) : ocurrence.note;           
                // dataToReturn.dataFieldsLst.add(fields);
                lFilterMap.put(fields.ProtocolNumber,fields);
            }  
        }    
        
        for(Case caseVariable :[SELECT Id, CaseNumber, LegacyProtocol__c, OccurrenceNumber__c, CreatedDate, Resolution__c, ClosedDate, EntryReason__c, toLabel(Status) FROM Case WHERE ContractBillingAccount__c = :lAccountId AND Id != :aRecordId AND (CreatedDate >= :formattedStartDate AND CreatedDate <= :formattedEndDate) ORDER BY CreatedDate DESC]){
            DataFields filter = caseVariable.LegacyProtocol__c != null ? lFilterMap.get(caseVariable.LegacyProtocol__c) : null;
            
            if(filter == null || (filter != null && filter.Type != 'Solicitações')){
                DataFields fields = new DataFields();
                
                fields.ProtocolNumber = caseVariable.CaseNumber;
                fields.OccurrenceNumber = caseVariable.OccurrenceNumber__c;
                fields.StartDate = caseVariable.CreatedDate != null ? caseVariable.CreatedDate.day() + '-' + caseVariable.CreatedDate.month() + '-' + caseVariable.CreatedDate.year() : null; 
                fields.EndDate =  caseVariable.ClosedDate != null ? caseVariable.ClosedDate.day() + '-' + caseVariable.ClosedDate.month() + '-' + caseVariable.ClosedDate.year() : null;
                fields.comparableStartDate =  caseVariable.CreatedDate != null ? Date.valueOf(caseVariable.CreatedDate) : null;
                fields.Status = caseVariable.Status;
                fields.Situation = caseVariable.Status;
                fields.Base = 'Solar';
                fields.Type = 'Caso';
                fields.Resolution = caseVariable.Resolution__c;
                fields.Description = caseVariable.EntryReason__c;
                fields.Id = caseVariable.Id;
                fields.DescriptionLabel =  caseVariable.EntryReason__c != null && caseVariable.EntryReason__c.length() > 50 ? caseVariable.EntryReason__c.abbreviate(50) : caseVariable.EntryReason__c;
                fields.ResolutionLabel = caseVariable.Resolution__c != null && caseVariable.Resolution__c.length() > 50 ? caseVariable.Resolution__c.abbreviate(50) : caseVariable.Resolution__c;
                // dataToReturn.dataFieldsLst.add(fields);
                lFilterMap.put(fields.ProtocolNumber,fields);
            }
        }
        dataToReturn.dataFieldsLst.addAll(lFilterMap.values());
        dataToReturn.dataFieldsLst.sort(); 
        system.debug('dataToReturn ' + dataToReturn);
        dataToReturn.StatusCode = 200;
        return dataToReturn;
    }

    //método copiado da classe CEC_360_IntegrationMobileProtocols e da classe CEC_360_Integration_ProtocolsResidential com intuito de trazer um retorno diferente, sem impactar as classes já desenvolvidas
    public static ProtocolWrapper getProtocols(String msisdn, String startDate, String endDate, String contractNumber, String operatorCode, String aBusinessUnit)
    {
        Protocols objProtocols = new Protocols ();
        ProtocolWrapper protocolReturn =  new ProtocolWrapper();
        CEC_RestObjects.mobileSubscribers objSubscriberAux = new  CEC_RestObjects.mobileSubscribers ();
        
        String service;
        HTTPRequest request = new HTTPRequest();

        if(aBusinessUnit == 'Net'){
            String newContractNumber = contractNumber.substringAfter('/').trim();     
            System.debug('newContractNumber ' + newContractNumber);
            service = CEC_360_ServiceName.getServiceName('Interactions');
            request.setEndpoint('callout:OAGNet'+ service + 
            '?contractNumber='+ newContractNumber + '&operatorCode=' 
            +operatorCode +  '&startDate=' + startDate + '&endDate=' + endDate);
        }
        else{//mobile
            objSubscriberAux = CEC_360_IntegrationsSubscriberHistory.getSubscriber(msisdn);
            service = CEC_360_ServiceName.getServiceName('Interactions');
            request.setEndpoint('callout:OAGClaro'+ service + 
            '?customerCrmID='+objSubscriberAux.crmSubscriberId +  
            '&page=1&limit=30&companyId=Movel'+ '&startDate=' + startDate + '&endDate=' + endDate);
        }
        if(test.isRunningTest()){        
            service = '/interactions';
            request.setEndpoint('/protocols');
        }
        
        try {
            request.setMethod('GET');
            request.setTimeout(120000);
            system.debug('GET PROTOCOLS ENDPOINT --------------->' + request.getEndpoint());
            HTTP http = new HTTP(); 
            protocolReturn.response = http.send(request);
            String responseBody = protocolReturn.response.getBody();
            system.debug('responseBody'+responseBody.replace('/n',''));         
            
            objProtocols = (Protocols)JSON.deserialize(responseBody, Protocols.class);
            system.debug('JSON RESPONSE BODY ##################################################### ' + responseBody);
            system.debug('### ObjProtocols'+objProtocols);
            if(objProtocols.data != null)
                protocolReturn.lstAttendences = objProtocols.data.attendances;
            system.debug('### lstAtt'+protocolReturn.lstAttendences);
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
            
        }
        system.debug('status code: ' + protocolReturn.response.getStatusCode());
        return protocolReturn;
    }

    //método copiado da classe CEC_360_IntegrationOcurrences com intuito de trazer um retorno diferente, sem impactar a classe já desenvolvida
    public static ProtocolWrapper getOcurrences(String contractNumber, String operatorCode, String startDate, String endDate) {
        String treatedStartDate = String.valueOf(Date.valueOf(startDate).year()) + '-' + String.valueOf(Date.valueOf(startDate).day()) + '-' +  String.valueOf(Date.valueOf(startDate).month());
        String treatedEndDate = String.valueOf(Date.valueOf(endDate).year()) + '-' +  String.valueOf(Date.valueOf(endDate).day()) + '-' +  String.valueOf(Date.valueOf(endDate).month());
        
        ProtocolWrapper protocolReturn = new ProtocolWrapper();
        CEC_RestObjects.occurrencesResponse occurrencesResponse = new CEC_RestObjects.occurrencesResponse();
        HTTPRequest request = new HTTPRequest();
		String service;
        
        service = CEC_360_ServiceName.getServiceName('contactRecords');
        request.setEndpoint('callout:OAGClaro' + service +
                            '?contractNumber=' + contractNumber +
                            '&operatorCode=' + operatorCode +
                            '&startDate=' + treatedStartDate + '&endDate=' + treatedEndDate + '&page=5');
        
        if(Test.isRunningTest()) {
		    service = '/contactrecords';
            request.setEndpoint('/ocurrences');
		}

		try {		
            request.setMethod('GET');
			request.setTimeout(120000);
            system.debug('GET Ocurrences ENDPOINT --------------->' + request.getEndpoint());

			HTTP http = new HTTP();
			protocolReturn.response = http.send(request);
			String responseBody = protocolReturn.response.getBody();
			system.debug('responseBody' + responseBody);
			system.debug(protocolReturn.response.getStatus());
			if(protocolReturn.response.getStatusCode() == 200) {
				occurrencesResponse = (CEC_RestObjects.occurrencesResponse) JSON.deserialize(responseBody.replace('\"number\"','\"number_Z\"' ), CEC_RestObjects.occurrencesResponse.class);
				protocolReturn.lstOcr = occurrencesResponse.data.data;
            }
            system.debug('### occurrencesResponse ' + occurrencesResponse);
            system.debug('### protocolReturn.lstOcr ' + protocolReturn.lstOcr);
		} 
		catch(CalloutException e) {
			System.debug('ERROR: ' + e);

		}
		return protocolReturn;
    }
    
    //Método que traz as Solics
    public static ProtocolWrapper getSolics(String contractNumber/*ContractReferenceNumber__c*/, String operatorCode/*CityCode__c*/, String startDate, String endDate, String searchTypeId, CEC_360_serviceName__mdt serviceName) { 
        String treatedStartDate = String.valueOf(Date.valueOf(startDate).year()) + '-' + String.valueOf(Date.valueOf(startDate).day()) + '-' +  String.valueOf(Date.valueOf(startDate).month());
        String treatedEndDate = String.valueOf(Date.valueOf(endDate).year()) + '-' +  String.valueOf(Date.valueOf(endDate).day()) + '-' +  String.valueOf(Date.valueOf(endDate).month());
        
        ProtocolWrapper protocolReturn = new ProtocolWrapper();

        CEC_360_IntegrationsOrderRequest.OrderReqRequest newOrderReqRequest = new CEC_360_IntegrationsOrderRequest.OrderReqRequest(operatorCode, Integer.valueOf(contractNumber));
        newOrderReqRequest.startDate = treatedStartDate;
        newOrderReqRequest.endDate = treatedEndDate;
        newOrderReqRequest.status = searchTypeId;

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(buildEndPoint(newOrderReqRequest, serviceName.ServiceName__c));
		request.setMethod('GET');
        request.setTimeout(120000);  

        if(Test.isRunningTest()) request.setEndpoint('/solics');
        
        protocolReturn.response = new HTTP().send(request);
        system.debug('Solic response code ' +  protocolReturn.response.getStatusCode());
        system.debug('Solic response body ' +  protocolReturn.response.getBody());
        CEC_360_IntegrationsOrderRequest.OrderReqResponse varOrderReqResponse = (CEC_360_IntegrationsOrderRequest.OrderReqResponse) JSON.deserialize(protocolReturn.response.getBody(), CEC_360_IntegrationsOrderRequest.OrderReqResponse.class);
        protocolReturn.lstSolic = varOrderReqResponse.data.requests;
        return protocolReturn;
    }

    //metodo copiado da classe CEC_360_IntegrationOrdersAbstract para montagem do endpoint da integração de SOLICS
    public static String buildEndPoint(Object varObject, String endPoint) {
        String parameters = '?';        
        List<String> listParameters = getListParametersByObj(varObject);
        
        for(Integer i = 0; i < listParameters.size(); i++) {
            if(listParameters.size()-1 == i) {
                parameters = parameters + listParameters.get(i);
            } else {
                parameters = parameters + listParameters.get(i) + '&';
            }
        }        
        String fullEndPoint = 'callout:OAGClaro' + endPoint + parameters;        
        return fullEndPoint;
    }
    
    //metodo copiado da classe CEC_360_IntegrationOrdersAbstract para montagem do endpoint da integração de SOLICS
    public static List<String> getListParametersByObj(Object varObject) {
        List<String> listParameters = new List<String>();        
        String jsonObject = JSON.serialize(varObject);
        Map<String, Object> mapObject = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
        
        for(String varParameterName : mapObject.keySet()) {
            String varParameterValue = (String) String.valueOf(mapObject.get(varParameterName));
            if(String.isNotBlank(varParameterValue)) {
                listParameters.add(varParameterName + '=' + varParameterValue);
            }
        }        
        return listParameters;
    }

    //método que retorna as OCs e OSs
    @AuraEnabled
    public static CEC_360_ShowRequisitionsController.Requisition getOCAndOS(String aSolic){
        DataFields lSolicParameter = (DataFields) JSON.deserialize(aSolic, DataFields.class);
        system.debug('aSolic ' + aSolic);
        system.debug('lSolicParameter ' + lSolicParameter);

        CEC_360_ShowRequisitionsController.Requisition lSolic = new CEC_360_ShowRequisitionsController.Requisition('1'); 

        //Teste que verifica se será feita integração OU se será utilizado um MOCK salvo no metadado personalizado, a fim de testar via MOCK
        List<SolarMockData__mdt> lMock = [SELECT MockData__c, Activate__c FROM SolarMockData__mdt WHERE DeveloperName = 'OCAndOS' LIMIT 1];
        if(!lMock.isEmpty() && lMock[0].Activate__c == true && !Test.isRunningTest()){
            lSolic = ( CEC_360_ShowRequisitionsController.Requisition)JSON.deserialize(lMock[0].MockData__c,  CEC_360_ShowRequisitionsController.Requisition.class);
            return lSolic;
        }
        else{
            lSolic.orderRequest = new CEC_360_IntegrationsOrderRequest.OrderReq();
            lSolic.listWorkOrder = new List<CEC_360_IntegrationsWorkOrder.WorkOrder>();
            lSolic.listConfigOrder = new List<CEC_360_IntegrationsConfiguration.ConfigOrder>();
            // system.debug('lSolic ' + lSolic);
                
            lSolic.orderRequest.contractNumber = lSolicParameter.OccurrenceNumber;
            lSolic.orderRequest.requestID = lSolicParameter.RequestID;
            lSolic.orderRequest.operatorCode = lSolicParameter.OperatorCode;

            String lRequisition = JSON.serialize(lSolic);
            CEC_360_ShowRequisitionsController.Requisition lOS = new CEC_360_ShowRequisitionsController.Requisition('1');
            lOS = CEC_360_ShowRequisitionsController.getOSs(lRequisition);   //OSs;

            CEC_360_ShowRequisitionsController.Requisition lOC = new CEC_360_ShowRequisitionsController.Requisition('1');
            lOC = CEC_360_ShowRequisitionsController.getOCs(lRequisition); //OCs

            lSolic.listWorkOrder = lOS.listWorkOrder;
            lSolic.listConfigOrder = lOC.listConfigOrder;

            return lSolic;
        }
    }

    //método que retorna o campo MEMO do PS8 para protocolos
    @AuraEnabled
    public static Protocols getMoreInfo(String aProtocol){
        Protocols objProtocols = new Protocols();

        //Teste que verifica se será feita integração OU se será utilizado um MOCK salvo no metadado personalizado, a fim de testar via MOCK
        List<SolarMockData__mdt> lMock = [SELECT MockData__c, Activate__c FROM SolarMockData__mdt WHERE DeveloperName = 'PS8MoreDetails' LIMIT 1];
        if(!lMock.isEmpty() && lMock[0].Activate__c == true && !Test.isRunningTest()){
            objProtocols = (Protocols)JSON.deserialize(lMock[0].MockData__c, Protocols.class);
            return objProtocols;
        }
        else{

            HTTPRequest request = new HTTPRequest();
            String service = CEC_360_ServiceName.getServiceName('Interactions');
            
            request.setEndpoint('callout:OAGClaro' + service +
                                '?protocolNumber=' + aProtocol +
                                '&companyId=Movel');
            
            if(Test.isRunningTest()) {
                request.setEndpoint('/memo');
            }
            try {		
                request.setMethod('GET');
                request.setTimeout(120000);
                system.debug('GET GETMEMOFIELD ENDPOINT --------------->' + request.getEndpoint());

                HTTP http = new HTTP();
                HttpResponse response = new HttpResponse();
                response = http.send(request);
                String responseBody = response.getBody();
                system.debug('responseBody' + responseBody);
                system.debug(response.getStatus());
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    system.debug('MoreInfos response -------------------> ' + JSON.serialize(responseBody));
                    objProtocols = (Protocols)JSON.deserialize(responseBody, Protocols.class);
                }
                else{
                    System.debug('Erro de integração ao buscar informações adicionais no PS8. Entre em contato com o administrador do sistema.');
                    throw new AuraHandledException('Erro de integração ao buscar informações adicionais no PS8. Entre em contato com o administrador do sistema.');
                    // return null;                
                }
                system.debug('### MEMO PROTOCOLS ' + objProtocols);
                return objProtocols;
            } 
            catch(CalloutException e) {
                System.debug('Erro ao buscar informações do protocolo: ' + e);
                throw new AuraHandledException('Erro ao buscar informações do protocolo: ' + e);
            }
        }
    }


    public class ProtocolWrapper{
       public HttpResponse response;
       @AuraEnabled public List<attendences> lstAttendences;
       @AuraEnabled public List<CEC_RestObjects.ocurrencesObj> lstOcr;
       @AuraEnabled public List<CEC_360_IntegrationsOrderRequest.OrderReq> lstSolic;

        public ProtocolWrapper(){
            response = new HttpResponse();
            lstAttendences = new List<attendences>();
            lstOcr = new List<CEC_RestObjects.ocurrencesObj>();
            lstSolic = new List<CEC_360_IntegrationsOrderRequest.OrderReq>();
        }
    }

    public class ComponentDataWrapper{
        @AuraEnabled public List<DataFields> dataFieldsLst;
        @AuraEnabled public Integer StatusCode;

        public ComponentDataWrapper(){
            dataFieldsLst = new List<DataFields>();
        }
    }

    public class Protocols {
        @AuraEnabled public  String apiVersion;
        @AuraEnabled public  String transactionId;
        @AuraEnabled public  DataProtocols data;        
    }
    
    public class dataProtocols{
        @AuraEnabled public List<attendences> attendances;
    }
    
    public class attendences{
        @AuraEnabled public string order;
        @AuraEnabled public string protocolNumber;
        @AuraEnabled public string interactionNumber; 
        @AuraEnabled public string action;
        @AuraEnabled public string solicitationType;
        @AuraEnabled public string solicitationDateOpening;
        @AuraEnabled public string solicitationDateClosing;
        @AuraEnabled public string solicitationStatus;
        @AuraEnabled public string channelRequestId;
        @AuraEnabled public string contactName;
        @AuraEnabled public String situation;
        @AuraEnabled public String reasonDescription1;
        @AuraEnabled public String reasonDescription2;
        @AuraEnabled public String reasonCode1;
        @AuraEnabled public String reasonCode2;
        @AuraEnabled public String reasonCode3;
        @AuraEnabled public String reasonCode4;
        @AuraEnabled public String reasonCode5;
        @AuraEnabled public String memo;
        @AuraEnabled public String updateResume;
        @AuraEnabled public String updateDetail;
        @AuraEnabled public String description;
        @AuraEnabled public String slaIndicatorExceeded;
        @AuraEnabled public String reclassificationIndicator;
        @AuraEnabled public String synthesisRanking;
        @AuraEnabled public String interactionSequenceId;
        @AuraEnabled public List<UpdateInteraction> updateInteraction;

        public attendences(){
            updateInteraction = new List<UpdateInteraction>();
        }
    }

    public class UpdateInteraction{
        @AuraEnabled public string updateResume;
        @AuraEnabled public string updateDetail;
        @AuraEnabled public List<Datetime> updateDate;

        public UpdateInteraction(){
            updateDate = new List<Datetime>();
        }
    }

    global class DataFields implements Comparable{
        @AuraEnabled public String ProtocolNumber;
        @AuraEnabled public String OccurrenceNumber;
        @AuraEnabled public String StartDate;
        @AuraEnabled public String EndDate;
        @AuraEnabled public String Status;
        @AuraEnabled public String Situation;
        @AuraEnabled public String Description;
        @AuraEnabled public String Base;
        @AuraEnabled public String Resolution;
        @AuraEnabled public String Type;
        @AuraEnabled public String Id;
        @AuraEnabled public String DescriptionLabel;
        @AuraEnabled public String ResolutionLabel;
        @AuraEnabled public String RequestID;
        @AuraEnabled public String OperatorCode;        
        @AuraEnabled public Date comparableStartDate;

        
        global Integer compareTo(Object compareTo) {
            DataFields dataFields = (DataFields)compareTo;
            if(comparableStartDate == null){
                return 1;
            }

            Date newStartDate = date.valueOf(comparableStartDate);
            Date newComparableDate = date.valueOf(dataFields.comparableStartDate);

            if (newStartDate ==  newComparableDate) return 0;
            if (newStartDate < newComparableDate) return 1;
            return -1;   
        }
    }
}