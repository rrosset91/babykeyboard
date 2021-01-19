({
	doInit: function(component, event, helper) {
		helper.initialLoad(component);
	},
    
    handleSelectedEvent : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedEvent', {});
        }else{
            component.set('v.selectedEvent',selectedRows[0]);
			helper.findEventDetails(component, selectedRows[0]);
        }
	},
    
    handleSelectedHistory : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedHistory', {});
        }else{
            component.set('v.selectedHistory',selectedRows[0]);
            
			helper.findHistoryDetails(component, selectedRows[0]);
        }
    },
    
    handleSelectedNewProduct : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedNewProduct', {});
        }else{
            component.set('v.selectedNewProduct',selectedRows[0]);
			helper.findNewProductDetails(component, selectedRows[0]);
        }
    },
        
    handleSelectedAdjustment : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedAdjustment', {});
        }else{
            component.set('v.selectedAdjustment',selectedRows[0]);
			helper.findAdjustmentDetails(component, selectedRows[0]);
        }
    },

    handleSelectedOccurrence : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedOccurrence', {});
        }else{
            component.set('v.selectedOccurrence',selectedRows[0]);
			helper.findOccurrenceDetails(component, selectedRows[0]);
        }
    },

    handleSelectedRequestFee : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedRequestFee', {});
        }else{
            component.set('v.selectedRequestFee',selectedRows[0]);
			helper.findRequestFeeDetails(component, selectedRows[0]);
        }
    },

    handleSelectedPpv : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedPpv', {});
        }else{
            component.set('v.selectedPpv',selectedRows[0]);
			helper.findPpvDetails(component, selectedRows[0]);
        }
    },

    handleSelectedOutage : function(component, event, helper) {
		const selectedRows = event.getParam('selectedRows');
        if(!selectedRows){
            return component.set('v.selectedOutage', {});
        }else{
            component.set('v.selectedOutage',selectedRows[0]);
			helper.findOutageDetails(component, selectedRows[0]);
        }
    },
    
    handlePeriodFilter: function(component, event, helper){
        let selectedFilter = component.get('v.period');
        if (selectedFilter != 'CustomFilter')
            component.set('v.PeriodoCustomizado',false);
        component.set('v.historyData',[]);
        component.set('v.dataSolic',[]);
        component.set('v.cancelData',[]);
        component.set('v.comprasData',[]);
        component.set('v.eventsData',[]);
        component.set('v.occurrenceDataAcompanhamento',[]);
        component.set('v.occurrenceDataFinanceira',[]);
        component.set('v.occurrenceDataCancelamento',[]);
        component.set('v.occurrenceDataServico',[]);
        component.set('v.occurrenceDataSolic',[]); 
        component.set('v.occurrenceDataOutros',[]);  //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
        component.set('v.occurrenceData',[]);
        component.set('v.newProductsData',[]);
        component.set('v.feesData',[]);
        component.set('v.ppvData',[]);
        component.set('v.outageData',[]);

        var sectionDiv1 = component.find('cancelamentosContainer').getElement();
        sectionDiv1.setAttribute('class' , 'slds-section slds-is-close');
        
        var sectionDiv2 = component.find('comprasContainer').getElement();
        sectionDiv2.setAttribute('class' , 'slds-section slds-is-close');
        
        var sectionDiv3 = component.find('eventsContainer').getElement();
        sectionDiv3.setAttribute('class' , 'slds-section slds-is-close');
        
        var sectionDiv4 = component.find('historyContainer').getElement();
        sectionDiv4.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv5 = component.find('newProductsContainer').getElement();
        sectionDiv5.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv6 = component.find('adjustmentsContainer').getElement();
        sectionDiv6.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv7 = component.find('occurrencesContainerAcompanhamento').getElement();
        sectionDiv7.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv8 = component.find('requestFeesContainer').getElement();
        sectionDiv8.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv9 = component.find('ppvContainer').getElement();
        sectionDiv9.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv10 = component.find('occurrencesContainerFinanceira').getElement();
        sectionDiv10.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv11 = component.find('occurrencesContainerCancelamento').getElement();
        sectionDiv11.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv12 = component.find('occurrencesContainerServico').getElement();
        sectionDiv12.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv13 = component.find('occurrencesContainerSolic').getElement();
        sectionDiv13.setAttribute('class' , 'slds-section slds-is-close');

        var sectionDiv14 = component.find('outageContainer').getElement();
        sectionDiv14.setAttribute('class' , 'slds-section slds-is-close');
         //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
        var sectionDiv15 = component.find('occurrencesContainerOutros').getElement();
        sectionDiv15.setAttribute('class' , 'slds-section slds-is-close');
    },
    onClickFiltrarPeriodo : function(component, event, helper){
          if(component.get('v.contractId') && component.get('v.operatorId')){
                if(component.get('v.FilterEndDate') != '' && component.get('v.FilterStartDate') != '')
                component.set('v.PeriodoCustomizado', true);
                var handle = component.get('c.handlePeriodFilter');
                $A.enqueueAction(handle);
               var toastEvent = $A.get("e.force:showToast");
        
          toastEvent.setParams({
            title : 'Filtros aplicados',
            message: $A.get("$Label.c.Fin_filter_success"),
            duration:' 6000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    };
    },

	closeModal: function(component, event, helper){
		component.find('detailModalEvent').close();
		component.set('v.selectedRows', []);
	},

	onCloseModal: function(component, event, helper){
		component.find('eventsTable').set('v.selectedRows', []);
        component.find('comprasTable').set('v.selectedRows', []);
        component.find('eventsTable').set('v.selectedRows', []);
	},
    
    closeHistoryModal: function(component, event, helper){
		component.find('detailModalHistory').close();
		component.find('historyEventsTable').set('v.selectedRows', []);
    },
    
    closeNewProductModal: function(component, event, helper){
		component.find('newProductModal').close();
		component.find('newProductsTable').set('v.selectedRows', []);
    },
    
    closeAdjustmentModal: function(component, event, helper){
		component.find('adjustmentModal').close();
		component.find('adjustmentTable').set('v.selectedRows', []);
    },
    
    closeOccurrenceModal: function(component, event, helper){
        component.find('occurrenceModal').close();
    },
    
    closeRequestFeeModal: function(component, event, helper){
		component.find('requestFeeModal').close();
		component.find('requestFeesTable').set('v.selectedRows', []);
    },
    
    closePpvModal: function(component, event, helper){
		component.find('ppvModal').close();
		component.find('ppvEventsTable').set('v.selectedRows', []);
    },
    
    closeOutageModal: function(component, event, helper){
		component.find('outageModal').close();
		component.find('outageTable').set('v.selectedRows', []);
	},

	onCloseOccurrenceModal: function(component, event, helper){
        helper.onCloseOccurrenceModal(component,event,helper);
    },

    onCloseNewProductModal: function(component, event, helper){
		component.find('newProductsTable').set('v.selectedRows', []);
    },
    
    onCloseAdjustmentModal: function(component, event, helper){
		component.find('adjustmentTable').set('v.selectedRows', []);
    },
    
    onCloseRequestFeeModal: function(component, event, helper){
		component.find('requestFeesTable').set('v.selectedRows', []);
    },
    
    onClosePpvModal: function(component, event, helper){
		component.find('ppvEventsTable').set('v.selectedRows', []);
    },

    onCloseOutageModal: function(component, event, helper){
		component.find('outageTable').set('v.selectedRows', []);
    },
    onCloseHistoryModal: function(component, event, helper){
		component.find('historyEventsTable').set('v.selectedRows', []);
	},
    
    onSortDetails : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByDetails",fieldName);
        component.set("v.sortedDirectionDetails",sortDirection);
        
        let allDetails = component.get('v.selectedEvent.configurations');
        
        if(!allDetails)
            return;
        
        component.set('v.selectedEvent.configurations', helper.sortData(fieldName,sortDirection,allDetails));
    },
    
    onSortHistory : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByHistory",fieldName);
        component.set("v.sortedDirectionHistory",sortDirection);
        
        let allHistory = component.get('v.historyData');
        
        if(!allHistory)
            return;
        
        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        component.set('v.historyData', helper.sortData(fieldName,sortDirection,allHistory));
    },
    
    onSortNewProducts : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByNewProducts",fieldName);
        component.set("v.sortedDirectionNewProducts",sortDirection);
        
        let allNewProducts = component.get('v.newProductsData');
        
        if(!allNewProducts)
            return;
        
        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        component.set('v.newProductsData', helper.sortData(fieldName,sortDirection,allNewProducts));
    },

    onSortAdjustments : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByAdjustment",fieldName);
        component.set("v.sortedDirectionAdjustment",sortDirection);
        
        let allAdjustment = component.get('v.adjustmentData');
        
        if(!allAdjustment)
            return;
        
        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        if(fieldName == 'formattedAmount')
            fieldName = 'realValue';
            
        if(fieldName == 'percentAdjusted')
            fieldName = 'percentValue';
            
        component.set('v.adjustmentData', helper.sortData(fieldName,sortDirection,allAdjustment));
    },

    onSortOccurrencesAcompanhamento : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceAcompanhamento",fieldName);
        component.set("v.sortedDirectionOccurrenceAcompanhamento",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataAcompanhamento');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataAcompanhamento', helper.sortData(fieldName,sortDirection,allOccurrence));
    },
    onSortOccurrencesFinanceira : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceFinanceira",fieldName);
        component.set("v.sortedDirectionOccurrenceFinanceira",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataFinanceira');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataFinanceira', helper.sortData(fieldName,sortDirection,allOccurrence));
    },
    onSortOccurrencesCancelamento : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceCancelamento",fieldName);
        component.set("v.sortedDirectionOccurrenceCancelamento",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataCancelamento');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataCancelamento', helper.sortData(fieldName,sortDirection,allOccurrence));
    },
    onSortOccurrencesServico : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceServico",fieldName);
        component.set("v.sortedDirectionOccurrenceServico",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataServico');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataServico', helper.sortData(fieldName,sortDirection,allOccurrence));
    },

    onSortOccurrencesSolic : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceSolic",fieldName);
        component.set("v.sortedDirectionOccurrenceSolic",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataSolic');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataSolic', helper.sortData(fieldName,sortDirection,allOccurrence));
    },

     //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
    onSortOccurrencesOutros : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOccurrenceOutros",fieldName);
        component.set("v.sortedDirectionOccurrenceOutros",sortDirection);
        
        let allOccurrence = component.get('v.occurrenceDataOutros');
        
        if(!allOccurrence)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.occurrenceDataOutros', helper.sortData(fieldName,sortDirection,allOccurrence));
    },
    
    onSortRequestFees : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByFee",fieldName);
        component.set("v.sortedDirectionFee",sortDirection);
        
        let allRequestFees = component.get('v.feesData');
        
        if(!allRequestFees)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';

        if(fieldName == 'formattedAmount')
            fieldName = 'amount';
        
        component.set('v.feesData', helper.sortData(fieldName,sortDirection,allRequestFees));
    },

    onSortPpvs : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByPpv",fieldName);
        component.set("v.sortedDirectionPpv",sortDirection);
        
        let allPpv = component.get('v.ppvData');
        
        if(!allPpv)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';

        if(fieldName == 'formattedPrice')
            fieldName = 'price';
        
        component.set('v.ppvData', helper.sortData(fieldName,sortDirection,allPpv));
    },

    onSortOutage : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByOutage",fieldName);
        component.set("v.sortedDirectionOutage",sortDirection);
        
        let allOutage = component.get('v.outageData');
        
        if(!allOutage)
            return;
        
        if(fieldName == 'formattedDate')
            fieldName = 'realDate';
        
        component.set('v.outageData', helper.sortData(fieldName,sortDirection,allOutage));
    },

    
    
    onSortEvents : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByEvents",fieldName);
        component.set("v.sortedDirectionEvents",sortDirection);
        
        let allEvents = component.get('v.eventsData');
        
        if(!allEvents)
            return;
        
        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        component.set('v.eventsData', helper.sortData(fieldName,sortDirection,allEvents));
    },
    onSortCompras : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByCompras",fieldName);
        component.set("v.sortedDirectionCompras",sortDirection);
        
        let allCompras = component.get('v.comprasData');
        
        if(!allCompras)
            return;
        
        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        component.set('v.comprasData', helper.sortData(fieldName,sortDirection,allCompras));
    },
    onSortCancelamento : function(component,event,helper){
        let fieldName = event.getParam("fieldName");
        const sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortedByCancelamento",fieldName);
        component.set("v.sortedDirectionCancelamento",sortDirection);
        
        let allCancelamentos = component.get('v.cancelData');
        
        if(!allCancelamentos)
            return;

        if(fieldName == 'formattedDate')
			fieldName = 'realDate';
        
        component.set('v.cancelData', helper.sortData(fieldName,sortDirection,allCancelamentos));
    },
    
	toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
		var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
		var openAction = false;
        var dateFilter = component.get('v.SelectedPeriodFilter');
        if(sectionState == -1){
			sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
			openAction = true;
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
            component.set('v.openedSection',false);
		}
		
		switch (sectionAuraId) {
			case 'cancelamentosContainer':
			helper.callSolicEvents(component, event, helper, openAction);
			break;
			
			case 'comprasContainer':
			helper.callSolicEvents(component, event, helper, openAction);
			break;

			case 'eventsContainer':
			helper.callSolicEvents(component, event, helper, openAction);
			break;

			case 'historyContainer':
			helper.onOpenHistoryEvents(component, event, helper, openAction);
            break;
            
            case 'occurrencesContainerAcompanhamento':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;
                        
            case 'occurrencesContainerFinanceira':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;
                        
            case 'occurrencesContainerCancelamento':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;
                        
            case 'occurrencesContainerServico':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;

            case 'occurrencesContainerSolic':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;
            //Melhoria: Novo agrupamento para ocorrências não categorizadas - 23-09-2020 - Roger Rosset
            case 'occurrencesContainerOutros':
            component.set('v.openedSection',true);
            helper.callOccurrences(component, event, helper, openAction);
            break;

            case 'newProductsContainer':
            helper.callNewProducts(component, event, helper, openAction);
            break;

            case 'adjustmentsContainer':
            helper.callAdjustments(component, event, helper, openAction);
            break;

            case 'requestFeesContainer':
            helper.callRequestFees(component, event, helper, openAction);
            break;

            case 'ppvContainer':
            helper.callPpvs(component, event, helper, openAction);
            break;

            case 'outageContainer':
            helper.callOutage(component, event, helper, openAction);
            break;
                
            
            default:
			  	console.log('sectionAuraId', sectionAuraId);
		}
    },
})