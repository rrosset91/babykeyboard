({
    getCaseRecord : function(component) {
        let caseId = component.get('v.recordId');
        let action = component.get('c.getCase');
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response){
            var state = response.getState();
            var retorno = response.getReturnValue();
            if(state === 'SUCCESS'){
                let status = retorno.Status;
                console.log('status: ' + status);
                if(status){
                    if(status === 'Solicitação em Analise'
                       || status === 'Cancelado'
                       || status === 'Solicitação Executada'
                       || status === 'Novo'
                       || status === 'New')
                    {
                        component.set('v.disableReagendar', true);
                        component.set('v.disableCancelar', true);
                    }else{
                        component.set('v.disableReagendar', false);
                        component.set('v.disableCancelar', false);
                    }
                }else{
                    component.set('v.disableReagendar', true);
                    component.set('v.disableCancelar', true);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors[0] && errors[0].message){
                    console.log(errors[0].message);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    //URL para tela step de Reagendamento (colocar em custom label a url abaixo)
    getUrlReagendar : function(caseId){
        try{
            let url = $A.get('$Label.c.URL_Reagendar');
            url = url.replace('{0}', caseId).replace('{0}', caseId);
            return url;
        }catch(err){
            console.log(err);
        }
    },
    //URL para tela step de Cancelamento (colocar em custom label a url abaixo)
    getUrlCancelar : function(caseId){
        try{
            let url = $A.get('$Label.c.URL_Cancelar');
            url = url.replace('{0}', caseId).replace('{0}', caseId);
            return url;
        }catch(err){
            console.log(err);
        }
    }
})