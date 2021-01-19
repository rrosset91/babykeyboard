({
    onInit : function(component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.selectedValue", 'Todos');
        var loadPicklist = component.get("v.options");
        if(loadPicklist == null || loadPicklist.length == 0){
            helper.getPicklistValues(component, event, helper);
        }
        helper.getParameterRecords(component, event, helper);
    },
    handleButtonClick : function(component, event, helper) {
        component.set("v.url", event.getSource().get("v.value"));
        helper.navigateToButtonUrl(component, event, helper);
    },

    changePicklistFilter : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.getParameterRecords(component, event, helper);
    },
})