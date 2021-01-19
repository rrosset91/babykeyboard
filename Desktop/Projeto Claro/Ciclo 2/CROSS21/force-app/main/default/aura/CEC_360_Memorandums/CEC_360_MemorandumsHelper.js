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
    
    validScreen: function(component,event,helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        
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
        
    },
    
    getMemosAsset: function(component,event,helper){
        var toastEvent;
        component.set('v.showSpinnerModal',true);
        var action = component.get("c.getMemosAsset");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate") 
        });
        
        action.setCallback(this, function(response) {
            var result;
            var state = response.getState();
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                if(result.data != null) {
                    component.set('v.showTable',true);
                    component.set('v.showSpinnerModal',false);
                    component.set('v.memoList', result.data.memoObj);
                    console.dir(result);
                   }
                else{
                    component.set('v.showSpinnerModal',false);
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não foram encontrados memorandos.'
                });
                toastEvent.fire(); 
                }
            }else{
                component.set('v.showSpinnerModal',false);
                component.set('v.showModalDetails',false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não foram encontrados memorandos.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getMemosContract : function(component,event,helper){
       var toastEvent;
        component.set('v.showSpinnerModal',true);
        var action = component.get("c.getMemosContract");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            startDate : component.get("v.startDate"),
            endDate : component.get("v.endDate") 
        });
        
        action.setCallback(this, function(response) {
            var result;
            var state = response.getState();
            if (state === "SUCCESS") {
                result = response.getReturnValue();
                if(result.data != null) {
                    component.set('v.showTable',true);
                    component.set('v.showSpinnerModal',false);
                    console.dir('result'+result);
                    component.set('v.memoList', result.data.memoObj);
                  }
                else{
                    component.set('v.showSpinnerModal',false);
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não foram encontrados memorandos.'
                });
                toastEvent.fire(); 
                }
            }else{
                component.set('v.showSpinnerModal',false);
                component.set('v.showModalDetails',false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro", 
                    "type": "Error", 
                    "message": 'Não foram encontrados memorandos.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})