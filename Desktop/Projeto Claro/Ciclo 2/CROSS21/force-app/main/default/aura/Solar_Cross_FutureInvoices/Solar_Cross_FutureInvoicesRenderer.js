({
	afterRender: function (component, helper) {
        this.superAfterRender();
        helper.getcontractandOppId(component);    
    }
})