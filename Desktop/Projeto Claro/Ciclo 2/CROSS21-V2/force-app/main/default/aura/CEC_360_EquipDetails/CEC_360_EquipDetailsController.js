({
    getDeviceDetail : function(component, event, helper) 
    {
        //Fechar modal de detalhe
        if(component.get("v.showDetail"))
            component.set("v.showDetail", false);
        else // Trazer informações da Integração
            helper.getDeviceDetail(component, event, helper);
    }
})