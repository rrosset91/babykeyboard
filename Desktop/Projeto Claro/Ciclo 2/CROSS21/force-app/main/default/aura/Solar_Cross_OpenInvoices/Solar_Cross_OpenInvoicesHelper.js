({
	initialLoad : function(component) {
        // this.setColumns(component); função comentada, pois partir da TU45 as colunas são montadas após a chamada do registro, para que seja dinamica caso seja um registro móvel ou residencial
        this.getBillingParams(component);
	},
    
    getBillingParams : function(component) {
       let action = component.get('c.getCase');
       let caseid = component.get('v.recordId');
       
        action.setParams ({
            strId : caseid         
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue();
            if(state === 'SUCCESS'){
				let mobileLabel = $A.get("$Label.c.Solar_Cross_MobileContract").split(';');
				let residentialLabel = $A.get("$Label.c.Solar_Cross_ResidentialContract").split(';');
				if(mobileLabel.includes(data.ContractBillingAccount__r.BusinessUnit__c)){
					var columns;
					component.set('v.isMobile',true);
					columns = [
						{label: 'DATA DE VENC.', fieldName: 'dataVencimento', type: 'text', sortable: true},
						{label: 'VALOR', fieldName: 'valor', type: 'text', sortable: true},
						{label: 'STATUS', fieldName: 'status', type: 'text', sortable: true}
					];
				}else if(residentialLabel.includes(data.ContractBillingAccount__r.BusinessUnit__c)){
					component.set('v.isMobile',false);
					columns = [
						{label: 'STATUS', fieldName: 'status', type: 'text', sortable: true},
						{label: 'VENCIMENTO', fieldName: 'dataVencimento', type: 'text', sortable: true},
						{label: 'SITUAÇÃO',cellAttributes : {iconName: { fieldName: 'iconUsed' }, iconPosition: 'left',class: { fieldName: 'varianIcon' }},initialWidth: 75,hideDefaultActions: true},
						{label: 'DESCRIÇÃO', fieldName: 'eventDescription', type: 'text', sortable: true},
						{label: 'MÉTODO', fieldName: 'cobranca', type: 'text', sortable: true},
						{label: 'VALOR', fieldName: 'valor', type: 'text', sortable: true},
						{label: 'VER MAIS', type: 'button-icon', initialWidth: 100, typeAttributes:
							{ label: 'Ver mais', title: 'Ver mais', name: 'showDetails', iconName: 'utility:preview', class: 'error'}}
					];			
				}
				component.set('v.columns', columns);
				component.set('v.operatorId', data.ContractBillingAccount__r.CityCode__c);
				//component.set('v.operatorId', params[0]);
				//component.set('v.contractId', params[1]);
				this.callOpenInvoices(component,data);  
            }
        });
        $A.enqueueAction(action);
        
    },
    
    callOpenInvoices : function(component,objCasejs) {		
		component.set('v.isLoading', true);

		let action = component.get('c.getOpenInvoicesByPeriod');
		action.setParams({
						objCase: objCasejs,
						period: component.get('v.period'),
						recordId : component.get('v.recordId'),
						isMobile: component.get('v.isMobile')

		});
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue()
			console.log('data Invoices' + JSON.stringify(data));

			 //var data = {"invoicesEvents":{"169319362":[{"invoiceID":169319362,"invoiceStatusID":1,"invoiceStatusDescription":"Em Aberto","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-12-06T00:00:00Z","eventDescription":"Evento de fatura disponivel para pagamento"},{"invoiceID":169319362,"invoiceStatusID":1,"invoiceStatusDescription":"Em Aberto","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-12-06T00:00:00Z","eventDescription":"Evento de envio de pagamento ao banco"}],"171109329":[{"invoiceID":171109329,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-07T00:00:00Z","eventDescription":"Evento de fatura disponivel para pagamento"},{"invoiceID":171109329,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-07T00:00:00Z","eventDescription":"Evento de envio de pagamento ao banco"},{"invoiceID":171109329,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-25T00:00:00Z","eventDescription":"Evento de pagamento de fatura"},{"invoiceID":171109329,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":241,"criticalReasonDescription":"BAIXA DE DEBITO AUTOMATICO - DEBITO EFETUADO","eventDate":"2019-11-26T04:35:48Z","eventDescription":"Evento de retorno bancario"}]},
			 //"success":true,"invoices":[{"iconUsed":"utility:clear","varianIcon":"error","eventDescription":"Erro de pagamento","dataVencimento":"10/12/2019","idFatura":"171109329","status":"Em Aberto","tipoFatura":"Fatura","valor":"R$124.99"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/11/2019","idFatura":"169319362","status":"Pago","tipoFatura":"Fatura","valor":"R$124.99"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/10/2019","idFatura":"167527221","status":"Pago","tipoFatura":"Fatura","valor":"R$124.99"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/09/2019","idFatura":"165735094","status":"Pago","tipoFatura":"Fatura","valor":"R$156.44"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/08/2019","idFatura":"163897930","status":"Pago","tipoFatura":"Fatura","valor":"R$192.39"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/07/2019","idFatura":"162113223","status":"Pago","tipoFatura":"Fatura","valor":"R$192.39"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/06/2019","idFatura":"160226783","status":"Pago","tipoFatura":"Fatura","valor":"R$178.55"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/05/2019","idFatura":"158421157","status":"Pago","tipoFatura":"Fatura","valor":"R$178.55"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/04/2019","idFatura":"156588298","status":"Pago","tipoFatura":"Fatura","valor":"R$178.55"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/03/2019","idFatura":"154807951","status":"Pago","tipoFatura":"Fatura","valor":"R$178.55"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/02/2019","idFatura":"153012745","status":"Pago","tipoFatura":"Fatura","valor":"R$178.45"},{"iconUsed":"utility:success","varianIcon":"success","dataVencimento":"10/01/2019","idFatura":"151250676","status":"Pago","tipoFatura":"Fatura","valor":"R$178.55"}]}

            if(state === 'SUCCESS'){
				component.set("v.events",data.invoicesEvents);
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
					if(invoicesToPush.length > 0){
						component.set('v.invoices', invoicesToPush);
					}
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
	
	//função comentada, pois partir da TU45 as colunas são montadas após a chamada do registro, para que seja dinamica caso seja um registro móvel ou residencial
    // setColumns : function(component) {
    //     const columns = [
    //         {label: 'DATA DE VENC.', fieldName: 'dataVencimento', type: 'text', sortable: true},
	// 		{label: 'VALOR', fieldName: 'valor', type: 'text', sortable: true},
	// 		{label: 'STATUS', fieldName: 'status', type: 'text', sortable: true},
	// 		{label: 'Ver mais', type: 'button-icon', initialWidth: 150, typeAttributes:
    //             { label: 'Ver mais', title: 'Ver mais', name: 'showDetails', iconName: 'utility:edit', class: ''}}
    //     ];
        
    //     component.set('v.columns', columns);
    // },
            
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

	closeEventModalhelper: function (component, event) {
        var cmpTarget = component.find('EventModal');
        var cmpBack = component.find('EventBackDrop');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},
	
	openEventModalHelper: function (component, event) {
		var row = event.getParam('row');
		// component.set("v.event",row.idFatura);

		var events = component.get("v.events");
		console.log('all events ' + JSON.stringify(events));
		console.log('selected row ' + JSON.stringify(row));
		var contextEvent = events[row.idFatura];

		var selectedRowLst = [];
		selectedRowLst.push(row.idFatura);
		component.set("v.selectedRows",selectedRowLst);

		var selectedInvoices = [];
		selectedInvoices.push(row);
		component.set("v.selectedInvoices", selectedInvoices);


		var disableButton = row.status == 'Em Aberto' ? false : true;
		component.set("v.disabledGen", disableButton);
		console.log('contextEvent ' + JSON.stringify(contextEvent));
		component.set("v.contextEvent",contextEvent);

        var cmpTarget = component.find('EventModal');
        var cmpBack = component.find('EventBackDrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    
})