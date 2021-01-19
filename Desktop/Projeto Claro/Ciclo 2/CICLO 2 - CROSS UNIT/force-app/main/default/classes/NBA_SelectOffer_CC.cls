/*--------------------------------------------------------------------------------------------
   --- Company: Accenture Brasil
   --- Creation Date: 20/01/2018
   --- Author: Vladson Araujo
   --- Description: Classe que representa o controlador do componente de Ofertas
   ---------------------------------------------------------------------------------------------*/
public with sharing class NBA_SelectOffer_CC { 

private static final Id recordTypeIdFixo                                = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECFixo').getRecordTypeId();
private static final Id recordTypeIdInternetFixa                = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetFixa').getRecordTypeId();
private static final Id recordTypeIdMovel                               = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId();
private static final Id recordTypeIdInternetMovel               = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetMovel').getRecordTypeId();
private static final Id recordTypeIdMovelPreControle    = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();
private static final Id recordTypeIdTv                                  = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECTV').getRecordTypeId();
private static final Id recordTypeIdNBAOffer                    = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();

@AuraEnabled
	public static void saveClickAllOffers(String recordId){
		update new Case(Id=recordId, CallResultIndt__c = 'Com Oferta');
	}

@AuraEnabled
public static void endCase(id recordId, String oferta, String produtoAtual, date dateSchedule, String descriptionSchedule, String isencoes, String produtoAntigo, String subscriberId, String offerValidationRequest) {
	if(String.isBlank(isencoes) || isencoes == null ) {
		isencoes = '[{"label":"Sem Isenção","preco":"00,00","tipo":"DESC","checked":false},{"label":"Sem Isenção","preco":"00,00","tipo":"DESC","checked":false},{"label":"Sem Isenção","preco":"00,00","tipo":"DESC","checked":false},{"label":"Sem Isenção","preco":"00,00","tipo":"DESC","checked":false}]';
	}

	System.debug('Diego Silva - Oferta --> ' + oferta);
	System.debug('Diego Silva - Posse --> ' + produtoAtual);
	System.debug('Diego Silva - Produto Antigo --> ' + produtoAntigo);

	List<Case> lstCase                                                                      = [SELECT id, contractNumber__r.AccountId, contractNumber__c, Order__c FROM CASE where id = :recordId];
	NBA_OfferComparator_CC.Offer ofertaSelecionada          = (NBA_OfferComparator_CC.Offer) JSON.deserialize(oferta, NBA_OfferComparator_CC.Offer.class);
	NBA_OfferComparator_CC.Offer posseAtual                         = (NBA_OfferComparator_CC.Offer) JSON.deserialize(produtoAtual, NBA_OfferComparator_CC.Offer.class);
	NBA_OfferComparator_CC.Offer oldProduct                         = (NBA_OfferComparator_CC.Offer) JSON.deserialize(produtoAntigo, NBA_OfferComparator_CC.Offer.class);
	List<NBA_OfferComparator_CC.IsencaoTaxa> lstTaxas       = (List<NBA_OfferComparator_CC.IsencaoTaxa>) JSON.deserialize(isencoes, List<NBA_OfferComparator_CC.IsencaoTaxa>.class);

	Map<String, NBA_OfferComparator_CC.Additional> mapAlarcarteLateral = new Map<String, NBA_OfferComparator_CC.Additional>();

	if (!lstCase.isEmpty()) {
		Case c                  = lstCase[0];
		c.Exceptions__c = ofertaSelecionada.free ? NBA_Constants.ISENTO : null;

		Order pedido = new Order();

		c.CallResultIndt__c = 'Com Oferta';
		if (c.Order__c != null) {
			pedido.Id = c.Order__c;
			//Limpando eventuais solics anteriores, antes de criar novas
			delete [SELECT Id FROM Solic_NBA__c WHERE Order__c = :pedido.Id AND Status__c IN (null, :NBA_Constants.EM_ABERTO)];
		}

		pedido.RTDMOfferId__c                           = ofertaSelecionada.key;
		pedido.SASOfferProfile__c                       = ofertaSelecionada.offerProfile;
		pedido.FeeAddValuePaymentForm__c        = ofertaSelecionada.paymentMethodUpgrade;
		pedido.AddFeeTotal__c                           = ofertaSelecionada.vlMembershipFee == null ? 0 : Decimal.valueOf(ofertaSelecionada.vlMembershipFee);
		pedido.UpgradeTaxTotal__c                       = ofertaSelecionada.vlUpgradeFee == null ? 0 : Decimal.valueOf(ofertaSelecionada.vlUpgradeFee);
		pedido.CurrentValueTotal__c                     = posseAtual.totalValue;
		pedido.Total_Proposed_Value__c          = ofertaSelecionada.totalValue;
		pedido.MobileMovement__c                        = getProductMovement(ofertaSelecionada.movimentMobile, ofertaSelecionada.mobile.solicitationType, oldProduct.mobile.planMobile.label);
		pedido.VirtuaMovement__c                        = getProductMovement(ofertaSelecionada.movimentBroadband, ofertaSelecionada.broadband.solicitationType, oldProduct.broadband.planBroadband.label);
		pedido.TVMovement__c                            = getProductMovement(ofertaSelecionada.movimentTv, ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType, oldProduct.tv[0].planTv.label);
		pedido.NETFoneMovement__c                       = getProductMovement(ofertaSelecionada.movimentPhone, ofertaSelecionada.phone.solicitationType, oldProduct.phone.planPhone.label);
		pedido.AccountId                                        = c.contractNumber__r.AccountId;
		pedido.EffectiveDate                            = Date.today();
		pedido.ContractId                                       = c.ContractNumber__c;
		pedido.Status                                           = 'Draft';
		pedido.RecordTypeId                                     = recordTypeIdNBAOffer;
		pedido.SchedulingTime__c                        = descriptionSchedule != null ? descriptionSchedule : '';
		pedido.Pointing__c								= (ofertaSelecionada.incentive != null && String.isNotBlank(ofertaSelecionada.incentive)) ? Decimal.valueOf(ofertaSelecionada.incentive) : 0;

		if(dateSchedule != null) {
			pedido.SchedulingDate__c                = dateSchedule;
		}

		if(!lstTaxas.isEmpty()) {
			String taxaTypeFormated                 = '';
			String taxaValueFormated                = '';
			List<NBA_OfferComparator_CC.IsencaoTaxa> checkedTaxas = new List<NBA_OfferComparator_CC.IsencaoTaxa> ();

			for (NBA_OfferComparator_CC.IsencaoTaxa taxa : lstTaxas) {
				if (taxa.checked) {
					checkedTaxas.add(taxa);
				}
			}

			for (Integer i = 0; i<checkedTaxas.size(); i++) {
				taxaTypeFormated                += lstTaxas[i].tipo;
				taxaValueFormated               += lstTaxas[i].preco;
				if (i<checkedTaxas.size() - 1) {
					taxaTypeFormated        += ' | ';
					taxaValueFormated       += ' | ';
				}
			}
			pedido.TaxExemptionType__c  = taxaTypeFormated;
			pedido.TaxExemptionValue__c = taxaValueFormated;
		}
		pedido.subscriberId__c = subscriberId;
		pedido.OfferValidationRequest__c = offerValidationRequest;
		Database.upsert( pedido );
		c.Order__c      = pedido.Id;

		List<Solic_NBA__c> lstSolic     = new List<Solic_NBA__c> ();

		//TV PACOTE - OFERTA SELECIONADA
		//AQUISIÇÃO, CANCELAMENTO E MUDANÇA DE PACOTE ORIGINADAS NA OFERTA.
		if((ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label != NBA_Constants.NAO_POSSUI && String.isNotBlank(ofertaSelecionada.movimentTv))) {
			lstSolic.add( NBA_ControllerTvPacote.getInstance().getTvPacoteOfertaSelecionada( ofertaSelecionada, oldProduct, pedido ) );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAlaCarteTvAquisicao( ofertaSelecionada, oldProduct, pedido, lstSolic, true );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAlaCarteTvLateral( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvAquisicao( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvLateral( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvMudancaPacote( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAdicionaisTvCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}
		//TV PACOTE - POSSE ATUAL | PRODUTO ATUAL
		//AQUISIÇÃO, CANCELAMENTO E LATERAL ORIGINADAS NA POSSE ATUAL / PRODUTO ATUAL.
		if((ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label != NBA_Constants.NAO_POSSUI && String.isBlank(ofertaSelecionada.movimentTv))) {
			lstSolic.add( NBA_ControllerTvPacote.getInstance().getTvPacoteProdutoAtual( ofertaSelecionada, oldProduct, pedido ) );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAlaCarteTvAquisicao( ofertaSelecionada, oldProduct, pedido, lstSolic, false );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAlaCarteTvLateral( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvAquisicao( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvLateral( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getPontoOpcionalTvMudancaPacote( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerTvPacote.getInstance().getAdicionaisTvCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}
		//TV PACOTE - CANCELAMENTO
		//CANCELAMENTO EM CASCATA DOS ADICIONAIS DE TV (A LA CARTE E PONTO OPCIONAL)
		if(oldProduct.tv[0].planTv != null && oldProduct.tv[0].planTv.label != NBA_Constants.NAO_POSSUI && oldProduct.tv[0].planTv.label != NBA_Constants.ACESSO_VIRTUA && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv != null && ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label == NBA_Constants.NAO_POSSUI) {
			lstSolic = NBA_ControllerTvPacote.getInstance().getTvCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}

		//BANDA LARGA - OFERTA SELECIONADA
		//AQUISIÇÃO, CANCELAMENTO E MUDANÇA DE PACOTE ORIGINADAS NA OFERTA.
		if((ofertaSelecionada.broadband.planBroadband != null && ofertaSelecionada.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && String.isNotBlank(ofertaSelecionada.movimentBroadband))) {
			lstSolic.add( NBA_ControllerBroadBand.getInstance().getBandaLargaOfertaSelecionada( ofertaSelecionada, oldProduct, pedido ) );
			lstSolic = NBA_ControllerBroadBand.getInstance().getAdicionaisBandaLargaCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}
		//BANDA LARGA - POSSE ATUAL | PRODUTO ATUAL
		//AQUISIÇÃO, CANCELAMENTO E LATERAL ORIGINADAS NA POSSE ATUAL / PRODUTO ATUAL.
		if((ofertaSelecionada.broadband.planBroadband != null && ofertaSelecionada.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && String.isBlank(ofertaSelecionada.movimentBroadband))) {
			lstSolic.add( NBA_ControllerBroadBand.getInstance().getBandaLargaProdutoAtual( ofertaSelecionada, oldProduct, pedido ) );
			lstSolic = NBA_ControllerBroadBand.getInstance().getAdicionaisBandaLargaCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}
		//BANDA LARGA - CANCELAMENTO
		//CANCELAMENTO EM CASCATA DOS ADICIONAIS DE BANDA LARGA (A LA CARTE E PONTO OPCIONAL)
		if(oldProduct.broadband.planBroadband != null && oldProduct.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && oldProduct.broadband.planBroadband.label != NBA_Constants.ACESSO_VIRTUA && ofertaSelecionada.broadband.planBroadband != null && ofertaSelecionada.broadband.planBroadband.label == NBA_Constants.NAO_POSSUI) {
			lstSolic = NBA_ControllerBroadBand.getInstance().getBandaLargaCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
		}

		//NET FONE - OFERTA SELECIONADA
		if(ofertaSelecionada.phone.planPhone != null && ofertaSelecionada.phone.planPhone.label != NBA_Constants.NAO_POSSUI && String.isNotBlank(ofertaSelecionada.movimentPhone)) {
			lstSolic.add( NBA_ControllerPhone.getInstance().getNetFoneOfertaSelecionada( ofertaSelecionada, oldProduct, pedido ) );
		}
		//NET FONE - POSSE ATUAL | PRODUTO ATUAL
		//AQUISIÇÃO, CANCELAMENTO E LATERAL ORIGINADAS NA POSSE ATUAL / PRODUTO ATUAL.
		if(ofertaSelecionada.phone.planPhone != null && ofertaSelecionada.phone.planPhone.label != NBA_Constants.NAO_POSSUI && String.isBlank(ofertaSelecionada.movimentPhone)) {
			lstSolic.add( NBA_ControllerPhone.getInstance().getNetFoneProdutoAtual( ofertaSelecionada, oldProduct, pedido ) );
		}
		//NET FONE - CANCELAMENTO
		//CANCELAMENTO NET FONE
		if(oldProduct.phone.planPhone != null && oldProduct.phone.planPhone.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.phone.planPhone != null && ofertaSelecionada.phone.planPhone.label == NBA_Constants.NAO_POSSUI) {
			lstSolic.add( NBA_ControllerPhone.getInstance().getNetFoneCancelamento( ofertaSelecionada, oldProduct, pedido ) );
		}

		//MOVEL - OFERTA SELECIONADA
		if((ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && String.isNotBlank(ofertaSelecionada.movimentMobile))) {
			lstSolic = NBA_ControllerMovel.getInstance().getMovelOfertaSelecionada(ofertaSelecionada, oldProduct, pedido, lstSolic);
			lstSolic = NBA_ControllerMovel.getInstance().getDependenteMovel(ofertaSelecionada, oldProduct, posseAtual, pedido, lstSolic);
			lstSolic = NBA_ControllerMovel.getInstance().getDependenteMovelCancelamento(ofertaSelecionada, oldProduct, posseAtual, pedido, lstSolic);
		}
		//MOVEL - PRODUTO ATUAL
		if(ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && (ofertaSelecionada.movimentMobile == null || String.isBlank(ofertaSelecionada.movimentMobile))) {         //LATERAL SEM MOVIMENTAÇÃO (OBS:CENÁRIO DE POSSE ATUAL)
			lstSolic = NBA_ControllerMovel.getInstance().getMovelProdutoAtual(ofertaSelecionada, oldProduct, pedido, lstSolic);
			lstSolic = NBA_ControllerMovel.getInstance().getDependenteMovel(ofertaSelecionada, oldProduct, posseAtual, pedido, lstSolic);
			lstSolic = NBA_ControllerMovel.getInstance().getDependenteMovelCancelamento(ofertaSelecionada, oldProduct, posseAtual, pedido, lstSolic);
		}
		//MOVEL - CANCELAMENTO
		//CANCELAMENTO MOVEL
		if(oldProduct.mobile.planMobile != null && oldProduct.mobile.planMobile.label != NBA_Constants.NAO_POSSUI && ofertaSelecionada.mobile.planMobile != null && ofertaSelecionada.mobile.planMobile.label == NBA_Constants.NAO_POSSUI) {
			lstSolic = NBA_ControllerMovel.getInstance().getMovelCancelamento( ofertaSelecionada, oldProduct, pedido, lstSolic );
			lstSolic = NBA_ControllerMovel.getInstance().getDependenteMovelCancelamento(ofertaSelecionada, oldProduct, posseAtual, pedido, lstSolic);
		}

		Map<String, String> mapProductType      = new Map<String, String>();
		Boolean isHasTvPacote                           = false;
		Boolean isHasPhone                                      = false;
		Boolean isHasBroadBand                          = false;
		Boolean isMovimentMobile                        = false;

		for(Solic_NBA__c s : lstSolic) {
			if(s.ProductType__c != null && String.isNotBlank(s.ProductType__c) && s.Movement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO) {
				if(s.ProductType__c == NBA_Constants.TV_PACOTE) {
					mapProductType.put('PTV', 'PTV');
				}
				if(s.ProductType__c == NBA_Constants.ACESSO_VIRTUA || s.ProductType__c == NBA_Constants.BL_ASSINATURA) {
					mapProductType.put('VIRTUA', 'VIRTUA');
				}
				if(s.ProductType__c == NBA_Constants.NET_FONE) {
					mapProductType.put('FONE', 'FONE');
				}
				if(s.ProductType__c == NBA_Constants.MOVEL_ASSINATURA_RPA) {
					mapProductType.put('MOVEL', 'CELULAR');
				}
			}else if(s.Movement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO && s.ProductType__c != null && String.isNotBlank( s.ProductType__c ) && s.ProductType__c == NBA_Constants.TV_PACOTE) {
				isHasTvPacote   = true;
			}else if(s.Movement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO && s.ProductType__c != null && String.isNotBlank( s.ProductType__c ) && s.ProductType__c == NBA_Constants.NET_FONE) {
				isHasPhone              = true;
			}else if(s.Movement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO && s.ProductType__c != null && String.isNotBlank( s.ProductType__c ) && s.ProductType__c == NBA_Constants.BL_ASSINATURA) {
				isHasBroadBand  = true;
			}

			if(s.ProductType__c != null && String.isNotBlank(s.ProductType__c) && s.ProductType__c == NBA_Constants.MOVEL_ASSINATURA_RPA && s.Movement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO) {
				isMovimentMobile = true;
			}
		}
		// Remove cancelamentos de TV (PP/PO) quando houver BL na seleção  
		Boolean temBL=false;
		for(Solic_NBA__c solic : lstSolic)
			if(solic.ProductType__c==NBA_Constants.BL_ASSINATURA)
				temBL=true;
		if(temBL)
			for(Integer index=lstSolic.size()-1 ; index>=0 ; index--)
				if((lstSolic[index].ProductType__c==NBA_Constants.TV_PACOTE || lstSolic[index].ProductType__c==NBA_Constants.TV_PONTOS_ADICIONAIS) && lstSolic[index].Movement__c==NBA_Constants.MOVIMENTO_CANCELAMENTO)
					lstSolic.remove(index);

		//Remove os movimentos caracterizados como LATERAL, mas que equivalem ao MANTER
		for (Integer i = (lstSolic.size() - 1) ; i >= 0 ; i--) {
			Solic_NBA__c solic = lstSolic[i];
			if (solic.Movement__c == NBA_Constants.MOVIMENTO_LATERAL && 
				String.isBlank(solic.SolicitationType__c) &&
				String.isBlank(solic.Status__c)) {
				lstSolic.remove(i);
			}
		} 

		if(!mapProductType.containsKey( NBA_Constants.TV_PACOTE )) {
			isHasTvPacote   = true;
		}else if(!mapProductType.containsKey( NBA_Constants.NET_FONE )) {
			isHasPhone              = true;
		}else if(!mapProductType.containsKey( NBA_Constants.BL_ASSINATURA )) {
			isHasBroadBand  = true;
		}


		String comboProfile = 'PTV';
		for(String key : mapProductType.keySet()) {
			if(key != 'PTV') {
				comboProfile += ' + ' +  mapProductType.get( key );
			}
		}

		if(isHasBroadBand && isHasPhone && isHasTvPacote && isMovimentMobile) {
			comboProfile = 'CELULAR';
		}

		pedido.OwnershipProfile__c      = comboProfile;
		pedido.OrderCase__c             = c.Id;

		update pedido;

		insert lstSolic;
		update c;
	}
}
	
	/**
	* ──────────────────────────────────────────────────────────────────────────────────────────────────
	* @author         Diego Silva   <diego.henrique.silva@accenture.com> | <diego.h.n.silva@gmail.com>
	* @version        1.0
	* @created        2020-01-04
	* @description	  Método para encerramento de caso com analise de crédito REPROVADA
	* ──────────────────────────────────────────────────────────────────────────────────────────────────
	*/
	@AuraEnabled
	public static void encerramentoCaso(id recordId, Boolean isRetencao) { 
		List<Case> lstCase				= [SELECT Id, ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c, BLN1Result__c, BLN2Result__c, BLN3Result__c, MobileN1Result__c, MobileN2Result__c, MobileN3Result__c, PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, Time_of_Service__c, TVN1Result__c, TVN2Result__c, TVN3Result__c FROM Case where id = :recordId];
		Case caso						= lstCase[0];
		caso.Time_of_Service__c			= NBA_Constants.ENCERRAMENTO;
		caso.CallResultIndt__c          = 'Com Ação';
		caso							= updateValuesAnaliseCredito(caso, isRetencao);
		Database.SaveResult sv			= Database.update(caso);
	}

	/**
	* ──────────────────────────────────────────────────────────────────────────────────────────────────
	* @author         Diego Silva   <diego.henrique.silva@accenture.com> | <diego.h.n.silva@gmail.com>
	* @version        1.0
	* @created        2020-01-04
	* @description	  Método para atualizar valores de tabulação quando analise de crédito == REPROVADA
	* ──────────────────────────────────────────────────────────────────────────────────────────────────
	*/
	@TestVisible
	private static Case updateValuesAnaliseCredito(Case caso, Boolean isRetencao){
		if(isRetencao){
			caso.TVN1Result__c		= NBA_Constants.INFORMACOES;
			caso.TVN2Result__c		= NBA_Constants.CREDITO_REPROVADO;
			caso.TVN3Result__c		= NBA_Constants.RESULT_N3_NENHUM;

			caso.BLN1Result__c		= NBA_Constants.INFORMACOES;
			caso.BLN2Result__c		= NBA_Constants.CREDITO_REPROVADO;
			caso.BLN3Result__c		= NBA_Constants.RESULT_N3_NENHUM;

			caso.PhoneN1Result__c	= NBA_Constants.INFORMACOES;
			caso.PhoneN2Result__c	= NBA_Constants.CREDITO_REPROVADO;
			caso.PhoneN3Result__c	= NBA_Constants.RESULT_N3_NENHUM;

			caso.MobileN1Result__c	= NBA_Constants.INFORMACOES;
			caso.MobileN2Result__c	= NBA_Constants.CREDITO_REPROVADO;
			caso.MobileN3Result__c	= NBA_Constants.RESULT_N3_NENHUM;
		}else {
			caso.TVN1Result__c		= NBA_Constants.IMPRODUTIVO;
			caso.TVN2Result__c		= NBA_Constants.CREDITO_REPROVADO;
			caso.TVN3Result__c		= NBA_Constants.RESULT_N3_NENHUM;

			caso.BLN1Result__c		= NBA_Constants.IMPRODUTIVO;
			caso.BLN2Result__c		= NBA_Constants.CREDITO_REPROVADO;
			caso.BLN3Result__c		= NBA_Constants.RESULT_N3_NENHUM;

			caso.PhoneN1Result__c	= NBA_Constants.IMPRODUTIVO;
			caso.PhoneN2Result__c	= NBA_Constants.CREDITO_REPROVADO;
			caso.PhoneN3Result__c	= NBA_Constants.RESULT_N3_NENHUM;

			caso.MobileN1Result__c	= NBA_Constants.IMPRODUTIVO;
			caso.MobileN2Result__c	= NBA_Constants.CREDITO_REPROVADO;
			caso.MobileN3Result__c	= NBA_Constants.RESULT_N3_NENHUM;
		}
		return caso;
	}

@AuraEnabled
public static void updateStage(id recordId, String exceptions) {
	List<Case> casos = [
		SELECT 	Id, Time_of_Service__c, Exceptions__c,
				TVN1Result__c, TVN2Result__c, TVN3Result__c,
				PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, 
				MobileN1Result__c, MobileN2Result__c, MobileN3Result__c, 
				BLN1Result__c, BLN2Result__c, BLN3Result__c, 
				ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c 
		FROM 	Case 
		WHERE 	id = :recordId
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
	
		caso.Exceptions__c = (exceptions!='' ? exceptions : null);
	
		caso.Time_of_Service__c = 'Encerramento do atendimento';
		
		update caso;
	}
}

@AuraEnabled
public static Contract consultContract(id recordId) {
	List<Case> lstCase      = [SELECT Id, Time_of_Service__c, ContractNumber__c FROM Case where id = :recordId];
	Case a                          = lstCase[0];
	Contract cont           = [SElECT Id, PaymentMethod__c, BillDeliveryMethod__c FROM Contract Where id = :a.ContractNumber__c];
	return cont;
}

@AuraEnabled
public static NBA_SelectOffer_CC.NavegacaoMovel consultContract2(id recordId) {
	NBA_SelectOffer_CC.NavegacaoMovel result        = new NBA_SelectOffer_CC.NavegacaoMovel();
	List<Case> lstCase                                                      = [SELECT Id, Time_of_Service__c, ContractNumber__c FROM Case where id = :recordId];
	if(!lstCase.isEmpty()) {
		Case a                                                                  = lstCase[0];
		Contract cont                                                   = [SElECT Id, PaymentMethod__c, BillDeliveryMethod__c, DocumentNumber__c FROM Contract WHERE id = :a.ContractNumber__c];
		String cpfAcc                                                   = cont.DocumentNumber__c;
		List<Account> lstAcc                                    = [SElECT Id, MothersName__c, RGEmitter__c, RG__c, RecordTypeId FROM Account WHERE DocumentNumber__c = :cpfAcc];
		List<Contact> lstContact                                = [SElECT Id, MothersName__c, RGEmitter__c, RG__c, RecordTypeId FROM Contact WHERE DocumentNumber__c = :cpfAcc];

		if(!lstContact.isEmpty()) {
			result.data.recordContact.idContact                             = lstContact[0].Id;
			result.data.recordContact.idRecordTypeCont              = lstContact[0].RecordTypeId;
			result.data.recordContact.mothersNameContact    = lstContact[0].MothersName__c;
			result.data.recordContact.rgEmitterContact              = lstContact[0].RGEmitter__c;
			result.data.recordContact.rgContact                             = lstContact[0].RG__c;
			result.data.recordContract.billDeliveryMethod   = cont.BillDeliveryMethod__c;
			result.data.recordContract.paymentMethod                = cont.PaymentMethod__c;
			result.isContact                                                                = true;
			return result;


		}else if(!lstAcc.isEmpty()) {
			result.data.recordAccount.idAccount                             = lstAcc[0].Id;
			result.data.recordAccount.idRecordTypeAcc               = lstAcc[0].RecordTypeId;
			result.data.recordAccount.mothersNameAcc                = lstAcc[0].MothersName__c;
			result.data.recordAccount.rgEmitterAcc                  = lstAcc[0].RGEmitter__c;
			result.data.recordAccount.rgAcc                                 = lstAcc[0].RG__c;
			result.data.recordContract.billDeliveryMethod   = cont.BillDeliveryMethod__c;
			result.data.recordContract.paymentMethod                = cont.PaymentMethod__c;
			result.isAccount                                                                = true;
			return result;

		}else{
			return result;
		}
	}else{
		return result;
	}
}

@AuraEnabled
	public static String OfferValidation(String posseParm, String ofertaParm, String subscriberId, String recordId) {

		NBA_OfferComparator_CC.Offer posse = (NBA_OfferComparator_CC.Offer) JSON.deserialize(posseParm,NBA_OfferComparator_CC.Offer.class);
		NBA_OfferComparator_CC.Offer oferta = (NBA_OfferComparator_CC.Offer) JSON.deserialize(ofertaParm,NBA_OfferComparator_CC.Offer.class);
		Case caso = [SELECT ContractNumber__r.vlocity_cmt__ContractReferenceNumber__c, ContractNumber__r.CityCode__c FROM Case WHERE Id = :recordId];
		User usuario = [SELECT NetServicos__c FROM User WHERE Id = :UserInfo.getUserId()];
		List<String> keepMoviments = new List<String>{NBA_Constants.MOVIMENTO_MANTIDO, NBA_Constants.MOVIMENTO_LATERAL};

		// VERIFICA CONDIÇÕES ONDE NÃO DEVE CHAMAR API

		Boolean callOfferValidation = true;

		// cancelamento po de tv (avulso)
		if(oferta.tv[oferta.techSelected].planTv.label!=NBA_Constants.NAO_POSSUI && (
			(posse.tv[0].addOptions.firstPoint.checked && !oferta.tv[oferta.techSelected].addOptions.firstPoint.checked) ||
			(posse.tv[0].addOptions.secondPoint.checked && !oferta.tv[oferta.techSelected].addOptions.secondPoint.checked) ||
			(posse.tv[0].addOptions.thirdPoint.checked && !oferta.tv[oferta.techSelected].addOptions.thirdPoint.checked) ||
			(posse.tv[0].addOptions.fourthPoint.checked && !oferta.tv[oferta.techSelected].addOptions.fourthPoint.checked)))
			callOfferValidation = false;

		// cancelamento de alacarte (avulso)
		if(oferta.tv[oferta.techSelected].planTv.label!=NBA_Constants.NAO_POSSUI){
			Map<String, NBA_OfferComparator_CC.Additional> alacartesOld = new Map<String, NBA_OfferComparator_CC.Additional>();
			for(NBA_OfferComparator_CC.Additional alacarteOld : posse.tv[0].addOptions.lstAdditionals) 
				if(alacarteOld.checked)
					alacartesOld.put(alacarteOld.id, alacarteOld);
			for(NBA_OfferComparator_CC.Additional alacarteNew : oferta.tv[oferta.techSelected].addOptions.lstAdditionals)
				if(!alacarteNew.checked && alacartesOld.containsKey(alacarteNew.id))
					callOfferValidation = false;
		}
		
		// cancelamento de internet ou fone
		if(oferta.movimentBroadband==NBA_Constants.MOVIMENTO_CANCELAMENTO || oferta.movimentPhone==NBA_Constants.MOVIMENTO_CANCELAMENTO)
			callOfferValidation = false;

		// movimentação de móvel
		if((oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI &&
		   (oferta.movimentMobile == NBA_Constants.MOVIMENTO_AQUISICAO || oferta.movimentMobile == NBA_Constants.MOVIMENTO_DOWNGRADE ||
		    oferta.movimentMobile == NBA_Constants.MOVIMENTO_UPGRADE || (oferta.movimentMobile == NBA_Constants.MOVIMENTO_LATERAL && 
			oferta.mobile.planMobile.label != NBA_Constants.MOVIMENTO_MANTER))) ||
			(posse.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && oferta.mobile.planMobile.label==NBA_Constants.NAO_POSSUI))
			callOfferValidation = false;
			
		// movimentação de dependentes de móvel
		if(oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && String.isNotBlank(oferta.movimentMobile)){
			for(NBA_OfferComparator_CC.Dependentes dep : oferta.mobile.listaDependentesMobileSelected)
				if(dep.origem != null && (dep.origem.equalsIgnoreCase('Novo') || dep.origem.equalsIgnoreCase('Portabilidade')))
					callOfferValidation = false;
		}
		if((oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI ||
		   (posse.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && oferta.mobile.planMobile.label==NBA_Constants.NAO_POSSUI)) 
		   && posse.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI){
			if(oferta.mobile.planMobile.label==NBA_Constants.NAO_POSSUI){
				for(NBA_OfferComparator_CC.Dependentes dep : posse.mobile.listaDependentesMobile)
					callOfferValidation = false;
		    }
			if(oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI){
				for(NBA_OfferComparator_CC.Dependentes dep : posse.mobile.listaDependentesMobile)
					if(!dep.checked)
						callOfferValidation = false;
			}
		}
		
		// movimentação de adicionais de móvel
		if(oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && String.isNotBlank(oferta.movimentMobile)){
			Map<String, NBA_OfferComparator_CC.Additional> mapAlacarteMV = new Map<String, NBA_OfferComparator_CC.Additional>();
			for(NBA_OfferComparator_CC.Additional oldOffer : oferta.mobile.addOptions.lstAdditionals)
				if(oldOffer.checked)
					mapAlacarteMV.put(oldOffer.label, oldOffer);
			for(NBA_OfferComparator_CC.Additional add : oferta.mobile.addOptions.lstAdditionals)
				if(add.checked && !mapAlacarteMV.containsKey(add.nameLegacy))
					callOfferValidation = false;
		}
		if(oferta.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && String.isBlank(oferta.movimentMobile))
			for(NBA_OfferComparator_CC.Additional alacarte : oferta.mobile.AddOptions.lstAdditionals)
				if(alacarte.checked)
					callOfferValidation = false;
		if(posse.mobile.planMobile.label!=NBA_Constants.NAO_POSSUI && oferta.mobile.planMobile.label==NBA_Constants.NAO_POSSUI)
			for(NBA_OfferComparator_CC.Additional alacarte : posse.mobile.addOptions.lstAdditionals)
				if (alacarte.checked)
					callOfferValidation = false;

		// MONTAGEM DO REQUEST PARA API

		NBA_IntegrationModels.OfferValidationRequest requestBody = new NBA_IntegrationModels.OfferValidationRequest();
		if(callOfferValidation){			
			requestBody.contract.id = Integer.valueOf(caso.ContractNumber__r.vlocity_cmt__ContractReferenceNumber__c);
			requestBody.seller = usuario.NetServicos__c;

			// tv: principal
			Integer indexTV = String.isNotBlank(oferta.tv[oferta.techSelected].solicitationType) ? (oferta.tv[oferta.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size()> 1 ? 1 : 0) : 0;
			String slTypeTV = String.isNotBlank(oferta.tv[oferta.techSelected].solicitationType) ? oferta.tv[oferta.techSelected].solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexTV] : null;
			
			if((oferta.tv[oferta.techSelected].planTv != null && oferta.tv[oferta.techSelected].planTv.label != NBA_Constants.NAO_POSSUI && 
			String.isNotBlank(oferta.movimentTv) && !(keepMoviments.contains(oferta.movimentTv) && String.isBlank(slTypeTV))) || 
			oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO){
				

				if(requestBody.offer.paytv==null)
					requestBody.offer.paytv = new List<NBA_IntegrationModels.OfferValidationCustomerProduct>();	   
				NBA_IntegrationModels.OfferValidationCustomerProduct produto = new NBA_IntegrationModels.OfferValidationCustomerProduct();
				produto.point = String.isNotBlank(posse.tv[0].planTv.pointId) ? Integer.valueOf(posse.tv[0].planTv.pointId) : null;
				produto.product.Name = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? NBA_Constants.ACESSO_VIRTUA : oferta.tv[oferta.techSelected].planTv.nameLegacy; 
				produto.product.price = oferta.tv[oferta.techSelected].planTv.value - oferta.tv[oferta.techSelected].automaticDebitDiscount;
				produto.product.discount.validity = (!oferta.tv[oferta.techSelected].planTv.lstPromotions.isEmpty() && oferta.tv[oferta.techSelected].planTv.lstPromotions[0].valid!=null ? oferta.tv[oferta.techSelected].planTv.lstPromotions[0].valid : 0);

				produto.product.adhesion.price =  oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : getAdhesionPrice(oferta, NBA_Constants.TV_PACOTE, oferta.movimentTv);
				produto.product.adhesion.period = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : getAdhesionPeriod(oferta, NBA_Constants.TV_PACOTE, oferta.movimentTv);

				requestBody.offer.paytv.add(produto);
			}
			
			// tv: pontos
			if((oferta.tv[oferta.techSelected].planTv != null && oferta.tv[oferta.techSelected].planTv.label != NBA_Constants.NAO_POSSUI) || 
				oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO){

				Integer count = 0;
				Map<Integer, NBA_OfferComparator_CC.Optional> pontosOpcionaisOld = new Map<Integer, NBA_OfferComparator_CC.Optional>();
				if(oferta.movimentTv!=NBA_Constants.MOVIMENTO_CANCELAMENTO){
					for(NBA_OfferComparator_CC.Optional pontoOpcionalOld : posse.tv[0].addOptions.lstOptionalPointsRPA){
						pontosOpcionaisOld.put(count, pontoOpcionalOld);
						count++;
					}
					count = 0;
				}
				for(NBA_OfferComparator_CC.Optional pontoOpcional : 
					oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? posse.tv[0].addOptions.lstOptionalPointsRPA : oferta.tv[oferta.techSelected].addOptions.lstOptionalPointsRPA){
					if(pontoOpcional.checked && (!pontoOpcional.isAlreadyIncluded || oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ||
					  (pontoOpcional.isAlreadyIncluded && pontoOpcional.solicitationType!=null && pontoOpcional.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO)))){
						if(requestBody.offer.paytv==null)
							requestBody.offer.paytv = new List<NBA_IntegrationModels.OfferValidationCustomerProduct>();	   
						NBA_IntegrationModels.OfferValidationCustomerProduct produto = new NBA_IntegrationModels.OfferValidationCustomerProduct();
						produto.point = oferta.movimentTv!=NBA_Constants.MOVIMENTO_CANCELAMENTO 
							? (pontosOpcionaisOld.containsKey(count) && String.isNotBlank(pontosOpcionaisOld.get(count).pointId) ? Integer.valueOf(pontosOpcionaisOld.get(count).pointId) : null)
							: (String.isNotBlank(pontoOpcional.pointId) ? Integer.valueOf(pontoOpcional.pointId) : null);
						produto.product.Name = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? NBA_Constants.ACESSO_VIRTUA : pontoOpcional.nameLegacy; 
						produto.product.price = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : pontoOpcional.value;
						produto.product.discount.validity = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : (pontoOpcional.promotion.valid!=null ? pontoOpcional.promotion.valid :0);
						String movimentoPontoOpcional = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? NBA_Constants.MOVIMENTO_CANCELAMENTO : (
							pontoOpcional.solicitationType!=null && pontoOpcional.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO) 
							? oferta.movimentTv : NBA_Constants.MOVIMENTO_AQUISICAO);
						produto.product.adhesion.price =  oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : getAdhesionPrice(oferta, NBA_Constants.TV_PONTOS_ADICIONAIS, movimentoPontoOpcional);
						produto.product.adhesion.period = oferta.movimentTv==NBA_Constants.MOVIMENTO_CANCELAMENTO ? 0 : getAdhesionPeriod(oferta, NBA_Constants.TV_PONTOS_ADICIONAIS, movimentoPontoOpcional);
						requestBody.offer.paytv.add(produto);
					}
					count++;

				}
			}
			
			// tv: alacarte
			List<NBA_IntegrationModels.OfferValidationProduct> produtos = new List<NBA_IntegrationModels.OfferValidationProduct>();
			if(oferta.tv[oferta.techSelected].planTv != null && oferta.tv[oferta.techSelected].planTv.label != NBA_Constants.NAO_POSSUI){
				Map<String, NBA_OfferComparator_CC.Additional> mapAlacartOld = new Map<String, NBA_OfferComparator_CC.Additional>();
				for (NBA_OfferComparator_CC.Additional alacarte : posse.tv[0].addOptions.lstAdditionals)
					if(alacarte.checked)
						mapAlacartOld.put(alacarte.id, alacarte);
				for(NBA_OfferComparator_CC.Additional alacarte : oferta.tv[oferta.techSelected].addOptions.lstAdditionals) {
					if(alacarte.checked && !mapAlacartOld.containsKey(alacarte.id)){
						NBA_IntegrationModels.OfferValidationProduct produto = new NBA_IntegrationModels.OfferValidationProduct();

						produto.Name = alacarte.nameLegacy;
						produto.price = alacarte.value;
						produto.discount.validity = (!alacarte.lstPromotions.isEmpty() && alacarte.lstPromotions[0].valid!=null ? alacarte.lstPromotions[0].valid : 0);
						produto.adhesion.price =  getAdhesionPrice(oferta, null, null);
						produto.adhesion.period = getAdhesionPeriod(oferta, null, null);

						produtos.add(produto);
					}
				}
			}
			if(!produtos.isEmpty()){
				if(String.isBlank(oferta.movimentTv) || (keepMoviments.contains(oferta.movimentTv) && String.isBlank(slTypeTV))){
					for(NBA_IntegrationModels.OfferValidationProduct produto : produtos){
						if(requestBody.offer.alacarte==null)
							requestBody.offer.alacarte = new List<NBA_IntegrationModels.OfferValidationCustomerProduct>();	   
						NBA_IntegrationModels.OfferValidationCustomerProduct produto_cliente = new NBA_IntegrationModels.OfferValidationCustomerProduct();
						produto_cliente.point = Integer.valueOf(posse.tv[0].planTv.pointId);
						produto_cliente.product = produto; 
						requestBody.offer.alacarte.add(produto_cliente);
					}
				}else{
					requestBody.offer.paytv[0].product.additional = new NBA_IntegrationModels.OfferValidationAdditionalProducts();
					requestBody.offer.paytv[0].product.additional.alacarte = new List<NBA_IntegrationModels.OfferValidationProduct>();			
					requestBody.offer.paytv[0].product.additional.alacarte.addAll(produtos);
				}
			}
			
			// internet: principal (sem alacartes)
			Integer indexBL = String.isNotBlank(oferta.broadband.solicitationType) ? (oferta.broadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
			String slTypeBL = String.isNotBlank(oferta.broadband.solicitationType) ? oferta.broadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexBL] : null;
			if(oferta.broadband.planBroadband != null && oferta.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI && 
			String.isNotBlank(oferta.movimentBroadband) && !(keepMoviments.contains(oferta.movimentBroadband) && String.isBlank(slTypeBL))){
				if(requestBody.offer.internet==null)
					requestBody.offer.internet = new List<NBA_IntegrationModels.OfferValidationCustomerProduct>();	   
				NBA_IntegrationModels.OfferValidationCustomerProduct produto = new NBA_IntegrationModels.OfferValidationCustomerProduct();
				produto.point = String.isNotBlank(posse.broadband.planBroadband.pointId) ? Integer.valueOf(posse.broadband.planBroadband.pointId) : null;
				produto.product.Name = oferta.broadband.planBroadband.nameLegacy; 
				produto.product.price = oferta.broadband.planBroadband.value - oferta.broadband.automaticDebitDiscount;
				produto.product.discount.validity = (!oferta.broadband.planBroadband.lstPromotions.isEmpty() && oferta.broadband.planBroadband.lstPromotions[0].valid!=null ? oferta.broadband.planBroadband.lstPromotions[0].valid : 0);

				produto.product.adhesion.price =  getAdhesionPrice(oferta, NBA_Constants.BL_ASSINATURA, oferta.movimentBroadband);
				produto.product.adhesion.period = getAdhesionPeriod(oferta, NBA_Constants.BL_ASSINATURA, oferta.movimentBroadband);

				requestBody.offer.internet.add(produto);
			}
			
			// telefone: principal (sem alacartes)
			Integer indexFN = String.isNotBlank(oferta.phone.solicitationType) ? (oferta.phone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
			String slTypeFN = String.isNotBlank(oferta.phone.solicitationType) ? oferta.phone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexFN] : null;
			if(oferta.phone.planPhone != null && oferta.phone.planPhone.label != NBA_Constants.NAO_POSSUI && 
			String.isNotBlank(oferta.movimentPhone) && !(keepMoviments.contains(oferta.movimentPhone) && String.isBlank(slTypeFN))){
				if(requestBody.offer.phone==null)
					requestBody.offer.phone = new List<NBA_IntegrationModels.OfferValidationCustomerProduct>();	   
				NBA_IntegrationModels.OfferValidationCustomerProduct produto = new NBA_IntegrationModels.OfferValidationCustomerProduct();
				produto.point = String.isNotBlank(posse.phone.planPhone.pointId) ? Integer.valueOf(posse.phone.planPhone.pointId) : null;
				produto.product.Name = oferta.phone.planPhone.nameLegacy; 
				produto.product.price = oferta.phone.planPhone.value;
				produto.product.discount.validity = (!oferta.phone.planPhone.lstPromotions.isEmpty() && oferta.phone.planPhone.lstPromotions[0].valid!=null ? oferta.phone.planPhone.lstPromotions[0].valid : 0);

				produto.product.adhesion.price =  getAdhesionPrice(oferta, NBA_Constants.NET_FONE, oferta.movimentPhone);
				produto.product.adhesion.period = getAdhesionPeriod(oferta, NBA_Constants.NET_FONE, oferta.movimentPhone);
				requestBody.offer.phone.add(produto);
			}
			
		}
		
		// CHAMADA A API E RETORNO PARA O FRONT

		NBA_IntegrationModels.OfferValidationResponse response;
		if(requestBody.offer.paytv==null && requestBody.offer.internet==null && requestBody.offer.phone==null && requestBody.offer.mobile==null && requestBody.offer.alacarte==null){

			response = new NBA_IntegrationModels.OfferValidationResponse();
			response.validationNeeded = false;
		}
		else{
			response = new NBA_IntegrationModels.OfferValidationResponse();
			response.validationNeeded = true;
			if(String.isNotBlank(subscriberId)){
				requestBody.contract.customerId = Integer.valueOf(subscriberId);	
				Map<String, Object> cleanRequestBody = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(requestBody, true));
				response = NBA_IntegrationServices.OfferValidation(cleanRequestBody, caso.ContractNumber__r.CityCode__c);
				response.request = cleanRequestBody;
				response.validationNeeded = true;
			}
		}
		
		return JSON.serialize(response);
	}


	public static Integer getAdhesionPeriod(NBA_OfferComparator_CC.Offer oferta, String tipoProdutoParm, String movimentoProdutoParm) {
		List<String> movimentosUpgrade = new List<String>{NBA_Constants.MOVIMENTO_MANTIDO, NBA_Constants.MOVIMENTO_LATERAL,NBA_Constants.MOVIMENTO_UPGRADE, NBA_Constants.MOVIMENTO_DOWNGRADE};
		String tipoProdutoUpgradeOfer = (oferta.lstUpgradeFee.size()>0 ? oferta.lstUpgradeFee[0].label : '');
		String tipoProdutoAdesaoOfer = (oferta.lstMembershipFee.size()>0 ? oferta.lstMembershipFee[0].label : '');
		Integer formaPagamentoRet = 0;

		if(tipoProdutoParm != null && tipoProdutoParm == (movimentosUpgrade.contains(movimentoProdutoParm) ? tipoProdutoUpgradeOfer : tipoProdutoAdesaoOfer)){
			String formaPagamentoOfer = '';
			
			if(movimentosUpgrade.contains(movimentoProdutoParm))
				formaPagamentoOfer = oferta.paymentMethodUpgrade;
			else 
				formaPagamentoOfer = oferta.paymentMethodMembership;

			if(formaPagamentoOfer == 'ISENTO' || formaPagamentoOfer=='' || formaPagamentoOfer==null)
				formaPagamentoRet = 0;
			else if(formaPagamentoOfer == 'A VISTA')
				formaPagamentoRet = 1;
			else{
				Matcher matcher = Pattern.compile('^([0-9]+) VEZ(ES)?$').matcher(formaPagamentoOfer);
				if(matcher.matches())
					formaPagamentoRet = Integer.valueOf(matcher.group(1));
			}
		}

		return formaPagamentoRet;
	}

	public static Decimal getAdhesionPrice(NBA_OfferComparator_CC.Offer oferta, String tipoProdutoParm, String movimentoProdutoParm) {
		List<String> movimentosUpgrade = new List<String>{NBA_Constants.MOVIMENTO_MANTIDO, NBA_Constants.MOVIMENTO_LATERAL,NBA_Constants.MOVIMENTO_UPGRADE, NBA_Constants.MOVIMENTO_DOWNGRADE};
		String tipoProdutoUpgradeOfer = (oferta.lstUpgradeFee.size()>0 ? oferta.lstUpgradeFee[0].label : '');
		String tipoProdutoAdesaoOfer = (oferta.lstMembershipFee.size()>0 ? oferta.lstMembershipFee[0].label : '');
		Decimal valorTaxa = 0.0;

		if(tipoProdutoParm != null && tipoProdutoParm == (movimentosUpgrade.contains(movimentoProdutoParm) ? tipoProdutoUpgradeOfer : tipoProdutoAdesaoOfer)){
			if(movimentosUpgrade.contains(movimentoProdutoParm)){
				if(oferta.lstUpgradeFee.size()>0 && oferta.lstUpgradeFee[0].value!=null)
					valorTaxa = oferta.lstUpgradeFee[0].value;
			}
			else{
				if(oferta.lstMembershipFee.size()>0 && oferta.lstMembershipFee[0].value!=null)
					valorTaxa = oferta.lstMembershipFee[0].value;
			}
		}
				
		return valorTaxa;

	}

@AuraEnabled
public static NBA_SelectOffer_CC.AgendamentoResponse consultarAgendamento(Id recordId, String ofertaId, String solicitationType, String cityCode, String codePriority, String ofertaSelecionada, String produtoAntigo ) {
	System.debug('oferta '+ ofertaSelecionada );
	System.debug('posse '+ produtoAntigo );
	NBA_SelectOffer_CC.AgendamentoResponse result = new NBA_SelectOffer_CC.AgendamentoResponse();
	Boolean posseOferta = false;
	if(ofertaSelecionada == produtoAntigo) {
		posseOferta = true;
	}

	NBA_OfferComparator_CC.Offer oferta = (NBA_OfferComparator_CC.Offer) JSON.deserialize(ofertaSelecionada,NBA_OfferComparator_CC.Offer.class);
	NBA_OfferComparator_CC.Offer posse = (NBA_OfferComparator_CC.Offer) JSON.deserialize(produtoAntigo,NBA_OfferComparator_CC.Offer.class);
	IdProduto idproduto = (IdProduto) JSON.deserialize(ofertaId, IdProduto.class);
	String productId = '';

	Try {
		List<Case> lstCase = [SELECT Id,
		                      ContractNumber__r.ContractNumber__c,
		                      CallReason__c
		                      FROM Case
		                      WHERE Id = :recordId];

		if(!lstCase.isEmpty()) {
			integer cod = 0;
			Boolean inadiplente = lstCase[0].CallReason__c == 'Inadimplente' ? true : false;
			List<Agendamento__mdt> lstAgendamento = [SELECT id, COD_BASE__c, DESCRICAO_OS__c, DESCRICAO_SOLIC__c, ID_TIPO_OS__c, ID_TIPO_SOLIC__c FROM Agendamento__mdt ];
			if(!lstAgendamento.isEmpty()) {
				String movimentoOriginal = oferta.movimentTv;
				if(posseOferta) {
					oferta.movimentTv = NBA_Constants.MOVIMENTO_CANCELAMENTO;
				}
				integer codTv = getCodeAgendamentoTV(oferta.tv[oferta.techSelected], posse.tv[posse.techSelected], posse.baseId, inadiplente, lstAgendamento, oferta.movimentTv);
				integer codBL = getCodeAgendamentoBL(oferta.broadband, posse.baseId, inadiplente, lstAgendamento, posse.broadband, oferta.movimentBroadband);
				integer codFN = getCodeAgendamentoFN(oferta.phone, posse.baseId, inadiplente, lstAgendamento, posse.phone, oferta.movimentPhone);
				if(posseOferta) {
					oferta.movimentTv = movimentoOriginal;
				}
				System.debug('COD_BASE ' + posse.baseId);
				System.debug('code tv '+ codTv );
				System.debug('code bl '+ codBL);
				System.debug('code fn '+  codFN);
				if(codTv != null && codTv != 0) {
					cod = codTv;
					productId = idproduto.idTv == '' ? idproduto.idTvPosse : idproduto.idTv;
				}else if(codBL != null && codBL != 0) {
					cod = codBL;
					productId = idproduto.idBl == '' ? idproduto.idBlPosse : idproduto.idBl;
				}else if(codFN != null && codFN != 0) {
					cod = codFN;
					productId = idproduto.idFn == '' ? idproduto.idFnPosse : idproduto.idFn;
				}
			}
			Case caso = lstCase[0];
			if(String.isNotBlank(caso.ContractNumber__r.ContractNumber__c)) {
				NBA_Integration_Definitions__mdt configuracao   = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_Agendamento');
				Map<String, Object> request                                             = new Map<String, Object> ();
				request.put('cityId', cityCode);
				request.put('isFieldOrder', true);
				request.put('contractNumber', caso.ContractNumber__r.ContractNumber__c);
				request.put('action', NBA_Constants.ACTION_SCHEDULE);
				request.put('entityTypeId', NBA_Constants.ENTITYTYPEID);
				//request.put('fieldOrderTypeId', codePriority);
				request.put('fieldOrderTypeId', cod );
				//request.put('productId', ofertaId);
				request.put('productId', productId);
				request.put('startDate', Date.today().addDays(2));
				request.put('numberDays', String.valueOf(configuracao.NBA_NumeroOfertas__c));

				NBA_IntegrationModels.AgendamentoResponse response = NBA_IntegrationServices.getAgendamento(request);
				if(response.error != null && response.error.httpCode != '200') {
					throw new DadosInvalidosException('Error ' + response.error.httpCode);
				}else{
					result = toGetAgendamento(response);
				}
			}else {
				throw new DadosInvalidosException('Valores de Número do Contrato está vazio!');
			}
		}
	} catch(Exception e) {
		System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
		throw new AuraHandledException(e.getMessage());
	}
	return result;
}

private static NBA_SelectOffer_CC.AgendamentoResponse toGetAgendamento(NBA_IntegrationModels.AgendamentoResponse response) {
	NBA_SelectOffer_CC.AgendamentoResponse result                                           = new NBA_SelectOffer_CC.AgendamentoResponse();
	Map<String, NBA_SelectOffer_CC.AgendamentoSchedule> mapAgendamentos = new Map<String, NBA_SelectOffer_CC.AgendamentoSchedule> ();
	if(response != null && response.data != null && response.data.schedule != null && !response.data.schedule.isEmpty()) {
		for(NBA_IntegrationModels.AgendamentoSchedule agdm : response.data.schedule) {
			if(agdm.periods != null && !agdm.periods.isEmpty()) {
				for(NBA_IntegrationModels.AgendamentoPeriods periodAgdm : agdm.periods) {
					NBA_SelectOffer_CC.AgendamentoSchedule scdle            = new NBA_SelectOffer_CC.AgendamentoSchedule();
					if (!mapAgendamentos.containsKey(String.valueOf(periodAgdm.dateSchedule))) {
						scdle.classSchedule                                                             = agdm.classSchedule;
						scdle.fieldSchedule                                                             = agdm.fieldSchedule;
						scdle.requiredMinutes                                                   = agdm.requiredMinutes;
						scdle.dateSchedule                                                              = periodAgdm.dateSchedule;
						mapAgendamentos.put(String.valueOf(periodAgdm.dateSchedule), scdle);
					}
					scdle                                                                                           = mapAgendamentos.get(String.valueOf(periodAgdm.dateSchedule));
					NBA_SelectOffer_CC.AgendamentoPeriods period            = new NBA_SelectOffer_CC.AgendamentoPeriods();
					period.availableMinutes                                                         = periodAgdm.availableMinutes;
					period.description                                                                      = periodAgdm.startHour + ' - ' + periodAgdm.endHour;
					period.emergency                                                                        = periodAgdm.emergency;
					period.endHour                                                                          = periodAgdm.endHour;
					period.isCapacityRegistration                                           = periodAgdm.isCapacityRegistration;
					period.periodTypeId                                                                     = periodAgdm.periodTypeId;
					period.startHour                                                                        = periodAgdm.startHour;

					scdle.periods.add(period);
					scdle.periods.sort();
				}
			}
			result.data.schedule.addAll(mapAgendamentos.values());
		}
	}
	return result;
}

/////////////////////////////////////////////////////////////////////
/////////    Agendamento Alexandre Amaro - 06/11/2019  //////////////
/////////////////////////////////////////////////////////////////////

/*	public static integer getCodeAgendamento (String tipo, NBA_OfferComparator_CC.Offer oferta, String contrato, ){

                Integer cod = 0;

                                if(Adesao de ponto Opicional){
                                        if(TV ??){
                                                if(Tecnologia == DIgital){
                                                        Decimal codID = 3;
                                                        String descricao = 'DIGITAL';
                                                }else{
                                                        Decimal codID = 3;
                                                        String descricao = 'CONEXAO';
                                                }
                                        }else if( BL ??){
                                                Decimal codID = 3;
                                                String descricao = 'VIRTUA';
                                        }else if(FN ??){
                                                Decimal codID = 3;
                                                String descricao = 'VOIP';
                                        }
                                }else if(mudança de pacote ??){
                                        if(TV ??){
                                                if(Acesso virtua no começo e ){
                                                        Decimal codID = 24;
                                                        String descricao = 'INSTALAR TV BASE';
                                                }else if(NAO acesso acesso virtua e tecnologia == Digital){
                                                        Decimal codID = 24;
                                                        String descricao = 'DIGITAL';
                                                }else if(NAO acesso acesso virtua e tecnologia != Digital){
                                                        Decimal codID = 24;
                                                        String descricao = 'MUDANCA DE PACOTE';
                                                }
                                        }else if(BL ??){
                                                Decimal codID = 24;
                                                String descricao = 'MUDANCA DE PACOTE';
                                        }else if(FN ??){
                                                Decimal codID = 24;
                                                String descricao = 'MUDANCA DE PACOTE';
                                        }

                                }else if( cancelamento de pontos  ??){
                                        if(ponto principal de TV ??){
                                                Decimal codID = 24;
                                                String descricao = 'MUDANCA DE PACOTE';
                                        }else if(ponto add de TV ou BL ??){
                                                Decimal codID = 4;
                                        }else if(ponto add de FN unico ??){
                                                Decimal codID = 924;
                                        }else if(ponto add de FN  NAO unico ??){
                                                Decimal codID = 4;
                                        }
                                }else if(desconexão por inadimplência ??){
                                        if(TV ??){
                                                Decimal codID = 48;
                                        }else if(BL ??){
                                                Decimal codID = 48;
                                        }else if(FN ??){
                                                Decimal codID = 923;
                                        }
                                }else if(desconexão por opção ??){
                                        if(TV ??){
                                                Decimal codID = 899;
                                        }else if(BL ??){
                                                Decimal codID = 899;
                                        }else if(FN ??){
                                                Decimal codID = 924;
                                        }
                                }
        } */

public static integer getCodeAgendamentoTV (NBA_OfferComparator_CC.PlanTv produto, NBA_OfferComparator_CC.PlanTv posse, String contrato, Boolean inadiplente, List<Agendamento__mdt> lstAgendamento, String movimentTv ){

	Integer cod = 0;
	String tipoDeSolicitacao = produto.solicitationType != null ? produto.solicitationType.split('\\|')[0] : '';
	System.debug('tipo de Solicitação ' + tipoDeSolicitacao);

	if(checkCancelationAdditionalsPointsTv(produto, posse) && tipoDeSolicitacao != '24' ) {
		movimentTv = NBA_Constants.MOVIMENTO_CANCELAMENTO;
	}


	if(inadiplente) {
		Decimal codID = 48;
		cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
	}else if( tipoDeSolicitacao == '03') {
		if(produto.technology == 'DIGITAL') {
			Decimal codID = 3;
			String descricao = 'DIGITAL';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, false, lstAgendamento);
		}else{
			Decimal codID = 3;
			String descricao = 'CONEXAO';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao,true, true, lstAgendamento);
		}
	}else if(tipoDeSolicitacao == '24' && movimentTv != NBA_Constants.MOVIMENTO_CANCELAMENTO  ) {
		if(posse.PlanTv.typeAcessoVirtua != null && posse.PlanTv.typeAcessoVirtua.split('').size() > 12 && posse.PlanTv.typeAcessoVirtua.substring(0, 13) == 'ACESSO VIRTUA' ) {
			Decimal codID = 24;
			String descricao = 'INSTALAR TV BASE';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, false, lstAgendamento);
		}else if(posse.PlanTv.typeAcessoVirtua != null && !posse.PlanTv.typeAcessoVirtua.contains('ACESSO VIRTUA') && produto.technology == 'DIGITAL') {
			Decimal codID = 24;
			String descricao = 'DIGITAL';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, false, lstAgendamento);
		}else if(posse.PlanTv.typeAcessoVirtua != null && !posse.PlanTv.typeAcessoVirtua.contains('ACESSO VIRTUA') && produto.technology != 'DIGITAL') {
			Decimal codID = 24;
			String descricao = 'MUDANCA DE PACOTE';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, true, lstAgendamento);
		}
	}else if(movimentTv == NBA_Constants.MOVIMENTO_CANCELAMENTO) {
		if(posse.planTv.label != NBA_Constants.NAO_POSSUI && produto.planTv.label == NBA_Constants.NAO_POSSUI) {
			Decimal codID = 24;
			String descricao = 'MUDANCA DE PACOTE';
			cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, true, lstAgendamento);
		}else if(checkCancelationAdditionalsPointsTv(produto, posse)) {
			System.debug('cancelamento PO >>');
			Decimal codID = 4;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}
	}

	return cod;
}

