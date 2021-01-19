({
	executePost:function(component,helper,cpf,requestType,successMessageByRequestType,reason,cleanNotes){
        var caseId = '';
        var idDsar = '';
        var email        = component.find("email").get("v.value");
        var customerType = component.get("v.customerType");
        var userLogin    = component.get("v.userLogin");
		var dsarAdditFields = component.get("v.dsarAdditFields"); 
        
        if(customerType == ''){
            customerType = 'ASSINANTE_CLARO';
        }
        
        var actionGetProtocol = component.get("c.getProtocolNumber");
        actionGetProtocol.setParams({
            recordId: component.get("v.recordId"),
            requestType: requestType
        });
        actionGetProtocol.setCallback(this, function (response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                //get protocol number
                if(response.getReturnValue() != null && 
                   response.getReturnValue() != '')
                {
                    var protocolNumber = response.getReturnValue().protocol;
                    
                    //console.log('PROTOCOLO: ' + protocolNumber);
                    // Fixed Data
                    caseId = response.getReturnValue().caseId;
                    var jsonBody = '{"data": {"language":"en-us","subjectTypes": ["' + customerType + '"],';
                    // Customer Data and Request Type 
                    jsonBody += '"cpf":"' + cpf + '","email": "' + email + '","protocolNumber": "' + protocolNumber + '","requestTypes": ["' + requestType + '"],';
                    // Create Additional Data using dynamic metadata
                    jsonBody += '"webFormData": {';
                    for(var key in dsarAdditFields){
                        if(key>0){
                            jsonBody += ',';
                        }
                        console.log("rodolfo----->>>>> dsarAdditFields" + JSON.stringify(dsarAdditFields[key].fieldLabel__c));
                        jsonBody += '"' + dsarAdditFields[key].fieldLabel__c + '":';
                        // if field has a fixed value, set it in JSON
                        if(dsarAdditFields[key].fixedValue__c){
                            jsonBody += '"' + dsarAdditFields[key].fieldValue__c + '"';
                        }else{
                            //if field is dynamic, set the appropriate value according switch
                            switch(dsarAdditFields[key].DeveloperName) {
                                case "Notes":
                                    jsonBody += '"' + cleanNotes + '"';
                                    break;
                                case "UserLogin":
                                    jsonBody += '"' + userLogin + '"';
                                    break;
                                case "Reason":
                                    jsonBody += '"' + reason + '"';
                                    break;
                                default:
                                    jsonBody += '""';
                            }
                        }
                        
                    }
                    jsonBody += '}}}';
                    console.log('rodolfo debugg: ' + jsonBody);
                    // call POST to OneTrust
                    var actionPost = component.get("c.saveDsar");
                    actionPost.setParams({
                        jsonBody: jsonBody
                    });
                    actionPost.setCallback(this, function (response) {
                        var state = response.getState();
                        
                        if(state === "SUCCESS") {
                            //console.log("----->>>>> SUCCESS");
                            //console.log('Resposta: ' + JSON.stringify(response.getReturnValue()));
                            
                            if(response.getReturnValue().data != null){
                                idDsar = response.getReturnValue().data.requestQueueRefId;
                                
                                // Set wasChanged attribute to false
                                component.set("v.wasChanged",false);
                                
                                // Show success message
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    duration: 12000,
                                    type: 'success',
                                    message: successMessageByRequestType
                                });
                                toastEvent.fire();
                                
                                var isNotesVisible = component.get("v.isNotesVisible");
                                // Set Notes field blank 
                                if(isNotesVisible){
                                    component.find("notes").set("v.value",'');
                                }
                                
                                // Reload page
                                var a = component.get('c.doInit');
                                $A.enqueueAction(a);
                                
                                //UP id Onetrush in Case SF
                                var actionUpdateCase = component.get("c.updateIdCase");
                                actionUpdateCase.setParams({
                                    idDsar: idDsar,
                                    caseId: caseId
                                    
                                });
                                
                                $A.enqueueAction(actionUpdateCase);
                                
                            }else{
                                component.set("v.wasChanged",true);
                                var errorCode = '';
                                var errorMsg = '';
                                console.log("----->>>>> INTEGRATION ERROR");
                                if(response.getReturnValue().error){
                                    console.log("ERRO: " + JSON.stringify(response.getReturnValue().error));
                                    if(response.getReturnValue().error){
                                        errorCode = response.getReturnValue().error.httpCode;
                                        errorMsg = response.getReturnValue().error.detailedMessage;
                                    }
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        type: 'error',
                                        title: 'Ocorreu um erro ao enviar a solicitação. Erro da API: ' + errorCode + ' - ' + errorMsg,
                                        message: 'Tente salvar novamente'
                                    });
                                    toastEvent.fire();
                                }else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        type: 'error',
                                        title: 'Ocorreu um erro ao enviar a solicitação. Erro da API: Sem retorno da mensagem do detalhe do erro.',
                                        message: 'Tente salvar novamente'
                                    });
                                    toastEvent.fire();
                                }
                            }
                            
                        } else if (state === "ERROR") {
                            component.set("v.wasChanged",true);
                            console.log("----->>>>> ERROR");
                            var errors = response.getError();
                            if(errors) {
                                if(errors[0] && errors[0].message) {
                                    console.log("Error message: " + errors[0].message);
                                }
                            } else {
                                console.log("Unknown error");
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: 'error',
                                title: 'Ocorreu um erro ao enviar a solicitação.',
                                message: 'Tente salvar novamente'
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(actionPost);
                    
                    
                }else{
                    component.set("v.wasChanged",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'error',
                        title: 'Erro ao gerar o Número do Protocolo.',
                        message: 'Tente salvar novamente'
                    });
                    toastEvent.fire();
                }
            }else{
                component.set("v.wasChanged",true);
                console.log("----->>>>> ERROR");
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'error',
                    title: 'Ocorreu um erro ao obter o Número do Protocolo.',
                    message: 'Tente salvar novamente'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(actionGetProtocol);
	}
})