({
	updateFeesExemptions: function (component, event, helper) {
		var feesExemptions = component.get("v.feesExemptions");
		var oferta = component.get("v.ofertaSelecionada");
		var listT = component.get("v.lstIsencaoTaxa");
		var check = false;
		for (var i = 0; i < listT.length; i++) {
			if(listT[i].checked){
				check = true;
				if(listT[i].label == "Isenção de Taxa de Adesão de Wifi"){
					feesExemptions.wifi = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Mudança de Endereço"){
					feesExemptions.address = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Visita Técnica"){
					feesExemptions.visit = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Migração do Docsis 2.0 para 3.0"){
					feesExemptions.docsis = true;
				}
			} 
		}
		if (oferta) {
			oferta.free = check;//feesExemptions.wifi || feesExemptions.address || feesExemptions.visit || feesExemptions.docsis;
		}

		component.set("v.feesExemptions", feesExemptions);
		component.set("v.ofertaSelecionada", oferta);
		//component.set("v.lstIsencaoTaxa",listT);
	},

	getSuspensionOptions: function (component) {
		let action = component.get('c.getSuspensionData');
		action.setCallback(this, function (response) { 
			let state = response.getState();
			if (state === 'SUCCESS') {
				let data = JSON.parse(response.getReturnValue());
				
				let periodOptions = [];
				data.forEach((option) => {
					periodOptions.push({
						period : option.Period__c,
						modalities : option.Modality__c.split(';'),
						phoneProduct : option.Label,
						productId: option.ProductIdPhone__c
					});
				});
				component.set('v.periodOptions', periodOptions);
			}
		});
		$A.enqueueAction(action);
	},

	getSuspensionProducts: function (component) {
		let action = component.get('c.getSuspensionProducts');
		action.setCallback(this, function (response) { 
			let state = response.getState();
			if (state === 'SUCCESS') {
				let data = JSON.parse(response.getReturnValue());
				
				let products = [];
				data.forEach((option) => {
					products.push({
						productType : option.ProductType__c,
						sequence: option.Sequence__c,
						technologies: option.Technology__c.split(';'),
						productId: option.ProductId__c,
						product : option.Label
					});
				});
				component.set('v.suspensionProducts', products);
			}
		});
		$A.enqueueAction(action);
	},

	getProductOptions: function (component) {
		let contractProducts = component.get('v.posse');		
		let produtoAtual = component.get('v.produtoAtual');		
		if(produtoAtual!=null){
		if ($A.util.isEmpty(contractProducts)) {
			return;
		}

		let products = [];
		if(contractProducts.hasTV && !produtoAtual.tv[0].planTv.label.includes('SUSPENSAO')){
			products.push({'label': 'TV', 'value': 'TV'});
		}
		if (contractProducts.hasBroadBand && !produtoAtual.broadband.planBroadband.label.includes('SUSPENSAO')) {
			products.push({'label': 'BL', 'value': 'VTA'});
		}
		if(contractProducts.hasPhone && !produtoAtual.phone.planPhone.label.includes('SUSPENSAO')){
			products.push({'label': 'FIXO', 'value': 'netFone'});
		}

		component.set('v.productOptions', products);
		}	
	},

	validateSuspension: function (component) {
		let produtoAtual = component.get('v.produtoAtual');
		let ofertaSelecionada = component.get('v.ofertaSelecionada');
		let period = component.get('v.selectedPeriod');
		let modality = component.get('v.selectedModality');

		if ($A.util.isEmpty(period)) {
			component.set('v.temporarySuspension', {hasSuspension: false});
			let pageEvent = $A.get('e.c:NBA_PageEvent');
			pageEvent.setParams({ 'action': 'RESET_ADDITIONALS',
									'data': {recalculateCurrentProduct : 'Sim',
										isNotCurrentProduct: false	
										}
		});
			pageEvent.fire();
		}
		if ($A.util.isEmpty(period) || produtoAtual != ofertaSelecionada) {
			return true;
		}

		let isValid = true;
		let selectedProducts = component.get('v.selectedProducts');
		if ($A.util.isEmpty(period) || $A.util.isEmpty(modality) || $A.util.isEmpty(selectedProducts) || $A.util.isEmpty(selectedProducts[0])) {
			isValid = false;
		}

		if (isValid) {
			this.applySuspension(component);
		}

		return isValid;
	},

	applySuspension: function (component) {
		let suspendedProducts = [];

		component.get('v.selectedProducts').forEach((selectedProduct) => { 
			if (selectedProduct == 'VTA') {
				let blTech = component.get('v.produtoAtual').broadband.planBroadband.label.includes(' PON ') ? 'PON' : 'Demais';
				let blSuspensionProduct = component.get('v.suspensionProducts').find((item) => {
					return item.productType == selectedProduct && item.technologies.includes(blTech);
				});
				suspendedProducts.push({
					productType: 'BL',
					productBody: blSuspensionProduct
				});
			}

			if (selectedProduct == 'TV') {
				suspendedProducts.push({
					productType: 'TV',
					productBody: component.get('v.suspensionProducts').find((item) => {
						return 	item.productType==selectedProduct && (item.technologies.includes('Demais') ||
								item.technologies.find((itemTech) => component.get('v.produtoAtual').tv[0].planTv.nameLegacy.includes(itemTech))!==undefined);
					})
				});
				['first','second','third','fourth'].forEach((pointName)=>{
					if(component.get('v.produtoAtual.tv[0].addOptions.'+pointName+'Point.checked')){
						suspendedProducts.push({
							productType: 'TVOptional',
							productId: pointName,
							productBody: component.get('v.suspensionProducts').find((item) => {
								return 	item.productType==selectedProduct && (item.technologies.includes('Demais') ||
										item.technologies.find((itemTech) => component.get('v.produtoAtual.tv[0].addOptions.'+pointName+'Point.label').includes(itemTech))!==undefined);
							})
						});
					}
				});
			}
			if(selectedProduct == 'netFone'){
				suspendedProducts.push({
					productType: 'netFone',
					productBody: component.get('v.periodOptions').find((item) => {
						return item.period == component.get('v.selectedPeriod')
					})
				})
		}
		});

		component.set('v.temporarySuspension', {
			hasSuspension: true,
			period: component.get('v.selectedPeriod'),
			modality: component.get('v.selectedModality'),
			selectedProducts: component.get('v.selectedProducts'),
			suspendedProducts: suspendedProducts
		});

		let pageEvent = $A.get('e.c:NBA_PageEvent');
		pageEvent.setParams({ 'action': 'RESET_ADDITIONALS',
								'data': {recalculateCurrentProduct : 'Sim',
										isNotCurrentProduct: false	
										}
							});
		pageEvent.fire();
	},

	
	
	cleanSuspension: function(component, event,data) {
		component.set('v.temporarySuspension', {hasSuspension: false});
		component.set('v.selectedPeriod', null);
		component.set('v.selectedModality', null);
		component.set('v.selectedProducts', []);
        if(component.get('v.ofertaSelecionada') !== component.get('v.produtoAtual')){
         let pageEvent = $A.get('e.c:NBA_PageEvent');
			pageEvent.setParams({
				'action': 'RESET_ADDITIONALS',
				'data': {recalculateCurrentProduct : 'Sim',
						isNotCurrentProduct: true	
						}
			});
		pageEvent.fire();   
        }else{
		let pageEvent = $A.get('e.c:NBA_PageEvent');
		pageEvent.setParams({'action' : 'RESET_ADDITIONALS',
							'data': {recalculateCurrentProduct : data.recalculateCurrentProduct,
									isNotCurrentProduct: false	
									}
								});
		pageEvent.fire();
        }	 
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
})