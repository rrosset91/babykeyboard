({
    doInit : function(component,helper){
        var action = component.get("c.getContractNumberBillingAccount");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set("v.record", response.getReturnValue());
            } 
            
        });        
        
        $A.enqueueAction(action);
        
    },
    
    openInvoice : function(component,helper) {
        component.set("v.isShow",true);
        helper.setModalDates(component,helper);
    },
    
    closeInvoiceView :function(component,helper){
        component.set("v.isShow",false);
        component.set("v.drawnTable",false);
        component.set("v.dataInValue",'');
        component.set("v.dataEndValue",'');
    },
    
    
    validField : function(component,helper){
        if(!component.get("v.dataInValue") || !component.get("v.dataEndValue") )
        {
            return false;
        }else{
            return true;
        }
    },
    
    setModalDates : function(component,helper){
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var todaySubtract = new Date();
        todaySubtract.setDate(todaySubtract.getDate() - 180);
        todaySubtract = $A.localizationService.formatDate(todaySubtract, "YYYY-MM-DD");
        component.set("v.dataInValue",todaySubtract);
        component.set("v.dataEndValue",today);
        var todayYear = new Date();
        todayYear.setYear(todayYear.getFullYear() - 5);
        todayYear = $A.localizationService.formatDate(todayYear, "YYYY-MM-DD");
        var todaySum = new Date();
        todaySum.setDate(todaySum.getDate() + 30);
        todaySum = $A.localizationService.formatDate(todaySum, "YYYY-MM-DD");
        component.set("v.minDate",todayYear);
        component.set("v.maxDate",todaySum);
    },
    
    retInvoiceData : function(component,helper){
        component.set("v.data",'');
        component.set("v.drawnTable", false);
        var validField = helper.validField(component,helper);
        var dateStart = component.get("v.dataInValue");
        var dateEnd = component.get("v.dataEndValue");
        var toastEvent;
        
        if(!validField) {
            component.set("v.showSpinner",false);
            toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Erro.", 
                "type": "Error", 
                "message":'Por favor, preencha os dois campos de data no formato dd/mm/aaaa.'
            });
            toastEvent.fire();
        }else{
            var month1 = dateStart.substring(5,7)-1;
            var month2 = dateEnd.substring(5,7)-1;
            var date1 = new Date(dateStart.substring(0,4),month1,dateStart.substring(8,10));
            var date2 = new Date(dateEnd.substring(0,4),month2,dateEnd.substring(8,10));
            var timeDiff = Math.abs(date2.getTime() - date1.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            var today = new Date();
            var diffYears = (today.getTime() - date1.getTime()) / 1000;
            diffYears /= (60 * 60 * 24);
            diffYears = Math.abs(Math.round(diffYears / 365.25));
            console.log('DiffYears'+diffYears);
          
            if(isNaN(date1) == true || isNaN(date2) == true){
                component.set("v.showSpinner",false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro.", 
                    "type": "Error", 
                    "message":'Data inválida ou inexiste.'
                });
                toastEvent.fire();
                
            } else if(date1 > date2){
                component.set("v.showSpinner",false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro.", 
                    "type": "Error", 
                    "message":'Data início é maior que a data fim.'
                });
                toastEvent.fire();
                
            }else if(diffYears >= 5){
                component.set("v.showSpinner",false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro.", 
                    "type": "Error", 
                    "message":"A data início não pode ser anterior há 5 anos."
                });
                toastEvent.fire();
                
            }else if(diffDays > 190){
                component.set("v.showSpinner",false);
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro.", 
                    "type": "Error", 
                    "message":"A diferença entre as datas não pode ser maior que 6 meses."
                });
                toastEvent.fire();
            }else{
                helper.callInvoice(component,helper);
            }
        }
    },
    
    callInvoice : function(component,helper){
        var action = component.get("c.getObjectDataBillingAcc");
        action.setParams({recordId : component.get("v.recordId"),
                          startDate: component.get("v.dataInValue"),
                          endDate : component.get("v.dataEndValue")});
        
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            var toastEvent;
            if(state == 'SUCCESS'){
                console.dir(response.getReturnValue());
                component.set("v.data",response.getReturnValue());
                
                if(component.get("v.data") == null){
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro na Busca", 
                        "type": "Error", 
                        "message":'Nenhum resultado encontrado.'
                    });
                    toastEvent.fire();
                }else{
                    component.set("v.drawnTable",true);
                }
                
            }
            
            if(state == 'ERROR'){
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro!", 
                    "type": "Error", 
                    "message":'Nenhum resultado encontrado.'
                });
                toastEvent.fire();
                
            }
            
        });        
        
        $A.enqueueAction(action);
    },
    
    
})