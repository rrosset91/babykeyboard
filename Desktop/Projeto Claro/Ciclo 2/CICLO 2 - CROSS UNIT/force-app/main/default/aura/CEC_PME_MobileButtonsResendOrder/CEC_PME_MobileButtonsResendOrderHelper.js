({
	reSendOrder : function(component, event, helper) {
		var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var reSendOrderAction = component.get('c.reenviarPedido');
        
        reSendOrderAction.setParams({
            recordId : component.get("v.recordId")
        });        
        reSendOrderAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {                 
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                this.showToast('Sucesso', 'SUCCESS', response.getReturnValue());              
            } else {
console.log('SAL >> Erro');                
                this.showToast('Erro', 'ERROR', response.getError()[0].message);
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        
        $A.enqueueAction(reSendOrderAction);
    },
    
    showToast : function(messageTitle, messageType, message) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": messageTitle,
            "type": messageType,
            "message": message
        });
        resultsToast.fire();
    },
    
    closeAction : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");

        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "Detail"
        });
        navEvt.fire();

        $A.get("e.force:closeQuickAction").fire(); 
    },
})