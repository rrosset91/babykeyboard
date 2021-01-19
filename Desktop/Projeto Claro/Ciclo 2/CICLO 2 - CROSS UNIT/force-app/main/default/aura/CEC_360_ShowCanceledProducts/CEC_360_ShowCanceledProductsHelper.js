({
	getCancelAssets : function(component,event,helper)
    {
        component.set("v.hasSpinner",true);
        
        var action = component.get("c.getAssets");
        action.setParams({
            id: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.hasSpinner",false);
                if(result.length == 0){
                    component.set('v.hasCancel',false);                    
                }else{
                    for(var i = 0; i< result.length ;i++){
                        console.log(result[i]);
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                    }
                    component.set('v.hasCancel',true);
                    component.set("v.cancProducts", result);
                }
            }
        });
        $A.enqueueAction(action);
    },    
        
    /* ----------------------- Métodos de Tratativa de Dados ----------------------- */
    formatMSISDN: function(msi) {
        console.log('formatMSISDN');
        console.log(msi);
        var inputValue = msi;
        if(msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            inputValue = res.substring(0,15);
            if(msi.length >= 11) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                inputValue = res.substring(0,15);
            }
        }
        console.log(inputValue)
        return inputValue;
    },
  
})