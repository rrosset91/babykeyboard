({
	setDates : function(component,event,helper){
        var today = $A.localizationService.formatDate(new Date() , "YYYY-MM-DD");
        var todaySubtract = new Date();
        var todayPlus = new Date();
        todayPlus = $A.localizationService.formatDate(todayPlus, "YYYY-MM-DD");
        todaySubtract.setDate(todaySubtract.getDate() - 60);
        todaySubtract = $A.localizationService.formatDate(todaySubtract, "YYYY-MM-DD");
        component.set("v.startDate",todaySubtract);
        component.set("v.endDate",todayPlus);
        var todayYear = new Date();
        todayYear.setYear(todayYear.getFullYear() - 5);
        todayYear = $A.localizationService.formatDate(todayYear, "YYYY-MM-DD");
        var todaySum = new Date();
        todaySum.setDate(todaySum.getDate() + 30);
        todaySum = $A.localizationService.formatDate(todaySum, "YYYY-MM-DD");
        component.set("v.minDate",todayYear);
        component.set("v.maxDate",todaySum);
    },
    
    
    isDateSearch : function(component,event,helper){
        component.set("v.isSearching",true);
        var action = component.get("c.getOrdemsfromData");
        action.setParams({ 
            startDate : component.get("v.startDate"),
            endDate: component.get("v.endDate"),
            contractNumber : component.get("v.contractNumber")
        });
        
        
        action.setCallback(this, function(response) {
            var result;
            var state = response.getState();
            component.set("v.isSearching",false);
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                console.dir(result);
                if(result.length != 0 && result.length != null) {
                    component.set("v.showTable",true);
                    component.set('v.ordersItem', result);
                    console.dir(result);
                }else{
                    component.set('v.showTable',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Não há ordens de serviço para o período selecionado.'
                    });
                    toastEvent.fire();
                    
                }
            }else{
                component.set('v.showTable',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não há ordens de serviço para o período selecionado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    isProtocolSearch : function(component,event,helper){
        component.set("v.isSearching",true);
        var action = component.get("c.getOrdemsfromProtocol");
        action.setParams({ 
            protocolNumber: component.get("v.protocolNumber"),
            contractNumber : component.get("v.contractNumber")
        });
        
        
        action.setCallback(this, function(response) {
            var result;
            var state = response.getState();
            component.set("v.isSearching",false);
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                console.dir(result);
                
                if(result.length != 0 && result.length != null) {
                    component.set("v.showTable",true);
                    component.set('v.ordersItem', result);
                    console.dir(result);
                }else{
                    component.set('v.showTable',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Não há ordens de serviço para o protocolo selecionado.'
                    });
                    toastEvent.fire();
                    
                }
            }else{
                component.set('v.showTable',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não há ordens de serviço para o protocolo selecionado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    validScreen : function(component,event,helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var protocolNumber = component.get("v.protocolNumber");
        var isDate = component.get("v.isNumber");
        var isNumber = component.get("v.isDate");
        
        
        if(isDate){
            if(startDate != null && endDate != null){
                var month1 = startDate.substring(5,7)-1;
                var month2 = endDate.substring(5,7)-1;
                var date1 = new Date(startDate.substring(0,4),month1,startDate.substring(8,10));
                var date2 = new Date(endDate.substring(0,4),month2,endDate.substring(8,10));
                var timeDiff = Math.abs(date2.getTime() - date1.getTime());
                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                var today = new Date();
                var diffYears = (today.getTime() - date1.getTime()) / 1000;
                diffYears /= (60 * 60 * 24);
                diffYears = Math.abs(Math.round(diffYears / 365.25));   
                
            }
            
            if (!startDate || !endDate)
            {   
             alert('aqui !startDate');
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 "title": "Erro", 
                 "type": "Error", 
                 "message": 'Por favor, preencha todos os campos.'
             });
             toastEvent.fire();
             return false;
            }else if(date1 > date2){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'A data início não pode ser maior  que  a data fim.'
                });
                toastEvent.fire();
            }else{
                return true; 
            }
        }
        
        if(isNumber){
            if(protocolNumber){
                return true;
            }else{
                alert('numero');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Por favor, preencha todos os campos.'
                });
                toastEvent.fire();
                return false; 
            }
        }
        
    },
    
})