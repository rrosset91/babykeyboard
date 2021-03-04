({
  setIcon: function(component) {
    var recordId = component.get("v.recordId");
    var varObjectApi = "Asset";
    if (recordId.startsWith("001")) {
      
      varObjectApi = "Account";
    }
    
    var action = component.get("c.getDataRecord");
    action.setParams({
      recordId: recordId,
      objectAPI: varObjectApi
    });

    action.setCallback(this, function(response)
    {
      var state = response.getState();
      
      if (state === "SUCCESS") 
      {
        var result = response.getReturnValue();

        if (varObjectApi === "Asset")
        {
            var result = response.getReturnValue(); 
            var recTypeName = result.recordTypeName;
           
            if (recTypeName.indexOf("Móvel") !== -1)
            {
              component.set("v.isMovel", true);
            }

            component.set("v.recordTypeName", recTypeName);

            if(recTypeName === 'Móvel Pré' || recTypeName === 'Móvel Pós' || recTypeName === 'Móvel Controle' || recTypeName === 'Móvel Banda Larga' )
            {
              let mobileFormat = this.formartMobilePhone(result.dataContract);
              component.set('v.contractData', mobileFormat);
              component.set("v.recordTypeName", recTypeName);
              console.log('mobileFormat: ' + mobileFormat);
              console.log('recTypeName: ' + recTypeName);
              console.log('Entrou aqui');
            }
        }
           else if(varObjectApi === "Account" )
           {
              component.set("v.recordTypeName", result.dataContract);
              component.set("v.isContract", true)
           } 
      }
    });
    $A.enqueueAction(action);
  },

  formartMobilePhone: function(dataContract)
  {
   
    dataContract = dataContract.replace(/\D/g, "");    
    dataContract= dataContract.replace(/^(\d{2})(\d)/g, "($1) $2");   
    dataContract = dataContract.replace(/(\d)(\d{4})$/, "$1-$2");

    return dataContract;
  },


  getAddresByAsset: function(component) {   
    var recordId = component.get("v.recordId");
    var varObjectApi = "Asset";

    if (recordId.startsWith("001")) {      
      varObjectApi = "Account";
    }

   
    var action = component.get("c.getAddress");
    action.setParams({
      recordId: component.get("v.recordId"),
      objectAPI: varObjectApi
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      
      if (state === "SUCCESS") 
      {
        var result = response.getReturnValue();
        let assetRecordtype = component.get('v.recordTypeName');
        console.log('assetRecordtype: ' + assetRecordtype);
        console.log('result: ' +JSON.stringify(result));

        if (result !== null && result.length > 0) 
        {
            var address = "";	
            var premises = result[0]["InstalledPremises__r"];
            console.log('result3: ' +JSON.stringify(premises));  
            
             if (premises == undefined) 
             {
              return;
               console.log('Entrou aqui premisses');
              }

              if(premises.vlocity_cmt__StreetAddress__c !== undefined && premises.vlocity_cmt__StreetAddress__c !== "")
              {
                address += premises.vlocity_cmt__StreetAddress__c;
              }

              if(premises.Complement__c !== undefined && premises.Complement__c !== "")
              {
                address += ", " + premises.Complement__c;
              }

              if (premises.vlocity_cmt__City__c !== undefined && premises.vlocity_cmt__City__c !== "")
              {
                address += " - " + premises.vlocity_cmt__City__c;
              }

              if(premises.vlocity_cmt__State__c !== undefined && premises.vlocity_cmt__State__c !== "")
              {
                address += "/" + premises.vlocity_cmt__State__c;
              }

              if (premises.vlocity_cmt__Country__c !== undefined && premises.vlocity_cmt__Country__c !== "")
              {
                address += " - " + premises.vlocity_cmt__Country__c;
              } 
              
              if(assetRecordtype === 'TV' || assetRecordtype === 'Fixo' || assetRecordtype === 'Internet Fixa' || varObjectApi === 'Account')
             {
                component.set("v.contractData", address);  
                console.log('address: ' + JSON.stringify(address));
             }    
        }
      }
    });
    $A.enqueueAction(action);
  }
});