public static integer getCodeAgendamentoBL (NBA_OfferComparator_CC.PlanBroadband produto, String contrato, Boolean inadiplente, List<Agendamento__mdt> lstAgendamento, NBA_OfferComparator_CC.PlanBroadband posse, String movimentBroadband ){

	Integer cod = 0;
	String tipoDeSolicitacao = produto.solicitationType != null ? produto.solicitationType.split('\\|')[0] : '';
	System.debug('tipo de solicitacao BL >>' + tipoDeSolicitacao);
	if(inadiplente) {
		Decimal codID = 48;
		cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
	}else if(tipoDeSolicitacao == '03') {
		Decimal codID = 3;
		String descricao = 'VIRTUA';
		cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, false, lstAgendamento);
	}else if(tipoDeSolicitacao == '24') {
		Decimal codID = 24;
		String descricao = 'MUDANCA DE PACOTE';
		cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, true, lstAgendamento);
	}else if(movimentBroadband == NBA_Constants.MOVIMENTO_CANCELAMENTO) {
		//if(checkCancelationAdditionalsPointsBl(produto, posse)){
		Decimal codID = 4;
		cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		//	}
	}

	return cod;
}

public static integer getCodeAgendamentoFN (NBA_OfferComparator_CC.PlanPhone produto, String contrato, Boolean inadiplente, List<Agendamento__mdt> lstAgendamento, NBA_OfferComparator_CC.PlanPhone posse, String movimentPhone ){

	Integer cod = 0;
	String tipoDeSolicitacao = produto.solicitationType != null ? produto.solicitationType.split('\\|')[0] : '';

	if(inadiplente) {
		Decimal codID = 923;
		cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
	}else if(tipoDeSolicitacao == '03') {
		Decimal codID = 3;
		String descricao = 'VOIP';
		cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, false, lstAgendamento);
	}else if(tipoDeSolicitacao == '24') {
		Decimal codID = 24;
		String descricao = 'MUDANCA DE PACOTE';
		cod = getCodeAgendamentoConsulta(contrato, codId, descricao, true, true, lstAgendamento);
	}else if(movimentPhone == NBA_Constants.MOVIMENTO_CANCELAMENTO) {
		RetornoFoneAgendamento retorno = checkCancelationAdditionalsPointsFn(produto, posse);
		if(retorno.unico && retorno.cancelamento ) {
			Decimal codID = 924;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}else if(!retorno.unico && retorno.cancelamento) {
			Decimal codID = 4;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}else if(!retorno.unico && retorno.cancelamento && retorno.cancelarProduto) {
			Decimal codID = 924;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}
	}

	return cod;
}

