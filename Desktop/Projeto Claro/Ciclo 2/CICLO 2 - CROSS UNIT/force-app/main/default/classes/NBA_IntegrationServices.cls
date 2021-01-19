/*--------------------------------------------------------------------------------------------
  --- Company: Accenture Brasil
  --- Creation Date: 06/03/2019
  --- Author: Dylan Santos 
  --- Description: Classe de controle dos serviços de NBA
  ----------------------------------------------------------------------------------------------*/
  public class NBA_IntegrationServices {

	public static String sendRetained(NBA_IntegrationModels.retainedObject payload, String operatorCode, String login, String identifierType, String notes, String cdBase, String recordId){
		NBA_Integration_Definitions__mdt configuracao 	= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Send_Retained');
		Map<String, Object> payloadmap = (Map<String, Object>)Json.deserializeUntyped(Json.serializePretty(payload));
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);
		System.debug('>>> response.body: ' + response.body);
  
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.body);
		Map<String, Object> mData = (Map<String, Object>) m.get('data');
		Map<String, Object> mEventType = (Map<String, Object>) mData.get('eventType');

		String occurrenceId = String.valueOf(mEventType.get('identifier')); 
		System.debug('>>>>' + String.valueOf(mEventType.get('identifier')));
		
		Case caso = [SELECT CallParameterIndt__c, Status FROM Case Where id = :recordId];
	    caso.CallParameterIndt__c += 'Abertura:' + identifierType + ';' + 'Fechamento:' + cdBase + ';' + 'Ocorrencia:' + occurrenceId + ';';
		//caso.status = 'Encerrado';
		update caso;
		             
		//return sendRetainedPatch(occurrenceId, operatorCode, login, identifierType, notes, cdBase, recordId); 
		return JSON.serializePretty(response); 
	}
		
	public static String sendRetainedPatch(String occurrenceId, String operatorCode, String login, String identifierType, String notes, String cdBase, String recordId){
		NBA_Integration_Definitions__mdt configuracao 	= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Send_Retained_Patch');
		Map<String, Object> payloadmap = new Map<String, Object>();
		

		NBA_IntegrationModels.retainedObjectPatch objectPatch = new NBA_IntegrationModels.retainedObjectPatch();
		NBA_IntegrationModels.retainedObjectPatchRes objectPatchRes = new NBA_IntegrationModels.retainedObjectPatchRes();
		objectPatch.operatorCode 		= operatorCode;
		objectPatch.occurrenceId		= occurrenceId; 
		objectPatch.resolution 			= objectPatchRes;
		objectPatch.source     			= 'CLARO';
		objectPatch.userLogin	 		= login;
		objectPatch.resolution.id		= cdBase;
		objectPatch.resolution.notes    = notes;
		//objectPatch.resolution.notes   	= 'Motivo da ligação: Sondagem N1 CallReason__c e N2 Subreason__c | Resultado Chamada: TV: Res. Nc3advel 1 (OBJETO CASO TVN1Result__c) / Res. Nc3advel 2 (OBJETO CASO TVN2Result__c) / Res. Nc3advel 3 (OBJETO CASO TVN1Result__c) | \r\n\r\nNc3bamero de Protocolo c39anico: | \r\n\r\nROBO CEC - NBA / Nome do Operador: (OBJETO user NAME) / Login do Operador: Z077141 / Nome do Supervisor: / Canal: retencao / EPS: NEOBPO |BL: Res. Nc3advel 1  / Res. Nc3advel 2 COM OFERTA / Res. Nc3advel 3 EXCLUSIVA | \r\n\r\nNc3bamero de Protocolo c39anico: | \r\n\r\nROBO CEC - NBA / Nome do Operador: ISABELA SANTOS RIBEIRO / Login do Operador: Z077141 / Nome do Supervisor: / Canal: retencao / EPS: NEOBPO | \r\n\r\n=====================================================\r\n';

		payloadmap = (Map<String, Object>)Json.deserializeUntyped(Json.serializePretty(objectPatch));

		NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel(); 
		response = Test.isRunningTest() ? response : NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);
		//System.debug('>>> response.body: ' + response.body);

		Case caso = [SELECT CallParameterIndt__c, Status FROM Case Where id = :recordId];        
        caso.CallParameterIndt__c = caso.CallParameterIndt__c + 'Envio:Sucesso;';
		caso.status = 'Encerrado';
		update caso;

		return JSON.serializePretty(response); 
	}

	public static NBA_IntegrationUtils.HttpResponseModel checkValidateCepPortability(string cep){
		NBA_Integration_Definitions__mdt configuracao			= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Valida_DDD_Portabilidade');
		Map<String, Object> payloadmap = new Map<String, Object>();
		payloadmap.put('zipCode',cep);
		NBA_IntegrationUtils.HttpResponseModel response	= NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);
		System.debug('>>> response.body: ' + response.body);
		return response;
	}

	public static NBA_IntegrationUtils.HttpResponseModel checkPortability(string celular){
		NBA_IntegrationModels.CheckPortability portabilidade	= new NBA_IntegrationModels.CheckPortability();
		NBA_Integration_Definitions__mdt configuracao			= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Portability_Validation');	
		NBA_IntegrationModels.CheckPortability 	 chkPortability	= new NBA_IntegrationModels.CheckPortability();
		list<NBA_IntegrationModels.mobilenumber> mblnumber		= new list<NBA_IntegrationModels.mobilenumber>();
		NBA_IntegrationModels.telephoneNumbers 	 tlpnumber 		= new NBA_IntegrationModels.telephoneNumbers();
		NBA_IntegrationModels.mobilenumber		 mobilephone	= new NBA_IntegrationModels.mobilenumber();
		mobilephone.mobilenumber = celular.replaceAll('[^0-9]','');
		mblnumber.add(mobilephone);
		tlpnumber.telephoneNumbers = mblnumber;
		chkPortability.data = tlpnumber;
		String payload = Json.serializePretty(chkPortability).replace('mobilenumber', 'number');
		Map<String, Object> payloadmap = (Map<String, Object>)Json.deserializeUntyped(payload);
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);
		System.debug('>>> response.body: ' + response.body);
		return response;
    
	}

	public static NBA_IntegrationModels.SearchOffersResponse getOffers(Map<String, object> query) {
		NBA_IntegrationModels.SearchOffersResponse retorno	= new NBA_IntegrationModels.SearchOffersResponse();
		NBA_Integration_Definitions__mdt configuracao		= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_List_Offers');
		NBA_IntegrationUtils.HttpResponseModel response		= NBA_IntegrationUtils.sendRequest(configuracao, query);
				
		retorno												= (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(response.body, NBA_IntegrationModels.SearchOffersResponse.class);
		return retorno;
	}

	public static NBA_IntegrationModels.OfferValidationResponse OfferValidation(Map<String, object> request, String regionId) {
		NBA_IntegrationModels.OfferValidationResponse retorno	= new NBA_IntegrationModels.OfferValidationResponse();
		NBA_Integration_Definitions__mdt configuracao			= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Offer_Validation');
		configuracao.NBA_Endpoint__c 							+= '/' + regionId;
		NBA_IntegrationUtils.HttpResponseModel response			= NBA_IntegrationUtils.sendRequest(configuracao, request);
		
		// mock inicio
		response.body = '{ "apiVersion": "1;2020-03-20", "transactionId": "Id-62a9215f14cd073930b38d65", "data": {"products":{"phone":{"additional":{},"adhesion":{"id":2029,"name":"UPGRADE DE SELECAO","period":0,"price":0},"id":27738,"name":"FONE ILIM BR TOTAL EXC RET 20.00","profile":{"id":460,"name":"VIRTUA + FONE"}}},"requestID":"edbfb3d7-3728-484f-9430-1d8c88b8ae2e","scheduling":true}  }';
		response.statusCode = 200;
		// mock fim				
		
		retorno.statusCode 										= response.statusCode;		
		if(retorno.statusCode == 200){
            System.debug('>>> response.body: ' + response.body);
			retorno.content    									= (NBA_IntegrationModels.OfferValidationResponseContent) JSON.deserialize(response.body, NBA_IntegrationModels.OfferValidationResponseContent.class);			
        
		}
		
		return retorno;
	}

	public static NBA_IntegrationModels.CurrentProductResponse getCurrentProduct(Map<String, object> query) {
		NBA_IntegrationModels.CurrentProductResponse retorno = new NBA_IntegrationModels.CurrentProductResponse();

		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Current_Products');
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);
		//NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();

		System.debug('>>> response.body: ' + response.body);
		retorno = (NBA_IntegrationModels.CurrentProductResponse) JSON.deserialize(response.body, NBA_IntegrationModels.CurrentProductResponse.class);
		
		return retorno;
	}

	public static NBA_IntegrationModels.AgendamentoResponse getAgendamento(Map<String, object> query) {

		NBA_IntegrationModels.AgendamentoResponse retorno = new NBA_IntegrationModels.AgendamentoResponse();

		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Agendamento');

		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);
		//NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();
		//response.body = '{"apiVersion":"1;2018-10-17","transactionId":"Id-3510b75cf3451fd26405708b","data":{"schedule":[{"field":"SANT07","class":"CLASSE5","requeridMinutes":"72","periods":[{"description":"20:00 - 23:00","availableMinutes":"36000","startHour":"20:00:00","endHour":"23:00:00","date":"2019-05-17","periodTypeId":"100","emergency":"0","isCapacityRegistration":true},{"description":"17:00 - 20:00","availableMinutes":"38200","startHour":"17:00:00","endHour":"20:00:00","date":"2019-05-17","periodTypeId":"97","emergency":"0","isCapacityRegistration":true},{"description":"14:00 - 17:00","availableMinutes":"43500","startHour":"14:00:00","endHour":"17:00:00","date":"2019-05-17","periodTypeId":"94","emergency":"0","isCapacityRegistration":true},{"description":"11:00 - 14:00","availableMinutes":"45000","startHour":"11:00:00","endHour":"14:00:00","date":"2019-05-17","periodTypeId":"91","emergency":"0","isCapacityRegistration":true},{"description":"08:00 - 11:00","availableMinutes":"14900","startHour":"08:00:00","endHour":"11:00:00","date":"2019-05-17","periodTypeId":"88","emergency":"0","isCapacityRegistration":true},{"description":"20:00 - 23:00","availableMinutes":"36000","startHour":"20:00:00","endHour":"23:00:00","date":"2019-05-18","periodTypeId":"100","emergency":"0","isCapacityRegistration":true},{"description":"17:00 - 20:00","availableMinutes":"38200","startHour":"17:00:00","endHour":"20:00:00","date":"2019-05-18","periodTypeId":"97","emergency":"0","isCapacityRegistration":true},{"description":"14:00 - 17:00","availableMinutes":"43500","startHour":"14:00:00","endHour":"17:00:00","date":"2019-05-18","periodTypeId":"94","emergency":"0","isCapacityRegistration":true},{"description":"11:00 - 14:00","availableMinutes":"45000","startHour":"11:00:00","endHour":"14:00:00","date":"2019-05-18","periodTypeId":"91","emergency":"0","isCapacityRegistration":true},{"description":"08:00 - 11:00","availableMinutes":"14900","startHour":"08:00:00","endHour":"11:00:00","date":"2019-05-18","periodTypeId":"88","emergency":"0","isCapacityRegistration":true}]}]}}';
		//System.debug('response.body: ' + response.body);

		retorno = NBA_WorkOrderSchedulesParser.parse(response.body);
		return retorno;
	}

	public static NBA_IntegrationUtils.HttpResponseModel provisionamento(String idOrder) {
		NBA_IntegrationUtils.HttpResponseModel retorno = new NBA_IntegrationUtils.HttpResponseModel();
		NBA_IntegrationModels.RPA_Data pedido = NBA_CustomRPA.provisionamento(idOrder);
		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('RPA_Aprovisionamento');
		retorno = NBA_IntegrationUtils.sendRequest(configuracao, pedido);
		return retorno;
	}

	public static NBA_IntegrationModels.NewExtrasResponse getAdicionais(Map<String, object> query) {

		NBA_IntegrationModels.NewExtrasResponse retorno = new NBA_IntegrationModels.NewExtrasResponse();

		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_List_Adicionais');

		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);
		//response.body = response.body.replaceAll('class', 'classSchedule');
		//response.body = response.body.replaceAll('date', 'dateSchedule');
		//response.body = response.body.replaceAll('field', 'fieldSchedule');
		
		retorno = (NBA_IntegrationModels.NewExtrasResponse) JSON.deserialize(response.body, NBA_IntegrationModels.NewExtrasResponse.class);

		return retorno;
	}

	public static NBA_IntegrationUtils.HttpResponseModel enviarOfertaAceita(String caseId) {
		NBA_IntegrationUtils.HttpResponseModel retorno	= new NBA_IntegrationUtils.HttpResponseModel();
		NBA_IntegrationModels.Offer_Accepted oferta		= NBA_AcceptedOffer.createdOffer( caseId );
		NBA_Integration_Definitions__mdt configuracao	= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Return_Offers');
		retorno = NBA_IntegrationUtils.sendRequest(configuracao, oferta);
		return retorno;
	}
	
	public static NBA_IntegrationModels.RespostaContratoResidencial consultarApiContratoResidencial(Map<String, object> query) {
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Contrato_Viabilidade'), query);
		return (NBA_IntegrationModels.RespostaContratoResidencial) JSON.deserialize(response.body, NBA_IntegrationModels.RespostaContratoResidencial.class);
	}

	public static NBA_IntegrationModels.RespostaContratoMovel consultarApiContratoMovel (Map<String, object> query) {
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Inadimplencia_Movel'), query);
		response.body = '{ "data": { "subscribers": [ { "productStatus": "ATIVO", "reason": "COBRANCA" } ] } }';
		return (NBA_IntegrationModels.RespostaContratoMovel) JSON.deserialize(response.body, NBA_IntegrationModels.RespostaContratoMovel.class);
	}

	public static NBA_IntegrationModels.ViabilidadeResponse getViabilidadeTecnica(Map<String, object> query) {

		NBA_IntegrationModels.ViabilidadeResponse retorno = new NBA_IntegrationModels.ViabilidadeResponse();
		// criar metadata de configuração
		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Viabilidade');

		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);

		retorno = (NBA_IntegrationModels.ViabilidadeResponse) JSON.deserialize(response.body, NBA_IntegrationModels.ViabilidadeResponse.class);
		
		return retorno;
	}

	public static NBA_IntegrationModels.GestorCreditoResponse getGestorCredito (NBA_IntegrationModels.DataGestorCreditoRequest request) {
		NBA_IntegrationModels.GestorCreditoResponse retorno = new NBA_IntegrationModels.GestorCreditoResponse();
		NBA_Integration_Definitions__mdt configuracao		= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Gestor_Credito');
		NBA_IntegrationUtils.HttpResponseModel response		= NBA_IntegrationUtils.sendRequest(configuracao, request);
		
		if(response != null && response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202){
			retorno											= (NBA_IntegrationModels.GestorCreditoResponse) JSON.deserialize(response.body, NBA_IntegrationModels.GestorCreditoResponse.class);
		}else {
			NBA_IntegrationModels.GestorCreditoResponse gestorResponse = new NBA_IntegrationModels.GestorCreditoResponse();
			gestorResponse.analiseError						= true;
			retorno											= gestorResponse;
		}
		//retorno											= NBA_IntegrationUtils.searchMockAnalise('Mock_Analise_RP');
		return retorno;
	}

}