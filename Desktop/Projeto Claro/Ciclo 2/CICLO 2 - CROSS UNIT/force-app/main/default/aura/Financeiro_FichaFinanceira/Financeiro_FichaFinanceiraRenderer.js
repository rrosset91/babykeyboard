({
	afterRender: function (component, helper) {
        this.superAfterRender();
        helper.fetchDetails(component, helper);
    }
})