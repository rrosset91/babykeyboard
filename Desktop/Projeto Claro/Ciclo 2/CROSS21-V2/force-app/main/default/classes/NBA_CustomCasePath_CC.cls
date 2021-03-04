public with sharing class NBA_CustomCasePath_CC {
		
		// Métodos para o componente "NBA_CustomCasePath"
		@AuraEnabled 
		public static String sendRetained(String recordId, String reason, String subReason, String tvn1, String tvn2, String tvn3, String bln1, String bln2, String bln3, String phonen1, String phonen2, String phonen3, String mobilen1, String mobilen2, String mobilen3, String lctn1, String lctn2, String lctn3, String cdBase){
			NBA_IntegrationModels.retainedObject payload = new NBA_IntegrationModels.retainedObject();
			NBA_IntegrationModels.retainedObjectData payloadData = new NBA_IntegrationModels.retainedObjectData();
			User usr 									 = [SELECT Login__c, NetServicos__c, phone, name, companyname FROM User WHERE Id = :UserInfo.getUserId()];
			Case caseRegister                            = [SELECT id, CallParameterIndt__c, CallReason__c, Subreason__c, ContractNumber__r.CityCode__c, ContractNumber__r.ContractNumber__c, ContractNumber__r.Account.Name, TVN1Result__c, TVN2Result__c, TVN3Result__c, BLN1Result__c, BLN2Result__c, BLN3Result__c, PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, MobileN1Result__c, MobileN2Result__c, MobileN3Result__c, ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c  FROM  Case WHERE id = :recordId];
			String notes;
			String cdBaseFromDatabase;
			String occurrenceId;

			for (String item : caseRegister.CallParameterIndt__c.split(';')) {
				if(item.startsWith('Base')){
					cdBaseFromDatabase = item.split(':')[1];
					
				}else if(item.startsWith('Ocorrencia')){
					occurrenceId = item.split(':')[1];
				}
			}
			
			Parametros_NBA_Retido__mdt configuracao = [SELECT note__c, Id_Fechamento__c, identifierType__c, description__c from Parametros_NBA_Retido__mdt WHERE Label = : cdBaseFromDatabase];

			subReason = String.isBlank(subReason) ? 'Não informado' : subReason;
			reason = String.isBlank(reason) ? 'Não informado' : reason;
			if(String.isNotBlank(occurrenceId)){
				tvn1 = caseRegister.TVN1Result__c;
				tvn2 = caseRegister.TVN2Result__c;
				tvn3 = caseRegister.TVN3Result__c;
				
				bln1 = caseRegister.BLN1Result__c;
				bln2 = caseRegister.BLN2Result__c;
				bln3 = caseRegister.BLN3Result__c;

				phonen1 = caseRegister.PhoneN1Result__c;
				phonen2 = caseRegister.PhoneN2Result__c;
				phonen3 = caseRegister.PhoneN3Result__c;

				mobilen1 = caseRegister.MobileN1Result__c;
				mobilen2 = caseRegister.MobileN2Result__c;
				mobilen3 = caseRegister.MobileN3Result__c;

				lctn1 = caseRegister.ALaCarteN1Result__c;
				lctn2 = caseRegister.ALaCarteN2Result__c;
				lctn3 = caseRegister.ALaCarteN3Result__c;

			}
			notes = 'Motivo da ligação: Sondagem N1: ' + reason + ' e N2: ' + subReason + 
					'\r\n' +
					'\r\nResultado Chamada:' +
					'\r\nTV: Res. Nível 1: ' 		 + tvn1 	+ ' / Res. Nível 2: ' + tvn2 	 + ' / Res. Nível 3: ' + tvn3 +
					'\r\nBL: Res. Nível 1: ' 		 + bln1 	+ ' / Res. Nível 2: ' + bln2 	 + ' / Res. Nível 3: ' + bln3 +
					'\r\nPHONE: Res. Nível 1: ' 	 + phonen1 	+ ' / Res. Nível 2: ' + phonen2  + ' / Res. Nível 3: ' + phonen3 +
					'\r\nMOBILE: Res. Nível 1: ' 	 + mobilen1 + ' / Res. Nível 2: ' + mobilen2 + ' / Res. Nível 3: ' + mobilen3 + 
					'\r\nA LA CARTE: Res. Nível 1: ' + lctn1 	+ ' / Res. Nível 2: ' + lctn2    + ' / Res. Nível 3: ' + lctn3 +
					'\r\n' +
					'\r\nNúmero de Protocolo único: ' +
					'\r\nNome do Operador: ' + usr.name + ' / Login do Operador: ' + usr.NetServicos__c + ' / Nome do Supervisor: / Canal: retencao / EPS: ' + usr.companyname + '' ;
			
			cdBase = configuracao.Id_Fechamento__c;
			
			//Populating fields of payload \õ/
			payload.data 				 = payloadData;
			payload.application 		 = 'OTHER';
			payload.data.sourceEvent 	 = 'CLARO';
			payload.data.login 			 = value(usr.NetServicos__c);
			payload.data.note 			 = notes;
			payload.data.identifierType	 = configuracao.identifierType__c;
			payload.data.description	 = configuracao.note__c;
			payload.data.name			 = value(caseRegister.ContractNumber__r.Account.Name);
			payload.data.contractNumber	 = value(caseRegister.ContractNumber__r.ContractNumber__c);
			payload.data.operatorCode	 = value(caseRegister.ContractNumber__r.CityCode__c); 
			payload.data.areaCode		 = '027';
			payload.data.telephoneNumber = value(usr.phone);

			System.debug('Request body >>>>>>');
			System.debug(JSON.serializePretty(payload)); 
			
			if(String.isBlank(occurrenceId)){
				return NBA_IntegrationServices.sendRetained(payload, payload.data.operatorCode, payload.data.login, payload.data.identifierType, notes, cdBase, recordId);
			}else if (String.isNotBlank(occurrenceId) && caseRegister.CallParameterIndt__c.contains('Sucesso')== false ){
				return NBA_IntegrationServices.sendRetainedPatch(occurrenceId, payload.data.operatorCode, payload.data.login, payload.data.identifierType, notes , cdBase, recordId);
			}else { 
				NBA_IntegrationUtils.HttpResponseModel response = new NBA_IntegrationUtils.HttpResponseModel();
				response.status = 'NOK';
				return JSON.serializePretty(response);
			}
		}

	public static String value(Object obj){
		return obj == null ? '' : String.valueOf(obj);
	}

	@AuraEnabled
	public static Case consultarCase(id recordId) {
		List<Case> lstCase = [SELECT id, CallReason__c, Subreason__c, Time_of_Service__c, RecordType.DeveloperName FROM Case WHERE id = :recordId];

		if (!lstCase.isEmpty())
			return lstCase[0];
		else
			return new Case();
	}

	@AuraEnabled
	public static List<NBA_CustomCasePath_CC.Stage> consultarStages(String caseSerial) {
		Case caseRecord = (Case)JSON.deserialize(caseSerial, Case.class);
		List<NBA_CustomCasePath_CC.Stage> stages = new List<NBA_CustomCasePath_CC.Stage> ();
		Boolean currentStage = false;
		for (Schema.PicklistEntry pickListVal : Case.Time_of_Service__c.getDescribe().getPicklistValues()) {
			NBA_CustomCasePath_CC.Stage stage = new NBA_CustomCasePath_CC.Stage();
			stage.label = pickListVal.getLabel();
			if (!currentStage && caseRecord.Time_of_Service__c == pickListVal.getValue()) {
				currentStage = true;
				stage.current = true;
			}
			if (pickListVal.isActive()) {
				stage.checked = !currentStage;
				stages.add(stage);
			}
		}
		
		if(caseRecord.CallReason__c != null)
			stages = updateStageByPoll(JSON.serialize(stages), JSON.serialize(caseRecord));

		return stages;
	}

	@AuraEnabled
	public static List<NBA_CustomCasePath_CC.Stage> updateStageByPoll(String stages, String caseSerial) {
		Case caseRecord = (Case)JSON.deserialize(caseSerial, Case.class);
		List<NBA_CustomCasePath_CC.Stage> stagesPicklist = (List<NBA_CustomCasePath_CC.Stage>) JSON.deserialize(stages, List<NBA_CustomCasePath_CC.Stage>.class);
		List<NBA_CustomCasePath_CC.Stage> stagesRetorno = new List<NBA_CustomCasePath_CC.Stage> ();
		List<NBA_PathMetadata__mdt> stagesMeta = [SELECT id, Type__c, Subreason__c, Reason__c, Actions__c FROM NBA_PathMetadata__mdt];
		List<NBA_PathMetadata__mdt> stagesMetaFinal = new List<NBA_PathMetadata__mdt> ();

		NBA_CustomCasePath_CC.Stage stageSondagem = new NBA_CustomCasePath_CC.Stage();
		stageSondagem.checked = true;
		stageSondagem.current = false;
		stageSondagem.label = 'Sondagem';
		stagesRetorno.add(stageSondagem);

		for (NBA_PathMetadata__mdt stageMeta : stagesMeta)
			if (caseRecord.CallReason__c == stageMeta.Reason__c && (caseRecord.Subreason__c == stageMeta.Subreason__c || 
			   (String.isBlank(caseRecord.Subreason__c) && String.isBlank(stageMeta.Subreason__c))) && 
			   caseRecord.RecordType.DeveloperName == stageMeta.Type__c)
				stagesMetaFinal.add(stageMeta);
				
		if (!stagesMetaFinal.isEmpty()) {
			List<String> stagesMetaString = stagesMetaFinal[0].Actions__c.split('#');
			
			Boolean primeiro = true;
			for (String stageMetaString : stagesMetaString) {
				for (NBA_CustomCasePath_CC.Stage stagePicklist : stagesPicklist) {
					if (stageMetaString == stagePicklist.label) {
						if (primeiro) {
							primeiro = false;
							stagePicklist.current = true;
						}
						stagesRetorno.add(stagePicklist);
					}
				}
			}

			NBA_CustomCasePath_CC.Stage stageFim = new NBA_CustomCasePath_CC.Stage();
			stageFim.checked = false;
			stageFim.current = false;
			stageFim.label = 'Encerramento do atendimento';
			stagesRetorno.add(stageFim);
		}

		return stagesRetorno;
	}

	@AuraEnabled
	public static List<NBA_CustomCasePath_CC.Stage> updateStageCase(String valor, Id caseId, String stages) {
		try {
			Case updateCase = new Case();
			updateCase.Id = caseId;
			updateCase.Time_of_Service__c = valor;

			updateCase.CallResultIndt__c = 'Com Ação';

			update updateCase;
		}
		catch(Exception e) {
			System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
		return consultarStagesPosSondagem(caseId, stages, valor);
	}

	@AuraEnabled(cacheable = false)
	public static List<NBA_CustomCasePath_CC.Stage> consultarStagesPosSondagem(Id caseId, String stagesString, String atual) {
		List<NBA_CustomCasePath_CC.Stage> stages = (List<NBA_CustomCasePath_CC.Stage>) JSON.deserialize(stagesString, List<NBA_CustomCasePath_CC.Stage>.class);
		List<NBA_CustomCasePath_CC.Stage> stagesRetorno = new List<NBA_CustomCasePath_CC.Stage> ();
		List<Case> lstCase = [SELECT Id, Time_of_Service__c FROM Case WHERE Id = :caseId];

		if (!lstCase.isEmpty()) {
			Case caso = lstCase[0];
			Boolean currentStage = false;
			for (NBA_CustomCasePath_CC.Stage stage : stages) {
				NBA_CustomCasePath_CC.Stage stageRetorno = new NBA_CustomCasePath_CC.Stage();
				stageRetorno.label = stage.label;
				if (!currentStage && caso.Time_of_Service__c == stage.label) {
					currentStage = true;
					stageRetorno.current = true;
				}
				stageRetorno.checked = !currentStage;
				stagesRetorno.add(stageRetorno);
			}
		}
		
		return stagesRetorno;
	}
	
	public class Stage {
		@AuraEnabled public String label;
		@AuraEnabled public Boolean checked;
		@AuraEnabled public Boolean current;
	}
	
	// Métodos para o componente "NBA_CallRegistration"

	@AuraEnabled
	public static Boolean isPerfilRentabilizacaoAtiva(){
		Boolean perfilRentabilizacaoAtiva = false;
		if(![SELECT Id FROM Profile WHERE Name = 'Atendente NBA - Rentabilizacao Ativo' AND Id = :UserInfo.getProfileId()].isEmpty())
			return true;
		else
			return false;
	} 

	@AuraEnabled
	public static Boolean isPerfilRetencao(){
		Boolean perfilRentencao = false;
		if(![SELECT Id FROM Profile WHERE Name = 'Atendente NBA - Retencao' AND Id = :UserInfo.getProfileId()].isEmpty())
			return true;
		else
			return false;
	} 
   
	@AuraEnabled
	public static String toRecuperaContractId(String recordId){
		List<Case> lstCase = [SELECT Id, order__r.Id, contractnumber__c, Status FROM CASE WHERE ID =: recordId];
		Map<ID, RecordType> mapRtdType = new Map<ID, RecordType>([SELECT Description,DeveloperName,Id,Name FROM RecordType]);
		String idContrato;
		
		if(!lstCase.isEmpty()){
			idContrato	= lstCase[0].contractnumber__c;
			if(!Test.isRunningTest() && lstCase.get(0).Status != 'Encerrado') {
				NBA_CustomRPA.sendProvisionamento( lstCase[0].order__r.Id );
                lstCase.get(0).Status = 'Encerrado';
                update lstCase.get(0);
			}
		} 
		else
			throw new NBA_OfferComparator_CC.DadosInvalidosException('Não encontrado nada.');
        
		return idContrato;
	}

	@AuraEnabled
	public static Case getCaseDetails (id recordId){
		Case result = null;
		if(recordId != null && String.isNotBlank(recordId)){
			List<Case> lstCase = [
				SELECT 	Id, CallParameterIndt__c, TotalCancellation__c, Order__c, Status,  TVN2Result__c, BLN2Result__c, PhoneN2Result__c, MobileN2Result__c, ALaCarteN2Result__c, Order__r.MobileMovement__c, Order__r.VirtuaMovement__c, Order__r.TVMovement__c, Order__r.NETFoneMovement__c, Order__r.ALaCarteMoviment__c,ContractNumber__r.Segmentation__c
				FROM 	Case 
				WHERE 	Id= :recordId
			];
				result = lstCase[0];
		}
		return result;
	}


	// Métodos para o componente "NBA_SearchAccContract"
	
    @AuraEnabled
	public static String toRecuperaIdContrato(String numberContract, String codeCity) {
		String idContrato;
		List<Contract> lstContract = [SELECT id FROM Contract WHERE vlocity_cmt__ContractReferenceNumber__c = :numberContract AND CityCode__c = :codeCity];

		if (!lstContract.isEmpty())
			idContrato = lstContract[0].id;
		else
			throw new NBA_OfferComparator_CC.DadosInvalidosException('Não encontrado nada.');

        return idContrato;
	}
	
}