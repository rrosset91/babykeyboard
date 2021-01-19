/*----------------------------------------------------------
  EMPRESA   - Accenture
  DESCRICÃO - classe responsável pelo controle do produto TV PACOTE 
  Autor     - Diego Silva
  Versão    - 1.0
  ------------------------------------------------------------*/
public class NBA_ControllerTvPacote  {
	
	private static NBA_ControllerTvPacote instance;

	public static NBA_ControllerTvPacote getInstance(){
		if(instance == null)
			instance = new NBA_ControllerTvPacote();
		return instance;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo TV Pacote, Oriundas da Oferta selecionada
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getTvPacoteOfertaSelecionada(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		
		Integer indexTV				= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? (ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size()> 1 ? 1 : 0) : 0;
		String slType				= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTV] : null;

		Boolean acquisition			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_AQUISICAO;
		Boolean downgrade			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_DOWNGRADE;
		Boolean upgrade 			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE;
		Boolean upgradeOrDowngrade	= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE || downgrade;
		Boolean keep				= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_MANTIDO || ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_LATERAL;


		//TAXA PARA MUDANÇA DE PACOTE
		NBA_OfferComparator_CC.Fee offerFee = ofertaSelecionada.lstUpgradeFee.size() > 0 ? ofertaSelecionada.lstUpgradeFee[0] : null;
		Decimal feePrice					= offerFee != null ? offerFee.value : null;
		String feeLabel						= offerFee != null ? offerFee.label : null;
		String feeType 						= '';
                
		if(feePrice != null && feePrice > 0 && !ofertaSelecionada.paymentMethodUpgrade.equalsIgnoreCase('isento') && upgrade){
			feeType							= 'Upgrade';   
		}else if(feePrice != null && feePrice > 0 && !ofertaSelecionada.paymentMethodUpgrade.equalsIgnoreCase('isento') && acquisition){
			feeType							= 'Adesao';   
		}else {
			feeType							= ofertaSelecionada.movimentTv;
		}
                
		//TAXA PARA ADESÃO
		NBA_OfferComparator_CC.Fee offerFeeAdesao	= ofertaSelecionada.lstMembershipFee.size() > 0 && !keep && !upgradeOrDowngrade ? ofertaSelecionada.lstMembershipFee[0] : null;
		Decimal feePriceAdesao						= offerFeeAdesao != null ? offerFeeAdesao.value : null;
		String feeLabelAdesao						= offerFeeAdesao != null ? offerFeeAdesao.label : null;
		String feeTypeAdesao 						= '';
                
		if(feePriceAdesao != null && feePriceAdesao > 0 && !ofertaSelecionada.paymentMethodMembership.equalsIgnoreCase('isento')){
			feeTypeAdesao							= 'Adesao';   
		}else {
			feeTypeAdesao							= ofertaSelecionada.movimentTv;
		}

		String productName;
		String productLegacyName;
		String currentProductName;

		if ((upgradeOrDowngrade || keep) && String.isNotBlank(slType)) {
			productName			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label;
			productLegacyName	= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy;
			currentProductName	= produtoAntigo.tv[0].planTv.label;
		} else if (acquisition) {
			productName			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label;
			productLegacyName	= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy;
			currentProductName	= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
		} else if (keep && String.isBlank(slType)) {
			productName			= produtoAntigo.tv[0].planTv.nameLegacy;
			productLegacyName	= produtoAntigo.tv[0].planTv.label;
			currentProductName	= produtoAntigo.tv[0].planTv.label;
		}

		Solic_NBA__c solicTv			= new Solic_NBA__c();
		solicTv.CurrentProduct__c		= currentProductName;
		solicTv.ProductName__c			= productName;
		solicTv.LegacyNameProduct__c	= productLegacyName;
		solicTv.Order__c				= pedido.Id;
		solicTv.ProductType__c			= NBA_Constants.TV_PACOTE;
		solicTv.Message__c				= '';
		solicTv.Order__c				= pedido.Id;
		solicTv.Status__c				= keep && String.isBlank(slType) ? null : NBA_Constants.EM_ABERTO;
		solicTv.Movement__c				= ofertaSelecionada.movimentTv;
		solicTv.OfferType__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
		solicTv.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
		solicTv.Family__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].familyName;
		solicTv.PromotionName__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions[0].description : '';
		solicTv.SolicitationType__c		= slType;
		solicTv.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PP;
		solicTv.Fidelity__c				= produtoAntigo.tv[0].planTv.fidelity.hasFidelity;
		solicTv.RenewFidelity__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.fidelity.hasFidelity;
		solicTv.PenaltyPrice__c			= null;
		solicTv.QuantityPromoMonths__c	= ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.size() > 0 ? String.valueOf(ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.get(0).valid) : '';
		solicTv.PromotionValue__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.size() > 0 ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.get(0).discount : 0;
		solicTv.TotalValue__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].totalValue;
		solicTv.TechnologyType__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].TechnologyName;
		solicTv.pointId__c				= keep && String.isBlank(slType) ? null : produtoAntigo.tv[0].planTv.pointId;

		if(keep || upgradeOrDowngrade){
			solicTv.FeeType__c 			= feeLabel == NBA_Constants.TV_PACOTE ? feeType : null;
			solicTv.FeePrice__c			= feeLabel == NBA_Constants.TV_PACOTE ? feePrice : null;
			solicTv.PaymentMethod__c	= feeLabel == NBA_Constants.TV_PACOTE ? ofertaSelecionada.paymentMethodUpgrade : null;  
		}else {
			solicTv.FeeType__c 			= feeLabelAdesao == NBA_Constants.TV_PACOTE ? feeTypeAdesao : null;
			solicTv.FeePrice__c			= feeLabelAdesao == NBA_Constants.TV_PACOTE ? feePriceAdesao : null;
			solicTv.PaymentMethod__c	= feeLabelAdesao == NBA_Constants.TV_PACOTE ? ofertaSelecionada.paymentMethodMembership : null;
		}
                
		if(acquisition){
			solicTv.CurrentValue__c		= 0.00;
			solicTv.Value__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.value;
		}else {
			solicTv.CurrentValue__c		= produtoAntigo.tv[0].planTv.value;
			solicTv.Value__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.value;
		}
		return solicTv;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Solic do tipo TV Pacote, Oriundas da Posse Atual ou Produto Atual
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getTvPacoteProdutoAtual(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		//TAXA
		NBA_OfferComparator_CC.Fee offerFee = ofertaSelecionada.lstUpgradeFee.size() > 0 ? ofertaSelecionada.lstUpgradeFee[0] : null;
		Decimal feePrice					= offerFee != null ? offerFee.value : null;
		String feeLabel						= offerFee != null ? offerFee.label : null;
        String feeType 						= NBA_Constants.MOVIMENTO_MANTIDO;

		Solic_NBA__c solicTv				= new Solic_NBA__c();
		solicTv.CurrentProduct__c			= produtoAntigo.tv[0].planTv.label;
		solicTv.ProductName__c				= produtoAntigo.tv[0].planTv.nameLegacy;
		solicTv.LegacyNameProduct__c		= produtoAntigo.tv[0].planTv.label;
		solicTv.Order__c					= pedido.Id;
		solicTv.ProductType__c				= NBA_Constants.TV_PACOTE;
		solicTv.Message__c					= '';
		solicTv.Order__c					= pedido.Id;
		solicTv.Status__c					= null;
		solicTv.Movement__c					= NBA_Constants.MOVIMENTO_LATERAL;
		solicTv.OfferType__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
		solicTv.ComboProfile__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
		solicTv.Family__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].familyName;
		solicTv.PromotionName__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions.size() > 0 ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.lstPromotions[0].description : '';
		solicTv.SolicitationType__c			= null;
		solicTv.SpotType__c					= NBA_Constants.SPOT_TYPE_SOLIC_PP;
		solicTv.Fidelity__c					= produtoAntigo.tv[0].planTv.fidelity.hasFidelity;
		solicTv.RenewFidelity__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.fidelity.hasFidelity;
		solicTv.PenaltyPrice__c				= null;
        solicTv.FeeType__c 					= feePrice > 0 ? feeType : null;
        solicTv.FeePrice__c					= feePrice != null ? feePrice : 0.00;
        solicTv.PaymentMethod__c			= null;  
        solicTv.CurrentValue__c				= produtoAntigo.tv[0].planTv.value;
        solicTv.Value__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.value;
		solicTv.TechnologyType__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].TechnologyName;
		solicTv.QuantityPromoMonths__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.size() > 0 ? String.valueOf(ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.get(0).valid) : '';
		solicTv.PromotionValue__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.size() > 0 ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].plantv.lstPromotions.get(0).discount : 0;
		solicTv.TotalValue__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].totalValue;
		return solicTv;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo A LA CARTE com movimentação LATERAL
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAlaCarteTvLateral(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartOld = new Map<String, NBA_OfferComparator_CC.Additional>();
		for (NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.tv[0].addOptions.lstAdditionals) {
			if(alacarte.checked)
				mapAlacartOld.put(alacarte.id, alacarte);
		}

		for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals) {
			if(alacarte.checked){
				if(mapAlacartOld.containsKey(alacarte.Id)){
					Solic_NBA__c solicAlaCarteTV			= new Solic_NBA__c();
					solicAlaCarteTV.Message__c				= '';
					solicAlaCarteTV.Order__c				= pedido.Id;
					solicAlaCarteTV.Status__c				= null;
					solicAlaCarteTV.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
					solicAlaCarteTV.ProductName__c			= mapAlacartOld.containsKey(alacarte.id) ? mapAlacartOld.get(alacarte.id).productName : alacarte.productName;
					solicAlaCarteTV.CurrentProduct__c 		= mapAlacartOld.containsKey(alacarte.id) ? mapAlacartOld.get(alacarte.id).label : alacarte.label;
					solicAlaCarteTV.LegacyNameProduct__c	= String.isNotBlank(alacarte.nameLegacy) ? alacarte.nameLegacy : alacarte.label;
					solicAlaCarteTV.ProductType__c			= NBA_Constants.TV_A_LA_CARTE;
					solicAlaCarteTV.OfferType__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
					solicAlaCarteTV.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
					solicAlaCarteTV.Family__c				= alacarte.familyName;
					solicAlaCarteTV.SolicitationType__c		= null;
					solicAlaCarteTV.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PP;
					solicAlaCarteTV.TechnologyType__c		= null; 
					solicAlaCarteTV.CurrentValue__c			= mapAlacartOld.containsKey(alacarte.id) ? mapAlacartOld.get(alacarte.id).value : 0.00;
					solicAlaCarteTV.Value__c				= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? alacarte.lstPromotions.get(0).value : alacarte.value;
					solicAlaCarteTV.QuantityPromoMonths__c	= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? String.valueOf(alacarte.lstPromotions.get(0).valid) : '0';
					solicAlaCarteTV.PromotionValue__c		= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? alacarte.lstPromotions.get(0).discount : 0;
					solicAlaCarteTV.TotalValue__c			= alacarte.value;
						
					if(String.isNotBlank(alacarte.description)) {
						solicAlaCarteTV.PromotionName__c    = alacarte.description;
					} else {
						solicAlaCarteTV.PromotionName__c    = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
					}
						
					if(mapAlacartOld.containsKey(alacarte.id) && alacarte.technologyType != mapAlacartOld.get(alacarte.id).technologyType){
						solicAlaCarteTV.MainPoint__c		= produtoAntigo.tv[0].planTv.label;
						if(solicAlaCarteTV.MainPoint__c	!= null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
							solicAlaCarteTV.MainPoint__c	= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
						}
					}else {
						solicAlaCarteTV.MainPoint__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
						if(solicAlaCarteTV.MainPoint__c != null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
							solicAlaCarteTV.MainPoint__c	= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
						}
					}
					lstSolicInsert.add(solicAlaCarteTV);
				}
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo A LA CARTE com movimentação AQUSIÇÃO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAlaCarteTvAquisicao(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert, Boolean isOffer){
		Integer indexTV				= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? (ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size()> 1 ? 1 : 0) : 0;
		String slType				= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTV] : null;
		Boolean keep				= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_MANTIDO || ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_LATERAL;
		
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartOld = new Map<String, NBA_OfferComparator_CC.Additional>();
		for (NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.tv[0].addOptions.lstAdditionals) {
			if(alacarte.checked)
				mapAlacartOld.put(alacarte.id, alacarte);
		}
		for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals) {
			if(alacarte.checked && !mapAlacartOld.containsKey(alacarte.id)){
				Integer indexTvAdd						= String.isNotBlank(alacarte.solicitationType) ? (alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
				String slTypeTvAdd						= String.isNotBlank(alacarte.solicitationType) ? alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTvAdd] : null;

				Solic_NBA__c solicAlaCarteTV			= new Solic_NBA__c();
				solicAlaCarteTV.Message__c				= '';
				solicAlaCarteTV.Order__c				= pedido.Id;
				solicAlaCarteTV.Status__c				= NBA_Constants.EM_ABERTO;
				solicAlaCarteTV.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
				solicAlaCarteTV.ProductName__c			= alacarte.label;
				solicAlaCarteTV.LegacyNameProduct__c	= isOffer ? alacarte.nameLegacy : alacarte.detail;
				solicAlaCarteTV.ProductType__c			= NBA_Constants.TV_A_LA_CARTE;
				solicAlaCarteTV.OfferType__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
				solicAlaCarteTV.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
				solicAlaCarteTV.Family__c				= alacarte.familyName;
				solicAlaCarteTV.SolicitationType__c		= slTypeTvAdd;
				solicAlaCarteTV.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PP;
				solicAlaCarteTV.TechnologyType__c		= null;
				solicAlaCarteTV.CurrentValue__c			= 0.00;
				solicAlaCarteTV.Value__c				= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? alacarte.lstPromotions.get(0).value : alacarte.value;
				solicAlaCarteTV.QuantityPromoMonths__c	= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? String.valueOf(alacarte.lstPromotions.get(0).valid) : '0';
				solicAlaCarteTV.PromotionValue__c		= (alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty()) ? alacarte.lstPromotions.get(0).discount : 0;
				solicAlaCarteTV.TotalValue__c			= alacarte.value;
				solicAlaCarteTV.pointId__c				= keep && String.isBlank(slType) ? produtoAntigo.tv[0].planTv.pointId : null;
						
				if (String.isNotBlank(alacarte.description)) {
					solicAlaCarteTV.PromotionName__c    = alacarte.description;
				} else {
					solicAlaCarteTV.PromotionName__c    = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}

				if(mapAlacartOld.containsKey(alacarte.id) && alacarte.technologyType != mapAlacartOld.get(alacarte.id).technologyType){
					solicAlaCarteTV.MainPoint__c		= produtoAntigo.tv[0].planTv.label;
					if(solicAlaCarteTV.MainPoint__c != null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
						solicAlaCarteTV.MainPoint__c	= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
					}
				}else {
					solicAlaCarteTV.MainPoint__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
					if(solicAlaCarteTV.MainPoint__c != null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
						solicAlaCarteTV.MainPoint__c	= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
					}
				}
				lstSolicInsert.add(solicAlaCarteTV);
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo PONTO OPCIONAL DE TV com movimentação LATERAL
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getPontoOpcionalTvLateral(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert ){
		//PONTO OPCIONAL 01 - MOVIMENTO LATERAL
		Map<Integer, NBA_OfferComparator_CC.Optional> mapPontoOpcional = new Map<Integer, NBA_OfferComparator_CC.Optional>();
		Integer count = 0;
		for(NBA_OfferComparator_CC.Optional pontoOpcional : produtoAntigo.tv.get(0).addOptions.lstOptionalPointsRPA){
			mapPontoOpcional.put( count, pontoOpcional );
			count++;
		}
		System.debug('MAP PO --> ' + mapPontoOpcional);
		count = 0; //Resetando contador.

		for(NBA_OfferComparator_CC.Optional pontoOpcional : ofertaSelecionada.tv.get(0).addOptions.lstOptionalPointsRPA){			
			if(pontoOpcional.checked && pontoOpcional.isAlreadyIncluded && (pontoOpcional.solicitationType==null ||
			  (pontoOpcional.solicitationType!=null && !pontoOpcional.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO)))){
				Solic_NBA__c solic				= new Solic_NBA__c();
				solic.OfferType__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
				solic.TechnologyType__c			= pontoOpcional.technologyType != '' ? pontoOpcional.technologyType : pontoOpcional.label;
				solic.LegacyNameProduct__c		= mapPontoOpcional.containsKey( count ) ? mapPontoOpcional.get( count ).catalogName : pontoOpcional.catalogName;
				solic.CurrentProduct__c			= mapPontoOpcional.containsKey( count ) ? mapPontoOpcional.get( count ).catalogName : pontoOpcional.catalogName;
				solic.ProductName__c			= mapPontoOpcional.containsKey( count ) ? mapPontoOpcional.get( count ).productName : pontoOpcional.productName;
				solic.Family__c					= pontoOpcional.familyName;
				solic.PromotionName__c			= pontoOpcional.promotion.label;
				solic.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
				solic.Message__c				= '';
				solic.Order__c					= pedido.Id;
				solic.Status__c					= null;
				solic.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
				solic.ProductType__c			= NBA_Constants.TV_PONTOS_ADICIONAIS;
				solic.SolicitationType__c		= null;
				solic.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solic.Value__c					= pontoOpcional.price;
				solic.PaymentMethod__c			= ofertaSelecionada.paymentMethodMembership;
				solic.CurrentValue__c			= mapPontoOpcional.containsKey( count ) ? mapPontoOpcional.get( count ).price : pontoOpcional.price;
				solic.MainPoint__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
				solic.TotalValue__c				= mapPontoOpcional.containsKey( count ) ? mapPontoOpcional.get( count ).totalValue : pontoOpcional.totalValue;
				solic.QuantityPromoMonths__c	= String.valueOf( pontoOpcional.promotion.valid ) != null ? String.valueOf( pontoOpcional.promotion.valid ) : '0';
				solic.PromotionValue__c			= String.valueOf( pontoOpcional.promotion.value ) != null ? pontoOpcional.promotion.value : 0;
				lstSolicInsert.add( solic );
				count++;
			}
		}
		return lstSolicInsert;
	}
	
	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo PONTO OPCIONAL DE TV com movimentação AQUISIÇÃO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getPontoOpcionalTvAquisicao(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		for(NBA_OfferComparator_CC.Optional pontoOpcional : ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstOptionalPointsRPA){
			if(pontoOpcional.checked && !pontoOpcional.isAlreadyIncluded){
				Solic_NBA__c solic				= new Solic_NBA__c();
				solic.OfferType__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
				solic.LegacyNameProduct__c		= pontoOpcional.nameLegacy;
				solic.ProductName__c			= pontoOpcional.label;
				solic.Family__c					= pontoOpcional.familyName;
				solic.PromotionName__c			= pontoOpcional.promotion.label;
				solic.TechnologyType__c			= pontoOpcional.technologyType;
				solic.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
				solic.Message__c				= '';
				solic.Order__c					= pedido.Id;
				solic.Status__c					= NBA_Constants.EM_ABERTO;
				solic.Movement__c				= NBA_Constants.MOVIMENTO_AQUISICAO;
				solic.ProductType__c			= NBA_Constants.TV_PONTOS_ADICIONAIS;
				solic.SolicitationType__c		= NBA_Constants.SOLICITAIONTYPE_PONTO_OPCIONAL;
				solic.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PP;
				solic.Value__c					= pontoOpcional.value;
				solic.PaymentMethod__c			= ofertaSelecionada.paymentMethodMembership;
				solic.CurrentValue__c			= 0.00;
				solic.MainPoint__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
				solic.TotalValue__c				= pontoOpcional.value;
				solic.QuantityPromoMonths__c	= String.valueOf( pontoOpcional.promotion.valid ) != null ? String.valueOf( pontoOpcional.promotion.valid ) : '0' ;
				solic.PromotionValue__c			= String.valueOf(pontoOpcional.promotion.value) != null ? pontoOpcional.promotion.value : 0;
				lstSolicInsert.add( solic );
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Description: Método que retorna uma Lista de Solic do tipo PONTO OPCIONAL DE TV com movimentação MUDANÇA DE PACOTE
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getPontoOpcionalTvMudancaPacote(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert ){

		Map<Integer, NBA_OfferComparator_CC.Optional> mapPontoOpcional = new Map<Integer, NBA_OfferComparator_CC.Optional>();
		Integer count = 0;
		for(NBA_OfferComparator_CC.Optional pontoOpcional : produtoAntigo.tv.get(0).addOptions.lstOptionalPointsRPA){
			mapPontoOpcional.put( count, pontoOpcional );
			count++;
		}
		count = 0;

		for(NBA_OfferComparator_CC.Optional pontoOpcional : ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstOptionalPointsRPA){
			Integer indexPO	= String.isNotBlank(pontoOpcional.solicitationType) ? (pontoOpcional.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size()> 1 ? 1 : 0) : 0;
			String slType	= String.isNotBlank(pontoOpcional.solicitationType) ? pontoOpcional.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexPO] : null;
			
			if(pontoOpcional.checked && pontoOpcional.isAlreadyIncluded && 
			   pontoOpcional.solicitationType!=null && pontoOpcional.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO)){
				Solic_NBA__c solic				= new Solic_NBA__c();
				solic.OfferType__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].offerType;
				solic.TechnologyType__c			= pontoOpcional.technologyType != '' ? pontoOpcional.technologyType : pontoOpcional.label;
				solic.LegacyNameProduct__c		= pontoOpcional.nameLegacy; 
				solic.CurrentProduct__c			= mapPontoOpcional.containsKey(count) ? mapPontoOpcional.get(count).catalogName : pontoOpcional.catalogName;
				solic.ProductName__c			= pontoOpcional.label;
				solic.Family__c					= pontoOpcional.familyName;
				solic.PromotionName__c			= pontoOpcional.promotion.label;
				solic.ComboProfile__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
				solic.Message__c				= '';
				solic.Order__c					= pedido.Id;
				solic.Status__c					= NBA_Constants.EM_ABERTO;
				solic.Movement__c				= ofertaSelecionada.movimentTv;
				solic.ProductType__c			= NBA_Constants.TV_PONTOS_ADICIONAIS;
				solic.SolicitationType__c		= slType;
				solic.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solic.Value__c					= pontoOpcional.value;
				solic.PaymentMethod__c			= ofertaSelecionada.paymentMethodMembership;
				solic.CurrentValue__c			= mapPontoOpcional.containsKey(count) ? mapPontoOpcional.get(count).value : pontoOpcional.value;
				solic.MainPoint__c				= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
				solic.TotalValue__c				= pontoOpcional.totalValue;
				solic.QuantityPromoMonths__c	= String.valueOf( pontoOpcional.promotion.valid ) != null ? String.valueOf( pontoOpcional.promotion.valid ) : '0';
				solic.PromotionValue__c			= String.valueOf( pontoOpcional.promotion.value ) != null ? pontoOpcional.promotion.value : 0;
				lstSolicInsert.add( solic );
				count++;
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo TV PACOTE, PONTO OPCIONAL, A LA CARTE DE TV com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	  public List<Solic_NBA__c> getTvCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		//CANCELAMENTO DO PRODUTO TV PACOTE
		//CANCELAMENTO EM CASCATA, A LA CARTE E PONTO OPCIONAL
		Integer indexTV				= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? (ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
		String slType				= String.isNotBlank(produtoAntigo.tv[0].solicitationType) ? produtoAntigo.tv[0].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTV] : null;

		Solic_NBA__c solicTv		= new Solic_NBA__c();
		solicTv.Order__c			= pedido.Id;
		solicTv.CurrentProduct__c	= produtoAntigo.tv[0].planTv.label;
		solicTv.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
		solicTv.Status__c			= NBA_Constants.EM_ABERTO;
		solicTv.ProductType__c		= NBA_Constants.TV_PACOTE;
		solicTv.OfferType__c		= produtoAntigo.tv[0].offerType;
		solicTv.PromotionName__c	= produtoAntigo.tv[0].planTv.lstPromotions.size() > 0 ? produtoAntigo.tv[0].planTv.lstPromotions[0].description : '';
		solicTv.ComboProfile__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].comboProfile;
		solicTv.Family__c			= produtoAntigo.tv[0].familyName;
		solicTv.SolicitationType__c	= slType;
		solicTv.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PP;
		solicTv.Fidelity__c			= produtoAntigo.tv[0].planTv.fidelity.hasFidelity;
		solicTv.PenaltyPrice__c		= produtoAntigo.tv[0].planTv.fidelity.penalty;
		solicTv.Value__c			= 0.00;
		solicTv.CurrentValue__c		= produtoAntigo.tv[0].planTv.value;
		solicTv.TechnologyType__c	= produtoAntigo.tv[0].technologyName;

		if(produtoAntigo.tv[0].planTv.lstPromotions != null && !produtoAntigo.tv[0].planTv.lstPromotions.isEmpty()){
			solicTv.CurrentValue__c = produtoAntigo.tv[0].planTv.lstPromotions.get(0).value;
		}else {
			solicTv.CurrentValue__c = produtoAntigo.tv[0].planTv.value;
		}
		lstSolicInsert.add( solicTv );

		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.tv[0].addOptions.lstAdditionals) {
            if(alacarte.checked){
				Solic_NBA__c solicAlacarte			= new Solic_NBA__c();
				solicAlacarte.Order__c				= pedido.Id;
				solicAlacarte.CurrentProduct__c		= alacarte.label;
				solicAlacarte.Status__c				= NBA_Constants.EM_ABERTO;
				solicAlacarte.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicAlacarte.ProductType__c		= NBA_Constants.TV_A_LA_CARTE;
				solicAlacarte.OfferType__c			= null;
				solicAlacarte.PromotionName__c		= null;
				solicAlacarte.ComboProfile__c		= null;
				solicAlacarte.SolicitationType__c	= slType;
				solicAlacarte.Message__c			= '';
				solicAlacarte.Family__c				= null;
				solicAlacarte.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PP;
				solicAlacarte.Value__c				= 0.00;
				solicAlacarte.CurrentValue__c		= alacarte.value;
				solicAlacarte.TechnologyType__c		= null;
				solicAlacarte.MainPoint__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
				lstSolicInsert.add( solicAlacarte );
			}
		}

		for(NBA_OfferComparator_CC.Optional pontoOpcional : produtoAntigo.tv[0].addOptions.lstOptionalPoints){
			if(pontoOpcional.checked){
				Solic_NBA__c solicPontoOpcional			= new Solic_NBA__c();
				solicPontoOpcional.Order__c				= pedido.Id;
				solicPontoOpcional.CurrentProduct__c	= produtoAntigo.tv[0].planTv.label;
				solicPontoOpcional.Status__c			= NBA_Constants.EM_ABERTO;
				solicPontoOpcional.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicPontoOpcional.ProductType__c		= NBA_Constants.TV_PONTOS_ADICIONAIS;
				solicPontoOpcional.OfferType__c			= produtoAntigo.tv[0].offerType;
				solicPontoOpcional.PromotionName__c		= pontoOpcional.promotion.label;
				solicPontoOpcional.Message__c			= '';
				solicPontoOpcional.Family__c			= pontoOpcional.familyName;
				solicPontoOpcional.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicPontoOpcional.TechnologyType__c	= pontoOpcional.technologyType;
				solicPontoOpcional.Value__c				= 0.00;
				solicPontoOpcional.CurrentValue__c		= pontoOpcional.price;
				solicPontoOpcional.MainPoint__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.nameLegacy;
				lstSolicInsert.add( solicPontoOpcional );
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo PONTO OPCIONAL, A LA CARTE DE TV com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAdicionaisTvCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Integer indexTV	= String.isNotBlank(ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType) ? (ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
		String slType	= String.isNotBlank(produtoAntigo.tv[0].solicitationType) ? produtoAntigo.tv[0].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTV] : null;
		Solic_NBA__c solic;

		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartAtual = new Map<String, NBA_OfferComparator_CC.Additional>();
		for (NBA_OfferComparator_CC.Additional add : produtoAntigo.tv[0].addOptions.lstAdditionals) {
			if(add.checked){
				mapAlacartAtual.put(add.id, add);
			}
		}
                         
        for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals) {
            if(!alacarte.checked && mapAlacartAtual.containsKey(alacarte.id)){
                solic						= new Solic_NBA__c();
				solic.Order__c				= pedido.Id;
                solic.CurrentProduct__c		= mapAlacartAtual.get( alacarte.id ).catalogName;
                solic.Status__c				= NBA_Constants.EM_ABERTO;
                solic.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
                solic.ProductType__c		= NBA_Constants.TV_A_LA_CARTE;
                solic.OfferType__c			= null;
                solic.PromotionName__c		= null;
                solic.ComboProfile__c		= null;
                solic.SolicitationType__c	= slType;
                solic.Message__c			= '';
                solic.Family__c				= null;
                solic.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PP;
                solic.Value__c				= 0.00;
                solic.CurrentValue__c		= alacarte.value;
                solic.TechnologyType__c		= null; 
				solic.MainPoint__c			= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
                lstSolicInsert.add( solic );
            }
        }
		

		//PONTO OPCIONAL 01 - MOVIMENTO CANCELAMENTO
		if(produtoAntigo.tv[0].addOptions.firstPoint.checked && !ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.firstPoint.checked) {
			solic								= new Solic_NBA__c();
			solic.Order__c						= pedido.Id;
			solic.CurrentProduct__c				= produtoAntigo.tv[0].planTv.label;
			solic.Status__c						= NBA_Constants.EM_ABERTO;
			solic.Movement__c					= NBA_Constants.MOVIMENTO_CANCELAMENTO;
			solic.ProductType__c				= NBA_Constants.TV_PONTOS_ADICIONAIS;
			solic.OfferType__c					= produtoAntigo.tv[0].offerType;
			solic.PromotionName__c				= produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[0].promotion.label;
			solic.Message__c					= '';
			solic.Family__c						= produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[0].familyName;
			solic.SpotType__c					= NBA_Constants.SPOT_TYPE_SOLIC_PO;
			solic.TechnologyType__c				= produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[0].technologyType;
			solic.Value__c						= 0.00;
			solic.CurrentValue__c				= produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[0].price;
			solic.MainPoint__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.nameLegacy;
			lstSolicInsert.add( solic );
		}
		
		//PONTO OPCIONAL 02 - MOVIMENTO CANCELAMENTO
        if(produtoAntigo.tv[0].addOptions.secondPoint.checked && !ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.secondPoint.checked) {
			solic								= new Solic_NBA__c();
			solic.Order__c						= pedido.Id;
			solic.CurrentProduct__c				= produtoAntigo.tv[0].planTv.label;
			solic.Status__c						= NBA_Constants.EM_ABERTO;
			solic.Movement__c					= NBA_Constants.MOVIMENTO_CANCELAMENTO;
			solic.ProductType__c				= NBA_Constants.TV_PONTOS_ADICIONAIS;
			solic.OfferType__c					= produtoAntigo.tv[0].offerType;
			solic.PromotionName__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=2 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[1].promotion.label : '';
			solic.Message__c					= '';
			solic.Family__c						= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=2 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[1].familyName : '';
			solic.SpotType__c					= NBA_Constants.SPOT_TYPE_SOLIC_PO;
			solic.TechnologyType__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=2 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[1].technologyType : '';
			solic.Value__c						= 0.00;
			solic.CurrentValue__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=2 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[1].price : 0;
			solic.MainPoint__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.nameLegacy;
			lstSolicInsert.add( solic );
		}
		
		//PONTO OPCIONAL 03 - MOVIMENTO CANCELAMENTO
        if(produtoAntigo.tv[0].addOptions.thirdPoint.checked && !ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.thirdPoint.checked) {
			solic								= new Solic_NBA__c();
			solic.Order__c						= pedido.Id;
			solic.CurrentProduct__c				= produtoAntigo.tv[0].planTv.label;
			solic.Status__c						= NBA_Constants.EM_ABERTO;
			solic.Movement__c					= NBA_Constants.MOVIMENTO_CANCELAMENTO;
			solic.ProductType__c				= NBA_Constants.TV_PONTOS_ADICIONAIS;
			solic.OfferType__c					= produtoAntigo.tv[0].offerType;
			solic.PromotionName__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=3 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[2].promotion.label : '';
			solic.Message__c					= '';
			solic.Family__c						= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=3 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[2].familyName : '';
			solic.SpotType__c					= NBA_Constants.SPOT_TYPE_SOLIC_PO;
			solic.TechnologyType__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=3 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[2].technologyType : '';
			solic.Value__c						= 0.00;
			solic.CurrentValue__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=3 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[2].price : 0;
			solic.MainPoint__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.nameLegacy;
			lstSolicInsert.add( solic );
		}
		
		//PONTO OPCIONAL 04 - MOVIMENTO CANCELAMENTO
        if(produtoAntigo.tv[0].addOptions.fourthPoint.checked && !ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.fourthPoint.checked) {
			solic								= new Solic_NBA__c();
			solic.Order__c						= pedido.Id;
			solic.CurrentProduct__c				= produtoAntigo.tv[0].planTv.label;
			solic.Status__c						= NBA_Constants.EM_ABERTO;
			solic.Movement__c					= NBA_Constants.MOVIMENTO_CANCELAMENTO;
			solic.ProductType__c				= NBA_Constants.TV_PONTOS_ADICIONAIS;
			solic.OfferType__c					= produtoAntigo.tv[0].offerType;
			solic.PromotionName__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=4 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[3].promotion.label : '';
			solic.Family__c						= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=4 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[3].familyName : '';
			solic.SpotType__c					= NBA_Constants.SPOT_TYPE_SOLIC_PO;
			solic.TechnologyType__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=4 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[3].technologyType : '';
			solic.Value__c						= 0.00;
			solic.CurrentValue__c				= !produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.isEmpty() && produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA.size() >=4 ? produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA[3].price : 0;
			solic.MainPoint__c					= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.nameLegacy;
			lstSolicInsert.add( solic );
		}
		return lstSolicInsert;
	}

	public Boolean isAquisicaoPontoOpacional(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo){
		Boolean aquisicao = false;
		
		if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.firstPoint.checked && !produtoAntigo.tv[0].addOptions.firstPoint.checked)
			aquisicao = true;
		if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.secondPoint.checked && !produtoAntigo.tv[0].addOptions.secondPoint.checked)
			aquisicao = true;
		if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.thirdPoint.checked && !produtoAntigo.tv[0].addOptions.thirdPoint.checked)
			aquisicao = true;
		if(ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.fourthPoint.checked && !produtoAntigo.tv[0].addOptions.fourthPoint.checked)
			aquisicao = true;

		return aquisicao;
	}
}