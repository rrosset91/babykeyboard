({
	doInit : function(component) {
        
        var actGetMobileButtonsVO = component.get("c.getMobileButtonsVO");

        actGetMobileButtonsVO.setParams({ 
            recordId : component.get("v.recordId")
        });
        
        actGetMobileButtonsVO.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var mobileButtonsVO = response.getReturnValue();
                var order = mobileButtonsVO.order;
                
                var isNeverManual = true;
                if(order && order != null && order.Histories && order.Histories != null) {
                    for (var i = 0; i < order.Histories.length; i++) {
                        var historyOrder = order.Histories[i];
                        isNeverManual = isNeverManual && (historyOrder.NewValue != 'Executando Input Manual');
                    }
                }
                
                component.set("v.cpcRole", mobileButtonsVO.user.RolerFormula__c);  
                var componentIcon = component.find("iconHeader");
                componentIcon.set('v.iconName', 'standard:orders');
                componentIcon.set('v.size', 'medium');
                
                var user = mobileButtonsVO.user;
                
                component.set("v.order", order);
                component.set("v.isNeverManual", isNeverManual);
                
                component.set("v.access", mobileButtonsVO.access);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(actGetMobileButtonsVO);
    },
    
    closeAction : function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "Detail"
        });
        navEvt.fire();
        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    navigateToResume : function(component) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "/apex/CEC_PME_ResumoPedido?id=" + component.get("v.recordId")
        });   
        
        navEvt.fire();      
    },
    
    callComponent : function(component, compName) { 
		var evt = $A.get("e.force:navigateToComponent"); 

		evt.setParams({
        	componentDef : compName,
        	componentAttributes: {
            	recordId : component.get("v.recordId")
        	}
    	});        

        evt.fire();        
    },
    
    fireComponentEvent : function(component, event, helper) {
        var appEvent = $A.get("e.c:CEC_PME_MobileButtonEvt");
        appEvent.fire();
    }
    
})