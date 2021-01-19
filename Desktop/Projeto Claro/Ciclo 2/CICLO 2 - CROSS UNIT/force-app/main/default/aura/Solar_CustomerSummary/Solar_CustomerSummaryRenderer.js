({
    afterRender: function (component, helper) {
        this.superAfterRender();
        helper.loadData(component);
    },
})