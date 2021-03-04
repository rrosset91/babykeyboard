({
	afterRender: function (component, helper) {
        this.superAfterRender();
        helper.callFutureInvoices(component);
    },
})