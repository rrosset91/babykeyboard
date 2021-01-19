({
	const: {
		'PRODUTO_ATUAL': 'produtoAtual',
		'OFERTA_1': 'oferta1',
		'OFERTA_2': 'oferta2',
		'OFERTA_3': 'oferta3',
		'SELECTED': 'selected'
	},
	dump: function (obj) {
		var out = '';
		for (var i in obj) {
			out += i + ": " + obj[i] + "\n";
		}
		//console.log(out);
	},

	consultarPerfilRetencao: function(component) {

		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		// var isInadimplente = component.get('v.isInadimplente');


		var action = component.get("c.isPerfilRentencao");
		action.setParams({
			"recordId": caseId
		});
		action.setCallback(this, function (response) { 
			var state = response.getState();
			if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
				component.set('v.isRetencao', !returnValue );
				if (returnValue) {
					component.set('v.ShowCancelamento', false);
					//component.set('v.ShowIsencaoTaxas', false);
					//if(isInadimplente){
					//	component.set('v.ShowIsencaoTaxas', true);
					//}else{
					//	component.set('v.ShowIsencaoTaxas', false);
					//}
				} else {
					component.set('v.ShowCancelamento', true);
					component.set('v.ShowIsencaoTaxas', true);
					//if(isInadimplente){
					//	component.set('v.ShowIsencaoTaxas', true);
					//}else{
					//	component.set('v.ShowIsencaoTaxas', false);
					//}
				}
			}
		});
		$A.enqueueAction(action);
	},

	isPurple: function(component) {

		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		var action = component.get("c.isPurple");
		action.setParams({
			"recordId": caseId
		});
		action.setCallback(this, function (response){
			var state = response.getState();
		if(state === "SUCCESS"){
				var data = response.getReturnValue();
				component.set('v.isPurple', data );
			}
		});
		$A.enqueueAction(action);
	},

	roundOfferValues: function(data){
		if(data!=null && data!=undefined && data.lstOffers!=null && data.lstOffers!=undefined){
			for (var indexOffer=0; indexOffer<data.lstOffers.length; indexOffer++){
				for (var indexProd=0; indexProd<data.lstOffers[indexOffer].tv.length; indexProd++){
					for (var indexPromotion=0; indexPromotion<data.lstOffers[indexOffer].tv[indexProd].planTv.lstPromotions.length; indexPromotion++){
						data.lstOffers[indexOffer].tv[indexProd].planTv.lstPromotions[indexPromotion]['roundedFullValue'] = (
							data.lstOffers[indexOffer].tv[indexProd].planTv.lstPromotions[indexPromotion].value + 
							data.lstOffers[indexOffer].tv[indexProd].planTv.lstPromotions[indexPromotion].discount 
						).toFixed(2);
					}
				}
				for (var indexPromotion=0; indexPromotion<data.lstOffers[indexOffer].broadband.planBroadband.lstPromotions.length; indexPromotion++){
					data.lstOffers[indexOffer].broadband.planBroadband.lstPromotions[indexPromotion]['roundedFullValue'] = (
						data.lstOffers[indexOffer].broadband.planBroadband.lstPromotions[indexPromotion].value + 
						data.lstOffers[indexOffer].broadband.planBroadband.lstPromotions[indexPromotion].discount 
					).toFixed(2);
				}
				for (var indexPromotion=0; indexPromotion<data.lstOffers[indexOffer].phone.planPhone.lstPromotions.length; indexPromotion++){
					data.lstOffers[indexOffer].phone.planPhone.lstPromotions[indexPromotion]['roundedFullValue'] = (
						data.lstOffers[indexOffer].phone.planPhone.lstPromotions[indexPromotion].value + 
						data.lstOffers[indexOffer].phone.planPhone.lstPromotions[indexPromotion].discount 
					).toFixed(2);
				}
				if(data.lstOffers[indexOffer].mobile.titularesOferta!=null && data.lstOffers[indexOffer].mobile.titularMobile.valorProduto!=null){
					for (var indexPromoTitular=0; indexPromoTitular<data.lstOffers[indexOffer].mobile.titularesOferta.length; indexPromoTitular++)
						data.lstOffers[indexOffer].mobile.titularesOferta[indexPromoTitular]['roundedValorProduto'] 
							= data.lstOffers[indexOffer].mobile.titularesOferta[indexPromoTitular].valorProduto.toFixed(2);
					data.lstOffers[indexOffer].mobile.titularMobile['roundedValorProduto'] = data.lstOffers[indexOffer].mobile.titularMobile.valorProduto.toFixed(2);
				}
			}
		}
	},
	
	consultarOfertas: function(component, event, helper, caseId) {
		var Exceptions;
		caseId = component.get("v.recordId");
		component.set('v.showSpinner', true);
		var action = component.get('c.getOfertas');
		action.setParams({
			"recordId": caseId
		});
		action.setCallback(this, function (response) {

			var state = response.getState();
			if (state === "SUCCESS") {

				// RECEBE E TRATA DADOS DO RETORNO
				var retorno = response.getReturnValue();
				var data = retorno.result;
				this.roundOfferValues(data);
				console.log(JSON.stringify(retorno));

				// VARIÁVEIS GERAIS
				component.set('v.ContractViabilidade', retorno.contractViabilidade);
				component.set('v.hasPosse', retorno.posseClienteSemAV);
                component.set('v.phoneTitular', retorno.mssidn);
				component.set('v.subscriberId', retorno.subscriberId);
				component.set('v.lstPontuacao', data.pontuacao);

				// VARIÁVEIS DE INADIMPLÊNCIA
				var temContratoInadimplente = retorno.contratoResidencialInadimplente || retorno.contratoMovelInadimplente;
				component.set('v.contratoResidencialInadimplente', retorno.contratoResidencialInadimplente);
				component.set('v.contratoMovelInadimplente', retorno.contratoMovelInadimplente);
				component.set('v.exibirBotaoConsultarInadimplencia',  temContratoInadimplente);
				component.set('v.desabilitarBotaoSelecionarOferta', temContratoInadimplente);
				
				// TRATAMENTOS DIVERSOS
				component.set('v.hasServicoIndisponivel', retorno.showModalServicoIndisponivel);

				// 1 - se erro não tratado (pt1) = mostra msg genérica, encerra caso, tabula como sistema indisponível (não salva comentário, não salva exception)
				if(retorno.unhandledError){
					component.set('v.hasServicoIndisponivelModalTexto', 'Ocorreu uma falha técnica interna.');
					component.set('v.hasServicoIndisponivelComentario', component.get('v.hasServicoIndisponivelModalTexto'));
					component.set('v.hasServicoIndisponivelModal', true);
				}
                
               else if(retorno.contractTypePME){
					component.set('v.hasServicoIndisponivelModalTexto', 'Cliente possui contrato PME, portanto não possui elegibilidade no Escolha Certa.');
					component.set('v.hasServicoIndisponivelComentario', component.get('v.hasServicoIndisponivelModalTexto'));
					component.set('v.hasServicoIndisponivelModal', true);
                    component.set('v.hasContractPME',true);
				}

				// 2 - se erro de api de posse = mostra msg da api de posse, encerra caso, tabula como sistema indisponível (não salva comentário, não salva exception)
				else if(retorno.apicontractproductsDisable){
					component.set('v.hasServicoIndisponivelModalTexto', 'Não foi possível consultar o produto atual desse contrato.');
					component.set('v.hasServicoIndisponivelComentario', component.get('v.hasServicoIndisponivelModalTexto'));
					component.set('v.hasServicoIndisponivelModal', true);
				}

				// se posse tem móvel, porém em configuração não válida (sem titular ou múltiplos titulares)
				else if(retorno.posseCliente.movelSemTitular || retorno.posseCliente.movelMultiplosTitulares){
					if(retorno.posseCliente.movelSemTitular)
						component.set('v.hasServicoIndisponivelModalTexto', 'Não foi possível identificar a linha titular móvel desse contrato (sem titular)');
					else
						component.set('v.hasServicoIndisponivelModalTexto', 'Não foi possível identificar a linha titular móvel desse contrato (múltiplos titulares)');
					component.set('v.hasServicoIndisponivelComentario', component.get('v.hasServicoIndisponivelModalTexto'));
					component.set('v.hasServicoIndisponivelModal', true);
					component.set('v.hasDadoInconsistente', true);
				}

				else{

					// *se rentabilização + inadimplente = mostra msg de inadimplente, encerra caso, tabula como inadimplente (não salva comentário, não salva exception)
					if(!component.get('v.isRetencao') && temContratoInadimplente){
						component.set('v.mensagemModalContratoInadimplente', this.gerarMensagemContratoInadimplente(component, retorno));
						component.set('v.exibirModalContratoInadimplente', true);   
					}

					// se diferente de rentabilização + inadimplente
					else{
						
						// 3 - se api de ofertas retorna erro tratado = mostra msg retornada na api, encerra caso, tabula como sistema indisponível, salva comentário com msg retornada na api, salva exception "SEM OFERTAS" 
						if (data.mensagemSemOfertas && data.mensagemSemOfertas.split('|')[1]!='') {
							component.set("v.showNoOffers", true);
							var lstmsg = data.mensagemSemOfertas.split('|');	
							var msg = lstmsg[1];
							component.set('v.errorOfertas', msg );
						}

						// se api de ofertas está com retorno nulo...
						else if (data==undefined || data.lstOffers==undefined) {

							// 4 - ... e se chegou a chamar a api de ofertas = mostra msg fixa, encerra caso, tabula como sistema indisponível, salva comentário com msg fixa, salva exception "SEM OFERTAS"
							if(data.OffersApiCalled){
								component.set("v.disableAllOffers", true);
								component.set("v.showNoOffers", true);
								component.set('v.errorOfertas', "Não foi possível consultar ofertas para esse cliente." ); // O serviço de busca de Ofertas apresentou um problema.
							}
							
							// 5 - ... e não chegou a chamar a api de ofertas / erro não tratado (pt2) = mostra msg genérica, encerra caso, tabula como sistema indisponível  (não salva comentário, não salva exception)
							else{
								component.set('v.hasServicoIndisponivelModalTexto', 'Ocorreu uma falha técnica interna.');
								component.set('v.hasServicoIndisponivelComentario', component.get('v.hasServicoIndisponivelModalTexto'));
								component.set('v.hasServicoIndisponivelModal', true);
								component.set('v.hasServicoIndisponivel', true);
							}

						}

						// *se api de ofertas retorna lista vazia
						else if(data.lstOffers.length === 0){
							Exceptions = 'SEM OFERTAS';
							this.updateStageAndExceptionNoReturn(component, Exceptions);
						}
						
						else{
							
							// se inadimplente = mostra msg de inadimplente. se encerrar = encerra caso, tabula como inadimplente (não salva comentário, não salva exception)
							if(temContratoInadimplente){
								component.set('v.mensagemModalContratoInadimplente', this.gerarMensagemContratoInadimplente(component, retorno));
								component.set('v.exibirModalContratoInadimplente', true);   
							}
							
							// RESTANTE DO PROCESSAMENTO

							component.set('v.ofertas', data);
							component.set('v.fristOffers', data.resultadoBrudoAPI );
							component.set('v.cityCode', data.cityCode);
							var isPurple = component.get('v.isPurple');
							var isRetencao = component.get('v.isRetencao');
							console.log('isPurple: '+isPurple);
							console.log('isRetencao: '+isRetencao);

							var mobileEmpty = { "technology": "", "totalValue": 0, "additionalMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0 }, "key": "", "label": "Adicionais", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "additionalPromoValue": 0, "addOptions": { "lstAdditionals": [] }, "dependentslMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0 }, "key": "", "label": "", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "difAdditionals": 0, "difAdditionalsStep": { "label": "", "value": 0 }, "difDependents": 0, "difDependentsStep": { "label": "", "value": 0 }, "difProducts": 0, "difProductsStep": { "label": "", "value": 0 }, "feeProducts": [], "isComboMulti": false, "listaDependentesMobile": [], "listaDependentesMobileSelected": [], "lstAdditionals": [], "msisdn": "", "name": "", "netsalesProductName": "", "numeroDependentesDados": 0, "numeroDependentesDadosOriginal": 0, "numeroDependentesDadosSelected": 0, "numeroDependentesVozDados": 0, "numeroDependentesVozDadosOriginal": 0, "numeroDependentesVozDadosSelected": 0, "numeroDependentesControle": 0, "numeroDependentesControleOriginal": 0, "numeroDependentesControleSelected": 0, "numeroMaxDep": 0, "planMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0, "startDate": "2015-09-25" }, "key": "380465365", "label": "NÃO POSSUI", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "posseAtual": false, "productDetail": "", "promotionName": "", "speed": "", "svas": [], "titularesOferta": [], "titularMobile": { "catalogName": "", "checked": true, "dependentType": "", "disabled": true, "disabledNew": false, "discountPromo": 0, "feeProducts": [], "fidelity": false, "listBeneficiosDoPlano": [], "listProdutosAdicionais": [], "nameLegacy": "", "nomePlano": "", "numeroTelefone": "", "operadora": "", "origem": "", "portabilityRequestType": "", "productName": "", "promoSelected": "", "promotionName": "", "technology": "", "validFor": 0, "valorProduto": 0 }, "totalDados": 0, "totalDadosOriginal": 0, "totalDadosSelected": 0, "totalDependentes": 0, "totalDependentesSelected": 0, "totalVozDados": 0, "totalVozDadosOriginal": 0, "totalVozDadosSelected": 0, "totalControle": 0, "totalControleOriginal": 0, "totalControleSelected": 0 };

							if(data.callReason == 'Inadimplente'){
								console.log('Dados: '+data);
	
								component.set('v.showAdditionalTv', true);
								component.set('v.showAdditionalBroadband', true);
								component.set('v.showAdditionalPhone', true);
								component.set('v.showAdditionalMobile', true);
								component.set('v.showAdditionalTaxas', true);
								component.set('v.disableAllOffers', true);
								component.set('v.isInadimplente', true);
								component.set('v.ofertaSelecionada', data.currentProduct);

								if (data.currentProduct !== null) {
									data.currentProduct = this.calculateOriginalValuePosse(component, data.currentProduct);
									component.set('v.produtoAtual', data.currentProduct); 
									component.set('v.produtoAntigo', JSON.parse(JSON.stringify(data.currentProduct)));
								}
	
								var produtoAtual = document.getElementById(helper.const.PRODUTO_ATUAL);
								produtoAtual.classList.remove(helper.const.SELECTED);
								component.set('v.' + helper.const.PRODUTO_ATUAL + '.selected', true);
								component.set('v.produtoAntigo.selected', true);
								component.set('v.ofertaSelecionada', component.get('v.' + helper.const.PRODUTO_ATUAL));
								component.set('v.selectedTv', component.get('v.' + helper.const.PRODUTO_ATUAL).tv[0]);
								produtoAtual.classList.add(helper.const.SELECTED);	
								var ofertaCmp = document.getElementById(helper.const.OFERTA_1);			
								ofertaCmp.classList.remove(helper.const.SELECTED);
								this.consultarPerfilRetencao(component, helper);
							}

							else{
								component.set('v.isInadimplente', false);
								console.log('Dados: '+data);

								if (data.currentProduct !== null) {
									data.currentProduct = this.calculateOriginalValuePosse(component, data.currentProduct);
									if(data.lstOffers.length > 0){
										component.set('v.produtoAtual', this.listaDescontoDependentes(component, event, helper, data.lstOffers[0], data.currentProduct));
									}
									else {
										component.set('v.produtoAtual', data.currentProduct);
									}
									component.set('v.produtoAntigo', JSON.parse(JSON.stringify(data.currentProduct)));
									component.set('v.produtoAntigo.selected', true);

									if(isPurple && isRetencao){
										if(component.get('v.produtoAtual.mobile.planMobile.label') == 'NÃO POSSUI'){
											component.set('v.produtoAntigo.mobile', mobileEmpty);
											component.set('v.produtoAtual.mobile', mobileEmpty);
										} 
									} 
									else if(!isRetencao){
										if (component.get('v.produtoAtual.mobile.planMobile.label') == 'NÃO POSSUI') {
											component.set('v.produtoAtual.mobile', mobileEmpty);
										}
									}
								}
	
								if(data.lstOffers != null){
									data.lstOffers = this.calculateOriginalValueOferta(component, data.lstOffers, data.currentProduct);
								}
	
								if (data.lstOffers != null) {
									if(data.lstOffers.length > 0){
										component.set('v.oferta1', data.lstOffers[0]); 
										component.set('v.ofertaSelecionada', data.lstOffers[0]);
										if (data.lstOffers[0].tv.length > 0) {
											component.set('v.tvSelected1', data.lstOffers[0].tv[0]);
											component.set('v.selectedTv', data.lstOffers[0].tv[0]);
										}
									}
	
										if (data.lstOffers.length > 1) {
											component.set('v.oferta2', data.lstOffers[1]);
										if (data.lstOffers[1].tv.length > 0) {
											component.set('v.tvSelected2', data.lstOffers[1].tv[0]);
										}
									}
								
									if(data.lstOffers.length > 2){
										component.set('v.oferta3', data.lstOffers[2]);
										if (data.lstOffers[2].tv.length > 0) {
											component.set('v.tvSelected3', data.lstOffers[2].tv[0]);
										}
									}					
								}
	
								var ofertaSelecionada = component.get('v.ofertaSelecionada');
								var ofertaSelecionadaHasTv = ofertaSelecionada.tv[0].planTv.label;
								if (ofertaSelecionadaHasTv === 'NÃO POSSUI') {
									component.set('v.showAdditionalTv', true);
								} else {
									component.set('v.showAdditionalTv', false);
								}
	
								var ofertaSelecionadaHasBroadband = ofertaSelecionada.broadband.planBroadband.label;
								if (ofertaSelecionadaHasBroadband === 'NÃO POSSUI') {
									component.set('v.showAdditionalBroadband', true);
								} else {
									component.set('v.showAdditionalBroadband', false);
								}
	
								var ofertaSelecionadaHasPhone = ofertaSelecionada.phone.planPhone.label;
								if (ofertaSelecionadaHasPhone === 'NÃO POSSUI') {
									component.set('v.showAdditionalPhone', true);
								} else {
									component.set('v.showAdditionalPhone', false);
								}
	
								var ofertaSelecionadaHasMobile = ofertaSelecionada.mobile.planMobile.label;
								if (ofertaSelecionadaHasMobile === 'NÃO POSSUI') {
									component.set('v.showAdditionalMobile', true);
								} else {
									component.set('v.showAdditionalMobile', false);
								}
							}

							if(data.pontuacao && data.lstOffers){
								this.calculoPercentual(component, event, helper, data.pontuacao, data.lstOffers);
							}
							
							sessionStorage.setItem('oldProduct', JSON.stringify(data.currentProduct));
							sessionStorage.setItem('cdBase', retorno.cdBase);
								
						}
					}
				}
			}

			else if (state === "ERROR") {
				var errors = action.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
					component.set('v.erroOfertas', errors[0].message);
						if (errors[0].message.includes("Read timed out")) {
							component.set('v.showTryAgain', true);
						} else if (errors[0].message.includes("Não foi identificada nenhuma oferta para esse cliente")) {
							component.set("v.disableAllOffers", true);
							component.set("v.showNoOffers", true);
							//var Exceptions = 'SEM OFERTAS';
							//this.updateStageAndExceptionNoReturn(component, Exceptions);
						} else {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": 'Erro ao consultar!',
								"message": errors[0].message,
								"type": "error",
								"mode": "sticky"
							});
							toastEvent.fire();
						}
					}
				}
				if(component.get('v.first') == true){
					Exceptions = 'SEM RETORNO';
					this.updateStageAndExceptionNoReturn(component, Exceptions);
				}
				component.set('v.first', true);
			}
			component.set('v.showSpinner', false);
			component.set('v.showAdditionals', true);

		});
		$A.enqueueAction(action);
	},

	checarInadimplencia : function(component) {
		var action = component.get("c.checkInadimplencia");
		action.setParams({
			"contratoPhone": component.get('v.phoneTitular'),
			"recordId": component.get('v.recordId'),
			"contratoResidencialInadimplente": component.get('v.contratoResidencialInadimplente'),
			"contratoMovelInadimplente": component.get('v.contratoMovelInadimplente')
		});
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") { 
				var retorno = response.getReturnValue();
				var temContratoInadimplente = retorno.contratoResidencialInadimplente || retorno.contratoMovelInadimplente;
				component.set('v.contratoResidencialInadimplente', retorno.contratoResidencialInadimplente);
				component.set('v.contratoMovelInadimplente', retorno.contratoMovelInadimplente);
				component.set('v.exibirBotaoConsultarInadimplencia',  temContratoInadimplente);
				component.set('v.desabilitarBotaoSelecionarOferta', temContratoInadimplente);
				if(temContratoInadimplente){
					component.set('v.mensagemModalContratoInadimplente', this.gerarMensagemContratoInadimplente(component, retorno));
					component.set('v.exibirModalContratoInadimplente', true);   
				}
				component.set('v.showSpinner', false );
			}

		});
		$A.enqueueAction(action);
	},

	gerarMensagemContratoInadimplente: function(component, retorno){
		var perfil=(component.get('v.isRetencao') ? 'RETENÇÃO' : 'RENTABILIZAÇÃO'),  mensagemFinal=[];
		component.set('v.hasServicoIndisponivel',false);

		if(retorno.contratoResidencialSituacao=='INADIMPLENTE' || (retorno.contratoResidencialSituacao=='BLOQUEADO' && retorno.contratoResidencialStatus!=''))
			mensagemFinal.push('Residencial: ' + retorno.contratoResidencialStatus.toUpperCase());
		else if(retorno.contratoResidencialConsulta=='SALESFORCE' && retorno.contratoResidencialSituacao=='BLOQUEADO' && retorno.contratoResidencialStatus=='')
			mensagemFinal.push('Residencial: ' + 'STATUS VAZIO');
		else if(retorno.contratoResidencialConsulta=='API' && retorno.contratoResidencialSituacao=='BLOQUEADO' && retorno.contratoResidencialStatus==''){
			mensagemFinal.push('Residencial: ' + '[ Falha ao consultar ]');
			component.set('v.hasServicoIndisponivel',true);
		}
		
		if(retorno.contratoMovelSituacao=='INADIMPLENTE' || (retorno.contratoMovelSituacao=='BLOQUEADO' && retorno.contratoMovelStatus!=''))
			mensagemFinal.push('Móvel: ' + retorno.contratoMovelStatus.toUpperCase() + (retorno.contratoMovelReason!='' ? ' - '+retorno.contratoMovelReason.toUpperCase() : ''));
		else if(retorno.contratoMovelConsulta=='SALESFORCE' && retorno.contratoMovelSituacao=='BLOQUEADO' && retorno.contratoMovelStatus=='')
			mensagemFinal.push('Móvel: ' + 'STATUS VAZIO');
		else if(retorno.contratoMovelConsulta=='API' && retorno.contratoMovelSituacao=='BLOQUEADO' && retorno.contratoMovelStatus==''){
			mensagemFinal.push('Móvel: ' + '[ Falha ao consultar ]');
			component.set('v.hasServicoIndisponivel',true);
		}

		if(component.get('v.hasServicoIndisponivel'))
			component.set('v.hasServicoIndisponivelComentario',mensagemFinal.join(', '));

		return mensagemFinal; 
	},

	desabilitarBotaoTodasOfertasMovelInadimplente : function(component, event, helper, ofertaSelecionada){
		var contratoResidencialInadimplente = component.get('v.contratoResidencialInadimplente');
		var contratoMovelInadimplente = component.get('v.contratoMovelInadimplente');

		component.set('v.desabilitarBotaoSelecionarOferta', false);

		if(contratoResidencialInadimplente || contratoMovelInadimplente){
			
			if(contratoResidencialInadimplente){
				var posse = component.get('v.produtoAtual');
				var tv = false;
				var bl = false;
				var fn = false;
				if(ofertaSelecionada.movimentBroadband != 'Downgrade' && ofertaSelecionada.movimentMobile != 'Downgrade' && ofertaSelecionada.movimentPhone != 'Downgrade' &&  ofertaSelecionada.movimentTv != 'Downgrade'){
					if(ofertaSelecionada.movimentBroadband != 'Upgrade' && ofertaSelecionada.movimentMobile != 'Upgrade' && ofertaSelecionada.movimentPhone != 'Upgrade' &&  ofertaSelecionada.movimentTv != 'Upgrade'){
						if(ofertaSelecionada.movimentBroadband != 'Aquisição' && ofertaSelecionada.movimentMobile != 'Aquisição' && ofertaSelecionada.movimentPhone != 'Aquisição' &&  ofertaSelecionada.movimentTv != 'Aquisição'){
							tv = this.verificarLateralInadimplencia(ofertaSelecionada.movimentTv,ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label,posse.tv[posse.techSelected].planTv.label, false);
							bl = this.verificarLateralInadimplencia(ofertaSelecionada.movimentBroadband,ofertaSelecionada.broadband.planBroadband.label,posse.broadband.planBroadband.label, false);
							fn = this.verificarLateralInadimplencia(ofertaSelecionada.movimentPhone,ofertaSelecionada.phone.planPhone.label,posse.phone.planPhone.label, false);
						}

					}
				}
				if(!(tv && bl && fn)){
					component.set('v.desabilitarBotaoSelecionarOferta', true);
				}
			}

			if(!component.get('v.desabilitarBotaoSelecionarOferta') && contratoMovelInadimplente){
				var posse = component.get('v.produtoAtual');
				var mv = false;
				if(ofertaSelecionada.movimentMobile != 'Downgrade'){
					if(ofertaSelecionada.movimentMobile != 'Upgrade'){
						if(ofertaSelecionada.movimentMobile != 'Aquisição'){
							mv = this.verificarLateralInadimplencia(ofertaSelecionada.movimentMobile,ofertaSelecionada.mobile.planMobile.label,posse.mobile.planMobile.label, true);			

						}
					}

				}
				if(!mv){
					component.set('v.desabilitarBotaoSelecionarOferta', true);
				}
			}
		}

	},

	verificarLateralInadimplencia : function( movimentacao, planOferta, planPosse, isMobile ){
		var result = false;
		if(movimentacao == 'Lateral'){
			if(planOferta == 'MANTER'){
				result = true;
			}
		}
		if(result==false && isMobile){
			if(movimentacao == 'Cancelamento'){
				if(planOferta == 'NÃO POSSUI'){
					result = true;
				}
			}
		}
		return result;
	},

	consultarPrecosPontosOpcionais: function (component) {
		var action = component.get('c.searchOptionalPointsPrices'); 
		action.setParams({
			"recordId": component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.lstPrecosPontosOpcionais', data);
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao consultar preços pontos opcionais!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
		});
		$A.enqueueAction(action);
	},
	
	recalculateOffers: function(component, event, helper) {
		component.set('v.showSpinner', true);
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		var lstPontuacao = component.get('v.lstPontuacao');
		var action = component.get('c.recalculateOffers_CC');
		action.setParams({
			"ofertaToCalculateJSON": JSON.stringify(component.get("v.newOffertas")),
			"recordId" : caseId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				this.roundOfferValues(data);

				let oferta1 = document.getElementById(helper.const.OFERTA_1);
				let oferta2 = document.getElementById(helper.const.OFERTA_2);
				let oferta3 = document.getElementById(helper.const.OFERTA_3);

				oferta1.classList.remove(helper.const.SELECTED);
				oferta2.classList.remove(helper.const.SELECTED);
				oferta3.classList.add(helper.const.SELECTED);

				component.set('v.isSelectedOffer', true);

				if(data.lstOffers != null){
					data.lstOffers = this.calculateOriginalValueOferta(component, data.lstOffers, data.currentProduct);
				}
				//component.set('v.oferta1', data.lstOffers[0]);
				//component.set('v.oferta2', data.lstOffers[1]);
				//component.set('v.selectedTv', data.lstOffers[2].tv[0]); //Alexandre AMARO
				component.set('v.tvSelected3', data.lstOffers[2].tv[0]); //Alexandre AMARO
				component.set('v.oferta3', data.lstOffers[2]);
				component.set('v.ofertaSelecionada', data.lstOffers[2]);
				component.set('v.ofertas', data);
				var NBAModalAdditionalsTV = component.find("modalAditionalsTV");
				var NBAModalAdditionalsBroadband = component.find("modalAditionalsBroadband");
				var NBAModalAdditionalsPhone = component.find("modalAditionalsPhone");
				var NBAModalAdditionalsMobile = component.find("modalAditionalsMobile");
				NBAModalAdditionalsTV.callUpdateAditionalsTV();
				component.set('v.calculate', true);
				NBAModalAdditionalsBroadband.callUpdateAditionalsBroadband();
				NBAModalAdditionalsPhone.callUpdateAditionalsPhone();
				NBAModalAdditionalsMobile.callUpdateAditionalsMobile();
				component.set('v.calculate', false);

				var ofertaSelecionada = component.get('v.ofertaSelecionada');
				// var produtoAtual = component.get('v.produtoAtual');

				var ofertaSelecionadaHasTv = ofertaSelecionada.tv[0].planTv.label;
				if (ofertaSelecionadaHasTv === 'NÃO POSSUI') {
					component.set('v.showAdditionalTv', true);
				} else {
					component.set('v.showAdditionalTv', false);
				}
				var ofertaSelecionadaHasBroadband = ofertaSelecionada.broadband.planBroadband.label;
				if (ofertaSelecionadaHasBroadband === 'NÃO POSSUI') {
					component.set('v.showAdditionalBroadband', true);
				} else {
					component.set('v.showAdditionalBroadband', false);
				}
				var ofertaSelecionadaHasPhone = ofertaSelecionada.phone.planPhone.label;
				if (ofertaSelecionadaHasPhone === 'NÃO POSSUI') {
					component.set('v.showAdditionalPhone', true);
				} else {
					component.set('v.showAdditionalPhone', false);
				}
				var ofertaSelecionadaHasMobile = ofertaSelecionada.mobile.planMobile.label;
				if (ofertaSelecionadaHasMobile === 'NÃO POSSUI') {
					component.set('v.showAdditionalMobile', true);
				} else {
					component.set('v.showAdditionalMobile', false);
				}
				if(lstPontuacao != null && lstPontuacao.length > 0){
					this.calculoPercentualRecalculate(component, event, helper, lstPontuacao);
				}
				if(data.currentProduct && data.lstOffers){
				//	this.calculateOriginalValuePosse(component, data.currentProduct);
					//this.calculateOriginalValueOferta(component, data.lstOffers);	
				}
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao consultar!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},
	setSelectedOfferVisual: function (component, event, helper) {
		var selectedOffer = document.getElementById(helper.const.OFERTA_3);
		selectedOffer.classList.add(helper.const.SELECTED);
		component.set('v.' + helper.const.OFERTA_3 + '.selected', true);
		component.set('v.ofertaSelecionada', component.get('v.' + helper.const.OFERTA_3));
	},

	updateStageAndExceptionNoReturn: function(component, Exceptions) {

		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		var action = component.get('c.updateStageAndExceptionNoReturn');
		action.setParams({
			"recordId": caseId,
			"Exceptions": Exceptions
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.getEvent("refresh").fire();
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao atualizar o caso!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
		});
		$A.enqueueAction(action);
	},
	getMockTaxas : function (component){
		var action = component.get('c.getIsencaoTaxas');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = JSON.parse(response.getReturnValue());
				var listTaxas = [];	
				console.log(data);
				for (var i = 0; i < data.length; i++) {
					console.log(data[i].TipoExibido__c);
					listTaxas.push({
						label: data[i].TipoExibido__c,
						preco: data[i].Valor__c,
						tipo: data[i].Tipo__c,
						checked: false
					});
				}
				component.set("v.lstIsencoesTaxas",listTaxas);
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao consultar as isenções!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
		});
		$A.enqueueAction(action);
	},
	// Alexandre Amaro API EXTRAS para posse atual 
	recalculateCurrentProduct: function(component) {


		component.set('v.showSpinner', true);
		var tipo = component.get('v.typeModal');
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
        var isPurple = component.get('v.isPurple');
		var isRetencao = component.get('v.isRetencao');
		var mobileEmpty = { "technology": "", "totalValue": 0, "additionalMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0 }, "key": "", "label": "Adicionais", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "additionalPromoValue": 0, "addOptions": { "lstAdditionals": [] }, "dependentslMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0 }, "key": "", "label": "", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "difAdditionals": 0, "difAdditionalsStep": { "label": "", "value": 0 }, "difDependents": 0, "difDependentsStep": { "label": "", "value": 0 }, "difProducts": 0, "difProductsStep": { "label": "", "value": 0 }, "feeProducts": [], "isComboMulti": false, "listaDependentesMobile": [], "listaDependentesMobileSelected": [], "lstAdditionals": [], "msisdn": "", "name": "", "netsalesProductName": "", "numeroDependentesDados": 0, "numeroDependentesDadosOriginal": 0, "numeroDependentesDadosSelected": 0, "numeroDependentesVozDados": 0, "numeroDependentesVozDadosOriginal": 0, "numeroDependentesVozDadosSelected": 0, "numeroDependentesControle": 0, "numeroDependentesControleOriginal": 0, "numeroDependentesControleSelected": 0, "numeroMaxDep": 0, "planMobile": { "fidelity": { "hasFidelity": false, "hasPenalty": false, "penalty": 0, "remainingDays": 0, "startDate": "2015-09-25" }, "key": "380465365", "label": "NÃO POSSUI", "lstPromotions": [], "nameLegacy": "", "originalValue": 0, "quantity": 0, "value": 0 }, "posseAtual": false, "productDetail": "", "promotionName": "", "speed": "", "svas": [], "titularesOferta": [], "titularMobile": { "catalogName": "", "checked": true, "dependentType": "", "disabled": true, "disabledNew": false, "discountPromo": 0, "feeProducts": [], "fidelity": false, "listBeneficiosDoPlano": [], "listProdutosAdicionais": [], "nameLegacy": "", "nomePlano": "", "numeroTelefone": "", "operadora": "", "origem": "", "portabilityRequestType": "", "productName": "", "promoSelected": "", "promotionName": "", "technology": "", "validFor": 0, "valorProduto": 0 }, "totalDados": 0, "totalDadosOriginal": 0, "totalDadosSelected": 0, "totalDependentes": 0, "totalDependentesSelected": 0, "totalVozDados": 0, "totalVozDadosOriginal": 0, "totalVozDadosSelected": 0, "totalVozControle": 0, "totalControleOriginal": 0, "totalControleSelected": 0 };
		var mobile = component.get('v.produtoAtual.mobile');
		var totalValue = component.get('v.produtoAtual.totalValue'); 
		var totalValueOriginal = component.get('v.produtoAtual.totalValueOriginal'); 


		var action = component.get('c.recalculateCurrentProduct');
		action.setParams({
			"ofertaToCalculateJSON": JSON.stringify(component.get("v.fristOffers")),
			"recordId" : caseId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				data.currentProduct = this.calculateOriginalValuePosse(component, data.currentProduct); 
				component.set('v.produtoAtual', data.currentProduct);

				component.set('v.produtoAtual.mobile', mobile);
				component.set('v.produtoAtual.totalValue', totalValue);
				component.set('v.produtoAtual.totalValueOriginal', totalValueOriginal);

				component.set('v.ofertaSelecionada', data.currentProduct);
				component.set('v.selectedTv', data.currentProduct.tv[0]);
				component.set('v.ofertas', data);
 				if(!isPurple && isRetencao){
					if(component.get('v.produtoAtual.mobile.planMobile.label') != 'NÃO POSSUI'){
						var total = component.get('v.produtoAtual.totalValue');
						var totalDebitar = 0 ;
						totalDebitar += component.get('v.produtoAtual.mobile.planMobile.value');
						totalDebitar += component.get('v.produtoAtual.mobile.totalValue');
						totalDebitar += component.get('v.produtoAtual.mobile.totalVozDados');
						totalDebitar += component.get('v.produtoAtual.mobile.totalVozDadosSelected');
					if(totalDebitar != 0){
						total = total - totalDebitar;
					}else{
						totalDebitar = 0;
						total = total - totalDebitar;
					}
						component.set('v.produtoAtual.mobile.planMobile.label', 'NÃO POSSUI');
						component.set('v.produtoAntigo.mobile.planMobile.label', 'NÃO POSSUI');
						component.set('v.produtoAtual.totalValue', total);
						component.set('v.produtoAntigo.totalValue', total); 
						component.set('v.produtoAtual.mobile', mobileEmpty);
						component.set('v.produtoAntigo.mobile', mobileEmpty);
					}
                    } else if(isPurple && isRetencao){
                        if(component.get('v.produtoAtual.mobile.planMobile.label') == 'NÃO POSSUI'){
                            component.set('v.produtoAntigo.mobile', mobileEmpty);
                            component.set('v.produtoAtual.mobile', mobileEmpty);
                        } 
                    }
				if(tipo === 'TV'){
					var modalAditionalsTV = component.find("modalAditionalsTV");
					modalAditionalsTV.callIncluirAdicionaisTV();
				}else if(tipo === 'BL'){
					component.set('v.addExtrasBL', true);
				}
	/*			var NBAModalAdditionalsTV = component.find("modalAditionalsTV");
				var NBAModalAdditionalsBroadband = component.find("modalAditionalsBroadband");
				var NBAModalAdditionalsPhone = component.find("modalAditionalsPhone");
				var NBAModalAdditionalsMobile = component.find("modalAditionalsMobile");
				NBAModalAdditionalsTV.callUpdateAditionalsTV();
				NBAModalAdditionalsBroadband.callUpdateAditionalsBroadband();
				NBAModalAdditionalsPhone.callUpdateAditionalsPhone();
				NBAModalAdditionalsMobile.callUpdateAditionalsMobile();
				var ofertaSelecionada = component.get('v.ofertaSelecionada');
				var ofertaSelecionadaHasTv = ofertaSelecionada.tv[0].planTv.label;
				if (ofertaSelecionadaHasTv === 'NÃO POSSUI') {
					component.set('v.showAdditionalTv', true);
				} else {
					component.set('v.showAdditionalTv', false);
				}
				var ofertaSelecionadaHasBroadband = ofertaSelecionada.broadband.planBroadband.label;
				if (ofertaSelecionadaHasBroadband === 'NÃO POSSUI') {
					component.set('v.showAdditionalBroadband', true);
				} else {
					component.set('v.showAdditionalBroadband', false);
				}
				var ofertaSelecionadaHasPhone = ofertaSelecionada.phone.planPhone.label;
				if (ofertaSelecionadaHasPhone === 'NÃO POSSUI') {
					component.set('v.showAdditionalPhone', true);
				} else {
					component.set('v.showAdditionalPhone', false);
				}
				var ofertaSelecionadaHasMobile = ofertaSelecionada.mobile.planMobile.label;
				if (ofertaSelecionadaHasMobile === 'NÃO POSSUI') {
					component.set('v.showAdditionalMobile', true);
				} else {
					component.set('v.showAdditionalMobile', false);
				} */
			} else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && errors[0].message) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'Erro ao consultar!',
							"message": errors[0].message,
							"type": "error",
							"mode": "sticky"
						});
						toastEvent.fire();
					}
				}
			}
			component.set('v.showSpinner', false);
		});
		$A.enqueueAction(action);
	},
	calculoPercentualRecalculate: function(component, event, helper, lstPontuacao) {
		if (lstPontuacao.length > 0) {
				var ofertaSelecionada = component.get('v.ofertaSelecionada');
				var produtoAntigo = component.get('v.produtoAntigo');
				var percentual = 100 * (ofertaSelecionada.totalValue / produtoAntigo.totalValue);
				for(var i = 0; i<lstPontuacao.length; i++){
					if(percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c){
						component.set('v.ofertaSelecionada.incentive', lstPontuacao[i].Pointing__c);
						break;
					}
				}
			}
		}, 
		 calculoPercentual: function (component, event, helper, lstPontuacao, lstOffers) {
			if(lstPontuacao && lstOffers){
			var produtoAntigo = component.get('v.produtoAntigo');
				for(var x = 0; x<lstOffers.length; x++ ){ 
					var percentual = 100 * (lstOffers[x].totalValue / produtoAntigo.totalValue);
					for(var i = 0; i<lstPontuacao.length; i++){
						if(percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c){
							lstOffers[x].incentive = lstPontuacao[i].Pointing__c;
							break;
						}
					}
				}
				component.set('v.ofertas.lstOffers', lstOffers);
			}

		}, 

	calculateOriginalValuePosse: function(component, produtoAtual) {
			var isPurple = component.get('v.isPurple');
			var isRetencao = component.get('v.isRetencao');
			var descontoDep = 0;
				var originalValue = 0; 
				var indexMaior = 0;	

		if (produtoAtual != null && produtoAtual.mobile != null) {
			var listDepAtual 	= produtoAtual.mobile.listaDependentesMobile;
			var descontoTitular = produtoAtual.mobile.descontoTitular;

		if (produtoAtual.lstSteps.length > 0) {
				for (var step = 0; step < produtoAtual.lstSteps.length; step++) {
					if (produtoAtual.lstSteps[step].label != null && parseInt(produtoAtual.lstSteps[step].label) > indexMaior) {
						indexMaior = parseInt(produtoAtual.lstSteps[step].label);
						originalValue = produtoAtual.lstSteps[step].value;
							produtoAtual.totalValueOriginal = originalValue;
					}
				}
			}
			if (listDepAtual.length > 0 && listDepAtual != null) {
				for (var index = 0; index < listDepAtual.length; index++) {

					listDepAtual[index].valueDependenteSemDesconto = listDepAtual[index].valorProduto;
					if (listDepAtual[index].checked) {
						if (listDepAtual[index].deducedPrice != null) {
									descontoDep += listDepAtual[index].deducedPrice;	
						}				
					}
				}
			}

			produtoAtual.mobile.listaDependentesMobile = listDepAtual;

			if(produtoAtual.mobile.mouseOverDependenteComDescontoBL != '0'){
				produtoAtual.totalValue = produtoAtual.totalValue - parseInt(produtoAtual.mobile.descontoDependenteBL);
			}
			if(produtoAtual.mobile.mouseOverDependenteComDescontoPG != '0'){
				produtoAtual.totalValue = produtoAtual.totalValue - parseInt(produtoAtual.mobile.descontoDependentePG);
			}
			if (produtoAtual.mobile.mouseOverDependenteComDescontoControle != '0') {
				produtoAtual.totalValue = produtoAtual.totalValue - parseInt(produtoAtual.mobile.descontoDependenteControle);
			}
			if(produtoAtual.mobile.planMobile.value > 0){
				produtoAtual.totalValue = produtoAtual.totalValue - produtoAtual.mobile.descontoTitular;
			} 
			if (produtoAtual.tv[0].additionalTv.lstPromotions.length > 0) {
				for (var tv = 0; tv < produtoAtual.tv[0].additionalTv.lstPromotions.length; tv++) {
					produtoAtual.totalValue = produtoAtual.totalValue - produtoAtual.tv[0].additionalTv.lstPromotions[tv].discount;
					}
				} 
				if(indexMaior == 0){
					var totalValue = produtoAtual.totalValue;
				var mobileValue = 0;
				if(produtoAtual.mobile.planMobile.label != 'NÃO POSSUI'){
					mobileValue = produtoAtual.mobile.planMobile.value != null && produtoAtual.mobile.planMobile.value > 0 ? produtoAtual.mobile.planMobile.value : 0;
				}
				produtoAtual.totalValueOriginal = totalValue + descontoDep + descontoTitular;
				if (!isPurple && isRetencao) {
					produtoAtual.totalValueOriginal = produtoAtual.totalValueOriginal - mobileValue;
				}
			} else {
				produtoAtual.totalValueOriginal = produtoAtual.totalValueOriginal + descontoDep + descontoTitular;		
				}
			if (produtoAtual.tv[0].additionalTv.lstPromotions.length > 0) {
				for (var atual = 0; atual < produtoAtual.tv[0].additionalTv.lstPromotions.length; atual++) {
					produtoAtual.totalValueOriginal = produtoAtual.totalValueOriginal + produtoAtual.tv[0].additionalTv.lstPromotions[atual].discount;
					}
				}
			}	
			return produtoAtual;			
		},


	calculateOriginalValueOferta: function(component, lstOffers, produtoAtual) {
		var originalValue = 0;
		var descontoDep		   = 0;
		var descontoTit		   = 0;
		var indexMaior 		   = 0;
		var listDepOffer	   = 0;
		var listDepProduto     = 0;
		var depComDesconto		= 0;
		var depSemDesconto		= 0;


		if(lstOffers){
				for(var x = 0; x<lstOffers.length; x++ ){
				listDepOffer   = lstOffers[x].mobile.listaDependentesMobile;
				listDepProduto = produtoAtual.mobile.listaDependentesMobile;
				indexMaior     = 0;
				descontoDep    = 0;
				descontoTit    = 0;


					if(lstOffers[x].lstSteps.length > 0){
						for(var i = 0; i<lstOffers[x].lstSteps.length; i++){				
							if(lstOffers[x].lstSteps[i].label != null && parseInt(lstOffers[x].lstSteps[i].label) > indexMaior){
								indexMaior = parseInt(lstOffers[x].lstSteps[i].label);
								originalValue = lstOffers[x].lstSteps[i].value;
								lstOffers[x].totalValueOriginal = originalValue;
								lstOffers[x].difTotal = lstOffers[x].totalValueOriginal - produtoAtual.totalValue;
							}			
						}
					}


				if(lstOffers[x].mobile.planMobile.label != 'MANTER'){
					if(listDepOffer.length > 0 && listDepOffer != null) {
						for (var index = 0; index < listDepOffer.length; index++) {
							if (listDepOffer[index].checked) {
								listDepOffer[index].valueDependenteSemDesconto = listDepOffer[index].valorProduto;
								//depComDesconto += listDepProduto[index].deducedPrice;
								//depSemDesconto += listDepProduto[index].valorProduto;
								if (listDepOffer[index].deducedPrice != null) {
									descontoDep += listDepOffer[index].deducedPrice;

								}
							}
						}
					}
				} else if (listDepProduto.length > 0 && listDepProduto != null) {
					for (var index = 0; index < listDepProduto.length; index++) {
						if (listDepProduto[index].checked) {
							listDepProduto[index].valueDependenteSemDesconto = listDepProduto[index].valorProduto;
							//depComDesconto += listDepProduto[index].deducedPrice;
							//depSemDesconto += listDepProduto[index].valorProduto;
							if (listDepProduto[index].deducedPrice != null) {
								descontoDep += listDepProduto[index].deducedPrice;
								descontoTit = produtoAtual.mobile.descontoTitular;
							}
						}
					}
				}
				lstOffers[x].totalValue -= descontoDep;
				lstOffers[x].totalValue -= descontoTit;

			if(indexMaior == 0){				
				var totalValue = lstOffers[x].totalValue;
					lstOffers[x].totalValueOriginal = totalValue + descontoDep + descontoTit;														
						} else {
				//	lstOffers[x].totalValueOriginal += descontoDep + descontoTit;																			
						}
					lstOffers[x].difTotal = lstOffers[x].totalValue - produtoAtual.totalValue;
					lstOffers[x].mobile.difProducts = lstOffers[x].mobile.planMobile.value - produtoAtual.mobile.planMobile.value;
					lstOffers[x].mobile.valueTitularSemDesconto = lstOffers[x].mobile.planMobile.value;
					//lstOffers[x].mobile.totalDependentes 			= depComDesconto;
					//lstOffers[x].mobile.totalDependentesSemDesconto = depSemDesconto;

					}
			}
		return lstOffers;
	},

	encerrarCaso: function(component) {        
		var action = component.get("c.encerramentoCaso");
		action.setParams({
			"recordId":				component.get('v.recordId'),
			"isRetencao":			component.get('v.isRetencao'),
			"servicoIndisponivel":	component.get('v.hasServicoIndisponivel'),
			"dadoInconsistente":	component.get('v.hasDadoInconsistente'),
			"textoComentario":      component.get('v.hasServicoIndisponivelComentario'),
            "isContractPME":		component.get('v.hasContractPME')
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.showSpinner', false );
				component.getEvent("refresh").fire();
			}
		});
		$A.enqueueAction(action);
	},


	listaDescontoDependentes : function(component, event, helper, oferta, posse){	
		if(posse.mobile.listaDependentesMobile != null){			
			for(var index = 0; index < posse.mobile.listaDependentesMobile.length; index++){
				posse.mobile.listaDependentesMobile[index].listDescontoDependente = oferta.mobile.listDescontoDependente;
				posse.mobile.listaDependentesMobile[index].listBonusDependente = oferta.mobile.listBonusDependente;
			}
		}
		return posse;
	},

	resetOrder : function(component, event) {
		let posse = component.get('v.hasPosse')
		let action = component.get('c.initOrder');

		action.setParams({
			'caseId': component.get('v.recordId'),
			'posseCliente': JSON.stringify(posse)
		});

		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state != 'SUCCESS') {
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					'title': 'Erro ao reinicar o pedido!',
					'message': 'Por favor, confirme se a tabulação está correta e se necessário, faça ajustes!',
					'type': 'error',
					'mode': 'dismissible'
				});
				toastEvent.fire();
	}

			let pageEvent = $A.get('e.c:NBA_PageEvent');
			pageEvent.setParams({'action' : 'FINISH_CASE'});

			pageEvent.fire();
		});

		$A.enqueueAction(action);

	}

})