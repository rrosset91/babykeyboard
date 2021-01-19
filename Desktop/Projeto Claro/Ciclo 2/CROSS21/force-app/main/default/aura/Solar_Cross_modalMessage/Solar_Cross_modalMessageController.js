({
	handleOpen: function(component, event, helper) {
		component.find('Solar_Cross_messageModal').open();
	},
	
	handleClose: function(component, event, helper) {
		component.find('Solar_Cross_messageModal').close();
	},
    
    onCancel: function(component, event, helper) {
		component.find('Solar_Cross_messageModal').close();
	}
   
})