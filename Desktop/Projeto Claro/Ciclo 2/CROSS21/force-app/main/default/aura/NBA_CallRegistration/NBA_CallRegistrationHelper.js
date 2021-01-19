({
	dispatchRetained : function(component, event, helper) {
		var action 			= component.get('c.sendRetained');
		let cdBase 			= component.get('v.cdBase');
		let callReason 		= component.find('callReason').get("v.value");
		let callSubReason 	= component.find('callSubReason').get("v.value");
		let bln1 			= component.find('bln1').get("v.value");
		let bln2 			= component.find('bln2').get("v.value");
		let bln3 			= component.find('bln3').get("v.value");
		let tvn1 			= component.find('tvn1').get("v.value");
		let tvn2 			= component.find('tvn2').get("v.value");
		let tvn3 			= component.find('tvn3').get("v.value");
		let phonen1 		= component.find('phonen1').get("v.value");
		let phonen2 		= component.find('phonen2').get("v.value");
		let phonen3 		= component.find('phonen3').get("v.value");
		let mobilen1 		= component.find('mobilen1').get("v.value");
		let mobilen2 		= component.find('mobilen2').get("v.value");
		let mobilen3 		= component.find('mobilen3').get("v.value");
		let lctn1 			= component.find('lctn1').get("v.value");
		let lctn2 			= component.find('lctn2').get("v.value");
		let lctn3 			= component.find('lctn3').get("v.value");
		console.log('dispatchRetained');
		if (cdBase && cdBase != 'undefined') {			
			action.setParams({
				"recordId" : component.get('v.recordId'),
				"reason" : callReason,
				"subReason" : callSubReason,
				"tvn1" : tvn1,
				"tvn2" : tvn2,
				"tvn3" : tvn3,
				"bln1" : bln1,
				"bln2" : bln2,
				"bln3" : bln3,
				"phonen1" : phonen1,
				"phonen2" : phonen2,
				"phonen3" : phonen3,
				"mobilen1" : mobilen1,
				"mobilen2" : mobilen2,
				"mobilen3" : mobilen3,
				"lctn1" : lctn1,
				"lctn2" : lctn2,
				"lctn3" : lctn3,
				"cdBase" : cdBase
			});
			action.setCallback(this, function (response) {
				//component.set('v.showSpinner', false);
				var state = response.getState();
				if (state === "SUCCESS") {
					var data = JSON.parse(response.getReturnValue());
					if (data.status == 'OK') {
						helper.dispatchRetained2(component, event, helper);
					} else { 
						component.set('v.validaRetido', true);
						component.set('v.msgRetido' , 'O Serviço que gera automaticamente o Lead está indisponível, favor gerar manualmente no NetSMS');						
					}
				}  else if (state === "ERROR") {
					component.set('v.showSpinner', false);
					component.set('v.validaRetido', true);
					component.set('v.msgRetido' , 'O Serviço que gera automaticamente o Lead está indisponível, favor gerar manualmente no NetSMS');
				}
			});
			$A.enqueueAction(action);
		}else{
			component.set('v.validaRetido', true);
			component.set('v.msgRetido' , 'Dados insuficientes para abertura de Ocorrência para este atendimento!');
		}
	},
	dispatchRetained2 : function(component, event, helper) {
		var action 			= component.get('c.sendRetained');
		let cdBase 			= component.get('v.cdBase');
		let callReason 		= component.find('callReason').get("v.value");
		let callSubReason 	= component.find('callSubReason').get("v.value");
		let bln1 			= component.find('bln1').get("v.value");
		let bln2 			= component.find('bln2').get("v.value");
		let bln3 			= component.find('bln3').get("v.value");
		let tvn1 			= component.find('tvn1').get("v.value");
		let tvn2 			= component.find('tvn2').get("v.value");
		let tvn3 			= component.find('tvn3').get("v.value");
		let phonen1 		= component.find('phonen1').get("v.value");
		let phonen2 		= component.find('phonen2').get("v.value");
		let phonen3 		= component.find('phonen3').get("v.value");
		let mobilen1 		= component.find('mobilen1').get("v.value");
		let mobilen2 		= component.find('mobilen2').get("v.value");
		let mobilen3 		= component.find('mobilen3').get("v.value");
		let lctn1 			= component.find('lctn1').get("v.value");
		let lctn2 			= component.find('lctn2').get("v.value");
		let lctn3 			= component.find('lctn3').get("v.value");
		console.log('dispatchRetained2');
		if (cdBase && cdBase != 'undefined') {			
			action.setParams({
				"recordId" : component.get('v.recordId'),
				"reason" : callReason,
				"subReason" : callSubReason,
				"tvn1" : tvn1,
				"tvn2" : tvn2,
				"tvn3" : tvn3,
				"bln1" : bln1,
				"bln2" : bln2,
				"bln3" : bln3,
				"phonen1" : phonen1,
				"phonen2" : phonen2,
				"phonen3" : phonen3,
				"mobilen1" : mobilen1,
				"mobilen2" : mobilen2,
				"mobilen3" : mobilen3,
				"lctn1" : lctn1,
				"lctn2" : lctn2,
				"lctn3" : lctn3,
				"cdBase" : cdBase
			});
			action.setCallback(this, function (response) {
				component.set('v.showSpinner', false);
				var state = response.getState();
				if (state === "SUCCESS") {
					var data = JSON.parse(response.getReturnValue());
					if (data.status == 'OK') {
						component.set('v.validaRetido', true);
						component.set('v.msgRetido' , 'Lead de Retido Gerado com Sucesso');
					} else { 
						component.set('v.validaRetido', true);
						component.set('v.msgRetido' , 'O Serviço que gera automaticamente o Lead está indisponível, favor gerar manualmente no NetSMS');						
					}
				}  else if (state === "ERROR") {
					component.set('v.validaRetido', true);
					component.set('v.msgRetido' , 'O Serviço que gera automaticamente o Lead está indisponível, favor gerar manualmente no NetSMS');
				}
			});
			$A.enqueueAction(action);
		}else{
			component.set('v.validaRetido', true);
			component.set('v.msgRetido' , 'Dados insuficientes para abertura de Ocorrência para este atendimento!');
		}
	},
	checkHasChangesT : function(component, event, helper) {
		let oldProduct = sessionStorage.getItem('oldProduct');
		let newProduct = sessionStorage.getItem('newProduct');
		if(oldProduct){
			if(newProduct){
				newProduct = newProduct.replace(',"selected":true','');
				if(newProduct == oldProduct){
					component.set('v.retido', true);
				}
			} 
		}
	},
	cdBase : function(component) {
		let cdBase = sessionStorage.getItem('cdBase');
		if(cdBase){
			component.set('v.cdBase', cdBase);
		}	
	},
	checkHasChanges : function(component, event, helper) {
		let inputOrigin = event.getSource().get('v.value');
		if (inputOrigin) {
			if (inputOrigin == 'RETIDO') {
				component.set('v.retido', true);
			}else{
				component.set('v.retido', false);
			}
		}
	},
	consultarPerfilHelper : function(component) {
		var action = component.get('c.isPerfilRentabilizacaoAtiva');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.activeMonetization', data);
			}  else if (state === "ERROR") {
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
		});
		$A.enqueueAction(action);
	},
	consultarPerfilRetencaoHelper : function(component) {
		var action = component.get('c.isPerfilRetencao');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.isRetencao', data);
			}  else if (state === "ERROR") {
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
		});
		$A.enqueueAction(action);
	},
	getCaseDetails : function(component) {
		var action = component.get('c.getCaseDetails');
		action.setParams({
			"recordId" : component.get('v.recordId')})
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.caseStatus', data.Status);
				component.set('v.totalCancelation', data.TotalCancellation__c == null ? false : data.TotalCancellation__c);
				component.set('v.caseOrder', data.Order__r);
				component.set('v.temSistemaIndisponivel', 
					data.TVN2Result__c=='SISTEMA INDISPONÍVEL' || data.BLN2Result__c=='SISTEMA INDISPONÍVEL' ||
					data.PhoneN2Result__c=='SISTEMA INDISPONÍVEL' || data.MobileN2Result__c=='SISTEMA INDISPONÍVEL' || 
					data.ALaCarteN2Result__c=='SISTEMA INDISPONÍVEL'
				);
                
                component.set('v.isContractPME',data.ContractNumber__r.Segmentation__c.includes('PME'));                                

				component.set('v.temInadimplencia', 
					data.TVN2Result__c=='INADIMPLENTE' || data.BLN2Result__c=='INADIMPLENTE' ||
					data.PhoneN2Result__c=='INADIMPLENTE' || data.MobileN2Result__c=='INADIMPLENTE' || 
					data.ALaCarteN2Result__c=='INADIMPLENTE'
				);

			}  else if (state === "ERROR") {
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
		});
		$A.enqueueAction(action);
	},
	toGetOrderIDCase : function(component, event, helper) {
		//var sPageURL = ' ' + window.location;
        //var sURL = sPageURL.split('/');
        //var caseId = sURL[sURL.length - 2];
		var caseId = component.get("v.recordId");
		var action = component.get('c.toRecuperaContractId'); 
		action.setParams({
           "recordId" : caseId
        	})
		action.setCallback(this, function (response) {
			component.set('v.showSpinner', false);
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				//Redirecionamento para o contrato
				var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": data,
                    "slideDevName": "detail"
                });
                navEvt.fire();
			}  else if (state === "ERROR") {
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
		});
		$A.enqueueAction(action);
	},

	copyLevel : function(component, event, helper) {
		event.stopPropagation();
		
		let fieldValue = event.getSource().get('v.value');
		let fieldId = event.getSource().getLocalId();

		let isRetencao = component.get('v.isRetencao');
		let totalCancelation = component.get('v.totalCancelation');
		let order = component.get('v.caseOrder');

		if (component.get('v.temSistemaIndisponivel') || totalCancelation || fieldValue == 'NULL') {
			return;
		}

		let products = [
			{baseId: 'tvn', movement: 'TVMovement__c'}, 
			{baseId: 'bln', movement: 'VirtuaMovement__c'}, 
			{baseId: 'phonen', movement: 'NETFoneMovement__c'},
			{baseId: 'mobilen', movement: 'MobileMovement__c'}, 
			{baseId: 'lctn', movement: 'ALaCarteMoviment__c'}
		];

		let sourceFieldValues = [];
		for (let levelNumber = 1; levelNumber <= 3; levelNumber++) {
			products.forEach((product, index) => {
				let field = product.baseId + levelNumber;
				if (field == fieldId) {
					for (let innerLevelNumber = 1; innerLevelNumber <= levelNumber; innerLevelNumber++)
						sourceFieldValues.push(component.find(product.baseId + innerLevelNumber).get('v.value'));
					products.splice(index, 1);
				}
			});
			if (products.length < 5) {
				break;
			}
		}

		products.forEach((product) => {
			if (
				(
					(
						isRetencao && 
						($A.util.isEmpty(order) || $A.util.isEmpty(order[product.movement]))
					) ||
						(
						!isRetencao && 
						(sourceFieldValues[0] == 'INFORMAÇÕES' || sourceFieldValues[0] == 'IMPRODUTIVO') && 
						($A.util.isEmpty(order) || $A.util.isEmpty(order[product.movement]))
					)
				) && 
				!$A.util.isEmpty(fieldValue)
			) {
				for (let levelNumber = 1; levelNumber <= sourceFieldValues.length; levelNumber++) 
					component.find(product.baseId + levelNumber).set('v.value', sourceFieldValues[levelNumber-1]);
			}
		});

	}	
})