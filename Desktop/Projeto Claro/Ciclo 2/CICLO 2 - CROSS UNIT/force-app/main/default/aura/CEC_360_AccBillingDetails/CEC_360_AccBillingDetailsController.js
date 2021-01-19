({
    doInit : function(component, event, helper) {
        helper.getContracts(component,event,helper);
        helper.fillContracts(component,event,helper);
        helper.setModalDates(component,event,helper);
        
    },
    
    getContractInfos : function(component,event,helper){
        component.set("v.data",null);
        component.set("v.hasSpinner2",true);
        component.set("v.drawnTable",false);
        var action = component.get("c.getDetails");
        action.setParams({
            contractNumber : component.get("v.contractNumber")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' +state);
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ' +JSON.stringify(result));
                
                component.set("v.Conta",result);
                if (result.BusinessUnit__c == 'Net') {
                    component.set("v.hasNet",true);
                } else if(result.BusinessUnit__c == 'Claro'){
                    component.set("v.hasNet",false);
                }
                
                
            } else{
                component.set('v.hasCancel',true);
                alert('erro');
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    retInvoiceData : function(component,event,helper){
        component.set("v.showSpinner",true);
        helper.retInvoiceData(component,helper);
    },
    
    pdfInvoice : function(component,event,helper){
        var bu;
        var action = component.get("c.getBUnit");
        // Correcao DDP-129830 - Inicio
        var dataIdd = event.target.getAttribute('data-id');
        var dateEndd = event.target.getAttribute('data-end');
        // Correcao DDP-129830 - Fim
        // 
        action.setParams({contractNumber : component.get("v.contractNumber")});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            bu = response.getReturnValue();
            if (state == "SUCCESS") { 
                if(bu == 'Net'){
                    // Correcao DDP-129830 - Inicio
                    //helper.getPDFInvoiceRes(component,event,helper);
                    helper.getPDFInvoiceRes(component,event,helper,dataIdd);
                    // Correcao DDP-129830 - Fim
                }
                else if(bu =='Claro'){
                    helper.getPDFInvoiceMov(component,event,helper,dateEndd);
                }
            } 
            
        });        
        
        $A.enqueueAction(action);
        
        
        
    }
    
    
})