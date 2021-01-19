({
    incluirAdicionaisBroadband : function(component, event, helper) {
		var disabled = component.get('v.disabledBroadband');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		if(ofertaSelecionada === produtoAtual && component.get('v.fristCall')){
			component.set('v.typeModal', 'BL');
			component.set('v.fristCall', false);
		}else if(disabled === false ){
			component.set('v.showAdditionalBroadband', true);
		}
	
		helper.getSellProtecaoDigital(component, event);
		helper.returnMonitoramentoAtual(component, event);
		helper.returnAutomacaoAtual(component, event);
		
    },

    closeAdicionalBroadband : function(component, event, helper){
        component.set('v.showAdditionalBroadband', false);
    },

	updateAdditionalsBroadband : function(component, event, helper){
		component.set('v.showSpinner', true);

		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		var lstPontuacao = component.get('v.lstPontuacao');
		var addOptions = ofertaSelecionada.broadband.addOptions;

		if(ofertaSelecionada === produtoAtual) {
			produtoAtual = helper.updateAdditionalsBroadbandHelper(component, addOptions, produtoAtual, produtoAtual);
			produtoAtual = helper.updateAdditionalSteps(produtoAtual);
			produtoAtual = helper.calculateOriginalValue(component, produtoAtual);
			component.set('v.produtoAtual', produtoAtual);
		}

		if(oferta1 === ofertaSelecionada) {
			if (oferta1.broadband.planBroadband.label != "NÃO POSSUI") {
				oferta1 = helper.updateAdditionalsBroadbandHelper(component, addOptions, oferta1, produtoAtual);
				oferta1 = helper.updateAdditionalSteps(oferta1);
				oferta1 = helper.calculateOriginalValueOferta(component, oferta1);
				oferta1 = helper.validateDifStepAdditionals(produtoAtual, oferta1);
				oferta1 = helper.validateDifStepTotalValue(produtoAtual, oferta1);
				component.set('v.oferta1', oferta1);
				helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
			}
		}

		if (oferta2 === ofertaSelecionada) {
			if (oferta2.broadband.planBroadband.label != "NÃO POSSUI") {
				oferta2 = helper.updateAdditionalsBroadbandHelper(component, addOptions, oferta2, produtoAtual);
				oferta2 = helper.updateAdditionalSteps(oferta2);
				oferta2 = helper.calculateOriginalValueOferta(component, oferta2);
				oferta2 = helper.validateDifStepAdditionals(produtoAtual, oferta2);
				oferta2 = helper.validateDifStepTotalValue(produtoAtual, oferta2);
				component.set('v.oferta2', oferta2);
				helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
			}
		}

		if (oferta3 === ofertaSelecionada) {
			if (oferta3.broadband.planBroadband.label != "NÃO POSSUI") {
				oferta3 = helper.updateAdditionalsBroadbandHelper(component, addOptions, oferta3, produtoAtual);
				oferta3 = helper.updateAdditionalSteps(oferta3);
				oferta3 = helper.calculateOriginalValueOferta(component, oferta3);
				oferta3 = helper.validateDifStepAdditionals(produtoAtual, oferta3);
				oferta3 = helper.validateDifStepTotalValue(produtoAtual, oferta3);
				component.set('v.oferta3', oferta3);
				helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
			}
		}

		component.set('v.showAdditionalBroadband', false);
		component.set('v.showSpinner', false);		
	},

	updatePromoAdd : function(component, event, helper){
		var valor = event.currentTarget.value;
		var indiceAdicional = valor.split('#')[0];
		var indicePromocao = valor.split('#')[1];

		var ofertaSelecionada = component.get('v.oferta');
		var additional = ofertaSelecionada.broadband.addOptions.lstAdditionals[indiceAdicional];
		additional.promoSelected = indicePromocao;
		ofertaSelecionada.broadband.addOptions.lstAdditionals[indiceAdicional] = additional;
		component.set('v.oferta', ofertaSelecionada);
	},

    hasProtecaoDigital :function(component, event, helper){

        document.getElementById("idProtecaoDigital").disabled = component.get(' v.sellProtecaoDigital');

        if(component.get(' v.sellProtecaoDigital') === true){
           component.set( 'v.sellProtecaoDigital', false);
        }else{
            component.set('v.sellProtecaoDigital', true);
			component.set('v.oferta.broadband.addOptions.protecaoDigitalSelected', '');
        }
    },
    
    hasMonitoramento :function(component, event, helper){

        document.getElementById("idMonitoramento").disabled = component.get(' v.sellMonitoramento');

        if(component.get(' v.sellMonitoramento') === true){
            component.set( 'v.sellMonitoramento', false);
        }else{
            component.set('v.sellMonitoramento', true);
			component.set('v.oferta.broadband.addOptions.smartHomeMonitorSelected', '');
        }
    },

    hasAutomacao :function(component, event, helper){

        document.getElementById("idAutomacao").disabled = component.get(' v.sellAutomacao');

        if(component.get(' v.sellAutomacao') === true){
            component.set( 'v.sellAutomacao', false);
        }else{
            component.set('v.sellAutomacao', true);
			component.set('v.oferta.broadband.addOptions.smartHomeAutomacaoSelected', '');
        }
    },

	updateProtecaoDigital : function(component, event, helper){
		var valor  = document.getElementById('idProtecaoDigital').value;
		component.set('v.oferta.broadband.addOptions.protecaoDigitalSelected', valor);
	},

	updateSmartHomeMonitor : function(component, event, helper){
		var valor  = document.getElementById('idMonitoramento').value;
		component.set('v.oferta.broadband.addOptions.smartHomeMonitorSelected', valor);
	},

	updateSmartAutomacao : function(component, event, helper){
		var valor  = document.getElementById('idAutomacao').value;
		component.set('v.oferta.broadband.addOptions.smartHomeAutomacaoSelected', valor);
	},

})