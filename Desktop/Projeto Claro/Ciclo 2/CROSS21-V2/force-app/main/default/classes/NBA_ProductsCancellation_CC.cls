public with sharing class NBA_ProductsCancellation_CC {

	private static final Id recordTypeIdFixo				= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECFixo').getRecordTypeId();
	private static final Id recordTypeIdInternetFixa		= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetFixa').getRecordTypeId();
	private static final Id recordTypeIdMovel				= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId();
	private static final Id recordTypeIdInternetMovel		= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetMovel').getRecordTypeId();
	private static final Id recordTypeIdMovelPreControle	= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();
	private static final Id recordTypeIdTv					= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECTV').getRecordTypeId();
	private static final Id recordTypeIdNBAOffer			= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();

	@AuraEnabled
    public static void saveClickCancelation(String recordId){
        update new Case(Id=recordId, CallResultIndt__c = 'Com Ação');
	}

    @AuraEnabled
    public static void updateStage(id recordId){
        List<Case> casos = [
			SELECT 	Id, Time_of_Service__c, Exceptions__c,
					TVN1Result__c, TVN2Result__c, TVN3Result__c,
					PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c,
					MobileN1Result__c, MobileN2Result__c, MobileN3Result__c,
					BLN1Result__c, BLN2Result__c, BLN3Result__c,
					ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c
			FROM	Case
			WHERE 	id =:recordId
		];

		if(!casos.isEmpty()){
			Case caso = casos[0];

			caso.TVN1Result__c       = null;
			caso.TVN2Result__c       = null;
			caso.TVN3Result__c       = null;
			caso.PhoneN1Result__c    = null;
			caso.PhoneN2Result__c    = null;
			caso.PhoneN3Result__c    = null;
			caso.MobileN1Result__c   = null;
			caso.MobileN2Result__c   = null;
			caso.MobileN3Result__c   = null;
			caso.BLN1Result__c       = null;
			caso.BLN2Result__c       = null;
			caso.BLN3Result__c       = null;
			caso.ALaCarteN1Result__c = null;
			caso.ALaCarteN2Result__c = null;
			caso.ALaCarteN3Result__c = null;

			caso.Exceptions__c 		 = null;
			caso.CallResultIndt__c = 'Com Ação';
			caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;

			update caso;
		}
    }

	@AuraEnabled
	public static void endCaseCancelation (id recordId , String atual, date dateSchedule, String descriptionSchedule, Boolean keepMobile){
		List<Case> lstCase							= [SELECT id, contractNumber__r.AccountId, CaseNumber, contractNumber__r.ContractNumber__c, Order__c FROM CASE where id =:recordId];
		NBA_OfferComparator_CC.Offer produtoAtual	= (NBA_OfferComparator_CC.Offer)JSON.deserialize(atual, NBA_OfferComparator_CC.Offer.class );
		Decimal multaTotal							= 0;
		Boolean hasFidelity							= false;
		Map<String, String> mapPenality				= new Map<String, String>();

        System.debug('Diego Silva --> PRODUTO ATUAL ' + atual);

		if(!lstCase.isEmpty()){
			Case c						= lstCase[0];
			Order pedido				= new Order();

			c.CallResultIndt__c = 'Com Ação';
			if (c.Order__c != null) {
				pedido.Id = c.Order__c;
				//Limpando eventuais solics anteriores, antes de criar novas
				delete [SELECT Id FROM Solic_NBA__c WHERE Order__c = :pedido.Id AND Status__c IN (null, :NBA_Constants.EM_ABERTO)];
			}

			pedido.RTDMOfferId__c		= produtoAtual.key;
            pedido.SASOfferProfile__c	= produtoAtual.offerProfile;
            pedido.AddFeeTotal__c		= produtoAtual.vlMembershipFee == null ? 0 : Decimal.valueOf(produtoAtual.vlMembershipFee);
            pedido.UpgradeTaxTotal__c	= produtoAtual.vlUpgradeFee == null? 0 : Decimal.valueOf(produtoAtual.vlUpgradeFee);
            pedido.CurrentValueTotal__c = produtoAtual.totalValue;
            pedido.MobileMovement__c	= getProductMovement(produtoAtual.mobile.planMobile);
            pedido.VirtuaMovement__c	= getProductMovement(produtoAtual.broadband.planBroadband);
            pedido.TVMovement__c		= getProductMovement(produtoAtual.tv[0].planTv);
            pedido.NETFoneMovement__c	= getProductMovement(produtoAtual.phone.planPhone);
			pedido.ALaCarteMoviment__c	= NBA_Constants.MOVIMENTO_CANCELAMENTO;
            pedido.AccountId			= c.contractNumber__r.AccountId;
            pedido.EffectiveDate		= Date.today();
            pedido.ContractId			= c.ContractNumber__c;
            pedido.Status				= 'Draft';
			pedido.RecordTypeId			= recordTypeIdNBAOffer;
			pedido.SchedulingTime__c    = descriptionSchedule != null ? descriptionSchedule : '';
			pedido.OrderCase__c         = c.Id;

			if (dateSchedule != null) {
				pedido.SchedulingDate__c = dateSchedule;
			}

			upsert pedido;
			c.Order__c = pedido.Id;

			List<Asset> lstAsset				= new List<Asset>();
			List<Solic_NBA__c> listSolicInsert  = new List<Solic_NBA__c>();

			List<Solic_NBA__c> solicsTemp = new List<Solic_NBA__c>();
			if(produtoAtual.tv[0].planTv != null && produtoAtual.tv[0].planTv.label != NBA_Constants.NAO_POSSUI){
				Solic_NBA__c solic			= new Solic_NBA__c();
				solic.CurrentProduct__c		= produtoAtual.tv[0].planTv.label;
				solic.ProductType__c		= NBA_Constants.TV_PACOTE;
				solic.Fidelity__c			= produtoAtual.tv[0].planTv.fidelity.hasFidelity;
				solic.PenaltyPrice__c		= produtoAtual.tv[0].planTv.fidelity.penalty;
                multaTotal					+= produtoAtual.tv[0].planTv.fidelity.penalty;

				if(solic.PenaltyPrice__c > 0){
					mapPenality.put( NBA_Constants.TV_PACOTE, String.valueOf(solic.PenaltyPrice__c.setScale(2)) );
				}else {
					mapPenality.put( NBA_Constants.TV_PACOTE, '0.00' );
				}

				if (!hasFidelity && solic.Fidelity__c){
					 hasFidelity = true;
				}
				solicsTemp.add( solic );
            }

			//A LA CARTE TV
			for(NBA_OfferComparator_CC.Additional add : produtoAtual.tv[0].addOptions.lstAdditionals){
				if(add.checked){
					Solic_NBA__c solic			= new Solic_NBA__c();
					solic.CurrentProduct__c		= add.label;
					solic.ProductType__c		= NBA_Constants.TV_A_LA_CARTE;
					solicsTemp.add( solic );
				}
			}

            //PONTO OPCIONAL TV
            if(produtoAtual.tv[0].addOptions.firstPoint.checked){
                Solic_NBA__c solic		= new Solic_NBA__c();
                solic.CurrentProduct__c = produtoAtual.tv[0].planTv.label;
                solic.ProductType__c	= NBA_Constants.TV_PONTOS_ADICIONAIS;
                solicsTemp.add(solic);
            }

            if(produtoAtual.tv[0].addOptions.secondPoint.checked){
                Solic_NBA__c solic			= new Solic_NBA__c();
                solic.CurrentProduct__c		= produtoAtual.tv[0].planTv.label;
                solic.ProductType__c		= NBA_Constants.TV_PONTOS_ADICIONAIS;
                solicsTemp.add(solic);
            }

            if(produtoAtual.tv[0].addOptions.thirdPoint.checked){
                Solic_NBA__c solic		= new Solic_NBA__c();
                solic.CurrentProduct__c = produtoAtual.tv[0].planTv.label;
                solic.ProductType__c	= NBA_Constants.TV_PONTOS_ADICIONAIS;
                solicsTemp.add(solic);
            }

            if(produtoAtual.tv[0].addOptions.fourthPoint.checked){
                Solic_NBA__c solic		= new Solic_NBA__c();
                solic.CurrentProduct__c = produtoAtual.tv[0].planTv.label;
                solic.ProductType__c	= NBA_Constants.TV_PONTOS_ADICIONAIS;
                solicsTemp.add(solic);
            }


			if(produtoAtual.broadband.planBroadband != null && produtoAtual.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI){
				Solic_NBA__c solic			= new Solic_NBA__c();
				solic.CurrentProduct__c		= produtoAtual.broadband.planBroadband.label;
				solic.ProductType__c		= NBA_Constants.BL_ASSINATURA;
				solic.Fidelity__c			= produtoAtual.broadband.planBroadband.fidelity.hasFidelity;
				solic.PenaltyPrice__c		= produtoAtual.broadband.planBroadband.fidelity.penalty;
				multaTotal					+= produtoAtual.broadband.planBroadband.fidelity.penalty;

				if (!hasFidelity && solic.Fidelity__c){
					 hasFidelity = true;
				}
				if(solic.PenaltyPrice__c > 0 )
					mapPenality.put( NBA_Constants.BL_ASSINATURA, String.valueOf(solic.PenaltyPrice__c.setScale(2)) );
				else
					mapPenality.put( NBA_Constants.BL_ASSINATURA, '0.00' );

				solicsTemp.add( solic );

                for (NBA_OfferComparator_CC.Additional oldAdd : produtoAtual.broadband.addOptions.lstAdditionals) {
                    if (oldAdd.checked) {
                        solic					= new Solic_NBA__c();
                        solic.CurrentProduct__c = oldAdd.label;
                        solic.ProductType__c	= NBA_Constants.BL_ADICIONAIS;
                        solicsTemp.add(solic);
                    }
				}
            }

			if(produtoAtual.phone.planPhone != null && produtoAtual.phone.planPhone.label != NBA_Constants.NAO_POSSUI){
				Solic_NBA__c solic			= new Solic_NBA__c();
				solic.CurrentProduct__c		= produtoAtual.phone.planPhone.label;
				solic.ProductType__c		= NBA_Constants.NET_FONE;
				solic.Fidelity__c			= produtoAtual.phone.planPhone.fidelity.hasFidelity;
				solic.PenaltyPrice__c		= produtoAtual.phone.planPhone.fidelity.penalty;
                multaTotal					+= produtoAtual.phone.planPhone.fidelity.penalty;

				if (!hasFidelity && solic.Fidelity__c){
					 hasFidelity = true;
				}

				if(solic.PenaltyPrice__c > 0)
					mapPenality.put( NBA_Constants.NET_FONE, String.valueOf(solic.PenaltyPrice__c.setScale(2)) );
				else
					mapPenality.put( NBA_Constants.NET_FONE, '0.00' );

				solicsTemp.add( solic );
            }

			if(!solicsTemp.isEmpty()){
				Solic_NBA__c solic		= new Solic_NBA__c();

				if(produtoAtual.tv[0].planTv.label != NBA_Constants.NAO_POSSUI){
					solic.CurrentProduct__c = String.isNotBlank(produtoAtual.tv[0].planTv.nameLegacy) ? produtoAtual.tv[0].planTv.nameLegacy : produtoAtual.tv[0].planTv.label;
				}else{
					solic.CurrentProduct__c = produtoAtual.tv[0].planTv.nameLegacy;
				}

				Map<String, String> mapProdAtual = new Map<String, String>();
				for(Solic_NBA__c s : solicsTemp){
					if(String.isNotBlank(s.ProductType__c) && s.ProductType__c != NBA_Constants.TV_PONTOS_ADICIONAIS && s.ProductType__c != NBA_Constants.TV_A_LA_CARTE){
						mapProdAtual.put( s.ProductType__c , s.CurrentProduct__c);
					}
				}

				String tipo			= '';
				String penality		= '';
				String prodAtual	= '';

				if(mapProdAtual.containsKey(NBA_Constants.TV_PACOTE)){
					for(String key : mapProdAtual.keySet()){
						if(String.isBlank(prodAtual)){
							prodAtual = mapProdAtual.get( key );
						}else {
							prodAtual += ' | ' + mapProdAtual.get( key );
						}
					}
				}else {
					prodAtual = produtoAtual.tv[0].planTv.typeAcessoVirtua;
					for(String key : mapProdAtual.keySet()){
						prodAtual += ' | ' + mapProdAtual.get( key );
					}
				}

				tipo = NBA_Constants.TV_PACOTE;
				for(String key : mapProdAtual.keySet()){
					if(key != NBA_Constants.TV_PACOTE)
						tipo += ' | ' + key;
				}

				List<String> listTipoString = tipo.replace('|', ';').split(';');

				for(String key : listTipoString){
					if(String.isBlank(penality)){
						penality	= mapPenality.containsKey( key.trim() ) ? mapPenality.get( key.trim() ) : '0.00';
					}else if(mapPenality.containsKey(key.trim())){
						String p	= mapPenality.containsKey( key.trim() ) ? mapPenality.get( key.trim() ) : '0.00';
						penality   += ' | ' + p;
					}
					System.debug('KEY ' + key.trim());
				}

				solic.Status__c			= 'Em aberto';
				solic.Order__c			= pedido.Id;
				solic.Movement__c		= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solic.PenaltyPrice__c	= multaTotal;
				solic.SpotType__c		= NBA_Constants.SPOT_TYPE_SOLIC_PP;
				solic.ProductName__c	= 'CANCELAMENTO TOTAL - ' + c.contractNumber__r.ContractNumber__c;
				solic.FullCancel__c		= true;
				solic.Fidelity__c		= hasFidelity;
				solic.ProductType__c	= tipo;
				solic.Penality_Price__c = penality;
				solic.CurrentProduct__c	= prodAtual;
				solic.Value__c			= 0.00;
				solic.CurrentValue__c	= produtoAtual.totalValue;
				if(produtoAtual.mobile.planMobile!=null && produtoAtual.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI){
					solic.CurrentValue__c -= produtoAtual.mobile.planMobile.value;
					if(produtoAtual.mobile.dependentslMobile!=null && produtoAtual.mobile.dependentslMobile.value!=null)
						solic.CurrentValue__c -= produtoAtual.mobile.dependentslMobile.value;
				}
				solic.TechnologyType__c	= produtoAtual.tv[0].technology;
				listSolicInsert.add( solic );
			}

			// movel (produtoAtual = obj posse)
			if (produtoAtual.mobile.planMobile != null && produtoAtual.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && !keepMobile) {
				listSolicInsert = NBA_ControllerMovel.getInstance().getMovelCancelamento(produtoAtual, produtoAtual, pedido, listSolicInsert);
				listSolicInsert = NBA_ControllerMovel.getInstance().getDependenteMovelCancelamento(null, produtoAtual, null, pedido, listSolicInsert);
			}

			Map<String, String> mapProductType = new Map<String, String>();
			for(Solic_NBA__c s : solicsTemp){
				if(s.ProductType__c != null && String.isNotBlank(s.ProductType__c)){
					if(s.ProductType__c == NBA_Constants.TV_PACOTE)
						mapProductType.put('PTV', 'PTV');
					if(s.ProductType__c == NBA_Constants.BL_ASSINATURA) //s.ProductType__c == NBA_Constants.ACESSO_VIRTUA ||
						mapProductType.put('VIRTUA', 'VIRTUA');
					if(s.ProductType__c == NBA_Constants.NET_FONE)
						mapProductType.put('FONE', 'FONE');
					if(s.ProductType__c == NBA_Constants.MOVEL_ASSINATURA)
						mapProductType.put('MOVEL', 'MOVEL');
				}
			}

			String comboProfile = 'PTV';
			for(String key : mapProductType.keySet()){
				if(key != 'PTV')
					comboProfile += ' + ' +  mapProductType.get( key );
			}

			pedido.OwnershipProfile__c = null;
			update pedido;

			insert listSolicInsert;
			update c;
		}
	}

	@AuraEnabled
	public static NBA_ProductsCancellation_CC.AgendamentoResponse consultarAgendamento(Id recordId, String ofertaId, String cityCode,  String produtoAntigo) {

		NBA_ProductsCancellation_CC.AgendamentoResponse result = new NBA_ProductsCancellation_CC.AgendamentoResponse();
		NBA_OfferComparator_CC.Offer posse = (NBA_OfferComparator_CC.Offer) JSON.deserialize(produtoAntigo ,NBA_OfferComparator_CC.Offer.class);
		IdProduto idproduto = (IdProduto) JSON.deserialize(ofertaId, IdProduto.class);
		String productId = '';

		Try {
			List<Case> lstCase = [SELECT Id,
			                      ContractNumber__r.ContractNumber__c,
								  CallReason__c
			                      FROM Case
			                      WHERE Id = :recordId];

			if (!lstCase.isEmpty()) {
				List<Agendamento__mdt> lstAgendamento = [SELECT id, COD_BASE__c, DESCRICAO_OS__c, DESCRICAO_SOLIC__c, ID_TIPO_OS__c, ID_TIPO_SOLIC__c FROM Agendamento__mdt ];
				integer cod = 0;
				Boolean inadiplente = lstCase[0].CallReason__c == 'Inadimplente' ? true: false;
				if(!lstAgendamento.isEmpty()){
					integer codTv = NBA_SelectOffer_CC.getCodeAgendamentoCancelamentoTotal('TV', posse.baseId, lstAgendamento, inadiplente);
					integer codBL = NBA_SelectOffer_CC.getCodeAgendamentoCancelamentoTotal('BL', posse.baseId, lstAgendamento, inadiplente);
					integer codFN = NBA_SelectOffer_CC.getCodeAgendamentoCancelamentoTotal('FN', posse.baseId, lstAgendamento, inadiplente);
				System.debug('code tv '+ codTv );
				System.debug('code bl '+ codBL);
				System.debug('code fn '+  codFN);
				if(codTv != null && codTv != 0){
					cod = codTv;
					productId = idproduto.idTvPosse;
				}else if(codBL != null && codBL != 0){
					cod = codBL;
					productId = idproduto.idBlPosse;
				}else if(codFN != null && codFN != 0){
					cod = codFN;
					productId = idproduto.idFnPosse;
				}
				}

				Case caso = lstCase[0];

				if (String.isNotBlank(caso.ContractNumber__r.ContractNumber__c)) {

					NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Agendamento');

					Map<String, Object> request = new Map<String, Object> ();
					//request.put('cityId', NBA_Constants.CITYID); //Codigo de MInas Gerais
					request.put('cityId', cityCode );
					request.put('isFieldOrder', true);
					request.put('contractNumber', caso.ContractNumber__r.ContractNumber__c);
					request.put('action', NBA_Constants.ACTION_SCHEDULE);
					request.put('entityTypeId', NBA_Constants.ENTITYTYPEID);
					request.put('fieldOrderTypeId', cod );
					//	request.put('productId', ofertaId);
					request.put('productId', productId);
					request.put('startDate', Date.today().addDays(2));
					request.put('numberDays', String.valueOf(configuracao.NBA_NumeroOfertas__c));

					NBA_IntegrationModels.AgendamentoResponse response = NBA_IntegrationServices.getAgendamento(request);

					if (response.data == null) {
						response.data = new NBA_IntegrationModels.AgendamentoData();
					}

					if(response.error != null && response.error.httpCode != '200') {
						throw new DadosInvalidosException('Error ' + response.error.httpCode);
					}else{
						result = toGetAgendamento(response);
					}

					//Criar um método para tratar o response
					result = toGetAgendamento(response);

				} else {
					throw new DadosInvalidosException('Valores de Número do Contrato está vazio!');
				}
			}
		} catch(Exception e) {
			System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}

		return result;
	}

	private static NBA_ProductsCancellation_CC.AgendamentoResponse toGetAgendamento(NBA_IntegrationModels.AgendamentoResponse response) {

		NBA_ProductsCancellation_CC.AgendamentoResponse result = new NBA_ProductsCancellation_CC.AgendamentoResponse();
		Map<String, NBA_ProductsCancellation_CC.AgendamentoSchedule> mapAgendamentos = new Map<String, NBA_ProductsCancellation_CC.AgendamentoSchedule> ();

		if (response != null && response.data != null && response.data.schedule != null && !response.data.schedule.isEmpty()) {
			for (NBA_IntegrationModels.AgendamentoSchedule agdm : response.data.schedule) {

				if (agdm.periods != null && !agdm.periods.isEmpty()) {
					for (NBA_IntegrationModels.AgendamentoPeriods periodAgdm : agdm.periods) {

						NBA_ProductsCancellation_CC.AgendamentoSchedule scdle = new NBA_ProductsCancellation_CC.AgendamentoSchedule();
						if (!mapAgendamentos.containsKey(String.valueOf(periodAgdm.dateSchedule))) {
							scdle.classSchedule = agdm.classSchedule;
							scdle.fieldSchedule = agdm.fieldSchedule;
							scdle.requiredMinutes = agdm.requiredMinutes;
							scdle.dateSchedule = periodAgdm.dateSchedule;
							mapAgendamentos.put(String.valueOf(periodAgdm.dateSchedule), scdle);
						}

						scdle = mapAgendamentos.get(String.valueOf(periodAgdm.dateSchedule));

						NBA_ProductsCancellation_CC.AgendamentoPeriods period = new NBA_ProductsCancellation_CC.AgendamentoPeriods();
						period.availableMinutes = periodAgdm.availableMinutes;
						period.description = periodAgdm.startHour + ' - ' + periodAgdm.endHour;
						period.emergency = periodAgdm.emergency;
						period.endHour = periodAgdm.endHour;
						period.isCapacityRegistration = periodAgdm.isCapacityRegistration;
						period.periodTypeId = periodAgdm.periodTypeId;
						period.startHour = periodAgdm.startHour;

						scdle.periods.add(period);
						scdle.periods.sort();
					}

				}
				result.data.schedule.addAll(mapAgendamentos.values());
			}
		}

		return result;
	}

	public static Date getDayInWeek(){
		Date dtResult;
		Boolean run = true;
		Integer day = 2;

		while( run ){
			Datetime myDate		= System.now().addDays( day );
			String dayOfWeek	= myDate.format('EEEE');

			if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday'){
				dtResult = Date.newInstance(myDate.year(), myDate.month(), myDate.day());
				break;
				run = false;
			}else {
				day += 1;
			}
		}
		return dtResult;
	}

	private static String getProductMovement(NBA_OfferComparator_CC.Product produtoAtual) {
		if (produtoAtual != null && produtoAtual.label == NBA_Constants.NAO_POSSUI) {
			return NBA_Constants.MOVIMENTO_NENHUMA;
		}

		return NBA_Constants.MOVIMENTO_CANCELAMENTO;
	}

	public class DadosInvalidosException extends Exception { }

	/////////////////////////////////////////////////////////////////////
	/////	   InnerClass de Agendamento de Visita do cliente	    /////
	/////////////////////////////////////////////////////////////////////

	//Objeto de negócio contendo os dados retornados pela API caso existam.
	public class AgendamentoResponse {
		@AuraEnabled public AgendamentoData data = new AgendamentoData();
	}

	public class AgendamentoData {
		@AuraEnabled public List<AgendamentoSchedule> schedule = new List<AgendamentoSchedule> ();
	}

	public class AgendamentoSchedule {
		@AuraEnabled public String fieldSchedule = ''; //Lembrar de usar o Replace - Agenda de área.
		@AuraEnabled public String classSchedule = ''; //Lembrar de usar o Replace - Agenda classe.
		@AuraEnabled public String requiredMinutes = ''; //minutos requeridos.
		@AuraEnabled public List<AgendamentoPeriods> periods = new List<AgendamentoPeriods> ();
		@AuraEnabled public Date dateSchedule = Date.today(); //Lembrar de usar o Replace - Data disponível do serviço técnico.
	}

	public class AgendamentoPeriods implements Comparable {
		@AuraEnabled public String description = ''; //Descrição do periodo de agendamento.
		@AuraEnabled public String availableMinutes = ''; //Minutos disponíveis.
		@AuraEnabled public String startHour = ''; //Hora de início.
		@AuraEnabled public String endHour = ''; //Hora de término.
		//@AuraEnabled public Date dateSchedule = Date.today(); //Lembrar de usar o Replace - Data disponível do serviço técnico.
		@AuraEnabled public String periodTypeId = ''; //Identificador tipo período.
		@AuraEnabled public String emergency = ''; //Serviço Emergencial.
		@AuraEnabled public String isCapacityRegistration = ''; //Se cadastrada a capacidade técnica
		@AuraEnabled public Boolean cheked = false; // usar no radio buttom no component

		public Integer compareTo(Object compareTo) {
			AgendamentoPeriods compareToOppy = (AgendamentoPeriods) compareTo;
			return description.compareTo(compareToOppy.description);
		}
	}

	public class IdProduto{

		public String idTvPosse = '';
		public String idBlPosse = '';
		public String idFnPosse = '';

	}
}