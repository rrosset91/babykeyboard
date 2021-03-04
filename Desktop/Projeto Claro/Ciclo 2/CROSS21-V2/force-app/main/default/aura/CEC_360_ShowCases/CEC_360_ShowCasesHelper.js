({
    setDates: function(component, event, helper) 
    {
        var action 	= component.get("c.getDates");   
        action.setCallback(this, function(response) {	
            var state = response.getState();
            if(state === "SUCCESS"){   
                var result = response.getReturnValue(); 
                console.log(result);
                component.set("v.endDate", result.endDate);
                component.set("v.startDate", result.startDate);       
                component.set("v.minDate", result.minDate);
                component.set("v.maxDate", result.maxDate);                
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.enqueueAction(action);
    },
    
    getPicklistValueByLabel: function(component, event, helper)
    {
        var action 	= component.get("c.getPicklistValueByLabel");   
        action.setParams({ varObject: "Case", varField: "Status"});
        action.setCallback(this, function(response) {	
            var state = response.getState();
            if(state === "SUCCESS"){               
				//bind the information to the selection option
                var lstStatusCase = [];
                var options = response.getReturnValue();
                for(var option in options){
                    lstStatusCase.push({label: options[option], value: option});
                }
                component.set("v.lstStatusCase", lstStatusCase);                
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.enqueueAction(action);
    },

    setIsMobile: function(component) {
        console.log('Entrou na setIsMobile:');
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
        action.setCallback(this, function(response) {
          let state = response.getState();
          let result = response.getReturnValue();
          
          if (state === "SUCCESS")
          {           
            if (varObjectApi == "Asset") {
                //var result = response.getReturnValue();                 
                component.set("v.isMobile", false);
                component.set("v.hasValue", true);
                
            } else if (varObjectApi == "Account")
            {
                if(result.businessUnit === 'Net')
                {               
                    component.set("v.isMobile", false);
                    component.set("v.hasValue", true);
                    console.log('result: ' + result);
                } 
                else if(result.businessUnit === 'Claro')
                {
                    component.set("v.isMobile", true);
                    this.getAssetsNumberFromContract(component);
                }
            }
          }
        });
        $A.enqueueAction(action);
      },

    setCase: function(component) {
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
    
        action.setCallback(this, function(response) {
          var state = response.getState();
          
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (varObjectApi === "Asset") {
              var result = response.getReturnValue(); 
                this.getCasesAsset(component, event);               
            } else if (varObjectApi === "Account") {               
                this.getCasesContract(component, event);                
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

                if(errors[0] && errors[0].message)
                {
                    this.methodModal(errors[0].message, 'info', '');
                }
            }
        });
        $A.enqueueAction(action);
    },

    /*setCaseType: function(component, event, helper) 
    {
        var action = component.get("c.getContracBusinessUnit");
        action.setParams({ contractId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Retorno setCaseType:  ' + result);
                if (result === 'Net')
                {
                    component.set("v.isMobile",false);

                } else if(result === 'Claro')
                {
                    component.set("v.isMobile",true);
                    this.getAssetsNumberFromContract(component);
                } 
            }
        });
        
        $A.enqueueAction(action);
    },*/
    
    getAssetsNumberFromContract: function(component) {
        var listOptions = [];
        var action = component.get("c.getAssetsByBillingAccount");
        action.setParams({
            billingAcountId : component.get("v.recordId")
            
        });
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();            
            var state = response.getState();
            component.set("v.isSearch", false);
            console.dir(result);
            
            if (result.length != null && result.length > 0) {
                for (let i = 0; i < result.length; i++) {
                    let choice = { 
                        label: this.formatMSISDN(result[i]),
                        value: result[i]
                    }
                    listOptions.push(choice);
                }
                component.set("v.options", listOptions);
            }else {
                this.methodModal("", "Error", "Não há protocolos para o período selecionado.");
            }
            
        });
        $A.enqueueAction(action);
    },   
    
    
    getCasesContract : function(component, event, helper)
    {
        console.log('getCasesContract');
        console.log(component.find("statusCase").get("v.value"));
        console.log(component.find("endDate").get("v.value"))
        console.log(component.find("startDate").get("v.value"))
        
        var action = component.get("c.getCasesContract");
        action.setParams({
            parentId: component.get("v.recordId"),
            dataIni: component.find("startDate").get("v.value"),
            dataFim: component.find("endDate").get("v.value"),
            status: component.find("statusCase").get("v.value")
            
        });

        action.setCallback(this, function(response)
        {
            component.set("v.hasCases",false);
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                console.log(result);
                /* Resolução da DDP 130451
                 * Desenvolvedor: João Pedro Galvão - joao.lima@sysmap.com.br */
                for(var i = 0;i<result.length;i++){
                    if(result[i].description != undefined){
                        var shortDesc;
                        if(result[i].description.length > 100){        
                            shortDesc = result[i].description.substring(0,70) + '...';
                        	console.log('shortDesc=>'+shortDesc);
                        }else{
                            shortDesc = result[i].description;
                        }
                        result[i].shortDesc = shortDesc;
                    }else{
                        var shortDesc = " ";
                        result[i].shortDesc = shortDesc;
                    }
                }
				/**************************************************************/                
                component.set("v.lstCases", result);
                console.log(result.length);
                component.set("v.showTable", true);
                
                if(result.length == 0){
                    component.set("v.showTable", false);
                    this.methodModal('Nenhum resultado encontrado', 'error', 'Erro!');
                }
            }else
            {
                let errors = response.getError();
                let mensagem = "Unknown error";
                if (errors && errors[0] && errors[0].message)
                {                   
                    mensagem = errors[0].message;
                } else {
                    console.log("Unknown error");
                }
                
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "",
                    "type": "ERROR",
                    "message": mensagem
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
        
    },  



    getCasesAsset : function(component, event, helper)
    {
        console.log('getCasesAsset');
        console.log(component.find("statusCase").get("v.value"));
        console.log(component.find("endDate").get("v.value"))
        console.log(component.find("startDate").get("v.value"))
        
        var action = component.get("c.getCasesAsset");
        action.setParams({
            parentId: component.get("v.recordId"),
            dataIni: component.find("startDate").get("v.value"),
            dataFim: component.find("endDate").get("v.value"),
            status: component.find("statusCase").get("v.value")
            
        });
        
        
        console.log('recordId:' + component.get("v.recordId"))

        action.setCallback(this, function(response) {
            component.set("v.hasCases",false);
            
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.lstCases", result);
                console.log(result.length);
                component.set("v.showTable", true);
                
                if(result.length == 0){
                    component.set("v.showTable", false);
                    this.methodModal('Nenhum resultado encontrado', 'error', 'Erro!');
                }
            }else
            {
                let errors = response.getError();
                let mensagem = "Unknown error";
                if (errors && errors[0] && errors[0].message)
                {                   
                    mensagem = errors[0].message;
                } else {
                    console.log("Unknown error");
                }
                
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "",
                    "type": "ERROR",
                    "message": mensagem
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);        
    },  
    
    formatMSISDN: function(msi)
    {
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
    

    methodModal : function(message, type, title)
    {
        var modalEvent = $A.get("e.force:showToast");
        modalEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        modalEvent.fire(); 
    },
})