({
	afterRender: function (component, helper) {
        this.superAfterRender();
        //chama as faturas em aberto após a construção da página em nível de elemento (DOM)
        //helper.callOpenInvoices(component);
    }
})