({
    doInit : function(component, event, helper) {
        
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var action = component.get("c.validate");
        var hasError = true;
        var message;
        action.setParams({ 
            opportunityId : component.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                if(response.getReturnValue() == "Sucesso") {
                    console.log("Sucesso");
                    hasError = false;
                    
                } else {
                    console.log("erro");
                    message = response.getReturnValue();
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        message = "Error message: " + errors[0].message;
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            if(hasError) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": message
                });
                toastEvent.fire();
            } else {
                var eventParams = event.getParams();
                
                //if(eventParams.changeType === "LOADED") {
                var url = '/apex/c__pmeJourneyTest3?OpportunityIdToConvert={0}&AccountId={1}&TradeInConversion={2}&SetTradeInReadOnlyConversion={3}';
                url = url.replace('{0}', component.get("v.recordId"));
                url = url.replace('{1}', component.get("v.oppRecord.AccountId")); //Id account
                url = url.replace('{2}', '');
                url = url.replace('{3}', '');
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url,
                    "isredirect" : true
                });
                helper.closeFocusedTab(component, helper);
                urlEvent.fire();
                //}
            }
            
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        
    }
})