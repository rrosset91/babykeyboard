/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 22-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   22-01-2021   Diego Almeida   Initial Version
**/
({
	//MÉTODO PARA CHAMAR AS OPÇOES DE SEGUNDA VIA PARA A FATURA
	getInvoiceDuplicates : function(component, invoice, callback){
		let action = component.get('c.getDuplicateInfo');
		action.setParams({billId: invoice.idFatura, operatorCode: component.get('v.operatorId')});
        action.setCallback(this, function(response){
            let state = response.getState();
            let data = response.getReturnValue();
            if(state === 'SUCCESS'){
				if(data.success){
					let sendMethod = data.availableSendMethods;
					var methods=[];
					for (let index = 0; index < sendMethod.length; index++) {
						let currentOption = sendMethod[index];
						var option = {
							'label': currentOption.sendMethodDescription,
							'value': currentOption.sendMethodId
						};
						methods.push(option);
					}
					let sendReasons = data.availableReasons;
					var reasons=[];
					for (let index = 0; index < sendReasons.length; index++) {
						let currentOption = sendReasons[index];
						var option = {
							'label': currentOption.SolarReason__c,
							'value': currentOption.SolarReason__c
						};
						reasons.push(option)
					}
					component.set("v.sendMethodOptions",methods);
					component.set("v.sendReasonOptions",reasons);
					component.set('v.duplicate', data);
					if(callback)
						callback(data.duplicates);
                }else{
					this.showToast('Erro', data.message, 'error');

					if(callback)
						callback(null, data.message);
                }
            }else if(state === 'ERROR'){
				const errors = response.getError();

                if(errors[0] && errors[0].message)
					this.showToast('Erro', errors[0].message, 'error');

				if(callback)
					callback(null, errors);
			}
        });
		$A.enqueueAction(action);
    },

    postInvoiceDuplicates : function(component, invoice, callback){
		console.log('entrou duplicater');
        var sendMethodOption = component.get('v.sendMethodOptions');
        var sendMethod;
        for (var i = 0; i < sendMethodOption.length; i++) {
            console.log('sendMethod', sendMethodOption[i]);
            if(sendMethodOption[i].value == component.get('v.selectedSendMethod')){
                sendMethod  = sendMethodOption[0].label;
            }
        }
        let action = component.get('c.postDuplicate');
        action.setParams({
            			operatorCode: component.get('v.operatorId'),
						contractNumber: component.get('v.duplicate.contractNumber'),
						userName: 'ALTERAR PROXIMA SPRINT',
						billId: invoice.idFatura,
						name: component.get('v.duplicate.name'),
						phoneNumber: component.get('v.duplicate.phoneNumber'),
						email: component.get('v.duplicate.email'),
						sendMethod: sendMethod,
						billExtend: component.get('v.duplicate.billExtend'),
						descriptionReason: component.get('v.selectedSendReason'),
						caseId : component.get('v.recordId')
        });

        action.setCallback(this, function(response){
            const state = response.getState();
			const data = response.getReturnValue();
			console.log('data retorno duplicate ->', JSON.parse(JSON.stringify(data)));
            if(state === 'SUCCESS'){
                if(data.success){
                    component.set('v.title', $A.get("$Label.c.Fin_send_title_success"));
                    component.set('v.typeIcon', 'utility:success');
                    component.set('v.typeVariant', 'success')
                    component.set('v.message', $A.get("$Label.c.Fin_send_success"));
                    component.find('modalMessage').open();
                }else{
					component.set('v.title', $A.get("$Label.c.Fin_send_title_error"));
					component.set('v.typeIcon', 'utility:warning');
					component.set('v.typeVariant', 'error');
					component.set('v.message', data.postDuplicateResponse);
					component.find('modalMessage').open();
                }
            }else if(state === 'ERROR'){
                component.set('v.title', 'Alerta:');
                component.set('v.typeIcon', 'utility:warning');
                component.set('v.typeVariant', 'warning');
				component.set('v.message', data.message );
				component.find('modalMessage').open();
            }

        });
		$A.enqueueAction(action);

	},

    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})