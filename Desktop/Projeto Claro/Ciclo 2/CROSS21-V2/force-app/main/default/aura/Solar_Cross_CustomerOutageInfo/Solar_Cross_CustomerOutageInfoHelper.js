({
    initialLoad : function(component) {
        console.log('Entrou no initial load')
        this.setColumns(component);        
	},
	setColumns : function(component){
        console.log('setColumns');
		const columns = [
		{label: 'STATUS',cellAttributes : {iconName: { fieldName: 'iconUsed' }, iconPosition: 'left',class: { fieldName: 'variantIcon' }},initialWidth: 75,hideDefaultActions: true},
        {label: 'OUTAGE', fieldName: 'OutageNumber'},
        {label: 'INICIO', fieldName: 'StartDate', type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true, sortable: true},
        {label: 'FIM', fieldName: 'EndDate', type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true, sortable: true},
        {label: 'PREVISÂO', fieldName: 'PrevisionDate', type: 'date-local',typeAttributes: {year:"numeric", month:"2-digit", day:"2-digit"},hideDefaultActions: true, sortable: true},
        {label: 'TIPO DE PRODUTO ', fieldName: 'productType', type:'text',hideDefaultActions: true, sortable: true},
        {label: 'SERVIÇO AFETADO', fieldName: 'affectedServices', type:'text', hideDefaultActions: true, sortable:true},
        {label: 'SINTOMA', fieldName: 'symptom',type: 'text', hideDefaultActions: true},
        {label: 'OBSERVAÇÂO', fieldName: 'coverage'},
        {label: 'NATUREZA', fieldName: 'nature', type:'text', hideDefaultActions: true, sortable: true}];
        component.set('v.columns', columns);
    },
    filterOutages: function(component,event,helper){
        let minDat = component.find("startDate");
        let formattedStartDat = $A.localizationService.formatDate(minDat.get('v.value'),"dd/MM/yyyy");
        let maxDat = component.find("endDate");
        let formattedEndDat = $A.localizationService.formatDate(maxDat.get('v.value'),"dd/MM/yyyy");
        component.set('v.hasError',false);
        let hasError = false;
        maxDat.setCustomValidity("");
        maxDat.setCustomValidity("");

        if(!minDat.get("v.value")){
            minDat.setCustomValidity("Necessário preencher uma data mínima");
            hasError = true;
        }else{
            minDat.setCustomValidity("");
        }
        if(!maxDat.get("v.value")){
            maxDat.setCustomValidity("Necessário preencher uma data máxima");            
            hasError = true;
        }else if(!maxDat.checkValidity()){
            console.log('Entrou aqui e não devia')
            hasError = true;
        }else{
            minDat.setCustomValidity("");
        }
        if(!hasError){
            console.log('error false')
            component.set('v.showSpinner',true);
            console.log('teste: ', component.get('v.showSpinner'));
            let action = component.get("c.getOutages");

            action.setParams({
                "recordId":component.get('v.recordId'),
                "strStartDate":formattedStartDat,
                "strEndDate":formattedEndDat
            })
    
            action.setCallback(this,function(response){
                let state = response.getState();
                let data = response.getReturnValue();
                console.log('data',data);
                console.log('state: ',state);
                if(state ==="SUCCESS"){
                    if(data.success){
                        if(data.outages !== undefined){
                            console.log('data.outages: ', data.outages)
                            component.set('v.allOutages',data.outages);
                        }else{
                            component.set('v.hasError',true);
                            component.set('v.messageError',data.message);
                        } 
                    }else{
                        component.set('v.hasError',true);
                        component.set('v.messageError',data.message);
                    }
                }else{
                }

                component.set('v.showSpinner',false);
            });
            $A.enqueueAction(action);
        }else{
            minDat.reportValidity('');
            maxDat.reportValidity('');
        }
        //component.set('v.showSpinner',false);

    },
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        console.log('Entrou no handleSort')
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var data = cmp.get('v.allOutages');
        var cloneData = data.slice(0);
        console.log('passou do slice',cloneData);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.allOutages', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    }
})