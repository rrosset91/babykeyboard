({
    doInit: function(component, event, helper) {
        helper.setDates(component, event, helper);
        helper.setProtocolType(component, event, helper);
    },
    
    getMobileProtocols: function(component, event, helper) {
        console.log('getMobileProtocols');
        var validScreen = helper.validScreen(component, event, helper);
        console.log('validScreen: ' + validScreen);
        if (validScreen) {
            helper.getMobileProtocols(component, event, helper);
        }
    },
        
    getResidentialProtocols: function(component, event, helper) {
        console.log('getResidentialProtocols');
        var validScreen = helper.validScreen(component, event, helper);
        console.log('validScreen: ' + validScreen);
        if (validScreen) {
            helper.getResidentialProtocols(component, event, helper);
        }
    },
    
    expandDetails: function(component, event, helper) {
        var list = component.get("v.protocolsLst");
        var index = event.getSource().get("v.value");
        list[index].showDetails = !list[index].showDetails;
        component.set("v.protocolsLst", list);
    },
    
    nextPage : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    
    prevPage : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    firstPage : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    lastPage  : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    
    makeAction : function(component, event, helper) { 
        component.set("v.showDates");
        component.set("v.hasValue", true);  
    }
    
});