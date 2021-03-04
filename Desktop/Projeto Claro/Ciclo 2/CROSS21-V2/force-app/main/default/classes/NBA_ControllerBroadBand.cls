/*----------------------------------------------------------  
  EMPRESA   - Accenture
  DESCRICÃO - classe responsável pelo controle do produto BANDA LARGA | BL ASSINATURA | Broad Band
  Autor     - Diego Silva
  Versão    - 1.0
  ------------------------------------------------------------*/
public class NBA_ControllerBroadBand  {
	
	private static NBA_ControllerBroadBand instance;

	public static NBA_ControllerBroadBand getInstance(){
		if(instance == null)
			instance = new NBA_ControllerBroadBand();
		return instance;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo BL ASSINATURA, Oriunda da Oferta selecionada
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getBandaLargaOfertaSelecionada(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		Integer indexBL				= String.isNotBlank(ofertaSelecionada.broadband.solicitationType) ? (ofertaSelecionada.broadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
		String slType				= String.isNotBlank(ofertaSelecionada.broadband.solicitationType) ? ofertaSelecionada.broadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexBL] : null;

		Boolean acquisition			= ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_AQUISICAO;
		Boolean downgrade			= ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_DOWNGRADE;
		Boolean upgrade 			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE;
        Boolean upgradeOrDowngrade	= ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_UPGRADE || downgrade;
		Boolean keep				= ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_MANTIDO || ofertaSelecionada.movimentBroadband == NBA_Constants.MOVIMENTO_LATERAL;

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
            feeType							= ofertaSelecionada.movimentBroadband;
        }
                
		//TAXA PARA ADESÃO DE PACOTE
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
			productName			= ofertaSelecionada.broadband.planBroadband.label;
			productLegacyName	= ofertaSelecionada.broadband.planBroadband.nameLegacy;
			currentProductName	= produtoAntigo.broadband.planBroadband.label;
		} else if (acquisition) {
			productName			= ofertaSelecionada.broadband.planBroadband.label;
			productLegacyName	= ofertaSelecionada.broadband.planBroadband.nameLegacy;
		} else if (keep && String.isBlank(slType)) {
			productName			= produtoAntigo.broadband.planBroadband.nameLegacy;
			productLegacyName	= produtoAntigo.broadband.planBroadband.label;
			currentProductName	= produtoAntigo.broadband.planBroadband.label;
		}

