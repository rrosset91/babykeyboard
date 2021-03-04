({
	doInit : function(component, event, helper) {
		helper.setModalDates(component,event,helper);
	},
    
    retInvoiceData : function(component,event,helper){
        component.set("v.showSpinner",true);
        helper.retInvoiceData(component,helper);
    },
    
    pdfInvoice : function(component,event,helper){
        component.set("v.showSpinner",true);
        var dateEnd = event.target.getAttribute('data-end');
        var dateForm = dateEnd.substring(6,10)+'-'+ dateEnd.substring(3,5) + '-' + dateEnd.substring(0,2);
        var action = component.get("c.getUrlPdfBillingAcc");
        action.setParams({ dueDate : dateForm ,
                          recordId: component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent;
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
                
            }
            
            if(state == 'ERROR'){
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
    
    
})