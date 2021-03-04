public class NBA_AcceptedOffer {

	public static void sendOffer(String caseId){
		if(!Test.isRunningTest()) {
			NBA_IntegrationUtils.HttpResponseModel res = NBA_IntegrationServices.enviarOfertaAceita( caseId );
			System.debug('DIEGO SILVA (API de Retorno) -- [RESPONSE] --->  ' + res);
		}else {
			System.debug('Construindo Mock');
		}
	}

	public static NBA_IntegrationModels.Offer_Accepted createdOffer(String caseId){
		if(caseId != null && String.isNotBlank(caseId) && getCase(caseId) != null){
			
			Case caso				= getCase( caseId );
			Solic_NBA__c solicNBA	= getResponseInSolic( getSolics( caso.Order__c ) );

			NBA_OfferComparator_CC.Offer ofertaSelecionada;
			NBA_OfferComparator_CC.Offer posseAtual;

			if(solicNBA != null){
				if(solicNBA.Response_CurrentProduct__c != null && solicNBA.Response_SelectOffer__c != null) {
					System.debug('Diego Silva -- POSSE ---> ' + solicNBA.Response_CurrentProduct__c);
					System.debug('Diego Silva -- OFERTA ---> ' + solicNBA.Response_SelectOffer__c);
					ofertaSelecionada	= (NBA_OfferComparator_CC.Offer) JSON.deserialize(solicNBA.Response_SelectOffer__c, NBA_OfferComparator_CC.Offer.class);
					posseAtual			= (NBA_OfferComparator_CC.Offer) JSON.deserialize(solicNBA.Response_CurrentProduct__c, NBA_OfferComparator_CC.Offer.class);
				}
			}

			
			NBA_IntegrationModels.Offer_Accepted offer		= new NBA_IntegrationModels.Offer_Accepted();
			if(ofertaSelecionada != null && posseAtual != null){

				offer.caseId									= caso.Id;
				offer.endDate									= String.valueOf(caso.LastModifiedDate);
				offer.origin									= NBA_Constants.ORIGEM_EVENTO;
				offer.acceptedOfferPriority						= ofertaSelecionada.oldPriority;
				offer.totalSpent								= ( ofertaSelecionada.lstSteps != null && ofertaSelecionada.lstSteps.size() > 0 ) ? getTotalSpent( ofertaSelecionada.lstSteps ) : String.valueOf( ofertaSelecionada.totalValue.setScale(2) );
				offer.finalResult								= caso.CallResult__c;
				Offer.results									= getTabulacao( caso );
				Decimal totalAceito								= 0;

				//TV && ADICIONAIS
				if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label != NBA_Constants.MOVIMENTO_MANTER && (ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_AQUISICAO || ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE || ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_DOWNGRADE || ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_LATERAL)){
					offer.tvProduct.Id								= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.key;
					offer.tvProduct.name							= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label;
					offer.tvProduct.catalogName						= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy;
					offer.tvProduct.price							= String.valueOf( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.value );
					offer.tvProduct.hasCinema						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.CINEMA_HD );
					offer.tvProduct.hasMovies						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FILME_SERIE );
					offer.tvProduct.hasFox							= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FOX_PREM_HD );
					offer.tvProduct.hasPtvSoccer					= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FUTEBOL_HD );
					offer.tvProduct.hasHbo							= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.HBO_HD );
					offer.tvProduct.hasTelecine						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.TELECINE_HD );
					offer.tvProduct.hasSeries						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.SERIE_HD );
					offer.tvProduct.additionalPointsAmount			= getQtdOpcionalPonto( ofertaSelecionada );
					offer.tvProduct.additionalPointsPrice			= getSumOpcionalPonto( ofertaSelecionada, posseAtual );
					offer.tvProduct.otherExtras						= getExtras( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.TV_PACOTE ); 
					offer.tvProduct.extrasTotalPrice				= String.valueOf( getSumAdicionalExtra(ofertaSelecionada, posseAtual, NBA_Constants.TV_PACOTE) );
					offer.tvProduct.promotion.id					= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).key : '';
					offer.tvProduct.promotion.duration				= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).valid ) : '';
					offer.tvProduct.promotion.discountValue			= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).discount ) : '';
					totalAceito += ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.value;
				}

				if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label == NBA_Constants.MOVIMENTO_MANTER){
					offer.tvProduct.Id								= posseAtual.tv[0].planTv.key;
					offer.tvProduct.name							= posseAtual.tv[0].planTv.label;
					offer.tvProduct.catalogName						= posseAtual.tv[0].planTv.nameLegacy;
					offer.tvProduct.price							= String.valueOf( posseAtual.tv[0].planTv.value );
					offer.tvProduct.hasCinema						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.CINEMA_HD );
					offer.tvProduct.hasMovies						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FILME_SERIE );
					offer.tvProduct.hasFox							= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FOX_PREM_HD );
					offer.tvProduct.hasPtvSoccer					= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.FUTEBOL_HD );
					offer.tvProduct.hasHbo							= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.HBO_HD );
					offer.tvProduct.hasTelecine						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.TELECINE_HD );
					offer.tvProduct.hasSeries						= getProduct( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.SERIE_HD );
					offer.tvProduct.additionalPointsAmount			= getQtdOpcionalPonto( ofertaSelecionada );
					offer.tvProduct.additionalPointsPrice			= getSumOpcionalPonto( ofertaSelecionada, posseAtual );
					offer.tvProduct.otherExtras						= getExtras( ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals, NBA_Constants.TV_PACOTE ); 
					offer.tvProduct.extrasTotalPrice				= String.valueOf( getSumAdicionalExtra(ofertaSelecionada, posseAtual, NBA_Constants.TV_PACOTE) );
					offer.tvProduct.promotion.id					= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).key : '';
					offer.tvProduct.promotion.duration				= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).valid ) : '';
					offer.tvProduct.promotion.discountValue			= ( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.get(0).discount ) : '';
				}


				//FONE
				if(ofertaSelecionada.phone.planPhone.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.phone.planPhone.label != NBA_Constants.MOVIMENTO_MANTER && (ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_AQUISICAO || ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_UPGRADE || ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_DOWNGRADE || ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_LATERAL)){
					offer.phoneProduct.Id							= ofertaSelecionada.phone.planPhone.key;	
					offer.phoneProduct.name							= ofertaSelecionada.phone.planPhone.label;	
					offer.phoneProduct.catalogName					= ofertaSelecionada.phone.planPhone.nameLegacy;
					offer.phoneProduct.price						= String.valueOf( ofertaSelecionada.phone.planPhone.value );

					offer.phoneProduct.promotion.id					= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? ofertaSelecionada.phone.planPhone.lstPromotions.get(0).key : '';
					offer.phoneProduct.promotion.duration			= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.phone.planPhone.lstPromotions.get(0).valid ) : '';
					offer.phoneProduct.promotion.discountValue		= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.phone.planPhone.lstPromotions.get(0).discount ) : '';	
					totalAceito += ofertaSelecionada.phone.planPhone.value;

				}
				if(ofertaSelecionada.phone.planPhone.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.phone.planPhone.label == NBA_Constants.MOVIMENTO_MANTER){
					offer.phoneProduct.Id							= posseAtual.phone.planPhone.key;	
					offer.phoneProduct.name							= posseAtual.phone.planPhone.label;	
					offer.phoneProduct.catalogName					= posseAtual.phone.planPhone.nameLegacy;
					offer.phoneProduct.price						= String.valueOf( posseAtual.phone.planPhone.value );
					offer.phoneProduct.promotion.id					= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? ofertaSelecionada.phone.planPhone.lstPromotions.get(0).key : '';
					offer.phoneProduct.promotion.duration			= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.phone.planPhone.lstPromotions.get(0).valid ) : '';
					offer.phoneProduct.promotion.discountValue		= ( ofertaSelecionada.phone.planPhone.lstPromotions != null && ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.phone.planPhone.lstPromotions.get(0).discount ) : '';
				}

		
				//BANDA LARGA && ADICIONAIS
				if(ofertaSelecionada.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.broadband.planBroadband.label != NBA_Constants.MOVIMENTO_MANTER && (ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_AQUISICAO || ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_UPGRADE || ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_DOWNGRADE || ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_LATERAL)){
					offer.broadbandProduct.Id						= ofertaSelecionada.broadband.planBroadband.key;	
					offer.broadbandProduct.name						= ofertaSelecionada.broadband.planBroadband.label;	
					offer.broadbandProduct.catalogName				= ofertaSelecionada.broadband.planBroadband.nameLegacy;
					offer.broadbandProduct.price					= String.valueOf( ofertaSelecionada.broadband.planBroadband.value );
					offer.broadbandProduct.extrasTotalPrice			= String.valueOf( getSumAdicionalExtra( ofertaSelecionada, posseAtual, NBA_Constants.BL_ASSINATURA ) );
					offer.phoneProduct.promotion.id					= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).key : '';
					offer.phoneProduct.promotion.duration			= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).valid ) : '';
					offer.phoneProduct.promotion.discountValue		= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).discount ) : '';				
				
					totalAceito += ofertaSelecionada.broadband.planBroadband.value;
					
				}

				if(ofertaSelecionada.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.broadband.planBroadband.label == NBA_Constants.MOVIMENTO_MANTER){
					offer.broadbandProduct.Id						= posseAtual.broadband.planBroadband.key;	
					offer.broadbandProduct.name						= posseAtual.broadband.planBroadband.label;	
					offer.broadbandProduct.catalogName				= posseAtual.broadband.planBroadband.nameLegacy;
					offer.broadbandProduct.price					= String.valueOf( posseAtual.broadband.planBroadband.value );
					offer.broadbandProduct.extrasTotalPrice			= String.valueOf( getSumAdicionalExtra( ofertaSelecionada, posseAtual, NBA_Constants.BL_ASSINATURA ) );
					offer.phoneProduct.promotion.id					= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).key : '';
					offer.phoneProduct.promotion.duration			= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).valid ) : '';
					offer.phoneProduct.promotion.discountValue		= ( ofertaSelecionada.broadband.planBroadband.lstPromotions != null && ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).discount ) : '';				
				}
				
				//MOVEL && ADICIONAIS && DEPENDENTE
				if(ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.MOVIMENTO_MANTER && (ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_AQUISICAO || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_UPGRADE || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_DOWNGRADE || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_LATERAL)){
					offer.mobileProduct.Id							= ofertaSelecionada.mobile.planMobile.key;	
					offer.mobileProduct.name						= ofertaSelecionada.mobile.planMobile.label;	
					offer.mobileProduct.catalogName					= ofertaSelecionada.mobile.planMobile.nameLegacy;
					offer.mobileProduct.price						= String.valueOf( ofertaSelecionada.mobile.planMobile.value );
					offer.mobileProduct.dependentAmount				= null;
					offer.mobileProduct.dependentsPrice				= null;
					offer.mobileProduct.extras						= getExtras( ofertaSelecionada.mobile.addOptions.lstAdditionals, NBA_Constants.MOVEL_ASSINATURA );
					offer.mobileProduct.promotion.id				= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).key : '';
					offer.mobileProduct.promotion.duration			= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).valid ) : '';
					offer.mobileProduct.promotion.discountValue		= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount ) : '';
				
					totalAceito += ofertaSelecionada.mobile.planMobile.value;
				
				}

				if(ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER){
					offer.mobileProduct.Id							= posseAtual.mobile.planMobile.key;	
					offer.mobileProduct.name						= posseAtual.mobile.planMobile.label;	
					offer.mobileProduct.catalogName					= posseAtual.mobile.planMobile.nameLegacy;
					offer.mobileProduct.price						= String.valueOf( posseAtual.mobile.planMobile.value );
					offer.mobileProduct.dependentAmount				= null;
					offer.mobileProduct.dependentsPrice				= null;
					offer.mobileProduct.extras						= getExtras( ofertaSelecionada.mobile.addOptions.lstAdditionals, NBA_Constants.MOVEL_ASSINATURA );
					offer.mobileProduct.promotion.id				= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).key : '';
					offer.mobileProduct.promotion.duration			= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).valid ) : '';
					offer.mobileProduct.promotion.discountValue		= ( ofertaSelecionada.mobile.planMobile.lstPromotions != null && ofertaSelecionada.mobile.planMobile.lstPromotions.size() > 0 ) ? String.valueOf( ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount ) : '';
				}

				totalAceito										   += getSumAdicional(ofertaSelecionada, posseAtual, NBA_Constants.TV_PACOTE);
				totalAceito										   += getSumAdicional(ofertaSelecionada, posseAtual, NBA_Constants.BL_ASSINATURA);
				totalAceito										   += getSumAdicional(ofertaSelecionada, posseAtual, NBA_Constants.MOVEL_ASSINATURA);
				totalAceito										   += Decimal.valueOf( getSumOpcionalPonto( ofertaSelecionada, posseAtual ) );
				offer.acceptedOfferValue							= String.valueOf(totalAceito);
			}
			System.debug('DIEGO SILVA (API de Retorno) -- [REQUEST]  ---> ' + JSON.serialize( offer ));

			return offer;
		}else {
			System.debug('DIEGO SILVA (API de Retorno) -- Case não localizado ---> ' + caseId);
		}
		return null;
	}

	@TestVisible
	private static Case getCase(String caseid){
		List<Case> listCase = [SELECT ALaCarteN1Result__c,ALaCarteN2Result__c,ALaCarteN3Result__c,BLN1Result__c,BLN2Result__c,BLN3Result__c,MobileN1Result__c,MobileN2Result__c,MobileN3Result__c,PhoneN1Result__c,PhoneN2Result__c,PhoneN3Result__c,TVN1Result__c,TVN2Result__c,TVN3Result__c,Order__c,LastModifiedDate,Id,CallResult__c FROM Case WHERE Id = :caseid];
		if(listCase != null && !listCase.isEmpty())
			return listCase.get(0);
		else 
			return null;
	}

	@TestVisible
	private static List<Solic_NBA__c> getSolics(String idOrder){
		List<Solic_NBA__c> listSolic = new List<Solic_NBA__c>();
		for(Solic_NBA__c solic : [SELECT 
											Message__c, Order__c, Asset__c, Status__c, ProductName__c, CurrentProduct__c, Value__c, FeeType__c, FeePrice__c,
											LegacyNameProduct__c, ComboProfile__c, SerialNumber__c, PaymentMethod__c, RenewFidelity__c,
											TechnologyType__c, Movement__c, SolicitationType__c, ProductType__c, PenaltyPrice__c, OfferType__c, Fidelity__c, Response_SelectOffer__c,
											AcceptedOffer__c, Priority__c, Family__c, PromotionName__c, Name, SpotType__c, Penality_Price__c, Id, Response_CurrentProduct__c 
								  FROM Solic_NBA__c WHERE Order__c = :idOrder]){
			listSolic.add( solic );
		}
		return listSolic;
	}

	@TestVisible
	private static String convertDatetimeToDate(Datetime dt){
		Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
		return d.format();
	}

	@TestVisible
	private static Solic_NBA__c getResponseInSolic(List<Solic_NBA__c> listSolic){
		for(Solic_NBA__c solic : listSolic){
			if(solic.Response_SelectOffer__c != null && String.isNotBlank(solic.Response_SelectOffer__c) && solic.Response_CurrentProduct__c != null && String.isNotBlank(solic.Response_CurrentProduct__c) && (solic.Response_CurrentProduct__c.contains('{') || solic.Response_SelectOffer__c.contains('{')))
				return solic;
			break;
		}
		return null;
	}

	@TestVisible
	private static List<String> getExtras(List<NBA_OfferComparator_CC.Additional> listAdicionais, String tipo){
		Map<String, String> mapExtras = new Map<String, String>();
		if(tipo == NBA_Constants.TV_PACOTE){
			for(NBA_OfferComparator_CC.Additional add : listAdicionais){
				if(add.checked && add.label != NBA_Constants.CINEMA_HD && add.label != NBA_Constants.FILME_SERIE && add.label != NBA_Constants.FOX_PREM_HD && add.label != NBA_Constants.FUTEBOL_HD && add.label != NBA_Constants.HBO_HD && add.label != NBA_Constants.TELECINE_HD && add.label != NBA_Constants.SERIE_HD)
					mapExtras.put( add.label, add.label);
			}
		}else if(tipo == NBA_Constants.MOVEL_ASSINATURA){
			for(NBA_OfferComparator_CC.Additional add : listAdicionais){
				if(add.checked)
					mapExtras.put( add.label, add.label );
			}
		}
		return mapExtras.values();
	}

	@TestVisible
	private static Boolean getProduct(List<NBA_OfferComparator_CC.Additional> listAdicionais, String tipo){
		Boolean result = false;
		for(NBA_OfferComparator_CC.Additional add : listAdicionais){
            if(add.checked && add.label.equalsIgnoreCase( tipo )){
                result = true;
                break;
            }
		}
		return result;
	}

	@TestVisible
	private static String getQtdOpcionalPonto(NBA_OfferComparator_CC.Offer oferta){
		Integer total = 0;
		if(oferta.tv[oferta.techSelected].addOptions.firstPoint.checked)
			total++;
		if(oferta.tv[oferta.techSelected].addOptions.secondPoint.checked)
			total++;
		if(oferta.tv[oferta.techSelected].addOptions.thirdPoint.checked)
			total++;
		if(oferta.tv[oferta.techSelected].addOptions.fourthPoint.checked)
			total++;
		return String.valueOf( total );
	}

	@TestVisible
	private static Decimal getSumAdicional(NBA_OfferComparator_CC.Offer oferta, NBA_OfferComparator_CC.Offer posse, String tipo){
		Decimal total = 0;
		if(tipo != null && tipo == NBA_Constants.TV_PACOTE){
			Map<String, NBA_OfferComparator_CC.Additional> mapAddPosse = new Map<String, NBA_OfferComparator_CC.Additional>();
			for(NBA_OfferComparator_CC.Additional add : posse.tv[0].addOptions.lstAdditionals){
				if(add.checked)
					mapAddPosse.put( add.label, add );
			}

			for(NBA_OfferComparator_CC.Additional add : oferta.tv[oferta.techSelected].addOptions.lstAdditionals){
				if(add.checked && !mapAddPosse.containsKey( add.nameLegacy )){
					total += add.value;
				}
			}
		}else if(tipo != null && tipo == NBA_Constants.BL_ASSINATURA){
			Map<String, NBA_OfferComparator_CC.Additional> mapAddPosse = new Map<String, NBA_OfferComparator_CC.Additional>();
			for(NBA_OfferComparator_CC.Additional add : posse.broadband.addOptions.lstAdditionals){
				if(add.checked)
					mapAddPosse.put( add.label, add );
			}

			for(NBA_OfferComparator_CC.Additional add : oferta.broadband.addOptions.lstAdditionals){
				if(add.checked && !mapAddPosse.containsKey( add.nameLegacy )){
					total += add.value;
				}
			}
		}else if(tipo != null && tipo == NBA_Constants.MOVEL_ADICIONAIS){
			Map<String, NBA_OfferComparator_CC.Additional> mapAddPosse = new Map<String, NBA_OfferComparator_CC.Additional>();
			for(NBA_OfferComparator_CC.Additional add : posse.mobile.addOptions.lstAdditionals){
				if(add.checked)
					mapAddPosse.put( add.label, add );
			}

			for(NBA_OfferComparator_CC.Additional add : oferta.mobile.addOptions.lstAdditionals){
				if(add.checked && !mapAddPosse.containsKey( add.nameLegacy )){
					total += add.value;
				}
			}
		}
		return total;
	}

	@TestVisible
	private static Decimal getSumAdicionalExtra(NBA_OfferComparator_CC.Offer oferta, NBA_OfferComparator_CC.Offer posse, String tipo){
		Decimal total = 0;
		if(tipo != null && tipo == NBA_Constants.TV_PACOTE){
			for(NBA_OfferComparator_CC.Additional add : oferta.tv[oferta.techSelected].addOptions.lstAdditionals){
				if(add.checked){
					total += add.value;
				}
			}
		}else if(tipo != null && tipo == NBA_Constants.BL_ASSINATURA){
			for(NBA_OfferComparator_CC.Additional add : oferta.broadband.addOptions.lstAdditionals){
				if(add.checked){
					total += add.value;
				}
			}
		}else if(tipo != null && tipo == NBA_Constants.MOVEL_ADICIONAIS){
			for(NBA_OfferComparator_CC.Additional add : oferta.mobile.addOptions.lstAdditionals){
				if(add.checked){
					total += add.value;
				}
			}
		}
		return total;
	}

	@TestVisible
	private static String getSumOpcionalPonto(NBA_OfferComparator_CC.Offer oferta, NBA_OfferComparator_CC.Offer posse){
		Decimal total = 0;

		//POSSE ATUAL
		Map<String, NBA_OfferComparator_CC.Optional> mapPosse = new Map<String, NBA_OfferComparator_CC.Optional>();
		if(posse.tv[0].addOptions.firstPoint.checked)
			mapPosse.put('firstPoint',posse.tv[0].addOptions.firstPoint);
		if(posse.tv[0].addOptions.secondPoint.checked)
			mapPosse.put('secondPoint',posse.tv[0].addOptions.firstPoint);
		if(posse.tv[0].addOptions.thirdPoint.checked)
			mapPosse.put('thirdPoint',posse.tv[0].addOptions.firstPoint);
		if(posse.tv[0].addOptions.fourthPoint.checked)
			mapPosse.put('fourthPoint',posse.tv[0].addOptions.firstPoint);


		if(oferta.tv[oferta.techSelected].addOptions.firstPoint.checked && mapPosse.containsKey('firstPoint') && oferta.tv[oferta.techSelected].addOptions.firstPoint.value != mapPosse.get('firstPoint').value){
			total += oferta.tv[oferta.techSelected].addOptions.firstPoint.value;
		}else if(oferta.tv[oferta.techSelected].addOptions.firstPoint.checked && !mapPosse.containsKey('firstPoint')) {
			total += oferta.tv[oferta.techSelected].addOptions.firstPoint.value;
		}

		if(oferta.tv[oferta.techSelected].addOptions.secondPoint.checked && mapPosse.containsKey('secondPoint') && oferta.tv[oferta.techSelected].addOptions.firstPoint.value != mapPosse.get('secondPoint').value){
			total += oferta.tv[oferta.techSelected].addOptions.secondPoint.value;
		}else if(oferta.tv[oferta.techSelected].addOptions.secondPoint.checked && !mapPosse.containsKey('secondPoint')) {
			total += oferta.tv[oferta.techSelected].addOptions.secondPoint.value;
		}

		if(oferta.tv[oferta.techSelected].addOptions.thirdPoint.checked && mapPosse.containsKey('thirdPoint') && oferta.tv[oferta.techSelected].addOptions.firstPoint.value != mapPosse.get('thirdPoint').value){
			total += oferta.tv[oferta.techSelected].addOptions.thirdPoint.value;
		}else if(oferta.tv[oferta.techSelected].addOptions.firstPoint.checked && !mapPosse.containsKey('thirdPoint')) {
			total += oferta.tv[oferta.techSelected].addOptions.thirdPoint.value;
		}

		if(oferta.tv[oferta.techSelected].addOptions.fourthPoint.checked && mapPosse.containsKey('fourthPoint') && oferta.tv[oferta.techSelected].addOptions.firstPoint.value != mapPosse.get('fourthPoint').value){
			total += oferta.tv[oferta.techSelected].addOptions.fourthPoint.value;
		}else if(oferta.tv[oferta.techSelected].addOptions.firstPoint.checked && !mapPosse.containsKey('fourthPoint')) {
			total += oferta.tv[oferta.techSelected].addOptions.fourthPoint.value;
		}

		return String.valueOf( total );
	}

	@TestVisible
	private static String getSumAlacarte(List<NBA_OfferComparator_CC.Additional> listAdicionais, String tipo){
		Decimal sumTotal = 0;
		if(tipo == NBA_Constants.TV_A_LA_CARTE){
			for(NBA_OfferComparator_CC.Additional add : listAdicionais){
				if(add.checked)
					sumTotal += add.value;
			}
		}else if(tipo == NBA_Constants.BL_ADICIONAIS){
			for(NBA_OfferComparator_CC.Additional add : listAdicionais){
				if(add.checked)
					sumTotal += add.value;
			}
		}
		return String.valueOf( sumTotal );
	}

	@TestVisible
	private static List<NBA_IntegrationModels.Offer_Result> getTabulacao(Case caso){
		List<NBA_IntegrationModels.Offer_Result> results = new List<NBA_IntegrationModels.Offer_Result>();
		if(caso != null){
			//TV A LA CARTE
			NBA_IntegrationModels.Offer_Result resultAlacarte = new NBA_IntegrationModels.Offer_Result();
			resultAlacarte.level		= 1;
			resultAlacarte.productType	= NBA_Constants.TV_A_LA_CARTE;
			resultAlacarte.result		= caso.ALaCarteN1Result__c;
			results.add( resultAlacarte );

			resultAlacarte				= new NBA_IntegrationModels.Offer_Result();
			resultAlacarte.level		= 2;
			resultAlacarte.productType	= NBA_Constants.TV_A_LA_CARTE;
			resultAlacarte.result		= caso.ALaCarteN2Result__c;
			results.add( resultAlacarte );

			resultAlacarte				= new NBA_IntegrationModels.Offer_Result();
			resultAlacarte.level		= 3;
			resultAlacarte.productType	= NBA_Constants.TV_A_LA_CARTE;
			resultAlacarte.result		= caso.ALaCarteN3Result__c;
			results.add( resultAlacarte );

			//NET FONE
			NBA_IntegrationModels.Offer_Result resultNetFone = new NBA_IntegrationModels.Offer_Result();
			resultNetFone.level			= 1;
			resultNetFone.productType	= NBA_Constants.NET_FONE;
			resultNetFone.result		= caso.PhoneN1Result__c;
			results.add( resultNetFone );

			resultNetFone				= new NBA_IntegrationModels.Offer_Result();
			resultNetFone.level			= 2;
			resultNetFone.productType	= NBA_Constants.NET_FONE;
			resultNetFone.result		= caso.PhoneN2Result__c;
			results.add( resultNetFone );

			resultNetFone				= new NBA_IntegrationModels.Offer_Result();
			resultNetFone.level			= 3;
			resultNetFone.productType	= NBA_Constants.NET_FONE;
			resultNetFone.result		= caso.PhoneN3Result__c;
			results.add( resultNetFone );

			//TV PACOTE
			NBA_IntegrationModels.Offer_Result resultTvPacote = new NBA_IntegrationModels.Offer_Result();
			resultTvPacote.level		= 1;
			resultTvPacote.productType	= NBA_Constants.TV_PACOTE;
			resultTvPacote.result		= caso.TVN1Result__c;
			results.add( resultTvPacote );

			resultTvPacote				= new NBA_IntegrationModels.Offer_Result();
			resultTvPacote.level		= 2;
			resultTvPacote.productType	= NBA_Constants.TV_PACOTE;
			resultTvPacote.result		= caso.TVN2Result__c;
			results.add( resultTvPacote );

			resultTvPacote				= new NBA_IntegrationModels.Offer_Result();
			resultTvPacote.level		= 3;
			resultTvPacote.productType	= NBA_Constants.TV_PACOTE;
			resultTvPacote.result		= caso.TVN3Result__c;
			results.add( resultTvPacote );

			//BL ASSINATURA
			NBA_IntegrationModels.Offer_Result resultBlAssinatura = new NBA_IntegrationModels.Offer_Result();
			resultBlAssinatura.level		= 1;
			resultBlAssinatura.productType	= NBA_Constants.BL_ASSINATURA;
			resultBlAssinatura.result		= caso.BLN1Result__c;
			results.add( resultBlAssinatura );

			resultBlAssinatura				= new NBA_IntegrationModels.Offer_Result();
			resultBlAssinatura.level		= 2;
			resultBlAssinatura.productType	= NBA_Constants.BL_ASSINATURA;
			resultBlAssinatura.result		= caso.BLN2Result__c;
			results.add( resultBlAssinatura );

			resultBlAssinatura				= new NBA_IntegrationModels.Offer_Result();
			resultBlAssinatura.level		= 3;
			resultBlAssinatura.productType	= NBA_Constants.BL_ASSINATURA;
			resultBlAssinatura.result		= caso.BLN3Result__c;
			results.add( resultBlAssinatura );
		}
		return results;
	}

	@TestVisible
	private static String getTotalSpent(List<NBA_OfferComparator_CC.Option> lstOtpion){
		String result = '';
		if(lstOtpion != null && !lstOtpion.isEmpty()){
			if(lstOtpion.size() == 1){
				result = String.valueOf( lstOtpion.get(0).value.setScale(2) ); 
			}else if(lstOtpion.size() == 2){
				result = String.valueOf( lstOtpion.get(1).value.setScale(2) ); 
			}else if(lstOtpion.size() == 3){
				result = String.valueOf( lstOtpion.get(2).value.setScale(2) ); 
			}else if(lstOtpion.size() == 4){
				result = String.valueOf( lstOtpion.get(3).value.setScale(2) ); 
			}else if(lstOtpion.size() == 5){
				result = String.valueOf( lstOtpion.get(4).value.setScale(2) ); 
			}else if(lstOtpion.size() == 6){
				result = String.valueOf( lstOtpion.get(5).value.setScale(2) ); 
			}else if(lstOtpion.size() == 7){
				result = String.valueOf( lstOtpion.get(6).value.setScale(2) ); 
			}else if(lstOtpion.size() == 8){
				result = String.valueOf( lstOtpion.get(7).value.setScale(2) ); 
			}else if(lstOtpion.size() == 9){
				result = String.valueOf( lstOtpion.get(8).value.setScale(2) ); 
			}else if(lstOtpion.size() == 10){
				result = String.valueOf( lstOtpion.get(9).value.setScale(2) ); 
			}
		}
		return result;
	}
}