		Solic_NBA__c solicBroadband			= new Solic_NBA__c();
		solicBroadband.CurrentProduct__c	= currentProductName;
		solicBroadband.ProductName__c		= productName;
		solicBroadband.LegacyNameProduct__c = productLegacyName;
		solicBroadband.Message__c			= '';
		solicBroadband.Order__c				= pedido.Id;
		solicBroadband.Status__c			= keep && String.isBlank(slType) ? null : NBA_Constants.EM_ABERTO;
		solicBroadband.ProductType__c		= NBA_Constants.BL_ASSINATURA;
		solicBroadband.Movement__c			= ofertaSelecionada.movimentBroadband;
		solicBroadband.OfferType__c			= ofertaSelecionada.broadband.offerType;
		solicBroadband.ComboProfile__c		= ofertaSelecionada.broadband.comboProfile;
		solicBroadband.Family__c			= ofertaSelecionada.broadband.familyName;
		solicBroadband.PromotionName__c		= ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ? ofertaSelecionada.broadband.planBroadband.lstPromotions[0].description : '';
		solicBroadband.SolicitationType__c	= slType;
		solicBroadband.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicBroadband.MainPoint__c			= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
		solicBroadband.Fidelity__c			= produtoAntigo.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.RenewFidelity__c		= ofertaSelecionada.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.PenaltyPrice__c		= null;							
		solicBroadband.QuantityPromoMonths__c	= ofertaSelecionada.broadband.planBroadband.lstPromotions != null && !ofertaSelecionada.broadband.planBroadband.lstPromotions.isEmpty() ? String.valueOf(ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).valid) : '0';
		solicBroadband.PromotionValue__c		= ofertaSelecionada.broadband.planBroadband.lstPromotions != null && !ofertaSelecionada.broadband.planBroadband.lstPromotions.isEmpty() ? ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).discount : 0;
		solicBroadband.TotalValue__c			= ofertaSelecionada.broadband.totalValue;
		solicBroadband.pointId__c				= keep && String.isBlank(slType) ? null : produtoAntigo.broadband.planBroadband.pointId;

        if(keep || upgradeOrDowngrade){
            solicBroadband.PaymentMethod__c		= feeLabel == NBA_Constants.BL_ASSINATURA ? ofertaSelecionada.paymentMethodUpgrade : null;
			solicBroadband.FeePrice__c			= feeLabel == NBA_Constants.BL_ASSINATURA ? feePrice : null;
            solicBroadband.FeeType__c   		= feeLabel == NBA_Constants.BL_ASSINATURA ? feeType : null;
        }else {
            solicBroadband.FeeType__c 			= feeLabelAdesao == NBA_Constants.BL_ASSINATURA ? feeTypeAdesao : null;
            solicBroadband.FeePrice__c			= feeLabelAdesao == NBA_Constants.BL_ASSINATURA ? feePriceAdesao : null;
            solicBroadband.PaymentMethod__c		= feeLabelAdesao == NBA_Constants.BL_ASSINATURA ? ofertaSelecionada.paymentMethodMembership : null;
        }
                
		if(acquisition){
			solicBroadband.CurrentValue__c		= 0.00;
			solicBroadband.Value__c				= ofertaSelecionada.broadband.planBroadband.value;
        }else {
            solicBroadband.CurrentValue__c		= produtoAntigo.broadband.planBroadband.value;
            solicBroadband.Value__c				= ofertaSelecionada.broadband.planBroadband.value;
        }
		
		return solicBroadband;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Solic do tipo BL ASSINATURA, Oriunda da Posse Atual ou Produto Atual
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getBandaLargaProdutoAtual(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		NBA_OfferComparator_CC.Fee offerFee = ofertaSelecionada.lstUpgradeFee.size() > 0 ? ofertaSelecionada.lstUpgradeFee[0] : null;
		Decimal feePrice					= offerFee != null ? offerFee.value : null;
		String feeLabel						= offerFee != null ? offerFee.label : null;
        String feeType 						= NBA_Constants.MOVIMENTO_MANTIDO;
                
		Solic_NBA__c solicBroadband			= new Solic_NBA__c();
		solicBroadband.CurrentProduct__c	= produtoAntigo.broadband.planBroadband.label;
		solicBroadband.ProductName__c		= produtoAntigo.broadband.planBroadband.nameLegacy;
		solicBroadband.LegacyNameProduct__c = produtoAntigo.broadband.planBroadband.label;
		solicBroadband.Message__c			= '';
		solicBroadband.Order__c				= pedido.Id;
		solicBroadband.Status__c			= null;
		solicBroadband.ProductType__c		= NBA_Constants.BL_ASSINATURA;
		solicBroadband.Movement__c			= NBA_Constants.MOVIMENTO_LATERAL;
		solicBroadband.OfferType__c			= ofertaSelecionada.broadband.offerType;
		solicBroadband.ComboProfile__c		= ofertaSelecionada.broadband.comboProfile;
		solicBroadband.Family__c			= ofertaSelecionada.broadband.familyName;
		solicBroadband.PromotionName__c		= ofertaSelecionada.broadband.planBroadband.lstPromotions.size() > 0 ? ofertaSelecionada.broadband.planBroadband.lstPromotions[0].description : '';
		solicBroadband.SolicitationType__c	= null;
		solicBroadband.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicBroadband.Fidelity__c			= produtoAntigo.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.RenewFidelity__c		= ofertaSelecionada.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.PenaltyPrice__c		= null;							
        solicBroadband.PaymentMethod__c		= feeLabel == NBA_Constants.BL_ASSINATURA ? ofertaSelecionada.paymentMethodUpgrade : null;
		solicBroadband.FeePrice__c			= feeLabel == NBA_Constants.BL_ASSINATURA ? feePrice : null;
        solicBroadband.FeeType__c   		= feePrice > 0 ? feeType : null;
        solicBroadband.CurrentValue__c		= produtoAntigo.broadband.planBroadband.value;
        solicBroadband.Value__c				= ofertaSelecionada.broadband.planBroadband.value;
		solicBroadband.QuantityPromoMonths__c	= ofertaSelecionada.broadband.planBroadband.lstPromotions != null && !ofertaSelecionada.broadband.planBroadband.lstPromotions.isEmpty()  ? String.valueOf(ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).valid) : '0';
		solicBroadband.PromotionValue__c		= ofertaSelecionada.broadband.planBroadband.lstPromotions != null && !ofertaSelecionada.broadband.planBroadband.lstPromotions.isEmpty()  ? ofertaSelecionada.broadband.planBroadband.lstPromotions.get(0).discount : 0;
		solicBroadband.TotalValue__c			= ofertaSelecionada.broadband.totalValue;
		return solicBroadband;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo A LA CARTE com movimentação LATERAL
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAlaCarteBandaLargaLateral(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartOld = new Map<String, NBA_OfferComparator_CC.Additional>();
		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.broadband.addOptions.lstAdditionals) {
			if(alacarte.checked){
				mapAlacartOld.put(alacarte.id, alacarte);
			}
		}

		for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.broadband.addOptions.lstAdditionals) {
			Integer indexBLAdd = String.isNotBlank(alacarte.solicitationType) ? (alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
			String slTypeBLAdd = String.isNotBlank(alacarte.solicitationType) ? alacarte.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexBLAdd] : null;
			
			if(alacarte.checked && mapAlacartOld.containsKey( alacarte.id )){
				Solic_NBA__c solicBroadband			= new Solic_NBA__c();
				solicBroadband.ProductName__c		= alacarte.nameLegacy;
				solicBroadband.LegacyNameProduct__c	= String.isNotBlank(alacarte.nameLegacy) ? alacarte.nameLegacy : alacarte.label;
				solicBroadband.Message__c			= '';
				solicBroadband.Order__c				= pedido.Id;
				solicBroadband.Status__c			= null;
				solicBroadband.Movement__c			= NBA_Constants.MOVIMENTO_LATERAL;
				solicBroadband.ProductType__c		= NBA_Constants.BL_ADICIONAIS;
				solicBroadband.OfferType__c			= ofertaSelecionada.broadband.offerType;
				solicBroadband.ComboProfile__c		= ofertaSelecionada.broadband.comboProfile;
				solicBroadband.Family__c			= alacarte.familyName;
				solicBroadband.SolicitationType__c	= null;
				solicBroadband.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicBroadband.CurrentValue__c		= mapAlacartOld.get(alacarte.id).value;
				solicBroadband.Value__c				= alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty() ? alacarte.lstPromotions.get(0).value : alacarte.value;
				solicBroadband.PromotionValue__c	= alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty() ? alacarte.lstPromotions.get(0).discount : 0;
				solicBroadband.TotalValue__c		= alacarte.value;
				solicBroadband.QuantityPromoMonths__c	= ofertaSelecionada.broadband.additionalBroadband.lstPromotions.size() > 0 ? String.valueOf(ofertaSelecionada.broadband.additionalBroadband.lstPromotions[0].valid) : '';
				solicBroadband.QuantityPromoMonths__c	= alacarte.lstPromotions != null && !alacarte.lstPromotions.isEmpty() ? String.valueOf(alacarte.lstPromotions.get(0).valid) : '0';
						
				if(String.isNotBlank(alacarte.description)) {
					solicBroadband.PromotionName__c		= alacarte.description;
				}else{
					solicBroadband.PromotionName__c		= String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}
				lstSolicInsert.add( solicBroadband );
			}
		}
		return lstSolicInsert;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo A LA CARTE com movimentação AQUSIÇÃO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAlaCarteBandaLargaAquisicao(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartOld = new Map<String, NBA_OfferComparator_CC.Additional>();
		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.broadband.addOptions.lstAdditionals) {
			if(alacarte.checked){
				mapAlacartOld.put(alacarte.id, alacarte);
			}
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
				solicAlaCarteTV.LegacyNameProduct__c	= String.isNotBlank(alacarte.nameLegacy) ? alacarte.nameLegacy : alacarte.label;
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
						
				if (String.isNotBlank(alacarte.description)) {
					solicAlaCarteTV.PromotionName__c    = alacarte.description;
				} else {
					solicAlaCarteTV.PromotionName__c    = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}

				if(mapAlacartOld.containsKey(alacarte.id) && alacarte.technologyType != mapAlacartOld.get(alacarte.id).technologyType){
					solicAlaCarteTV.MainPoint__c		= produtoAntigo.tv[0].planTv.label;
					if(solicAlaCarteTV.MainPoint__c != null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
						solicAlaCarteTV.MainPoint__c	= NBA_Constants.ACESSO_VIRTUA;
					}
				}else {
					solicAlaCarteTV.MainPoint__c		= ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.nameLegacy : produtoAntigo.tv[0].planTv.label;
					if(solicAlaCarteTV.MainPoint__c != null && solicAlaCarteTV.MainPoint__c.equalsIgnoreCase(NBA_Constants.NAO_POSSUI)){
						solicAlaCarteTV.MainPoint__c	= NBA_Constants.ACESSO_VIRTUA;
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
	  --- Description: Método que retorna uma Lista de Solic do tipo BANDA LARGA E ADICIONAIS com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getBandaLargaCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		//CANCELAMENTO DO PRODUTO BANDA LARGA
		//CANCELAMENTO EM CASCATA DE ADICIONAIS DA BANDA LARGA
		Solic_NBA__c solicBandaLarga		= new Solic_NBA__c();
		solicBandaLarga.Order__c			= pedido.Id;
		solicBandaLarga.CurrentProduct__c	= produtoAntigo.broadband.planBroadband.label;
		solicBandaLarga.Status__c			= NBA_Constants.EM_ABERTO;
		solicBandaLarga.ProductType__c		= NBA_Constants.BL_ASSINATURA;
		solicBandaLarga.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
		solicBandaLarga.ComboProfile__c		= null;
		solicBandaLarga.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicBandaLarga.Fidelity__c			= produtoAntigo.broadband.planBroadband.fidelity.hasFidelity;
		solicBandaLarga.PenaltyPrice__c		= produtoAntigo.broadband.planBroadband.fidelity.penalty;
		solicBandaLarga.Value__c			= 0.00;
		solicBandaLarga.CurrentValue__c		= produtoAntigo.broadband.planBroadband.value;
		lstSolicInsert.add( solicBandaLarga );

		for(NBA_OfferComparator_CC.Additional alacarte : produtoAntigo.broadband.addOptions.lstAdditionals) {
			if(alacarte.checked) {
				Solic_NBA__c solicAlacarte			= new Solic_NBA__c();
				solicAlacarte.Order__c				= pedido.Id;
				solicAlacarte.CurrentProduct__c		= alacarte.label;
				solicAlacarte.Status__c				= NBA_Constants.EM_ABERTO;
				solicAlacarte.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicAlacarte.ProductType__c		= NBA_Constants.BL_ADICIONAIS;
				solicAlacarte.OfferType__c			= produtoAntigo.broadband.offerType;
				solicAlacarte.TechnologyType__c		= produtoAntigo.broadband.technology;
				solicAlacarte.ComboProfile__c		= null;
				solicAlacarte.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicAlacarte.Value__c				= 0.00;
				solicAlacarte.CurrentValue__c		= produtoAntigo.broadband.planBroadband.value;
				solicAlacarte.Message__c			= '';
				solicAlacarte.MainPoint__c			= ofertaSelecionada.broadband.planBroadband.nameLegacy != NBA_Constants.MOVIMENTO_MANTER ? ofertaSelecionada.broadband.planBroadband.nameLegacy : produtoAntigo.broadband.planBroadband.label;
				
				if(String.isNotBlank(alacarte.description)) {
					solicAlacarte.PromotionName__c	= alacarte.description;
				}else{
					solicAlacarte.PromotionName__c	= String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}
				lstSolicInsert.add( solicAlacarte );
			}
		}
		return lstSolicInsert;
	}

	public Solic_NBA__c getBandaLargaProdutoSuspensao(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		Solic_NBA__c solicBroadband			= new Solic_NBA__c();
		solicBroadband.CurrentProduct__c	= produtoAntigo.broadband.planBroadband.label;
		solicBroadband.ProductName__c		= ofertaSelecionada.broadband.planBroadband.nameLegacy;
		solicBroadband.LegacyNameProduct__c = ofertaSelecionada.broadband.planBroadband.label;
		solicBroadband.Message__c			= '';
		solicBroadband.Order__c				= pedido.Id;
		solicBroadband.Status__c			= NBA_Constants.EM_ABERTO;
		solicBroadband.ProductType__c		= NBA_Constants.BL_ASSINATURA;
		solicBroadband.Movement__c			= NBA_Constants.MOVIMENTO_SUSPENSO;
		solicBroadband.Family__c			= 'SUSPENSÃO';
		solicBroadband.SolicitationType__c	= NBA_Constants.TP_SOLIC_MOVIMENTACAO;
		solicBroadband.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicBroadband.Fidelity__c			= produtoAntigo.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.RenewFidelity__c		= ofertaSelecionada.broadband.planBroadband.fidelity.hasFidelity;
		solicBroadband.PenaltyPrice__c		= null;							
        solicBroadband.PaymentMethod__c		= ofertaSelecionada.temporarySuspension.taxValue != 0 ? 'Avista' : 'Isento';
		solicBroadband.FeePrice__c			= ofertaSelecionada.temporarySuspension.taxValue;
        solicBroadband.FeeType__c   		= NBA_Constants.MOVIMENTO_SUSPENSO;
		solicBroadband.CurrentValue__c		= produtoAntigo.broadband.planBroadband.value;
		solicBroadband.PointId__c			= produtoAntigo.broadband.planBroadband.pointId;
		solicBroadband.Value__c				= ofertaSelecionada.broadband.planBroadband.value;
		solicBroadband.TotalValue__c		= ofertaSelecionada.broadband.totalValue;
		solicBroadband.QuantityPromoMonths__c = ofertaSelecionada.temporarySuspension.period;
        solicBroadband.TechnologyType__c 	= 	ofertaSelecionada.broadband.planBroadband.label.contains('PON') ? 'GPON' : 'HFC';
        solicBroadband.ProductID__c 		=	ofertaSelecionada.broadband.planBroadband.key;
		return solicBroadband;
	}


	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo ADICIONAIS DE BANDA LARGA com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	public List<Solic_NBA__c> getAdicionaisBandaLargaCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido, List<Solic_NBA__c> lstSolicInsert){
		Map<String, NBA_OfferComparator_CC.Additional> mapAlacartAtual = new Map<String, NBA_OfferComparator_CC.Additional>();
		for (NBA_OfferComparator_CC.Additional add : produtoAntigo.broadband.addOptions.lstAdditionals) {
			if(add.checked){
				mapAlacartAtual.put(add.id, add);
			}
		}
                         
        for(NBA_OfferComparator_CC.Additional alacarte : ofertaSelecionada.broadband.addOptions.lstAdditionals) {
            if(!alacarte.checked && mapAlacartAtual.containsKey(alacarte.id)){
				Solic_NBA__c solicAlacarteBandaLarga			= new Solic_NBA__c();
				solicAlacarteBandaLarga.ProductName__c			= null;
				solicAlacarteBandaLarga.LegacyNameProduct__c 	= String.isNotBlank(alacarte.nameLegacy) ? alacarte.nameLegacy : alacarte.label;
				solicAlacarteBandaLarga.Message__c				= '';
				solicAlacarteBandaLarga.Order__c				= pedido.Id;
				solicAlacarteBandaLarga.Status__c				= null;
				solicAlacarteBandaLarga.CurrentProduct__c		= mapAlacartAtual.containsKey(alacarte.label) ? mapAlacartAtual.get(alacarte.label).label : alacarte.label;
				solicAlacarteBandaLarga.Movement__c				= NBA_Constants.MOVIMENTO_CANCELAMENTO;
				solicAlacarteBandaLarga.ProductType__c			= NBA_Constants.BL_ADICIONAIS;
				solicAlacarteBandaLarga.OfferType__c			= ofertaSelecionada.broadband.offerType;
				solicAlacarteBandaLarga.ComboProfile__c			= ofertaSelecionada.broadband.comboProfile;
				solicAlacarteBandaLarga.Family__c				= alacarte.familyName;
				solicAlacarteBandaLarga.SolicitationType__c		= null;
				solicAlacarteBandaLarga.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
				solicAlacarteBandaLarga.CurrentValue__c			= alacarte.value;
				solicAlacarteBandaLarga.Value__c				= 0.00;
				
				if(String.isNotBlank(alacarte.description)) {
					solicAlacarteBandaLarga.PromotionName__c    = alacarte.description;
				}else {
					solicAlacarteBandaLarga.PromotionName__c    = String.isNotBlank(alacarte.promoSelected) ? alacarte.lstPromotions[Integer.valueOf(alacarte.promoSelected)].description : null;
				}

				lstSolicInsert.add( solicAlacarteBandaLarga );
            }
        }
		return lstSolicInsert;
	}
}