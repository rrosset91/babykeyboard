({
	initialLoad : function(component) {
        this.setColumns(component);        
	},
	setColumns : function(component){
		const columns = [
		{label: 'Item', fieldName: 'itemName', type: 'text', sortable: true},
		{label: 'Data de Lançamento', fieldName: 'formattedDate', type: 'text', sortable: true},
		{label: 'Valor', fieldName: 'amountDue', type: 'text', sortable: true}];

		component.set('v.columns', columns);
    },
    getcontractandOppId :function(component){
        console.log('entrou no getContractId');
        let action = component.get("c.getContractId");
        let recordId = component.get("v.recordId");
        action.setParams({
            strId : recordId
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            let conId = response.getReturnValue();
            if(state === "SUCCESS"){
                console.log('conId: ' + conId);
                if(conId !== 'undefined' && conId != ''){
                    component.set("v.contractId",conId);
                    this.callFutureInvoices(component);
                }else{
                    component.set("v.hasError",true);
                }
            }else{
                component.set("v.hasError",true);
            }
        });
        $A.enqueueAction(action);
    },
 	callFutureInvoices : function(component) {

        component.set('v.isLoading', true);

        let action = component.get('c.getHistoryByPeriod');
        action.setParams({
            contractId: component.get('v.contractId'),
            extractItemStatus: 'FUTURE_RELEASE',
            period: 6
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var data = response.getReturnValue();
            var futureReleases = [];
            var cont = 0;
            console.log('Data' + data);
                
            if(state === 'SUCCESS'){
                if(data.success){
                    console.log('dataaa: ' ,data.events[0])
                    data.events.sort(function(a,b){
                        if (a.paymentDueDate > b.paymentDueDate) {
                            return 1;
                          }
                          if (a.paymentDueDate < b.paymentDueDate) {
                            return -1;
                          }
                    });
                    data.events.forEach(x => {
                    const item = x.extractItensDetails[0].detTypeExtractItemNote;
                    x.itemName = item;
                    x.title = item;
                            
                    const historyDate = x.paymentDueDate;	
                    x.formattedDate = $A.localizationService.formatDate(historyDate, "dd/MM/yyyy");
      	    		let realDate = x.formattedDate.split("/");					
                    x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
                           
                    const historyBillDate = x.billDate;
                    x.formattedBillDate = $A.localizationService.formatDate(historyBillDate, "MMMM");
      				let realBillDate = x.formattedBillDate.split("/");					
                    x.realBillDate = new Date(realBillDate[2], realBillDate[1], realBillDate[0]);

                        let correctValue = x.amountDue.toFixed(2);
                        x.amountDue = 'R$'+correctValue;
                           
                        if(x.extractItensDetails[0].productDescription == null)
                            x.extractItensDetails[0].productDescription = '--';
                            
                        if(x.extractItensDetails[0].installmentNumber == null)
                            x.extractItensDetails[0].installmentNumber = '--';
                            
                        if(x.extractItensDetails[0].installmentsCount == null)
                            x.extractItensDetails[0].installmentsCount = '--';
                            
                        if(x.installments == null)
                            x.installments = '--';

                        if(cont < 5){
                            futureReleases.push(x);
                            cont++;
                        }
                                
                    });
                    component.set('v.futureReleases', futureReleases);
                    if(data.events.length > 5){
                        component.set("v.hasMoreRecords",true);
                    }
                    this.setColumns(component);
                }else{
                    component.set("v.hasRecords",false);
                }   
            }else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors[0] && errors[0].message){
                    console.log('Erro', errors[0].message);
                    component.set("v.hasError",true);
                }     
            }
                
                component.set('v.isLoading', false);
            });
            $A.enqueueAction(action);
        },
	sortData : function(fieldName, direction, list){
		const reverse = direction != 'asc';

		if(!list)
			return list;

		list.sort((x, y) => {
            if (!x[fieldName] && y[fieldName])
                return reverse ? 1 : -1;

            if (x[fieldName] && !y[fieldName])
                return reverse ? -1 : 1;

            if (x[fieldName] > y[fieldName])
                return reverse ? -1 : 1;

            if (x[fieldName] == y[fieldName])
                return 0;

            if (x[fieldName] < y[fieldName])
                return reverse ? 1 : -1;
        });

		return list;
    }

})