({
    updateAdditionalsBroadbandHelper : function(component, addOptions, offer, current) {
		var add;
		offer.broadband.addOptions = addOptions;
		offer.totalValue -= Math.abs(offer.broadband.additionalBroadband.value);
		offer.broadband.additionalBroadband.value = 0;
		offer.broadband.additionalBroadband.lstPromotions = [];
		
		offer.broadband.additionalPromoValue = 0;
		for(var x in offer.broadband.addOptions.lstAdditionals){
			add = offer.broadband.addOptions.lstAdditionals[x];
			
			if(add.checked){
				if(add.promoSelected != null && add.promoSelected !== ''){
					
					var discount = add.lstPromotions[add.promoSelected].discount;
					var percent = add.lstPromotions[add.promoSelected].percent;
					var valid = add.lstPromotions[add.promoSelected].valid;
					
					if(percent > 0){
						discount = add.value * percent;
						add.lstPromotions[add.promoSelected].discount = discount;
					}
					
					var value = add.value - discount;
					if(value < 0) {
						value = 0;
					}
					offer.broadband.additionalPromoValue += value;
					offer.broadband.additionalBroadband.lstPromotions.push({label:add.label, valid:valid, value:value, discount:discount});

				} else {
					offer.broadband.additionalBroadband.value += add.value;
				}
			}
		}

		for(var y in offer.broadband.addOptions.lstProtecaoDigital){
			add = offer.broadband.addOptions.lstProtecaoDigital[y];
			if(add.value === offer.broadband.addOptions.protecaoDigitalSelected){
				offer.broadband.additionalBroadband.value += add.price;
			}
		}

		offer.broadband.difProducts = offer.broadband.planBroadband.value - current.broadband.planBroadband.value;
		offer.broadband.difAdditionals = this.validateDifAdditionals(current, offer);
		offer.totalValue += (offer.broadband.additionalBroadband.value + offer.broadband.additionalPromoValue);
		offer.difTotal = offer.totalValue - current.totalValue;
		
		return offer;
	},

	updateAdditionalSteps : function(offer){
		offer.lstSteps = [];

		this.validateSteps(offer, offer.tv[offer.techSelected].planTv.lstPromotions, offer.tv[offer.techSelected].addOptions.lstAdditionals);
		this.validateSteps(offer, offer.broadband.planBroadband.lstPromotions, offer.broadband.addOptions.lstAdditionals);
		this.validateSteps(offer, offer.phone.planPhone.lstPromotions, offer.phone.addOptions.lstAdditionals);
		this.validateSteps(offer, offer.mobile.planMobile.lstPromotions, offer.mobile.addOptions.lstAdditionals);

		offer.lstSteps.sort(function(a, b){
			if(a.label < b.label){
				return -1;
			} else if(a.label > b.label){
				return 1;
			}
			return 0;
		});
		return offer;
	},

	validateSteps : function(offer, lstPromotions, lstAdditionals){
		var mapStep = new Map();
        var newStepValue;
		for(var promotion in lstPromotions){
			var actualPromo = lstPromotions[promotion];
			if (actualPromo.valid) {
				if (mapStep.get(actualPromo.valid)) {
					newStepValue = mapStep.get(actualPromo.valid) + actualPromo.discount;
					mapStep.set(parseInt(actualPromo.valid), newStepValue);
				} else { 
					mapStep.set(parseInt(actualPromo.valid), actualPromo.discount);
				}
			}
		}

		for(var addit in lstAdditionals){
			var actualPromoAddit = '';
			var additional = lstAdditionals[addit];

			if(additional.promoSelected !== ''){
				actualPromoAddit = additional.lstPromotions[additional.promoSelected];
			}
			
			if(additional.checked && actualPromoAddit !== ''){
				newStepValue = 0;
				if (actualPromoAddit.valid && mapStep.get(actualPromoAddit.valid)) {
					newStepValue = mapStep.get(actualPromoAddit.valid) + actualPromoAddit.discount;
					mapStep.set(parseInt(actualPromoAddit.valid), newStepValue);
				} else { 
					mapStep.set(parseInt(actualPromoAddit.valid), actualPromoAddit.discount);
				}
			}
		}

		//var nextDiscount = 0;
		var keysList = [];
		if (mapStep.size > 0) {
			for (var valid of mapStep.keys()) {
				keysList.push(valid);
			}

			keysList.sort();
			for (var i = keysList.length - 1; i > 0 ; i--) {
				var sum = 0;
				for (var key of mapStep.keys()) {
					if (key < keysList[i]) {
						sum += mapStep.get(key);
					}
				}
				var stepValue = mapStep.get(keysList[i]);
				mapStep.set(keysList[i], sum + stepValue);
			}

			for (var validStep of mapStep.keys()) {
				var hasStep = false;
				for (var step in offer.lstSteps) {
					if (offer.lstSteps[step].label == validStep) {
						offer.lstSteps[step].value += mapStep.get(validStep);
						hasStep = true;
					}
				}

				if (!hasStep && validStep) {
					newStepValue = offer.totalValue + mapStep.get(validStep);
					offer.lstSteps.push({label:validStep, value:newStepValue});
				}
			}

			offer.lstSteps.sort(function (a, b) { return a.label - b.label; } );
		}
	},

	validateDifAdditionals : function(current, offer){
		var lstAdditionalsOffer = offer.broadband.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.broadband.addOptions.lstAdditionals;

		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;
		
		for(var curr in lstAdditionalsCurrent) {
			var addCurrent = lstAdditionalsCurrent[curr];
			if (addCurrent.checked) {
				if (addCurrent.promoSelected) {
					totalAdditionalsCurrent += addCurrent.lstPromotions[addCurrent.promoSelected].value;
				} else {
					totalAdditionalsCurrent += addCurrent.value;
				}
			}
		}

		for(var off in lstAdditionalsOffer) {
			var addOffer = lstAdditionalsOffer[off];
			if (addOffer.checked) {
				if (addOffer.promoSelected) {
					totalAdditionalsOffer += addOffer.lstPromotions[addOffer.promoSelected].value;
				} else {
					totalAdditionalsOffer += addOffer.value;
				}
			}
		}

		var difAdditionals = totalAdditionalsOffer - totalAdditionalsCurrent;

		return difAdditionals;
	},

	validateDifStepAdditionals : function(current, offer){
		var lstAdditionalsOffer = offer.broadband.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.broadband.addOptions.lstAdditionals;
		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;		
		var valids = [];

		for(var curr in lstAdditionalsCurrent) {
			var addCurrent = lstAdditionalsCurrent[curr];
			if (addCurrent.checked) {
				if (addCurrent.promoSelected) {
					valids.push(addCurrent.lstPromotions[addCurrent.promoSelected].valid);
				}
				totalAdditionalsCurrent += addCurrent.value;
			}
		}

		for(var off in lstAdditionalsOffer) {
			var addOffer = lstAdditionalsOffer[off];
			if (addOffer.checked) {
				if (addOffer.promoSelected) {
					valids.push(addOffer.lstPromotions[addOffer.promoSelected].valid);
				}
				totalAdditionalsOffer += addOffer.value;
			}
		}

		var maxValid = 0;

		if (valids.length > 0) {
			for (var valid in valids) {
				if (parseInt(valids[valid]) > maxValid)  {
					maxValid = parseInt(valids[valid]);
				}
			}
		}

		offer.broadband.difAdditionalsStep.label = maxValid > 0 ? maxValid : '';
		offer.broadband.difAdditionalsStep.value = (totalAdditionalsOffer - totalAdditionalsCurrent).toFixed(2);

		return offer;
	},

	validateDifStepTotalValue : function(current, offer){
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
			} else if (lastStepOffer.value > 0) {
				offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
			} else if (lastStepCurrent.value > 0) {
				offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
			}
		} else if (lastStepOffer) {
			offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
		} else if (lastStepCurrent) {
			offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
		}

		var valids = [];
		for (var off in lstStepsOffer) {
			var stepOffer = lstStepsOffer[off];

			valids.push(stepOffer.label);
		}

		for (var curr in lstStepsCurrent) {
			var stepCurrent = lstStepsCurrent[curr];

			valids.push(stepCurrent.label);
		}

		var maxValid = 0;

		if (valids.length > 0) {
			for (var valid in valids) {
				if (parseInt(valids[valid]) > maxValid)  {
					maxValid = parseInt(valids[valid]);
				}
			}
		}

		offer.difTotalStep.label = maxValid > 0 ? maxValid : '';

		return offer;
	},

	getSellProtecaoDigital : function (component){
	
		if(component.get('v.oferta.NboBroadband.listaProtecaoDigital') != null && component.get('v.oferta.NboBroadband.listaProtecaoDigital') !== '' ){
			component.set('v.sellProtecaoDigital', false );
		}else{ 
			component.set('v.sellProtecaoDigital', true );
		}
		if(component.get('v.oferta.NboBroadband.listaSmartHomeMonitor') != null && component.get('v.oferta.NboBroadband.listaSmartHomeMonitor') !== '' ){
			component.set('v.sellMonitoramento', false );
		}else{ 
			component.set('v.sellMonitoramento', true );
		}
		if(component.get('v.oferta.NboBroadband.listaSmartHomeAutomacao') != null && component.get('v.oferta.NboBroadband.listaSmartHomeAutomacao') !== '' ){
			component.set('v.sellAutomacao', false );
		}else{ 
			component.set('v.sellAutomacao', true );
		}
	    
	},

	returnMonitoramentoAtual : function (component){
	
		var lista = component.get('v.oferta.broadband.addOptions.lstSmartHomeMonitor');
		var listaRetorno = [] ;
		var select = component.get('v.oferta.broadband.addOptions.smartHomeMonitorSelected');
		var i = 0 ;
		if(lista != null ){
			for( i  ; i < lista.length ; i++){
				if(lista[i].value === select){
					component.set('v.monitoramentoAtual', lista[i].label);
				}
				if(lista[i].value <= select){
					listaRetorno.push(lista[i]);
				}
			}
            if(lista.length !== listaRetorno.length){
                listaRetorno.shift();
            }
		}
		component.set('v.listaMonitoramento', listaRetorno );
	},
	
	returnAutomacaoAtual : function (component){
	
		var lista = component.get('v.oferta.broadband.addOptions.lstSmartHomeAutomacao');
		var listaRetorno = [] ;
		var select = component.get(' v.oferta.broadband.addOptions.smartHomeAutomacaoSelected');
		var i = 0 ;
		if(lista != null ){
			for( i  ; i < lista.length ; i++){
				if(lista[i].value === select){
					component.set('v.automacaoAtual', lista[i].label);
				}
				if(lista[i].value <= select){
					listaRetorno.push(lista[i]);
				}
			}
             if(lista.length !== listaRetorno.length){
                listaRetorno.shift();
            }
		}
		component.set('v.listAutomacao', listaRetorno );
	},

	calculoPercentualRecalculate: function (component, event, helper, lstPontuacao, ofertaSelecionada, produtoAntigo) {
		
			if(lstPontuacao && ofertaSelecionada && produtoAntigo){
				var percentual = 100 * (ofertaSelecionada.totalValue / produtoAntigo.totalValue);
				for(var i = 0; i<lstPontuacao.length; i++){
					if(percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c){
						component.set('v.oferta.incentive', lstPontuacao[i].Pointing__c);
						break;
					}
				}
			}
		}, 

		calculateOriginalValue : function(component, currentProduct){
			var descontoBL = 0;
			var descontoPG = 0;
			var descontoTitular = 0;
			if(currentProduct.mobile.planMobile.label != 'NÃO POSSUI'){
				descontoBL = parseInt(currentProduct.mobile.descontoDependenteBL);
				descontoPG = parseInt(currentProduct.mobile.descontoDependentePG);
				descontoTitular = parseInt(currentProduct.mobile.descontoTitular);
			}
			var originalValue = 0;
			var indexMaior = 0;			
			if(currentProduct.lstSteps.length > 0){
				for(var i = 0; i<currentProduct.lstSteps.length; i++){					
					if(currentProduct.lstSteps[i].label != null && parseInt(currentProduct.lstSteps[i].label) > indexMaior){
						indexMaior = parseInt(currentProduct.lstSteps[i].label);
						originalValue = currentProduct.lstSteps[i].value;
						currentProduct.totalValueOriginal = originalValue + descontoBL + descontoPG + descontoTitular;
					}			
				}
			}

			if(indexMaior == 0){
				var totalValue = currentProduct.totalValue;
				currentProduct.totalValueOriginal = totalValue + descontoBL + descontoPG + descontoTitular;
			}		
			
			return currentProduct;	
		},

		calculateOriginalValueOferta : function(component, ofertaSelecionada){
			var originalValue	   = 0;
			var descontoDep		   = 0;
			var descontoTit		   = 0;
			var indexMaior 		   = 0;
			var listDepProduto     = component.get('v.produtoAtual.mobile.listaDependentesMobile');
			var produtoAtual	   = component.get('v.produtoAtual');
			var calculate		   = component.get('v.calculate');

			if(calculate == false){
				for(var index = 0; index<ofertaSelecionada.lstSteps.length; index++){				
					if(ofertaSelecionada.lstSteps[index].label != null && parseInt(ofertaSelecionada.lstSteps[index].label) > indexMaior){
						indexMaior = parseInt(ofertaSelecionada.lstSteps[index].label);
						originalValue = ofertaSelecionada.lstSteps[index].value;
						ofertaSelecionada.totalValueOriginal = originalValue;
						ofertaSelecionada.difTotal = ofertaSelecionada.totalValueOriginal - produtoAtual.totalValue;
					}			
				}				              
        
				if(ofertaSelecionada.mobile.planMobile.label == 'MANTER'){
					if(listDepProduto.length > 0 && listDepProduto != null) {
						for (var index = 0; index < listDepProduto.length; index++) {
							if(listDepProduto[index].checked) {
								if (listDepProduto[index].deducedPrice != null) {
									descontoDep += listDepProduto[index].deducedPrice;
									descontoTit = produtoAtual.mobile.descontoTitular;
								}
							}
						}
					}
				} 
		
				ofertaSelecionada.totalValue -= descontoDep;
				ofertaSelecionada.totalValue -= descontoTit;
                
				if(indexMaior == 0){					
					var totalValue = ofertaSelecionada.totalValue;
					ofertaSelecionada.totalValueOriginal = totalValue + descontoDep + descontoTit;														
				} else {
					ofertaSelecionada.totalValueOriginal += descontoDep + descontoTit;																			
				}
		
				ofertaSelecionada.difTotal = ofertaSelecionada.totalValue - produtoAtual.totalValue;
			}
			return ofertaSelecionada;	
				
		},


})