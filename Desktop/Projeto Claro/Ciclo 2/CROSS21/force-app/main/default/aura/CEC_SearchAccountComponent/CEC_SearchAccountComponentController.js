({
    doInit: function(component, event, helper) {
       
        var workspaceAPI = component.find("workspace");
        var pageSize = component.get("v.pageSize");
        var isCom = component.get("v.isCom");
         

        var actionProfile = component.get("c.getProfileNBONBA");
        actionProfile.setCallback(this, function(response) {
            component.set("v.isProfileNBONBA", response.getReturnValue());
        });
        $A.enqueueAction(actionProfile);

        actionProfile = component.get("c.getProfileComercialUsers");
        actionProfile.setCallback(this, function(response) {
            component.set("v.isProfileComercialUsers", response.getReturnValue());
        });
        $A.enqueueAction(actionProfile);

        component.set("v.tipo", "CPF");
        component.set("v.label", "Documento");       

        var action;

        if (component.get("v.pageReference").state.c__tipo) {
            component.set("v.doc", component.get("v.pageReference").state.c__doc);
            component.set("v.tipo", component.get("v.pageReference").state.c__tipo);
            component.set("v.cepCTI", component.get("v.pageReference").state.c__cep);
            component.set("v.isDoc", true);
            component.set("v.label", 'Documento');
            component.set("v.documentType", false);
            component.set("v.tipoContrato", false); 
            
            var formatoCPF = component.get("v.doc");
            var rep;
            var res;
            
            if(formatoCPF !== ''){
                rep = formatoCPF.replace(/[^0-9]/g, '');
                res = rep.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
                component.set("v.inputValue", res.substring(0, 14));
            }
            
            
            var doc = component.get("v.doc");            
            var docRadio = true;            
            var cmbBox = component.get("v.pageReference").state.c__tipo;
            
            if (isCom) {
                action = component.get("c.getvalidKeyDocument");
                action.setParams({ "text": doc, "type": cmbBox }); 
            }else{
                action = component.get("c.getDocument");
                action.setParams({ "text": doc, "type": cmbBox });
            }
        }

        if (component.get("v.pageReference").state.c__doc != null &&
            component.get("v.pageReference").state.c__isContract) {

            component.set("v.doc", component.get("v.pageReference").state.c__doc);
            component.set("v.isContract", component.get("v.pageReference").state.c__isContract);
            component.set("v.label", 'BAN');
            component.set("v.documentType", true);
            component.set("v.tipoContrato", true);
            var opCode = component.get("v.codOperadoraValue");
            var contrato = component.get("v.pageReference").state.c__doc;
            if (component.get("v.isProfileNBONBA") == false) {
                action = component.get("c.getContract");
                action.setParams({ "numeroContrato": contrato, "codOperadora": contrato });
            } else {
                action = component.get("c.getContractNBONBA");
                action.setParams({ "numeroContrato": contrato, "codOperadora": contrato });
            }
        }

        if (component.get("v.pageReference").state.c__doc != null &&
            component.get("v.pageReference").state.c__isMsisdn) {

            component.set("v.doc", component.get("v.pageReference").state.c__doc);
            component.set("v.isMsisdn", component.get("v.pageReference").state.c__isMsisdn);
            component.set("v.label", 'Linha');
            component.set("v.documentType", true);
            component.set("v.tipoContrato", false);

            var msdn = component.get("v.pageReference").state.c__doc;
            action = component.get("c.getMSISDN");
            action.setParams({ "msdn": msdn });
        }

        if (action != null) {

            component.set("v.spinner", true);
            action.setCallback(this, function(response) {
                component.set("v.spinner", false);
                var state = response.getState();
                var list = response.getReturnValue();

                if (component.isValid() && state == "SUCCESS") {
                    var accList = JSON.parse(JSON.stringify(response.getReturnValue()));
                    
                    var mensagem = accList.searchAccountIntegration && !accList.isBaseMovel && !accList.isBaseResidencial ? cmbBox + ' ' + $A.get("$Label.c.CEC_Prospect") : 'A busca encontrou resultados.';
                   
                     if (isCom) {
                   		 var accListAux = docRadio ? accList.account : accList;
                     }else{
                          var accListAux = accList;                          
                     }

                    if (((cmbBox == 'CPF' || cmbBox == 'CNPJ') && docRadio && accList.searchAccountIntegration)) {
                        if (accList.searchAccountIntegration && accList.isBaseMovel && accList.isBaseResidencial) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseClaroNet"));
                            helper.displayError(component, event, helper);

                        } else if (accList.isBaseMovel && !accList.isProspect) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseClaro"));
                            helper.displayError(component, event, helper);

                        } else if (accList.isBaseResidencial && !accList.isProspect) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseNET"));
                            helper.displayError(component, event, helper);
                        }
                        component.set("v.isProspect", (!accList.accountBase));
                    }


                    component.set("v.accountIntegration", accList.searchAccountIntegration);                   
                    component.set("v.showErrors", false);
                    component.set("v.acctList", accListAux);
                   


                    if ((accListAux.length == 0 || accListAux.length == null) && !accList.searchAccountIntegration) {
                        component.set("v.errorMessage", 'A busca não retornou resultados.');  
                        component.set("v.showPaginationList", true);
                        helper.getCriticalChannels(component, event, helper);                       
                        $A.enqueueAction(actionProfile);
                        helper.displayError(component, event, helper);
                    } else {
                        component.set("v.totalSize", component.get("v.acctList").length - 1);
                        component.set("v.start", 0);
                        component.set("v.end", pageSize - 1);
                        if (component.get("v.acctList").length < 5) {
                            pageSize = component.get("v.acctList").length;
                        }

                        var paginationList = [];
                        for (var i = 0; i < pageSize; i++) {
                            if (accListAux[i] != null) {
                                paginationList.push(accListAux[i]);
                            }
                        }
                        component.set('v.paginationList', paginationList);
                        component.set('v.showPaginationList', true);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Sucesso",
                            "type": "success",
                            "message": mensagem,
                        });
                        toastEvent.fire();
                    }
                } else if (state == "ERROR") {
                    component.set("v.spinner", false);
                    component.set("v.acctList", null);
                    var errors = response.getError();
                    component.set("v.showErrors", true);
                    component.set("v.errorMessage", errors[0].message);
                    helper.displayError(component, event, helper);
                }
            });

            $A.enqueueAction(action);
        }

        action = component.get("c.getPermissionCom");
        action.setCallback(this, function(response) {
            component.set("v.isCom", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    reInit: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    buscarHandler: function(component, event, helper) {
        var cid = component.get("v.selectedLookUpRecord");
        var cod = component.get("v.selectedLookUpRecord1");

        if (cod.Id && !cid.Id) {
            var cidCmp = component.find("cidade");
            cidCmp.set('v.selectedRecord', cod);
            cidCmp.callSearch();
        }

        if (cid.Id && !cod.Id) {
            var codCmp = component.find("codOperadora");
            codCmp.set('v.selectedRecord', cid);
            codCmp.callSearch();
        }
    },

    adicionarHandler: function(component, event, helper) {
        var cid = component.get("v.selectedLookUpRecord");
        var cod = component.get("v.selectedLookUpRecord1");

        
        if ((JSON.stringify(cod) != '{}' && JSON.stringify(cid) != '{}') && (JSON.stringify(cod) != '""' && JSON.stringify(cid) != '""') && (cod.Id == cid.Id)) {
            component.set('v.nomeCidade', cid.MasterLabel);
            component.set('v.codOperadoraValue', cid.CodigoOperadora__c);
            document.getElementById("txtCodOperadora").value = cid.CodigoOperadora__c;
            component.set('v.showModalPesquisa', false);
            component.find("codOperadora").clear();
            component.find("cidade").clear();
            component.set("v.selectedLookUpRecord", '');
            component.set("v.selectedLookUpRecord1", '');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Sucesso',
                type: 'success',
                duration: ' 1000',
                message: 'Código da operadora adicionado com sucesso!',
            });
            toastEvent.fire();
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Alerta',
                type: 'error',
                duration: ' 1000',
                message: 'Selecione uma cidade ou código da operadora.',
            });
            toastEvent.fire();
        }
    },

    limparHandler: function(component, event, helper) {
        component.find("codOperadora").clear();
        component.find("cidade").clear();
        component.set("v.selectedLookUpRecord", '');
        component.set("v.selectedLookUpRecord1", '');
    },

    openContractPage: function(component, event) {
        var action = component.get("c.getContractId");
        action.setParams({
            contractNumber: event.target.getAttribute('data-contract-number')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue()
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    },

    openDetailPage: function(component, event) {

        var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.getAttribute('data-id');
        navEvt.setParams({
            "recordId": id
        });

        navEvt.fire();
    },

    handleAddressSearch: function(component, event, helper) {
        if (event.which == 13 || event.keyCode == 13) {
            var a = component.get('c.addressSearch');
            $A.enqueueAction(a);
        }
    },

    handleTypeSearch: function(component, event, helper) {
        if (event.which == 13 || event.keyCode == 13) {
            var a = component.get('c.typeSearch');
            $A.enqueueAction(a);
        }
    },

    clearDocument: function(component, event, helper) {
        component.set("v.doc", '');
    },

    limit: function(component, event, helper) {
        var input = component.find("txtDoc").get("v.value");
        var doc = component.find("radioDoc").getElement().checked;
        var docType = component.find("cmbDoc").get("v.value");
        var nome = component.find("radioName").getElement().checked;
        var msisdn = component.find("radioMsisdn").getElement().checked;
        var contrato = component.find("radioContrato").getElement().checked;

        var sel = window.getSelection().toString();
        var tam;

        if (input != null) {
            tam = input.length;

            if (doc == true) {
                if (docType == 'CPF') {

                    if (tam > 13 && sel == '') {
                        event.preventDefault();
                    }
                }

                if (docType == 'CNPJ') {
                    if (tam > 17 && sel == '') {
                        event.preventDefault();
                    }
                }

                if (docType == 'Passaporte') {
                    if (tam > 20 && sel == '') {
                        event.preventDefault();
                    }
                }

                if (docType == 'RNE') {
                    if (tam > 9 && sel == '') {
                        event.preventDefault();
                    }
                }
            }

            if (nome) {
                if (tam > 40 && sel == '') {
                    event.preventDefault();
                }
            }

            if (contrato) {
                if (tam > 13 && sel == '') {
                    event.preventDefault();
                }
            }

        }
    },

    formatText: function(component, event, helper) {
        var docRadio = component.find("radioDoc").getElement().checked;
        var nameRadio = component.find("radioName").getElement().checked;
        var msisdnRadio = component.find("radioMsisdn").getElement().checked;
        var contratoRadio = component.find("radioContrato").getElement().checked;


        if (docRadio) {
            helper.formatDoc(component, helper);
        }

        if (nameRadio) {
            helper.formatNome(component, helper);
        }

        if (msisdnRadio) {
            helper.formatMSISDN(component, helper);
        }

        if (contratoRadio) {
            helper.formatContrato(component, helper);
        }
    },

    formatCodOperadora: function(component, event, helper) {
        var cod = document.getElementById("txtCodOperadora").value;

        if (cod) {
            var rep = cod.replace(/[^0-9]/g, '');
            document.getElementById("txtCodOperadora").value = rep.substring(0, 3);
        }

        var action = component.get("c.getCityByCarrierCode");
        action.setParams({
            carrierCode: cod.replace(/[^0-9]/g, '')
        });

        action.setCallback(this, function(response) {
            component.set('v.nomeCidade', response.getReturnValue())
        });

        $A.enqueueAction(action);
    },

    formatCep: function(component, event, helper) {
        var cep = component.find("txtCep").get("v.value");

        if (cep) {
            var rep = cep.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{5})(\d{3})/, "$1-$2");
            component.set("v.cep", res.substring(0, 9));
        }

    },

    handleComplemento: function(component, event, helper) {
        var field = component.find("txtComplemento").get("v.value");
        var sel = window.getSelection().toString();
        if (field != null) {
            var tam = field.length;
            if (tam > 25 && sel == '')
                event.preventDefault();
        }
    },

    formatComplemento: function(component, event, helper) {
        var field = component.find("txtComplemento").get("v.value");
        var res = field.replace(/[^A-Za-z \xC0-\xFF0-9]/g, '');
        component.set("v.complemento", res);

        if (field != null) {
            var tam = field.length;
            var rep = res.replace(/[^A-Za-z \xC0-\xFF0-9]/g, '');
            if (tam > 25) {
                component.set("v.complemento", rep.substring(0, 25));
            }
        }
    },

    handleUF: function(component, event, helper) {
        var field = component.find("txtUF").get("v.value");
        var sel = window.getSelection().toString();
        if (field != null) {
            var tam = field.length;
            if (tam > 2 && sel == '')
                event.preventDefault();
        }
    },

    formatUF: function(component, event, helper) {
        var field = component.find("txtUF").get("v.value");
        var res = field.replace(/[^A-Za-z]/g, '');
        component.set("v.uf", res);

        if (field != null) {
            var tam = field.length;
            var rep = res.replace(/[^A-Za-z]/g, '');
            if (tam > 2) {
                component.set("v.uf", rep.substring(0, 2));
            }
        }
    },

    handleCidade: function(component, event, helper) {
        var field = component.find("txtCidade").get("v.value");
        var sel = window.getSelection().toString();
        if (field != null) {
            var tam = field.length;
            if (tam > 25 && sel == '')
                event.preventDefault();
        }
    },

    handleLogradouro: function(component, event, helper) {
        if (component.find("txtLogradouro").get("v.value") != null) {
            if (component.find("txtLogradouro").get("v.value").length > 70) {
                event.preventDefault();
            }
        }
    },

    formatCidade: function(component, event, helper) {
        var field = component.find("txtCidade").get("v.value");
        var res = field.replace(/[^A-Za-z \xC0-\xFF]/g, '');
        component.set("v.cidade", res);

        if (field != null) {
            var tam = field.length;
            var rep = res.replace(/[^A-Za-z \xC0-\xFF]/g, '');
            if (tam > 25) {
                component.set("v.cidade", rep.substring(0, 25));
            }
        }
    },

    formatLogradouro: function(component, event, helper) {
        if (component.find("txtLogradouro").get("v.value") != null) {
            if (component.find("txtLogradouro").get("v.value").length > 70)
                component.set("v.logradouro", component.find("txtLogradouro").get("v.value").substring(0, 70));
        }
    },

    handleNumero: function(component, event, helper) {
        var txtNum = component.find("txtNumero").get("v.value");
        var sel = window.getSelection().toString();
        if (txtNum != null) {
            var tam = txtNum.length;
            if (tam > 6 && sel == '')
                event.preventDefault();
        }
    },

    formatNumero: function(component, event, helper) {
        var num = component.find("txtNumero").get("v.value");
        var res = num.replace(/[^0-9]/g, '');
        component.set("v.numero", res);
        if (num != null) {
            var tam = num.length;
            var rep = res.replace(/[^0-9]/g, '');
            if (tam > 6) {
                component.set("v.numero", rep.substring(0, 6));
            }
        }
    },

    isResidencial: function(component, helper) {
        component.set("v.isMovel", false);
        component.set("v.isResidencial", true);
    },

    handlePesquisa: function(component, helper) {
        component.set("v.showModalPesquisa", true);
    },

    isMovel: function(component, helper) {
        component.set("v.isMovel", true);
        component.set("v.isResidencial", false);
        component.set("v.doc", null);
        component.set("v.doc2", null);
        component.set("v.codOperadoraValue", null);
    },

    closeModalPesquisa: function(component, helper) {
        component.set("v.showModalPesquisa", false);
    },

    handleTipo: function(component, event, helper) {
        var doc = component.find("radioDoc").getElement().checked;
        var nom = component.find("radioName").getElement().checked;
        var msi = component.find("radioMsisdn").getElement().checked;
        var con = component.find("radioContrato").getElement().checked;

        component.set("v.isMovel", true);
        component.set("v.isResidencial", false);

        if (doc) {
            component.set("v.isContractSearch", false);
            component.set("v.label", 'Documento');
            component.set("v.documentType", false);
            component.set("v.doc", null);
            component.set("v.tipoContrato", false);
        }

        if (con) {
            component.set("v.label", 'BAN');
            component.set("v.isContractSearch", true);
            component.set("v.documentType", true);
            component.set("v.doc", null);
            component.set("v.tipoContrato", true);
        }

        if (nom || msi) {
            if (nom) component.set("v.label", 'Nome');

            if (msi) component.set("v.label", 'Linha');

            component.set("v.isContractSearch", false);
            component.set("v.documentType", true);
            component.set("v.doc", null);
            component.set("v.tipoContrato", false);
        }
    },


    /* Dentro da ação de clicar no botão, a classe controladora aponta para a função validKey*/
    typeSearch: function(component, event, helper) {
        console.log('Entrou na função typeSearch ');
        /*Variaveis busca por CPf ou CNPJ*/
        var doc = component.get("v.doc");
        var doc2 = component.get("v.doc2");
        var cmbBox = component.find("cmbDoc").get("v.value");
        var docRadio = component.find("radioDoc").getElement().checked;
        var nameRadio = component.find("radioName").getElement().checked;
        var msisdnRadio = component.find("radioMsisdn").getElement().checked;
        var contratoRadio = component.find("radioContrato").getElement().checked;
        var pageSize = component.get("v.pageSize");
        var isCom = component.get("v.isCom");
        component.set("v.isDoc", false);
        component.set("v.isProspect", false);
        component.set("v.paginationList", null);
        component.set("v.isProfileCanalCritico", false);
        /*Variável de retorno da ação*/
        var action;
        if (doc) {


            if (docRadio) {
                component.set("v.isDoc", true);
                if (isCom) {
                    action = component.get("c.getvalidKeyDocument");
                    action.setParams({ "text": doc, "type": cmbBox });
                } else {
                    action = component.get("c.getDocument");
                    action.setParams({ "text": doc, "type": cmbBox });
                }
            } else if (nameRadio) {
                action = component.get("c.getAccountName");
                action.setParams({ "nome": doc });
            } else if (msisdnRadio) {
                action = component.get("c.getMSISDN");
                action.setParams({ "msdn": doc });
            } else if (contratoRadio) {
                if (component.get("v.isProfileNBONBA") == false) {
                    action = component.get("c.getContract");
                    action.setParams({ "numeroContrato": doc });
                } else {
                    action = component.get("c.getContractNBONBA");
                    action.setParams({ "numeroContrato": doc });
                }
            } else {
                component.set("v.acctList", null);
                component.set("v.errorMessage", 'Escolha uma opção de busca.');
                helper.displayError(component, helper);
            }
        } else if (doc2) {
            if (contratoRadio) {
                if (component.get("v.isProfileNBONBA") == false) {
                    action = component.get("c.getContract");
                    action.setParams({ "numeroContrato": doc2, "codOperadora": document.getElementById("txtCodOperadora").value });
                } else {
                    action = component.get("c.getContractNBONBA");
                    action.setParams({ "numeroContrato": doc2, "codOperadora": document.getElementById("txtCodOperadora").value });
                }
            } else {
                component.set("v.acctList", null);
                component.set("v.errorMessage", 'Escolha uma opção de busca.');
                helper.displayError(component, helper);
            }
        } else {
            component.set("v.acctList", null);
            component.set("v.errorMessage", 'Não é possivel pesquisar sem as informações requeridas.');
            helper.displayError(component, helper);
        }

        if (action != null) {
            component.set("v.spinner", true);

            action.setCallback(this, function(response) {
                var state = response.getState();


                if (component.isValid() && state == "SUCCESS") {
                    component.set("v.spinner", false);

                    var accList = JSON.parse(JSON.stringify(response.getReturnValue()));
                    console.dir(accList);
                    var mensagem = accList.searchAccountIntegration && !accList.isBaseMovel && !accList.isBaseResidencial ? cmbBox + ' ' + $A.get("$Label.c.CEC_Prospect") : 'A busca encontrou resultados.';
                    if (isCom) {
                        var accListAux = docRadio ? accList.account : accList;
                    } else {
                        var accListAux = accList;
                    }


                    if (((cmbBox == 'CPF' || cmbBox == 'CNPJ') && docRadio && accList.searchAccountIntegration)) {
                        if (accList.searchAccountIntegration && accList.isBaseMovel && accList.isBaseResidencial) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseClaroNet"));
                            helper.displayError(component, event, helper);

                        } else if (accList.isBaseMovel && !accList.isProspect) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseClaro"));
                            helper.displayError(component, event, helper);

                        } else if (accList.isBaseResidencial && !accList.isProspect) {
                            component.set("v.errorMessage", $A.get("$Label.c.CEC_ClienteBaseNET"));
                            helper.displayError(component, event, helper);
                        }
                        component.set("v.isProspect", (!accList.accountBase));
                    }

                    component.set("v.accountIntegration", accList.searchAccountIntegration);
                    
                    component.set("v.showErrors", false);
                    component.set("v.acctList", accListAux);
                    
                    if ((accListAux.length == 0 || accListAux.length == null) && !accList.searchAccountIntegration) {
                        var actionProfile = component.get("c.getProfileCanaisCriticos");
                        actionProfile.setCallback(this, function(response) {
                            component.set("v.isProfileCanalCritico", response.getReturnValue());
                        });
                        $A.enqueueAction(actionProfile);
                        if (cmbBox == 'CPF' && doc && docRadio && !component.get("v.isCom")) {
                            component.set("v.errorMessage", 'CPF não encontrado.');
                        } else if (cmbBox == 'CNPJ' && doc && docRadio && !component.get("v.isCom")) {
                            component.set("v.errorMessage", 'CNPJ não encontrado.');
                        } else if (cmbBox == 'Passaporte' && doc && docRadio) {
                            component.set("v.errorMessage", 'Passaporte não encontrado.');
                        } else if (cmbBox == 'RNE' && doc && docRadio) {
                            component.set("v.errorMessage", 'RNE não encontrado.');
                        } else if (cmbBox == 'Passaporte' && doc && docRadio) {
                            component.set("v.errorMessage", 'Passaporte não encontrado.');
                        } else if (nameRadio && doc) {

                            component.set("v.errorMessage", 'Nome não encontrado.');
                        } else if (msisdnRadio && doc) {
                            component.set("v.errorMessage", 'Linha não encontrada.');
                        } else if (contratoRadio) {
                            component.set("v.errorMessage", 'Contrato não encontrado.');
                        }
                        helper.displayError(component, event, helper);
                    } else {
                        component.set("v.totalSize", component.get("v.acctList").length - 1);
                        component.set("v.start", 0);
                        component.set("v.end", pageSize - 1);
                        if (component.get("v.acctList").length < 5) {
                            pageSize = component.get("v.acctList").length;
                        }

                        var paginationList = [];
                        for (var i = 0; i < pageSize; i++) {
                            if (accListAux[i] != null) {
                                paginationList.push(accListAux[i]);
                            }
                        }
                        component.set('v.paginationList', paginationList);
                        
                        component.set("v.spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Sucesso",
                            "type": "success",
                            "message": mensagem,
                        });
                        toastEvent.fire();
                    }
                } else if (state == "ERROR") {
                    component.set("v.spinner", false);
                    component.set("v.acctList", null);
                    var errors = response.getError();
                    component.set("v.errorMessage", errors[0].message)
                    helper.displayError(component, event, helper);
                }
            });
            $A.enqueueAction(action);

        }

        action = component.get("c.getPermissionCom");
        action.setCallback(this, function(response) {
            component.set("v.isCom", response.getReturnValue());
            console.log(response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    /* Dentro da ação de clicar no botão, a classe controladora aponta para a função validKey*/
    addressSearch: function(component, event, helper) {
        component.set("v.paginationList", null);
        helper.helperAddresSearch(component, event, helper);
    },

    clearDocument: function(component, event, helper) {
        component.set("v.doc", null);
    },

    openOs: function(component, event, helper) {
        var CEC_OmniScript;
        var action = component.get("c.getParametersByOmniscriptName");
        action.setParams({
            omniscriptName: "Simulação"
        });
        action.setCallback(this, function(response) {
            CEC_OmniScript = response.getReturnValue();
            var urlEvent = $A.get("e.force:navigateToURL");
            var url;
            if (component.get('v.isProspect')) {
                url = "/apex/CEC_OmniScriptPage?strOmniScriptType=" + CEC_OmniScript.strOmniScriptType__c + "&strOmniScriptSubType=" + CEC_OmniScript.strOmniScriptSubType__c + "&strOmniScriptLang=" + CEC_OmniScript.strOmniScriptLang__c + "&OSname=" + CEC_OmniScript.MasterLabel + "&accountDocType=" + event.target.getAttribute('data-type') + "&accountDocNumber=" + event.target.getAttribute('data-doc') + "&premisesCEP=" + component.get("v.cepCTI");
                console.log(url);
            } else {
                url = "/apex/CEC_OmniScriptPage?accountId=" + event.target.getAttribute('data-id') + "&strOmniScriptType=" + CEC_OmniScript.strOmniScriptType__c + "&strOmniScriptSubType=" + CEC_OmniScript.strOmniScriptSubType__c + "&strOmniScriptLang=" + CEC_OmniScript.strOmniScriptLang__c + "&OSname=" + CEC_OmniScript.MasterLabel + "&premisesCEP=" + component.get("v.cepCTI");
                console.log(url)
            }
            urlEvent.setParams({
                "url": url,
                "isredirect": "true"
            });
            urlEvent.fire();
        });
        $A.enqueueAction(action);
    },

    anteriorHandler: function(component, event, helper) {
        var dataList = component.get("v.acctList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        
        var paginationList = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                paginationList.push(dataList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },

    proximoHandler: function(component, event, helper) {
        var dataList = component.get("v.acctList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (dataList.length > end) {
                if (dataList[i] != null) paginationList.push(dataList[i]);
                counter++;
            }
        }
        start = start + counter;
        end = end + counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },

    callflowCC: function(component, event, helper) {
        component.set("v.showModalFluxo", true);
        var flow = component.find("startFlowCC");
        flow.startFlow("CriacaoContaContatoCC");
    },



    handleStatusChange: function(component, event) {
        if (event.getParam("status") === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Sucesso",
                "type": "success",
                "message": "Conta criada com sucesso"
            });
            toastEvent.fire();

            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for (var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if (outputVar.name === "AccountId") {
                    component.set("v.accountId", outputVar.value);
                    component.set("v.showModalFluxo", false);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.accountId"),
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                }
            }
        }
    },

    closeFlow: function(component, event, helper) {
        component.set("v.showModalFluxo", false);
    },


    expandContract: function(component, event, helper) {
        var list = component.get("v.paginationList");
        var index = event.getSource().get("v.value");
        var size = list.length;
        list[index].isExpandable = !list[index].isExpandable;

        for (var i = 0; i < size; i++) {
            if (i != index) {
                list[i].isExpandable = false;
            }
        }

        component.set("v.paginationList", list);
        helper.showListContracts(component, event, helper);

    },

    navigateToContract: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.getAttribute('data-contid');
        navEvt.setParams({
            "recordId": id
        });

        navEvt.fire();
    },

    sortByName: function(component, event, helper) {
        helper.sortBy(component, helper, "name");
    },

    sortByDocument: function(component, event, helper) {
        helper.sortBy(component, helper, "DocumentNumber");
    },

    sortByAddress: function(component, event, helper) {
        helper.sortBy(component, helper, "StreetAddress");
    },

    sortByNumber: function(component, event, helper) {
        helper.sortBy(component, helper, "FormattedNumberAddress");
    },
    
    sortByComplement: function(component, event, helper) {
        helper.sortBy(component, helper, "UnformattedComplement");
    },
})