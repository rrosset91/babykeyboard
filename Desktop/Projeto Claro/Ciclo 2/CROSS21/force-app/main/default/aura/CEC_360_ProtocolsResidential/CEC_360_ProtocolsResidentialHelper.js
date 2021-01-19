({
    validScreen : function(component,event,helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var protocolNumber = component.get("v.protocolNumber");
        var isDate = component.get("v.isDate");
        var isNumber = component.get("v.isNumber");
        
        
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
            {   var toastEvent = $A.get("e.force:showToast");
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
            }else if(diffDays > 60){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'A diferença entre as datas não pode ser maior que 60 dias.'
                });
                toastEvent.fire();
                return false; 
                
            }else{
                return true; 
            }
        }
        
        if(isNumber){
            if(protocolNumber){
                return true;
            }else{
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
    
    getProtocolsDate : function(component,event,helper){
        var action = component.get("c.getProtocols");
        action.setParams({ 
            contractFormatted : component.get("v.contractNumber"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            var result;
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                
                if(result != null && result.length != 0) {
                    component.set('v.showProtocols',true);
                    component.set('v.protocolsList', result);
                    component.set('v.activeSection',component.get("v.selectedContract"));
                    console.dir(result);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Não há protocolos para o período selecionado.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não há protocolos para o período selecionado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
     getProtocolsNumber : function(component,event,helper){
        var action = component.get("c.getProtocolsNumber");
        action.setParams({ 
            contractFormatted : component.get("v.contractNumber"),
            protocolNumber : component.get("v.protocolNumber")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            var result;
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                
                if(result != null && result.length != 0) {
                    component.set('v.showProtocols',true);
                    component.set('v.protocolsList', result);
                    component.set('v.activeSection',component.get("v.selectedContract"));
                    console.dir(result);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Protocolo não encontrado.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Protocolo não encontrado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getProtocolsDetails : function(component,event,helper){
        var action = component.get("c.getDetails");
        action.setParams({ 
            protocolNumber : component.get("v.protocolNumber"),
            contract : component.get("v.selectedContract"),
          });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result;
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                console.dir('Result'+result);
                if(result != null) {
                    component.set('v.protocolsList', result);
                    console.log('Select'+component.get("v.selectedContract"));
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro", 
                        "type": "Error", 
                        "message": 'Protocolo não encontrado.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Protocolo não encontrado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
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
    }
})