({
    onInit : function(component, event, helper) {        
        helper.getPicklistValues(component, event, helper);
        helper.load(component, event, helper);
        
        
    },
    descriptionModal : function(component, event, helper) {
            helper.openModal(component, event, helper);
        // }
    },
    closeDescriptionModal: function (component, event, helper) {
        helper.closeModal(component, event, helper);      
    },

    updateIcon: function (component, event, helper) {
        component.set("v.isLoading", true);
        var selectedOption = event.getSource().get("v.value");
        component.set("v.icon",selectedOption);
        helper.updateRecordIcon(component, event, helper);      
        helper.closeModal(component, event, helper);      
    }


})