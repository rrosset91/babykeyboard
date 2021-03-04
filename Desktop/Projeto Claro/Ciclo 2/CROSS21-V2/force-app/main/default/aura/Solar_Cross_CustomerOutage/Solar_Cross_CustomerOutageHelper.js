({
    helperMethod : function(component,event,helper) {
        var action = component.get('c.getOutages');
        action.setParams({
            recordId : component.get('v.recordId'),
            isResidential : component.get('v.isResidential')
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            var data = response.getReturnValue();

            if(state === 'SUCCESS'){
                if(data.success){
                    if(component.get('v.isResidential')){
                        if(data.outages !== undefined){
                            component.set('v.outages',data.outages);
                            component.set('v.outagesFirst',data.outagesFirst);
                            component.set('v.iconUsed',data.objimportantOut.iconUsed);
                            component.set('v.variantUsed',data.objimportantOut.variantIcon);
                            component.set('v.hasError',false);
                        }else{
                            component.set('v.iconUsed','utility:ban');
                            component.set('v.variantUsed','');
                            component.set('v.hasError',true);
                            component.set('v.messageError',data.message);
                        }
                    }else{
                        if(data.outage != null){
                            console.log('data.outage: ' + data.outage);
                            if(data.outage.isInOutage){
                                component.set('v.iconUsed', 'utility:clear');
                                component.set('v.variantUsed','error');
                                component.set('v.mobileOutageBol', true);
                                component.set('v.mobilePrevisionDate', data.outage.prevision);
                            }else{
                                component.set('v.iconUsed', 'utility:success');
                                component.set('v.variantUsed','success');
                                component.set('v.mobilePrevisionDate',data.prevision);
                            }
                        }else{
                            component.set('v.hasError',true);
                            component.set('v.messageError',data.message);
                        }
                    }
                }else{
                    component.set('v.iconUsed','utility:ban');
                    component.set('v.variantUsed','');
                    component.set('v.hasError',true);
                    component.set('v.messageError',data.message);
                }
                    
            }
        })
        $A.enqueueAction(action);
    },

    getContract : function(component,event,helper){
        console.log('Entrou no get contract')
        var action = component.get('c.getContractType');
        action.setParams({
            recordId : component.get('v.recordId')
        });

        action.setCallback(this,function(response){
            var state = response.getState();
            var data = response.getReturnValue();

            if(state === 'SUCCESS'){
                console.log('data bol returned',data);
                component.set('v.isResidential',data);
                this.helperMethod(component,event,helper);
            }
        })
        $A.enqueueAction(action);
    }
})