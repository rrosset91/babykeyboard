({
    onInit : function(component, event, helper) {
        helper.getAlertsFromApex(component, event, helper);
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    openConcludeModal: function (component, event, helper) {
        var alertId = event.getSource().get("v.name");
        var index = event.getSource().get("v.value");
        console.log('alertId ' + alertId);
        console.log('index ' + index);
        component.set("v.alertId",alertId);
        component.set("v.index",index);
        helper.openModal(component, event, helper);     

    },
    closeConcludeModal: function (component, event, helper) {
        component.set("v.alertId",null);
        component.set("v.index",null);
        helper.closeModal(component, event, helper);      
    },
    concludeAlert: function (component, event, helper) {
       helper.concludeAlertWithApex(component, event, helper);
       helper.closeModal(component, event, helper);      


    },
})