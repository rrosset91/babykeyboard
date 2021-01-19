({
    fillContractData : function(component, helper){
        let wrapper     = component.get('v.wrapper');
        let recordId    = component.get("v.recordId");
        let contractNumber = component.get("v.contractNumber");
        let startDay    = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        let endDay      = new Date();
        endDay.setDate(endDay.getDate() - 90);
        endDay          = $A.localizationService.formatDate(endDay, "YYYY-MM-DD");

        console.log('fillContractNumber', recordId);

        var action = component.get("c.getContractData");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") { 
                wrapper = response.getReturnValue();
                contractNumber    =     wrapper.contractNumber;
                component.set("v.contractNumber",   wrapper.contractNumber);
                component.set("v.businessUnit",     wrapper.businessUnit);

                if(wrapper.contractNumber != null){
                    var callInvoice = component.get("c.getObjectDataBillingAcc");
                    callInvoice.setParams({
                        contractNumber : contractNumber,
                        startDate: startDay,
                        endDate : endDay
                    });
                    callInvoice.setCallback(this, function(response) {
                        component.set('v.showSpinner', false);
                        console.dir(response.getReturnValue());
                        // component.set("v.showSpinner",false);
                        var state = response.getState();
                        if(state == 'SUCCESS'){
                            component.set("v.dataInvoice",  response.getReturnValue());
                            component.set('v.showInvoice',  true);
                        }else{
                            console.log('Error', response.getReturnValue());
                            component.set('v.showSpinner',  false);
                            component.set('v.showInvoice',  false);
                            component.set('v.noInvoice',    true);
                        }
                    });        
                    $A.enqueueAction(callInvoice);
                }
            }else{
                console.log('fillContractNumber ERror', response.getReturnValue());
            }
            component.set("v.showButtonFinace", true);
        });        
        
        $A.enqueueAction(action);
    },

    getPDFInvoiceMov : function(component,event,helper,dateEndd){ 
        console.log('getPDFInvoiceMov');
        component.set("v.showSpinner",true);
        var dateEnd = event.target.getAttribute('data-end');
        var dateForm = dateEndd.substring(6,10)+'-'+ dateEndd.substring(3,5) + '-' + dateEndd.substring(0,2);

        var action = component.get("c.getUrlPdfBillingAcc");
        action.setParams({ 
            dueDate : dateForm ,
            contractNumber : component.get("v.contractNumber")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent;
            console.log('getPDFInvoiceMov response', response.getReturnValue());
            component.set("v.showSpinner",false);
            if(state == 'SUCCESS'){
                var urlPDF = response.getReturnValue();
                if(urlPDF != null){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": urlPDF
                    });
                    urlEvent.fire();
                }else{
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro!", 
                        "type": "Error", 
                        "message":'Documento inexistente.'
                    });
                    toastEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro!", 
                    "type": "Error", 
                    "message":'Documento inexistente.'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);
    },

    getPDFInvoiceRes : function(component,event,helper,dataIdd){ 
        console.log('getPDFInvoiceRes');
        component.set("v.showSpinner",true);
        var dataId = event.target.getAttribute('data-id');

        var action = component.get("c.getUrlPdfBillingAccRes");
        action.setParams({ 
            contractNumber : component.get("v.contractNumber"),
            invoiceId :dataIdd 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent;
            console.log('getPDFInvoiceMov response', response.getReturnValue());
            component.set("v.showSpinner",false);
            if(state == 'SUCCESS'){
                var pdfData = response.getReturnValue();
                if(pdfData  != null){
                    helper.callSaveComp(component,event,helper,pdfData);
                }else{
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro!", 
                        "type": "Error", 
                        "message":'Documento inexistente.'
                    });
                    toastEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro!", 
                    "type": "Error", 
                    "message":'Documento inexistente.'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    callSaveComp : function(component,event,helper,pdfData){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef  : "c:CEC_360_invoiceViewer" ,
            componentAttributes : {
                pdfData : pdfData 
            }
        });
        
        evt.fire();
        
    }
})