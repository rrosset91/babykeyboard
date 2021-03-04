({
    onInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.getDataFromApex(component, event, helper);
    },

    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }
})