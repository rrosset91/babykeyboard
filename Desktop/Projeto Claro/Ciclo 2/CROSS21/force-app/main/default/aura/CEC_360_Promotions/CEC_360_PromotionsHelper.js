({
    loadPromotions : function(component, event, helper) {
        console.log('loadPromotions');
        component.set("v.showSpinner", true);
        var action = component.get("c.getPromotions");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        console.log('recordId: ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retorno;
            console.log('Retorno loadPromotions: ' + retorno);
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                component.set("v.showSpinner", false);
                if(retorno != null && retorno.data != null) {
                    component.set('v.dataPromotions', retorno.data.promotions);
                    component.set('v.hasPromotions', true);
                } else {                   
                    component.set('v.hasPromotions', false);
                    
                }
            } else {
                component.set("v.showSpinner", false);
                component.set('v.hasPromotions', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadPromotionsHistory: function(component,event,helper){
        component.set("v.showSpinnerHistory", true);
        component.set("v.showTableHistory",false);
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getHistoryPromotion");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            startDate: component.get("v.startDate"),
            endDate: component.get("v.endDate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                component.set("v.showSpinnerHistory", false);
                 if(retorno != null ) {
                   component.set('v.dataPromotionsHistory', retorno);
                   component.set("v.showTableHistory",true);
                   component.set("v.totalSize", component.get("v.dataPromotionsHistory").length - 1);
                   component.set("v.start", 0);
                   component.set("v.end", pageSize - 1);
                   component.set("v.hasHistoric", true);
                     
                    if (component.get("v.dataPromotionsHistory").length < 5) {
                        pageSize = component.get("v.dataPromotionsHistory").length;
                    }
                     
                     var paginationList = [];
                     for (var i = 0; i < pageSize; i++) {
                         console.log(retorno[i]);
                         paginationList.push(retorno[i]);
                     }
                     
                    component.set('v.paginationList', paginationList);
                    component.set("v.showPromotions",true);
                     
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Sucesso", 
                        "type": "Success", 
                        "message": 'Promoções carregadas.'
                    });
                    toastEvent.fire();
                   
                } else {
                    component.set("v.showPromotions",false);
                    component.set("v.showSpinnerHistory", false);
                    component.set("v.hasHistoric", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "", 
                        "type": "Error", 
                        "message": 'Não foi possível encontrar promoções no período selecionado.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.dataPromotionsHistory", false);
                component.set("v.showSpinnerHistory", false);
                component.set("v.hasHistoric", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "", 
                    "type": "Error", 
                    "message": 'Não foi possível encontrar promoções no período selecionado.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    setDatePromotions: function(component,event,helper){
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
    
    validScreen : function(component){
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
        {   component.set("v.hasHistoric", false);
            var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
             "title": "", 
             "type": "Error", 
             "message": 'Por favor, preencha todos os campos.'
         });
         toastEvent.fire();
         return false;
        }else if(date1 > date2){
            component.set("v.hasHistoric", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "", 
                "type": "Error", 
                "message": 'A data início não pode ser maior  que  a data fim.'
            });
            toastEvent.fire();
        }else if(diffDays > 60){
            component.set("v.hasHistoric", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "", 
                "type": "Error", 
                "message": 'A diferença entre as datas não pode ser maior que 60 dias.'
            });
            toastEvent.fire();
            return false; 
            
        }else{
            return true; 
        }
    }
    
})