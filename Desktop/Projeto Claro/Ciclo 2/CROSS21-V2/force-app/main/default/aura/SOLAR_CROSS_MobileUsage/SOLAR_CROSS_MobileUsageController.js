({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.getMobileUsage");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if(state === "SUCCESS") {
                if(response.getReturnValue().data != null) {
                    component.set("v.dataMobileUsage", response.getReturnValue().data.usages);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error" ,
                        "message": "Não há consumos para a linha.1"
                    });
                   // toastEvent.fire();
                    component.set("v.MobileDataUsageReturn",false);
                    component.set("v.refreshData",true);
                }
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error" ,
                    "message": "Não há consumos para a linha.2"
                });
               // toastEvent.fire(); 
                component.set("v.MobileDataUsageReturn",false);
                component.set("v.refreshData",true);
                
            }
        });
  
        $A.enqueueAction(action);
    },

    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }
    
    // toggleSection : function(component, event, helper) {
    //     // dynamically get aura:id name from 'data-auraId' attribute
    //     var sectionAuraId = event.target.getAttribute("data-auraId");
    //     // get section Div element using aura:id
    //     var sectionDiv = component.find(sectionAuraId).getElement();
    //     /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
    //      * This method returns -1 if no match is found.
    //     */
    //     var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
    //     // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
    //     if(sectionState == -1){
    //         sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
    //     }else{
    //         sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
    //     }
    // }
})