public static integer getCodeAgendamentoCancelamentoTotal(string tipoDeProduto, string contrato, List<Agendamento__mdt> lstAgendamento, Boolean inadiplente){

	integer cod = 0;
	if(tipoDeProduto == 'TV') {
		if(inadiplente) {
			Decimal codID = 48;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}else{
			Decimal codID = 899;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}
	}else if(tipoDeProduto == 'BL') {
		if(inadiplente) {
			Decimal codID = 48;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}else{
			Decimal codID = 899;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}
	}else if(tipoDeProduto == 'FN') {
		if(inadiplente) {
			Decimal codID = 923;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}else{
			Decimal codID = 924;
			cod = getCodeAgendamentoConsulta(contrato, codId, '', false, false, lstAgendamento);
		}
	}

	return cod;

}

public static Boolean checkCancelationAdditionalsPointsTv(NBA_OfferComparator_CC.PlanTv oferta, NBA_OfferComparator_CC.PlanTv posse){

	Boolean cancelou = false;

	if(posse.addOptions.firstPoint.checked && !oferta.addOptions.firstPoint.checked) {
		cancelou = true;
	}else if(posse.addOptions.secondPoint.checked && !oferta.addOptions.secondPoint.checked) {
		cancelou = true;
	}else if(posse.addOptions.thirdPoint.checked && !oferta.addOptions.thirdPoint.checked) {
		cancelou = true;
	}else if(posse.addOptions.fourthPoint.checked && !oferta.addOptions.fourthPoint.checked) {
		cancelou = true;
	}
	return cancelou;
}

