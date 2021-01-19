/*----------------------------------------------------------  
  EMPRESA   - Accenture
  DESCRICÃO - classe responsável pelo controle do produto NET FONE
  Autor     - Diego Silva
  Versão    - 1.0
  ------------------------------------------------------------*/
public class NBA_ControllerPhone  {
	
	private static NBA_ControllerPhone instance;

	public static NBA_ControllerPhone getInstance(){
		if(instance == null)
			instance = new NBA_ControllerPhone();
		return instance;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo NET FONE, Oriunda da Oferta selecionada
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getNetFoneOfertaSelecionada(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		Integer indexFN				= String.isNotBlank(ofertaSelecionada.phone.solicitationType) ? (ofertaSelecionada.phone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
		String slType				= String.isNotBlank(ofertaSelecionada.phone.solicitationType) ? ofertaSelecionada.phone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexFN] : null;

		Boolean acquisition			= ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_AQUISICAO;
		Boolean downgrade			= ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_DOWNGRADE;
		Boolean upgrade 			= ofertaSelecionada.movimentTv == NBA_Constants.MOVIMENTO_UPGRADE;
        Boolean upgradeOrDowngrade	= ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_UPGRADE || downgrade;
		Boolean keep				= ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_MANTIDO || ofertaSelecionada.movimentPhone == NBA_Constants.MOVIMENTO_LATERAL;

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
            feeType							= ofertaSelecionada.movimentPhone;
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
			productName			= ofertaSelecionada.phone.planPhone.label;
			productLegacyName	= ofertaSelecionada.phone.planPhone.nameLegacy;
			currentProductName	= produtoAntigo.phone.planPhone.label;
		} else if (acquisition) {
			productName			= ofertaSelecionada.phone.planPhone.label;
			productLegacyName	= ofertaSelecionada.phone.planPhone.nameLegacy;
		} else if (keep && String.isBlank(slType)) {
			productName			= produtoAntigo.phone.planPhone.nameLegacy;
			productLegacyName	= produtoAntigo.phone.planPhone.label;
			currentProductName	= produtoAntigo.phone.planPhone.label;
		}

		Solic_NBA__c solicPhone				= new Solic_NBA__c();
		solicPhone.CurrentProduct__c		= currentProductName;
		solicPhone.ProductName__c			= productName;
		solicPhone.LegacyNameProduct__c		= productLegacyName;
		solicPhone.Message__c				= '';
		solicPhone.Order__c					= pedido.Id;
		solicPhone.Status__c				= keep && String.isBlank(slType) ? null : NBA_Constants.EM_ABERTO;
		solicPhone.ProductType__c			= NBA_Constants.NET_FONE;
		solicPhone.Movement__c				= ofertaSelecionada.movimentPhone;
		solicPhone.OfferType__c				= ofertaSelecionada.phone.offerType;
		solicPhone.ComboProfile__c			= ofertaSelecionada.phone.comboProfile;
		solicPhone.Family__c				= ofertaSelecionada.phone.familyName;
		solicPhone.MainPoint__c				= produtoAntigo.tv[0].planTv.typeAcessoVirtua;
        solicPhone.PromotionName__c			= ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ? ofertaSelecionada.phone.planPhone.lstPromotions[0].description : '';
		solicPhone.SolicitationType__c		= slType;
		solicPhone.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicPhone.Fidelity__c				= produtoAntigo.phone.planPhone.fidelity.hasFidelity;
		solicPhone.RenewFidelity__c			= ofertaSelecionada.phone.planPhone.fidelity.hasFidelity;
		solicPhone.PenaltyPrice__c			= null;
		solicPhone.QuantityPromoMonths__c	= ofertaSelecionada.phone.planPhone.lstPromotions != null && !ofertaSelecionada.phone.planPhone.lstPromotions.isEmpty() ? String.valueOf(ofertaSelecionada.phone.planPhone.lstPromotions.get(0).valid) : '0';
		solicPhone.PromotionValue__c		= ofertaSelecionada.phone.planPhone.lstPromotions != null && !ofertaSelecionada.phone.planPhone.lstPromotions.isEmpty() ? ofertaSelecionada.phone.planPhone.lstPromotions.get(0).discount : 0;
		solicPhone.TotalValue__c			= ofertaSelecionada.phone.totalValue;
        solicPhone.pointId__c				= keep && String.isBlank(slType) ? null : produtoAntigo.phone.planPhone.pointId;
                
        if(keep || upgradeOrDowngrade){
            solicPhone.PaymentMethod__c		= feeLabel == NBA_Constants.NET_FONE ? ofertaSelecionada.paymentMethodUpgrade : null;
			solicPhone.FeePrice__c			= feeLabel == NBA_Constants.NET_FONE ? feePrice : null;
			solicPhone.FeeType__c 			= feeLabel == NBA_Constants.NET_FONE ? feeType : null;
        }else {
            solicPhone.FeeType__c 			= feeLabelAdesao == NBA_Constants.NET_FONE ? feeTypeAdesao : null;
            solicPhone.FeePrice__c			= feeLabelAdesao == NBA_Constants.NET_FONE ? feePriceAdesao : null;
            solicPhone.PaymentMethod__c		= feeLabelAdesao == NBA_Constants.NET_FONE ? ofertaSelecionada.paymentMethodMembership : null;
        }

		if(acquisition){
			solicPhone.CurrentValue__c		= 0.00;
			solicPhone.Value__c				= ofertaSelecionada.phone.planPhone.value;
		}else {
            solicPhone.CurrentValue__c		= produtoAntigo.phone.planPhone.value;
            solicPhone.Value__c				= ofertaSelecionada.phone.planPhone.value;
        }
		return solicPhone;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma solic do tipo NET FONE, Oriundas da Posse Atual ou Produto Atual
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getNetFoneProdutoAtual(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido){
		Solic_NBA__c solicPhone				= new Solic_NBA__c();
		if(ofertaSelecionada.phone.planPhone != null && ofertaSelecionada.phone.planPhone.label != NBA_Constants.NAO_POSSUI && String.isBlank(ofertaSelecionada.movimentPhone)){
			//TAXA
			NBA_OfferComparator_CC.Fee offerFee = ofertaSelecionada.lstUpgradeFee.size() > 0 ? ofertaSelecionada.lstUpgradeFee[0] : null;
			Decimal feePrice					= offerFee != null ? offerFee.value : null;
			String feeLabel						= offerFee != null ? offerFee.label : null;
			String feeType 						= NBA_Constants.MOVIMENTO_MANTIDO;
                
			String productName					= produtoAntigo.phone.planPhone.nameLegacy;
			String productLegacyName			= produtoAntigo.phone.planPhone.label;
			String currentProductName			= produtoAntigo.phone.planPhone.label;
				
			solicPhone.CurrentProduct__c		= produtoAntigo.phone.planPhone.label;
			solicPhone.ProductName__c			= produtoAntigo.phone.planPhone.nameLegacy;
			solicPhone.LegacyNameProduct__c		= produtoAntigo.phone.planPhone.label;
			solicPhone.Message__c				= '';
			solicPhone.Order__c					= pedido.Id;
			solicPhone.Status__c				= null;
			solicPhone.ProductType__c			= NBA_Constants.NET_FONE;
			solicPhone.Movement__c				= NBA_Constants.MOVIMENTO_LATERAL;
			solicPhone.OfferType__c				= ofertaSelecionada.phone.offerType;
			solicPhone.ComboProfile__c			= ofertaSelecionada.phone.comboProfile;
			solicPhone.Family__c				= ofertaSelecionada.phone.familyName;
			solicPhone.PromotionName__c			= ofertaSelecionada.phone.planPhone.lstPromotions.size() > 0 ? ofertaSelecionada.phone.planPhone.lstPromotions[0].description : '';
			solicPhone.SolicitationType__c		= null;
			solicPhone.SpotType__c				= NBA_Constants.SPOT_TYPE_SOLIC_PO;
			solicPhone.Fidelity__c				= produtoAntigo.phone.planPhone.fidelity.hasFidelity;
			solicPhone.RenewFidelity__c			= ofertaSelecionada.phone.planPhone.fidelity.hasFidelity;
			solicPhone.PenaltyPrice__c			= null;
			solicPhone.PaymentMethod__c			= feeLabel == NBA_Constants.NET_FONE ? ofertaSelecionada.paymentMethodUpgrade : null;
			solicPhone.FeePrice__c				= feeLabel == NBA_Constants.NET_FONE ? feePrice : null;
			solicPhone.FeeType__c 				= feePrice > 0 ? feeType : null;
			solicPhone.CurrentValue__c			= produtoAntigo.phone.planPhone.value;
			solicPhone.Value__c					= ofertaSelecionada.phone.planPhone.value;
			solicPhone.QuantityPromoMonths__c	= ofertaSelecionada.phone.planPhone.lstPromotions != null && !ofertaSelecionada.phone.planPhone.lstPromotions.isEmpty() ? String.valueOf(ofertaSelecionada.phone.planPhone.lstPromotions.get(0).valid) : '0';
			solicPhone.PromotionValue__c		= ofertaSelecionada.phone.planPhone.lstPromotions != null && !ofertaSelecionada.phone.planPhone.lstPromotions.isEmpty() ? ofertaSelecionada.phone.planPhone.lstPromotions.get(0).discount : 0;
			solicPhone.TotalValue__c			= ofertaSelecionada.phone.totalValue;
		}
		return solicPhone;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Creation Date: 01/10/2019
	  --- Author: Diego Silva
	  --- Description: Método que retorna uma Lista de Solic do tipo NET FONE com movimentação CANCELAMENTO
	  -------------------------------------------------------------------------------------------------------*/
	public Solic_NBA__c getNetFoneCancelamento(NBA_OfferComparator_CC.Offer ofertaSelecionada, NBA_OfferComparator_CC.Offer produtoAntigo, Order pedido ){
		//CANCELAMENTO DO PRODUTO NET FONE
		Solic_NBA__c solicPhone			= new Solic_NBA__c();
		solicPhone.CurrentProduct__c	= produtoAntigo.phone.planPhone.label;
		solicPhone.Order__c				= pedido.Id;
		solicPhone.Status__c			= NBA_Constants.EM_ABERTO;
		solicPhone.ProductType__c		= NBA_Constants.NET_FONE;
		solicPhone.Movement__c			= NBA_Constants.MOVIMENTO_CANCELAMENTO;
		solicPhone.SpotType__c			= NBA_Constants.SPOT_TYPE_SOLIC_PO;
		solicPhone.Fidelity__c			= produtoAntigo.phone.planPhone.fidelity.hasFidelity;
		solicPhone.PenaltyPrice__c		= produtoAntigo.phone.planPhone.fidelity.penalty;
		solicPhone.ComboProfile__c		= null;
		solicPhone.Value__c				= 0.00;
		solicPhone.CurrentValue__c		= produtoAntigo.phone.planPhone.value;
		return solicPhone;
	}
}