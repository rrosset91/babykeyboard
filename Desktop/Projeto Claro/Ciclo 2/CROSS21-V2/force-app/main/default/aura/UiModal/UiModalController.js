({
	handleOpen: function (component) {

		component.set("v.class", "show");

		const func = component.get('v.onOpen');      
        
        if(func)
            $A.enqueueAction(func);
	},
    
	handleClose: function (component) {
		component.set("v.class", "fadding");

		const func = component.get('v.onClose');      
        
        if(func)
			$A.enqueueAction(func);

		var exec = setTimeout(
			$A.getCallback(
				function () {
					component.set("v.class", "disposed")
				}
			),
			500
		);
	},
})