//public static Boolean checkCancelationAdditionalsPointsBl(NBA_OfferComparator_CC.PlanBroadband oferta, NBA_OfferComparator_CC.PlanBroadband posse){

//Boolean cancelou = false;

//if(posse.addOptions.lstAdditionals.size() < oferta.addOptions.lstAdditionals.size()) {
//cancelou = true;
//}

//return cancelou;
//	}

public static RetornoFoneAgendamento checkCancelationAdditionalsPointsFn (NBA_OfferComparator_CC.PlanPhone oferta, NBA_OfferComparator_CC.PlanPhone posse){

	RetornoFoneAgendamento retorno = new RetornoFoneAgendamento();

	if(!posse.addOptions.secondLine.checked) {
		retorno.unico = true;
	}

	if(posse.addOptions.secondLine.checked && !oferta.addOptions.secondLine.checked) {
		retorno.cancelamento = true;
	}else if(posse.planPhone.label != NBA_Constants.NAO_POSSUI && oferta.planPhone.label == NBA_Constants.NAO_POSSUI) {
		retorno.cancelamento = true;
		retorno.cancelarProduto = true;
	}

	return retorno;
}

public class RetornoFoneAgendamento {

public Boolean unico = false;
public Boolean cancelamento = false;
public Boolean cancelarProduto = false;
}

