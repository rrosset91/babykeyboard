({
    alterarTipoAnexo : function(component, event) {
        var tipoAnexo = component.find('select').get('v.value');
        var action = component.get("c.saveTipoAnexo");
        action.setParams({
            'Id': component.get("v.orderId"), 
            'tipoAnexo': tipoAnexo,
            'title': component.get("v.contVersion").ContentDocument.Title
        });
        
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            component.set("v.contVersion.CEC_Tipo_de_Anexo__c",tipoAnexo);
        }));
        
        $A.enqueueAction(action);
    }
})