({
    setDates: function(component, event, helper) 
    {
        var todaySubtract = new Date();
        component.set("v.endDate", $A.localizationService.formatDate(todaySubtract, "YYYY-MM-DD"));        
        
        todaySubtract.setDate(todaySubtract.getDate() - 60);
        todaySubtract = $A.localizationService.formatDate(todaySubtract, "YYYY-MM-DD");
        component.set("v.startDate", todaySubtract);
        
        var todayYear = new Date();
        todayYear.setYear(todayYear.getFullYear() - 5);
        todayYear = $A.localizationService.formatDate(todayYear, "YYYY-MM-DD");
        component.set("v.minDate", todayYear);
        
        var todaySum = new Date();
        todaySum.setDate(todaySum.getDate() + 30);
        todaySum = $A.localizationService.formatDate(todaySum, "YYYY-MM-DD");
        component.set("v.maxDate", todaySum);
    },
    
    setProtocolType: function(component, event, helper) 
    {
        var action = component.get("c.getContracBusinessUnit");
        action.setParams({ contractId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === 'Net') {
                    component.set("v.isMov",false);
                } else {
                    component.set("v.isMov",true);
                    helper.getAssetsNumberFromContract(component, helper);
                } 
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getAssetsNumberFromContract: function(component) {
        var listOptions = [];
        var action = component.get("c.getAssetsByBillingAccount");
        action.setParams({
            billingAcountId : component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();            
            var state = response.getState();
            component.set("v.isSearching", false);
            console.dir(result);
            
            if (result.length != null && result.length > 0) {
                for (let i = 0; i < result.length; i++) {
                    let choice = { 
                        label: this.formatMSISDN(result[i]),
                        value: result[i]
                    }
                    listOptions.push(choice);
                }
                component.set("v.options", listOptions);
            }else {
                this.toastEventMethod("", "Error", "Não há protocolos para o período selecionado.");
            }
            
        });
        $A.enqueueAction(action);
    },   
    
    validScreen: function(component, event, helper) 
    {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var protocolNumber = component.get("v.protocolNumber");
        
        if (startDate != null && endDate != null) 
        {
            var monthStartDate = startDate.substring(5, 7) - 1;
            var monthEndDate = endDate.substring(5, 7) - 1;
            
            var newStartDate= new Date(startDate.substring(0, 4), monthStartDate, startDate.substring(8, 10));
            var newEndDate = new Date( endDate.substring(0, 4), monthEndDate, endDate.substring(8, 10));
            
            var timeDiff = Math.abs(newEndDate.getTime() - newStartDate.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            var today = new Date();
            var diffYears = (today.getTime() - newStartDate.getTime()) / 1000;
            
            diffYears /= 60 * 60 * 24;
            diffYears = Math.abs(Math.round(diffYears / 365.25));
        }
        
        if (!startDate || !endDate) {
            this.toastEventMethod("", "Error", "Por favor, preencha todos os campos.");
            return false;
        } else if (newStartDate> newEndDate) {
            this.toastEventMethod("", "Error", "A data início não pode ser maior que a data fim.");
            return false;
        } else if (diffDays > 185) {
            this.toastEventMethod("", "Error", "O período máximo de consulta é de seis meses.");
            return false;
        } else {
            return true;
        }
    },
    
    getMobileProtocols: function(component, event, helper) 
    {
        component.set("v.isSearching", true);
        console.log('getMobileProtocols');
        
        console.log(component.get("v.startDate"));
        console.log(component.get("v.endDate"));
        console.log(component.find("slds-ativos").get("v.value"));
        
        var action = component.get("c.integrationMobileProtocols");
        action.setParams({
            startDate     : component.get("v.startDate"),
            endDate       : component.get("v.endDate"),
            msisdn : component.find("slds-ativos").get("v.value")
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();;
            var state = response.getState();
            
            component.set("v.isSearching", false);
            
            if (state === "SUCCESS") {                
                console.dir(state);
                console.dir(result);
                
                if (result.length != 0 && result.length != null) {
                    component.set("v.showTable", true);
                    component.set("v.protocolsLst", result);
                    console.log('result: ' +JSON.stringify(result));
                    
                } else {
                    component.set("v.showTable", false);
                    helper.toastEventMethod("", "Error", "Não há protocolos para o período selecionado.");
                }
            } else {
                component.set("v.showTable", false);
                helper.toastEventMethod("", "Error", "Não há protocolos para o período selecionado.");
            }
        });
        $A.enqueueAction(action);
    },
    
    getResidentialProtocols: function(component, event, helper) 
    {
        component.set("v.isSearching", true);
        console.log('getResidentialProtocols');

        console.log(component.get("v.startDate"));
        console.log(component.get("v.endDate"));
        console.log(component.get("v.recordId"));        
        
        var action = component.get("c.integrationProtocolsResidential");
        action.setParams({
            startDate     : component.get("v.startDate"),
            endDate       : component.get("v.endDate"),
            contractId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();;
            var state = response.getState();            
            component.set("v.isSearching", false);            
            
            if (state === "SUCCESS") {                
                console.dir(state);
                console.dir(result);
                
                if (result.length != null && result.length != 0) {
                    component.set("v.showTable", true);
                    component.set("v.protocolsLst", result);
                } else {
                    component.set("v.showTable", false);
                    helper.toastEventMethod("", "Error", "Não há protocolos para o período selecionado.");
                }
            } else {
                component.set("v.showTable", false);
                helper.toastEventMethod("", "Error", "Não há protocolos para o período selecionado.");
            }
            
        });
        $A.enqueueAction(action);
      	
    },   
    
    
    /* ----------------------- Métodos de Tratativa de Dados ----------------------- */
    formatMSISDN: function(msi) {
        console.log('formatMSISDN');
        console.log(msi);
        var inputValue = msi;
        if(msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            inputValue = res.substring(0,15);
            if(msi.length >= 11) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                inputValue = res.substring(0,15);
            }
        }
        console.log(inputValue)
        return inputValue;
    },
    
    toastEventMethod: function(title, type, message)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    },
    
    buildData: function(component,helper, event) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.data", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    
    
    
});