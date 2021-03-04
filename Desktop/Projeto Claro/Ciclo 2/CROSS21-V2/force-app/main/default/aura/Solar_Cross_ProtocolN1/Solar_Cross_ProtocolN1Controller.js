({
    loaded : function(component, event, helper) {
        var message = "O protocolo foi <b>encerrado</b> em N1 com as seguintes tratativas";
        component.set("v.message", message);
        component.set("v.isLoading", false);

    }
})