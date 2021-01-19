/*----------------------------------------------------------
  EMPRESA   - Accenture
  DESCRICÃO - classe responsável pelo controle do produto MOVEL ASSINATURA || MOVEL DEPENDENTE
  Autor     - Diego Silva
  Versão    - 1.0
  ------------------------------------------------------------*/
  public class NBA_ControllerMovel  {

	public static NBA_ControllerMovel instance;

	public static NBA_ControllerMovel getInstance(){
		if(instance == null){
			instance = new NBA_ControllerMovel();
		}
		return instance;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo MOVEL ASSINATURA, Oriundas da Oferta selecionada
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getMovelOfertaSelecionada(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Integer indexMV = String.isNotBlank(ofertaSelecionada.mobile.solicitationType) ? (ofertaSelecionada.mobile.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
		String slType	= String.isNotBlank(ofertaSelecionada.mobile.solicitationType) ? ofertaSelecionada.mobile.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexMV] : null;

		Boolean acquisition			= ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_AQUISICAO;
		Boolean downgrade			= ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_DOWNGRADE;
		Boolean upgrade 			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE;
        Boolean upgradeOrDowngrade	= ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_UPGRADE || downgrade;
		Boolean keep				= ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_MANTIDO || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_MANTER || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_LATERAL;
				
		//TAXA UPGRADE/DOWNGRADE
		NBA_OfferComparator_CC.Fee offerFee = ofertaSelecionada.lstUpgradeFee.size() > 0 ? ofertaSelecionada.lstUpgradeFee[0] : null;
		Decimal feePrice					= offerFee != null ? offerFee.value : null;
		String feeLabel						= offerFee != null ? offerFee.label : null;
        String feeType 						= '';
                
        if(feePrice != null && feePrice > 0 && !ofertaSelecionada.paymentMethodUpgrade.equalsIgnoreCase('isento') && upgrade){
            feeType = 'Upgrade';   
        }else if(feePrice != null && feePrice > 0 && !ofertaSelecionada.paymentMethodUpgrade.equalsIgnoreCase('isento') && acquisition){
            feeType = 'Adesao';   
        }else {
            feeType = ofertaSelecionada.movimentMobile;
        }
                
		//TAXA DE ADESÃO
		NBA_OfferComparator_CC.Fee offerFeeAdesao	= ofertaSelecionada.lstMembershipFee.size() > 0 && !keep && !upgradeOrDowngrade ? ofertaSelecionada.lstMembershipFee[0] : null;
		Decimal feePriceAdesao						= offerFeeAdesao != null ? offerFeeAdesao.value : null;
		String feeLabelAdesao						= offerFeeAdesao != null ? offerFeeAdesao.label : null;
        String feeTypeAdesao 						= '';
                
		if(feePriceAdesao != null && feePriceAdesao > 0 && !ofertaSelecionada.paymentMethodMembership.equalsIgnoreCase('isento')){
            feeTypeAdesao = 'Adesao';   
        }else {
            feeTypeAdesao = ofertaSelecionada.movimentTv; 
        }

		String productName;
		String productLegacyName;
		String currentProductName;

		if ((upgradeOrDowngrade || keep) && String.isNotBlank(slType)) {
			productName			= ofertaSelecionada.mobile.planMobile.label;
			productLegacyName	= ofertaSelecionada.mobile.planMobile.nameLegacy;
			currentProductName	= produtoAntigo.mobile.planMobile.label;
		} else if (acquisition) {
			productName			= ofertaSelecionada.mobile.planMobile.label;
			productLegacyName	= ofertaSelecionada.mobile.planMobile.nameLegacy;
		} else if (keep && String.isBlank(slType)) {
			productName			= produtoAntigo.mobile.planMobile.nameLegacy;
			productLegacyName	= produtoAntigo.mobile.planMobile.label;
			currentProductName	= produtoAntigo.mobile.planMobile.label;
		}

		Solic_NBA__c solicMobile;

		if(ofertaSelecionada.movimentMobile != NBA_Constants.MOVIMENTO_LATERAL){//MOVIMENTO DE AQUISIÇÃO/DOWNGRADE/UPGRADE				
			if(ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_AQUISICAO){ //AQUISIÇÃO
				solicMobile							= new Solic_NBA__c();
				solicMobile.Order__c				= pedido.Id;
				//Alexandre API de retorno
				//solicMobile.Response_SelectOffer__c = String.valueOf(JSON.serialize(ofertaSelecionada));
				//solicMobile.Response_CurrentProduct__c = String.valueOf(JSON.serialize(produtoAntigo));
				//
				solicMobile.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
				solicMobile.Portability__c			= ofertaSelecionada.mobile.titularMobile.origem != null && ofertaSelecionada.mobile.titularMobile.origem.equalsIgnoreCase('Portabilidade') ? true : false;
				solicMobile.MSISDN__c				= ofertaSelecionada.mobile.titularMobile.origem != null && ofertaSelecionada.mobile.titularMobile.origem.equalsIgnoreCase('Portabilidade') ? ofertaSelecionada.mobile.titularMobile.numeroTelefone : null;
				solicMobile.CurrentValue__c			= 0.00;
				solicMobile.ProductName__c			= ofertaSelecionada.mobile.planMobile.nameLegacy;
				solicMobile.MobileName__c           = ofertaSelecionada.mobile.planMobile.label;
				solicMobile.LegacyNameProduct__c	= ofertaSelecionada.mobile.netsalesProductName;
				solicMobile.TotalValue__c			= ofertaSelecionada.mobile.planMobile.value;
				solicMobile.PromotionValue__c		= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount : 0.00; 
				solicMobile.Value__c				= ofertaSelecionada.mobile.planMobile.value;
				solicMobile.ProductType__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
				solicMobile.PromotionName__c		= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).label : '';
				solicMobile.ComboProfile__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
				solicMobile.Family__c				= ofertaSelecionada.mobile.familyName;
				solicMobile.Status__c				= null;
				solicMobile.Status__c				= NBA_Constants.EM_ABERTO;
				solicMobile.Fidelity__c				= false;
				solicMobile.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
				solicMobile.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
				solicMobile.NumberDep__c	        = produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
				solicMobile.QuantityPromoMonths__c	= ofertaSelecionada.mobile.validFor; 
				solicMobile.PromotionValue__c		= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount : 0; 
				solicMobile.TotalValue__c			= ofertaSelecionada.mobile.totalValue;
				solicMobile.RenewFidelity__c		= ofertaSelecionada.mobile.planMobile.fidelity.hasFidelity;
				solicMobile.MobilePlan__c			= ofertaSelecionada.mobile.technology != NBA_Constants.CONTROLE && String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.POS_PAGO : String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.CONTROLE : '';
			}
			else if(ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_DOWNGRADE || ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_UPGRADE) { //MOVIMENTO DOWNGRADE/UPGRADE
				solicMobile							= new Solic_NBA__c();
				solicMobile.Order__c				= pedido.Id;
				//Alexandre API de retorno
				//solicMobile.Response_SelectOffer__c = String.valueOf(JSON.serialize(ofertaSelecionada));
				//solicMobile.Response_CurrentProduct__c = String.valueOf(JSON.serialize(produtoAntigo));
				//
				solicMobile.IsComboMulti__c			= produtoAntigo.mobile.isComboMulti;
				solicMobile.Movement__c				= ofertaSelecionada.movimentMobile;
				solicMobile.Fidelity__c				= produtoAntigo.mobile.planMobile.fidelity.hasFidelity;
				solicMobile.CurrentPlan__c			= produtoAntigo.mobile.productDetail != NBA_Constants.CONTROLE && String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.POS_PAGO : String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.CONTROLE : '';
				solicMobile.MobilePlan__c			= ofertaSelecionada.mobile.technology != NBA_Constants.CONTROLE && String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.POS_PAGO : String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.CONTROLE : '';
				solicMobile.DataPlan__c				= ofertaSelecionada.mobile.speed;
				solicMobile.MobileName__c			= ofertaSelecionada.mobile.planMobile.nameLegacy;
				solicMobile.PromotionName__c		= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).label : '';
				solicMobile.MSISDN__c				= produtoAntigo.mobile.msisdn;
				solicMobile.ProductName__c			= ofertaSelecionada.mobile.planMobile.label;
				solicMobile.LegacyNameProduct__c	= ofertaSelecionada.mobile.netsalesProductName;
				solicMobile.CurrentValue__c			= produtoAntigo.mobile.planMobile.value;
				solicMobile.CurrentProduct__c		= produtoAntigo.mobile.planMobile.nameLegacy;
				solicMobile.ComboProfile__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
				solicMobile.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
				solicMobile.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
				solicMobile.Status__c				= null;
				solicMobile.Status__c				= NBA_Constants.EM_ABERTO;
				solicMobile.ProductType__c			= NBA_Constants.MOVEL_ASSINATURA_RPA; 
				solicMobile.Family__c				= ofertaSelecionada.mobile.familyName;
				solicMobile.TotalValue__c			= ofertaSelecionada.mobile.planMobile.value != null ? ofertaSelecionada.mobile.planMobile.value : 0.00;
				solicMobile.NumberDep__c	        = produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
				solicMobile.QuantityPromoMonths__c	= ofertaSelecionada.mobile.validFor; 
				solicMobile.PromotionValue__c		= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount : 0; 
				solicMobile.Value__c				= solicMobile.TotalValue__c - solicMobile.PromotionValue__c;
				solicMobile.TotalValue__c			= ofertaSelecionada.mobile.totalValue;
				solicMobile.RenewFidelity__c		= ofertaSelecionada.mobile.planMobile.fidelity.hasFidelity;
				solicMobile.pointId__c				= produtoAntigo.mobile.planMobile.pointId;
			}
		}
		else if(ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_LATERAL && ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER){//LATERAL SEM MOVIMENTACAO
			solicMobile								= new Solic_NBA__c();
			solicMobile.Order__c					= pedido.Id;
			//Alexandre API de retorno
			//solicMobile.Response_SelectOffer__c = String.valueOf(JSON.serialize(ofertaSelecionada));
			//solicMobile.Response_CurrentProduct__c = String.valueOf(JSON.serialize(produtoAntigo));
			//
			solicMobile.IsComboMulti__c				= produtoAntigo.mobile.isComboMulti;
			solicMobile.Movement__c					= NBA_Constants.MOVIMENTO_LATERAL;
			solicMobile.Fidelity__c					= produtoAntigo.mobile.planMobile.fidelity.hasFidelity;
			solicMobile.CurrentPlan__c				= produtoAntigo.mobile.productDetail != NBA_Constants.CONTROLE && String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.POS_PAGO : String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.CONTROLE : '';
			solicMobile.MobilePlan__c				= ofertaSelecionada.mobile.technology != NBA_Constants.CONTROLE && String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.POS_PAGO : String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.CONTROLE : '';
			solicMobile.PromotionName__c			= produtoAntigo.mobile.promotionName;
			solicMobile.MSISDN__c					= produtoAntigo.mobile.msisdn;
			solicMobile.ProductName__c				= produtoAntigo.mobile.planMobile.label;
			solicMobile.LegacyNameProduct__c		= produtoAntigo.mobile.planMobile.nameLegacy;
			solicMobile.Value__c					= ofertaSelecionada.mobile.planMobile.value;
			solicMobile.CurrentValue__c				= produtoAntigo.mobile.planMobile.value;
			solicMobile.CurrentProduct__c			= produtoAntigo.mobile.planMobile.nameLegacy;
			solicMobile.Discount__c 			    = ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
			solicMobile.Bonus__c 				    = ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
			solicMobile.Status__c					= null;
			solicMobile.ProductType__c				= NBA_Constants.MOVEL_ASSINATURA_RPA;
			solicMobile.ComboProfile__c				= NBA_Constants.MOVEL_ASSINATURA_RPA;
			solicMobile.Family__c					= ofertaSelecionada.mobile.familyName;
			solicMobile.NumberDep__c				= produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
			solicMobile.QuantityPromoMonths__c		= ofertaSelecionada.mobile.validFor;
			solicMobile.PromotionValue__c			= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount : 0; 
			solicMobile.TotalValue__c				= ofertaSelecionada.mobile.totalValue;
		}
		else if(ofertaSelecionada.movimentMobile == NBA_Constants.MOVIMENTO_LATERAL && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.MOVIMENTO_MANTER){//LATERAL COM MOVIMENTACAO
			solicMobile								= new Solic_NBA__c();
			solicMobile.Order__c					= pedido.Id;
			//Alexandre API de retorno
			//solicMobile.Response_SelectOffer__c = String.valueOf(JSON.serialize(ofertaSelecionada));
			//solicMobile.Response_CurrentProduct__c = String.valueOf(JSON.serialize(produtoAntigo));
			//
			solicMobile.IsComboMulti__c				= produtoAntigo.mobile.isComboMulti;
			solicMobile.Movement__c					= ofertaSelecionada.movimentMobile;
			solicMobile.Fidelity__c					= produtoAntigo.mobile.planMobile.fidelity.hasFidelity;
			solicMobile.CurrentPlan__c				= produtoAntigo.mobile.productDetail != NBA_Constants.CONTROLE && String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.POS_PAGO : String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.CONTROLE : '';
			solicMobile.MobilePlan__c				= ofertaSelecionada.mobile.technology != NBA_Constants.CONTROLE && String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.POS_PAGO : String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.CONTROLE : '';
			solicMobile.QuantityPromoMonths__c		= ofertaSelecionada.mobile.validFor;
			solicMobile.DataPlan__c					= ofertaSelecionada.mobile.speed;
			solicMobile.MobileName__c				= ofertaSelecionada.mobile.planMobile.nameLegacy;
			solicMobile.PromotionName__c			= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).label : '';
			solicMobile.MSISDN__c					= produtoAntigo.mobile.msisdn;
			solicMobile.ProductName__c				= produtoAntigo.mobile.planMobile.label;
			solicMobile.LegacyNameProduct__c		= ofertaSelecionada.mobile.netsalesProductName;
			solicMobile.CurrentValue__c				= produtoAntigo.mobile.planMobile.value;
			solicMobile.CurrentProduct__c			= produtoAntigo.mobile.planMobile.nameLegacy;
			solicMobile.ComboProfile__c				= NBA_Constants.MOVEL_ASSINATURA_RPA;
			solicMobile.Status__c					= null;
			solicMobile.Status__c					= NBA_Constants.EM_ABERTO;
			solicMobile.ProductType__c				= NBA_Constants.MOVEL_ASSINATURA_RPA; 
			solicMobile.Family__c					= ofertaSelecionada.mobile.familyName;
			solicMobile.Discount__c 				= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
			solicMobile.Bonus__c 					= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
			solicMobile.TotalValue__c				= ofertaSelecionada.mobile.planMobile.value != null ? ofertaSelecionada.mobile.planMobile.value : 0.00;
			solicMobile.PromotionValue__c			= !ofertaSelecionada.mobile.planMobile.lstPromotions.isEmpty() ? ofertaSelecionada.mobile.planMobile.lstPromotions.get(0).discount : 0.00; 
			solicMobile.Value__c					= solicMobile.TotalValue__c - solicMobile.PromotionValue__c;
			solicMobile.NumberDep__c				= produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
			solicMobile.RenewFidelity__c			= ofertaSelecionada.mobile.planMobile.fidelity.hasFidelity;
			solicMobile.pointId__c					= produtoAntigo.mobile.planMobile.pointId;
		}


		//agregado Informativo + solicitation type
		if(String.isNotBlank(ofertaSelecionada.AgregadoInformativo.nomeDaMae) && String.isNotBlank(ofertaSelecionada.AgregadoInformativo.rg) && 
		   String.isNotBlank(ofertaSelecionada.AgregadoInformativo.dataEmissaoDoRG) && String.isNotBlank(ofertaSelecionada.AgregadoInformativo.orgaoEmissorRG) && 
		   String.isNotBlank(ofertaSelecionada.AgregadoInformativo.dataeNascimentodoTitular)){
			
			solicMobile.MothersName__c			= ofertaSelecionada.AgregadoInformativo.nomeDaMae != null ? ofertaSelecionada.AgregadoInformativo.nomeDaMae : '';
			solicMobile.RG__c					= ofertaSelecionada.AgregadoInformativo.rg != null ? ofertaSelecionada.AgregadoInformativo.rg : '';
			solicMobile.RGDate__c				= String.isNotBlank(ofertaSelecionada.AgregadoInformativo.dataEmissaoDoRG) ? Date.valueOf(ofertaSelecionada.AgregadoInformativo.dataEmissaoDoRG) : null;
			solicMobile.RGEmitter__c			= ofertaSelecionada.AgregadoInformativo.orgaoEmissorRG != null ? ofertaSelecionada.AgregadoInformativo.orgaoEmissorRG : '';
			solicMobile.BirthDate__c			= String.isNotBlank(ofertaSelecionada.AgregadoInformativo.dataeNascimentodoTitular) ? Date.valueOf(ofertaSelecionada.AgregadoInformativo.dataeNascimentodoTitular) : null;
			
			solicMobile.SolicitationType__c = 'AQUISIÇÃO DE AGREGADO INFORMATIVO';
		}
		else{
			solicMobile.SolicitationType__c = ofertaSelecionada.mobile.solicitationType;
		}

		lstSolicInsert.add( solicMobile );


		//MOVEL A LA CARTE
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacarteMV = new Map<String, NBA_OfferComparator_CC.Additional>();
		for(NBA_OfferComparator_CC.Additional oldOffer : ofertaSelecionada.mobile.addOptions.lstAdditionals) {
			if(oldOffer.checked){
				mapAlacarteMV.put(oldOffer.label, oldOffer);
			}
		}

		for(NBA_OfferComparator_CC.Additional add : ofertaSelecionada.mobile.addOptions.lstAdditionals) {
			if(add.checked && !mapAlacarteMV.containsKey(add.nameLegacy)) {
				Integer indexMVAdd = String.isNotBlank(add.solicitationType) ? (add.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
				String slTypeMvAdd = String.isNotBlank(add.solicitationType) ? add.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexMVAdd] : null;

				Solic_NBA__c SolicAlaCarteMV			= new Solic_NBA__c();
				SolicAlaCarteMV.ProductName__c			= add.label;
				SolicAlaCarteMV.LegacyNameProduct__c   	= String.isNotBlank(add.nameLegacy) ? add.nameLegacy : add.label;
				SolicAlaCarteMV.Message__c				= '';
				SolicAlaCarteMV.Order__c				= pedido.Id;
				SolicAlaCarteMV.Status__c				= NBA_Constants.EM_ABERTO;
				SolicAlaCarteMV.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
				SolicAlaCarteMV.ProductType__c			= NBA_Constants.MOVEL_ADICIONAIS;
				SolicAlaCarteMV.OfferType__c			= ofertaSelecionada.mobile.offerType;
				SolicAlaCarteMV.ComboProfile__c			= ofertaSelecionada.mobile.comboProfile;
				SolicAlaCarteMV.Family__c				= add.familyName;
				SolicAlaCarteMV.QuantityPromoMonths__c  = ofertaSelecionada.mobile.additionalMobile.lstPromotions.size() > 0 ? String.valueOf(ofertaSelecionada.mobile.additionalMobile.lstPromotions[0].valid) : '';
				SolicAlaCarteMV.SolicitationType__c		= slTypeMvAdd;
				SolicAlaCarteMV.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				SolicAlaCarteMV.CurrentValue__c			= 0.00;
				SolicAlaCarteMV.Value__c				= add.value;
				SolicAlaCarteMV.pointId__c				= keep && String.isBlank(slType) ? produtoAntigo.mobile.planMobile.pointId : null;
				
				if(String.isNotBlank(add.description)) {
					SolicAlaCarteMV.PromotionName__c    = add.description;
				}else {
					SolicAlaCarteMV.PromotionName__c    = String.isNotBlank(add.promoSelected) ? add.lstPromotions[Integer.valueOf(add.promoSelected)].description : null;
				}

				lstSolicInsert.add( SolicAlaCarteMV );
			}else if(add.checked && !mapAlacarteMV.containsKey(add.nameLegacy)){
				Solic_NBA__c SolicAlaCarteMV			= new Solic_NBA__c();
				SolicAlaCarteMV.ProductName__c			= add.nameLegacy;
				SolicAlaCarteMV.LegacyNameProduct__c	= String.isNotBlank(add.nameLegacy) ? add.nameLegacy : add.label;
				SolicAlaCarteMV.Message__c				= '';
				SolicAlaCarteMV.Order__c				= pedido.Id;
				SolicAlaCarteMV.Status__c				= null;
				SolicAlaCarteMV.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
				SolicAlaCarteMV.ProductType__c			= NBA_Constants.MOVEL_ADICIONAIS;
				SolicAlaCarteMV.OfferType__c			= ofertaSelecionada.mobile.offerType;
				SolicAlaCarteMV.ComboProfile__c			= ofertaSelecionada.mobile.comboProfile;
				SolicAlaCarteMV.Family__c				= add.familyName;
				SolicAlaCarteMV.QuantityPromoMonths__c  = ofertaSelecionada.mobile.additionalMobile.lstPromotions.size() > 0 ? String.valueOf(ofertaSelecionada.mobile.additionalMobile.lstPromotions[0].valid) : '';
				SolicAlaCarteMV.SolicitationType__c		= null;
				SolicAlaCarteMV.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				SolicAlaCarteMV.CurrentValue__c			= mapAlacarteMV.get(add.nameLegacy).value;
				SolicAlaCarteMV.Value__c				= add.value;
				
				if(String.isNotBlank(add.description)){
					SolicAlaCarteMV.PromotionName__c    = add.description;
				}else {
					SolicAlaCarteMV.PromotionName__c    = String.isNotBlank(add.promoSelected) ? add.lstPromotions[Integer.valueOf(add.promoSelected)].description : null;
				}

				lstSolicInsert.add( SolicAlaCarteMV );
			}
		}
		return lstSolicInsert;
	}
	
	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo MOVEL ASSINATURA, Oriundas da Posse Atual ou Produto Atual
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getMovelProdutoAtual(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Solic_NBA__c solicMobile			= new Solic_NBA__c();
		solicMobile.Order__c				= pedido.Id;
		solicMobile.IsComboMulti__c			= produtoAntigo.mobile.isComboMulti;
		solicMobile.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
		solicMobile.Fidelity__c				= produtoAntigo.mobile.planMobile.fidelity.hasFidelity;
		solicMobile.CurrentPlan__c			= produtoAntigo.mobile.productDetail != NBA_Constants.CONTROLE && String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.POS_PAGO : String.isNotBlank( produtoAntigo.mobile.productDetail ) ? NBA_Constants.CONTROLE : '';
		solicMobile.MobilePlan__c			= ofertaSelecionada.mobile.technology != NBA_Constants.CONTROLE && String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.POS_PAGO : String.isNotBlank( ofertaSelecionada.mobile.technology ) ? NBA_Constants.CONTROLE : '';
		solicMobile.PromotionName__c		= produtoAntigo.mobile.promotionName;
		solicMobile.MSISDN__c				= produtoAntigo.mobile.msisdn;
		solicMobile.ProductName__c			= produtoAntigo.mobile.planMobile.label;
		solicMobile.LegacyNameProduct__c	= produtoAntigo.mobile.planMobile.nameLegacy;
		solicMobile.Value__c				= ofertaSelecionada.mobile.planMobile.value;
		solicMobile.CurrentValue__c			= produtoAntigo.mobile.planMobile.value;
		solicMobile.CurrentProduct__c		= produtoAntigo.mobile.planMobile.nameLegacy;
		solicMobile.Status__c				= null;
		solicMobile.Discount__c 			= produtoAntigo.mobile.descontTitularRPA;
		solicMobile.Bonus__c 				= produtoAntigo.mobile.bonusTitularRPA;
		solicMobile.ProductType__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
		solicMobile.ComboProfile__c			= NBA_Constants.MOVEL_ASSINATURA_RPA;
		solicMobile.Family__c				= ofertaSelecionada.mobile.familyName;
		solicMobile.SolicitationType__c		= null;
		solicMobile.NumberDep__c	        = produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
		lstSolicInsert.add( solicMobile );
		
		for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.mobile.AddOptions.lstAdditionals) {
			if(alacarte.checked) {
				Integer indexMVAdd							= String.isNotBlank(alacarte.solicitationType) ? (alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
				String slTypeMvAdd							= String.isNotBlank(alacarte.solicitationType) ? alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexMVAdd] : null;

				Solic_NBA__c solicAlacarteMovel				= new Solic_NBA__c();
				solicAlacarteMovel.ProductName__c			= alacarte.label;
				solicAlacarteMovel.LegacyNameProduct__c		= String.isNotBlank(alacarte.nameLegacy) ? alacarte.nameLegacy : alacarte.label;
				solicAlacarteMovel.Message__c				= '';
				solicAlacarteMovel.Order__c					= pedido.Id;
				solicAlacarteMovel.Status__c				= NBA_Constants.EM_ABERTO;
				solicAlacarteMovel.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
				solicAlacarteMovel.ProductType__c			= NBA_Constants.MOVEL_ADICIONAIS;
				solicAlacarteMovel.OfferType__c				= ofertaSelecionada.mobile.offerType;
				solicAlacarteMovel.ComboProfile__c			= ofertaSelecionada.mobile.comboProfile;
				solicAlacarteMovel.Family__c				= alacarte.familyName;
				solicAlacarteMovel.SolicitationType__c		= slTypeMvAdd;
				solicAlacarteMovel.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicAlacarteMovel.CurrentValue__c			= 0.00;
				solicAlacarteMovel.Value__c					= alacarte.value;
				solicAlacarteMovel.pointId__c				= produtoAntigo.mobile.planMobile.pointId;

				if(String.isNotBlank(alacarte.description)) {
					solicAlacarteMovel.PromotionName__c    = alacarte.description;
				}else{
					solicAlacarteMovel.PromotionName__c    = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}

				lstSolicInsert.add( solicAlacarteMovel );
			}
		}
		return lstSolicInsert;
	}

	 /*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo MOVEL ASSINATURA E MOVEL ADICIONAIS com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	  public List<Solic_NBA__c> getMovelCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		//CANCELAMENTO DO PRODUTO MOVEL ASSINATURA
		//CANCELAMENTO EM CASCATA DE MOVEL ADICIONAIS
		Solic_NBA__c solicMovel			= new Solic_NBA__c();
		solicMovel.Order__c				= pedido.Id;
		//Alexandre API de retorno
		//solicMovel.Response_SelectOffer__c = String.valueOf(JSON.serialize(ofertaSelecionada));
		//solicMovel.Response_CurrentProduct__c = String.valueOf(JSON.serialize(produtoAntigo));
		//
		solicMovel.IsComboMulti__c		= produtoAntigo.mobile.isComboMulti;
		solicMovel.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
		solicMovel.Fidelity__c			= produtoAntigo.mobile.planMobile.fidelity.hasFidelity;
		solicMovel.MSISDN__c			= produtoAntigo.mobile.msisdn;
		solicMovel.CurrentProduct__c	= produtoAntigo.mobile.planMobile.nameLegacy;
		solicMovel.CurrentValue__c		= produtoAntigo.mobile.planMobile.value;
		solicMovel.ProductType__c		= NBA_Constants.MOVEL_ASSINATURA_RPA;
		solicMovel.Value__c				= 0.00;
		solicMovel.PromotionName__c		= produtoAntigo.mobile.promotionName;

		if(produtoAntigo.mobile.productDetail == NBA_Constants.CONTROLE){
			solicMovel.CurrentPlan__c = NBA_Constants.CONTROLE;
		}else{
			solicMovel.CurrentPlan__c = 'POS-PAGO';
		}

		solicMovel.Status__c			= NBA_Constants.EM_ABERTO;
		solicMovel.SpotType__c			= null;
		solicMovel.PenaltyPrice__c		= null;
		solicMovel.ComboProfile__c		= NBA_Constants.MOVEL_ASSINATURA_RPA;
		solicMovel.RG__c				= '';
		solicMovel.RGDate__c			= null;
		solicMovel.RGEmitter__c			= '';
		solicMovel.NumberDep__c			= produtoAntigo.mobile.listaDependentesMobile != null ? produtoAntigo.mobile.listaDependentesMobile.size() : 0;
		lstSolicInsert.add( solicMovel );

		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.mobile.addOptions.lstAdditionals) {
			if (alacarte.checked) {
				Solic_NBA__c solicAlacarteMovel			= new Solic_NBA__c();
				solicAlacarteMovel.CurrentProduct__c	= alacarte.label;
				solicAlacarteMovel.Order__c				= pedido.Id;
				solicAlacarteMovel.Status__c			= NBA_Constants.EM_ABERTO;
				solicAlacarteMovel.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicAlacarteMovel.ProductType__c		= NBA_Constants.MOVEL_ADICIONAIS;
				solicAlacarteMovel.OfferType__c			= produtoAntigo.mobile.offerType;
				solicAlacarteMovel.TechnologyType__c	= produtoAntigo.mobile.technology;
				solicAlacarteMovel.ComboProfile__c		= null;
				solicAlacarteMovel.SolicitationType__c	= produtoAntigo.mobile.solicitationType;
				solicAlacarteMovel.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicAlacarteMovel.Message__c			= '';
				solicAlacarteMovel.Value__c				= 0.00;
				solicAlacarteMovel.CurrentValue__c		= produtoAntigo.mobile.planMobile.value;
				solicAlacarteMovel.MainPoint__c			= ofertaSelecionada.mobile.planMobile.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.mobile.planMobile.nameLegacy : produtoAntigo.mobile.planMobile.label;

				if(String.isNotBlank(alacarte.description)) {
					solicAlacarteMovel.PromotionName__c  = alacarte.description;
				}else{
					solicAlacarteMovel.PromotionName__c  = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}
				lstSolicInsert.add( solicAlacarteMovel );
			}
		}
		return lstSolicInsert;
	}

	 /*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo MOVEL ADICIONAIS com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	  public List<Solic_NBA__c> getMovelAdicionalCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		//CANCELAMENTO DO PRODUTO MOVEL ASSINATURA
		//CANCELAMENTO EM CASCATA DE MOVEL ADICIONAIS
		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.mobile.addOptions.lstAdditionals) {
			if (alacarte.checked) {
				Solic_NBA__c solicAlacarteMovel			= new Solic_NBA__c();
				solicAlacarteMovel.CurrentProduct__c	= alacarte.label;
				solicAlacarteMovel.Order__c				= pedido.Id;
				solicAlacarteMovel.Status__c			= NBA_Constants.EM_ABERTO;
				solicAlacarteMovel.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicAlacarteMovel.ProductType__c		= NBA_Constants.MOVEL_ADICIONAIS;
				solicAlacarteMovel.OfferType__c			= produtoAntigo.mobile.offerType;
				solicAlacarteMovel.TechnologyType__c	= produtoAntigo.mobile.technology;
				solicAlacarteMovel.ComboProfile__c		= null;
				solicAlacarteMovel.SolicitationType__c	= produtoAntigo.mobile.solicitationType;
				solicAlacarteMovel.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicAlacarteMovel.Message__c			= '';
				solicAlacarteMovel.Value__c				= 0.00;
				solicAlacarteMovel.CurrentValue__c		= produtoAntigo.mobile.planMobile.value;
				solicAlacarteMovel.MainPoint__c			= ofertaSelecionada.mobile.planMobile.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.mobile.planMobile.nameLegacy : produtoAntigo.mobile.planMobile.label;

				if(String.isNotBlank(alacarte.description)) {
					solicAlacarteMovel.PromotionName__c  = alacarte.description;
				}else{
					solicAlacarteMovel.PromotionName__c  = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}
				lstSolicInsert.add( solicAlacarteMovel );
			}
		}
		return lstSolicInsert;
	}

	 /*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo MOVEL DEP com movimentação AQUISIÇÃO
	  -------------------------------------------------------------------------------------------------------*/
	  public List<Solic_NBA__c> getDependenteMovel(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, NBA_OfferComparator_CC.Offer posseAtual, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		if((ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && String.isNotBlank(ofertaSelecionada.movimentMobile))){
			
			//INCLUSÃO DE DEPENDENTE
			for(NBA_OfferComparator_CC.Dependentes dep : ofertaSelecionada.mobile.listaDependentesMobileSelected){
				if(dep.origem != null && dep.origem.equalsIgnoreCase('Novo')){
					Solic_NBA__c solic				= new Solic_NBA__c();
					solic.Order__c					= pedido.Id;
					solic.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
					solic.CurrentValue__c			= 0.00;
					solic.ProductName__c		    = dep.catalogName;
					solic.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
					solic.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
					solic.LegacyNameProduct__c		= dep.nameLegacy;
					solic.ProductType__c		    = NBA_Constants.MOVEL_DEPENDENTES;
					solic.Value__c					= dep.valorProduto;
					solic.Portability__c		    = false;
					solic.PromotionName__c			= dep.promotionName;
					solic.MainPoint__c				= ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER ? produtoAntigo.mobile.titularMobile.productName : ofertaSelecionada.mobile.name;
					solic.SolicitationType__c		= NBA_Constants.SOLICITATION_TYPE_DEP;
					solic.Status__c					= NBA_Constants.EM_ABERTO;

					if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS_PAGO')){
						solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
					}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('BANDA_LARGA')){
						solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
					}else {
						solic.DependentProfile__c	= dep.nomePlano; 
					}

					lstSolicInsert.add( solic );
				}else if(dep.origem != null && dep.origem.equalsIgnoreCase('Portabilidade')){
					Solic_NBA__c solic				= new Solic_NBA__c();
					solic.Order__c					= pedido.Id;
					solic.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
					solic.CurrentValue__c			= 0.00;
					solic.ProductName__c		    = dep.catalogName;
					solic.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
					solic.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
					solic.LegacyNameProduct__c		= dep.nameLegacy;
					solic.ProductType__c		    = NBA_Constants.MOVEL_DEPENDENTES;
					solic.Value__c					= dep.valorProduto;
					solic.Portability__c		    = true;
					solic.PromotionName__c			= dep.promotionName;
					solic.MainPoint__c				= ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER ? produtoAntigo.mobile.titularMobile.productName : ofertaSelecionada.mobile.name;
					solic.SolicitationType__c		= NBA_Constants.SOLICITATION_TYPE_DEP;
					solic.MSISDN__c					= dep.numeroTelefone;
					solic.Status__c					= NBA_Constants.EM_ABERTO;

					if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS_PAGO')){
						solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
					}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('BANDA_LARGA')){
						solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
					}else {
						solic.DependentProfile__c	= dep.nomePlano; 
					}

					lstSolicInsert.add( solic );
				}
			}

			if(ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER) {
				for(NBA_OfferComparator_CC.Dependentes dep : posseAtual.mobile.listaDependentesMobile){
					//SOLIC DEP MOVIMENTO LATERAL
					if(dep.checked){
						Solic_NBA__c solic				= new Solic_NBA__c();
						solic.Order__c					= pedido.Id;
						solic.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
						solic.CurrentProduct__c			= dep.productName;
						solic.LegacyNameProduct__c		= dep.productName;
						solic.ProductName__c		    = dep.catalogName;
						solic.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
						solic.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
						solic.CurrentValue__c			= dep.valorProduto;
						solic.Value__c					= dep.valorProduto;
						solic.MainPoint__c				= produtoAntigo.mobile.titularMobile.productName;
						solic.ProductType__c		    = NBA_Constants.MOVEL_DEPENDENTES;
						solic.Fidelity__c				= dep.fidelity;
						solic.MSISDN__c					= dep.numeroTelefone;
						solic.PromotionName__c			= dep.promotionName;
						solic.Status__c					= null;

						if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS PG')){
							solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
						}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS BL')){
							solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
						}else {
							solic.DependentProfile__c	= dep.nomePlano; 
						}

						lstSolicInsert.add( solic );
					}
				}
			}else if(ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI){
				for(NBA_OfferComparator_CC.Dependentes dep : posseAtual.mobile.listaDependentesMobile){
					if(dep.checked){
						Solic_NBA__c solic				= new Solic_NBA__c();
						solic.Order__c					= pedido.Id;
						solic.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
						solic.CurrentProduct__c			= dep.productName;
						solic.LegacyNameProduct__c		= dep.productName;
						solic.ProductName__c			= dep.catalogName;
						solic.Discount__c 			= ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
						solic.Bonus__c 				= ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
						solic.CurrentValue__c			= dep.valorProduto;
						solic.Value__c					= dep.valorProduto;
						solic.MainPoint__c				= ofertaSelecionada.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER ? produtoAntigo.mobile.titularMobile.productName : ofertaSelecionada.mobile.name;
						solic.ProductType__c			= NBA_Constants.MOVEL_DEPENDENTES;
						solic.Fidelity__c				= dep.fidelity;
						solic.MSISDN__c					= dep.numeroTelefone;
						solic.PromotionName__c			= dep.promotionName;
						solic.Status__c					= null;

						if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS PG')){
							solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
						}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS BL')){
							solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
						}else {
							solic.DependentProfile__c	= dep.nomePlano; 
						}

						lstSolicInsert.add( solic );
					}
				}
			}
		}else if((ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && String.isBlank(ofertaSelecionada.movimentMobile))){
			//MANTERE SEM MOVIMENTAÇÃO - USUARIO MANTEVE O PRODUTO ATUAL
			for(NBA_OfferComparator_CC.Dependentes dep : ofertaSelecionada.mobile.listaDependentesMobile){
				if(dep.checked){
					Solic_NBA__c solic				= new Solic_NBA__c();
					solic.Order__c					= pedido.Id;
					solic.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
					solic.CurrentProduct__c			= dep.productName;
					solic.LegacyNameProduct__c		= dep.productName;
					solic.ProductName__c		    = dep.catalogName;
					solic.Discount__c 			    = ofertaSelecionada.mobile.descontTitularRPA != null ? ofertaSelecionada.mobile.descontTitularRPA : null;
					solic.Bonus__c 				    = ofertaSelecionada.mobile.bonusTitularRPA != null ? ofertaSelecionada.mobile.bonusTitularRPA:null;
					solic.ProductType__c		    = NBA_Constants.MOVEL_DEPENDENTES;
					solic.CurrentValue__c			= dep.valorProduto;
					solic.Value__c					= dep.valorProduto;
					solic.Portability__c		    = false;
					solic.PromotionName__c			= dep.promoSelected;
					solic.MainPoint__c				= produtoAntigo.mobile.planMobile.label;
					solic.SolicitationType__c		= ofertaSelecionada.mobile.solicitationType;
					solic.Fidelity__c				= dep.fidelity;
					solic.MSISDN__c					= dep.numeroTelefone;
					solic.Status__c					= null;

					if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS PG')){
						solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
					}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS BL')){
						solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
					}else {
						solic.DependentProfile__c	= dep.nomePlano; 
					}

					lstSolicInsert.add( solic );
				}
			}
		}
		return lstSolicInsert;
	}

	 /*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo MOVEL DEP com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	  public List<Solic_NBA__c> getDependenteMovelCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, NBA_OfferComparator_CC.Offer posseAtual, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		if(	produtoAntigo.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.mobile.planMobile.label == NBA_Constants.NAO_POSSUI){
			//CANCELAMENTO DE TODOS DEP
			for(NBA_OfferComparator_CC.Dependentes dep : produtoAntigo.mobile.listaDependentesMobile){
				Solic_NBA__c solic				= new Solic_NBA__c();
				solic.Order__c					= pedido.Id;
				solic.Movement__c				= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solic.Value__c					= 0.00;
				solic.CurrentValue__c			= dep.valorProduto;
				solic.CurrentProduct__c			= dep.productName;
				solic.PromotionName__c			= dep.promotionName;
				solic.MSISDN__c					= dep.numeroTelefone;
				solic.Fidelity__c				= dep.fidelity;
				solic.ProductType__c		    = NBA_Constants.MOVEL_DEPENDENTES;
				solic.SolicitationType__c		= NBA_Constants.SOLICITATION_TYPE_DEP;
				solic.MainPoint__c				= produtoAntigo.mobile.planMobile.nameLegacy;
				solic.Status__c					= NBA_Constants.EM_ABERTO;

				if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS PG')){
					solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
				}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS BL')){
					solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
				}else {
					solic.DependentProfile__c	= dep.nomePlano; 
				}
				lstSolicInsert.add( solic );
			}
		}else if( produtoAntigo.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI){
			//CANCELAMENTO DE DEP
			for(NBA_OfferComparator_CC.Dependentes dep : posseAtual.mobile.listaDependentesMobile){
				if(!dep.checked){
					Solic_NBA__c solic			= new Solic_NBA__c();
					solic.Order__c				= pedido.Id;
					solic.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
					solic.Value__c				= 0.00;
					solic.CurrentValue__c		= dep.valorProduto;
					solic.CurrentProduct__c		= dep.productName;
					solic.PromotionName__c		= dep.promotionName;
					solic.MSISDN__c				= dep.numeroTelefone;
					solic.Fidelity__c			= dep.fidelity;
					solic.ProductType__c		= NBA_Constants.MOVEL_DEPENDENTES;
					solic.SolicitationType__c	= NBA_Constants.SOLICITATION_TYPE_DEP;
					solic.MainPoint__c			= produtoAntigo.mobile.planMobile.nameLegacy; 
					solic.Status__c             = NBA_Constants.EM_ABERTO;

					if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS PG')){
						solic.DependentProfile__c	= 'DEPENDENTE VOZ + DADOS SEM DESCONTO';
					}else if(dep.nomePlano != null && dep.nomePlano.equalsIgnoreCase('POS BL')){
						solic.DependentProfile__c	= 'DEPENDENTE DADOS'; 
					}else {
						solic.DependentProfile__c	= dep.nomePlano; 
					}
					lstSolicInsert.add( solic );
				}
			}
		}
		return lstSolicInsert;
	}
}