({
    getContractsActiveAsset : function(component, event, helper)
    {
        let action = component.get("c.getAssetsActive");
        action.setParams({ accountId: component.get("v.recordId") });
        action.setCallback(this, function(response)
        {
            let state = response.getState();
            if(state === "SUCCESS")
            {                
                let result = response.getReturnValue();
                let redirectIdAsset;
                

                if(result !== null)
                {

                   
                    for(let  i=0; i < result.length; i++)
                    {                        
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                        redirectIdAsset = result[i].id;
                        
                    }
                    component.set("v.assets", result); 
                    console.log('result: ' + JSON.stringify(result)); 
                    component.set("v.idAsset", redirectIdAsset); 
                    console.log('redirectIdAsset: ' + redirectIdAsset);
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
                }
                else if(result === null)
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

    formatMSISDN: function(msisdn)
    {        
        
        let inputValue = msisdn;
        if (msisdn) {
          var rep = msisdn.replace(/[^0-9]/g, "");
          var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
          inputValue = res.substring(0, 15);
          if (msisdn.length >= 11) {
            var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
            inputValue = res.substring(0, 15);
          }
        }        
        return inputValue;
    }    
});