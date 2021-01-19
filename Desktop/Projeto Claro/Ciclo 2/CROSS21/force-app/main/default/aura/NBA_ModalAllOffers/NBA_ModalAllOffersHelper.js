({
	dump: function (obj) {
		var out = '';
		for (var i in obj) {
			out += i + ": " + obj[i] + "\n";
		}
		//console.log(out);
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

	arrayMove: function (arr, old_index, new_index) {
		if (new_index >= arr.length) {
			var k = new_index - arr.length + 1;
			while (k--) {
				arr.push(undefined);
			}
		}
		arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
		return arr;
	},

	saveClickSelectOffer: function (component, event){
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var recordId = sURL[sURL.length - 2];

		var action = component.get('c.saveClickSelectOffer');	
		action.setParams({
			"recordId" : recordId
		});

		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('Campo Gravado com Sucesso');
            } else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {
						if (errors[0].pageErrors[0].message) {
							this.showToast('Erro!', errors[0].pageErrors[0].message, 'error');
						} else if (errors[0].message) {
							this.showToast('Erro!', errors[0].message, 'error');
						}
					}
				}
			}
    
        });
        $A.enqueueAction(action);

	},

	getAllOffers: function (component, event, helper) {

		component.set('v.showSpinner', true);
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var recordId = sURL[sURL.length - 2];

		var offerObj;
		var isCancel = component.get("v.showCancelOffers");
		var lstPontuacao = component.get('v.lstPontuacao');

		var storage = isCancel ? 'JSONCancelOffers' + recordId : 'JSONOffers' + recordId;

		if (localStorage[storage]) {
			
			offerObj = JSON.parse(localStorage['JSONOffers' + recordId]);
			this.configActionsSort(component, offerObj, false);
			this.calculateAditionals(component, offerObj);

			component.set('v.offersList', offerObj);
			component.set('v.ofertas', offerObj);
			component.set('v.ofertas.data.recommendations.rewardPoints', offerObj.data.recommendations.rewardPoints); 

			component.set('v.showSpinner', false);

		} else {
			var posseCliente = component.get('v.hasPosse');
			var action = isCancel ? component.get('c.consultarListaOfertasCancelamento') : component.get('c.consultarListaOfertas');
			action.setParams({
				"recordId": component.get("v.caseId"),
				"tvAvailable"			: 'true',
				"BroadbandAvailable"	: 'true',
				"digAvailable"			: 'true',
				"phoneAvailable"		: 'true'
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {

					offerObj = response.getReturnValue();
					//console.log(JSON.stringify(offerObj));
					this.configActionsSort(component, offerObj, true);
					this.calculateAditionals(component, offerObj);
					this.calculoPercentual(component, lstPontuacao, offerObj);
					
					if(	offerObj!=null && offerObj!=undefined && offerObj.data!=null && offerObj.data!=undefined && 
						offerObj.data.recommendations!=null && offerObj.data.recommendations!=undefined){
						for (var indexOffer=0; indexOffer<offerObj.data.recommendations.length; indexOffer++){
							if(typeof offerObj.data.recommendations[indexOffer].totalValue != "undefined")
								offerObj.data.recommendations[indexOffer]['roundedTotalValue'] = offerObj.data.recommendations[indexOffer].totalValue.toFixed(2);
							if(typeof offerObj.data.recommendations[indexOffer].variation != "undefined")
								offerObj.data.recommendations[indexOffer]['roundedVariation'] = offerObj.data.recommendations[indexOffer].variation.toFixed(2);
							for (var indexTv=0; indexTv<offerObj.data.recommendations[indexOffer].nboTv.length; indexTv++)
								if(typeof offerObj.data.recommendations[indexOffer].nboTv[indexTv].value != "undefined")
									offerObj.data.recommendations[indexOffer].nboTv[indexTv]['roundedValue'] = offerObj.data.recommendations[indexOffer].nboTv[indexTv].value.toFixed(2);
						}					
					}

					if (isCancel) {
						var ofertasSemCancel = JSON.parse(localStorage['JSONOffers' + recordId]).data.recommendations;
						var ofertasCancel = offerObj.data.recommendations;
						localStorage['JSONCancelOffers' + recordId] = JSON.stringify(ofertasCancel);
						var listToAdd = [];
						var achou;
						for (var off = 0; off < ofertasCancel.length; off++) {
							achou = false;
							for (var sca = 0; sca < ofertasSemCancel.length; sca++) {
								 if (ofertasSemCancel[sca] === ofertasCancel[off]) {
									achou = true;
									break;
								 }
							 }
							 if (!achou) {
								listToAdd.push(ofertasCancel[off]);
							 }
						}
						var ofertasComCancel = ofertasSemCancel.concat(listToAdd);
						offerObj.data.recommendations = ofertasComCancel;
						for (var obj in offerObj.data.recommendations) 
							offerObj.data.recommendations[obj].priority = (parseInt(obj) + 1).toString();
						localStorage['JSONOffers' + recordId] = JSON.stringify(offerObj);
					} else {
						for (var obj in offerObj.data.recommendations) 
							offerObj.data.recommendations[obj].priority = (parseInt(obj) + 1).toString();
						localStorage[storage] = JSON.stringify(offerObj);
					}

					component.set('v.ofertas', offerObj);
					component.set('v.offersList', offerObj);

				} else if (state === "ERROR") {
					var errors = action.getError();
					if (errors) {
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
				component.set('v.showCancelOffers', false);
			});
			$A.enqueueAction(action);
		}
	},

	configActionsSort : function(component, offerObj, firstExecute) {
		var ofertas = offerObj.data.recommendations;
		for (var i = 0; ofertas.length > i; i++) {
			if (firstExecute) {
				if (ofertas[i].actionTv === '1') { // Aquisição
					ofertas[i].actionTv = 'a';
				} else if (ofertas[i].actionTv === '3') { // Upgrade
					ofertas[i].actionTv = 'b';
				} else if (ofertas[i].actionTv === '5') { // Lateral ou Mantido
					ofertas[i].actionTv = 'c';
				} else if (ofertas[i].actionTv === '4') { // Downgrade
					ofertas[i].actionTv = 'd';
				} else if (ofertas[i].actionTv === '2') { // Cancelamento
					ofertas[i].actionTv = 'e';
				} else {
					ofertas[i].actionTv = 'f';
				}

				if (ofertas[i].actionBroadband === '1') { // Aquisição
					ofertas[i].actionBroadband = 'a';
				} else if (ofertas[i].actionBroadband === '3') { // Upgrade
					ofertas[i].actionBroadband = 'b';
				} else if (ofertas[i].actionBroadband === '5') { // Lateral ou Mantido
					ofertas[i].actionBroadband = 'c';
				} else if (ofertas[i].actionBroadband === '4') { // Downgrade
					ofertas[i].actionBroadband = 'd';
				} else if (ofertas[i].actionBroadband === '2') { // Cancelamento
					ofertas[i].actionBroadband = 'e';
				} else {
					ofertas[i].actionBroadband = 'f';
				}

				if (ofertas[i].actionMobile === '1') { // Aquisição
					ofertas[i].actionMobile = 'a';
				} else if (ofertas[i].actionMobile === '3') { // Upgrade
					ofertas[i].actionMobile = 'b';
				} else if (ofertas[i].actionMobile === '5') { // Lateral ou Mantido
					ofertas[i].actionMobile = 'c';
				} else if (ofertas[i].actionMobile === '4') { // Downgrade
					ofertas[i].actionMobile = 'd';
				} else if (ofertas[i].actionMobile === '2') { // Cancelamento
					ofertas[i].actionMobile = 'e';
				} else {
					ofertas[i].actionMobile = 'f';
				}

				if (ofertas[i].actionPhone === '1') { // Aquisição
					ofertas[i].actionPhone = 'a';
				} else if (ofertas[i].actionPhone === '3') { // Upgrade
					ofertas[i].actionPhone = 'b';
				} else if (ofertas[i].actionPhone === '5') { // Lateral ou Mantido
					ofertas[i].actionPhone = 'c';
				} else if (ofertas[i].actionPhone === '4') { // Downgrade
					ofertas[i].actionPhone = 'd';
				} else if (ofertas[i].actionPhone === '2') { // Cancelamento
					ofertas[i].actionPhone = 'e';
				} else {
					ofertas[i].actionPhone = 'f';
				}
			}

			var broadband = ofertas[i].nboBroadband;
			var mobile = ofertas[i].nboMobile[0];
			var phone = ofertas[i].nboPhone;
			var tv = ofertas[i].nboTv[0] ? ofertas[i].nboTv[0] : {};

			ofertas[i].combate = (tv.offerType ? tv.offerType.toLowerCase().includes("combate") : false) || (broadband.offerType ? broadband.offerType.toLowerCase().includes("combate") : false) || 
								(phone.offerType ? phone.offerType.toLowerCase().includes("combate") : false) || (mobile.offerType ? mobile.offerType.toLowerCase().includes("combate") : false) ;
			ofertas[i].exclusivo = (tv.offerType ? tv.offerType.toLowerCase().includes("exclusivo") : false) || (broadband.offerType ? broadband.offerType.toLowerCase().includes("exclusivo") : false) || 
								(phone.offerType ? phone.offerType.toLowerCase().includes("exclusivo") : false) || (mobile.offerType ? mobile.offerType.toLowerCase().includes("exclusivo") : false);
			ofertas[i].blindagem = (tv.offerType ? tv.offerType.toLowerCase().includes("blindagem") : false) || (broadband.offerType ? broadband.offerType.toLowerCase().includes("blindagem") : false) || 
								(phone.offerType ? phone.offerType.toLowerCase().includes("blindagem") : false) || (mobile.offerType ? mobile.offerType.toLowerCase().includes("blindagem") : false);
			
			var priceVirtua = broadband.price ? broadband.price : 0;
			var priceMobile = mobile.price ? mobile.price : 0;
			var pricePhone = phone.price ? phone.price : 0;
			var priceTV = tv.price ? tv.price : 0;
			var discountTv = tv.validFor && tv.promotion.discount.value ? parseFloat(tv.promotion.discount.value) : 0;
			var discountPhone = phone.validFor && phone.promotion.discount.value ? parseFloat(phone.promotion.discount.value) : 0;
			var discountMobile = mobile.validFor && mobile.promotion.discount.value ? parseFloat(mobile.promotion.discount.value) : 0;
			var discountBroadband = broadband.validFor && broadband.promotion.discount.value ? parseFloat(broadband.promotion.discount.value) : 0;
			var totalPrice = parseFloat(priceMobile) + parseFloat(pricePhone) + parseFloat(priceTV) + parseFloat(priceVirtua);
			var totalPromo = discountTv + discountPhone + discountMobile + discountBroadband;

			ofertas[i].nboTv[0].value = priceTV - discountTv;
			ofertas[i].nboBroadband.value = priceVirtua - discountBroadband;
			ofertas[i].nboPhone.value = pricePhone - discountPhone;
			ofertas[i].nboMobile[0].value = priceMobile - discountMobile;

			// var currentTotal = component.get('v.produtoAtual').totalValue;

			ofertas[i].totalProductPrice = totalPrice - totalPromo;
			ofertas[i].totalValue = ofertas[i].totalProductPrice;
			
		}
	},

	resetConfigActions : function(component, ofertasObj) {

		for (var j = 0; ofertasObj.data.recommendations.length > j; j++) {

			if (ofertasObj.data.recommendations[j].actionTv === 'a') {
				ofertasObj.data.recommendations[j].actionTv = '1'; // Aquisição
			} else if (ofertasObj.data.recommendations[j].actionTv === 'b') {
				ofertasObj.data.recommendations[j].actionTv = '3'; // Upgrade
			} else if (ofertasObj.data.recommendations[j].actionTv === 'c') {
				ofertasObj.data.recommendations[j].actionTv = '5'; // Lateral ou Mantido
			} else if (ofertasObj.data.recommendations[j].actionTv === 'd') {
				ofertasObj.data.recommendations[j].actionTv = '4'; // Downgrade
			} else if (ofertasObj.data.recommendations[j].actionTv === 'e') {
				ofertasObj.data.recommendations[j].actionTv = '2'; // Cancelamento
			} else if (ofertasObj.data.recommendations[j].actionTv === 'f') {
				ofertasObj.data.recommendations[j].actionTv = 'N/A';
			}

			if (ofertasObj.data.recommendations[j].actionBroadband === 'a') {
				ofertasObj.data.recommendations[j].actionBroadband = '1'; // Aquisição
			} else if (ofertasObj.data.recommendations[j].actionBroadband === 'b') {
				ofertasObj.data.recommendations[j].actionBroadband = '3'; // Upgrade
			} else if (ofertasObj.data.recommendations[j].actionBroadband === 'c') {
				ofertasObj.data.recommendations[j].actionBroadband = '5'; // Lateral ou Mantido
			} else if (ofertasObj.data.recommendations[j].actionBroadband === 'd') {
				ofertasObj.data.recommendations[j].actionBroadband = '4'; // Downgrade
			} else if (ofertasObj.data.recommendations[j].actionBroadband === 'e') {
				ofertasObj.data.recommendations[j].actionBroadband = '2'; // Cancelamento
			} else if (ofertasObj.data.recommendations[j].actionTv === 'f') {
				ofertasObj.data.recommendations[j].actionBroadband = 'N/A';
			}

			if (ofertasObj.data.recommendations[j].actionMobile === 'a') {
				ofertasObj.data.recommendations[j].actionMobile = '1'; // Aquisição
			} else if (ofertasObj.data.recommendations[j].actionMobile === 'b') {
				ofertasObj.data.recommendations[j].actionMobile = '3'; // Upgrade
			} else if (ofertasObj.data.recommendations[j].actionMobile === 'c') {
				ofertasObj.data.recommendations[j].actionMobile = '5'; // Lateral ou Mantido
			} else if (ofertasObj.data.recommendations[j].actionMobile === 'd') {
				ofertasObj.data.recommendations[j].actionMobile = '4'; // Downgrade
			} else if (ofertasObj.data.recommendations[j].actionMobile === 'e') {
				ofertasObj.data.recommendations[j].actionMobile = '2'; // Cancelamento
			} else if (ofertasObj.data.recommendations[j].actionTv === 'f') {
				ofertasObj.data.recommendations[j].actionMobile = 'N/A';
			}

			if (ofertasObj.data.recommendations[j].actionPhone === 'a') {
				ofertasObj.data.recommendations[j].actionPhone = '1'; // Aquisição
			} else if (ofertasObj.data.recommendations[j].actionPhone === 'b') {
				ofertasObj.data.recommendations[j].actionPhone = '3'; // Upgrade
			} else if (ofertasObj.data.recommendations[j].actionPhone === 'c') {
				ofertasObj.data.recommendations[j].actionPhone = '5'; // Lateral ou Mantido
			} else if (ofertasObj.data.recommendations[j].actionPhone === 'd') {
				ofertasObj.data.recommendations[j].actionPhone = '4'; // Downgrade
			} else if (ofertasObj.data.recommendations[j].actionPhone === 'e') {
				ofertasObj.data.recommendations[j].actionPhone = '2'; // Cancelamento
			} else if (ofertasObj.data.recommendations[j].actionTv === 'f') {
				ofertasObj.data.recommendations[j].actionPhone = 'N/A';
			}

		}

		component.set('v.newOffertas', ofertasObj);
	},

	calculateAditionals : function(component, ofertasObj) {
		var produtoAtual = component.get('v.produtoAtual');
		var currentTotal = produtoAtual.totalValue;
		var ofertas = ofertasObj.data.recommendations;
        var hasDiscountAutomaticDebit;
        if (ofertas.length > 2) {
            hasDiscountAutomaticDebit = component.get('v.oferta3').hasDiscountAutomaticDebit;
        } else if (ofertas.length > 1) {
            hasDiscountAutomaticDebit = component.get('v.oferta2').hasDiscountAutomaticDebit;
        } else if (ofertas.length > 0) {
            hasDiscountAutomaticDebit = component.get('v.oferta1').hasDiscountAutomaticDebit;
        }
		var automaticDebitDiscount;
		var totalAdditionals;
		var oferta;
		var extra;
		if (ofertasObj.data.recommendations) {
			for (var i = 0; i < ofertasObj.data.recommendations.length; i++) {
				totalAdditionals = 0;
				automaticDebitDiscount = 0;
				oferta = ofertasObj.data.recommendations[i];
				if (oferta) {
					var value;
					if (oferta.extras.length > 0) {
						for (var y = 0 ; y < oferta.extras.length; y++) {
							extra = oferta.extras[y];
							if (extra.isAlreadyIncluded === "1") {
								if (extra.promotion.discount.value) {
									value = parseFloat(extra.price) - parseFloat(extra.promotion.discount.value);
								} else {
									value = parseFloat(extra.price);
								}
								totalAdditionals += value;
							}
						}
					} 
					else  {
						totalAdditionals += oferta.nboTv[0].optionalPointsPricing ? parseFloat(oferta.nboTv[0].optionalPointsPricing) : 0;
						totalAdditionals += oferta.nboTv[0].aLaCartePricing ? parseFloat(oferta.nboTv[0].aLaCartePricing) : 0;
						totalAdditionals += oferta.nboBroadband.additionalsTotalPricing ? parseFloat(oferta.nboBroadband.additionalsTotalPricing) : 0;
					}
					totalAdditionals += oferta.nboMobile[0].additionalsTotalPricing ? parseFloat(oferta.nboMobile[0].additionalsTotalPricing) : 0;

					if (hasDiscountAutomaticDebit) {
						if (oferta.nboTv[0].catalogName != "SEM PLANO") {
							automaticDebitDiscount += 5;
						}

						if (oferta.nboBroadband.catalogName != "SEM PLANO") {
							automaticDebitDiscount += 5;
						}
					}

					ofertasObj.data.recommendations[i].totalValue = oferta.totalProductPrice + totalAdditionals - automaticDebitDiscount;
					
					// calculo da diferença (listagem) 
					ofertasObj.data.recommendations[i].variation = oferta.totalValue - currentTotal;

					if(oferta.profile === '1'){  
						ofertasObj.data.recommendations[i].profile = 'Single';
					}else if(oferta.profile === '2'){
						ofertasObj.data.recommendations[i].profile = 'Double';
					}else if(oferta.profile === '3'){
						ofertasObj.data.recommendations[i].profile ='Triple';
					}else if(oferta.profile === '4'){
						ofertasObj.data.recommendations[i].profile = 'Combo Multi';
					}
				}
				
			}
		}
	},

	consultarPerfilRetencao: function (component, helper) {

		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];

		var action = component.get("c.isPerfilRentencao");
		action.setParams({
			"recordId": caseId
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();

				if (returnValue) {
					component.set('v.ShowCancelamento', false);
					component.set('v.ShowIsencaoTaxas', false);
				} else {
					component.set('v.ShowCancelamento', true);
					component.set('v.ShowIsencaoTaxas', true);
				}
			}
		});

		$A.enqueueAction(action);
	},

	removerAcento : function (text) {
		text = text.toLowerCase();                                                         
		text = text.replace(new RegExp('[ÁÀÂÃ]','gi'), 'a');
		text = text.replace(new RegExp('[ÉÈÊ]','gi'), 'e');
		text = text.replace(new RegExp('[ÍÌÎ]','gi'), 'i');
		text = text.replace(new RegExp('[ÓÒÔÕ]','gi'), 'o');
		text = text.replace(new RegExp('[ÚÙÛ]','gi'), 'u');
		text = text.replace(new RegExp('[Ç]','gi'), 'c');
		return text;
	},


	 calculoPercentual: function (component, lstPontuacao, lstOffers) {
			
		if(lstPontuacao && lstOffers){
			var produtoAntigo = component.get('v.produtoAtual');

			for (var j = 0; j<lstOffers.data.recommendations.length; j++) {
				var oferta = lstOffers.data.recommendations[j];
				var percentual = 100 * (oferta.totalValue / produtoAntigo.totalValue);
					for(var i = 0; i<lstPontuacao.length; i++){
						if(percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c){
							lstOffers.data.recommendations[j].rewardPoints = lstPontuacao[i].Pointing__c;
							break;
					}
				}
			}
			component.set('v.ofertas', lstOffers);
			}
		},  

		calculateOriginalValueOferta: function(component) {
			var originalValue	   = 0;
			var descontoDep		   = 0;
			var descontoTit		   = 0;
			var indexMaior 		   = 0;
			var ofertaSelecionada  = component.get('v.ofertaSelecionada');
			var listDepProduto     = component.get('v.produtoAtual.mobile.listaDependentesMobile');
			var produtoAtual	   = component.get('v.produtoAtual');
	
			if(ofertaSelecionada.lstSteps){
			for(var index = 0; index<ofertaSelecionada.lstSteps.length; index++){				
				if(ofertaSelecionada.lstSteps[index].label != null && parseInt(ofertaSelecionada.lstSteps[index].label) > indexMaior){
					indexMaior = parseInt(ofertaSelecionada.lstSteps[index].label);
					originalValue = ofertaSelecionada.lstSteps[index].value;
					ofertaSelecionada.totalValueOriginal = originalValue;
					ofertaSelecionada.difTotal = ofertaSelecionada.totalValueOriginal - produtoAtual.totalValue;
				}			
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
	
			component.set('v.ofertaSelecionada', ofertaSelecionada);
		},
})