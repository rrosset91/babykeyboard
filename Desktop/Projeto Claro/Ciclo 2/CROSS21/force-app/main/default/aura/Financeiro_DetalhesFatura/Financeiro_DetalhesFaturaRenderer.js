({
    afterRender: function (component, helper) {
        this.superAfterRender();
        //chama detalhes da fatura após a construção da página em nível de elemento (DOM)
        helper.callInvoiceDetail(component);
    }
})