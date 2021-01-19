({
	initialLoad : function(component) {
        this.setColumns(component);
        this.getBillingParams(component);
	},
    
    getBillingParams : function(component) {
       let action = component.get('c.getInvoiceParams');
       let caseid = component.get('v.recordId');
       
        action.setParams ({
            strId : caseid         
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue();
            let params = [];
            
            if(state === 'SUCCESS'){
				params = data.split('/');
				component.set('v.operatorId', params[0]);
				component.set('v.contractId', params[1]);
				this.callOpenInvoices(component);  
            }
        });
        $A.enqueueAction(action);
        
    },
    
    callOpenInvoices : function(component) {

        if(!component.get('v.contractId') || !component.get('v.operatorId'))
			return; 
		
		component.set('v.isLoading', true);

		let action = component.get('c.getOpenInvoicesByPeriod');
		action.setParams({contractId: component.get('v.contractId'),
						operatorId: component.get('v.operatorId'),
                          period: component.get('v.period')

		});
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue();
            
            if(state === 'SUCCESS'){
                if(data.success){
					data.invoices.forEach(x => {
						let realValue = JSON.parse(JSON.stringify(x.valor));
						realValue = Number(realValue.replace(/[^0-9,.]/g, '').replace(',','.').replace(' ',''));
						x.realValue = realValue;

						x.hasContestation = x.contestation != null && x.contestation != undefined;
						x.hasContestationText = x.contestation ? 'Sim' : 'Não';

						let realDate = JSON.parse(JSON.stringify(x.dataVencimento));   
						if(realDate != null && realDate != undefined){
							realDate = realDate.split("/");
							x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
						}                    
					});
					var invoicesToPush = [];
					if(data.invoices.length <= 6){
						component.set('v.invoices', data.invoices);
					}
					else{
						for(var i = 0; i < 6; i++){
							invoicesToPush.push(data.invoices[i]);
						}
					}
					component.set('v.invoices', invoicesToPush);
                    component.set('v.errorOnCall', false);
                }else{
                    this.showToast('Erro', data.message, 'error');
                    component.set('v.errorOnCall', true);
                }   
            }else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors[0] && errors[0].message){
                    this.showToast('Erro', errors[0].message, 'error');
                    component.set('v.errorOnCall', true);
                }     
            }
            
            component.set('v.isLoading', false);
        });
		$A.enqueueAction(action);
    },
    
    setColumns : function(component) {
        const columns = [
            {label: 'Data de Venc.', fieldName: 'dataVencimento', type: 'text', sortable: true},
			{label: 'Valor', fieldName: 'valor', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'status', type: 'text', sortable: true}
        ];
        
        component.set('v.columns', columns);
    },
            
    //MÉTODO PARA CHAMAR AS OPÇOES DE SEGUNDA VIA PARA A FATURA
	getInvoiceDuplicates : function(component, invoice, callback){
		let action = component.get('c.getDuplicateInfo');
		action.setParams({
						billId: invoice.idFatura,
						operatorCode: component.get('v.operatorId')
		});
        action.setCallback(this, function(response){
            let state = response.getState();
            let data = response.getReturnValue();
      
            if(state === 'SUCCESS'){

				if(data.success){

					let sendMethod = data.duplicates.availableSendMethods;
					var methods=[];
		
					for (let index = 0; index < sendMethod.length; index++) {
						let currentOption = sendMethod[index];
						var option = {
							'label': currentOption.sendMethodDescription,
							'value': currentOption.sendMethodId   
						};
						methods.push(option);
					}
					let sendReasons = data.duplicates.availableReasons;
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
					component.set('v.duplicate', data.duplicates);

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
    
    //MÉTODO PARA POST DE SEGUNDA VIA PARA A FATURA
	postInvoiceDuplicates : function(component, invoice, callback){
		console.log('entrou duplicater');
		const sendMethodOption = component.get('v.sendMethodOptions');
		const selectedMethod = component.get('v.selectedSendMethod');
		const sendMethodSize = sendMethodOption.length;
		let sendMethod;
		
        for (var i = 0; i < sendMethodSize; i++) {
			let methodOption = sendMethodOption[i];

            if(methodOption.value == selectedMethod)
                sendMethod = methodOption.label;
		}

		sendMethod = sendMethod.replace(/-/g, '');
		
		console.log('sendMethod ->', JSON.parse(JSON.stringify(sendMethodOption)));
		console.log('method option selected', JSON.parse(JSON.stringify(component.get('v.selectedSendMethod'))));
		console.log('sendMethod', JSON.parse(JSON.stringify(sendMethod)));
        
        let action = component.get('c.postDuplicate');
        action.setParams({
            			operatorCode: component.get('v.operatorId'),
						contractNumber: component.get('v.duplicate.contractNumber'),
						userName: 'REMOVER PROXIMA SPRINT',
						billId: invoice.idFatura,
						name: component.get('v.duplicate.name'),
						phoneNumber: component.get('v.duplicate.phoneNumber'),
						email: component.get('v.duplicate.email'),
						//sendMethod: component.get('v.selectedSendMethod'),
						sendMethod: sendMethod,
						billExtend: component.get('v.duplicate.billExtend'),
						descriptionReason: component.get('v.selectedSendReason')
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
                    component.set('v.dialogModal', true);
                    component.find('Solar_Cross_modalMessage').open();
                    component.set('v.isLoadingModal',false);
                }else{
					component.set('v.title', $A.get("$Label.c.Fin_send_title_error"));
					component.set('v.typeIcon', 'utility:warning');
					component.set('v.typeVariant', 'error');
					component.set('v.message', data.postDuplicateResponse);
                    component.set('v.dialogModal', true);
					component.find('Solar_Cross_modalMessage').open();
                    component.set('v.isLoadingModal',false);
                }
            }else if(state === 'ERROR'){
                component.set('v.title', 'Alerta:');
                component.set('v.typeIcon', 'utility:warning');
                component.set('v.typeVariant', 'warning');
				component.set('v.message', data.message );
                component.set('v.dialogModal', true);
				component.find('Solar_Cross_modalMessage').open();
                component.set('v.isLoadingModal',false);
            } 

        });
		$A.enqueueAction(action);

	},
    
    
})