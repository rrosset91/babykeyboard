({
    doInit : function(component, event, helper) {
		component.set("v.isNotesVisible",false);
        
        var action = component.get("c.getCustomMetadatadsar");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set('v.dsar', response.getReturnValue());
            } else if (state === "ERROR") {
                component.set('v.dsar', null);
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
        
        var action2 = component.get("c.getCustomerData");
        action2.setParams({
            recordId: component.get("v.recordId")
        });
        action2.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //component.set('v.isEmailReadOnly',false);
                //console.log('Customer Data: '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null){
                    component.set('v.cpf', response.getReturnValue().DocumentNumber__c);
                    if(response.getReturnValue().Contacts != null &&
                       response.getReturnValue().Contacts[0] != null && 
                       response.getReturnValue().Contacts[0].Email != null &&
                       response.getReturnValue().Contacts[0].Email != ''){
                        component.set('v.email', response.getReturnValue().Contacts[0].Email);
                    } else if(response.getReturnValue().vlocity_cmt__BillingEmailAddress__c != null){
                        component.set('v.email', response.getReturnValue().vlocity_cmt__BillingEmailAddress__c);
                    }
                    if(response.getReturnValue().CustomerTypeList__c != null){
                        component.set('v.customerType', response.getReturnValue().CustomerTypeList__c);
                    }
                }
            }else{
                //component.set('v.isEmailReadOnly',false);
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.getCustomMetadataDsarAdditionalFields");
        action3.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('Resposta: ' + JSON.stringify(response.getReturnValue()));
                component.set('v.dsarAdditFields', response.getReturnValue());
            } else if (state === "ERROR") {
                component.set('v.dsarAdditFields', null);
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
        $A.enqueueAction(action3);
        
        var action4 = component.get("c.getUserName");
        action4.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.userLogin",'Não identificado');
            if(state === "SUCCESS") {
                //console.log('UserName: '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null && response.getReturnValue().FederationIdentifier != null){
                    component.set('v.userLogin', response.getReturnValue().FederationIdentifier);
                }
            }
        });
        $A.enqueueAction(action4);
        
    },
    
    handleReloadTab : function(component, event, helper) {
        //try again: call OneTrust GET 
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    },
    
    onSelection:function(component,event,helper){
        component.set("v.wasChanged", true);
        var dsar = component.get("v.dsar");
        var selected;
        /*= event.srcElement.value;
        component.set( "v.selection", event.srcElement.value );*/
        
        if (event.getSource) {
            // handling a framework component event
            selected = event.getSource(); // this is a Component object
            component.set("v.selection", selected.get("v.id"));
        } else {
            // handling a native browser event
            selected = event.target.id; // this is a DOM element
            component.set("v.selection", event.target.id);
        }
        console.log('event.srcElement.value: ' + event.srcElement.value);
        console.log('SELECTED: ' + selected);
        
        //find position of the list with the selected Id and update Notes Visibility
        for(var key in dsar){
            // Concatenate screenId as CPF + Id (necessary because we are using visual picker with Id, not a lightning:input with aura:id)
            var screenId = component.get("v.cpf") + dsar[key].rightId__c;
            if(screenId == selected){
                component.set("v.isNotesVisible",dsar[key].hasNotesVisibility__c);
                if(dsar[key].hasNotesVisibility__c){
                    var reasons = dsar[key].reasons__c;
                    //console.log("Reasons: " + reasons);
                    component.set('v.options', JSON.parse(reasons));
                    // set default value
                    component.set('v.selectedValue', '');
                }
                break;
            }
        }
        
    },
    
    handleSaveButton: function(component, event, helper) {

        //Group all the fields ids into a JS array
        var controlAuraIds = [].concat(component.find('email'));
       	
        var isNotesVisible = component.get("v.isNotesVisible");
        var notes = '';
        var reason = '';
        if(isNotesVisible){
            controlAuraIds.push(component.find('notes'));
        	notes  = component.find("notes").get("v.value");
            var reasonObj = component.get("v.options")[component.get("v.selectedValue")];
            if(JSON.stringify(reasonObj) != ""){
                reason = reasonObj.label;
            }
            // component.find("reason").get("v.text");
        }

        // Validate Email field
       	var allValid = controlAuraIds.reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(isNotesVisible){
            var reasonSelect = component.find("reason").get("v.value");
            if(reasonSelect == "" || reasonSelect == undefined || reasonSelect == null) {
                allValid = false;
            }
        }
        
        if (!allValid) {
            alert('Por favor, revise os campos obrigatórios para a solicitação.');
            return;
        }
        
        // disable save button 
        component.set("v.wasChanged",false);
        
        var cpf       = component.get("v.cpf");
        var dsar      = component.get("v.dsar");
        var selection = component.get("v.selection");
        
        var cleanNotes = '';
        if(notes != undefined && notes != ''){
            // Clear invalid characters Of Notes field
            let searchRegex = new RegExp('[\'"<>&*\]', 'g');
            cleanNotes = notes.replace(searchRegex,'');
    	}
        
        var requestType = '';
        var successMessageByRequestType = '';
        var callGetBeforePost = false;
        //find position of the list with the selected Id and update Notes Visibility
        for(var key in dsar){
            // Concatenate screenId as CPF + Id (necessary because we are using visual picker with Id, not a lightning:input with aura:id)
            var screenId = cpf + dsar[key].rightId__c;
            if(screenId == selection){
                requestType = dsar[key].DeveloperName;
                successMessageByRequestType = dsar[key].screenSuccessMessage__c;
                callGetBeforePost = dsar[key].isRecordUnique__c;
                break;
            }
        }

        if(callGetBeforePost){
            var actionGet = component.get("c.getDsarByType");
            actionGet.setParams({
                recordId: component.get("v.recordId"),
                requestType: requestType
            });
            actionGet.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state: '+state);
                if(state === "SUCCESS") {
                    //O teste acima afirma que existe solicitações em Aberto ou Pendente
                    //console.log("RESPOSTA GET :" + JSON.stringify(response.getReturnValue()));
                    // if the get returns one or more results, show popup
                    //console.log('customerOrders: '+response.getReturnValue().customerOrders[0]);
                    if(response.getReturnValue().customerOrders != null && 
                       response.getReturnValue().customerOrders[0] != null){
                        var canOpen = true;       
                        for (var key in response.getReturnValue().customerOrders){
                            //console.log('orderType: '+response.getReturnValue().customerOrders[key].orderType);
                            //console.log('subjectType: '+response.getReturnValue().customerOrders[key].subjectType[0]);
                            if (response.getReturnValue().customerOrders[key].orderType == requestType 
                                && response.getReturnValue().customerOrders[key].subjectType[0] === "ASSINANTE_CLARO"){
                             	canOpen = false;   
                                break;
                            }
                        }
                        
                        if (canOpen){
                            // Create protocol and execute POST to OneTrust
                            helper.executePost(component, helper, cpf, requestType, successMessageByRequestType, reason, cleanNotes);                                
                        }else{                            
                            component.set("v.wasChanged",true);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                duration: 7000,
                                type: 'error',
                                title: 'Existe uma solicitação pelo mesmo motivo em tratamento.',
                                message: 'Número da solicitação: ' + response.getReturnValue().customerOrders[0].id + ' - Status: ' + response.getReturnValue().customerOrders[0].status
                            });
                            toastEvent.fire();
                        }
                    }else{
                        var errorCode = '';
                        var errorMsg = '';
                        if(response.getReturnValue().error){
                            console.log("----->>>>> INTEGRATION ERROR");
                            console.log("ERRO no GET antes de executar POST: " + JSON.stringify(response.getReturnValue().error));
                            component.set("v.wasChanged",true);
                            if(response.getReturnValue().error[0]){
                                errorCode = response.getReturnValue().error[0].httpCode;
                                errorMsg = response.getReturnValue().error[0].detailedMessage;
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: 'error',
                                title: 'Erro ao verificar se existe solicitação em tratamento. Erro da API de GET: ' + errorCode + ' - ' + errorMsg,
                                message: 'Tente salvar novamente'
                            });
                            toastEvent.fire();
                        } else{
                            // Create protocol and execute POST to OneTrust
							helper.executePost(component, helper, cpf, requestType, successMessageByRequestType, reason, cleanNotes);
                        }
                    }
                }else if (state === "ERROR") {
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
                        title: 'Ocorreu um erro ao verificar se há solicitação em aberto para este tipo.',
                        message: 'Tente salvar novamente'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(actionGet);
        }else{
            // if request type don't need to be unique, call function to create protocol and execute POST without searching for not closed requests of the same type
            helper.executePost(component, helper, cpf, requestType, successMessageByRequestType, reason, cleanNotes);
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
        var isNotesVisible = component.get("v.isNotesVisible");
        if(isNotesVisible){
        	component.find("notes").set("v.value",'');
        }
		// Reload page
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
        // Set wasChanged attribute to false
        component.set("v.wasChanged",false);
    },

})