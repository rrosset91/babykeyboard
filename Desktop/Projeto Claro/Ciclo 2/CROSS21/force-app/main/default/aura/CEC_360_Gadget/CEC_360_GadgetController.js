({
    doInit : function(component, event, helper) {
      helper.h_doInit(component,event,helper);
    },
    
     handleCloseClick: function (cmp, event, helper) {
        cmp.set("v.visible", false);
    },
    
    handleClose : function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
      
})