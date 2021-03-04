({
    onInit : function(component, event, helper) {
        component.set("v.isLoading", true);

       var startDate = helper.getDate(component, event, helper, 180);
       var endDate = helper.getDate(component, event, helper, 0);
       console.log('startDate ' + startDate);
       console.log('endDate ' + endDate);

        helper.getDataFromApex(component, event, helper, startDate, endDate);

    },
    changeComboboxFilter : function(component, event, helper) {
        helper.changeFilter(component, event, helper, 0);
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