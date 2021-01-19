({
    doInit: function(component, event, helper) {
        var action = component.get("c.getSearchConfig");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searchConfig", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    search: function(component, event, helper) {
        component.set("v.searchConfig.searchButton.label", "Buscando...");
        component.set("v.searchConfig.searchButton.disabled", "true");
        
        var action = component.get("c.getTable");
        console.log(component.get("v.searchConfig.startDate.value"));
        action.setParams({ 
            "startDate" : component.get("v.searchConfig.startDate.value"),
            "endDate" : component.get("v.searchConfig.endDate.value"),
            "searchTypeId" : component.get("v.searchConfig.typeInput.value"),
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (response.getState() === "SUCCESS") {
                console.log('SUCCESS');
                component.set("v.table", response.getReturnValue());
                component.set("v.hasRequisitions", "true");
            } else {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;
                } else {
                    console.log("Unknown error");
                }
                component.set("v.hasRequisitions", "false");
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "",
                    "type": "ERROR",
                    "message": message
                });
                resultsToast.fire();
            }
            
            component.set("v.searchConfig.searchButton.label", "Buscar");
            component.set("v.searchConfig.searchButton.disabled", "false");
        });
        
        $A.enqueueAction(action);
    },
    
    setSearchButtonDisabled: function(component, event, helper) {
        var startDateinput = component.find("startDate");
        var endDateinput = component.find("endDate");
        var isSearchButtonDisabled = !(startDateinput.checkValidity() 
                                       && endDateinput.checkValidity());
        
        component.set("v.searchConfig.searchButton.disabled", isSearchButtonDisabled);
    },
})