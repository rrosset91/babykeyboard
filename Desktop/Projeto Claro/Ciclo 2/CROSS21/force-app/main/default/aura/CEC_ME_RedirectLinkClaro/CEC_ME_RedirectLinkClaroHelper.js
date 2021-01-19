({
    getPicklistValues : function(component, event, helper) {
        var action = component.get("c.picklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.options", result);
                console.log('result ==========================> ' +JSON.stringify(result));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message Links Úteis: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getParameterRecords : function(component, event, helper) {
        var typeFilter = component.get("v.selectedValue");
        var recordId = component.get("v.recordId");
        console.log('recordId ' + recordId);
        var action = component.get("c.getParameterRecords");
        action.setParams({"aTypeFilter": typeFilter, "aRecordId": recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.data", result.lParametersLst);                                
                if(result.lJourney != null){
                    var jorneyMsg =  'Jornada ' + result.lJourney;
                    component.set("v.jorneyMsg",jorneyMsg);
                }
                else{
                    component.set("v.jorneyMsg", null);
                }
                console.log('result ==========================> ' +JSON.stringify(result));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message Links Úteis: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    navigateToButtonUrl : function(component) {
        var url = component.get("v.url");

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
})