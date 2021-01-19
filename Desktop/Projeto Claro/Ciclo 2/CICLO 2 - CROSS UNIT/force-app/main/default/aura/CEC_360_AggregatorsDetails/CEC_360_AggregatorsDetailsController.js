({
	doInit : function(component, event, helper) {
		
	},
    
    handleClose : function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    }
})