public class IdProduto {

public String idTv = '';
public String idBl = '';
public String idFn = '';
public String idTvPosse = '';
public String idBlPosse = '';
public String idFnPosse = '';

}


public static Integer getCodeAgendamentoConsulta(String contrato, Decimal codID, String descricao, Boolean hasDescicao, Boolean conexao, List<Agendamento__mdt> lstAgendamento){

	Integer cod = 0;
	if(!lstAgendamento.isEmpty()) {
		for(Agendamento__mdt ag : lstAgendamento) {
			if(hasDescicao) {
				if(ag.COD_BASE__c == contrato && ag.ID_TIPO_SOLIC__c == codID  && ag.DESCRICAO_OS__c.contains(descricao)) {
					if(conexao) {
						if(ag.COD_BASE__c == contrato && ag.ID_TIPO_SOLIC__c == codID  && ag.DESCRICAO_OS__c.contains(descricao) && !ag.DESCRICAO_OS__c.contains('DIGITAL') ) {
							cod = Integer.valueOf(ag.ID_TIPO_OS__c);
						}
					}else{
						cod = Integer.valueOf(ag.ID_TIPO_OS__c);
					}
				}
			}else{
				if(ag.COD_BASE__c == contrato && ag.ID_TIPO_SOLIC__c == codID) {
					cod = Integer.valueOf(ag.ID_TIPO_OS__c);
				}
			}
		}
	}
	return cod;
}

