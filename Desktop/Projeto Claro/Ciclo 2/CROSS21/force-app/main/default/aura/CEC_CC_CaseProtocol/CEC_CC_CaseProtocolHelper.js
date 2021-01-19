({
    /* 27-01-2020 
     * Unidades de Negógio Claro DTH e NET geram protocolos no NETSMS
     * Unidade de Negócio Claro gera protocolo automático no PS8 na conclusão do caso
     * Unidade de Negócio Embratel gera somente protocolo maual
 	 */
    setTypeProtocol : function(component)
    {
        var newCase = component.get("v.case");
        var action = component.get("c.getTypeProtocol");        
        action.setParams({ objCase: newCase });
        action.setCallback(this, function(response)  {
			console.log(response.getReturnValue());
            if(response.getState() === 'SUCCESS') {
               component.set('v.typeProtocol', response.getReturnValue());
            }
        })
        $A.enqueueAction(action);        
        console.log('setTypeProtocol: ' + component.get('v.typeProtocol'));
    },

    fetchPicklist : function(component, objectType, selectedField)
    {      
        var action 			= component.get("c.getPicklistvalues");        
        var objectType 		= component.get("v.objectType");
        var selectedField 	= component.get("v.selectedField");
        
        action.setParams({ objectType: objectType, selectedField: selectedField, });
        
        action.setCallback(this, function(response)  {
            var state = response.getState();
            var listFlag = response.getReturnValue();
            component.set("v.picklistValues", listFlag);
            
            if(state === 'SUCCESS') {
                console.dir(result);
                var result = response.getReturnValue();
                var controllerField = [];
                
                if(result != undefined && result.length > 0) {
                    controllerField.push('Selecionar');    
                }
                
                for(var i =0; i < result.length; i++) {
                    controllerField.push(result[i]);        
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    getAutomaticProtocol : function(component, event, helper)
    {      
        //Geração de protocolo automático NETSMS
        var valueRecordId = component.get("v.recordId");   
        var newCase  	  = component.get("v.case");
            
        if(newCase.Status != null && newCase.Status.includes('Closed') || newCase.Status.includes('Encerrado')){
            this.methodModal("Geração de Protocolo", 'Não é possivel gerar protocolo para caso encerrado', 'error');
            return;
        }
        
        if(newCase.ContractMSISDN__c == null && newCase.Product__c != 'Sem produto'){
            this.methodModal("Geração de Protocolo", 'Contrato não preenchido!', 'warning');
            return;
        }
        
        if(newCase.LegacyProtocol__c != null){
            this.methodModal("Geração de Protocolo", 'Protocolo já existe!', 'warning');
            return;
        }
        
        if(newCase.ContractMSISDN__c != null && !newCase.ContractMSISDN__c.includes('/')){
            this.methodModal("Geração de Protocolo", 'Contrato inválido, é esperado o formato de contrato "XXX/XXXXXXXXX".', 'warning');
            return;
        }
        
        var action = component.get("c.GetProtocol");        
        action.setParams({ "objCase" : newCase }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") 
            {
                var result = response.getReturnValue(); 
                var msg = result[0].msgProtocol;
                var status = result[0].msgStatus;
                var title =	result[0].msgTitle;
                var protocolType = result[0].typeProtocol;

                console.log(status + ': '  + title + ' - ' + msg + '/' + protocolType);

                if(result != null && result.length > 0 && status == "success")
                {
                    component.set("v.listProtocol", result);    

                    if(result[0].msgStatus == "success" || result[1].msgStatus == "success"){
                        newCase.LegacyProtocol__c = result[1].protocolo;   
                    }    
                }
                else {
                    //Habilitar Opção de Procotolo manual
                    component.set('v.typeProtocol', protocolType);
                }

                this.methodModal(title, msg, status);
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal('', errors[0].message, 'info');
            }
            
        });
        $A.enqueueAction(action);
    },
    
    setManualProtocol : function(component, event, helper)
    {   
        //Geração de Protocolo Manual
        var valueRecordId = component.get("v.recordId"); 
        var valueProtocol = component.find("inputProtocol").get("v.value");
        var newCase  	  = component.get("v.case");
        
        if(newCase.Status != null && newCase.Status.includes('Closed') || newCase.Status.includes('Encerrado')){
            this.methodModal("Geração de Protocolo", 'Não é possivel gerar protocolo para caso encerrado', 'error');
            return;
        }

        var action = component.get("c.getProtocolSaveProcolCase");        
        action.setParams({ 'objCaseParameter' : newCase });  
        
        action.setCallback(this, function(response) {            
            var state = response.getState();

            if(state === "SUCCESS") {
                var result = response.getReturnValue(); 
                var title;
                var type;
                
                //Validação campo protocolo legado.
                if(valueProtocol == undefined || valueProtocol == ''){
                    title = 'O campo protocolo precisa ser preenchido!';                    
                    type = 'error';
                }else{
                    title = result[0].msgProtocol;
                    type = result[0].msgStatus;
                }         
                component.set("v.listProtocol", result);
                this.setTypeProtocol(component);
                this.methodModal(title, result, type);
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                var errors = response.getError();
                if (errors[0] && errors[0].message)
                    this.methodModal('Geração de Protocolo', errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    
    getProtocolLits : function(component)
    {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProtocolCase");        
        action.setParams({ arecordId: recordId });
        
        action.setCallback(this, function(response) {	
            var state = response.getState();  

            if(state === "SUCCESS") { 
                component.set("v.listProtocol", response.getReturnValue());
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError;
                if (errors[0] && errors[0].message) 
                    this.methodModal('', errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    
    getCase : function(component)
    {
        var action 	= component.get("c.GetCase");          
        action.setParams({ varCaseParameterId: component.get("v.recordId")});
        
        action.setCallback(this, function(response) {	
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") { 
                console.dir(result);
                component.set("v.case", result);
                this.setTypeProtocol(component);
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError
                if (errors[0] && errors[0].message) 
                    this.methodModal('', errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    methodModal : function(titleModal, messageModal, typeModal)
    {
        var modalEvent = $A.get("e.force:showToast");
        modalEvent.setParams({
            title: titleModal,
            message: messageModal,
            type: typeModal
        });
        modalEvent.fire(); 
    }
    
})