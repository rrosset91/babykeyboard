({
	doInit : function(component, event, helper) {
      helper.loadPromotionsBenefits(component, event, helper);
	},    
    
    handleClose : function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    handleCloseClick : function (component, event, helper) {
        component.set("v.visible", false);
    },

    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.buildData(component, helper);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.buildData(component, helper);
    },
    
    onMid : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    }
})