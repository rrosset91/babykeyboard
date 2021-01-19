({
    getContractsActive : function(component, event, helper)
    {
        console.log('Entrou aqui'); 
        let action = component.get("c.getContractsActive");
        action.setParams({ parentId: component.get("v.recordId") });
        action.setCallback(this, function(response)
        {
            let state = response.getState();
            if(state === "SUCCESS")
            {
                let result = response.getReturnValue();
                let redirectIdContrato;
                console.log('getContractsActive: ' + JSON.stringify(result));

                if( result !== null )
                {                
                    for (let i = 0; i < result.length; i++)
                    {                    
                        redirectIdContrato = result[i].id;
                    }

                    component.set("v.contracts", result);
                    //component.set("v.idContract", redirectIdContrato);
                    //console.log('redirectIdContrato: ' + redirectIdContrato);
                }else if(result === null)
                {
                    component.set("v.hasNoContract", true);
                    
                }        
                 
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                let errors = response.getError();
                let customMessagemErro;

                if (errors && errors[0] && errors[0].message)
                {                   
                    customMessagemErro = errors[0].message;
                }
            }
        });	
        $A.enqueueAction(action);
    },
    
    getContactPrimary : function(component, event, helper)
    {
        let action = component.get("c.getContactPrimary");
        action.setParams({ parentId: component.get("v.recordId") });
        action.setCallback(this, function(response)
        {
            let state = response.getState();
            let result = response.getReturnValue();                
            let redirectIdContact;
            if(state === "SUCCESS")
            {
                if( result !== null )
                {                    
                redirectIdContact = result.Id;
                component.set("v.idContact", redirectIdContact); 
                
                }else  if(result === null)
                {
                    console.log('Erro');
                }
               
                 
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                let errors = response.getError();
                let customMessagemErro;

                if (errors && errors[0] && errors[0].message)
                {                   
                    customMessagemErro = errors[0].message;
                }
            }
        });	
        $A.enqueueAction(action);
    },


    getCriticalChannels : function(component, event, helper)
    {    
        let action = component.get("c.getCriticalChannels");

        action.setCallback(this, function(response)
        {
            let state = response.getState();

            if(state === "SUCCESS")
            {
                component.set("v.isProfileCanalCritico", response.getReturnValue());
            }
            else if(state === "ERROR" || state === "INCOMPLETE" )
            {
                let errors = response.getError();
                let customMessagemErro;

                if(errors[0] && errors[0].message)
                {
                    customMessagemErro = errors[0].message;
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecordtype : function(component, event, helper)
    {    
        let action = component.get("c.getAvailableRecordTypeCase");

        action.setParams({"objectApiName": component.get('v.objType')}); 
        action.setCallback(this, function(response)
        {
            let state = response.getState();

            if(state === "SUCCESS")
            {                   
              let jsonObject = JSON.parse(response.getReturnValue());                
               component.set('v.recordTypeList', jsonObject); 
                 
            }
            else if(state === "ERROR" || state === "INCOMPLETE" )
            {
                let errors = response.getError();
                let customMessagemErro;
                
                if(errors[0] && errors[0].message)
                {
                    customMessagemErro = errors[0].message;
                }
            }
        });
        $A.enqueueAction(action);
    }, 
});