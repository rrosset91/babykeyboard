({
    doInit : function(component, event, helper) {
        var actionProfile = component.get("c.getPermissionToEditConsents");
        actionProfile.setCallback(this, function(response) {
            component.set("v.isProfileWithEditPermission", response.getReturnValue());
        });
        $A.enqueueAction(actionProfile);
        
        var action = component.get("c.getConsents");
        var list = [];
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                //PROBABLY WE NEED TO CHANGE purposes[0] FOR SPECIFIC purpose FIND BY Id
                  if(response.getReturnValue().purposes != null &&
                   response.getReturnValue().purposes[0] != null &&
                   response.getReturnValue().purposes[0].agreements[0] != null &&
                   response.getReturnValue().purposes[0].agreements[0].id != '') {
                   
                    component.set('v.purposeId', response.getReturnValue().purposes[0].id);
                   
                    //console.log(response.getReturnValue().purposes[0].agreements);
                    list = response.getReturnValue().purposes[0].agreements;
                    if(response.getReturnValue().purposes[0].agreements[2].id == 'e807b97b-e77f-4886-aa52-f571ac04c938'){
                    list = list.splice(0, 2);
        }

                    // assign checked in consent node level according to OneTrust
                    for(var key in list){
                        // find option where label equals 'Sim'
                        var options = list[key].options;
                        for(var key2 in options){
                            if(list[key].options[key2].label === 'Sim'){
                                if(list[key].options[key2].checked === true){
                                    //console.log(list[key].name + ': CHECKED');
                                    list[key].checked = true;
                                }else{
                                    //console.log(list[key].name + ': NOT CHECKED');
                                    list[key].checked = false;
                                }
                            }
                        }
                    }
                    
                    //console.log('Consents Onload: ' + JSON.stringify(list));
                    component.set('v.consents', list);
                    //component.set('v.onloadConsents',JSON.stringify(list));
                    
                    // verify if all toggle buttons are checked to check the toggleAllButton
                    helper.verifyAllToggleValues(component, helper, list, true);
                    
                }else{
                    component.set('v.consents', null);
                    console.log("----->>>>> INTEGRATION ERROR");
                    if(response.getReturnValue().error){
                        console.log("ERRO: " + JSON.stringify(response.getReturnValue().error));
                    }
                }
            } else if (state === "ERROR") {
                component.set('v.consents', null);
                console.log("----->>>>> ERROR");
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    verifyIfCheckToggleAllButton:function(component,event,helper){
        var consents = component.get("v.consents");
        // verify if all toggle buttons are checked to check the toggleAllButton
        helper.verifyAllToggleValues(component, helper, consents, false);
    },
    
    getToggleAllButtonValue:function(component,event,helper){
        component.set("v.wasChanged", true);
        
        //console.log("getToggleAllButtonValue");
        var checkCmp = component.find("toggleAllButton").get("v.checked");

    	if(checkCmp === true){
            var consents = component.get("v.consents");
    		helper.setAllCheckboxesToChecked(component, helper, consents);
            component.find("toggleAllButton").set("v.disabled",true); 
		} else{
            component.find("toggleAllButton").set("v.disabled",false); 
 			//helper.setAllCheckboxesToUnchecked(component, helper);
		}
    },
    
    handleReloadTab : function(component, event, helper) {
        //try again: call OneTrust GET 
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    },
    
    handleSaveButton: function(component, event, helper) {
        //console.log("handleSaveButton");
        component.set("v.wasChanged",false);
        var consents = component.get("v.consents");
        
        var actionGetProtocol = component.get("c.getProtocolNumber");
        actionGetProtocol.setParams({
            recordId: component.get("v.recordId")
        });
        actionGetProtocol.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //get protocol number
                if(response.getReturnValue() != null && response.getReturnValue() != ''){
                    var protocolNumber = response.getReturnValue();
                    //console.log('PROTOCOLO: ' + protocolNumber);
                    
                    var jsonBody = '{"notes": "' + protocolNumber + '","origin": "Salesforce","agreements": [';
                    for(var key in consents){
                        
                        // just add ',' if there is more than one node of JSON to send
                        if(key>0){
                            jsonBody += ',';
                        }
                        
                        // find the Ids of yes and no to send in the PUT body
                        var yesId = '';
                        var noId = '';
                        for(var pos in consents[key].options){
                            if(consents[key].options[pos].label == 'Sim'){
                                yesId = consents[key].options[pos].id;
                            }
                            else if(consents[key].options[pos].label == 'Não'){
                                noId = consents[key].options[pos].id;
                            }
                        }
                        
                        jsonBody += '{"id":"' + consents[key].id + '",' + '"options":[{"id":';
                        
                        // If consent checked, send yes to Onetrust, otherwise send no
                        if(consents[key].checked){
                            jsonBody += '"' + yesId + '"';
                        }else{
                            jsonBody += '"' + noId + '"';
                        }
                        
                        jsonBody += '}]' + '}';
                        
                    }
                    jsonBody += ',{"id":"a1111111-1111-111b-a11b-111aa111111e","options": [{"id":"a1111111-1111-111b-a11b-111aa111111e"}]}';
                    jsonBody += ']}';
                    //console.log('jsonBody to be saved: ' + jsonBody);
                    
                    // call PUT to OneTrust
                    var action = component.get("c.saveConsents");
                    action.setParams({
                        recordId: component.get("v.recordId"),
                        jsonBody: jsonBody,
                        purposeId: component.get("v.purposeId")
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        
                        if(state === "SUCCESS") {
                            //console.log("----->>>>> SUCCESS");
                            //console.log('Resposta: ' + JSON.stringify(response.getReturnValue()));
                            
                            if(response.getReturnValue().error == null){
                                // Set wasChanged attribute to false
                                component.set("v.wasChanged",false);
                                
                                // Show success message
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    type: 'success',
                                    //title: '|o/',
                                    message: 'Dados salvos com sucesso!'
                                });
                                toastEvent.fire();
                            }else{
                                component.set("v.wasChanged",true);
                                console.log("----->>>>> INTEGRATION ERROR");
                                if(response.getReturnValue().error){
                                    console.log("ERRO: " + JSON.stringify(response.getReturnValue().error));
                                }
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    type: 'error',
                                    title: 'Ocorreu um erro ao salvar os dados!',
                                    message: 'Tente salvar novamente'
                                });
                                toastEvent.fire();
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
                                title: 'Ocorreu um erro ao salvar os dados!',
                                message: 'Tente salvar novamente'
                            });
                            toastEvent.fire();
                        }
                    });
            
                    // Some logic
                    $A.enqueueAction(action);
                    
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
  
    },
    
     onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId');
        //console.log("Tab closed: xxxx" +tabId );

        var msg ='Deseja salvar as alterações realizadas na aba consentimento da conta fechada?';
        
        var wasChanged = component.get("v.wasChanged");
        
        if(wasChanged == true){
        
            if (!confirm(msg)) {
                //console.log('NÃO');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'error',
                    //title: 'Alteraçoes canceladas!',
                    message: 'Alterações nos consentimentos da conta fechada foram perdidas'
                });
                toastEvent.fire();
                return false;
            } else {
                var a = component.get('c.handleSaveButton');
        		$A.enqueueAction(a);
            }
            
        }
         
    },
    
    handleCancelButton: function(component, event, helper) {
    	// Set isModalOpen attribute to true
    	component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
  
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.isModalOpen", false);
		//Logic to load previously saved statuses of the account
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
        // Set wasChanged attribute to false
        component.set("v.wasChanged",false);
    },
    
})