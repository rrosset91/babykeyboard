({
    initialLoad : function(component) {
        // @note  83484 - Dados "Itens Títulos Não Emitidos"
        this.setColumns(component);
        this.setFilters(component);
        this.callBillDebts(component);
    },
    
    callBillDebts : function(component) {
        // @note callFutureInvoices
		component.set('v.isLoading', true);

        console.log('callFutureInvoices');

        let action = component.get('c.getBillDebts');
        action.setParams({
            contractId: component.get('v.contractId'),
            operatorId: component.get('v.operatorId'), 
            startDate: component.get('v.FilterStartDate'),
            endDate: component.get('v.FilterEndDate')
        }); 
        action.setCallback(this, function(response){
            var state = response.getState(); 
            var data = response.getReturnValue();          
            console.log(state, data);
            
            if(state === 'SUCCESS'){
                if(data.responseCode < 400){
                    component.set('v.wrapper', data);
                }else{
                    this.showToast('Erro', data.errorMessage, 'error');
                }
            }else if(state === 'ERROR'){   
                this.showToast('Erro', data.errorMessage, 'error');
                component.set('v.errorOnCall', true);  
            }
            
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
        
        
        // component.set('v.invoices', productsArr);
        component.set('v.isLoading', false);
    },
    
    setColumns : function(component) {
        const columns = [
            {label: 'Tipo', fieldName: 'itemDescription', type: 'text', sortable: true},
            {label: 'Data do Lançamento', fieldName: 'entryDate', type: 'text', sortable: true},
            {label: 'Valor', fieldName: 'amount', type: 'text', sortable: true},
            {label: '', type: 'button', initialWidth: 180, typeAttributes: { 
                label: $A.get('$Label.c.Fin_TitulosNaoEmitidos_MaisInformacoes'), 
                name: 'view_details', 
                title: 'Click to View Details',
                iconName: 'utility:preview'
            }}
        ];
        
        component.set('v.columns', columns);
    },
    showRowDetails : function(component, event, helper, row) {
        console.log('row', row);
        component.set('v.wrapperDetail',row);
        component.find('detailModal').open();
    },
    
    setFilters : function(component) {
        component.set('v.periodFilters', [
            {'label': '6 Meses', 'value': '6'},
            {'label': '12 Meses', 'value': '12'},
            {'label': '24 Meses', 'value': '24'},
        ]);
            
        component.set('v.typeFilters', [
            {'label': 'Visualizar Todos', 'value': 'all'},
        ]);
        
    },

    sortData : function(component,fieldName,sortDirection, groups){
        for (let i = 0; i < groups.length; i++) {
            const data = groups[i].debts;
             //function to return the value stored in the field
            var key = function(a) { return a[fieldName]; }
            var reverse = sortDirection == 'asc' ? 1: -1;
            
            // to handel number/currency type fields 
            if(fieldName == 'amount'){ 
                data.sort(function(a,b){
                    var a = key(a) ? key(a) : '';
                    var b = key(b) ? key(b) : '';
                    return reverse * ((a>b) - (b>a));
                }); 
            }
            //to handle dates 
            if(fieldName == 'entryDate'){ 
                data.sort(function(a,b){
                    return reverse * (new Date(b.sortentryDate) - new Date(a.sortentryDate));
                });
            }
            if(fieldName == 'itemDescription'){// to handel text type fields 
                data.sort(function(a,b){ 
                    var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                    var b = key(b) ? key(b).toLowerCase() : '';
                    return reverse * ((a>b) - (b>a));
                });    
            }
        }
       
        //set sorted data to  attribute
        component.set("v.wrapper.groupDebts", groups);
    }
})