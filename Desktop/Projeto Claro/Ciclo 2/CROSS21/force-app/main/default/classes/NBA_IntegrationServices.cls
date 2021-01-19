/*--------------------------------------------------------------------------------------------
  --- Company: Accenture Brasil
  --- Creation Date: 06/03/2019
  --- Author: Dylan Santos 
  --- Description: Classe de controle dos serviços de NBA
  ----------------------------------------------------------------------------------------------*/
public class NBA_IntegrationServices {
	
	public static NBA_IntegrationUtils.HttpResponseModel portabilityPerformPreAnalysis(Map<String, Object> payload){
		NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();
		try {
			response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_PortabilityPreAnalysis'), payload);
		}
		catch (Exception e){}
		return response;
	}
	
	public static NBA_IntegrationUtils.HttpResponseModel portabilityValidateMatchingDDD(Map<String, Object> payload){
		NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();
		try {
			response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_MobileAddress'), payload);
		}
		catch (Exception e){}
		return response;		
	}

	public static NBA_IntegrationUtils.HttpResponseModel portabilityValidateOwnership(Map<String, Object> payload){
		NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();
		try {
			response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_MobileOwnership'), payload);
		}
		catch (Exception e){}
		return response;
	}

	public static String sendRetained(NBA_IntegrationModels.retainedObject payload, String operatorCode, String login, String identifierType, String notes, String cdBase, String recordId){
		NBA_Integration_Definitions__mdt configuracao 	= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Send_Retained');
		Map<String, Object> payloadmap = (Map<String, Object>)Json.deserializeUntyped(Json.serializePretty(payload));
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);
  
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.body);
		Map<String, Object> mData = (Map<String, Object>) m.get('data');
		Map<String, Object> mEventType = (Map<String, Object>) mData.get('eventType');

		String occurrenceId = String.valueOf(mEventType.get('identifier')); 
		
		Case caso = [SELECT CallParameterIndt__c, Status FROM Case Where id = :recordId];
	    caso.CallParameterIndt__c += 'Abertura:' + identifierType + ';' + 'Fechamento:' + cdBase + ';' + 'Ocorrencia:' + occurrenceId + ';';
		update caso;
		             
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

		payloadmap = (Map<String, Object>)Json.deserializeUntyped(Json.serializePretty(objectPatch));

		NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel(); 
		response = Test.isRunningTest() ? response : NBA_IntegrationUtils.sendRequest(configuracao, payloadmap);

		Case caso = [SELECT CallParameterIndt__c, Status FROM Case Where id = :recordId];
        caso.CallParameterIndt__c = caso.CallParameterIndt__c + 'Envio:Sucesso;';
		caso.status = 'Encerrado';
		update caso;

		return JSON.serializePretty(response); 
	}	

	public static NBA_IntegrationModels.SearchOffersResponse getOffers(Map<String, object> query) {
		NBA_IntegrationModels.SearchOffersResponse retorno	= new NBA_IntegrationModels.SearchOffersResponse();
		NBA_Integration_Definitions__mdt configuracao		= NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_List_Offers');
		NBA_IntegrationUtils.HttpResponseModel response		= NBA_IntegrationUtils.sendRequest(configuracao, query);

		retorno												= (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(response.body, NBA_IntegrationModels.SearchOffersResponse.class);
		return retorno;
	}

	public static NBA_IntegrationModels.OfferValidationResponse OfferValidation(Map<String, object> request, String regionId) {
		NBA_IntegrationModels.OfferValidationResponse retorno = new NBA_IntegrationModels.OfferValidationResponse();
		try {
			NBA_Integration_Definitions__mdt configuration = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Offer_Validation');
			configuration.NBA_Endpoint__c += '/' + regionId;
			
			NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuration, request);			
			retorno.statusCode = response.statusCode;
			retorno.response = (NBA_IntegrationModels.OfferValidationResponseContent) JSON.deserialize(response.body, NBA_IntegrationModels.OfferValidationResponseContent.class);
			
			if(retorno.response.error!=null && String.isNotBlank(retorno.response.error.detailedMessage)){
				retorno.response.error.textMessages = new List<String>();
				try{
					for(NBA_IntegrationModels.OfferValidationError erro : ((NBA_IntegrationModels.OfferValidationErrorObj) JSON.deserialize(retorno.response.error.detailedMessage, NBA_IntegrationModels.OfferValidationErrorObj.class)).errors)
						if(String.isNotBlank(erro.message))	
							retorno.response.error.textMessages.add(erro.message);
				}catch (Exception e){}
			}else{
				retorno.response.error = new NBA_IntegrationModels.OfferValidationResponseError();
			}
		} 
		catch (Exception e){
			retorno.ValidationSuccess = false;
		}
		return retorno;
	}

	public static NBA_IntegrationModels.CurrentProductResponse getCurrentProduct(Map<String, object> query) {
		NBA_IntegrationModels.CurrentProductResponse retorno = new NBA_IntegrationModels.CurrentProductResponse();
		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Current_Products');
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);
		
		retorno = (NBA_IntegrationModels.CurrentProductResponse) JSON.deserialize(response.body, NBA_IntegrationModels.CurrentProductResponse.class);
		return retorno;
	}

	public static NBA_IntegrationModels.AgendamentoResponse getAgendamento(Map<String, object> query) {
		NBA_IntegrationModels.AgendamentoResponse retorno = new NBA_IntegrationModels.AgendamentoResponse();
		NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Agendamento');
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(configuracao, query);
		
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
		return (NBA_IntegrationModels.RespostaContratoMovel) JSON.deserialize(response.body, NBA_IntegrationModels.RespostaContratoMovel.class);
	}

	public static NBA_IntegrationModels.ViabilidadeResponse getViabilidadeTecnica(Map<String, object> query) {
		NBA_IntegrationModels.ViabilidadeResponse retorno = new NBA_IntegrationModels.ViabilidadeResponse();
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
		return retorno;
	}

	public static NBA_IntegrationModels.SalesmanResponse getSalesmanData(Map<String, object> query) {
		NBA_IntegrationUtils.HttpResponseModel response = NBA_IntegrationUtils.sendRequest(NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Salesman_Residential'), query);
		return (NBA_IntegrationModels.SalesmanResponse) JSON.deserialize(response.body, NBA_IntegrationModels.SalesmanResponse.class);
	}

}