/*----------------------------------------------------------------------------------------------------------------------------------------------------------
  Autor: Alexandre Amaro
  Data: 02/05/19

  ------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  public with sharing class NBA_CaseTriggerHandler extends TriggerHandler {

	private static final Id recordTypeIdRetencao = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
	private static final Id recordTypeIdRentabilizacao = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
	private static final Id recordTypeIdOrderOffer = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();

	public override void beforeInsert() {
		List<Case> nbaCases = filterByNbaCases(Trigger.new);

		if (nbaCases.isEmpty()) {
			return;
		}

		updateStagebyReason(nbaCases);
	}

	public override void beforeUpdate() {
		List<Case> newNbaCases = filterByNbaCases(Trigger.new);

		if (newNbaCases.isEmpty()) {
			return;
		}

		cleanOrder(newNbaCases);
		automaticFillingCallEnding(newNbaCases);
	}

	@TestVisible
	private static List<Case> filterByNbaCases(List<Case> cases) {
		List<Case> nbaCases = new List<Case>();

		for (Case caseRecord : cases) {
			if (caseRecord.RecordTypeId == recordTypeIdRetencao || caseRecord.RecordTypeId == recordTypeIdRentabilizacao) {
				nbaCases.add(caseRecord);
			}
		}

		return nbaCases;
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Company: Accenture Brasil
	  --- Creation Date: 27/02/2019
	  --- Author: Alexandre Amaro
	  --- Description: Metodo que altera o momento do atendimento de acordo com o motivo e submotivo do caso
	  -------------------------------------------------------------------------------------------------------*/
	@TestVisible
	private static void updateStagebyReason(List<Case> lstCase) {

		List<NBA_PathMetadata__mdt> lstSondagem = [SELECT id, Type__c, Subreason__c, Reason__c, Actions__c FROM NBA_PathMetadata__mdt];
		Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Case.getRecordTypeInfosById();

		for (Case caseUpdate : lstCase) {

			String developerName = recordTypeInfos.get(caseUpdate.RecordTypeId).getDeveloperName();

			for (NBA_PathMetadata__mdt sondagem : lstSondagem) {
				if (caseUpdate.CallReason__c == sondagem.Reason__c &&
					caseUpdate.Subreason__c == sondagem.Subreason__c &&
					developerName == sondagem.Type__c) {
					List<String> lstMomento = sondagem.Actions__c.split('#');

					if (!lstMomento.isEmpty()) {
						caseUpdate.Time_of_Service__c = lstMomento[0];
					}
				}
			}
		}
	}

	/*-------------------------------------------------------------------------------------------------------
	  --- Company: Accenture Brasil
	  --- Creation Date: 18/03/2019
	  --- Author: Vladson Araujo
	  --- Description: Metodo que preenche automaticamente os campos do caso no momento do encerramento
	  -------------------------------------------------------------------------------------------------------*/
	@TestVisible
	private static void automaticFillingCallEnding(List<Case> lstCase) {
		Set<Id> setIdsOrders = new Set<Id> ();
		for (Case caso : lstCase) {
			if (caso.Time_of_Service__c == NBA_Constants.ENCERRAMENTO && String.isNotBlank(caso.Order__c)) {
				setIdsOrders.add(caso.Order__c);
			}
		}

		String perfil = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

		Map<String, Order> mapPedidos = new Map<String, Order> ([SELECT Id,
		                                                        MobileMovement__c,
		                                                        VirtuaMovement__c,
		                                                        TVMovement__c,
		                                                        NETFoneMovement__c,
		                                                        ALaCarteMoviment__c
		                                                        FROM Order
		                                                        WHERE Id IN :setIdsOrders
		                                                        AND RecordTypeId = :recordTypeIdOrderOffer]);

		List<Solic_NBA__c> lstSolics = [SELECT Id,
		                                OfferType__c,
		                                ProductType__c,
		                                QuantityPromoMonths__c,
		                                Order__c,
		                                PromotionName__c
		                                FROM Solic_NBA__c
		                                WHERE Order__c IN :setIdsOrders
		                                AND Order__r.RecordTypeId = :recordTypeIdOrderOffer];

		Map<String, List<Solic_NBA__c>> mapOrderSolics = new Map<String, List<Solic_NBA__c>> ();
		for (Solic_NBA__c solic : lstSolics) {
			if (!mapOrderSolics.containsKey(solic.Order__c)) {
				mapOrderSolics.put(solic.Order__c, new List<Solic_NBA__c> ());
			}
			mapOrderSolics.get(solic.Order__c).add(solic);
		}

        System.debug('#### caso antes: ' + JSON.serialize(lstCase));
		for (Case caso : lstCase) {
			if (caso.Time_of_Service__c == NBA_Constants.ENCERRAMENTO) {
				Order pedido = mapPedidos.get(caso.Order__c);

				if(caso.RecordTypeId == recordTypeIdRetencao) {
					if(analiseDeCredito(caso) && !sistemaIndisponivel(caso)){
						updateResultsRetencao(caso, pedido, mapOrderSolics);
					}
				}

				if(caso.RecordTypeId == recordTypeIdRentabilizacao) {
					if(analiseDeCredito(caso) && !sistemaIndisponivel(caso)){
						Boolean temSolic = pedido == null ? false : mapOrderSolics.get(pedido.Id) != null && !mapOrderSolics.get(pedido.Id).isEmpty();
						updateValuesRentabilizacao(caso, pedido, temSolic, perfil);
					}
				}
			}
		}
        System.debug('#### caso depois: ' + JSON.serialize(lstCase));
	}

	@TestVisible
	private static Boolean analiseDeCredito(Case caso){
		Boolean result = false;
        if(caso != null){
            if(caso.TVN2Result__c != NBA_Constants.CREDITO_REPROVADO && caso.BLN2Result__c != NBA_Constants.CREDITO_REPROVADO && caso.PhoneN2Result__c != NBA_Constants.CREDITO_REPROVADO && caso.MobileN2Result__c != NBA_Constants.CREDITO_REPROVADO){
                result = true;
            }
        }
		return result;
	}

	@TestVisible
	private static Boolean sistemaIndisponivel(Case caso){
		Boolean result = false;
		if(caso.TVN2Result__c == NBA_Constants.SISTEMA_INDISPONIVEL || caso.BLN2Result__c == NBA_Constants.SISTEMA_INDISPONIVEL || caso.PhoneN2Result__c == NBA_Constants.SISTEMA_INDISPONIVEL || caso.MobileN2Result__c == NBA_Constants.SISTEMA_INDISPONIVEL){
			result = true;
		}
		return result;
	}

	@TestVisible
	private static void updateResultsRetencao(Case caso, Order pedido, Map<String, List<Solic_NBA__c>> mapOrderSolics){

		Boolean hasTV = false;
		Boolean hasBL = false;
		Boolean hasPhone = false;
		Boolean hasMobile = false;

		// Cenário de VENDA, RETIDO, NAO POSSUI e NAO RETIDO (parcial)
		if(pedido != null) {

			// N1 - VENDA
			if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			}

			if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			}

			if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			}

			if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			}


			// N1 - NAO RETIDO (PARCIAL)
			if(pedido.TVMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO){
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;

				// N2 e N3
				if (caso.CallReason__c == NBA_Constants.MOTIVO_INADIMPLENCIA) {
					caso.TVN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
					caso.TVN3Result__c = NBA_Constants.RESULT_N3_INADIMPLENCIA;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FALECIMENTO) {
					caso.TVN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.TVN3Result__c = NBA_Constants.RESULT_N3_FALECIMENTO;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_REFORMA_OU_VIAGEM) {
					caso.TVN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.TVN3Result__c = NBA_Constants.RESULT_N3_REFORMA_OU_VIAGEM;
				}
			}

			if(pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO){
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;

				// N2 e N3
				if (caso.CallReason__c == NBA_Constants.MOTIVO_INADIMPLENCIA) {
					caso.BLN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
					caso.BLN3Result__c = NBA_Constants.RESULT_N3_INADIMPLENCIA;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FALECIMENTO) {
					caso.BLN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.BLN3Result__c = NBA_Constants.RESULT_N3_FALECIMENTO;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_REFORMA_OU_VIAGEM) {
					caso.BLN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.BLN3Result__c = NBA_Constants.RESULT_N3_REFORMA_OU_VIAGEM;
				}
			}

			if(pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO){
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;

				// N2 e N3
				if (caso.CallReason__c == NBA_Constants.MOTIVO_INADIMPLENCIA) {
					caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
					caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_INADIMPLENCIA;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FALECIMENTO) {
					caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_FALECIMENTO;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_REFORMA_OU_VIAGEM) {
					caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_REFORMA_OU_VIAGEM;
				}
			}

			if(pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO){
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;

				// N2 e N3
				if (caso.CallReason__c == NBA_Constants.MOTIVO_INADIMPLENCIA) {
					caso.MobileN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
					caso.MobileN3Result__c = NBA_Constants.RESULT_N3_INADIMPLENCIA;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FALECIMENTO) {
					caso.MobileN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.MobileN3Result__c = NBA_Constants.RESULT_N3_FALECIMENTO;
				} else if (caso.CallReason__c == NBA_Constants.MOTIVO_REFORMA_OU_VIAGEM) {
					caso.MobileN2Result__c = NBA_Constants.RESULT_N2_CASOS_ESPECIAIS;
					caso.MobileN3Result__c = NBA_Constants.RESULT_N3_REFORMA_OU_VIAGEM;
				}
			}

			if (mapOrderSolics.get(pedido.Id) != null && !mapOrderSolics.get(pedido.Id).isEmpty()) {
				for (Solic_NBA__c solic : mapOrderSolics.get(pedido.Id)) {

					// PHONE - N1, N2, N3
					if (String.isNotBlank(solic.ProductType__c) && solic.ProductType__c == NBA_Constants.NET_FONE) {

						hasPhone = true;
						if(pedido.NETFoneMovement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO){
							if(pedido.NETFoneMovement__c != NBA_Constants.MOVIMENTO_AQUISICAO){
								caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
							}

							if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase() == NBA_Constants.TIPO_OFERTA_PADRAO) {
								caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_MOVIMENTACAO;
								caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_PRATELEIRA;
							} else if (String.isBlank(solic.OfferType__c) && caso.PhoneN1Result__c == NBA_Constants.RESULT_N1_RETIDO) {
								caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
								caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
							} else {

								caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_COM_OFERTA;
								if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_EXCLUSIVO)) {
									caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_EXCLUSIVA;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_BLINDAGEM)) {
									caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_BLINDAGEM;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_COMBATE)) {
									caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_COMBATE;
								} else {
									caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_PROMOCAO;
								}
							}
						}

					// BROADBAND - N1, N2, N3
					} else if (String.isNotBlank(solic.ProductType__c) && solic.ProductType__c == NBA_Constants.BL_ASSINATURA) {

						hasBL = true;
						if(pedido.VirtuaMovement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO){
							if(pedido.VirtuaMovement__c != NBA_Constants.MOVIMENTO_AQUISICAO){
								caso.BLN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
							}

							if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase() == NBA_Constants.TIPO_OFERTA_PADRAO) {
								caso.BLN2Result__c = NBA_Constants.RESULT_N2_MOVIMENTACAO;
								caso.BLN3Result__c = NBA_Constants.RESULT_N3_PRATELEIRA;
							} else if (String.isBlank(solic.OfferType__c) && caso.BLN1Result__c == NBA_Constants.RESULT_N1_RETIDO) {
								caso.BLN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
								caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
							} else {

								caso.BLN2Result__c = NBA_Constants.RESULT_N2_COM_OFERTA;
								if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_EXCLUSIVO)) {
									caso.BLN3Result__c = NBA_Constants.RESULT_N3_EXCLUSIVA;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_BLINDAGEM)) {
									caso.BLN3Result__c = NBA_Constants.RESULT_N3_BLINDAGEM;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_COMBATE)) {
									caso.BLN3Result__c = NBA_Constants.RESULT_N3_COMBATE;
								} else {
									caso.BLN3Result__c = NBA_Constants.RESULT_N3_PROMOCAO;
								}
							}
						}

					// MOBILE - N1, N2, N3
					} else if (String.isNotBlank(solic.ProductType__c) && (solic.ProductType__c == NBA_Constants.MOVEL_ASSINATURA_RPA || solic.ProductType__c == NBA_Constants.RECORDTYPE_INTERNET_MOVEL || solic.ProductType__c == NBA_Constants.RECORDTYPE_MOVEL_PRE_CONTROLE)){

						hasMobile = true;
						if(pedido.MobileMovement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO){
							if(pedido.MobileMovement__c != NBA_Constants.MOVIMENTO_AQUISICAO){
								caso.MobileN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
							}

							if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase() == NBA_Constants.TIPO_OFERTA_PADRAO) {
								caso.MobileN2Result__c = NBA_Constants.RESULT_N2_MOVIMENTACAO;
								caso.MobileN3Result__c = NBA_Constants.RESULT_N3_PRATELEIRA;
							} else if (String.isBlank(solic.OfferType__c) && caso.MobileN1Result__c == NBA_Constants.RESULT_N1_RETIDO) {
								caso.MobileN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
								caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
							} else {

								caso.MobileN2Result__c = NBA_Constants.RESULT_N2_COM_OFERTA;
								if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_EXCLUSIVO)) {
									caso.MobileN3Result__c = NBA_Constants.RESULT_N3_EXCLUSIVA;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_BLINDAGEM)) {
									caso.MobileN3Result__c = NBA_Constants.RESULT_N3_BLINDAGEM;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_COMBATE)) {
									caso.MobileN3Result__c = NBA_Constants.RESULT_N3_COMBATE;
								} else {
									caso.MobileN3Result__c = NBA_Constants.RESULT_N3_PROMOCAO;
								}
							}
						}

					// TV - N1, N2, N3
					} else if (String.isNotBlank(solic.ProductType__c) && solic.ProductType__c == NBA_Constants.TV_PACOTE) {

						hasTV = true;
						if(pedido.TVMovement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO){
							if(pedido.TVMovement__c != NBA_Constants.MOVIMENTO_AQUISICAO){
								caso.TVN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
							}

							if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase() == NBA_Constants.TIPO_OFERTA_PADRAO) {
								caso.TVN2Result__c = NBA_Constants.RESULT_N2_MOVIMENTACAO;
								caso.TVN3Result__c = NBA_Constants.RESULT_N3_PRATELEIRA;
							} else if (String.isBlank(solic.OfferType__c) && caso.TVN1Result__c == NBA_Constants.RESULT_N1_RETIDO) {
								caso.TVN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
								caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
							} else {

								caso.TVN2Result__c = NBA_Constants.RESULT_N2_COM_OFERTA;
								//caso.TVN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
								if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_EXCLUSIVO)) {
									caso.TVN3Result__c = NBA_Constants.RESULT_N3_EXCLUSIVA;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_BLINDAGEM)) {
									caso.TVN3Result__c = NBA_Constants.RESULT_N3_BLINDAGEM;
								} else if (solic.OfferType__c != null && solic.OfferType__c.toLowerCase().contains(NBA_Constants.TIPO_OFERTA_COMBATE)) {
									caso.TVN3Result__c = NBA_Constants.RESULT_N3_COMBATE;
								} else {
									caso.TVN3Result__c = NBA_Constants.RESULT_N3_PROMOCAO;
								}
							}
						}
					}
				}
			}
		}

		// Casos de exceção na consulta das ofertas e divergências no cadastro do cliente
		if (caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_RETORNO || caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_OFERTAS
				|| caso.Exceptions__c == NBA_Constants.EXCEPTION_MENOS_QUE_3_OFERTAS || caso.CallReason__c == NBA_Constants.MOTIVO_DIVERGENCIA_CADASTRO) {

			// N1
			caso.TVN1Result__c = NBA_Constants.INFORMACOES;
			caso.BLN1Result__c = NBA_Constants.INFORMACOES;
			caso.MobileN1Result__c = NBA_Constants.INFORMACOES;
			caso.PhoneN1Result__c = NBA_Constants.INFORMACOES;

			// N2
			if (caso.CallReason__c == NBA_Constants.MOTIVO_DIVERGENCIA_CADASTRO) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_DIVERGENCIA_CAD;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_DIVERGENCIA_CAD;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_DIVERGENCIA_CAD;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_DIVERGENCIA_CAD;
			} else {
				caso.TVN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
				caso.BLN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
				caso.MobileN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
				caso.PhoneN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
			}

			// N3
			caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;

		// Cenário de cancelamento total
		} else if (pedido != null &&
				   (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO || pedido.TVMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) &&
				   (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO || pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_NENHUMA ) &&
				   (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO || pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) &&
				   (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO || pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_NENHUMA)) {

			caso.TotalCancellation__c = true;

			// N1
			caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;
			caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;
			caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;
			caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;
			caso.ALaCarteN1Result__c = NBA_Constants.RESULT_N1_NAO_RETIDO;

			// N2
			if (caso.CallReason__c == NBA_Constants.MOTIVO_PRODUTO) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_PRODUTO;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_PRODUTO;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_PRODUTO;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_PRODUTO;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_PRODUTO;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FINANCEIRO) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_FINANCEIRO;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_FALTA_DE_VANTAGENS) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_FALTA_DE_VANTAGENS;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_ATENDIMENTO) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_ATENDIMENTO;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_ATENDIMENTO;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_ATENDIMENTO;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_ATENDIMENTO;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_ATENDIMENTO;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_PROBLEMAS_TECNICOS) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_PROBLEMAS_TECNICOS;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_PROBLEMAS_TECNICOS;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_PROBLEMAS_TECNICOS;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_PROBLEMAS_TECNICOS;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_PROBLEMAS_TECNICOS;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_MUDANCA_DE_ENDERECO) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_MUDANCA_DE_ENDERECO;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_MUDANCA_DE_ENDERECO;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_MUDANCA_DE_ENDERECO;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_MUDANCA_DE_ENDERECO;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_MUDANCA_DE_ENDERECO;

			} else if (caso.CallReason__c == NBA_Constants.MOTIVO_CONCORRENCIA) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_CONCORRENCIA;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_CONCORRENCIA;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_CONCORRENCIA;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_CONCORRENCIA;
				caso.ALaCarteN2Result__c = NBA_Constants.RESULT_N2_CONCORRENCIA;
			}
		}

		if(pedido!=null){
			if(pedido.TVMovement__c == NBA_Constants.MOVIMENTO_MANTIDO){ // Não tem solic
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
				caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}else if(pedido.TVMovement__c == NBA_Constants.MOVIMENTO_NENHUMA){
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if(pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_MANTIDO){ // Não tem solic
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
				caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}else if(pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_NENHUMA){
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if(pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_MANTIDO){ // Não tem solic
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
				caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}else if(pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_NENHUMA){
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if(pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_MANTIDO){ // Não tem solic
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_SEM_MOVIMENTACAO_OFERTA;
				caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}else if(pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_NENHUMA){
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}
		}

	}

	// Método auxiliar para atualizar os valores dos resultados do atendimento de cada produto
	@TestVisible
	private static void updateValuesRentabilizacao(Case caso, Order pedido, Boolean temSolic, String perfil) {
	Boolean hasTV = false;
	Boolean hasBL = false;
	Boolean hasPhone = false;
	Boolean hasMobile = false;

		if (perfil == NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_ATIVO
		    && (caso.Exceptions__c == NBA_Constants.EXCEPTION_MENOS_QUE_3_OFERTAS || caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_RETORNO
		        || caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_OFERTAS)) {

			caso.TVN1Result__c = NBA_Constants.IMPRODUTIVO;
			caso.BLN1Result__c = NBA_Constants.IMPRODUTIVO;
			caso.MobileN1Result__c = NBA_Constants.IMPRODUTIVO;
			caso.PhoneN1Result__c = NBA_Constants.IMPRODUTIVO;
			caso.ALaCarteN1Result__c = NBA_Constants.IMPRODUTIVO;

		} else if (perfil == NBA_Constants.PROFILE_USERNAME_RENTABILIZACAO_RECEPTIVO
		           && (caso.Exceptions__c == NBA_Constants.EXCEPTION_MENOS_QUE_3_OFERTAS || caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_RETORNO
		               || caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_OFERTAS)) {

			caso.TVN1Result__c = NBA_Constants.INFORMACOES;
			caso.BLN1Result__c = NBA_Constants.INFORMACOES;
			caso.MobileN1Result__c = NBA_Constants.INFORMACOES;
			caso.PhoneN1Result__c = NBA_Constants.INFORMACOES;
			caso.ALaCarteN1Result__c = NBA_Constants.INFORMACOES;			

		} else if (pedido != null && temSolic) {

			if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			} else if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_UPGRADE) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_UPGRADE;
			} else if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_DOWNGRADE) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_DOWNGRADE;
			} else if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_LATERAL) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_SIDEGRADE;
			} else if (pedido.TVMovement__c == null || pedido.TVMovement__c == NBA_Constants.MOVIMENTO_MANTIDO) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_APLICAVEL;
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			} else {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_VENDA;
			}

			if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			} else if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_UPGRADE) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_UPGRADE;
			} else if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_DOWNGRADE) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_DOWNGRADE;
			} else if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_LATERAL) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_SIDEGRADE;
			} else if (pedido.VirtuaMovement__c == null || pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_MANTIDO) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_APLICAVEL;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			} else {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_VENDA;
			}

			if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			} else if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_UPGRADE) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_UPGRADE;
			} else if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_DOWNGRADE) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_DOWNGRADE;
			} else if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_LATERAL) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_SIDEGRADE;
			} else if (pedido.MobileMovement__c == null || pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_MANTIDO) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_APLICAVEL;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			} else {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_VENDA;
			}

			if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_AQUISICAO) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_VENDA;
			} else if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_UPGRADE) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_UPGRADE;
			} else if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_DOWNGRADE) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_DOWNGRADE;
			} else if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_LATERAL) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_SIDEGRADE;
			} else if (pedido.NETFoneMovement__c == null || pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_MANTIDO) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_APLICAVEL;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			} else {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_VENDA;
			}

			List<String> movimentosVenda = new List<String> {
				NBA_Constants.MOVIMENTO_AQUISICAO, 
				NBA_Constants.MOVIMENTO_UPGRADE, 
				NBA_Constants.MOVIMENTO_DOWNGRADE, 
				NBA_Constants.MOVIMENTO_LATERAL
			};

			if (movimentosVenda.contains(pedido.TVMovement__c)) {
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_PRECO_OFERTA;
				caso.TVN3Result__c = NBA_Constants.RESULT_N3_OUTROS;
			}

			if (movimentosVenda.contains(pedido.VirtuaMovement__c)) {
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_PRECO_OFERTA;
				caso.BLN3Result__c = NBA_Constants.RESULT_N3_OUTROS;
			}

			if (movimentosVenda.contains(pedido.MobileMovement__c)) {
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_PRECO_OFERTA;
				caso.MobileN3Result__c = NBA_Constants.RESULT_N3_OUTROS;
			}

			if (movimentosVenda.contains(pedido.NETFoneMovement__c)) {
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_PRECO_OFERTA;
				caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_OUTROS;
			}

			if (caso.Exceptions__c == NBA_Constants.ISENTO) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
				//caso.ALaCarteN1Result__c = NBA_Constants.RESULT_N1_RETIDO;
			}
		} else if (caso.CallReason__c == NBA_Constants.MOTIVO_DIVERGENCIA_CADASTRO) {
			caso.TVN1Result__c = NBA_Constants.RESULT_N1_INFORMACOES;
			caso.BLN1Result__c = NBA_Constants.RESULT_N1_INFORMACOES;
			caso.MobileN1Result__c = NBA_Constants.RESULT_N1_INFORMACOES;
			caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_INFORMACOES;
			//caso.ALaCarteN1Result__c = NBA_Constants.RESULT_N1_INFORMACOES;
		}

		if (caso.Exceptions__c == NBA_Constants.EXCEPTION_MENOS_QUE_3_OFERTAS || 
			caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_RETORNO || 
			caso.Exceptions__c == NBA_Constants.EXCEPTION_SEM_OFERTAS
		) {
			caso.TVN2Result__c = NBA_Constants.SEM_OFERTAS;
			caso.BLN2Result__c = NBA_Constants.SEM_OFERTAS;
			caso.MobileN2Result__c = NBA_Constants.SEM_OFERTAS;
			caso.PhoneN2Result__c = NBA_Constants.SEM_OFERTAS;
			caso.ALaCarteN2Result__c = NBA_Constants.SEM_OFERTAS;

			caso.TVN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
			caso.BLN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
			caso.MobileN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
			caso.PhoneN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
			caso.ALaCarteN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
		}

		if (pedido != null) {
			if (pedido.TVMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) {
				caso.TVN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.TVN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if (pedido.VirtuaMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) {
				caso.BLN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.BLN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if (pedido.MobileMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) {
				caso.MobileN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.MobileN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}

			if (pedido.NETFoneMovement__c == NBA_Constants.MOVIMENTO_NENHUMA) {
				caso.PhoneN1Result__c = NBA_Constants.RESULT_N1_NAO_POSSUI;
				caso.PhoneN2Result__c = NBA_Constants.RESULT_N2_NENHUM;
				caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
			}
		}
	}

	@TestVisible
	private static void cleanOrder(List<Case> cases) {
		Set<Id> orders = new Set<Id>();
		
		for (Case caseRecord : cases) {
			if (caseRecord.Status != 'Encerrado' && 
			    caseRecord.Order__c != null &&
			    (caseRecord.Time_of_Service__c == 'Sondagem' || caseRecord.Time_of_Service__c == 'Ação')) {
				
				orders.add(caseRecord.Order__c);

				caseRecord.TVN1Result__c = null;
				caseRecord.TVN2Result__c = null;
				caseRecord.TVN3Result__c = null;
				caseRecord.BLN1Result__c = null;
				caseRecord.BLN2Result__c = null;
				caseRecord.BLN3Result__c = null;
				caseRecord.MobileN1Result__c = null;
				caseRecord.MobileN2Result__c = null;
				caseRecord.MobileN3Result__c = null;
				caseRecord.PhoneN1Result__c = null;
				caseRecord.PhoneN2Result__c = null;
				caseRecord.PhoneN3Result__c = null;
				caseRecord.ALaCarteN1Result__c = null;
				caseRecord.ALaCarteN2Result__c = null;
				caseRecord.ALaCarteN3Result__c = null;
			}
		}

		if (!orders.isEmpty()) {
			delete [SELECT Id FROM Solic_NBA__c WHERE Order__c IN :orders];
			delete [SELECT Id FROM Order WHERE Id IN :orders];
		}
	}
}