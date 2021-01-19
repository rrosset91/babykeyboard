({
	handleOpen: function(component, event, helper) {
		component.find('messageModal').open();
	},
	
	handleClose: function(component, event, helper) {
		component.find('messageModal').close();
	}
   
})