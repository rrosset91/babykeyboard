({
    addAdditionalPhone: function (component, event, helper) {
		var disabled = component.get('v.disabledPhone');
        if(disabled === false){
			component.set('v.showAdditionalPhone', true);
		}
    },

    closeAdditionalPhone: function (component, event, helper) {
        component.set('v.showAdditionalPhone', false);
    },

	updateAdditionalsPhone : function(component, event, helper){
		component.set('v.showSpinner', true);

		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		var lstPontuacao = component.get('v.lstPontuacao');
		var addOptions = ofertaSelecionada.phone.addOptions;
		let cloneOldProduct = JSON.parse(JSON.stringify(component.get('v.produtoAntigo')));

		if(ofertaSelecionada === produtoAtual) {
			produtoAtual = cloneOldProduct;	
			produtoAtual = helper.updateAdditionalsPhoneHelper(component, addOptions, produtoAtual, produtoAtual);
			produtoAtual = helper.calculateOriginalValue(component, produtoAtual);
			component.set('v.oferta',produtoAtual);
			component.set('v.produtoAtual', produtoAtual);
		}

		oferta1 = helper.updateAdditionalsPhoneHelper(component, addOptions, oferta1, produtoAtual);
		oferta2 = helper.updateAdditionalsPhoneHelper(component, addOptions, oferta2, produtoAtual);
		oferta3 = helper.updateAdditionalsPhoneHelper(component, addOptions, oferta3, produtoAtual);

		oferta1 = helper.calculateOriginalValueOferta(component, oferta1);
		oferta2 = helper.calculateOriginalValueOferta(component, oferta2);
		oferta3 = helper.calculateOriginalValueOferta(component, oferta3);
		
		component.set('v.oferta1', oferta1);
		component.set('v.oferta2', oferta2);
		component.set('v.oferta3', oferta3);
		//component.set('v.ofertaSelecionada', ofertaSelecionada);
		helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);

		component.set('v.showAdditionalPhone', false);
		component.set('v.showSpinner', false);		
	},

	//Esta função deve ser chamada somente através do click do botão na tela
	//pois ela gera eventos, e se for chamada por algum aura:handler (change) ou aura:method
	//como o c.updateAdditionalsPhone, haverá inconsistências em caso de suspensão temporária
	handleUpdateAdditionalClick: function (component, event, helper) {
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		$A.enqueueAction(component.get('c.updateAdditionalsPhone'));

		let pageEvent = $A.get('e.c:NBA_PageEvent');
		pageEvent.setParams({'action' : 'RESET_SUSPENSION',
							 'data' : {recalculateCurrentProduct : ofertaSelecionada == produtoAtual ? 'Não' : 'Sim'} });
		pageEvent.fire();
	},

	updateExtension : function(component, event, helper){
		var valor = document.getElementById('idExtension').value;
		component.set('v.oferta.phone.addOptions.quantityExtension', valor);
	},

    hasSection: function (component, event, helper) {
       
        document.getElementById("idExtension").disabled = component.get(' v.sellExtension');

        if(component.get(' v.sellExtension') === false){
            component.set( 'v.sellExtension', true);
            component.set('v.extensions' , [1,2,3,4]);
        }else{
            component.set('v.sellExtension', false);
        }
	},
	
	updateOfferDiffs : function(component, event, helper){
		/* implementar quando habilitar suspensão temporária de phone
		for(var offerNumber=1; offerNumber<=3; offerNumber++){
			var offer = component.get('v.oferta'+offerNumber);
			var addOptions = offer.phone.addOptions;
			var current = component.get('v.produtoAtual');

			helper.updateAdditionalsPhoneHelper(component, addOptions, offer, current);
			helper.validateDifStepAdditionals(current, offer);
			helper.validateDifStepTotalValue(current, offer);

			component.set('v.oferta'+offerNumber, offer);
    }
		*/
	},
})