/////////////////////////////////////////////////////////////////////
/////	   InnerClass da Navegação Móvel - US106.2       	    /////
/////////////////////////////////////////////////////////////////////
public class NavegacaoMovel {
@AuraEnabled public MovelNavigation data        = new MovelNavigation();
@AuraEnabled public Boolean isContact           = false;
@AuraEnabled public Boolean isAccount           = false;
}

public class MovelNavigation {
@AuraEnabled public MovelContract recordContract        = new MovelContract();
@AuraEnabled public MovelAccount recordAccount          = new MovelAccount();
@AuraEnabled public MovelContact recordContact          = new MovelContact();
}

public class MovelContract {
@AuraEnabled public String paymentMethod                = '';                 //Método de Pagamento.
@AuraEnabled public String billDeliveryMethod   = '';                 //método de taxa.
@AuraEnabled public String idContract                   = '';                 //Id do Contrato.
}

public class MovelAccount {
@AuraEnabled public String idAccount                    = '';                 //Id do Conta.
@AuraEnabled public String idRecordTypeAcc              = '';                 //Id Record Type da Conta.
@AuraEnabled public String mothersNameAcc               = '';                 //Nome da mão do conta principal.
@AuraEnabled public String rgAcc                                = '';                 //Número do RG da conta.
@AuraEnabled public Date rgDateAcc                              = Date.today();                 //Data de expedição do RG.
@AuraEnabled public String rgEmitterAcc                 = '';                 //Orgao expedidor do RG.
}

