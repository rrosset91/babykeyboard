({
    verifyBatchJobsSameDay : function(component,event,helper){
        let action = component.get("c.verifyAssinc");
        console.log('Entrou no VerifyBatch')
        action.setCallback(this,function(response){

            let state = response.getState();
            if(state === "SUCCESS"){
                let ret = response.getReturnValue();
                console.log('ret' + ret);
                component.set("v.disableButton",ret);
            }else{
                
            }
        });

        $A.enqueueAction(action);
    },
    reprioritize : function(component, event, helper) {
        console.log('entrou aqui')
        let minDat = component.find("minDate");
        let maxDat = component.find("maxDate");
        let prior = component.find("prior");
        console.log('aaa:: ' + minDat.checkValidity());
        console.log('bbb:: ' + maxDat.checkValidity());
        let hasError = false;


        if(!minDat.get("v.value")){
            minDat.setCustomValidity("Necessário preencher uma data mínima");
            hasError = true;
        }else if(!minDat.checkValidity()){
            hasError = true;
        }else{
            minDat.setCustomValidity("");
        }
        if(!maxDat.get("v.value")){
            maxDat.setCustomValidity("Necessário preencher uma data máxima");            
            hasError = true;
        }else if(!maxDat.checkValidity()){
            hasError = true;
        }else{
            minDat.setCustomValidity("");
        }
        if(!prior.get("v.value")){
            prior.setCustomValidity("Necessário preencher uma prioridade");
            hasError = true;
        }else{
            prior.setCustomValidity("");
        }

        if(!hasError){
            console.log('error false')
            component.set("v.disableButton",true);
            let action = component.get("c.callBatchClass");

            action.setParams({
                "minDate":minDat.get("v.value"),
                "maxDate":maxDat.get("v.value"),
                "priority":prior.get("v.value")
            })
    
            action.setCallback(this,function(response){
                let state = response.getState();
                console.log('state: ',state);
                if(state ==="SUCCESS"){
                    console.log('Teste:  ');
                    this.showToast(component,event,helper);
                }else{
                    component.set("v.disableButton",false);
                }
            });
         
            $A.enqueueAction(action);
        }else{
            minDat.reportValidity('');
            maxDat.reportValidity('');
            prior.reportValidity('');
        }
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Requisição enviada!",
            "message": "A requisição foi enviada com sucesso.Você receberá um email com o status da solicitação.",
            "type" : "success"
        });
        toastEvent.fire();
    }
})