({
	incluirAdicionaisTV : function(component, event, helper){		
		var disabled = component.get('v.disabledTV');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		let cloneOldProduct = JSON.parse(JSON.stringify(component.get('v.produtoAntigo')));
		if(ofertaSelecionada === produtoAtual && component.get('v.fristCall')){
			component.set('v.typeModal', 'TV');
			component.set('v.fristCall', false);
			helper.validateTechnology(component, event, helper);
		}else if(disabled === false){
			
			if (ofertaSelecionada === produtoAtual && component.get('v.selectedTv.planTv.label').includes('SUSPENSAO')){
				component.get('v.selectedTv.addOptions.lstAdditionals').filter(checkItem => checkItem.checked == true).forEach((item) => {
					cloneOldProduct.tv[0].addOptions.lstAdditionals.forEach((itemOld) => {
						if(itemOld.id == item.id){
							item.value = itemOld.value;
						}	
						if(item.lstPromotions.length !== 0){
							item.lstPromotions.forEach((itemPromotion) => {
								itemOld.lstPromotions.forEach((itemOldPromotion)=> {
									if(itemPromotion.label == itemOldPromotion.label){
										itemPromotion.value = itemOldPromotion.value;
									}
								});
							});
						}							
					});

				});				
			}
			component.set('v.showAdditionalTv', true);
			helper.validateTechnology(component, event, helper);
		}
    },
    
	closeAdicionalTV : function(component, event, helper){
        component.set('v.showAdditionalTv', false);
    },

	updateAdditionalsTV : function(component, event, helper){
		component.set('v.showSpinner', true);

		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		var lstPontuacao = component.get('v.lstPontuacao');
		var addOptions = ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions;
		let cloneOldProduct = JSON.parse(JSON.stringify(component.get('v.produtoAntigo')));
			

		if(ofertaSelecionada === produtoAtual) {
			produtoAtual = cloneOldProduct;			
			produtoAtual = helper.updateAdditionalsTVHelper(component, addOptions, produtoAtual, produtoAtual);
			produtoAtual = helper.updateAdditionalSteps(produtoAtual);
			produtoAtual = helper.calculateOriginalValue(component, produtoAtual);
			component.set('v.oferta',produtoAtual);
			component.set('v.produtoAtual', produtoAtual);
			component.set('v.selectedTv',produtoAtual.tv[0]);			
			 // Calcular diferença no footer para demais ofertas ///
		/*	if (oferta1.tv[oferta1.techSelected].planTv.label != "NÃO POSSUI") {
				oferta1 = helper.updateAdditionalsTVHelper(component, oferta1.tv[oferta1.techSelected].addOptions, oferta1, produtoAtual);
				oferta1 = helper.updateAdditionalSteps(oferta1);
				oferta1 = helper.validateDifStepAdditionals(produtoAtual, oferta1);
				oferta1 = helper.validateDifStepTotalValue(produtoAtual, oferta1);
				component.set('v.oferta1', oferta1);
				component.set('v.tv', oferta1.tv[oferta1.techSelected]);
			}
			if (oferta2.tv[oferta2.techSelected].planTv.label != "NÃO POSSUI") {
				oferta2 = helper.updateAdditionalsTVHelper(component, oferta2.tv[oferta2.techSelected].addOptions, oferta2, produtoAtual);
				oferta2 = helper.updateAdditionalSteps(oferta2);
				oferta2 = helper.validateDifStepAdditionals(produtoAtual, oferta2);
				oferta2 = helper.validateDifStepTotalValue(produtoAtual, oferta2);
				component.set('v.oferta2', oferta2);
				component.set('v.tv', oferta2.tv[oferta2.techSelected]);
			}
			if(oferta3.tv[oferta3.techSelected].planTv.label != "NÃO POSSUI"){
				oferta3 = helper.updateAdditionalsTVHelper(component,  oferta3.tv[oferta3.techSelected].addOptions, oferta3, produtoAtual);
				oferta3 = helper.updateAdditionalSteps(oferta3);
				oferta3 = helper.validateDifStepAdditionals(produtoAtual, oferta3);
				oferta3 = helper.validateDifStepTotalValue(produtoAtual, oferta3);
				component.set('v.oferta3', oferta3);
				component.set('v.tv', oferta3.tv[oferta3.techSelected]);
			} */
		}

		if(oferta1 === ofertaSelecionada) {
			if (oferta1.tv[oferta1.techSelected].planTv.label != "NÃO POSSUI") {				
				oferta1 = helper.updateAdditionalsTVHelper(component, addOptions, oferta1, produtoAtual);
				oferta1 = helper.updateAdditionalSteps(oferta1);
				oferta1 = helper.calculateOriginalValueOferta(component, oferta1);
				oferta1 = helper.validateDifStepAdditionals(produtoAtual, oferta1);
				oferta1 = helper.validateDifStepTotalValue(produtoAtual, oferta1);
				component.set('v.oferta1', oferta1);
				component.set('v.selectedTv', oferta1.tv[oferta1.techSelected]);					
				helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
				

			}
		}

		if (oferta2 === ofertaSelecionada) {
			if (oferta2.tv[oferta2.techSelected].planTv.label != "NÃO POSSUI") {
				oferta2 = helper.updateAdditionalsTVHelper(component, addOptions, oferta2, produtoAtual);
				oferta2 = helper.updateAdditionalSteps(oferta2);
				oferta2 = helper.calculateOriginalValueOferta(component, oferta2);
				oferta2 = helper.validateDifStepAdditionals(produtoAtual, oferta2);
				oferta2 = helper.validateDifStepTotalValue(produtoAtual, oferta2);
				component.set('v.oferta2', oferta2);
				component.set('v.selectedTv', oferta2.tv[oferta2.techSelected]);
				helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
			}
		}

		if (oferta3 === ofertaSelecionada) {
			oferta3 = helper.updateAdditionalsTVHelper(component, addOptions, oferta3, produtoAtual);
			oferta3 = helper.updateAdditionalSteps(oferta3);
			oferta3 = helper.calculateOriginalValueOferta(component, oferta3);
			oferta3 = helper.validateDifStepAdditionals(produtoAtual, oferta3);
			oferta3 = helper.validateDifStepTotalValue(produtoAtual, oferta3);
			component.set('v.oferta3', oferta3);
			component.set('v.selectedTv', oferta3.tv[oferta3.techSelected]);
			helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
		}

		component.set('v.showAdditionalTv', false);
		component.set('v.showSpinner', false);
	},

	//Esta função deve ser chamada somente através do click do botão na tela
	//pois ela gera eventos, e se for chamada por algum aura:handler (change) ou aura:method
	//como o c.updateAdditionalsTV, haverá inconsistências em caso de suspensão temporária
	handleUpdateAdditionalClick: function (component, event, helper) {
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		$A.enqueueAction(component.get('c.updateAdditionalsTV'));

		let pageEvent = $A.get('e.c:NBA_PageEvent');
		pageEvent.setParams({'action' : 'RESET_SUSPENSION',
							 'data' : {recalculateCurrentProduct : ofertaSelecionada == produtoAtual ? 'Não' : 'Sim'} });
		pageEvent.fire();
	},

	updateAdditional : function(component, event, helper){
		var index = event.getSource().get('v.name');
		var checked = event.getSource().get('v.checked');
		var ofertaSelecionada = component.get('v.oferta');
		var additional = ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals[index];
		if(checked){
			additional.disabled = false;
		} else {
			var prevPromo = additional.promoSelected;
			if(prevPromo != null && prevPromo !== ''){
				additional.prevPromo = prevPromo;
			}
			additional.promoSelected = '';
			additional.description = '';
			additional.disabled = true;
		}

		for (var i = 0; i < ofertaSelecionada.tv.length; i++) { 
			ofertaSelecionada.tv[i].addOptions.lstAdditionals[index] = additional;
		}
		component.set('v.oferta', ofertaSelecionada);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	updatePromoAdd : function(component, event, helper){
		var valor = event.currentTarget.value;
		var indiceAdicional = valor.split('#')[0];
		var indicePromocao = valor.split('#')[1];
		
		var ofertaSelecionada = component.get('v.oferta');
		var additional = ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals[indiceAdicional];

		if(indicePromocao && indicePromocao >= 0) {
			additional.promoSelected = indicePromocao + '';
			additional.description = additional.lstPromotions[additional.promoSelected].label;
		} else {
			additional.promoSelected = '';
			additional.description = '';
		}
		
		for (var i = 0; i < ofertaSelecionada.tv.length; i++) {
			ofertaSelecionada.tv[i].addOptions.lstAdditionals[indiceAdicional] = additional;
		}
		component.set('v.oferta', ofertaSelecionada);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	morethan4 : function(component, event, helper){
		var total = 0;
		var listop = component.get('v.oferta.tv.addOptions.lstOptionalPoints');
		var listopSelected = component.get('v.oferta.tv.addOptions.lstPontoOpcionalSelected');
		
		for (var index = 0 ; index < listop.length; index++) {
			for(var x in listopSelected){
				var y = listopSelected[x];

				if(listop[index].value === y){
					total += listop[index].quantity;
				}
			}
		}

		if (total > 4) {
			listopSelected.pop(listopSelected.length - 1);

			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
				"message": "O Numero maximo de Pontos Opcionais são 4.",
				"type": "error"
			});
			toastEvent.fire();
		}
	},

	addPoint : function(component, event, helper){
		var isChecked = event.getSource().get("v.checked");
		var checkOrder = event.getSource().get("v.name");
		var oferta = component.get('v.oferta');
		var addOptions;

		for (var i = 0; i < oferta.tv.length; i++) {
			addOptions = oferta.tv[i].addOptions;

			if(checkOrder === '1'){
				addOptions.firstPoint.checked = isChecked;

				if (addOptions.firstPoint.checked) {
					addOptions.firstPoint.disabled = false;
				} else {
					addOptions.firstPoint.disabled = true;
					addOptions.firstPoint.label = '';
				}
		
			} else if(checkOrder === '2'){
				addOptions.secondPoint.checked = isChecked;
				if(addOptions.firstPoint.label !== ''){
					addOptions.secondPoint.disabled = false;
				}
				if(!addOptions.secondPoint.checked){
					addOptions.secondPoint.disabled = true;
					addOptions.secondPoint.label = '';
				}
		
			} else if(checkOrder === '3'){
				addOptions.thirdPoint.checked = isChecked;
				if(addOptions.secondPoint.label !== ''){
					addOptions.thirdPoint.disabled = false;
				}
				if(!addOptions.thirdPoint.checked){
					addOptions.thirdPoint.disabled = true;
					addOptions.thirdPoint.label = '';
				}

			} else if(checkOrder === '4'){
				addOptions.fourthPoint.checked = isChecked;
				if(addOptions.thirdPoint.label !== ''){
					addOptions.fourthPoint.disabled = false;
				}
				if(!addOptions.fourthPoint.checked){
					addOptions.fourthPoint.disabled = true;
					addOptions.fourthPoint.label = '';
				}

			} else {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Campos obrigatórios!",
					"message": "Necessário preencher todas informações do ponto para passar para o próximo",
					"type": "error"
				});
				toastEvent.fire();
			}
			helper.updateOptionalPoints(component, addOptions, i);
		}

		var disableCheckbox = helper.disableCheckbox(component, event, helper); 

		component.set('v.disableCheckbox', disableCheckbox);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	updateTechnology : function(component, event, helper){
		var selectId = event.currentTarget.id;
		var oferta = component.get('v.oferta');
		var addOptions;

		for (var j = 0; j < oferta.tv.length; j++) {
			addOptions = oferta.tv[j].addOptions;

			if(selectId === 'select1'){
				addOptions.firstPoint.label = event.currentTarget.value;

			} else if(selectId === 'select2'){
				addOptions.secondPoint.label = event.currentTarget.value;

			} else if(selectId === 'select3'){
				addOptions.thirdPoint.label = event.currentTarget.value;

			} else if(selectId === 'select4'){
				addOptions.fourthPoint.label = event.currentTarget.value;
			}

			helper.updateOptionalPoints(component, addOptions, j);
		}

		var disableCheckbox = helper.disableCheckbox(component, event, helper); 

		component.set('v.disableCheckbox', disableCheckbox);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	validateTechnology : function(component, event, helper){
		helper.clearOptionalPoints(component,event, helper);
		helper.validateTechnology(component, event, helper);
	},
	updateOfferDiffs : function(component, event, helper){
		for(var offerNumber=1; offerNumber<=3; offerNumber++){
			var offer = component.get('v.oferta'+offerNumber);
			var addOptions = offer.tv[offer.techSelected].addOptions;
			var current = component.get('v.produtoAtual');

			helper.updateAdditionalsTVHelper(component, addOptions, offer, current);
			helper.validateDifStepAdditionals(current, offer);
			helper.validateDifStepTotalValue(current, offer);

			component.set('v.oferta'+offerNumber, offer);
		}
	},
})