public class MovelContact {
@AuraEnabled public String idContact                    = '';                 //Id do Contato.
@AuraEnabled public String idRecordTypeCont             = '';                 //Id Record Type da Contato.
@AuraEnabled public String mothersNameContact   = '';                 //Nome da mão do contato principal.
@AuraEnabled public String rgContact                    = '';                 //Número do RG da conta.
@AuraEnabled public Date rgDateContact                  = Date.today();                //Data de expedição do RG.
@AuraEnabled public String rgEmitterContact             = '';                 //Orgao expedidor do RG.
}

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
@AuraEnabled public String fieldSchedule                                = '';                 //Lembrar de usar o Replace - Agenda de área.
@AuraEnabled public String classSchedule                                = '';                 //Lembrar de usar o Replace - Agenda classe.
@AuraEnabled public String requiredMinutes                              = '';                 //minutos requeridos.
@AuraEnabled public List<AgendamentoPeriods> periods    = new List<AgendamentoPeriods> ();
@AuraEnabled public Date dateSchedule                                   = Date.today();                 //Lembrar de usar o Replace - Data disponível do serviço técnico.
}

public class AgendamentoPeriods implements Comparable {
@AuraEnabled public String description                          = '';                 //Descrição do periodo de agendamento.
@AuraEnabled public String availableMinutes                     = '';                 //Minutos disponíveis.
@AuraEnabled public String startHour                            = '';                 //Hora de início.
@AuraEnabled public String endHour                                      = '';                 //Hora de término.
@AuraEnabled public String periodTypeId                         = '';                 //Identificador tipo período.
@AuraEnabled public String emergency                            = '';                 //Serviço Emergencial.
@AuraEnabled public String isCapacityRegistration       = '';                 //Se cadastrada a capacidade técnica
@AuraEnabled public Boolean cheked                                      = false;                 // usar no radio buttom no component

public Integer compareTo(Object compareTo) {
	AgendamentoPeriods compareToOppy                                = (AgendamentoPeriods) compareTo;
	return description.compareTo(compareToOppy.description);
}
}

