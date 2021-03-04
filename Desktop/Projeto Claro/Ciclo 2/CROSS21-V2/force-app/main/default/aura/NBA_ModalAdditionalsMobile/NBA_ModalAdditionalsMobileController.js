({
	forceAdditionalMobile: function (component, event, helper) {
		if (component.get('v.forceAdditionalMobile') == true) {
			$A.enqueueAction(component.get('c.incluirAdicionaisMobile'));
			$A.enqueueAction(component.get('c.validateAdditionalsMobile'));
			component.set('v.forceAdditionalMobile', false);
		}
	},

	// oferta >> titular >> gera e seta infos obrigatórias (ao selecionar oferta) 
	loadAdditionalMobile: function (component, event, helper) {
		if (component.get('v.oferta') != null) {
			helper.carregarAdicionaisMobile(component, event, helper);
			$A.enqueueAction(component.get('c.validateAdditionalsMobile'));
		}
	},

	// oferta >> titular/dependente >> gera e seta infos gerais (ao abrir adicionais)
	incluirAdicionaisMobile: function (component, event, helper) {
		component.set('v.mobileBackup', JSON.parse(JSON.stringify(component.get('v.oferta.mobile'))));
		var disabled = component.get('v.disabledMobile');
		if (disabled === false)
			component.set('v.showAdditionalMobile', true);
		helper.carregarAdicionaisMobile(component, event, helper);
	},

	closeAdicionalMobile: function (component, event, helper) {
		component.set('v.showAdditionalMobile', false);

		// restore memorized relevant fields
		event.stopPropagation();
		component.get('v.mobileBackup.titularesOferta').forEach(function (backup, index) {
			component.set('v.oferta.mobile.titularesOferta[' + index + '].promocao', (typeof backup.promocao !== "undefined") ? backup.promocao : null);
			component.set('v.oferta.mobile.titularesOferta[' + index + '].origem', (typeof backup.origem !== "undefined") ? backup.origem : null);
		});
		component.set('v.oferta.mobile.titularMobile.promocao', (typeof component.get('v.mobileBackup.titularMobile.promocao') !== "undefined") ? component.get('v.mobileBackup.titularMobile.promocao') : null);
		component.set('v.oferta.mobile.titularMobile.origem', (typeof component.get('v.mobileBackup.titularMobile.origem') !== "undefined") ? component.get('v.mobileBackup.titularMobile.origem') : null);
		
		component.get('v.mobileBackup.listaDependentesMobilePosse').forEach(function (backup, index) {
			component.set('v.oferta.mobile.listaDependentesMobilePosse[' + index + '].checked',  backup.checked);
		});
	},

	resetOfferId: function (component, event, helper) {
		if (component.get('v.showAdditionalMobile') == false)
			component.set('v.offerId', '');
	},

	// oferta >> titular(novo)/dependente(novo) >> valida portabilidade/obrigatoriedade
	validateAdditionalsMobile: function (component, event, helper) {
		if (component.get('v.showAdditionalMobile') && component.get('v.dependentes').filter(dependent => dependent.utilizacao == '' || dependent.promocao == '').length > 0)
			helper.showToast('Preencha todos os campos', 'Você precisa preencher todos os campos da tela.', 'error');
		else {
			var portabilityPhones = component.get('v.showAdditionalMobile') ? helper.portabilityGetPhones(component) : [];
			if (portabilityPhones.length > 0) {
				component.set('v.showSpinner', true);
				helper.portabilityValidateNumberLength(component, portabilityPhones);
			}
			else
				$A.enqueueAction(component.get('c.updateAdditionalsMobile'));
		}

	},

	//Esta função deve ser chamada somente através do click do botão na tela
	//pois ela gera eventos, e se for chamada por algum aura:handler (change) ou aura:method
	//como o c.validateAdditionalsMobile, haverá inconsistências em caso de suspensão temporária
	handleUpdateAdditionalClick: function (component, event, helper) {
		$A.enqueueAction(component.get('c.validateAdditionalsMobile'));

		let pageEvent = $A.get('e.c:NBA_PageEvent');
		pageEvent.setParams({'action' : 'RESET_SUSPENSION'});
		pageEvent.fire();
	},

	// oferta >> movel/titular/dependente >> persiste alterações do usuário
	updateAdditionalsMobile: function (component, event, helper) {
		if (component.get('v.showAdditionalMobile')) component.set('v.showSpinner', true);

		var produtoAtual = component.get('v.produtoAtual');
		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.oferta');
		var lstPontuacao = component.get('v.lstPontuacao');
		var previousPromo = component.get('v.oferta.mobile.planMobile.lstPromotions[0]');
		var selectedOfferName = '';

		if (ofertaSelecionada === produtoAtual) {
			produtoAtual = helper.updateAdditionalsMobileHelper(component, produtoAtual, component.get('v.produtoAntigo'));
			produtoAtual = helper.calculateOriginalValue(component, produtoAtual);
			component.set('v.produtoAtual', produtoAtual);
		}
		else if (ofertaSelecionada === oferta1) {
			selectedOfferName = 'oferta1';
			if (oferta1.mobile.planMobile.label != "NÃO POSSUI") {
				oferta1 = helper.updateAdditionalsMobileHelper(component, oferta1, component.get('v.produtoAntigo'));
				oferta1 = helper.calculateOriginalValueOferta(component, oferta1);
				oferta1 = helper.validateDifStepAdditionals(produtoAtual, oferta1);
				oferta1 = helper.validateDifStepTotalValue(produtoAtual, oferta1);
			}
			component.set('v.oferta1', oferta1);
		}
		else if (ofertaSelecionada === oferta2) {
			selectedOfferName = 'oferta2';
			if (oferta2.mobile.planMobile.label != "NÃO POSSUI") {
				oferta2 = helper.updateAdditionalsMobileHelper(component, oferta2, component.get('v.produtoAntigo'));
				oferta2 = helper.calculateOriginalValueOferta(component, oferta2);
				oferta2 = helper.validateDifStepAdditionals(produtoAtual, oferta2);
				oferta2 = helper.validateDifStepTotalValue(produtoAtual, oferta2);
			}
			component.set('v.oferta2', oferta2);
		}
		else if (ofertaSelecionada === oferta3) {
			selectedOfferName = 'oferta3';
			oferta3 = helper.updateAdditionalsMobileHelper(component, oferta3, component.get('v.produtoAntigo'));
			oferta3 = helper.calculateOriginalValueOferta(component, oferta3);
			oferta3 = helper.validateDifStepAdditionals(produtoAtual, oferta3);
			oferta3 = helper.validateDifStepTotalValue(produtoAtual, oferta3);
			component.set('v.oferta3', oferta3);
		}

		helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);

		// atualiza steps e valores derivados dos steps
		if (component.get('v.showAdditionalMobile') && ofertaSelecionada.posseAtual && ofertaSelecionada.mobile.planMobile.label != 'MANTER') {
			var selectedOffer = component.get('v.' + selectedOfferName);
			var currentPromo = component.get('v.oferta.mobile.planMobile.lstPromotions[0]');

			// remove o step da promoção anterior, caso haja desconto nela
			if (previousPromo.valid > 0) {
				for (var index = 0; index < selectedOffer.lstSteps.length; index++)
					if (parseInt(selectedOffer.lstSteps[index].label) == previousPromo.valid) {
						selectedOffer.lstSteps.splice(index, 1);
						break;
					}
			}

			// subtrai valor da promoção anterior dos steps anteriores (descontado), e dos posteriores (cheio)
			for (var index = 0; index < selectedOffer.lstSteps.length; index++)
				if (parseInt(selectedOffer.lstSteps[index].label) < previousPromo.valid)
					selectedOffer.lstSteps[index].value -= previousPromo.value - (previousPromo.discount != null ? previousPromo.discount : 0);
				else
					selectedOffer.lstSteps[index].value -= previousPromo.value;

			// atualiza valor total (cheio/descontado)
			selectedOffer.totalValueOriginal -= previousPromo.value;
			selectedOffer.totalValueOriginal += currentPromo.value;
			selectedOffer.totalValue -= previousPromo.value;
			selectedOffer.totalValue += currentPromo.value;

			// atualiza diferença total (cheio/descontado)
			$A.enqueueAction(component.get('c.updateAdditionalsMobile'));

			// atualiza diferença do movel (s/ desconto)
			selectedOffer.mobile.difProductsStep.value -= previousPromo.value;
			selectedOffer.mobile.difProductsStep.value += currentPromo.value;
			selectedOffer.mobile.difProductsStep.label = currentPromo.valid.toString();

			// adiciona valor da promoção atual nos steps anteriores (descontado), e nos posteriores (cheio)
			for (var index = 0; index < selectedOffer.lstSteps.length; index++)
				if (parseInt(selectedOffer.lstSteps[index].label) < currentPromo.valid)
					selectedOffer.lstSteps[index].value += currentPromo.value - (currentPromo.discount != null ? currentPromo.discount : 0);
				else
					selectedOffer.lstSteps[index].value += currentPromo.value;

			// inclui o step da promoção atual, caso haja desconto nela
			if (currentPromo.valid > 0) {
				if (selectedOffer.lstSteps.length == 0)
					selectedOffer.lstSteps.push({ label: currentPromo.valid.toString(), value: selectedOffer.totalValueOriginal });
				else if (currentPromo.valid < parseInt(selectedOffer.lstSteps[0].label))
					selectedOffer.lstSteps.splice(0, 0, { label: currentPromo.valid.toString(), value: selectedOffer.lstSteps[index].value });
				else
					for (var index = 0; index < selectedOffer.lstSteps.length; index++) {
						if (currentPromo.valid > parseInt(selectedOffer.lstSteps[index].label) &&
							(index + 1 == selectedOffer.lstSteps.length || currentPromo.valid < parseInt(selectedOffer.lstSteps[index + 1].label))) {
							selectedOffer.lstSteps.splice(index + 1, 0, { label: currentPromo.valid.toString(), value: selectedOffer.lstSteps[index].value + currentPromo.discount });
							break;
						}
					}
			}

			component.set('v.' + selectedOfferName, selectedOffer);
		}
		component.set('v.showSpinner', false);

		component.set('v.showAdditionalMobile', false);
	},

	closemodalportabilidade: function (component, event, helper) {
		component.set('v.msgportabilidade', "");
	},

	addPoint: function (component, event, helper) {
		var checkOrder = event.getSource().get("v.name");
		var addOptions = component.get('v.oferta.tv.addOptions');
		if (checkOrder === '1') {
			addOptions.firstPoint.disabled = !addOptions.firstPoint.disabled;
			if (!addOptions.firstPoint.checked) {
				addOptions.firstPoint.label = '';
			}
		}
		else if (checkOrder === '2') {
			if (addOptions.firstPoint.label !== '') {
				addOptions.secondPoint.disabled = !addOptions.secondPoint.disabled;
			}
			if (!addOptions.secondPoint.checked) {
				addOptions.secondPoint.label = '';
			}
		}
		else if (checkOrder === '3') {
			if (addOptions.secondPoint.label !== '') {
				addOptions.thirdPoint.disabled = !addOptions.thirdPoint.disabled;
			}
			if (!addOptions.thirdPoint.checked) {
				addOptions.thirdPoint.label = '';
			}
		}
		else if (checkOrder === '4') {
			if (addOptions.thirdPoint.label !== '') {
				addOptions.fourthPoint.disabled = !addOptions.fourthPoint.disabled;
			}
			if (!addOptions.fourthPoint.checked) {
				addOptions.fourthPoint.label = '';
			}
		}
		else {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Campos obrigatórios!",
				"message": "Necessário preencher todas informações do ponto para passar para o próximo",
				"type": "error"
			});
			toastEvent.fire();
		}
		helper.updateOptionalPoints(component, addOptions);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	/*
	updateListDependentesMobile : function(component, event, helper){
		var novo = component.find('new').get('v.checked');
		if(novo){
			var listDependentesAPI = component.get('v.oferta.mobile.listaDependentesMobile');
			var objNovo = {"disabled":false,"checked":false,"disabledNew":true,"feeProducts":[],"listBeneficiosDoPlano":[],"listProdutosAdicionais":[],"nomePlano":"","numeroTelefone":"","operadora":"Claro","origem":"Novo","promoSelected":"","technology":"","valorProduto":0} ;
			listDependentesAPI.push(objNovo);
			component.set('v.oferta.mobile.listaDependentesMobile', listDependentesAPI);
			component.set('v.atualizarDependentesPosse', false);
			component.set('v.atualizarDependentesPosse', true);
			component.find('new').set('v.checked', false);
		}
	},
	*/

	alterarFlagDependente: function (component, event, helper) {
		if (!event.getSource().get("v.checked")) {
			var dependentes = component.get('v.dependentes');
			dependentes.splice(event.getSource().get("v.name"), 1);
			component.set('v.dependentes', dependentes);
			component.set('v.atualizarDependentesOferta', false);
			component.set('v.atualizarDependentesOferta', true);
		}
	},

	// *** oferta >> dependente(posse) >> atualiza listas valores/descontos
	updateAttChecked: function (component, event, helper) {
		component.set('v.hasDependentChanges', true);
		
		/* rever necessidade
		var index = event.getSource().get("v.name");

		var currentDependents = component.get('v.oferta.mobile.listaDependentesMobilePosse');
		var currentDependentValues = component.get('v.currentDependentValues');
		var currentDependentDiscounts = component.get('v.currentDependentDiscounts');

		// sincroniza lista não inicializada ???

		if (event.getSource().get("v.checked")) {
			for (let i = 0; i < currentDependents.length; i++) {
				if (i === index) {
					currentDependentValues.push(currentDependents[i].valorProduto);
					currentDependentDiscounts.push(currentDependents[i].deducedPrice);
				}
			}
		}

		// alguns indices errados ???

		else {
			if (currentDependents.length == currentDependentValues.length) {
				if (index == 0) {
					currentDependentValues.splice(index, 1);
					currentDependentDiscounts.splice(index, 1);
				}
				else {
					currentDependentValues.splice(index - 1, 1);
					currentDependentDiscounts.splice(index - 1, 1);
				}
			}
			else if (currentDependents.length > currentDependentValues.length) {
				if (index == 0) {
					currentDependentValues.splice(index, 1);
					currentDependentDiscounts.splice(index, 1);
				}
				else {
					currentDependentValues.splice(index, 1);
					currentDependentDiscounts.splice(index, 1);
				}
			}
		}

		component.set('v.currentDependentValues', currentDependentValues);
		component.set('v.currentDependentDiscounts', currentDependentDiscounts);
		*/
	},

	adicionarDependente: function (component, event, helper) {
		component.set('v.hasDependentChanges', true);
		let qtdPromoDepOferta = component.get('v.oferta.mobile.listaDependentesMobile.length');
		let qtdMaxDepOferta = component.get('v.oferta.mobile.numeroMaxDep');
		let QtdDepSelecOferta = component.get('v.dependentes.length');
		let QtdDepSelecPosse = component.get('v.produtoAtual.mobile.numeroMaxDep');

		if (component.get('v.frist')) {
			component.set("v.oldMaxDep", QtdDepSelecPosse);
			component.set('v.frist', false);
		}
		if (qtdPromoDepOferta == 0 || qtdMaxDepOferta == 0) {
			helper.showToast('Não disponível ', 'Não existem dependentes disponíveis para essa oferta!', 'error');
		}
		else if (QtdDepSelecPosse + QtdDepSelecOferta >= qtdMaxDepOferta) {
			helper.showToast('Número máximo de dependentes', 'Você atingiu o número máximo de dependentes!', 'error');
		}
		else {
			var dependentes = component.get('v.dependentes');
			var dependente = { "disabled": false, "checked": true, "Origem": "", "operadora": "", "numeroTelefone": "", "utilizacao": "", "promocao": "", "value": 0, "idDep": "", "listaUtilizacao": [], "listaPromocao": [], "beneficios": [] };
			dependentes.push(dependente);
			component.set('v.dependentes', dependentes);
			component.set('v.atualizarDependentesOferta', false);
			component.set('v.atualizarDependentesOferta', true);
		}
	},

	alterarOrigemDependente: function (component, event, helper) {
		var indice = event.getSource().get('v.name');
		var dependentes = component.get('v.dependentes');
		dependentes[indice].operadora = 'Claro';
		dependentes[indice].numeroTelefone = '';
		dependentes[indice].utilizacao = '';
		dependentes[indice].listaUtilizacao = [];
		dependentes[indice].promocao = '';
		dependentes[indice].listaPromocao = [];
		dependentes[indice].value = 0;
		dependentes[indice].beneficios = [];
		component.set('v.dependentes', dependentes);
		helper.obterUtilizacaoDependente(component, dependentes[indice].origem, indice);
	},

	onchageOrigemTitular: function (component, event, helper) {
		var origem = component.get('v.origemTitular');
		helper.getPromocaoTitularOferta(component, origem);
	},

	alterarUtilizacaoDependente: function (component, event, helper) {
		var indice = event.getSource().get('v.name');
		var dependentes = component.get('v.dependentes');
		dependentes[indice].promocao = '';
		dependentes[indice].listaPromocao = [];
		dependentes[indice].value = 0;
		dependentes[indice].beneficios = [];
		component.set('v.dependentes', dependentes);
		var origem = dependentes[indice].origem;
		var utilizacao = dependentes[indice].utilizacao;
		helper.obterPromocaoDependente(component, origem, utilizacao, indice);
	},

	alterarPromocaoDependente: function (component, event, helper) {
		var indice = event.getSource().get('v.name');

		var dependentes = component.get('v.dependentes');
		dependentes[indice].value = 0;
		dependentes[indice].beneficios = [];

		if (dependentes[indice].utilizacao != '') {
			component.get('v.oferta.mobile.listaDependentesMobile').forEach((promocaoDependente) => {
				let utilizacaoControle = promocaoDependente.nomePlano + ' - ' + promocaoDependente.familyName;
				if (helper.formatOrigem(promocaoDependente.portabilityRequestType) == dependentes[indice].origem &&
					(promocaoDependente.nomePlano == dependentes[indice].utilizacao || utilizacaoControle == dependentes[indice].utilizacao) &&
					promocaoDependente.promoSelected == dependentes[indice].promocao) {
					dependentes[indice].value = promocaoDependente.valorProduto;
					dependentes[indice].idDep = promocaoDependente.newId;
					dependentes[indice].beneficios = promocaoDependente.listBeneficiosDoPlano;
				}
			});
		}
		component.set('v.dependentes', dependentes);
	},

	// oferta >> titular(posse) >> promocao(ao alterar) >> seta promoção(valor), gera benifícios(lista)
	onchagePromocaoTitular: function (component, event, helper) {
		var promocao = component.get('v.promocaoTitular');
		component.set('v.oferta.mobile.titularMobile.promocao', promocao);
		var valor = 0;
		var beneficios = [];
		var listBeneficiosDoPlano = (component.get('v.oferta.mobile.planMobile.label') != 'MANTER' ? component.get('v.oferta.mobile.titularMobile.listBeneficiosDoPlano') : component.get('v.produtoAtual.mobile.titularMobile.listBeneficiosDoPlano'));
		if (listBeneficiosDoPlano != null && listBeneficiosDoPlano.length > 0)
			beneficios = beneficios.concat(listBeneficiosDoPlano).filter(Boolean);
		var listaTitulares = component.get('v.oferta.mobile.titularesOferta');
		component.set('v.idTitularOferta', '');
		for (var x = 0; x < listaTitulares.length; x++) {
			if (listaTitulares[x].promoSelected === promocao) {
				valor = listaTitulares[x].valorProduto - listaTitulares[x].discountPromo;
				beneficios = listaTitulares[x].listBeneficiosDoPlano;
				component.set('v.idTitularOferta', listaTitulares[x].newId);
			}
		}
		if (component.get('v.showAdditionalMobile')) {
			if (valor > 0)
				component.find('valorPromocaoTitular').set('v.value', valor);
			else
				component.find('valorPromocaoTitular').set('v.value', component.get('v.oferta.mobile.planMobile.originalValue'));
		}
		component.set('v.beneficionsPromocaoTitular', beneficios);
	},

	onchagePromocaoTitularOferta: function (component, event, helper) {
		var origem = component.get('v.origemTitular');
		var promocao = component.get('v.promocaoTitularOferta');
		component.set('v.oferta.mobile.titularMobile.promocao', promocao);
		var valor = 0;
		var beneficios = new Set();
		component.set('v.idTitularOferta', '');
		component.get('v.oferta.mobile.titularesOferta').forEach((promocaoTitular) => {
			if (promocaoTitular.promoSelected == promocao && helper.formatOrigem(promocaoTitular.portabilityRequestType) == origem) {
				valor = promocaoTitular.valorProduto - promocaoTitular.discountPromo;
				beneficios = promocaoTitular.listBeneficiosDoPlano;
				component.set('v.idTitularOferta', promocaoTitular.newId);
			}
		});
		component.set('v.beneficionsPromocaoTitular', Array.from(beneficios));
		if (component.get('v.showAdditionalMobile')) {
			if (valor > 0)
				component.find('valorPromocaoTitular').set('v.value', valor);
			else
				component.find('valorPromocaoTitular').set('v.value', component.get('v.oferta.mobile.planMobile.originalValue'));
		}
	},

	mascaraTelefone: function (component, event) {
		var list = component.get('v.dependentes');
		var index = event.getSource().get('v.name');
		var valor = event.getSource().get('v.value');
		var valorNovo = valor.replace(/[^0-9]/, '').replace(/(\d{2})(\d{5})(\d{4})/, "(\$1)\$2-\$3");
		for (var x = 0; x < list.length; x++) {
			if (x === index) {
				list[x].numeroTelefone = valorNovo;
			}
		}
		component.set('v.dependentes', list);
	},

	mascaraTelefoneTitular: function (component, event) {
		var valor = event.getSource().get('v.value');
		var valorNovo = valor.replace(/[^0-9]/, '').replace(/(\d{2})(\d{5})(\d{4})/, "(\$1)\$2-\$3");
		component.find('numeroTelefoneTitular').set('v.value', valorNovo);
	},

	updateOfferDiffs : function(component, event, helper){
		for(var offerNumber=1; offerNumber<=3; offerNumber++){
			var offer = component.get('v.oferta'+offerNumber);
			var current = component.get('v.produtoAtual');

			helper.updateAdditionalsMobileHelper(component, offer, current); // difProducts
			helper.validateDifStepAdditionals(current, offer); // difAdditionals
			helper.validateDifStepTotalValue(current, offer);

			component.set('v.oferta'+offerNumber, offer);
		}
	},
})