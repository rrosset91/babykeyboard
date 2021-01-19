({
	initialLoad : function(component) {
        this.setColumns(component);        
	},
	setColumns : function(component){
		const columns = [
		{label: 'ITEM', fieldName: 'itemName', type: 'text', sortable: true},
		{label: 'DATA DE LANÇAMENTO', fieldName: 'formattedDate', type: 'text', sortable: true},
		{label: 'VALOR', fieldName: 'amountDue', type: 'text', sortable: true}];
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
                if(conId !== 'undefined'){
                    component.set("v.objCase",conId);
                    console.log('mobile: ',conId);
                    let mobileLabel = $A.get("$Label.c.Solar_Cross_MobileContract").split(';');
                    console.log('mobileLabel: ',mobileLabel)
                    let residentialLabel = $A.get("$Label.c.Solar_Cross_ResidentialContract").split(';');
                    if(mobileLabel.includes(conId.ContractBillingAccount__r.BusinessUnit__c)){
                        component.set('v.isMobile',true);
                        console.log('é mobile')
                    }else if(residentialLabel.includes(conId.ContractBillingAccount__r.BusinessUnit__c)){
                        component.set('v.isMobile',false);
                        console.log('não é mobile')
                    }
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
        console.log('Entrou aqui');
        let mobile = component.get('v.isMobile');
        console.log('mobile',mobile);
        let action = component.get('c.callCorrectIntegration');
        action.setParams({
            objCase : component.get('v.objCase'),
            isMobile : component.get('v.isMobile')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var data = response.getReturnValue();
            var futureReleases = [];
            var hundredFuture =[];
            var cont = 0;
            let totalperPage = $A.get("$Label.c.Solar_Cross_LimitPerPage");


            console.log('Data' + data);
            if(state === 'SUCCESS'){
                if(data.success){
                  //  console.log('dataaa: ' ,data.events[0])
                    data.events.sort(function(a,b){
                        if (a.paymentDueDate > b.paymentDueDate) {
                            return 1;
                          }
                          if (a.paymentDueDate < b.paymentDueDate) {
                            return -1;
                          }
                    });
                    data.events.forEach((x,index) => {
                    let item;
                    if(!mobile){
                        console.log('Entrou aqui.')
                        item = x.extractItensDetails[0].detTypeExtractItemNote;
                        if(x.extractItensDetails[0].productDescription == null)
                            x.extractItensDetails[0].productDescription = '--';
                        if(x.extractItensDetails[0].installmentNumber == null)
                            x.extractItensDetails[0].installmentNumber = '--';
                        if(x.extractItensDetails[0].installmentsCount == null)
                            x.extractItensDetails[0].installmentsCount = '--';
                        if(x.installments == null)
                            x.installments = '--';
                    }else{
                        console.log('Entrou ali');
                        item = x.description;
                    }
                    x.itemName = item;
                    x.title = item;
                    x.index = index;      
                    const historyDate = x.paymentDueDate;	
                    console.log('Entrou pós history',historyDate);
                    x.formattedDate = $A.localizationService.formatDate(historyDate, "dd/MM/yyyy");
      	    		let realDate = x.formattedDate.split("/");					
                    x.realDate = new Date(realDate[2], realDate[1], realDate[0]);
                    const historyBillDate = x.billDate;
                    console.log('historyBillDate',historyBillDate);
                    x.formattedBillDate = $A.localizationService.formatDate(historyBillDate, "dd/MM/yyyy");
                    console.log('formattedBillDate', x.formattedBillDate);
                    let realBillDate = x.formattedBillDate.split("/");		
                    console.log('realBillDate', realBillDate);			
                    x.realBillDate = new Date(realBillDate[2], realBillDate[1], realBillDate[0]);
                    console.log('depois do realBillDate');
                    let correctValue = x.amountDue.toFixed(2);
                    x.amountDue = 'R$'+correctValue;
                        if(cont < 5){
                            futureReleases.push(x);
                        }

                        if(cont < 200){
                            hundredFuture.push(x);

                            cont++;
                        }
                    });
                    component.set('v.allFutureReleases',data.events);
                    component.set('v.futureReleases', futureReleases);
                    component.set('v.hundredFutureReleases', hundredFuture);
                    component.set('v.totalPages', (Math.ceil(data.events.length/totalperPage)));
                    component.set("v.pageNumber",1);
            		component.set("v.pageSize",totalperPage);
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
    },
    onNext : function(component,event,value){
        console.log('Entrou onNext ::');
        let allReleases = component.get('v.allFutureReleases');
        console.log('Entrou onNext ::');
        let pageSize = component.get('v.pageSize');
        let pageNumber = component.get('v.pageNumber');
        component.set('v.pageNumber',pageNumber+1);
        pageNumber = component.get('v.pageNumber');
        console.log('Entrou onNext ::', pageNumber, pageSize);
        let nextElements = allReleases.slice((pageNumber - 1) * pageSize, (pageSize * pageNumber));
        console.log('nextElements',nextElements);

        component.set('v.futureReleases', nextElements);

    },
    onPrevious : function(component,event,value){
        let allReleases = component.get('v.allFutureReleases');
        let pageSize = component.get('v.pageSize');
        let pageNumber = component.get('v.pageNumber');
        component.set('v.pageNumber',pageNumber-1);
        pageNumber = component.get('v.pageNumber');
        console.log('Entrou onPrevous ::', pageNumber , pageSize);
        console.log('Entrou no pre: ',(pageNumber - 2))
        let previousElements = allReleases.slice((pageNumber - 1) * pageSize, (pageSize * (pageNumber)));
        console.log('previousElements',previousElements);

        component.set('v.futureReleases', previousElements);

    }
})