@AuraEnabled
public static String  gestorCredito (Id recordId, String ofertaSelecionada) {
	String result='';
	NBA_OfferComparator_CC.Offer oferta = (NBA_OfferComparator_CC.Offer) JSON.deserialize(ofertaSelecionada,NBA_OfferComparator_CC.Offer.class);
	Try {
		List<Case> lstCase = [SELECT Id,
									ContractNumber__c,
									ContractNumber__r.CityCode__c, 
									ContractNumber__r.Account.BillingPostalCode, 
									ContractNumber__r.Account.Name, 
                            		ContractNumber__r.ContractNumber__c, 
									ContractNumber__r.Account.DocumentNumber__c 
							  FROM Case
		                      WHERE Id = :recordId];

  		

		if(!lstCase.isEmpty()) {
			integer cod = 0; 
			Case caso = lstCase[0];

			if(String.isNotBlank(caso.ContractNumber__c)) {
				List<Contact> lstContact = [SELECT Birthdate from Contact where DocumentNumber__c = :caso.ContractNumber__r.Account.DocumentNumber__c];
				
				List<User> lstUser = [SELECT NetServicos__c,SalesTeamNET__c,Name, FederationIdentifier, CompanyName, Claro__c FROM User WHERE Id = :UserInfo.getUserId()];
				
				NBA_IntegrationModels.DataGestorCreditoRequest gestorCredito = new NBA_IntegrationModels.DataGestorCreditoRequest();

				NBA_IntegrationModels.GestorCreditoRequest gestorCreditoRequest = new NBA_IntegrationModels.GestorCreditoRequest();
				gestorCreditoRequest.itens = new List<NBA_IntegrationModels.Itens>();
				gestorCreditoRequest.operatorCode = caso.ContractNumber__r.CityCode__c;
				Integer fieldId = 1;
                String cityCodeAux  = caso.ContractNumber__r.CityCode__c;
                if(cityCodeAux.length()<3){
                    cityCodeAux = '0'+cityCodeAux;
                }
				gestorCreditoRequest.itens.add(getItem(caso.ContractNumber__r.Account.Name,'true','DI_NOME', String.valueOf(fieldId++)));
				gestorCreditoRequest.itens.add(getItem(cityCodeAux,'true','DE_CIDADE_OPERADORA', String.valueOf(fieldId++)));
				gestorCreditoRequest.itens.add(getItem(caso.ContractNumber__r.Account.BillingPostalCode,'true','DE_CEP', String.valueOf(fieldId++)));
				if(lstContact.size() > 0){
					gestorCreditoRequest.itens.add(getItem(String.valueOf(lstContact[0].Birthdate),'true','DA_DATA_NASCIMENTO', String.valueOf(fieldId++)));
				}
				gestorCreditoRequest.itens.add(getItem(String.valueOf(Date.today()),'true','DC_DATA_INSTALACAO', String.valueOf( fieldId++)));
				gestorCreditoRequest.itens.add(getItem(caso.ContractNumber__r.ContractNumber__c,'true','DC_NUMERO_CONTRATO', String.valueOf(fieldId++)));
                
                if( caso.ContractNumber__r.Account.DocumentNumber__c != null && caso.ContractNumber__r.Account.DocumentNumber__c != ''){
					gestorCreditoRequest.itens.add(getItem(caso.ContractNumber__r.Account.DocumentNumber__c ,'true','DI_CPF_CNPJ', String.valueOf(fieldId++)));
				}else {
					gestorCreditoRequest.itens.add(getItem('' ,'true','DI_CPF_CNPJ', String.valueOf(fieldId++)));
				}
				String dsProd = '' ;
				String dsProdlegancy = '' ;
				String valor = '' ;

				if(oferta != null && !oferta.tv.isEmpty()){
					if(oferta.tv[oferta.techSelected].planTv.label != NBA_Constants.ACESSO_VIRTUA){
						dsProd = oferta.tv[oferta.techSelected].planTv.label;
						dsProdlegancy = oferta.tv[oferta.techSelected].planTv.nameLegacy;
						valor = String.valueOf(oferta.tv[oferta.techSelected].planTv.value.setScale(2));
					}else if(oferta.broadband.planBroadband != null){
						dsProd = oferta.broadband.planBroadband.label;
						dsProdlegancy = oferta.broadband.planBroadband.nameLegacy;
						valor = String.valueOf(oferta.broadband.planBroadband.value.setScale(2));
					}else if(oferta.phone.planPhone != null){
						dsProd = oferta.phone.planPhone .label;
						dsProdlegancy = oferta.phone.planPhone.nameLegacy;
						valor = String.valueOf(oferta.phone.planPhone.value.setScale(2));
					}
				}else if(oferta != null && oferta.broadband.planBroadband != null){
					dsProd = oferta.broadband.planBroadband.label;
					dsProdlegancy = oferta.broadband.planBroadband.nameLegacy;
					valor = String.valueOf(oferta.broadband.planBroadband.value.setScale(2));
				}else if(oferta != null && oferta.phone.planPhone != null){
					dsProd = oferta.phone.planPhone .label;
					dsProdlegancy = oferta.phone.planPhone.nameLegacy;
					valor = String.valueOf(oferta.phone.planPhone.value.setScale(2));
				}
				gestorCreditoRequest.itens.add(getItem(dsProd,'true','DC_PLANO_PRINCIPAL', String.valueOf( fieldId++)));
				gestorCreditoRequest.itens.add(getItem(dsProdlegancy,'true','DSP_PRODUTO', String.valueOf(fieldId++)));
				gestorCreditoRequest.itens.add(getItem('NORMAL','true','DC_TIPO_ASSINANTE', String.valueOf( fieldId++)));
				gestorCreditoRequest.itens.add(getItem(valor,'true','DSP_PRECO_MENSAL', String.valueOf(fieldId++)));
				
				if(lstUser.size()>0){
					gestorCreditoRequest.itens.add(getItem(lstUser[0].NetServicos__c ,'true','DV_ATENDENTE',String.valueOf(fieldId++)));
					gestorCreditoRequest.itens.add(getItem(lstUser[0].SalesTeamNET__c ,'true','DV_EQUIPE_VENDA', String.valueOf(fieldId++)));
					gestorCreditoRequest.itens.add(getItem(lstUser[0].Name ,'true','DV_VENDEDOR', String.valueOf(fieldId++)));
				}
				
				gestorCreditoRequest.itens.add(getItem('NET','true','DSP_PARCEIRO', String.valueOf(fieldId++)));
				gestorCredito.data = gestorCreditoRequest;
                System.debug('data>>>'+JSON.serialize(gestorCredito));
				NBA_IntegrationModels.GestorCreditoResponse response =  NBA_IntegrationServices.getGestorCredito(gestorCredito);
				System.debug('response>>>'+response);
                
				if (response!=null && response.data!=null) {
                    System.debug('response.data>>>'+response.data);
					result = JSON.serialize(response.data);
				}else if(response!=null && response.analiseError){
					result = JSON.serialize(response);
				}
				
			}else {
				throw new DadosInvalidosException('Valores de Número do Contrato está vazio!');
			}
		}
	} catch(Exception e) {
		System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
		throw new AuraHandledException(e.getMessage());
	}
	return result;
}

public static NBA_IntegrationModels.Itens getItem(String value,String key, String fieldName, String fieldId){
	NBA_IntegrationModels.Itens itens =  new NBA_IntegrationModels.Itens();
	NBA_IntegrationModels.Item item = new NBA_IntegrationModels.Item ();
	item.value = value;
	item.key = key;
	item.fieldName = fieldName;
	item.fieldId = fieldId;
	itens.item =  item;
	return itens;
}

private static String getProductMovement(String selectedProductMovement, String selectedProductSolicType, String possessionProductLabel) {
	if(String.isNotBlank(selectedProductMovement)){
		if(selectedProductMovement==NBA_Constants.MOVIMENTO_LATERAL){
			if(String.isNotBlank(selectedProductSolicType)){
				return NBA_Constants.MOVIMENTO_LATERAL;
			}
			else{
				if(possessionProductLabel!=NBA_Constants.NAO_POSSUI){
					return NBA_Constants.MOVIMENTO_MANTIDO;
				}
				else{
					return NBA_Constants.MOVIMENTO_NENHUMA;
				}
			}
		}
		else{
			return selectedProductMovement;
		}
	}
	else{
		if(possessionProductLabel!=NBA_Constants.NAO_POSSUI){
			return NBA_Constants.MOVIMENTO_MANTIDO;
		}
		else{
			return NBA_Constants.MOVIMENTO_NENHUMA;
		}
	}
}


public class DadosInvalidosException extends Exception { }
}