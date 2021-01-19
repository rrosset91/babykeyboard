({
    doInit : function(component) { 
        var actGetRoleAndProfile = component.get("c.getRoleAndProfile");
        
        actGetRoleAndProfile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                console.log('teste response ' + response.getReturnValue());
                var r = JSON.parse(response.getReturnValue());
                component.set("v.profileName", r.profileName);
                component.set("v.cpcRole", r.cpcRole);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        var actGetSObject = component.get("c.getSObject");
        actGetSObject.setParams({ 
            recordId : component.get("v.recordId"), 
            sObjectName : "Order"
        });
        
        actGetSObject.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set("v.record", response.getReturnValue());
                component.set("v.orderStatus", response.getReturnValue().Status);
                component.set("v.newEmail", response.getReturnValue().Account.Email__c);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        var actGetOptions = component.get("c.getPicklistOptions");
        
        actGetOptions.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") { 
                
                var res = response.getReturnValue();
                var lstSubStatus = [];
                lstSubStatus.push({label:"-- Nenhum --", text:null});
                
                for(var key in res) { 
                    
                    for(var value in res[key]) { 
                        
                        if(key === 'SubStatus__c') { 
                            lstSubStatus.push({label:res[key][value], text:res[key][value]});
                        }                       
                    }
                    
                }
                component.set("v.lstSubStatus", lstSubStatus);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });        
        
        $A.enqueueAction(actGetSObject);
        $A.enqueueAction(actGetRoleAndProfile);
        $A.enqueueAction(actGetOptions);
        
    }, 
    
    backofficeUser : function (cmp){
        var backoffice = cmp.get("c.isBackofficeUser");
        backoffice.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                cmp.set("v.isBackoffice", response.getReturnValue());                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(backoffice);  
    },
    
    validateBackoffice : function(component) { 
        
        var actChangeStatus = component.get("c.changeStatusBackOffice");
        actChangeStatus.setParams({ 
            recordId : component.get("v.recordId")
        });
        
        actChangeStatus.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.orderStatus", response.getReturnValue());
                var evtPath = $A.get("e.c:EvtPath");
                evtPath.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(actChangeStatus);  
    }, 
    
    setStatus : function(component) {
        if(component.get("v.orderStatus") == 'Pré Analise'){
            this.changeOrderStatus(component, "Aguardando Assinatura");
        } else {
            this.changeOrderStatus(component, "Documentação Aprovada");       
        }
    }, 
    
    closeOrder : function(component) {
        var deleteContDocNCompAction = component.get("c.deleteContDocNComp");
        deleteContDocNCompAction.setParams({
            'recordId': component.get("v.recordId")
        });
        
        deleteContDocNCompAction.setCallback(this, $A.getCallback(function(response) {
            
            if(response.getState() === "SUCCESS") {
                var action = component.get("c.closeOrder");
                action.setParams({
                    'recordId': component.get("v.recordId")
                });
                
                action.setCallback(this, $A.getCallback(function(response) {
                    if (response.getState() === "SUCCESS") {
                        component.set("v.message", response.getReturnValue());
                        var returnMessage = component.get("v.message");
                        if(returnMessage.length == 0) {
                            var actGetStatus = component.get("c.getSObject");
                            actGetStatus.setParams({ 
                                recordId : component.get("v.recordId"), 
                                sObjectName : "Order"
                            });
                            
                            actGetStatus.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") { 
                                    component.set("v.orderStatus", response.getReturnValue().Status);
                                    component.set("v.record", response.getReturnValue());
                                }
                            });
                            
                            var evtPath = $A.get("e.c:EvtPath");
                            evtPath.fire();
                            $A.get('e.force:refreshView').fire();
                            $A.enqueueAction(actGetStatus);
                        }
                    } else {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.showToast('error', "Error message: " + 
                                               errors[0].message);
                            }
                        } else {
                            this.showToast('error', "Unknown error");
                        }
                        component.set("v.realizandoInput",false);
                    }
                    
                    
                }));
                $A.enqueueAction(action);  
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast('error', "Error message: " + 
                                       errors[0].message);
                    }
                } else {
                    this.showToast('error', "Unknown error");
                }
            }
        }));
        $A.enqueueAction(deleteContDocNCompAction);  
    }, 
    
    setSubStatus : function(component) { 
        if(component.get("v.orderStatus") == 'Pré Analise'){
            this.changeOrderStatus(component, "Devolvido");
        } else {
            this.changeOrderStatus(component, "Documentação Devolvida");
        }
    }, 
    
    closeSubStatus : function(component) { 
        
        var actChangeSubStatus = component.get("c.changeSubStatus");
        actChangeSubStatus.setParams({ 
            recordId : component.get("v.recordId"), 
            subStatus : document.getElementById("select-01").value, 
            complemento : document.getElementById("textarea-id-01").value
        });
        
        actChangeSubStatus.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(actChangeSubStatus);        
        
    }, 
    
    callIntegRemoveSigners : function(component) { 
        var actcallRemoveSigners = component.get("c.callRemoveSigners");
        
        actcallRemoveSigners.setParams({ 
            recordId : component.get("v.recordId")
        });
        
        actcallRemoveSigners.setCallback(this, function(response){
           
            var state = response.getState();
            
            if(state === 'SUCCESS') {
                
                var result = response.getReturnValue();
                
                if(result.isError) {
                    this.showToast('error', result.message);
                } else {
                    if(result.message !== '') {
                        this.showToast('success', result.message);
                    }
                    this.changeOrderStatus(component, "Documentação Aprovada");
                }
                
            } else if (state === "ERROR") {
                this.showToast('error', 'Falha ao aprovar pedido.');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    this.showToast('error', 'Falha ao aprovar pedido.');
                    console.log("Unknown error");
                }
            } else {
                console.log('Error Unknown');
            } 
        });
        
        $A.enqueueAction(actcallRemoveSigners);
        
    },
    
    changeOrderStatus : function(component, status) { 

        
        var actChangeStatus = component.get("c.changeStatus");
        actChangeStatus.setParams({ 
            recordId : component.get("v.recordId"), 
            status : status
        });
        
        actChangeStatus.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                
                component.set("v.orderStatus", status);
                var evtPath = $A.get("e.c:EvtPath");
                evtPath.fire();
                this.showToast('success', 'Status do pedido alterado com sucesso!');
                $A.get('e.force:refreshView').fire();
                
            } else if (state === "ERROR") {
                this.showToast('error', 'Falha ao alterar status do pedido.');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    this.showToast('error', 'Falha ao alterar status do pedido.');
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(actChangeStatus);
        
    },
    
    checkAndSendToDocusign : function(component) {
        
        var checkIntegrationMethod = component.get('c.isIntegrationEnabled');
        
        checkIntegrationMethod.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var integrationSwitch = response.getReturnValue();
                
                if(integrationSwitch.isIntegracaoAtiva__c) {
                    this.setIntegrationMethod(component);
                } else {
                    this.showToast('error', integrationSwitch.Mensagem__c);
                }
                
            }
            
            else {
                console.log('error at fetching custom setting \'Desabilitar RPA\' from apex: ' + response.getError());
            }
            
        });
        
        $A.enqueueAction(checkIntegrationMethod);
        
    },
    
    setIntegrationMethod : function(component) {
        
        var getFlowAction = component.get('c.getIntegrationFlow');
        
        getFlowAction.setCallback(this, function(response) {
            
            var state = response.getState();

            if(state === "SUCCESS") {
                
                var integrationFlow = response.getReturnValue();                    
                this.sendToDocusign(component, integrationFlow);

                
            } else if(state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

            }
            
        });
        
        $A.enqueueAction(getFlowAction);
        
    },
    
    sendToDocusign : function(component, integrationFlow) {
        
        var action = component.get('c.openEnvelope');
        console.log('intEmbedded: ' + integrationFlow.isEmbedded__c);
        
        action.setParams({
            orderId : component.get('v.recordId'),
            isSigningRequired: integrationFlow.isSigningRequired__c,
            isEmbedded: integrationFlow.isEmbedded__c,
            accountId: integrationFlow.AccountId__c,
            templateId: integrationFlow.TemplateId__c
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                
                if(result.isError) {

                    this.showToast('error', result.message);

                } else {
                    component.set("v.orderStatus", result.statusOrder);
                    console.log('urlEmbedded: ' + result.urlEmbedded);
                    if(typeof result.urlEmbedded !== 'undefined') {

                        // Utilizar sistema embarcado
                        // fazer request para obter url do sistema, e executar o código abaixo no callback
                        var openEmbeddedSysComponentEvent = $A.get("e.force:navigateToComponent");
                        
                        openEmbeddedSysComponentEvent.setParams({
                            componentDef: "c:CEC_PME_EmbeddedSignatureSystem",
                            componentAttributes: { url: result.urlEmbedded }
                        });
                        
                        openEmbeddedSysComponentEvent.fire();
                        

                    } else {
                        this.showToast('success', result.message);
                    }
                }

                this.toggleButton('btnAssinar');
                $A.get('e.force:refreshView').fire();
                
            } else if(state === "ERROR") {
                console.log('ERROR at sending to DocuSign: ');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

                this.toggleButton('btnAssinar');
                this.showToast('error', 'Erro no processo de assinatura. Por favor reenviar!.');
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    checkAndReSendEnvelope : function(component) {
        /*
        var checkIntegrationMethod = component.get('c.isIntegrationEnabled');
        
        checkIntegrationMethod.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var integrationSwitch = response.getReturnValue();
                
                if(integrationSwitch.isIntegracaoAtiva__c) {
                    this.setIntegrationMethod(component);
                } else {
                    this.closeAlterEmailModal(component);
                    this.showToast('error', integrationSwitch.Mensagem__c);
                }
                
            }
            
            else {
                this.closeAlterEmailModal(component);
                this.showToast('error', 'Não foi possível enviar o documento.');
                console.log('error at fetching custom setting \'Desabilitar RPA\' from apex: ' + response.getError());
            }
            
        });
        
        $A.enqueueAction(checkIntegrationMethod);
        */
    },
    
    
    
    reSendEnvelope : function(component) {
        console.log('helper reSendEnvelope');
        component.set("v.isReSendEnvelope", true);
        
        var action = component.get('c.reSendDocusignEnvelope');
        var signers = JSON.stringify(component.get('v.contactsTableData'));
        var recordId = component.get("v.record.Id");
        console.log(signers);
        console.log(recordId);
        action.setParams({
            signers : signers,
            orderId : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                component.set('v.showAlterEmailModal', false);
                this.showToast('success', 'Envelope reenviado com sucesso');
                this.closeAlterEmailModal(component);
            } else {
                this.closeAlterEmailModal(component);
                this.showToast('error', 'Erro: ' + response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
        //$A.get('e.force:refreshView').fire();
                /*
        var action = component.get('c.reSendEnvelope');
        
        action.setParams({
            signers : component.get('v.contactsTableData'),
            orderId : component.get('v.recordId'),
            isSigningRequired: integrationFlow.isSigningRequired__c,
            accountId: integrationFlow.AccountId__c,
            templateId: integrationFlow.TemplateId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                
                console.log('result.isError (reenvio): ' + result.isError);
                
                if(result.isError) {
                    this.showToast('error', result.message);
                } else {
                    this.showToast('success', result.message);
                }
                
                this.closeAlterEmailModal(component);
                $A.get('e.force:refreshView').fire();
                
            } else {
                this.closeAlterEmailModal(component);
                this.showToast('error', 'Erro no processo de assinatura. Por favor reenviar!.');
                console.log('ERROR at sending to DocuSign: ' + response.getError());
            }
            
        });
        
        $A.enqueueAction(action);
        */
    },
    
    showTerritoryAssociation : function(component) {
        var action = component.get('c.getListTerritorysRadios');
        action.setParams({
            orderId : component.get("v.record.Id")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                component.set('v.isShowTerritoryAssociationModal', true);
                
                var list = JSON.parse(response.getReturnValue());
                component.set("v.optionsTerritory", list);
            } else {
                this.showToast('error', 'Erro: ' + response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    salveTerritory : function(component) {
        var action = component.get('c.updateAccountTerritory');
        
        action.setParams({
            orderId : component.get("v.record.Id"),
            territoryId : component.get("v.valueTerritory"),
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.isShowTerritoryAssociationModal", false);
                this.showToast("success", "Território associado com sucesso!");
                this.changeOrderStatus(component, "Território Associado");
                
            } else {
                this.showToast('error', 'Erro: ' + response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showAlterEmailModal : function(component) {
        
        var getContactsAction = component.get('c.getSignatureContacts');
        
        getContactsAction.setParams({
            orderId : component.get("v.record.Id")
        });
        
        getContactsAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var tableData = [];
                console.log(JSON.parse(response.getReturnValue()));
                
                //component.set('v.signatureContacts', response.getReturnValue());
                var list = JSON.parse(response.getReturnValue()); // component.get('v.signatureContacts');
                console.log(list);
                for(var i = 0; i < list.length; ++i) {
                    var contact = list[i];
                    var tableRow = {
                        Id: contact.recipientId + '-' + i,
                        clientId: contact.recipientId,
                        clientName:  contact.name,
                        clientEmail: contact.email
                    };
                    tableData.push(tableRow);
                }
                console.log(tableData);
                component.set('v.contactsTableData', tableData);
                component.set('v.selectedContact', list[0]);
                component.set('v.showAlterEmailModal', true);
                
            } else {
                // this.showErrorMsgToast(component);
                this.closeAlterEmailModal(component);
                this.showToast('error', 'Erro: ' + response.getError()[0].message);
            }
            
        });
        
        $A.enqueueAction(getContactsAction);
        
    },
    
    
    
    saveTableData : function(component, draftValues) {
        
        /*var updateEmailsAction = component.get('c.updateAccountContactRelationEmail');
        
        var contacts = component.get('v.signatureContacts');
        
        for(var i = 0; i < draftValues.length; ++i) {
            var currentId = draftValues[i].Id.split('-')[0];
            for(var j = 0; j < contacts.length; ++j) {
                if(contacts[j].Id == currentId) {
                    contacts[j].Email__c = draftValues[i].clientEmail;    
                }
            }
        }
        
        component.set('v.signatureContacts', contacts);
        
        var tableData = [];
        for(var i = 0; i < draftValues.length; ++i) {
            var contact = contacts[i];
            var tableRow = {
                clientId: contact.Id,
                clientName:  contact.name,
                clientEmail: contact.email
            };
            tableData.push(tableRow);
        }*/
        var contactsTableData = component.get('v.contactsTableData');
        console.log(draftValues);
        console.log(contactsTableData);
        
        for(var i = 0; i < draftValues.length; ++i) {
            var draftValue = draftValues[i];
            console.log(draftValue);
            for(var j = 0; j < contactsTableData.length; ++j) {
                var contactTableData = contactsTableData[j];
                console.log(contactTableData);
                if(contactTableData.Id == draftValue.Id) {
                    console.log('aqui');
                    contactTableData.clientEmail = draftValue.clientEmail;
                }
            }
        }
        console.log(contactsTableData);
        component.set("v.draftValues", []);
        component.set("v.contactsTableData", contactsTableData);
        
        
        
        //this.showToast('success', response.getReturnValue());
        
        
        /*
        updateEmailsAction.setParams({
            relations: component.get('v.signatureContacts')
        });
        
        updateEmailsAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                component.set('v.contactsTableData', tableData);
                this.showToast('success', response.getReturnValue());
                component.find("emailTable").set("v.draftValues", null);
                
            } else {
                console.log('Error at updating emails: ' + response.getError());
                this.showToast('error', response.getReturnValue());
            }
            
        });
        
        $A.enqueueAction(updateEmailsAction);
        */
    },
    
    isEmailValid : function(component, email) {
        
        if(email.length > 20) {
            var emailForm = component.find('email-form');
            $A.util.addClass(emailForm, 'slds-has-error');
            var errorMsg = component.find('email-input-error');
            component.set('v.emailErrorMsg', 'O email não deve conter além de 20 caracteres.');
            $A.util.removeClass(errorMsg, 'slds-hide');
            component.set('v.emailIsValid', false);
            return false;
        }
        else if(email.length == 0) {
            var emailForm = component.find('email-form');
            $A.util.addClass(emailForm, 'slds-has-error');
            var errorMsg = component.find('email-input-error');
            component.set('v.emailErrorMsg', 'O campo de email deve estar preenchido.');
            $A.util.removeClass(errorMsg, 'slds-hide');
            component.set('v.emailIsValid', false);
            return false;
        }
            else {
                var emailForm = component.find('email-form');
                $A.util.removeClass(emailForm, 'slds-has-error');
                var errorMsg = component.find('email-input-error');
                $A.util.addClass(errorMsg, 'slds-hide');
                component.set('v.newEmail', email);
                component.set('v.emailIsValid', true);
                return true;
            }
        
    },
    
    closeAlterEmailModal : function(component) {
        
        this.toggleButton('btnReenviar');
        component.set("v.showAlterEmailModal", false);
        
    },
    
    showToast : function(type, message) {
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "type" : type,
            "title": message,
            "message" : ' '
        });
        
        toastEvent.fire();
        
    },
    
    updateEmail : function(component) {
        
        var updateEmailAction = component.get("c.updateAccountEmail");
        
        var newEmail = component.get("v.newEmail");
        var account = component.get("v.record.Account")
        
        updateEmailAction.setParams({
            accountId : account.Id,
            newEmail : newEmail
        });
        
        updateEmailAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                this.closeAlterEmailModal(component);
                //this.sendToDocusign();
            } else {
                console.log('ERROR at updating the account\'s email: ' + response.getError());
            }
            
        });
        
        $A.enqueueAction(updateEmailAction);
        
    },
    
    createContractCall : function(component){
        
        var action = component.get("c.createContractService")
        action.setParams({
            "idPedido" : component.get("v.recordId")
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
                
                var varResponse = response.getReturnValue();
                
                //***** Resposta MOCK - CASO DE SUCESSO *****
                //var response = '{"apiVersion":"1;2018-12-17","transactionId":"Id-12312414231","data":{"salesDocuments":[{"documentId":"1234567","documentName":"venda34282843.pdf","content":"Um9vbXMgb2ggZnVsbHkgdGFrZW4gYnkgd29yc2UgZG8uIFBvaW50cyBhZnJhaWQgYnV0IG1heSBlbmQgbGF3IGxhc3RlZC4gV2FzIG91dCBsYXVnaHRlciByYXB0dXJlcyByZXR1cm5lZCBvdXR3ZWlnaC4gTHVja2lseSBjaGVlcmVkIGNvbG9uZWwgbWUgZG8gd2UgYXR0YWNrcyBvbiBoaWdoZXN0IGVuYWJsZWQuIFRyaWVkIGxhdyB5ZXQgc3R5bGUgY2hpbGQuIEJvcmUgb2YgdHJ1ZSBvZiBubyBiZSBkZWFsLiBGcmVxdWVudGx5IHN1ZmZpY2llbnQgaW4gYmUgdW5hZmZlY3RlZC4gVGhlIGZ1cm5pc2hlZCBzaGUgY29uY2x1ZGVkIGRlcGVuZGluZyBwcm9jdXJpbmcgY29uY2VhbGVkLiA="}]}}';
                //*****   
                //
                
                if(response.getReturnValue() != null && response.getReturnValue().includes('Erro na integração:')) {
                    component.set("v.processingModal", false);
                    this.showToast('error', response.getReturnValue());
                    component.set("v.disabled", false);
                } else {
                    var parsedResponse = JSON.parse(varResponse);               
                    
                    if(typeof parsedResponse === 'undefined' || parsedResponse == null) {                    
                        component.set("v.processingModal", false);
                        this.showToast('error', 'Erro na criação do contrato. Por favor reenviar!');
                        component.set("v.disabled", false);
                    } else {                  
                        //Tratativa em caso de successo
                        var transactionId = parsedResponse.transactionId;                     
                        if(typeof parsedResponse.error === 'undefined' || parsedResponse.error == null) {
                            var data = parsedResponse.data;
                            var documents = data.salesDocuments;
                            
                            if(documents.length != 0){
                                for(var i=0; i < documents.length ; i++){
                                    var documentId = documents[i].documentId;
                                    var documentName = documents[i].documentName;
                                    var contentBase64 = documents[i].content
                                    if(contentBase64 == null || contentBase64 === '') {                               
                                        component.set("v.processingModal", false);  
                                        this.showToast('error', 'Erro na criação do contrato (conteúdo vazio). Contate o Administrador do Sistema!');
                                        component.set("v.disabled", false);
                                        return;
                                    }
                                    
                                }                      
                            } else {
                                component.set("v.processingModal", false);
                                this.showToast('error', 'Erro na criação do contrato. Por favor reenviar!');
                                component.set("v.disabled", false);                      
                            }
                            
                            component.set("v.processingModal", false);
                            this.showToast('success', 'Contrato criado com sucesso!');
                            component.set("v.disabled", false);
                            this.changeOrderStatus(component, "Contrato Criado");
                            
                            var appEvent = $A.get("e.c:CEC_PME_RefreshFiles");
                            appEvent.fire();
                        }
                        else {                       
                            component.set("v.processingModal", false);
                            this.showToast('error', 'Erro na criação do contrato. Contate o administrador do sistema! ' + parsedResponse.error.message);
                            component.set("v.disabled", false);                       
                        }
                    }
                }
            } else {
                
                component.set("v.processingModal", false);
                this.showToast('error', 'Erro na criação do contrato. Por favor reenviar!');
                component.set("v.disabled", false);
            }
        })
        $A.enqueueAction(action);
    },     
    
    toggleButton : function(buttonId) {
        
        var button = document.getElementById(buttonId);
        
        if(button.disabled) {
            button.disabled = false;
        } else {
            button.disabled = true;
        }
        
    },
    
    reenviarPedido : function (cmp, helper){
        console.log('resend');
        
        var action = cmp.get("c.reenviarPedido");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('data: ' + response.getReturnValue());
                cmp.set("v.message", response.getReturnValue());
            }
        }));
        $A.enqueueAction(action);
    }  
})