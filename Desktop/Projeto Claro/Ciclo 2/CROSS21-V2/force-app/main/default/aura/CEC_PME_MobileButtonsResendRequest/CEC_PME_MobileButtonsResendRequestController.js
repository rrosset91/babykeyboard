({
    handleSaveTableEdit : function(component, event, helper) {
        helper.saveTableData(component,event, helper);
    },
    
    doInit : function(component, event, helper) {
        console.log('do init');
        component.set('v.contactsTableColumns', [
            {
                label: $A.get("$Label.c.CEC_PME_MobileButtonsResendRequest_4"), 
                fieldName: 'clientName', 
                type: 'text', 
                editable: false, 
                typeAttributes: { 
                    required: true 
                }
            },
            {
                label: $A.get("$Label.c.CEC_PME_MobileButtonsResendRequest_5"), 
                fieldName: 'clientEmail', 
                type: 'email', 
                editable: true, 
                typeAttributes: { 
                    maxlength: 20, 
                    required: true 
                }, 
                initialWidth: 250
            },
        ]);
        helper.getSignatureContacts(component, event, helper);
    },
            
    closeAction : function(component, event, helper) {
        helper.closeAction(component, event, helper);
    },
            
    reSendEnvelope : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
            
        helper.reSendEnvelope(component, event, helper);
    },          
})