({
	// oferta(!=posse) >> titular(novo)/dependente(novo) >> gera lista numeros portabilidade
	portabilityGetPhones: function (component) {
		var phones = new Set();
		if (component.get('v.origemTitular') == 'Portabilidade')
			phones.add({ isHolder: true, number: component.get('v.numeroTelefoneTitularOferta').replace(/[^0-9]+/g, ''), message: '' });
		component.get('v.dependentes')
			.filter(dependent => dependent.origem == 'Portabilidade')
			.forEach(dependent => phones.add({ isHolder: false, number: dependent.numeroTelefone.replace(/[^0-9]+/g, ''), message: '' }));
		return Array.from(phones);
	},

	portabilityValidateNumberLength: function (component, phones) {
		phones.filter(phone => phone.number.length != 11).forEach(phone => phone.message = $A.get("$Label.c.NBA_PortabilityIncompleteNumber"));
		if (phones.filter(phone => phone.message == '').length == 0)
			this.portabilityRenderMessages(component, phones, false);
		else
			this.portabilityValidateDuplicateNumber(component, phones);
	},

	portabilityValidateDuplicateNumber: function (component, phones) {
		var phonesComp = JSON.parse(JSON.stringify(phones.filter(phone => phone.message == '')));
		phones.filter(phone => phone.message == '').forEach((phone, index) => {
			phonesComp.filter(phoneComp => phoneComp.message == '').forEach((phoneComp, indexComp) => {
				if (index != indexComp && phone.number == phoneComp.number)
					phone.message = $A.get("$Label.c.NBA_PortabilityDuplicateNumber");
			});
		});

		if (phones.filter(phone => phone.message == '').length == 0)
			this.portabilityRenderMessages(component, phones, false);
		else
			this.portabilityPerformPreAnalysis(component, phones);
	},

	portabilityPerformPreAnalysis: function (component, phones) {
		var phoneNumbers = new Set();
		phones.filter(phone => phone.message == '').forEach(phone => phoneNumbers.add(phone.number));
		var action = component.get("c.portabilityPerformPreAnalysis");
		action.setParams({ "phoneNumbers": Array.from(phoneNumbers) });
		action.setCallback(this, function (response) {
			if (response.getState() != "SUCCESS" || (response.getState() == "SUCCESS" && (!(JSON.parse(response.getReturnValue())).success ||
				typeof (JSON.parse((JSON.parse(response.getReturnValue())).body)).data.portabilty === "undefined")))
				this.portabilityRenderMessages(component, phones, $A.get("$Label.c.NBA_PortabilityAPIUnavailable"));
			else {
				var unavailables = (JSON.parse((JSON.parse(response.getReturnValue())).body)).data.portabilty.unavailables;
				if (Array.isArray(unavailables))
					unavailables.forEach(unavailable => unavailable.tickets.forEach(ticket =>
						phones.filter(phone => phone.message == '' && phone.number == ticket.telephoneNumber.number).forEach(phone => {
							if (unavailable.reasonId == 'BILHETE_PRE_EXISTENTE')
								phone.message = $A.get("$Label.c.NBA_PortabilityInProgress");
							else if (unavailable.reasonId == 'NUMERO_NA_CLARO')
								phone.message = $A.get("$Label.c.NBA_PortabilityAlreadyClaro");
							else if (unavailable.reasonId == 'PREFIXO_NAO_CADASTRADO')
								phone.message = $A.get("$Label.c.NBA_PortabilityInvalidNumber");
						})
					));
				if (phones.filter(phone => phone.message == '').length == 0)
					this.portabilityRenderMessages(component, phones, null);
				else
					this.portabilityValidateMatchingDDD(component, phones);
			}
		});
		$A.enqueueAction(action);
	},

	portabilityValidateMatchingDDD: function (component, phones) {
		var action = component.get("c.portabilityValidateMatchingDDD");
		action.setParams({ "caseId": component.get("v.caseId") });
		action.setCallback(this, function (response) {
			if (response.getState() != "SUCCESS" || (response.getState() == "SUCCESS" && (!(JSON.parse(response.getReturnValue())).success ||
				!Array.isArray((JSON.parse((JSON.parse(response.getReturnValue())).body)).data.address))))
				this.portabilityRenderMessages(component, phones, $A.get("$Label.c.NBA_PortabilityAPIUnavailable"));
			else {
				var ddd = (JSON.parse((JSON.parse(response.getReturnValue())).body)).data.address[0].ddd;
				phones.filter(phone => phone.message == '' && phone.number.substring(0, 2) != ddd).forEach(phone => phone.message = $A.get("$Label.c.NBA_PortabilityDivergentDDD"));
				if (phones.filter(phone => phone.isHolder && phone.message == '').length == 0)
					this.portabilityRenderMessages(component, phones, null);
				else
					this.portabilityValidateOwnership(component, phones);
			}
		});

		$A.enqueueAction(action);
	},

	portabilityValidateOwnership: function (component, phones) {
		var phoneNumber = '';
		phones.filter(phone => phone.isHolder && phone.message == '').forEach(phone => phoneNumber = phone.number);
		var action = component.get("c.portabilityValidateOwnership");
		action.setParams({ "cityId": component.get('v.cityCode'), "phoneNumber": phoneNumber, "caseId": component.get("v.caseId") });

		action.setCallback(this, function (response) {
			if (response.getState() != "SUCCESS" || (response.getState() == "SUCCESS" && (!(JSON.parse(response.getReturnValue())).success ||
				typeof (JSON.parse((JSON.parse(response.getReturnValue())).body)).data.ownershipStatus === "undefined")))
				this.portabilityRenderMessages(component, phones, $A.get("$Label.c.NBA_PortabilityAPIUnavailable"));
			else {
				if ((JSON.parse((JSON.parse(response.getReturnValue())).body)).data.ownershipStatus != '1')
					this.portabilityRenderMessages(component, phones, $A.get("$Label.c.NBA_PortabilityDivergentOwner"));
				else
					this.portabilityRenderMessages(component, phones, null);
			}
		});
		$A.enqueueAction(action);
	},

	portabilityRenderMessages: function (component, phones, infoMessage) {
		var holderInput = Array.isArray(component.find("numeroTelefoneTitular")) ? component.find("numeroTelefoneTitular")[0] : (
			typeof component.find("numeroTelefoneTitular") == "object" ? component.find("numeroTelefoneTitular") : false);
		if (holderInput) {
			holderInput.setCustomValidity("");
			phones.filter(phone => phone.message != '' && phone.isHolder).forEach(function (phone) {
				holderInput.setCustomValidity(phone.message);
			});
			holderInput.reportValidity();
		}

		var dependentInputs = Array.isArray(component.find("numeroTelefoneDependente")) ? component.find("numeroTelefoneDependente") : (
			typeof component.find("numeroTelefoneDependente") == "object" ? [component.find("numeroTelefoneDependente")] : false);
		if (dependentInputs) {
			dependentInputs.forEach(dependentInput => dependentInput.setCustomValidity(""));
			phones.filter(phone => phone.message != '' && !phone.isHolder).forEach(function (phone) {
				dependentInputs
					.filter(dependentInput => !dependentInput.get('v.disabled') && dependentInput.get('v.value').replace(/[^0-9]+/g, '') == phone.number)
					.forEach(dependentInput => dependentInput.setCustomValidity(phone.message));
			});
			dependentInputs.forEach(dependentInput => dependentInput.reportValidity());
		}

		if (phones.filter(phone => phone.message != '').length == 0) {
			$A.enqueueAction(component.get('c.updateAdditionalsMobile'));
			if (infoMessage != null && infoMessage != '')
				component.set('v.msgportabilidade', infoMessage);
		}
		else
			component.set('v.showSpinner', false);
	},

	FormatNumberphone: function (str) {

		//Filter only numbers from the input
		let cleaned = ('' + str).replace(/\D/g, '');

		//Check if the input is of correct length
		let match = cleaned.match(/^(\d{2})(\d{5})(\d{4})$/);
		if (match) {
			return '(' + match[1] + ') ' + match[2] + '-' + match[3]
		};
		return null
	},

	// oferta >> titular/dependente >> gera e seta informações gerais
	carregarAdicionaisMobile: function (component, event, helper) {
		this.obterOrigemDependente(component);

		// só busca quando é aquisição, pois quando já tem na posse, os valores estão fixos
		if (component.get('v.produtoAtual.mobile.planMobile.label') == 'NÃO POSSUI')
			this.getOrigemTitular(component);

		this.numeroDeDependentes(component);

		// só busca quando já tem na posse, pois quanto é aquisição, a propria origem dispara o carregamento das promos
		if (component.get('v.produtoAtual.mobile.planMobile.label') != 'NÃO POSSUI')
			this.getPromocaoTitular(component);
	},

	// oferta >> movel >> seta valor-total(c/desc.), valor-original(s/desc.), dif-total(c/desc.)
	updateAdditionalsMobileHelper: function (component, offer, produtoAntigo) {	

		offer.totalValue += Math.abs(offer.mobile.titularMobile.discountPromo);
		offer.totalValue -= Math.abs(offer.mobile.totalDependentes);
		offer.totalValue -= Math.abs(offer.mobile.totalDependentesSelected);

		offer.totalValueOriginal -= Math.abs(offer.mobile.totalDependentes);
		offer.totalValueOriginal -= Math.abs(offer.mobile.totalDependentesSelected);
		offer.mobile.listaDependentesMobilePosse
			.filter(dependent => dependent.previousChecked && dependent.valorProduto>0 && dependent.possessionDiscount>0)
			.forEach(dependent => offer.totalValueOriginal -= dependent.possessionDiscount);

		offer.mobile.listaDependentesMobilePosse
			.forEach(dependent => dependent.previousChecked = dependent.checked);
		
		this.dependentesPosseAtual(component);
		this.getValuesDep(component);
		
		var steps = offer.lstSteps;
		if (steps.length > 0) {
			for (var step = 0; step < steps.length; step++) {
				steps[step].value += offer.mobile.totalDependentesSelected;
			}
		}

		offer.totalValue -= offer.mobile.titularMobile.discountPromo;
		offer.totalValue += offer.mobile.totalDependentes;
		offer.totalValue += offer.mobile.totalDependentesSelected;
		
		offer.totalValueOriginal += offer.mobile.totalDependentes;
		offer.totalValueOriginal += offer.mobile.totalDependentesSelected;
		offer.mobile.listaDependentesMobilePosse
			.filter(dependent => dependent.checked && dependent.valorProduto>0 && dependent.possessionDiscount>0)
			.forEach(dependent => offer.totalValueOriginal += dependent.possessionDiscount);

		offer.difTotal = offer.totalValue - component.get('v.produtoAtual.totalValue');
		offer.mobile.difProducts = offer.mobile.planMobile.value - component.get('v.produtoAtual.mobile.planMobile.value');
		return offer;
	},

	calcDependenteMobile: function (component, event, offer) {
		var jsonOffer = JSON.stringify(offer);
		var action = component.get("c.calculateDependenteMobile");
		action.setParams({
			"jsonProdutoAtual": jsonOffer
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
			}
		});
		$A.enqueueAction(action);
		component.set('v.produtoAtual', produtoAtual);
		return offer;
	},

	validateDifAdditionals: function (current, offer) {
		var lstAdditionalsOffer = offer.mobile.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.mobile.addOptions.lstAdditionals;
		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;
		for (var i in lstAdditionalsCurrent) {
			var add = lstAdditionalsCurrent[i];
			if (add.checked) {
				if (add.promoSelected) {
					totalAdditionalsCurrent += add.lstPromotions[add.promoSelected].value;
				}
				else {
					totalAdditionalsCurrent += add.value;
				}
			}
		}
		for (var i in lstAdditionalsOffer) {
			var add = lstAdditionalsOffer[i];
			if (add.checked) {
				if (add.promoSelected) {
					totalAdditionalsOffer += add.lstPromotions[add.promoSelected].value;
				}
				else {
					totalAdditionalsOffer += add.value;
				}
			}
		}
		var difAdditionals = totalAdditionalsOffer - totalAdditionalsCurrent;
		return difAdditionals;
	},

	// oferta(!=posse) >> adicionais >> seta mouse over da diferença de adicionais móveis
	validateDifStepAdditionals: function (current, offer) {
		var lstAdditionalsOffer = offer.mobile.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.mobile.addOptions.lstAdditionals;
		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;
		var valids = [];
		for (var i in lstAdditionalsCurrent) {
			var add = lstAdditionalsCurrent[i];
			if (add.checked) {
				if (add.promoSelected) {
					valids.push(add.lstPromotions[add.promoSelected].valid);
				}
				totalAdditionalsCurrent += add.value;
			}
		}
		for (var i in lstAdditionalsOffer) {
			var add = lstAdditionalsOffer[i];
			if (add.checked) {
				if (add.promoSelected) {
					valids.push(add.lstPromotions[add.promoSelected].valid);
				}
				totalAdditionalsOffer += add.value;
			}
		}
		var maxValid = 0;
		if (valids.length > 0) {
			for (var x in valids) {
				if (parseInt(valids[x]) > maxValid) {
					maxValid = parseInt(valids[x]);
				}
			}
		}
		if (current.mobile.dependentsMobile) {
			offer.mobile.difAdditionalsStep.value -= current.mobile.dependentsMobile.value;
		}
		if (offer.mobile.dependentsMobile) {
			offer.mobile.difAdditionalsStep.value += offer.mobile.dependentsMobile.value;
		}
		offer.mobile.difAdditionalsStep.label = maxValid > 0 ? maxValid : '';
		offer.mobile.difAdditionalsStep.value = (totalAdditionalsOffer - totalAdditionalsCurrent).toFixed(2);
		return offer;
	},

	// oferta(!=posse) >> geral >> seta mouseover da diferença da oferta toda
	validateDifStepTotalValue: function (current, offer) {
		var lstStepsOffer = offer.lstSteps;
		var lstStepsCurrent = current.lstSteps;
		var lastStepOffer;
		var lastStepCurrent;
		if (lstStepsOffer) {
			lastStepOffer = lstStepsOffer[lstStepsOffer.length - 1];
		}
		if (lstStepsCurrent) {
			lastStepCurrent = lstStepsCurrent[lstStepsCurrent.length - 1];
		}
		if (lastStepOffer && lastStepCurrent) {
			if (lastStepOffer.value > 0 && lastStepCurrent.value > 0) {
				offer.difTotalStep.value = (lastStepOffer.value - lastStepCurrent.value).toFixed(2);
			}
			else if (lastStepOffer.value > 0) {
				offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
			}
			else if (lastStepCurrent.value > 0) {
				offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
			}
		}
		else if (lastStepOffer) {
			offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
		}
		else if (lastStepCurrent) {
			offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
		}
		var valids = [];
		for (var off in lstStepsOffer) {
			var step = lstStepsOffer[off];
			valids.push(step.label);
		}
		for (var cur in lstStepsCurrent) {
			var step = lstStepsCurrent[cur];
			valids.push(step.label);
		}
		var maxValid = 0;
		if (valids.length > 0) {
			for (var x in valids) {
				if (parseInt(valids[x]) > maxValid) {
					maxValid = parseInt(valids[x]);
				}
			}
		}
		offer.difTotalStep.label = maxValid > 0 ? maxValid : '';
		return offer;
	},

	// oferta(!=posse) >> dependente(novo) >> converte oferta->tela 
	numeroDeDependentes: function (component) {
		var dependentes = [];
		component.get('v.oferta.mobile.listaDependentesMobileSelected').forEach((dependenteSelecionado) => {
			var dependente = { "disabled": false, "checked": true, "Origem": "", "operadora": "", "numeroTelefone": "", "utilizacao": "", "promocao": "", "value": 0, "idDep": "", "listaUtilizacao": [], "listaPromocao": [], "beneficios": [] };
			dependente.checked = true;
			dependente.origem = dependenteSelecionado.origem;
			dependente.disabled = false;
			dependente.operadora = dependenteSelecionado.operadora;
			dependente.numeroTelefone = dependenteSelecionado.numeroTelefone;
			dependente.utilizacao = dependenteSelecionado.utilizacao;
			dependente.listaUtilizacao = dependenteSelecionado.listaUtilizacao;
			dependente.promocao = dependenteSelecionado.promocao;
			dependente.listaPromocao = dependenteSelecionado.listaPromocao;
			dependente.value = dependenteSelecionado.value;
			dependente.beneficios = dependenteSelecionado.beneficios;
			dependente.idDep = dependenteSelecionado.newId;
			dependentes.push(dependente);
		});
		component.set('v.dependentes', dependentes);
		var oldMaxDep = component.get('v.oldMaxDep');
		if (oldMaxDep)
			component.set('v.produtoAtual.mobile.numeroMaxDep', oldMaxDep);
	},

	showToast: function (title, message, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message,
			"type": type
		});
		toastEvent.fire();
	},

	// oferta(!=posse) >> dependente(oferta novo) >> gera origem(lista)
	obterOrigemDependente: function (component) {
		var origensDependente = new Set();
		origensDependente.add('');
		component.get('v.oferta.mobile.listaDependentesMobile').forEach((promocaoDependente) => {
			origensDependente.add(this.formatOrigem(promocaoDependente.portabilityRequestType));
		});
		component.set('v.origensDependente', Array.from(origensDependente));
		this.dependentesPosseAtual(component);
	},

	getOrigemTitular: function (component) {
		var listaOrigem = new Set();
		component.get('v.oferta.mobile.titularesOferta').forEach((promocaoTitular) => {
			listaOrigem.add(this.formatOrigem(promocaoTitular.portabilityRequestType));
		});
		listaOrigem = Array.from(listaOrigem);
		component.set('v.listaOrigemTitular', listaOrigem);
		if (component.get('v.oferta.mobile.titularMobile.origem') != null && component.get('v.oferta.mobile.titularMobile.origem') == component.get('v.origemTitular'))
			this.getPromocaoTitularOferta(component, component.get('v.origemTitular'));
		else if (component.get('v.oferta.mobile.titularMobile.origem') != null)
			component.set('v.origemTitular', component.get('v.oferta.mobile.titularMobile.origem'));
		else if (listaOrigem.length > 0) {
			if (component.get('v.origemTitular') == listaOrigem[0])
				this.getPromocaoTitularOferta(component, component.get('v.origemTitular'));
			else
				component.set('v.origemTitular', listaOrigem[0]);
		}
	},

	obterUtilizacaoDependente: function (component, origem, indice) {
		var utilizacoesDependente = new Set();
		if (origem != '') {
			utilizacoesDependente.add('');
			component.get('v.oferta.mobile.listaDependentesMobile').forEach((promocaoDependente) => {
				if (this.formatOrigem(promocaoDependente.portabilityRequestType) == origem) {
					if (promocaoDependente.nomePlano == 'CONTROLE') {
						utilizacoesDependente.add(promocaoDependente.nomePlano + ' - ' + promocaoDependente.familyName);
					} else {
						utilizacoesDependente.add(promocaoDependente.nomePlano);
					}
				}
			});
		}
		var dependentes = component.get('v.dependentes');
		dependentes[indice].listaUtilizacao = Array.from(utilizacoesDependente);
		component.set('v.dependentes', dependentes);
	},

	obterPromocaoDependente: function (component, origem, utilizacao, indice) {
		var promocoesDependente = new Set();
		if (utilizacao != '') {
			promocoesDependente.add('');
			component.get('v.oferta.mobile.listaDependentesMobile').forEach((promocaoDependente) => {
				let utilizacaoControle = promocaoDependente.nomePlano + ' - ' + promocaoDependente.familyName;
				if (this.formatOrigem(promocaoDependente.portabilityRequestType) == origem && 
					(promocaoDependente.nomePlano == utilizacao || utilizacaoControle == utilizacao))
					promocoesDependente.add(promocaoDependente.promoSelected);
			});
		}
		var dependentes = component.get('v.dependentes');
		dependentes[indice].listaPromocao = Array.from(promocoesDependente);
		component.set('v.dependentes', dependentes);
	},

	duplicate: function (list) {
		var newList = [];
		for (var x = 0; x < list.length; x++) {
			if (!newList.includes(list[x])) {
				newList.push(list[x]);
			}
		}
		return newList;
	},

	// oferta >> titular >> gera promoção(lista), altera promoção(valor)
	getPromocaoTitular: function (component) {
		component.set('v.showPromocao', false);
		var listaTitular = component.get('v.oferta.mobile.titularesOferta');
		var listaPromocaoTitular = [];
		for (var x = 0; x < listaTitular.length; x++) {
			if (!listaPromocaoTitular.includes(listaTitular[x].promoSelected)) {
				listaPromocaoTitular.push(listaTitular[x].promoSelected);
			}
		}
		component.set('v.listaPromocaoTitular', listaPromocaoTitular);
		if (component.get('v.offerId') == component.get('v.oferta.key'))
			component.set('v.oferta.mobile.titularMobile.promocao', null);
		if (component.get('v.showAdditionalMobile'))
			component.set('v.offerId', component.get('v.oferta.key'));
		else
			component.set('v.offerId', '');
		if (component.get('v.oferta.mobile.titularMobile.promocao') != null && component.get('v.oferta.mobile.titularMobile.promocao') == component.get('v.promocaoTitular'))
			$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
		else if (component.get('v.oferta.mobile.titularMobile.promocao') != null)
			component.set('v.promocaoTitular', component.get('v.oferta.mobile.titularMobile.promocao'));
		else if (listaPromocaoTitular.length > 0) {
			if (component.get('v.promocaoTitular') == listaPromocaoTitular[0])
				$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
			else
				component.set('v.promocaoTitular', listaPromocaoTitular[0]);
		}
		else {
			var isDifferent = component.get('v.promocaoTitular') != '';
			component.set('v.promocaoTitular', '');
			if(!isDifferent)
				$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
		}
		component.set('v.showPromocao', true);
	},

	getPromocaoTitularOferta: function (component, origem) {
		component.set('v.oferta.mobile.titularMobile.origem', origem);
		if (component.get('v.showAdditionalMobile')) {
			if (origem == 'Portabilidade' && component.get('v.oferta.mobile.titularMobile.numeroTelefone') != null) {
				component.find('operadoraTitular').set('v.value', component.get('v.oferta.mobile.titularMobile.operadora'));
				component.find('numeroTelefoneTitular').set('v.value', component.get('v.oferta.mobile.titularMobile.numeroTelefone'));
			}
			else {
				component.find('operadoraTitular').set('v.value', 'Claro');
				component.find('numeroTelefoneTitular').set('v.value', '');
			}
		}
		component.set('v.showPromocao', false);
		var listaPromocaoTitular = new Set();
		component.get('v.oferta.mobile.titularesOferta').forEach((promocaoTitular) => {
			if (this.formatOrigem(promocaoTitular.portabilityRequestType) == origem)
				listaPromocaoTitular.add(promocaoTitular.promoSelected);
		});
		listaPromocaoTitular = Array.from(listaPromocaoTitular);
		component.set('v.listaPromocaoTitular', listaPromocaoTitular);
		if (component.get('v.offerId') == component.get('v.oferta.key'))
			component.set('v.oferta.mobile.titularMobile.promocao', null);
		if (component.get('v.showAdditionalMobile'))
			component.set('v.offerId', component.get('v.oferta.key'));
		else
			component.set('v.offerId', '');
		if (component.get('v.oferta.mobile.titularMobile.promocao') != null && component.get('v.oferta.mobile.titularMobile.promocao') == component.get('v.promocaoTitularOferta'))
			$A.enqueueAction(component.get('c.onchagePromocaoTitularOferta'));
		else if (component.get('v.oferta.mobile.titularMobile.promocao') != null)
			component.set('v.promocaoTitularOferta', component.get('v.oferta.mobile.titularMobile.promocao'));
		else if (listaPromocaoTitular.length > 0) {
			if (component.get('v.promocaoTitularOferta') == listaPromocaoTitular[0])
				$A.enqueueAction(component.get('c.onchagePromocaoTitularOferta'));
			else
				component.set('v.promocaoTitularOferta', listaPromocaoTitular[0]);
		}
		component.set('v.showPromocao', true);
	},

	formatOrigem: function (origem) {
		var retorno = '';
		if (origem == '1' || origem == '2')
			retorno = "Novo";
		else if (origem == '8' || origem == '9')
			retorno = "Portabilidade";
		return retorno;
	},

	// oferta >> dependente(posse) >> faz limpeza, seta contadores/totais por tipo 
	dependentesPosseAtual: function (component) {
		var listDepAtual = component.get('v.oferta.mobile.listaDependentesMobilePosse');
		var listDepAtualRefactored = [];
		var numeroDadosVoz = 0;
		var numeroDados = 0;
		var numeroControle = 0;
		var totalDadosVoz = 0;
		var totalDados = 0;
		var totalControle = 0;
		var totalDependentes = 0;
		for (var x = 0; x < listDepAtual.length; x++) {
			if (listDepAtual[x].valorProduto > 0) {
				var isIncluded = false;
				for (var y = 0; y < listDepAtualRefactored.length; y++) {
					if (listDepAtual[x].numeroTelefone == listDepAtualRefactored[y].numeroTelefone) {
						isIncluded = true;
						listDepAtualRefactored[y].valorProduto += listDepAtual[x].valorProduto;
					}
				}
					if (listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG') {
					if(!isIncluded)
						numeroDadosVoz++;
						totalDadosVoz = totalDadosVoz + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
					else if (listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL') {
					if(!isIncluded)
						numeroDados++;
						totalDados = totalDados + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
					else if (listDepAtual[x].checked && listDepAtual[x].nomePlano === 'CONTROLE') {
					if(!isIncluded)
						numeroControle++;
						totalControle = totalControle + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
				if(!isIncluded)
					listDepAtualRefactored.push(listDepAtual[x]);
				}
			}
		component.set('v.oferta.mobile.listaDependentesMobilePosse', listDepAtualRefactored);
		component.set('v.oferta.mobile.numeroDependentesVozDados', numeroDadosVoz);
		component.set('v.oferta.mobile.numeroDependentesDados', numeroDados);
		component.set('v.oferta.mobile.numeroDependentesControle', numeroControle);
		component.set('v.oferta.mobile.totalVozDados', totalDadosVoz);
		component.set('v.oferta.mobile.totalDados', totalDados);
		component.set('v.oferta.mobile.totalControle', totalControle);
		component.set('v.oferta.mobile.totalDependentes', totalDependentes);
	},

	// oferta(!=posse) >> dependente(novo) >> converte tela->oferta, seta contadores/totais por tipo
	// oferta(!=posse) >> titular >> seta titular(objeto)/promoção(valor)/valor(c/desc.)/origem/telefone/operadora
	getValuesDep: function (component) {
		var ofertaSelecionada = component.get('v.oferta');
		var steps = ofertaSelecionada.lstSteps;
		if (steps) {
			for (var x = 0; x < steps.length; x++) {
				steps[x].value -= ofertaSelecionada.mobile.totalDependentesSelected;
			}
		}
		component.set('v.oferta.lstSteps', steps);

		// dependentes pós pago (voz + dados)
		component.set('v.oferta.mobile.numeroDependentesVozDadosSelected', 0);
		component.set('v.oferta.mobile.totalVozDadosSelected', 0);

		// dependentes banda larga (dados)
		component.set('v.oferta.mobile.numeroDependentesDadosSelected', 0);
		component.set('v.oferta.mobile.totalDadosSelected', 0);

		// dependentes controle (controle)
		component.set('v.oferta.mobile.numeroDependentesControleSelected', 0);
		component.set('v.oferta.mobile.totalControleSelected', 0);
		
		component.set('v.oferta.mobile.totalDependentesSelected', 0);
		var totalDep = 0;

		//Alexandre Amaro (adicionar dependentes)
		var newDep = component.get('v.dependentes');
		var newList = [];
		if (newDep) {
			for (var x = 0; x < newDep.length; x++) {
				if (newDep[x].idDep != '') {
					var idDependente = newDep[x].idDep;
					for (var y = 0; y < ofertaSelecionada.mobile.listaDependentesMobile.length; y++) {
						if (ofertaSelecionada.mobile.listaDependentesMobile[y].newId === idDependente) {
							
							ofertaSelecionada.mobile.listaDependentesMobile[y].origem = newDep[x].origem;
							ofertaSelecionada.mobile.listaDependentesMobile[y].operadora = newDep[x].operadora;
							ofertaSelecionada.mobile.listaDependentesMobile[y].numeroTelefone = newDep[x].numeroTelefone;
							ofertaSelecionada.mobile.listaDependentesMobile[y].utilizacao = newDep[x].utilizacao;
							ofertaSelecionada.mobile.listaDependentesMobile[y].listaUtilizacao = newDep[x].listaUtilizacao;
							ofertaSelecionada.mobile.listaDependentesMobile[y].promocao = newDep[x].promocao;
							ofertaSelecionada.mobile.listaDependentesMobile[y].listaPromocao = newDep[x].listaPromocao;
							ofertaSelecionada.mobile.listaDependentesMobile[y].value = newDep[x].value;
							ofertaSelecionada.mobile.listaDependentesMobile[y].beneficios = newDep[x].beneficios;
							newList.push(ofertaSelecionada.mobile.listaDependentesMobile[y]);
							
							if (ofertaSelecionada.mobile.listaDependentesMobile[y].nomePlano === 'DADOS + VOZ') {
								component.set('v.oferta.mobile.numeroDependentesVozDadosSelected', component.get('v.oferta.mobile.numeroDependentesVozDadosSelected') + 1);
								component.set('v.oferta.mobile.totalVozDadosSelected', component.get('v.oferta.mobile.totalVozDadosSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
								component.set('v.oferta.mobile.totalDependentesSelected', component.get('v.oferta.mobile.totalDependentesSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
							}
							else if (ofertaSelecionada.mobile.listaDependentesMobile[y].nomePlano === 'DADOS') {
								component.set('v.oferta.mobile.numeroDependentesDadosSelected', component.get('v.oferta.mobile.numeroDependentesDadosSelected') + 1);
								component.set('v.oferta.mobile.totalDadosSelected', component.get('v.oferta.mobile.totalDadosSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
								component.set('v.oferta.mobile.totalDependentesSelected', component.get('v.oferta.mobile.totalDependentesSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
							}
							else if (ofertaSelecionada.mobile.listaDependentesMobile[y].nomePlano === 'CONTROLE') {
								component.set('v.oferta.mobile.numeroDependentesControleSelected', component.get('v.oferta.mobile.numeroDependentesControleSelected') + 1);
								component.set('v.oferta.mobile.totalControleSelected', component.get('v.oferta.mobile.totalControleSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
								component.set('v.oferta.mobile.totalDependentesSelected', component.get('v.oferta.mobile.totalDependentesSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
							}
						}
					}
				}
			}
			var listTitulares = component.get('v.oferta.mobile.titularesOferta');
			var newIdTittular = component.get('v.idTitularOferta');
			var promo = { valid: 0, discount: 0, value: 0, label: '' };
			var lstPromo = [];

			var telefoneAnterior = component.get('v.oferta.mobile.titularMobile.numeroTelefone');
			var operadoraAnterior = component.get('v.oferta.mobile.titularMobile.operadora');
			for (var x = 0; x < listTitulares.length; x++) {
				if (newIdTittular === listTitulares[x].newId) {
					promo.valid = listTitulares[x].validFor;
					promo.discount = listTitulares[x].discountPromo;
					promo.label = listTitulares[x].promoSelected;
					promo.value = listTitulares[x].valorProduto;
					var origem = component.get('v.oferta.mobile.titularMobile.origem');
					component.set('v.oferta.mobile.titularMobile', listTitulares[x]);
					component.set('v.oferta.mobile.titularMobile.origem', listTitulares[x].origem==null? origem : listTitulares[x].origem);
					component.set('v.oferta.mobile.titularMobile.promocao', listTitulares[x].promoSelected);
					component.set('v.oferta.mobile.planMobile.value', listTitulares[x].valorProduto - listTitulares[x].discountPromo);
					lstPromo = [promo];
				}
			}
			if (component.find('numeroTelefoneTitular') !== undefined && component.get('v.showAdditionalMobile')) {
				if (component.find('numeroTelefoneTitular').get('v.value') != '') {
					component.set('v.oferta.mobile.titularMobile.numeroTelefone', component.find('numeroTelefoneTitular').get('v.value'));
					component.set('v.oferta.mobile.titularMobile.operadora', component.find('operadoraTitular').get('v.value'));
				}
				else if (telefoneAnterior != null) {
					component.set('v.oferta.mobile.titularMobile.numeroTelefone', telefoneAnterior);
					component.set('v.oferta.mobile.titularMobile.operadora', operadoraAnterior);
				}
			}
			if (component.find('origemTitularOferta') !== undefined) {
				var origemTitularOferta = component.find('origemTitularOferta').get('v.value');
				if (origemTitularOferta) {
					component.set('v.oferta.mobile.titularMobile.origem', origemTitularOferta);
				}
			}
			component.set('v.oferta.mobile.planMobile.lstPromotions', lstPromo);

			component.set('v.oferta.mobile.listaDependentesMobileSelected', newList);
		}
	},

	// oferta >> seta potuação (p/ pedido)
	calculoPercentualRecalculate: function (component, event, helper, lstPontuacao, ofertaSelecionada, produtoAntigo) {
		if (lstPontuacao && ofertaSelecionada && produtoAntigo) {
			var percentual = 100 * (ofertaSelecionada.totalValue / produtoAntigo.totalValue);
			for (var i = 0; i < lstPontuacao.length; i++) {
				if (percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c) {
					component.set('v.oferta.incentive', lstPontuacao[i].Pointing__c);
					break;
				}
			}
		}
	},

	// ***oferta(posse) >> geral >> seta valor-total(c/desc.), valor-original(s/desc.)
	// oferta(posse) >> dependente >> seta mouse-over por tipo
	calculateOriginalValue: function (component, currentProduct) {
		
		var currentDependents = component.get('v.oferta.mobile.listaDependentesMobilePosse');
		
		/* rever necessidade
		var checkedCurrentDependentsValue = 0;
		var checkedCurrentDependentsDiscount = 0;
		var uncheckedCurrentDependentsValue = 0;
		var uncheckedCurrentDependentsDiscount = 0;
		
		var oldUncheckedCurrentDependentsValue = component.get('v.oldUncheckedCurrentDependentsValue');
		var oldUncheckedCurrentDependentsDiscount = component.get('v.oldUncheckedCurrentDependentsDiscount');
		var oldValueSemDescontoChecked = component.get('v.oldValueSemDescontoChecked');
		*/


			/* rever necessidade
			var originalValue = 0;
			var maxMonthStep = 0;
			if (currentProduct.lstSteps.length > 0) {
				for (var i = 0; i < currentProduct.lstSteps.length; i++) {
					if (currentProduct.lstSteps[i].label != null && parseInt(currentProduct.lstSteps[i].label) > maxMonthStep) {
						maxMonthStep = parseInt(currentProduct.lstSteps[i].label);
						originalValue = currentProduct.lstSteps[i].value;
						currentProduct.totalValueOriginal = originalValue;
					}
				}
			}

			for (var index = 0; index < currentDependents.length; index++) {
				if (currentDependents[index].checked) {
					checkedCurrentDependentsValue += currentDependents[index].valorProduto;
					checkedCurrentDependentsDiscount += currentDependents[index].deducedPrice;
				}
				else {
					uncheckedCurrentDependentsValue += currentDependents[index].valorProduto;
					uncheckedCurrentDependentsDiscount += currentDependents[index].deducedPrice;
				}
			}
			
			if (maxMonthStep == 0) {
				
				// não entra ???
				if (uncheckedCurrentDependentsDiscount > oldUncheckedCurrentDependentsDiscount) {
					currentProduct.totalValue -= ((uncheckedCurrentDependentsValue - uncheckedCurrentDependentsDiscount) - oldUncheckedCurrentDependentsDiscount);
					currentProduct.totalValue += oldUncheckedCurrentDependentsValue;
				}

				// sempre entra ??? 
				else if (uncheckedCurrentDependentsValue > 0 && uncheckedCurrentDependentsDiscount == 0) {
					// subtrai o mesmo dep várias vezes ???
					currentProduct.totalValue -= uncheckedCurrentDependentsValue;
				}

				if (uncheckedCurrentDependentsValue > oldUncheckedCurrentDependentsValue) {
					currentProduct.totalValueOriginal -= (uncheckedCurrentDependentsValue - oldUncheckedCurrentDependentsValue);
				}

				// considera valores apenas dos que foram manualmente checados/deschecados ???
				
				var currentDependentsValue = 0;
				var currentDependentValues = component.get('v.currentDependentValues');
				for (var index = 0; index < currentDependentValues.length; index++) {
					currentDependentsValue += currentDependentValues[index];
				}

				var currentDependentsDiscount = 0;
				var currentDependentDiscounts = component.get('v.currentDependentDiscounts');
				for (var index = 0; index < currentDependentDiscounts.length; index++) {
					currentDependentsDiscount += currentDependentDiscounts[index];
				}

				//DESCONTO POSSE - DIEGO
				if (oldUncheckedCurrentDependentsDiscount > 0 && oldUncheckedCurrentDependentsDiscount < currentDependentsDiscount && oldUncheckedCurrentDependentsDiscount < checkedCurrentDependentsDiscount) {
					currentProduct.totalValue += (currentDependentsDiscount - oldUncheckedCurrentDependentsDiscount);
				}
				else if (currentDependentsDiscount > oldUncheckedCurrentDependentsDiscount) {
					currentProduct.totalValue -= (currentDependentsDiscount - oldUncheckedCurrentDependentsDiscount);
				}
				else if (currentDependentsDiscount != oldUncheckedCurrentDependentsDiscount) {
					currentProduct.totalValue += currentDependentsDiscount;
				}
				else if (currentDependentsDiscount == oldUncheckedCurrentDependentsDiscount) {
					currentProduct.totalValue += (currentDependentsValue - currentDependentsDiscount);
				}

				if (currentDependentsValue > oldValueSemDescontoChecked && currentDependentsValue > uncheckedCurrentDependentsValue) {
					currentProduct.totalValueOriginal += (currentDependentsValue - oldValueSemDescontoChecked);
				}
				else if (currentDependentsValue < oldValueSemDescontoChecked) {
					var sumFinal = 0;
					if (currentDependentsValue > 0 && uncheckedCurrentDependentsValue > 0) {
						sumFinal = oldValueSemDescontoChecked - currentDependentsValue;
						currentProduct.totalValueOriginal += sumFinal;
					}
					else if (currentDependentsValue > 0) {
						sumFinal = oldValueSemDescontoChecked - currentDependentsValue;
						currentProduct.totalValueOriginal += (sumFinal - uncheckedCurrentDependentsValue);
					}
					else if (uncheckedCurrentDependentsValue > 0) {
						sumFinal = oldValueSemDescontoChecked - uncheckedCurrentDependentsValue;
						if (oldValueSemDescontoChecked == uncheckedCurrentDependentsValue) {
							currentProduct.totalValueOriginal += sumFinal;
						}
						else {
							currentProduct.totalValueOriginal += (sumFinal - uncheckedCurrentDependentsValue);
						}
					}
					if (uncheckedCurrentDependentsValue > 0 && currentDependentsValue == 0) {
						currentDependentsValue = sumFinal;
					}
					else if (uncheckedCurrentDependentsValue > 0) {
						currentDependentsValue += uncheckedCurrentDependentsValue;
					}
					else if (sumFinal > 0) {
						currentDependentsValue += sumFinal;
					}
				}
				else {
					if (currentDependentsValue > uncheckedCurrentDependentsValue) {
						currentProduct.totalValueOriginal += currentDependentsValue;
						currentDependentsValue += currentDependentsValue;
					}
				}
			}
			
			else {
				if (uncheckedCurrentDependentsDiscount > oldUncheckedCurrentDependentsDiscount) {
					currentProduct.totalValue -= uncheckedCurrentDependentsDiscount;
				}
				currentProduct.totalValueOriginal += currentProduct.totalValue;
				if (uncheckedCurrentDependentsValue > oldUncheckedCurrentDependentsValue) {
					currentProduct.totalValueOriginal -= uncheckedCurrentDependentsValue;
				}
			}
			*/

			var totalDepComDescontoPG = 0;
			var totalDepSemDescontoPG = 0;
			var descontoDependentePG = 0;

			var totalDepComDescontoBL = 0;
			var totalDepSemDescontoBL = 0;
			var descontoDependenteBL = 0;

			var totalDepComDescontoCTRL = 0;
			var totalDepSemDescontoCTRL = 0;
			var descontoDependenteCTRL = 0;

			for (var x = 0; x < currentDependents.length; x++) {
				if (currentDependents[x].checked && currentDependents[x].nomePlano === 'POS PG') {
					totalDepComDescontoPG += (currentDependents[x].valorProduto - currentDependents[x].deducedPrice);
					totalDepSemDescontoPG += currentDependents[x].valorProduto + currentDependents[x].possessionDiscount;
					descontoDependentePG += currentDependents[x].deducedPrice;
				}
				else if (currentDependents[x].checked && currentDependents[x].nomePlano === 'POS BL') {
					totalDepComDescontoBL += (currentDependents[x].valorProduto - currentDependents[x].deducedPrice);
					totalDepSemDescontoBL += currentDependents[x].valorProduto + currentDependents[x].possessionDiscount;
					descontoDependenteBL += currentDependents[x].deducedPrice;
				}
				else if (currentDependents[x].checked && currentDependents[x].nomePlano === 'CONTROLE') {
					totalDepComDescontoCTRL += (currentDependents[x].valorProduto - currentDependents[x].deducedPrice);
					totalDepSemDescontoCTRL += currentDependents[x].valorProduto + currentDependents[x].possessionDiscount;
					descontoDependenteCTRL += currentDependents[x].deducedPrice;
				}
			}

			component.get('v.oferta.mobile.listaDependentesMobileSelected').forEach(newDependent => {
				if (newDependent.nomePlano === 'DADOS + VOZ') {
					totalDepComDescontoPG += (newDependent.valorProduto - newDependent.deducedPrice);
					totalDepSemDescontoPG += newDependent.valorProduto;
					descontoDependentePG += newDependent.deducedPrice;
				}
				else if (newDependent.nomePlano === 'DADOS') {
					totalDepComDescontoBL += (newDependent.valorProduto - newDependent.deducedPrice);
					totalDepSemDescontoBL += newDependent.valorProduto;
					descontoDependenteBL += newDependent.deducedPrice;
				}
				else if (newDependent.nomePlano === 'CONTROLE') {
					totalDepComDescontoCTRL += (newDependent.valorProduto - newDependent.deducedPrice);
					totalDepSemDescontoCTRL += newDependent.valorProduto;
					descontoDependenteCTRL += newDependent.deducedPrice;
				}
			}); 

			component.set('v.oferta.mobile.mouseOverDependenteSemDescontoPG',  totalDepSemDescontoPG-totalDepComDescontoPG>0 ? 'Valor Após Desconto - '+totalDepSemDescontoPG.toFixed(2) : '');
			component.set('v.oferta.mobile.mouseOverDependenteComDescontoPG', totalDepComDescontoPG);
			component.set('v.oferta.mobile.descontoDependentePG', descontoDependentePG);

			component.set('v.oferta.mobile.mouseOverDependenteSemDescontoBL', totalDepSemDescontoBL-totalDepComDescontoBL>0 ? 'Valor Após Desconto - '+totalDepSemDescontoBL.toFixed(2) : '');
			component.set('v.oferta.mobile.mouseOverDependenteComDescontoBL', totalDepComDescontoBL);
			component.set('v.oferta.mobile.descontoDependenteBL', descontoDependenteBL);

			component.set('v.oferta.mobile.mouseOverDependenteSemDescontoControle', totalDepSemDescontoCTRL-totalDepComDescontoCTRL>0 ? 'Valor Após Desconto - '+totalDepSemDescontoCTRL.toFixed(2) : '');
			component.set('v.oferta.mobile.mouseOverDependenteComDescontoControle', totalDepComDescontoCTRL);
			component.set('v.oferta.mobile.descontoDependenteControle', descontoDependenteCTRL);	

			component.set('v.hasDependentChanges', false);
			
			/* rever necessidade
			component.set('v.oldUncheckedCurrentDependentsDiscount', uncheckedCurrentDependentsDiscount);
			component.set('v.oldUncheckedCurrentDependentsValue', uncheckedCurrentDependentsValue);
			component.set('v.oldValueComDescontoChecked', checkedCurrentDependentsDiscount);
			component.set('v.oldValueSemDescontoChecked', currentDependentsValue);
			
			// nunca chamou (usava component.get('v.ofertaSelecionada'))
			if (component.get('v.oferta') == currentProduct) {
				this.calculateOriginalValueTodasAsOfertas(component, component.get('v.lstOfertas.lstOffers'), currentProduct);
			}
			*/
		return currentProduct;
	},

	// ***oferta(!=posse) >> geral >> seta valor-total(c/desc.), valor-original(s/desc.)
	// oferta(posse) >> dependente >> seta mouse-over por tipo
	calculateOriginalValueOferta: function (component, ofertaSelecionada) {

		var lstOfertas = component.get('v.lstOfertas');
		var originalValue = 0;
		var sumDependenteCheked = 0;
		var indexMaior = 0;
		var checkedDepDesconto = 0;
		var sumDependente = 0;
		var uncheckedDepDesconto = 0;
		var listDepAtual = ofertaSelecionada.mobile.listaDependentesMobilePosse;
		var listDepOferta = ofertaSelecionada.mobile.listaDependentesMobileSelected;
		var listDepOfertaAtual = ofertaSelecionada.mobile.listaDependentesMobilePosse;
		var produtoAtual = component.get('v.produtoAtual');
		var hasDependentChanges = component.get('v.hasDependentChanges');
		var oldUncheckedCurrentDependentsValue = component.get('v.oldUncheckedCurrentDependentsValue');
		var oldUncheckedCurrentDependentsDiscount = component.get('v.oldUncheckedCurrentDependentsDiscount');
		var oldValueComDescontoChecked = component.get('v.oldValueComDescontoChecked');
		var oldValueSemDescontoChecked = component.get('v.oldValueSemDescontoChecked');
		var calculate = component.get('v.calculate');
		var depOffer = false;

		if (calculate == false) {
			/* rever necessidade
			if (ofertaSelecionada.lstSteps.length > 0) {
				indexMaior = 0;
				for (var i = 0; i < ofertaSelecionada.lstSteps.length; i++) {
					if (ofertaSelecionada.lstSteps[i].label != null && parseInt(ofertaSelecionada.lstSteps[i].label) > indexMaior) {
						indexMaior = parseInt(ofertaSelecionada.lstSteps[i].label);
						originalValue = ofertaSelecionada.lstSteps[i].value;
						ofertaSelecionada.totalValueOriginal = originalValue;
					}
				}
			}
			if (ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER') {
				for (var index = 0; index < listDepAtual.length; index++) {
					if (listDepAtual[index].checked) {
						if (listDepAtual[index].deducedPrice != null) {
							checkedDepDesconto += parseFloat(listDepAtual[index].deducedPrice);
						}
						sumDependenteCheked += listDepAtual[index].valorProduto;
					}
					else {
						sumDependente += listDepAtual[index].valorProduto;
						uncheckedDepDesconto += listDepAtual[index].deducedPrice;
					}
				}
			}
			else {
				for (var index = 0; index < listDepOfertaAtual.length; index++) {
					if (listDepOfertaAtual[index].checked) {
						sumDependenteCheked += listDepOfertaAtual[index].valorProduto;
					}
					else {
						sumDependente += listDepOfertaAtual[index].valorProduto;
						uncheckedDepDesconto += listDepOfertaAtual[index].valorProduto;
					}
					depOffer = true;
				}
			}
			if (listDepOferta != null && listDepOferta.length > 0) {
				for (var index = 0; index < listDepOferta.length; index++) {
					if (listDepOferta[index].checked) {
						if (listDepOferta[index].deducedPrice != null) {
							checkedDepDesconto += parseFloat(listDepOferta[index].deducedPrice);
						}
						sumDependenteCheked += listDepOferta[index].valorProduto;
					}
					else {
						sumDependente += listDepOferta[index].valorProduto;
						uncheckedDepDesconto += listDepOferta[index].deducedPrice;
					}
				}
			}

			if (indexMaior == 0) {
				if (uncheckedDepDesconto > oldUncheckedCurrentDependentsDiscount) {
					ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - ((sumDependente - uncheckedDepDesconto) - oldUncheckedCurrentDependentsDiscount);
					ofertaSelecionada.totalValue += oldUncheckedCurrentDependentsValue;
				}
				if (depOffer == true) {
					ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - sumDependente;
				}
				if (sumDependente > oldUncheckedCurrentDependentsValue) {
					ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal - (sumDependente - oldUncheckedCurrentDependentsValue);
					if (uncheckedDepDesconto == 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - sumDependente;
					}
				}
				var currentDependentsValue = 0;
				var currentDependentValues = component.get('v.currentDependentValues');
				for (var index = 0; index < currentDependentValues.length; index++) {
					currentDependentsValue += currentDependentValues[index];
				}
				var currentDependentsDiscount = 0;
				var currentDependentDiscounts = component.get('v.currentDependentDiscounts');
				for (var index = 0; index < currentDependentDiscounts.length; index++) {
					currentDependentsDiscount += currentDependentDiscounts[index];
				}

				//DESCONTO POSSE - DIEGO
				if (ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER') {
					if (currentDependentsDiscount > 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + (currentDependentsValue - currentDependentsDiscount);
					}
				}
				else {
					if (currentDependentsDiscount > 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + currentDependentsValue;
					}
				}
				if (currentDependentsValue > oldValueSemDescontoChecked) {
					ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (currentDependentsValue - oldValueSemDescontoChecked);
					if (currentDependentsDiscount <= 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + (currentDependentsValue - oldValueSemDescontoChecked);
					}
				}
				else if (currentDependentsValue < oldValueSemDescontoChecked) {
					var sumFinal = 0;
					if (currentDependentsValue > 0 && sumDependente > 0) {
						sumFinal = oldValueSemDescontoChecked - currentDependentsValue;
						ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + sumFinal;
					}
					else if (currentDependentsValue > 0) {
						sumFinal = oldValueSemDescontoChecked - currentDependentsValue;
						ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (sumFinal - sumDependente);
					}
					else if (sumDependente > 0) {
						sumFinal = oldValueSemDescontoChecked - sumDependente;
						if (oldValueSemDescontoChecked == sumDependente) {
							ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + sumFinal;
						}
						else {
							ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (sumFinal - sumDependente);
						}
					}
					if (sumDependente > 0 && currentDependentsValue == 0) {
						currentDependentsValue = sumFinal;
					}
					else if (sumDependente > 0) {
						currentDependentsValue += sumDependente;
					}
					else if (sumFinal > 0) {
						currentDependentsValue += sumFinal;
					}
				}
				else {
					ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + currentDependentsValue;
					currentDependentsValue = currentDependentsValue + currentDependentsValue;
				}
			}
			else {
				if (uncheckedDepDesconto > oldUncheckedCurrentDependentsDiscount) {
					ofertaSelecionada.totalValue -= (sumDependente - uncheckedDepDesconto);
					ofertaSelecionada.totalValue = parseFloat(ofertaSelecionada.totalValue.toFixed(2));
				}
				var currentDependentsValue = 0;
				var currentDependentValues = component.get('v.currentDependentValues');
				for (var index = 0; index < currentDependentValues.length; index++) {
					currentDependentsValue += currentDependentValues[index];
				}
				var currentDependentsDiscount = 0;
				var currentDependentDiscounts = component.get('v.currentDependentDiscounts');
				for (var index = 0; index < currentDependentDiscounts.length; index++) {
					currentDependentsDiscount += currentDependentDiscounts[index];
				}

				//DESCONTO POSSE - DIEGO
				if (ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER') {
					if (currentDependentsDiscount > 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + (currentDependentsValue - currentDependentsDiscount);
					}
				}
				else {
					if (currentDependentsDiscount > 0) {
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + currentDependentsValue;
					}
				}

				//ofertaSelecionada.totalValueOriginal  = ofertaSelecionada.totalValueOriginal + ofertaSelecionada.totalValue;
				if (sumDependente > oldUncheckedCurrentDependentsValue) {
					ofertaSelecionada.totalValueOriginal -= sumDependente;
				}
			}
			if (ofertaSelecionada.automaticDebitDiscount > 0) {

				//ofertaSelecionada.totalValueOriginal -= ofertaSelecionada.automaticDebitDiscount;
			}
			*/

			/* rever necessidade
			//NEW - 26/01/2020 - DIEGO
			var totalDepComDescontoPG = 0;
			var totalDepSemDescontoPG = 0;
			var totalDepComDescontoBL = 0;
			var totalDepSemDescontoBL = 0;

			for (var x = 0; x < listDepAtual.length; x++) {
				if (listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG') {
					totalDepComDescontoPG += (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
					totalDepSemDescontoPG += listDepAtual[x].valorProduto;
				}
				else if (listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL') {
					totalDepComDescontoBL += (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
					totalDepSemDescontoBL += listDepAtual[x].valorProduto;
				}
			}
			*/

				this.calculateOriginalValue(component, produtoAtual);

			/* rever necessidade
			if (lstOfertas != null && lstOfertas.lstOffers.length > 0) {
				for (var index = 0; index < lstOfertas.lstOffers.length; index++) {
					if (lstOfertas.lstOffers[index].mobile.planMobile.label == 'MANTER') {
						this.calculateOriginalValueOferta(component, lstOfertas.lstOffers[index]);
					}
				}
			}
			*/
		}

		return ofertaSelecionada;
	},

	calculateOriginalValueTodasAsOfertas: function (component, lstOffers, produtoAtual) {
		var originalValue = 0;
		var descontoDep = 0;
		var descontoTit = 0;
		var indexMaior = 0;
		var listDepOffer = 0;
		var listDepProduto = 0;
		if (lstOffers) {
			for (var x = 0; x < lstOffers.length; x++) {
				listDepOffer = lstOffers[x].mobile.listaDependentesMobile;
				listDepProduto = produtoAtual.mobile.listaDependentesMobilePosse;
				indexMaior = 0;
				descontoDep = 0;
				descontoTit = 0;
				if (lstOffers[x].lstSteps.length > 0) {
					for (var i = 0; i < lstOffers[x].lstSteps.length; i++) {
						if (lstOffers[x].lstSteps[i].label != null && parseInt(lstOffers[x].lstSteps[i].label) > indexMaior) {
							indexMaior = parseInt(lstOffers[x].lstSteps[i].label);
							originalValue = lstOffers[x].lstSteps[i].value;
							lstOffers[x].totalValueOriginal = originalValue;
							lstOffers[x].difTotal = lstOffers[x].totalValueOriginal - produtoAtual.totalValue;
						}
					}
				}
				if (lstOffers[x].mobile.planMobile.label != 'MANTER') {
					if (listDepOffer.length > 0 && listDepOffer != null) {
						for (var index = 0; index < listDepOffer.length; index++) {
							if (listDepOffer[index].checked) {
								if (listDepOffer[index].deducedPrice != null) {
									descontoDep += listDepOffer[index].deducedPrice;
								}
							}
						}
					}
				}
				else if (listDepProduto.length > 0 && listDepProduto != null) {
					for (var index = 0; index < listDepProduto.length; index++) {
						if (listDepProduto[index].checked) {
							if (listDepProduto[index].deducedPrice != null) {
								descontoDep += listDepProduto[index].deducedPrice;
								descontoTit = produtoAtual.mobile.descontoTitular;
							}
						}
					}
				}
				lstOffers[x].totalValue -= descontoDep;

				//lstOffers[x].totalValue -= descontoTit;
				if (indexMaior == 0) {
					var totalValue = lstOffers[x].totalValue;
					lstOffers[x].totalValueOriginal = totalValue + descontoDep + descontoTit;
				}
				else {
					lstOffers[x].totalValueOriginal += descontoDep + descontoTit;
				}
				lstOffers[x].difTotal = lstOffers[x].totalValue - produtoAtual.totalValue;
				lstOffers[x].mobile.difProducts = lstOffers[x].mobile.planMobile.value - produtoAtual.mobile.planMobile.value;
			}
		}
		component.set('v.lstOfertas.lstOffers', lstOffers);
		return lstOffers;
	},

	calculoTeste: function (component, event, produtoAtual) {
		var action = component.get('c.calculateDependenteMobile');
		action.setParams({
			"jsonProdutoAtual": JSON.stringify(produtoAtual)
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.produtoAtual', data);
			}
		});
		$A.enqueueAction(action);
	}
})