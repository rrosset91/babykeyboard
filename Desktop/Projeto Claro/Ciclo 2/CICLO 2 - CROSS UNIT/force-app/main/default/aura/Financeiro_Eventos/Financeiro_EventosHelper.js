({
    initialLoad : function(component) {
        this.setColumns(component);
        this.setFilters(component);
    },
    
    openCancelamento : function(component) {
        var componentList = "v.cancelData";
        var groupType = "Cancelamentos em andamento ou executados";
        this.fillDataAccordionList(component, componentList, groupType);
    },
    
    openCompras : function(component) {
        var componentList = "v.comprasData";
        var groupType = "Compras/ Movimentações de Produtos e Serviços";
        this.fillDataAccordionList(component, componentList, groupType);
    },
    
    openEventos : function(component) {
        var componentList = "v.eventsData";
        var groupType = "Eventos Técnicos / Serviços";
        this.fillDataAccordionList(component, componentList, groupType);
    },
    
    openHistory : function(component) {
        var componentList = "v.historyData";
        var groupType = "Manual de Lançamento";
        this.fillDataAccordionHistoryList(component, componentList, groupType);
    },

    openNewProducts : function(component) {
        var componentList = "v.newProductsData";
        var groupType = "New Products";
        this.fillDataAccordionNewProductList(component, componentList, groupType);
    },
    
    openAdjustment : function(component) {
        var componentList = "v.adjustmentData";
        var groupType = "Readjustments";
        this.fillDataAccordionAdjustmentList(component, componentList, groupType);
    },

    openOccurrenceAcompanhamento : function(component) {
        var componentList = "v.occurrenceDataAcompanhamento";
        var groupType = "Ocorrências de Acompanhamento de Chamados";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },

    openOccurrenceFinanceira : function(component) {
        var componentList = "v.occurrenceDataFinanceira";
        var groupType = "Ocorrências Financeiras";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },

    openOccurrenceCancelamento : function(component) {
        var componentList = "v.occurrenceDataCancelamento";
        var groupType = "Ocorrências de Cancelamento";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },

    openOccurrenceSolic : function(component) {
        var componentList = "v.occurrenceDataSolic";
        var groupType = "Ocorrências de Solicitações";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },
     //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
    openOccurrenceOutros : function(component) {
        var componentList = "v.occurrenceDataOutros";
        var groupType = "Ocorrências - Outros";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },

    openOccurrenceServico : function(component) {
        var componentList = "v.occurrenceDataServico";
        var groupType = "Ocorrências de Serviços";
        this.fillDataAccordionOccurrenceList(component, componentList, groupType);
    },

    openRequestFees : function(component) {
        var componentList = "v.feesData";
        var groupType = "Request Fees";
        this.fillDataAccordionRequestFeeList(component, componentList, groupType);
    },

    openPpvs : function(component) {
        var componentList = "v.ppvData";
        var groupType = "Pay Per View";
        this.fillDataAccordionPpvList(component, componentList, groupType);
    },
    
    openOutage : function(component) {
        var componentList = "v.outageData";
        var groupType = "Outage";
        this.fillDataAccordionOutageList(component, componentList, groupType);
    },
    fillDataAccordionList: function(component, componentList, groupType) {
        var solicData = component.get("v.dataSolic");
        var listData = [];
        for (let i = 0; i < solicData.length; i++) {
            var solic = solicData[i];
            console.log('solic'+i,solic);
            if(solic.groupType == groupType){
                listData.push(solic);
            }
        }
        console.log('listData',listData);
        component.set(componentList, listData);
    },
    
        fillDataAccordionHistoryList: function(component, componentList, groupType) {
        var histData = component.get("v.historyData");
        var listData = [];
        for (let i = 0; i < histData.length; i++) {
            var histRecord = histData[i];
            console.log('histRecord'+i,histRecord);
                listData.push(histRecord);
            
        }
        console.log('listData',listData);
        component.set(componentList, listData);
    },

    fillDataAccordionNewProductList: function(component, componentList, groupType) {
        var newProductData = component.get("v.newProductsData");
        var listData = [];
        for (let i = 0; i < newProductData.length; i++) {
            var newProductRecord = newProductData[i];
                listData.push(newProductRecord);   
        }
        component.set(componentList, listData);
    },

    fillDataAccordionAdjustmentList: function(component, componentList, groupType) {
        var adjustmentData = component.get("v.adjustmentData");
        var listData = [];
        for (let i = 0; i < adjustmentData.length; i++) {
            var adjustmentRecord = adjustmentData[i];
                listData.push(adjustmentRecord);   
        }
        component.set(componentList, listData);
    },
    
    fillDataAccordionOccurrenceList: function(component, componentList, groupType) {
        var occurrenceData = component.get("v.occurrenceData");
        var listData = [];
        for (let i = 0; i < occurrenceData.length; i++) {
            var occurrence = occurrenceData[i];
            if(occurrence.groupType == groupType){
                listData.push(occurrence);
            }
        }
        component.set(componentList, listData);
    },
    
    fillDataAccordionRequestFeeList: function(component, componentList, groupType) {
        var feeData = component.get("v.feesData");
        var listData = [];
        for (let i = 0; i < feeData.length; i++) {
            var feeRecord = feeData[i];
                listData.push(feeRecord);   
        }
        component.set(componentList, listData);
    },
    
    fillDataAccordionPpvList: function(component, componentList, groupType) {
        var ppvData = component.get("v.ppvData");
        var listData = [];
        for (let i = 0; i < ppvData.length; i++) {
            var ppvRecord = ppvData[i];
                listData.push(ppvRecord);   
        }
        component.set(componentList, listData);
    },

    fillDataAccordionOutageList: function(component, componentList, groupType) {
        var outageData = component.get("v.outageData");
        var listData = [];
        for (let i = 0; i < outageData.length; i++) {
            var outageRecord = outageData[i];
                listData.push(outageRecord);   
        }
        component.set(componentList, listData);
    },
	
	
    callSolicEvents : function(component, event, helper, openAction) {
        var dataSolic = component.get('v.dataSolic');
        if(!component.get('v.contractId') || !component.get('v.operatorId')){
        	return;
        }
        
        if((dataSolic == ''|| dataSolic == undefined)&& openAction){
            component.set('v.isLoading', true);
            if(component.get('v.PeriodoCustomizado')==false){
            var action = component.get('c.getEvents');
            action.setParams({
                contractId: component.get('v.contractId'),
                operatorId: component.get('v.operatorId'), 
                period: component.get('v.period')
            });
            }else if(component.get('v.PeriodoCustomizado')==true){
            var action = component.get('c.getEventsByDate');
            action.setParams({
                contractId: component.get('v.contractId'),
                operatorId: component.get('v.operatorId'), 
                startDate: component.get('v.FilterStartDate'),
                endDate: component.get('v.FilterEndDate')
            });
    
            }    
            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){                    
                    if(data.success){
                        data.events.forEach(x => {
                            if(!x.closeDate)
                                return;
                            const [dayName, month, day, hour, timezone, year] = x.closeDate.split(' ');
                            x.realDate = new Date(year, this.getMonth(month), day);
                            x.formattedDate = `${day}/${this.getMonth(month)}/${year}`;
                        });
                        console.log('dataSolic',data.events);
                        component.set('v.dataSolic', data.events);
                        component.set('v.errorOnCall', false);

                        this.openCancelamento(component);
                        this.openCompras(component);
                        this.openEventos(component);

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
        }


    },

	getMonth: function(month){
		const d = Date.parse(month + " 1, 2012");

		if(!isNaN(d)){
			const newMonth = new Date(d).getMonth() + 1;
			return newMonth < 10 ? '0' + newMonth : newMonth;
		}

		return -1;
	},

    findEventDetails : function(component, event){
		component.set('v.isLoading', true);

		let action = component.get('c.getEventDetails');
		action.setParams({
			contractId: component.get('v.contractId'),
			operatorId: component.get('v.operatorId'),
			requestId: event.requestID
		}); 
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue();
             
            if(state === 'SUCCESS'){
                if(data.success){
					console.log('Valor configurations -> ', JSON.parse(JSON.stringify(data.configurations)));
					console.log('Valor orders -> ', JSON.parse(JSON.stringify(data.orders)));
					console.log('Valor event -> ', JSON.parse(JSON.stringify(event)));

					event.evId = event.requestID.toString();

					data.configurations.forEach(x => {
                        if(!x.executionDate)
                                return;
						const [dayName, month, day, hour, timezone, year] = x.executionDate.split(' ');

						x.realDate = new Date(year, this.getMonth(month), day);
						x.formattedDate = `${day}/${this.getMonth(month)}/${year}`;
					});

					component.set('v.selectedEvent', {
						fullEv: event,
						orders: data.orders,
						configurations: data.configurations
					});
					component.find('detailModalEvent').open();
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
    
    findHistoryDetails : function(component, event){
        component.find('detailModalHistory').open();
        component.set('v.isLoading', false);
    },      

    findNewProductDetails : function(component, event){
        component.find('newProductModal').open();
        component.set('v.isLoading', false);
    },      

    findAdjustmentDetails : function(component, event){
        component.find('adjustmentModal').open();
        component.set('v.isLoading', false);
    },      

    findOccurrenceDetails : function(component, event){
        component.find('occurrenceModal').open();
        component.set('v.isLoading', false);
    },      

    findRequestFeeDetails : function(component, event){
        component.find('requestFeeModal').open();
        component.set('v.isLoading', false);
    },      

    findPpvDetails : function(component, event){
        component.find('ppvModal').open();
        component.set('v.isLoading', false);
    },    
    
    findOutageDetails : function(component, event){
        component.find('outageModal').open();
        component.set('v.isLoading', false);
    },     

    onCloseOccurrenceModal: function(component, event, helper){
        component.find('occurrencesTableCancelamento').set('v.selectedRows',[]);
        component.find('occurrencesTableFinanceira').set('v.selectedRows',[]);
        component.find('occurrencesTableAcompanhamento').set('v.selectedRows',[]);
        component.find('occurrencesTableServico').set('v.selectedRows',[]);
        component.find('occurrencesTableSolic').set('v.selectedRows',[]);
        component.find('occurrencesTableOutros').set('v.selectedRows',[]);  //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
    },
                    
    setColumns : function(component) {
		component.set('v.columns', [
			{label: 'Descrição', fieldName: 'requestTypeDescription', type: 'text', sortable: true},
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);

        component.set('v.columnsDetail', [
			{label: 'Tipo de OCs', fieldName: 'type', type: 'text', sortable: true},
			{label: 'Produto', fieldName: 'productDescription', type: 'text', sortable: true}
        ]);
    },
    
    setHistoryColumns : function(component) {
		component.set('v.historyColumns', [
			{label: 'Descrição', fieldName: 'extractItemTypeDescription', type: 'text', sortable: true},
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setNewProductColumns : function(component) {
		component.set('v.newProductsColumns', [
            {label: 'Descrição', fieldName: 'productDescription', type: 'text', sortable: true},
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setAdjustmentColumns : function(component) {
		component.set('v.adjustmentColumns', [
            {label: 'Nome do Evento', fieldName: 'readjustmentType', type: 'text', sortable: true},
            {label: 'Data do Reajuste', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setOccurrenceColumns : function(component) {
		component.set('v.occurrenceColumns', [
            {label: 'Tipo / Descrição', fieldName: 'typeDescription', type: 'text', sortable: true},
            {label: 'Data / Hora Abertura', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setRequestFeeColumns : function(component) {
		component.set('v.feesColumns', [
            {label: 'Nome / Descrição', fieldName: 'requestTypeDescription', type: 'text', sortable: true}, 
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setPpvColumns : function(component) {
		component.set('v.ppvColumns', [
            {label: 'Produto', fieldName: 'typeSaleDescription', type: 'text', sortable: true}, 
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },
    
    setOutageColumns : function(component) {
		component.set('v.outageColumns', [
            {label: 'Natureza', fieldName: 'outageNature', type: 'text', sortable: true}, 
			{label: 'Data', fieldName: 'formattedDate', type: 'text', sortable: true}
		]);
    },

    setFilters : function(component) {
        component.set('v.periodFilters', [
            {'label': '6 Meses', 'value': '6'},
            {'label': '12 Meses', 'value': '12'},
            {'label': '24 Meses', 'value': '24'},
            {'label': 'Customizado', 'value': 'CustomFilter'}
        ]);  
    },

	onOpenHistoryEvents: function(component, event, helper, openAction) {
        var historyData = component.get('v.historyData');
        if((historyData == ''|| historyData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	return;
        
            component.set('v.isLoading', true);

            if(component.get('v.PeriodoCustomizado')==false){
            var action = component.get('c.getHistoryEventsByPeriod');
            action.setParams({
                contractId: component.get('v.contractId'),
                operatorId: component.get('v.operatorId'),
                extractItemStatus: 'ISSUED',
                period: component.get('v.period')
            });
            }else if(component.get('v.PeriodoCustomizado')==true){
                var action = component.get('c.getHistoryByDate');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'), 
                    extractItemStatus: 'ISSUED',
                    startDate: component.get('v.FilterStartDate'),
                    endDate: component.get('v.FilterEndDate')
                });
            }
            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.events.forEach(x => {
                            if(x.billDate){
                            let historyDate = x.billDate;
                            historyDate = historyDate.split("T")[0];
                            historyDate = historyDate.split("-"); 
                            x.formattedDate = historyDate[2]+'/'+historyDate[1]+'/'+historyDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
                        }
                            let correctValue = x.amountDue.toFixed(2);
                            if(x.extractItensDetails[0].productDescription == null)
                            	x.extractItensDetails[0].productDescription = '--';
                            if(x.installments == null)
                            	x.installments = '--';
                        });
                        component.set('v.historyData', data.events);
                        component.set('v.errorOnCallHistory', false);
                        this.setHistoryColumns(component);
                        this.openHistory(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallHistory', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallHistory', true);
                    }     
                }
                
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },

    callOccurrences: function(component, event, helper, openAction) {
        var occurrenceData = component.get('v.occurrenceData');
        if((occurrenceData == ''|| occurrenceData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	return;
        
            component.set('v.isLoading', true);

            if(component.get('v.PeriodoCustomizado')==false){
            var action = component.get('c.getOccurrencesByPeriod');
            action.setParams({
                contractId: component.get('v.contractId'),
                operatorId: component.get('v.operatorId'),
                period: component.get('v.period')
            });
            }else if(component.get('v.PeriodoCustomizado')==true){
                var action = component.get('c.getOccurrencesByDate');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'), 
                    startDate: component.get('v.FilterStartDate'),
                    endDate: component.get('v.FilterEndDate')
                });
            }
            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.occurrences.forEach(x => {
                            if(x.creationDate){
                            let occurrenceDate = x.creationDate;
                            let occurrenceTime = occurrenceDate.split("T")[1];
                            occurrenceTime = occurrenceTime.replace('Z','');
                            occurrenceDate = occurrenceDate.split("T")[0];
                            occurrenceDate = occurrenceDate.split("-"); 
                            x.formattedDate = occurrenceDate[2]+'/'+occurrenceDate[1]+'/'+occurrenceDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
                            x.formattedDate = occurrenceDate[2]+'/'+occurrenceDate[1]+'/'+occurrenceDate[0]+' - '+occurrenceTime;
                            }
                        });
                        component.set('v.occurrenceData', data.occurrences);
                        component.set('v.errorOnCallOccurrence', false);
                        this.setOccurrenceColumns(component);
                        this.openOccurrenceAcompanhamento(component);
                        this.openOccurrenceFinanceira(component);
                        this.openOccurrenceCancelamento(component);
                        this.openOccurrenceServico(component);
                        this.openOccurrenceSolic(component);
                        this.openOccurrenceOutros(component);  //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallOccurrence', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallOccurrence', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },

    callAdjustments: function(component, event, helper, openAction) {
        var adjustmentData = component.get('v.adjustmentData');
        if((adjustmentData == ''|| adjustmentData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	    return;
            component.set('v.isLoading', true);
            var action = component.get('c.getReadjustments');
            action.setParams({
                contractId: component.get('v.contractId'),
                operatorId: component.get('v.operatorId')
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.readjustments.forEach(x => {
                            if(x.readjustmentDate){
                            let readjustmentDate = x.readjustmentDate;
                            readjustmentDate = readjustmentDate.split("T")[0];
                            readjustmentDate = readjustmentDate.split("-"); 
                            x.formattedDate = readjustmentDate[2]+'/'+readjustmentDate[1]+'/'+readjustmentDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
                            }
                        });
                        component.set('v.adjustmentData', data.readjustments);
                        component.set('v.errorOnCallAdjustment', false);
                        this.setAdjustmentColumns(component);
                        this.openAdjustment(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallAdjustment', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallAdjustment', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },

    callNewProducts: function(component, event, helper, openAction) {
        var newProductsData = component.get('v.newProductsData');
        if((newProductsData == ''|| newProductsData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	    return;
            component.set('v.isLoading', true);
            
            if(component.get('v.PeriodoCustomizado')==false){
                var action = component.get('c.getNewProductsByPeriod');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'),
                    period: component.get('v.period')
                });
                }else if(component.get('v.PeriodoCustomizado')==true){
                    var action = component.get('c.getNewProductsByDate');
                    action.setParams({
                        contractId: component.get('v.contractId'),
                        operatorId: component.get('v.operatorId'), 
                        startDate: component.get('v.FilterStartDate'),
                        endDate: component.get('v.FilterEndDate')
                    });
                }

            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.newProducts.forEach(x => {
                            if(x.effectiveDate){
                            let effectiveDate = x.effectiveDate;
                            effectiveDate = effectiveDate.split("T")[0];
                            effectiveDate = effectiveDate.split("-"); 
                            x.formattedDate = effectiveDate[2]+'/'+effectiveDate[1]+'/'+effectiveDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);             
                            }
                        });
                        component.set('v.newProductsData', data.newProducts);
                        component.set('v.errorOnCallNewProducts', false);
                        this.setNewProductColumns(component);
                        this.openNewProducts(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallNewProducts', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallNewProducts', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },
    
    callRequestFees: function(component, event, helper, openAction) {
        var requestFeesData = component.get('v.feesData');
        if((requestFeesData == ''|| requestFeesData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	    return;
            component.set('v.isLoading', true);
            
            if(component.get('v.PeriodoCustomizado')==false){
                var action = component.get('c.getRequestFeesByPeriod');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'),
                    period: component.get('v.period')
                });
                }else if(component.get('v.PeriodoCustomizado')==true){
                    var action = component.get('c.getRequestFeesByDate');
                    action.setParams({
                        contractId: component.get('v.contractId'),
                        operatorId: component.get('v.operatorId'), 
                        startDate: component.get('v.FilterStartDate'),
                        endDate: component.get('v.FilterEndDate')
                    });
                }

            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.requestFees.forEach(x => {
                            if(x.releaseDate){
                            let releaseDate = x.releaseDate;
                            releaseDate = releaseDate.split("T")[0];
                            releaseDate = releaseDate.split("-"); 
                            x.formattedDate = releaseDate[2]+'/'+releaseDate[1]+'/'+releaseDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);              
                            }
                        });
                        component.set('v.feesData', data.requestFees);
                        component.set('v.errorOnCallFees', false);
                        this.setRequestFeeColumns(component);
                        this.openRequestFees(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallFees', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallFees', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },

    callPpvs: function(component, event, helper, openAction) {
        var ppvData = component.get('v.ppvData');
        if((ppvData == ''|| ppvData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	    return;
            component.set('v.isLoading', true);
            
            if(component.get('v.PeriodoCustomizado')==false){
                var action = component.get('c.getPpvByPeriod');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'),
                    period: component.get('v.period')
                });
                }else if(component.get('v.PeriodoCustomizado')==true){
                    var action = component.get('c.getPpvByDate');
                    action.setParams({
                        contractId: component.get('v.contractId'),
                        operatorId: component.get('v.operatorId'), 
                        startDate: component.get('v.FilterStartDate'),
                        endDate: component.get('v.FilterEndDate')
                    });
                }

            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.ppvs.forEach(x => {
                            if(x.saleDate){
                            let saleDate = x.saleDate;
                            saleDate = saleDate.split("T")[0];
                            saleDate = saleDate.split("-"); 
                            x.formattedDate = saleDate[2]+'/'+saleDate[1]+'/'+saleDate[0];
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);            
                            }
                        });
                        component.set('v.ppvData', data.ppvs);
                        component.set('v.errorOnCallPpv', false);
                        this.setPpvColumns(component);
                        this.openPpvs(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallPpv', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallPpv', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },

    callOutage: function(component, event, helper, openAction) {
        var outageData = component.get('v.outageData');
        if((outageData == ''|| outageData == undefined)&& openAction){
            if(!component.get('v.contractId') || !component.get('v.operatorId'))
        	    return;
            component.set('v.isLoading', true);
            
            if(component.get('v.PeriodoCustomizado')==false){
                var action = component.get('c.getOutageByPeriod');
                action.setParams({
                    contractId: component.get('v.contractId'),
                    operatorId: component.get('v.operatorId'),
                    period: component.get('v.period')
                });
                }else if(component.get('v.PeriodoCustomizado')==true){
                    var action = component.get('c.getOutageByDate');
                    action.setParams({
                        contractId: component.get('v.contractId'),
                        operatorId: component.get('v.operatorId'), 
                        startDate: component.get('v.FilterStartDate'),
                        endDate: component.get('v.FilterEndDate')
                    });
                }

            action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                if(state === 'SUCCESS'){
                    if(data.success){
                        data.outage.forEach(x => {
                        if(x.products[0].startDate){
                            let startDate = x.products[0].startDate;
                            startDate = startDate.split("/"); 
                            x.formattedDate = startDate[0]+'/'+startDate[1]+'/'+startDate[2];
                            x.products[0].startDate = x.formattedDate;
                            
      						let realDate = x.formattedDate.split("/");					
                            x.realDate = new Date(realDate[2], realDate[1], realDate[0]);    
                        }
                        if(x.products[0].previsionDate != null){
                            let formattedPrevisionDate = x.products[0].previsionDate.split("/");
                            formattedPrevisionDate = formattedPrevisionDate[0]+'/'+formattedPrevisionDate[1]+'/'+formattedPrevisionDate[2];
                            x.products[0].previsionDate = formattedPrevisionDate;
                        }
                        if(x.products[0].endDate != null){
                            let formattedEndDate = x.products[0].endDate.split("/");
                            formattedEndDate = formattedEndDate[0]+'/'+formattedEndDate[1]+'/'+formattedEndDate[2];
                            x.products[0].endDate = formattedEndDate;
                        }
                        x.outageNature = x.products[0].nature; 
                        });
                        component.set('v.outageData', data.outage);
                        component.set('v.errorOnCallOutage', false);
                        this.setOutageColumns(component);
                        this.openOutage(component);
                    }else{
                        this.showToast('Erro', data.message, 'error');
                        component.set('v.errorOnCallOutage', true);
                        console.log('Erro', data.message);
                    }   
                    
                }else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        this.showToast('Erro', errors[0].message, 'error');
                        console.log('Erro', errors[0].message);
                        component.set('v.errorOnCallOutage', true);
                    }     
                }
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        }

    },
})