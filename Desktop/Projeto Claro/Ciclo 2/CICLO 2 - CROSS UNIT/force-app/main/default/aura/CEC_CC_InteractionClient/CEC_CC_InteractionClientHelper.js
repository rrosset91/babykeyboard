/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-02-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
({
    setCaseType: function (component) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getCaseType');        
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response)  {
			console.log(response.getReturnValue());
            if(response.getState() === 'SUCCESS') {
               component.set('v.caseType', response.getReturnValue());
            }
        })
        $A.enqueueAction(action);        
        console.log('caseType: ' + component.get('v.caseType'));
    },


    setTypeProtocol: function (component) {
        var newCase = component.get("v.case");
        var action = component.get("c.getTypeProtocol");        
        action.setParams({
            objCase: newCase
        });
        action.setCallback(this, function(response)  {
			console.log(response.getReturnValue());
            if(response.getState() === 'SUCCESS') {
               component.set('v.typeProtocol', response.getReturnValue());
            }
        })
        $A.enqueueAction(action);        
        console.log('setTypeProtocol: ' + component.get('v.typeProtocol'));
    },
    fetchLeadSourcePicklist: function (component, lObject, lFieldApiname, filterInteraction) {
        var action = component.get("c.getPicklistValuesByProfile");
        action.setParams({
            ObjectName: lObject,
            fieldApiname: lFieldApiname,   
            filterInteraction: filterInteraction
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var controllerField = [];
                if (result != undefined && result.length > 0) {
                    controllerField.push('Selecionar');   
                    for(var i =0; i < result.length; i++){
                        controllerField.push(result[i]);        
                    }
                }
                if(lFieldApiname == 'TypeInteractionGov__c') 
                    component.set("v.TypePicklist", controllerField); 
            } else if (state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    handleChangesByInteration: function (component, event, helper) {
        var selectedOptionValue = component.find('typeInteraction').get('v.value');
        var filterInteraction = component.get('v.filterInteraction');
        if(selectedOptionValue == 'Selecionar') 
            component.set("v.isOpen", false); 
        else {
            component.set("v.isOpen", true); 
            if(selectedOptionValue != 'Tentativa de Contato com Cliente' &&
               selectedOptionValue != 'Tentativa de Contato' &&
               selectedOptionValue != 'Cobra Retorno' &&
               selectedOptionValue != 'Registro de Tratamento')
                component.set("v.checkUpload", true);   
            else 
                component.set("v.checkUpload", false); 
        }
        if(filterInteraction == 'Interna')
            component.set("v.checkSizeText", false); 
        else
            component.set("v.checkSizeText", true); 


        if (selectedOptionValue.includes('Tentativa de Contato')) {
            var statusPicklist = [];
            statusPicklist.push('Sucesso');   
            statusPicklist.push('Insucesso'); 
            component.set("v.StatusPicklist", statusPicklist); 
            component.set("v.checkStatus", true);   
            component.set("v.checkStatus2", true);
        } else if (selectedOptionValue == 'Cobra Retorno') {
            var statusPicklist = [];
            statusPicklist.push('Confirmação de agenda técnica');
            statusPicklist.push('Não aceita prazo de tratamento');
            statusPicklist.push('Manifesto fora do prazo');       
            component.set("v.StatusPicklist", statusPicklist); 
            component.set("v.checkStatus", true); 
            component.set("v.checkStatus2", false);
        } else {
            component.set("v.checkStatus", false);  
            component.set("v.checkStatus2", false);
        }
    },
    handleMeiosContato: function (component, lObject, lFieldApiname) {
        var selectedOptionValue = component.find('statusInteraction2').get('v.value');
        if (selectedOptionValue == 'E-mail') {
            component.set("v.liberaEmail", true);
            component.set("v.liberaTelefone", false);
        } else if (selectedOptionValue == 'Telefone') {
            component.set("v.liberaEmail", false);
            component.set("v.liberaTelefone", true);
        } else {
            component.set("v.liberaEmail", false);
            component.set("v.liberaTelefone", false);
        }
    },
    fetchPicklistValues: function (component, lObject, lFieldApiname) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            ObjectName: lObject,
            fieldApiname: lFieldApiname,        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var controllerField = [];
                if (result != undefined && result.length > 0) {
                    controllerField.push('Selecionar');   
                    for(var i =0; i < result.length; i++){
                        controllerField.push(result[i]);        
                    }
                }
                if(lFieldApiname == 'TypeInteractionGov__c') 
                    component.set("v.TypePicklist", controllerField); 
                else
                    component.set("v.CompanyPicklist", controllerField);  
            } else if (state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    getInteration: function (component) {
        var filterInteraction = component.get('v.filterInteraction');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getInteractionVelocity");         
        action.setParams({
            caseId: recordId,
            filterInteraction: filterInteraction
        });
        action.setCallback(this, function (response) {
		   var state = response.getState();            
		   if(state === "SUCCESS") {
			   var result = response.getReturnValue();
			   component.set("v.listCustomerInteractions", result.lstCustomer);
                this.calculaSucessoInsucesso(component, result.lstCustomer);
            } else if (state === "ERROR" || state === "INCOMPLETE") {
			   var errors = response.getError();                
			   if (errors[0] && errors[0].message) 
				   this.methodModal(errors[0].message, 'info');
		   }
		});
        $A.enqueueAction(action);
    },


    createInteration: function (component) {
        var caseDetail = component.get("v.case");
        var lstInteractions = component.get("v.listCustomerInteractions");
        var filterInteraction = component.get("v.filterInteraction");
        var typeInteraction = component.find("typeInteraction").get("v.value");
        var descriptionInteraction = component.find("descriptionInteraction").get("v.value");
        var recordId = component.get("v.recordId");
        var lstDocumentId = component.get("v.lstDocumentId");
        var emailContato = null;
        if (component.find("emailcontato") != null) {
            emailContato = component.find("emailcontato").get("v.value");
        }
        var telefoneContato = null;
        if (component.find("telefonecontato") != null) {
            telefoneContato = component.find("telefonecontato").get("v.value");
        }
        // var statusInteraction = (typeInteraction == 'Cobra Retorno' || typeInteraction.includes('Tentativa de Contato'))  ? 
                                //  component.find("statusInteraction").get("v.value") : null;
        //var statusInteraction = component.find("statusInteraction").get("v.value");
        var statusInteraction = (component.find("statusInteraction")) ? component.find("statusInteraction").get("v.value") : '';                 
        var IsValid = this.validationForm(component);
        if (IsValid) {
            var action = component.get("c.createInteration"); 
            action.setParams({ 
                filterInteraction : filterInteraction,
                typeInteraction: typeInteraction,
                statusInteraction : statusInteraction,
                descriptionInteraction: descriptionInteraction,
                caseId: recordId,
                lstDocumentId: lstDocumentId,
                emailContato: emailContato,
                telefoneContato: telefoneContato
            });
            action.setCallback(this, function(response) {		
                var state = response.getState();
                if(state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.listCustomerInteractions", result.lstCustomer);
                    this.calculaSucessoInsucesso(component, result.lstCustomer);
                    if(result.error) {
                        this.methodModal(result.message, 'warning');
                    } else {
                        this.methodModal('Cadastro realizado com sucesso!', 'success');
                    }
                    component.find("descriptionInteraction").set("v.value", "");
                    component.find("typeInteraction").set("v.value", "Selecionar");
                    component.set("v.lstDocumentId", null);
                    if (typeInteraction == 'Cobra Retorno' || typeInteraction == 'Tentativa de Contato') {
                        component.find("statusInteraction").set("v.value", "");
                }
                    if (typeInteraction == 'Tentativa de Contato') {
                        component.find("statusInteraction2").set("v.value", "Selecionar");
                        component.set("v.liberaEmail", false);
                        component.set("v.liberaTelefone", false);
                        component.set("v.inputTel", '');
                    }
                    this.handleChangesByInteration(component, null, null);
                } else if (state === "ERROR" || state === "INCOMPLETE") {
                    var errors = response.getError();
                    if (errors[0] && errors[0].message) 
                        this.methodModal(errors[0].message, 'info');
                }
            });
            $A.enqueueAction(action);
        }        	
    },
    clearAllAttachmentInserted: function (lstDocumentId, component) {
    	//Clear all attachment created 
        var action = component.get("c.clearAllAttachmentInserted"); 
            action.setParams({ 
            lstDocumentId: lstDocumentId,
        });            
        action.setCallback(this, function(response) {		
            var state = response.getState();
            if (state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);    
	},
    getCase: function (component, isToCreate) {
        var action 	= component.get("c.GetCaseById");   
        action.setParams({
            caseId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
		   var state = response.getState();
		   var result = response.getReturnValue();
		   if(state === "SUCCESS") { 
			   component.set("v.case", result);
               this.setTypeProtocol(component);
			   if(isToCreate)
				   this.createInteration(component);    
            } else if (state === "ERROR" || state === "INCOMPLETE") {
			   var errors = response.getError();
			   if (errors[0] && errors[0].message) 
				   this.methodModal(errors[0].message, 'info');
		   }
		});
        $A.enqueueAction(action);
    },
    openFile: function (component, event) {
        var valueId = event.getSource().get("v.value");
        var action = component.get("c.getOpenFile");
        action.setParams({
            aId: valueId
        });
        action.setCallback(this, function (response) {
		   var state = response.getState();
            if (state === "SUCCESS") {
			   var result = response.getReturnValue();
			   component.set("v.lLstDocument", result);       
		   }
            if (state === "ERROR" || state === "INCOMPLETE") {
			   var errors = response.getError();
			   if (errors[0] && errors[0].message) 
				   this.methodModal(errors[0].message, 'info');
		   }
		});        
        $A.enqueueAction(action);
    },
    methodModal: function (messageModal, typeModal) {
        var modalEvent = $A.get("e.force:showToast");
        modalEvent.setParams({
            title: "Interações",
            message: messageModal,
            type: typeModal
        });
        modalEvent.fire(); 
    },
    validationForm: function (component) {
        var typeProtocol = component.get("v.typeProtocol");
        var checkSizeText = component.get("v.checkSizeText");
        var caseDetail = component.get("v.case");
        var lstInteractions = component.get("v.listCustomerInteractions");
        var typeInteraction = component.find("typeInteraction").get("v.value");
        var descriptionInteraction = component.find("descriptionInteraction").get("v.value");
        var recordId = component.get("v.recordId");
        var lstDocumentId = component.get("v.lstDocumentId");
        var statusInteraction = (typeInteraction == 'Cobra Retorno' || typeInteraction.includes('Tentativa de Contato'))  ? 
            component.find("statusInteraction").get("v.value") : null;   
        //------------------------------------------------------
        //		Validações no caso 
        //------------------------------------------------------
        //
        if (caseDetail.Status.includes('Cancelado') ||
            caseDetail.Status.includes('Cancel')) {
            this.methodModal('Não é possível inserir interação, caso cancelado.', 'warning');
            return false;
        }
        if (caseDetail.Status.includes('Encerrado') ||
            caseDetail.Status.includes('Closed')) {
            this.methodModal('Não é possível inserir interação, caso encerrado.', 'warning');
            return false;
        }
        if (typeInteraction == null || typeInteraction == "" || typeInteraction == 'Selecionar') {
            this.methodModal('Selecionar o tipo de interação.', 'warning');
            return false;    
        }        
        if ((typeInteraction.includes('Cobra Retorno') ||  typeInteraction.includes('Tentativa de Contato')) && 
            (statusInteraction == null || statusInteraction == "")) {
            this.methodModal('Preencha o campo de Status.', 'warning');
            return false;
        }
        if (descriptionInteraction == null || descriptionInteraction == "") {
            this.methodModal('Preencha o campo de interação.', 'warning');
            return false;    
        }
        if(checkSizeText && descriptionInteraction != null &&
            descriptionInteraction.length <= 30 || descriptionInteraction.length >= 3000) {
            this.methodModal('Verifique o tamanho do texto da interação.', 'warning');
            return false;   
        }
        if (typeInteraction.includes('Resposta da Reclamação') && 
            (caseDetail.Output_Subject__c == null || 
             caseDetail.Relevant__c == null || 
                caseDetail.Resolution__c == null)) {
            this.methodModal('Os campos "Motivo de Saída", "Reclamação é procedente?"  e "Resolução" são obrigatórios!', 'warning');
            return false;
        }
        if (typeInteraction.includes('Resposta da Reclamação') && 
            caseDetail.SubStatus__c.includes('Recusa Solicitada')) {
            this.methodModal('Não é possível responder o caso, recusa já solicitada.', 'warning');
            return false;
        }
        if (typeProtocol != 'PS8' && 
            typeInteraction.includes('Resposta da Reclamação') && 
            caseDetail.LegacyProtocol__c == null) {
            this.methodModal('O campo "Protocolo Legado" deve ser preenchido.', 'warning');
            return false;
        }
        if (component.find("emailcontato") != null) {
            if (!component.find("emailcontato").get('v.validity').valid) {
                this.methodModal('Verifique o E-mail digitado.', 'warning');
                return false;
            }
        }
        //------------------------------------------------------
        //		Validações na Customer Interaction 
        //------------------------------------------------------
        if(lstInteractions != null){
            //variable to check what kind of case is
            let caseType = component.get('v.caseType');
            for (let i = 0; i < lstInteractions.length; i++) {
                let obj = lstInteractions[i];
                if(caseType !== 'Cross'){


                    if (obj.vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c.includes('Resposta da Reclamação') &&
                        typeInteraction.includes('Resposta da Reclamação') &&
                        caseDetail.SubStatus__c.includes('Respondido e Aguardando Avaliação')) {
                        this.methodModal('Não é possível inserir mais de uma resposta.', 'warning');
                        return false;
                    }
                    if (obj.vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c.includes('Resposta da Reclamação') &&
                        typeInteraction.includes('Recusa da Reclamação')) {
                        this.methodModal('Não é possível recusar o caso, resposta já inserida.', 'warning');
                        return false;
                    }
                    if (typeInteraction.includes('Resposta da Reclamação') && 
                        obj.vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c.includes('Recusa da Reclamação') &&
                        caseDetail.SubStatus__c.includes('Recusa Solicitada')) {
                        this.methodModal('Não é possível responder a interação, recusa já solicitada.', 'warning');
                        return false;
                    }
                    if (typeInteraction.includes('Recusa da Reclamação') && 
                        obj.vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c.includes('Recusa da Reclamação')&&
                        caseDetail.SubStatus__c.includes('Recusa Solicitada')) {
                        this.methodModal('Não é possível recusar o caso, recusa já solicitada.', 'warning');
                        return false;
                    }
                }else{
                    if(obj.vlocity_cmt__CaseId__r.SubStatus__c === 'Concluído'){
                        this.methodModal('O contato com o Cliente ja foi bem sucedido.', 'warning');
                        return false;
                    }
                }
            }
        }
        //------------------------------------------------------
        return true;
    },

    calculaSucessoInsucesso: function (component, lstcostumer) {
        var contSucess = 0;
        var contInSucess = 0;
        if (lstcostumer != undefined) {
            if (lstcostumer.length > 0) {
                for (var i = 0; i < lstcostumer.length; i++) {
                    if (lstcostumer[i].vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Status__c == 'Sucesso') {
                        contSucess = contSucess + 1;
                    }
                    if (lstcostumer[i].vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Status__c == 'Insucesso') {
                        contInSucess = contInSucess + 1;
                    }
                }
            }

            if (contSucess > 0) {
                component.set('v.contsucesso', contSucess);
            }

            if (contInSucess > 0) {
                component.set('v.continsucesso', contInSucess);
            }
    }
    },

    validateEmail: function (c, e, h) {
        try {
            let isValidEmail = true;
            let emailField = c.find("emailcontato");
            let emailFieldValue = emailField.get("v.value");
            let regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!$A.util.isEmpty(emailFieldValue)) {
                if (emailFieldValue.match(regExpEmailformat)) {
                    console.log('Você inseriu um formato válido.');
                    emailField.set("v.errors", [{
                        message: null
                    }]);
                    $A.util.removeClass(emailField, 'slds-has-error');
                    isValidEmail = true;
                    c.find("emailcontato").set('v.value', null);
                } else {
                    console.log('Você inseriu um formato inválido.');
                    $A.util.addClass(emailField, 'slds-has-error');
                    emailField.set("v.errors", [{
                        message: "Você inseriu um formato inválido."
                    }]);
                    isValidEmail = false;
                }
            }
            if (isValidEmail) {

                // code write here..if Email Address is valid. 
            }
        } catch (e) {
            console.log('Error>>>' + e);
        }
    },

    validateTel: function (component, event, helper) {
        var msi = component.find("telefonecontato").get("v.value");
        if (msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            component.set("v.inputTel", res.substring(0, 15));
            if (msi.length >= 11) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                component.set("v.inputTel", res.substring(0, 15));
            }
        }
    },

})