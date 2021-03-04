({
	updateAdditionalsTVHelper : function(component, addOptions, offer, current) {

		// var ofertaSelecionada = component.get('v.oferta');
		// var produtoAtual = component.get('v.produtoAtual');

		var totalValueWithoutTv;
		for (var i = 0; i < offer.tv.length; i++) {
			offer.tv[i].addOptions = addOptions;
			if (!totalValueWithoutTv) {
				offer.totalValue -= Math.abs(offer.tv[i].additionalTv.value);
				offer.totalValue -= Math.abs(offer.tv[i].additionalPromoValue);		
				offer.totalValue -= Math.abs(offer.tv[i].optionalPointsTv.value);
				offer.totalValue -= Math.abs(offer.tv[offer.techSelected].planTv.value);
				totalValueWithoutTv = offer.totalValue;
			} else {
				offer.totalValue = totalValueWithoutTv;
			}
			//offer.tv[offer.techSelected].planTv.value = offer.tv[offer.techSelected].planTv.originalValue;
			offer.tv[i].additionalTv.value = 0;
			offer.tv[i].additionalTv.lstPromotions = [];
			offer.tv[i].optionalPointsTv.value = 0;
			offer.tv[i].optionalPointsTv.lstPromotions = [];
		
			// Atualização valores a la cartes
			offer.tv[i].additionalPromoValue = 0;
			var totalValueAdd = 0;
			var maxValid = 0;
			for(var x in offer.tv[i].addOptions.lstAdditionals){
				var add = offer.tv[i].addOptions.lstAdditionals[x];
			
				if(add.checked){
					if(add.promoSelected !== null && add.promoSelected !== ''){
					
						var discountAddit = add.lstPromotions[add.promoSelected].discount;
						var percentAddit = add.lstPromotions[add.promoSelected].percent;
						var validAddit = add.lstPromotions[add.promoSelected].valid;
						var descriptionAddit = add.lstPromotions[add.promoSelected].label;

						if (maxValid > validAddit) {
							maxValid = validAddit;
						}

						totalValueAdd += add.value;

						if(percentAddit > 0){
							discountAddit = add.value * percentAddit;
							add.lstPromotions[add.promoSelected].discount = discountAddit;
						}
					
						var value = add.value - discountAddit;
						offer.tv[i].additionalPromoValue += value;
						offer.tv[i].additionalTv.lstPromotions.push({label:add.label, valid:validAddit, value:value, discount:discountAddit, description:descriptionAddit});

					} else {
						offer.tv[i].additionalTv.value += add.value;
					}
				}
			}

			for (var y in offer.tv[i].addOptions.lstOptionalPoints) {
				var po = offer.tv[i].addOptions.lstOptionalPoints[y];

				var calculate = (y == 0 && offer.tv[i].addOptions.firstPoint.checked) ||
								(y == 1 && offer.tv[i].addOptions.secondPoint.checked) ||
								(y == 2 && offer.tv[i].addOptions.thirdPoint.checked) ||
								(y == 3 && offer.tv[i].addOptions.fourthPoint.checked);

				if (calculate) {
					var discountPo = po.promotion.discount;
					// var percentPo = po.promotion.percent;
					var validPo = po.promotion.valid;
					var descriptionPo = po.promotion.description;
					var valuePo = po.promotion.value;

					if (validPo > 0) {
						offer.tv[i].optionalPointsTv.lstPromotions.push({label:po.label, valid:validPo, value:valuePo, discount:discountPo, description:descriptionPo});
					} else {
						if(valuePo > 0){
							offer.tv[i].optionalPointsTv.value += valuePo;
							qtPontos += 1;
						} else {
							qtPontosPromo += 1;
							offer.tv[i].optionalPointsPromoTv.quantity++;
						}
					}
				}
			}

			// Atualização valores pontos opcionais
			var qtPontos = 0;
			var qtPontosPromo = 0;
			/*
			var point1 = true;
			var point2 = true;
			var point3 = true;
			var point4 = true;
            */

			offer.tv[i].optionalPointsPromoTv.quantity = 0;

			// 1° ponto
			if(offer.tv[i].addOptions.firstPoint.checked/* && point1*/ ){
				if(offer.tv[i].addOptions.firstPoint.price > 0){
					offer.tv[i].optionalPointsTv.value += offer.tv[i].addOptions.firstPoint.price;
					qtPontos += 1;
				} else {
					qtPontosPromo += 1;
					offer.tv[i].optionalPointsPromoTv.quantity++;
				}
                //point1 = false;
			} 

			// 2° ponto
			if(offer.tv[i].addOptions.secondPoint.checked/* && point2*/ ){
				if(offer.tv[i].addOptions.secondPoint.price > 0){
					offer.tv[i].optionalPointsTv.value += offer.tv[i].addOptions.secondPoint.price;
					qtPontos += 1;
				} else {
					qtPontosPromo += 1;
					offer.tv[i].optionalPointsPromoTv.quantity++;
				} 
                //point2 = false;
			}

			// 3° ponto
			if(offer.tv[i].addOptions.thirdPoint.checked/* && point3*/ ){
				if(offer.tv[i].addOptions.thirdPoint.price > 0){
					offer.tv[i].optionalPointsTv.value += offer.tv[i].addOptions.thirdPoint.price;
					qtPontos += 1;
				} else {
					qtPontosPromo += 1;
					offer.tv[i].optionalPointsPromoTv.quantity++;
				}
                //point3 = false;
			} 

			// 4° ponto
			if(offer.tv[i].addOptions.fourthPoint.checked/* && point4*/ ){
				if(offer.tv[i].addOptions.fourthPoint.price > 0){
					offer.tv[i].optionalPointsTv.value += offer.tv[i].addOptions.fourthPoint.price;
					qtPontos += 1;
				} else {
					qtPontosPromo += 1;
					offer.tv[i].optionalPointsPromoTv.quantity++;
				}
                //point4 = false;
			}
			offer.tv[i].optionalPointsTv.label = qtPontos + ' Ponto(s) Opcional(is)';
			offer.tv[i].optionalPointsPromoTv.label = qtPontosPromo + ' Ponto(s) Grátis';
			offer.tv[i].optionalPointsPromoTv.value = 0;

			// Atualização valores tecnologia
			if(offer.tv[i].addOptions.fourKTechnology.checked){
				for (var ft = 0; ft < offer.tv.length; ft++) {
					if (offer.tv[ft].technology.toLowerCase().includes('4k')) {
						offer.techSelected = ft;
					}
				}
			} else if (offer.tv[i].addOptions.recordTechnology.checked) {
				for (var rt = 0; rt < offer.tv.length; rt++) {
					if (offer.tv[rt].technology.toLowerCase().includes('max')) {
						offer.techSelected = rt;
					}
				}
			} else {
				offer.techSelected = 0;
			}

			// Sumarização
			offer.tv[i].difProducts = offer.tv[i].planTv.value - current.tv[0].planTv.value;
			if (maxValid > 0) {
				offer.tv[i].difProductsStep = {label: maxValid, value:totalValueAdd};
			}
			offer.tv[i].difAdditionals = this.validateDifAdditionals(current, offer, i);

			//if(offer.tv[offer.techSelected].planTv.lstPromotions.length > 0 && offer.tv[offer.techSelected].planTv.lstPromotions != null){
				//offer.totalValue += (offer.tv[offer.techSelected].planTv.lstPromotions[0].value + offer.tv[i].additionalTv.value + offer.tv[i].additionalPromoValue + offer.tv[i].optionalPointsTv.value);
			//}else {
				offer.totalValue += (offer.tv[offer.techSelected].planTv.value + offer.tv[i].additionalTv.value + offer.tv[i].additionalPromoValue + offer.tv[i].optionalPointsTv.value);
			//}
			
			offer.difTotal = offer.totalValue - current.totalValue;
		}

		offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA = [];

		// PO - RPA
		if (offer.tv[offer.techSelected].addOptions.firstPoint.checked) {
			if (offer.tv[offer.techSelected].addOptions.firstPoint.isAlreadyIncluded) {
				for (var a = 0; a < offer.tv[offer.techSelected].addOptions.lstOptionalPoints.length; a++) {
					if (offer.tv[offer.techSelected].addOptions.firstPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPoints[a].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPoints[a]);
						console.log('P1');
						break;
					}
				}
			} else {
				for (var b = 0; b < offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI.length; b++) {
					if (offer.tv[offer.techSelected].addOptions.firstPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[b].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[b]);
						break;
					}
				}
			}
		} else {
			offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA = [];
		}

		if (offer.tv[offer.techSelected].addOptions.secondPoint.checked) {
			if (offer.tv[offer.techSelected].addOptions.secondPoint.isAlreadyIncluded) {
				for (var c = 0; c < offer.tv[offer.techSelected].addOptions.lstOptionalPoints.length; c++) {
					if (offer.tv[offer.techSelected].addOptions.secondPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPoints[c].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPoints[c]);
						console.log('P2');
						break;
					}
				}
			} else {
				for (var d = 0; d < offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI.length; d++) {
					if (offer.tv[offer.techSelected].addOptions.secondPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[d].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[d]);
						break;
					}
				}
			}
		} else {
			for (var e = 1; e < offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.length; e++) {
				offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.pop();
			}
		}

		if (offer.tv[offer.techSelected].addOptions.thirdPoint.checked) {
			if (offer.tv[offer.techSelected].addOptions.thirdPoint.isAlreadyIncluded) {
				for (var f = 0; f < offer.tv[offer.techSelected].addOptions.lstOptionalPoints.length; f++) {
					if (offer.tv[offer.techSelected].addOptions.thirdPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPoints[f].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPoints[f]);
						console.log('P3');
						break;
					}
				}
			} else {
				for (var g = 0; g < offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI.length; g++) {
					if (offer.tv[offer.techSelected].addOptions.thirdPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[g].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[g]);
						break;
					}
				}
			}
		} else {
			for (var h = 2; h < offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.length; h++) {
				offer.tv[i].addOptions.lstOptionalPointsRPA.pop();
			}
		}

		if (offer.tv[offer.techSelected].addOptions.fourthPoint.checked) {
			if (offer.tv[offer.techSelected].addOptions.fourthPoint.isAlreadyIncluded) {
				for (var k = 0; k < offer.tv[offer.techSelected].addOptions.lstOptionalPoints.length; k++) {
					if (offer.tv[offer.techSelected].addOptions.fourthPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPoints[k].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPoints[k]);
						console.log('P4');
						break;
					}
				}
			} else {
				for (var l = 0; l < offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI.length; l++) {
					if (offer.tv[offer.techSelected].addOptions.fourthPoint.label === offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[l].technologyType) {
						offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.push(offer.tv[offer.techSelected].addOptions.lstOptionalPointsPriceAPI[l]);
						break;
					}
				}
			}
		} else {
			for (var m = 3; m < offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.length; m++) {
				offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.pop();
			}
		}

		for (var n = 0; n < offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA.length; n++) {
			offer.tv[offer.techSelected].addOptions.lstOptionalPointsRPA[n].checked = true;
		}
		
		console.log(JSON.parse(JSON.stringify(offer.tv[0].addOptions.lstOptionalPointsRPA)));
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
		for(var promo in lstPromotions){
			var actualPromo = lstPromotions[promo];
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
			var actualAddit = '';
			var additional = lstAdditionals[addit];

			if(additional.promoSelected !== ''){
				actualAddit = additional.lstPromotions[additional.promoSelected];
			}
			
			if(additional.checked && actualAddit !== ''){
				newStepValue = 0;
				if (actualAddit.valid && mapStep.get(actualAddit.valid)) {
					newStepValue = mapStep.get(actualAddit.valid) + actualAddit.discount;
					mapStep.set(parseInt(actualAddit.valid), newStepValue);
				} else { 
					mapStep.set(parseInt(actualAddit.valid), actualAddit.discount);
				}
				
			}
		}

		// var nextDiscount = 0;
		var keysList = [];
		if (mapStep.size > 0) {
			for (var valid of mapStep.keys()) {
				keysList.push(valid);
			}

			keysList.sort();
			for (var lis = keysList.length - 1; lis > 0 ; lis--) {
				var sum = 0;
				for (var key of mapStep.keys()) {
					if (key < keysList[lis]) {
						sum += mapStep.get(key);
					}
				}
				var stepValue = mapStep.get(keysList[lis]);
				mapStep.set(keysList[lis], sum + stepValue);
			}

			for (var validStep of mapStep.keys()) {
				var hasStep = false;
				for (var step in offer.lstSteps) {
					if (offer.lstSteps[step].label == validStep) {
						offer.lstSteps[step].value += mapStep.get(validStep);
						hasStep = true;
					}
				}

				if (!hasStep) {
					newStepValue = offer.totalValue + mapStep.get(validStep);
					offer.lstSteps.push({label:validStep, value:newStepValue});
				}
			}

			offer.lstSteps.sort(function (a, b) { return a.label - b.label; } );
		}
	},

	validateDifAdditionals : function(current, offer, index){
		var lstAdditionalsOffer = offer.tv[index].addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.tv[0].addOptions.lstAdditionals;

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

		if (current.tv[0].optionalPointsTv) {
			difAdditionals -= current.tv[0].optionalPointsTv.value;
		}

		if (offer.tv[offer.techSelected].optionalPointsTv) {
			difAdditionals += offer.tv[index].optionalPointsTv.value;
		}

		return difAdditionals;
	},

	validateDifStepAdditionals : function(current, offer){
		var lstAdditionalsOffer = offer.tv[offer.techSelected].addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.tv[0].addOptions.lstAdditionals;

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

		for (var t = 0; t < offer.tv.length; t++) {
			offer.tv[t].difAdditionalsStep.label = maxValid > 0 ? maxValid : '';
			offer.tv[t].difAdditionalsStep.value = (totalAdditionalsOffer - totalAdditionalsCurrent).toFixed(2);

			if (current.tv[0].optionalPointsTv) {
				offer.tv[t].difAdditionalsStep.value -= current.tv[0].optionalPointsTv.value;
			}

			if (offer.tv[t].optionalPointsTv) {
				offer.tv[t].difAdditionalsStep.value += offer.tv[t].optionalPointsTv.value;
			}
		}

		return offer;
	},

	validateDifStepTotalValue : function(current, offer){
		var lstStepsOffer = offer.lstSteps;
		var lstStepsCurrent = current.lstSteps;
		// var lstAdditionalsOffer = offer.tv[offer.techSelected].addOptions.lstAdditionals;
		// var lstAdditionalsCurrent = current.tv[0].addOptions.lstAdditionals;
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

	updateOptionalPoints : function(component, addOptions, index){	
		// var lstPrecosPontosOpcionais = [];
		var lstOptionalFiltered;
		var lstTech;
		var hasTech;
		var y;
		var x;

		// Calcula o preço e tecnologia do primeiro selecionado
		if(addOptions.firstPoint.checked && addOptions.firstPoint.label !== ''){
			hasTech = false;
			if (addOptions.firstPoint.isAlreadyIncluded) {
				for (var i = 0; i < addOptions.lstOptionalPoints.length; i++) {
					if (addOptions.lstOptionalPoints[i].technologyType === addOptions.firstPoint.label) {
						hasTech = true;
					}
				} 

				lstOptionalFiltered = hasTech ? addOptions.lstOptionalPoints : addOptions.lstOptionalPointsPriceAPI;
			} else {
				lstOptionalFiltered = addOptions.lstOptionalPointsPriceAPI;
			}
			lstTech = addOptions.firstPoint.isAlreadyIncluded ? addOptions.lstTechnology : addOptions.lstTechnologyAPI;
			for(x in lstTech){
				if(lstTech[x].label === addOptions.firstPoint.label){
					for(y in lstOptionalFiltered){
						if(lstTech[x].label === lstOptionalFiltered[y].technologyType){
							addOptions.firstPoint.price = addOptions.firstPoint.value = hasTech ? lstOptionalFiltered[0].value : lstOptionalFiltered[y].value;
							break;
						}
					}
				}
			}
		}

		// Calcula o preço e tecnologia do segundo selecionado
		if(addOptions.secondPoint.checked && addOptions.secondPoint.label !== ''){
			hasTech = false;
			if (addOptions.secondPoint.isAlreadyIncluded) {
				for (var op = 0; op < addOptions.lstOptionalPoints.length; op++) {
					if (addOptions.lstOptionalPoints[op].technologyType === addOptions.secondPoint.label) {
						hasTech = true;
					}
				} 

				lstOptionalFiltered = hasTech ? addOptions.lstOptionalPoints : addOptions.lstOptionalPointsPriceAPI;
			} else {
				lstOptionalFiltered = addOptions.lstOptionalPointsPriceAPI;
			}
			lstTech = addOptions.secondPoint.isAlreadyIncluded ? addOptions.lstTechnology : addOptions.lstTechnologyAPI;
			for(x in lstTech){
				if(lstTech[x].label === addOptions.secondPoint.label){
					for(y in lstOptionalFiltered){
						if(lstTech[x].label === lstOptionalFiltered[y].technologyType){
							addOptions.secondPoint.price = addOptions.secondPoint.value = hasTech ? lstOptionalFiltered[1].value : lstOptionalFiltered[y].value;
							break;
						}
					}
				}
			}
		}

		// Calcula o preço e tecnologia do terceiro selecionado
		if(addOptions.thirdPoint.checked && addOptions.thirdPoint.label !== ''){
			hasTech = false;
			if (addOptions.thirdPoint.isAlreadyIncluded) {
				for (var tp = 0; tp < addOptions.lstOptionalPoints.length; tp++) {
					if (addOptions.lstOptionalPoints[tp].technologyType === addOptions.thirdPoint.label) {
						hasTech = true;
					}
				} 

				lstOptionalFiltered = hasTech ? addOptions.lstOptionalPoints : addOptions.lstOptionalPointsPriceAPI;
			} else {
				lstOptionalFiltered = addOptions.lstOptionalPointsPriceAPI;
			}
			lstTech = addOptions.thirdPoint.isAlreadyIncluded ? addOptions.lstTechnology : addOptions.lstTechnologyAPI;
			for(x in lstTech){
				if(lstTech[x].label === addOptions.thirdPoint.label){
					for(y in lstOptionalFiltered){
						if(lstTech[x].label === lstOptionalFiltered[y].technologyType){
							addOptions.thirdPoint.price = addOptions.thirdPoint.value = hasTech ? lstOptionalFiltered[2].value : lstOptionalFiltered[y].value;
							break;
						}
					}
				}
			}
		}
		
		// Calcula o preço e tecnologia do quarto selecionado
		if(addOptions.fourthPoint.checked && addOptions.fourthPoint.label !== ''){
			hasTech = false;
			if (addOptions.fourthPoint.isAlreadyIncluded) {
				for (var fp = 0; fp < addOptions.lstOptionalPoints.length; fp++) {
					if (addOptions.lstOptionalPoints[fp].technologyType === addOptions.fourthPoint.label) {
						hasTech = true;
					}
				}

				lstOptionalFiltered = hasTech ? addOptions.lstOptionalPoints : addOptions.lstOptionalPointsPriceAPI;
			} else {
				lstOptionalFiltered = addOptions.lstOptionalPointsPriceAPI;
			}
			lstTech = addOptions.fourthPoint.isAlreadyIncluded ? addOptions.lstTechnology : addOptions.lstTechnologyAPI;
			for(x in lstTech){
				if(lstTech[x].label === addOptions.fourthPoint.label){
					for(y in lstOptionalFiltered){
						if(lstTech[x].label === lstOptionalFiltered[y].technologyType){
							addOptions.fourthPoint.price = addOptions.fourthPoint.value = hasTech ? lstOptionalFiltered[3].value : lstOptionalFiltered[y].value;
							break;
						}
					}
				}
			}
		}
		
		var oferta = component.get('v.oferta');
		oferta.tv[index].addOptions = addOptions;
		component.set('v.oferta', oferta);
	},

	hasTechnology : function(addOptions, technology){
		var hasTechnology1 = false;
		var hasTechnology2 = false;
		for(var papi in addOptions.lstOptionalPointsPriceAPIByTechnology){
			if(addOptions.lstOptionalPointsPriceAPIByTechnology[papi].technologyType === technology){
				hasTechnology1 = true;
			}
		}

		for(var tech in addOptions.lstTechnology){
			if(addOptions.lstTechnology[tech].label === technology){
				hasTechnology2 = true;
			}
		}

		return hasTechnology1 && !hasTechnology2;
	},

	validateTechnology : function(component, event, helper){
		var oferta = component.get('v.oferta');
		var addOptions = oferta.tv[oferta.techSelected].addOptions;
		var lstUpgradeFee = component.get('v.oferta.lstUpgradeFee');
		var lstMembershipFee = component.get('v.oferta.lstMembershipFee');

		var tech = oferta.tv[oferta.techSelected].technology;

		// Atualiza a lista filtrada com os métodos de pagamento da taxa da tecnologia
		var lstFiltered = [];
		for (var i in lstUpgradeFee) {
			if (lstUpgradeFee[i].technologyType === tech) {
				lstFiltered.push(lstUpgradeFee[i]);
			}
		}

		component.set('v.oferta.lstUpgradeFeeFiltered', lstFiltered);

		lstFiltered = [];

		for (var fee in lstMembershipFee) {
			if (lstMembershipFee[fee].technologyType === tech) {
				lstFiltered.push(lstMembershipFee[fee]);
			}
		}

		component.set('v.oferta.lstMembershipFeeFiltered', lstFiltered);

		// Atualiza a lista de tecnologias no picklist
		var lstAux = [];
		for(var tec in addOptions.lstTechnology){
			if(addOptions.lstTechnology[tec].label === '4K'){
				if(addOptions.fourKTechnology.checked && helper.hasTechnology(addOptions, '4K')){
					lstAux.push(addOptions.lstTechnology[tec]);
				}
			} else if(addOptions.lstTechnology[tec].label === 'MAX'){
				if(addOptions.recordTechnology.checked && helper.hasTechnology(addOptions, 'MAX')){
					lstAux.push(addOptions.lstTechnology[tec]);
				}
			} else {
				lstAux.push(addOptions.lstTechnology[tec]);
			}
		}

		addOptions.lstOptionalPointsPriceAPIByTechnology = [];
		for (var papi = 0; papi < addOptions.lstOptionalPointsPriceAPI.length; papi++) {
			if (addOptions.fourKTechnology.checked) {
				if (addOptions.lstOptionalPointsPriceAPI[papi].technologyType == '4K') {
					addOptions.lstOptionalPointsPriceAPIByTechnology.push(addOptions.lstOptionalPointsPriceAPI[papi]);
				} else if (addOptions.lstOptionalPointsPriceAPI[papi].technologyType == 'HD') {
					addOptions.lstOptionalPointsPriceAPIByTechnology.push(addOptions.lstOptionalPointsPriceAPI[papi]);
				}
			} else if (addOptions.recordTechnology.checked) {
				if (addOptions.lstOptionalPointsPriceAPI[papi].technologyType == 'MAX') {
					addOptions.lstOptionalPointsPriceAPIByTechnology.push(addOptions.lstOptionalPointsPriceAPI[papi]);
				} else if (addOptions.lstOptionalPointsPriceAPI[papi].technologyType == 'HD') {
					addOptions.lstOptionalPointsPriceAPIByTechnology.push(addOptions.lstOptionalPointsPriceAPI[papi]);
				}
			} else {
				if (addOptions.lstOptionalPointsPriceAPI[papi].technologyType == 'HD') {
					addOptions.lstOptionalPointsPriceAPIByTechnology.push(addOptions.lstOptionalPointsPriceAPI[papi]);
				}
			}
		}

		var lstTechnologyAPI = [];
		for (var bytec = 0; bytec < addOptions.lstOptionalPointsPriceAPIByTechnology.length; bytec++) {
			lstTechnologyAPI.push({label: addOptions.lstOptionalPointsPriceAPIByTechnology[bytec].technologyType, quantity: 0});
		}

		addOptions.lstTechnologyAPI = lstTechnologyAPI;

		if(helper.hasTechnology(addOptions, 'HD')){
			lstAux.push({label: 'HD', quantity: 0});
		}

		if(addOptions.fourKTechnology.checked && helper.hasTechnology(addOptions, '4K')){
			lstAux.push({label: '4K', quantity: 0});
		}

		if(addOptions.recordTechnology.checked && helper.hasTechnology(addOptions, 'MAX')){
			lstAux.push({label: 'MAX', quantity: 0});
		}

		addOptions.lstTechnology = lstAux;

		var disableCheckbox = helper.disableCheckbox(component, event, helper);

		component.set('v.disableCheckbox', disableCheckbox);

		oferta.tv[oferta.techSelected].addOptions = addOptions;
		component.set('v.oferta', oferta);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},

	disableCheckbox : function (component) {
		var oferta = component.get('v.oferta');
		var addOptions = oferta.tv[oferta.techSelected].addOptions;

		var disableCheckbox = {
			first: addOptions.secondPoint.checked || (!addOptions.firstPoint.checked && addOptions.lstOptionalPointsPriceAPIByTechnology.length == 0 && addOptions.lstOptionalPoints.length < 1),
			second : (addOptions.firstPoint.disabled || (addOptions.firstPoint.label == '' || !addOptions.thirdPoint.disabled)) || (!addOptions.secondPoint.checked && addOptions.lstOptionalPointsPriceAPIByTechnology.length == 0 && addOptions.lstOptionalPoints.length < 2),
			third : (addOptions.secondPoint.disabled || (addOptions.secondPoint.label == '' || !addOptions.fourthPoint.disabled)) || (!addOptions.thirdPoint.checked && addOptions.lstOptionalPointsPriceAPIByTechnology.length == 0 && addOptions.lstOptionalPoints.length < 3),
			fourth : (addOptions.thirdPoint.disabled || addOptions.thirdPoint.label == '') || (!addOptions.fourthPoint.checked && addOptions.lstOptionalPointsPriceAPIByTechnology.length == 0 && addOptions.lstOptionalPoints.length < 4)
		};

		return disableCheckbox;
	},

	clearOptionalPoints : function(component) {
		var oferta = component.get('v.oferta');
		var addOptions = oferta.tv[oferta.techSelected].addOptions;
		for (var i = 0; i < addOptions.lstOptionalPoints; i++) {
			if (i === 0) {
				addOptions.firstPoint.id = addOptions.lstOptionalPoints[i].id;
				addOptions.firstPoint.checked = true;
				addOptions.firstPoint.disabled = false;
				addOptions.firstPoint.label = addOptions.lstOptionalPoints[i].label;
				addOptions.firstPoint.nameLegacy = addOptions.lstOptionalPoints[i].nameLegacy;
				addOptions.firstPoint.familyName = addOptions.lstOptionalPoints[i].familyName;
				addOptions.firstPoint.solicitationType = addOptions.lstOptionalPoints[i].solicitationType;
				addOptions.firstPoint.technologyType = addOptions.lstOptionalPoints[i].technologyType;
				addOptions.firstPoint.isAlreadyIncluded = true;
				addOptions.firstPoint.value = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.firstPoint.price = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.firstPoint.promotion.label = addOptions.lstOptionalPoints[i].promotion.label;
				addOptions.firstPoint.promotion.description = addOptions.lstOptionalPoints[i].promotion.description;
				addOptions.firstPoint.promotion.discount = addOptions.lstOptionalPoints[i].promotion.discount;
				addOptions.firstPoint.promotion.valid = addOptions.lstOptionalPoints[i].promotion.discount.valid;
			}

			if (i === 1) {
				addOptions.secondPoint.id = addOptions.lstOptionalPoints[i].id;
				addOptions.secondPoint.checked = true;
				addOptions.secondPoint.disabled = false;
				addOptions.secondPoint.label = addOptions.lstOptionalPoints[i].label;
				addOptions.secondPoint.nameLegacy = addOptions.lstOptionalPoints[i].nameLegacy;
				addOptions.secondPoint.familyName = addOptions.lstOptionalPoints[i].familyName;
				addOptions.secondPoint.solicitationType = addOptions.lstOptionalPoints[i].solicitationType;
				addOptions.secondPoint.technologyType = addOptions.lstOptionalPoints[i].technologyType;
				addOptions.secondPoint.isAlreadyIncluded = true;
				addOptions.secondPoint.value = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.secondPoint.price = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.secondPoint.promotion.label = addOptions.lstOptionalPoints[i].promotion.label;
				addOptions.secondPoint.promotion.description = addOptions.lstOptionalPoints[i].promotion.description;
				addOptions.secondPoint.promotion.discount = addOptions.lstOptionalPoints[i].promotion.discount;
				addOptions.secondPoint.promotion.valid = addOptions.lstOptionalPoints[i].promotion.discount.valid;
			}

			if (i === 2) {
				addOptions.thirdPoint.id = addOptions.lstOptionalPoints[i].id;
				addOptions.thirdPoint.checked = true;
				addOptions.thirdPoint.disabled = false;
				addOptions.thirdPoint.label = addOptions.lstOptionalPoints[i].label;
				addOptions.thirdPoint.nameLegacy = addOptions.lstOptionalPoints[i].nameLegacy;
				addOptions.thirdPoint.familyName = addOptions.lstOptionalPoints[i].familyName;
				addOptions.thirdPoint.solicitationType = addOptions.lstOptionalPoints[i].solicitationType;
				addOptions.thirdPoint.technologyType = addOptions.lstOptionalPoints[i].technologyType;
				addOptions.thirdPoint.isAlreadyIncluded = true;
				addOptions.thirdPoint.value = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.thirdPoint.price = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.thirdPoint.promotion.label = addOptions.lstOptionalPoints[i].promotion.label;
				addOptions.thirdPoint.promotion.description = addOptions.lstOptionalPoints[i].promotion.description;
				addOptions.thirdPoint.promotion.discount = addOptions.lstOptionalPoints[i].promotion.discount;
				addOptions.thirdPoint.promotion.valid = addOptions.lstOptionalPoints[i].promotion.discount.valid;
			}

			if (i === 3) {
				addOptions.fourthPoint.id = addOptions.lstOptionalPoints[i].id;
				addOptions.fourthPoint.checked = true;
				addOptions.fourthPoint.disabled = false;
				addOptions.fourthPoint.label = addOptions.lstOptionalPoints[i].label;
				addOptions.fourthPoint.nameLegacy = addOptions.lstOptionalPoints[i].nameLegacy;
				addOptions.fourthPoint.familyName = addOptions.lstOptionalPoints[i].familyName;
				addOptions.fourthPoint.solicitationType = addOptions.lstOptionalPoints[i].solicitationType;
				addOptions.fourthPoint.technologyType = addOptions.lstOptionalPoints[i].technologyType;
				addOptions.fourthPoint.isAlreadyIncluded = true;
				addOptions.fourthPoint.value = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.fourthPoint.price = addOptions.lstOptionalPoints[i].price ? addOptions.lstOptionalPoints[i].price : 0;
				addOptions.fourthPoint.promotion.label = addOptions.lstOptionalPoints[i].promotion.label;
				addOptions.fourthPoint.promotion.description = addOptions.lstOptionalPoints[i].promotion.description;
				addOptions.fourthPoint.promotion.discount = addOptions.lstOptionalPoints[i].promotion.discount;
				addOptions.fourthPoint.promotion.valid = addOptions.lstOptionalPoints[i].promotion.discount.valid;
			}
		}

		if (addOptions.lstOptionalPoints.length == 3) {
			addOptions.fourthPoint.label = '';
			addOptions.fourthPoint.checked = false;
			addOptions.fourthPoint.disabled = true;
			addOptions.fourthPoint.isAlreadyIncluded = false;
			addOptions.fourthPoint.value = 0;
			addOptions.fourthPoint.price = 0;
		} else if (addOptions.lstOptionalPoints.length == 2) {
			addOptions.fourthPoint.label = '';
			addOptions.fourthPoint.checked = false;
			addOptions.fourthPoint.disabled = true;
			addOptions.fourthPoint.isAlreadyIncluded = false;
			addOptions.fourthPoint.value = 0;
			addOptions.fourthPoint.price = 0;

			addOptions.thirdPoint.label = '';
			addOptions.thirdPoint.checked = false;
			addOptions.thirdPoint.disabled = true;
			addOptions.thirdPoint.isAlreadyIncluded = false;
			addOptions.thirdPoint.value = 0;
			addOptions.thirdPoint.price = 0;
		} else if (addOptions.lstOptionalPoints.length == 1) {
			addOptions.fourthPoint.label = '';
			addOptions.fourthPoint.checked = false;
			addOptions.fourthPoint.disabled = true;
			addOptions.fourthPoint.isAlreadyIncluded = false;
			addOptions.fourthPoint.value = 0;
			addOptions.fourthPoint.price = 0;

			addOptions.thirdPoint.label = '';
			addOptions.thirdPoint.checked = false;
			addOptions.thirdPoint.disabled = true;
			addOptions.thirdPoint.isAlreadyIncluded = false;
			addOptions.thirdPoint.value = 0;
			addOptions.thirdPoint.price = 0;

			addOptions.secondPoint.label = '';
			addOptions.secondPoint.checked = false;
			addOptions.secondPoint.disabled = true;
			addOptions.secondPoint.isAlreadyIncluded = false;
			addOptions.secondPoint.value = 0;
			addOptions.secondPoint.price = 0;
		} else if (addOptions.lstOptionalPoints.length == 0) {
			addOptions.fourthPoint.label = '';
			addOptions.fourthPoint.checked = false;
			addOptions.fourthPoint.disabled = true;
			addOptions.fourthPoint.isAlreadyIncluded = false;
			addOptions.fourthPoint.value = 0;
			addOptions.fourthPoint.price = 0;

			addOptions.thirdPoint.label = '';
			addOptions.thirdPoint.checked = false;
			addOptions.thirdPoint.disabled = true;
			addOptions.thirdPoint.isAlreadyIncluded = false;
			addOptions.thirdPoint.value = 0;
			addOptions.thirdPoint.price = 0;

			addOptions.secondPoint.label = '';
			addOptions.secondPoint.checked = false;
			addOptions.secondPoint.disabled = true;
			addOptions.secondPoint.isAlreadyIncluded = false;
			addOptions.secondPoint.value = 0;
			addOptions.secondPoint.price = 0;

			addOptions.firstPoint.label = '';
			addOptions.firstPoint.checked = false;
			addOptions.firstPoint.disabled = true;
			addOptions.firstPoint.isAlreadyIncluded = false;
			addOptions.firstPoint.value = 0;
			addOptions.firstPoint.price = 0;
		}
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
				descontoBL = parseFloat(currentProduct.mobile.descontoDependenteBL);
				descontoPG = parseFloat(currentProduct.mobile.descontoDependentePG);
				descontoTitular = parseFloat(currentProduct.mobile.descontoTitular);
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
			var originalValue = 0;
			var indexMaior = 0;			
			var lstOffers		= component.get('v.lstOfertas.lstOffers');
			var produtoAtual	= component.get('v.produtoAtual');
			var	listDepOffer    = ofertaSelecionada.mobile.listaDependentesMobile;
			var	listDepProduto  = produtoAtual.mobile.listaDependentesMobilePosse;
			var	descontoDep		= 0;
			var	descontoTit		= 0;
					
			if(ofertaSelecionada.lstSteps.length > 0){
				for(var i = 0; i<ofertaSelecionada.lstSteps.length; i++){					
					if(parseInt(ofertaSelecionada.lstSteps[i].label) > indexMaior){
						indexMaior = parseInt(ofertaSelecionada.lstSteps[i].label);
						originalValue = ofertaSelecionada.lstSteps[i].value;
						ofertaSelecionada.totalValueOriginal = originalValue;
					}			
				}
			}

			if(ofertaSelecionada.mobile.planMobile.label != 'MANTER'){
				if(listDepOffer.length > 0 && listDepOffer != null) {
					for (var index = 0; index < listDepOffer.length; index++) {
						if (listDepOffer[index].checked) {
							if (listDepOffer[index].deducedPrice != null) {
								descontoDep += listDepOffer[index].deducedPrice;
							}
						}
					}
				}
			} else {
				descontoDep = parseFloat(produtoAtual.mobile.descontoDependentePG) + parseFloat(produtoAtual.mobile.descontoDependenteBL) + parseFloat(produtoAtual.mobile.descontoDependenteControle);
				descontoTit = produtoAtual.mobile.descontoTitular;
				if (listDepProduto.length > 0 && listDepProduto != null) {
					for (var index = 0; index < listDepProduto.length; index++) {
						if (listDepProduto[index].checked) {
							if (listDepProduto[index].deducedPrice != null) {
								descontoDep += listDepProduto[index].deducedPrice;
							}
						}
					}
				}
			}

			ofertaSelecionada.mobile.listaDependentesMobilePosse
				.filter(dependent => dependent.checked && dependent.valorProduto>0 && dependent.possessionDiscount>0)
				.forEach(dependent => descontoDep += dependent.possessionDiscount);
			if(indexMaior == 0){
				var totalValue = ofertaSelecionada.totalValue;
				ofertaSelecionada.totalValueOriginal = totalValue + descontoDep + descontoTit;														
			} else {
				ofertaSelecionada.totalValueOriginal += descontoDep + descontoTit;																					
			}	
			
			return ofertaSelecionada;			
		},

})