({
  loadOptions: function(component, event, helper) {
    var options = [];

    options.push({ value: "Document", label: "Documento" });
    options.push({ value: "Name", label: "Nome" });
    options.push({ value: "Phone", label: "Linha" });
    options.push({ value: "Contract", label: "Contrato" });
    options.push({ value: "Address", label: "Endereço" });

    component.set("v.statusOptions", options);
  },

  handleOptionSelected: function(component, event) {
    console.log(event.getParam("value"));

    component.set("v.searchBy", event.getParam("value"));
    component.set("v.isContractSearch", false);

    if (event.getParam("value") == "Contract") {
      component.set("v.isContractSearch", true);
    }
    component.set("v.inputValue", null);
  },

  handleButtonSearch: function(component, event, helper) {
    var searchBy = event.getSource().getLocalId();
    component.set("v.searchBy", searchBy);
    helper.addCSS(component, helper);
    component.set("v.isContractSearch", false);
    if (searchBy == "Contract") {
      component.set("v.isContractSearch", true);
    }
    component.set("v.inputValue", null);
  },

  handleLogradouro: function(component, event, helper) {
    if (component.find("txtLogradouro").get("v.value") != null) {
      if (component.find("txtLogradouro").get("v.value").length > 70) {
        event.preventDefault();
      }
    }
  },

  handleComplemento: function(component, event, helper) {
    var field = component.find("txtComplemento").get("v.value");
    var sel = window.getSelection().toString();
    if (field != null) {
      var tam = field.length;
      if (tam > 25 && sel == "") event.preventDefault();
    }
  },

  handleNumero: function(component, event, helper) {
    var txtNum = component.find("txtNumero").get("v.value");
    var sel = window.getSelection().toString();
    if (txtNum != null) {
      var tam = txtNum.length;
      if (tam > 6 && sel == "") event.preventDefault();
    }
  },

  isCPF: function(component, event, helper) {
    component.set("v.isCPF", true);
    component.set("v.isCNPJ", false);
    component.set("v.inputValue", "");
  },

  isCNPJ: function(component, event, helper) {
    component.set("v.isCPF", false);
    component.set("v.isCNPJ", true);
    component.set("v.inputValue", "");
  },

  formatText: function(component, event, helper) {
    if (component.get("v.searchBy") == "Document") {
      helper.formatDoc(component, helper);
    }

    if (component.get("v.searchBy") == "Name") {
      helper.formatNome(component, helper);
    }
    if (component.get("v.searchBy") == "Phone") {
      helper.formatMSISDN(component, helper);
    }

    if (component.get("v.searchBy") == "Contract") {
      helper.formatContrato(component, helper);
    }
  },

  formatCep: function(component, event, helper) {
    var cep = component.find("txtCep").get("v.value");

    if (cep.length == 8 && !cep.includes("-")) {
      var resp = cep.replace(/[^0-9]/g, "");
      var res = resp.replace(/(\d{5})(\d{3})/, "$1-$2");
      component.set("v.cep", res.substring(0, 9));
      console.log("entrou1: " + res);
    }
  },

  formatLogradouro: function(component, event, helper) {
    if (component.find("txtLogradouro").get("v.value") != null) {
      if (component.find("txtLogradouro").get("v.value").length > 70)
        component.set(
          "v.logradouro",
          component
            .find("txtLogradouro")
            .get("v.value")
            .substring(0, 70)
        );
    }
  },

  formatNumero: function(component, event, helper) {
    var num = component.find("txtNumero").get("v.value");

    var res = num.replace(/[^0-9]/g, "");
    component.set("v.numero", res);
    if (num != null) {
      var tam = num.length;
      var rep = res.replace(/[^0-9]/g, "");
      if (tam > 6) {
        component.set("v.numero", rep.substring(0, 6));
      }
    }
  },

  formatComplemento: function(component, event, helper) {
    var field = component.find("txtComplemento").get("v.value");
    var res = field.replace(/[^A-Za-z \xC0-\xFF0-9]/g, "");
    component.set("v.complemento", res);

    if (field != null) {
      var tam = field.length;
      var rep = res.replace(/[^A-Za-z \xC0-\xFF0-9]/g, "");
      if (tam > 25) {
        component.set("v.complemento", rep.substring(0, 25));
      }
    }
  },

  handleAddressSearch: function(component, event, helper) {
    if (event.which == 13 || event.keyCode == 13) {
      console.log("handleAddressSearch enter pressed");
      var a = component.get("c.addressSearch");
      $A.enqueueAction(a);
    }
  },

  addressSearch: function(component, event, helper) {
    component.set("v.paginationList", null);
    helper.helperAddresSearch(component, event, helper);
  },

  handleSearchCityByCarrierCode: function(component, event, helper) {
    var cod = document.getElementById("txtCodOperadora").value;
    var showMessage = event.which == 13 || event.keyCode == 13;
    console.log(cod);
    if (cod) {
      var rep = cod.replace(/[^0-9]/g,"");
      document.getElementById("txtCodOperadora").value = rep.substring(0, 3);
    }
    if (cod.length == 0 || cod.length == 3) {
      component.set("v.nomeCidade", null);
      component.set("v.UF", null);
      component.set("v.codOperadoraValue", cod);
    }

    if (cod.length == 0) {
      component.set("v.codOperadoraValue", null);
    }
    console.log("getCityByCarrierCode");
    var action = component.get("c.getCityByCarrierCode");
    action.setParams({
      carrierCode: cod.replace(/[^0-9]/g, "")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      var result = response.getReturnValue();
      console.log(state);
      console.log(result);
      if (state == "SUCCESS") {
        console.log(result);
        component.set("v.codOperadoraValue", cod);
        component.set("v.nomeCidade", result["MasterLabel"]);
        component.set("v.UF", result["Estado__c"]);
      } else {
        if (showMessage) {
          component.set(
            "v.errorMessage",
            "Código de operadora não localizado."
          );
          helper.displayError(component, helper);
        }
      }
    });

    $A.enqueueAction(action);
  },

  handleKeydown: function(component, event, helper) {
    console.log("handle Keydown => ", event.keyCode);
    if (event.keyCode == 9) {
      var nomeCidade  = document.getElementById("txtNomeCidade").value;
            nomeCidade = nomeCidade.replace(new RegExp(/[àáâãäå]/g),"a");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÀÁÂÃ]/g),"a");
            nomeCidade = nomeCidade.replace(new RegExp(/ç/g),"c");
            nomeCidade = nomeCidade.replace(new RegExp(/Ç/g),"c");
            nomeCidade = nomeCidade.replace(new RegExp(/[èéêë]/g),"e");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÈÉÊË]/g),"e");
            nomeCidade = nomeCidade.replace(new RegExp(/[ìíîï]/g),"i");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÌÍÎÏ]/g),"i");
            nomeCidade = nomeCidade.replace(new RegExp(/ñ/g),"n");                
            nomeCidade = nomeCidade.replace(new RegExp(/Ñ/g),"n");                
            nomeCidade = nomeCidade.replace(new RegExp(/[òóôõö]/g),"o");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÒÓÔÕÖ]/g),"o");
            nomeCidade = nomeCidade.replace(new RegExp(/[ùúûü]/g),"u");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÙÚÛÜ]/g),"u");
            nomeCidade = nomeCidade.replace(new RegExp(/[ýÿ]/g),"y");
            nomeCidade = nomeCidade.replace(new RegExp(/[Ý]/g),"y");
            nomeCidade = nomeCidade.toUpperCase();
      document.getElementById("txtNomeCidade").value = nomeCidade;
      if (nomeCidade) {
        helper.helperCityByName(component, event, helper, nomeCidade);
      }
    }
  },

  handleSearchCityByName: function(component, event, helper) {
    if (event.which == 13 || event.keyCode == 13) {

      var nomeCidade  = document.getElementById("txtNomeCidade").value;
            nomeCidade = nomeCidade.replace(new RegExp(/[àáâãäå]/g),"a");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÀÁÂÃ]/g),"a");
            nomeCidade = nomeCidade.replace(new RegExp(/ç/g),"c");
            nomeCidade = nomeCidade.replace(new RegExp(/Ç/g),"c");
            nomeCidade = nomeCidade.replace(new RegExp(/[èéêë]/g),"e");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÈÉÊË]/g),"e");
            nomeCidade = nomeCidade.replace(new RegExp(/[ìíîï]/g),"i");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÌÍÎÏ]/g),"i");
            nomeCidade = nomeCidade.replace(new RegExp(/ñ/g),"n");                
            nomeCidade = nomeCidade.replace(new RegExp(/Ñ/g),"n");                
            nomeCidade = nomeCidade.replace(new RegExp(/[òóôõö]/g),"o");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÒÓÔÕÖ]/g),"o");
            nomeCidade = nomeCidade.replace(new RegExp(/[ùúûü]/g),"u");
            nomeCidade = nomeCidade.replace(new RegExp(/[ÙÚÛÜ]/g),"u");
            nomeCidade = nomeCidade.replace(new RegExp(/[ýÿ]/g),"y");
            nomeCidade = nomeCidade.replace(new RegExp(/[Ý]/g),"y");
            nomeCidade = nomeCidade.toUpperCase();
      document.getElementById("txtNomeCidade").value = nomeCidade;
      component.set("v.nomeCidade", nomeCidade);

      console.log('nomeCidade: ' + nomeCidade);

      if (nomeCidade) {
        console.log('citycity: ' + nomeCidade);
        helper.helperCityByName(component, event, helper, nomeCidade);

      }
    }
  },

  searchAddress: function(component, event, helper) {
      helper.helperThatCallsHelper(component, event, helper);
  },

  handleTypeSearch: function(component, event, helper) {
    if (event.which == 13 || event.keyCode == 13) {
      var a = component.get("c.typeSearch");
      $A.enqueueAction(a);
    }
  },

  /* Dentro da ação de clicar no botão, a classe controladora aponta para a função validKey*/
  typeSearch: function(component, event, helper) {
    var doc = component.get("v.inputValue"); //doc
    var isCom = component.get("v.isCom");
    var pageSize = component.get("v.pageSize");
    var cmbBox = component.get("v.searchBy");
    if (cmbBox == "Document") {
      cmbBox = component.get("v.isCPF") ? "CPF" : "CNPJ";
    }
    console.log(
      "typesearch doc: " +
        doc +
        " >>isCom: " +
        isCom +
        " >>cmbBox: " +
        cmbBox +
        " >>searchBy: " +
        component.get("v.searchBy")
    );
    var docRadio = component.get("v.searchBy") == "Document";

    component.set("v.isProspect", false);
    component.set("v.isProfileCanalCritico", false);
    component.set("v.paginationList", null);

    var action;

    if (doc) {
      if (component.get("v.searchBy") == "Document") {
        if (isCom) {
          action = component.get("c.getvalidKeyDocument");
          action.setParams({ text: doc, type: cmbBox });
        } else {
          action = component.get("c.getDocument");
          action.setParams({ text: doc, type: cmbBox });
        }
      } else if (component.get("v.searchBy") == "Contract") {
        if (component.get("v.isProfileNBONBA") == false) {
          action = component.get("c.getContract");
          action.setParams({
            numeroContrato: doc,
            codOperadora: component.get("v.codOperadoraValue")
          });
        } else {
          action = component.get("c.getContractNBONBA");
          action.setParams({
            numeroContrato: doc,
            codOperadora: component.get("v.codOperadoraValue")
          });
        }
      } else if (component.get("v.searchBy") == "Phone") {
        action = component.get("c.getMSISDN");
        action.setParams({ msdn: doc });
      } else if (component.get("v.searchBy") == "Name") {
        action = component.get("c.getAccountName");
        action.setParams({ nome: doc });
      } else {
        component.set("v.acctList", null);
        component.set("v.errorMessage", "Escolha uma opção de busca.");
        helper.displayError(component, helper);
      }
    } else {
      component.set("v.acctList", null);
      component.set(
        "v.errorMessage",
        "Não é possivel pesquisar sem as informações requeridas."
      );
      helper.displayError(component, helper);
    }

    if (action != null) {
      component.set("v.spinner", true);

      action.setCallback(this, function(response) {
        var state = response.getState();

        if (component.isValid() && state == "SUCCESS") {
          component.set("v.spinner", false);

          var accList = JSON.parse(JSON.stringify(response.getReturnValue()));

          var mensagem =
            accList.searchAccountIntegration &&
            !accList.isBaseMovel &&
            !accList.isBaseResidencial
              ? cmbBox + " " + $A.get("$Label.c.CEC_Prospect")
              : "A busca encontrou resultados.";

          if (isCom) {
            var accListAux = docRadio ? accList.account : accList;
          } else {
            var accListAux = accList;
          }

          if (
            (cmbBox == "CPF" || cmbBox == "CNPJ") &&
            docRadio &&
            accList.searchAccountIntegration
          ) {
            if (
              accList.searchAccountIntegration &&
              accList.isBaseMovel &&
              accList.isBaseResidencial
            ) {
              component.set(
                "v.errorMessage",
                $A.get("$Label.c.CEC_ClienteBaseClaroNet")
              );
              helper.displayError(component, event, helper);
            } else if (accList.isBaseMovel && !accList.isProspect) {
              component.set(
                "v.errorMessage",
                $A.get("$Label.c.CEC_ClienteBaseClaro")
              );
              helper.displayError(component, event, helper);
            } else if (accList.isBaseResidencial && !accList.isProspect) {
              component.set(
                "v.errorMessage",
                $A.get("$Label.c.CEC_ClienteBaseNET")
              );
              helper.displayError(component, event, helper);
            }
            component.set("v.isProspect", !accList.accountBase);
          }

          component.set(
            "v.accountIntegration",
            accList.searchAccountIntegration
          );

          component.set("v.showErrors", false);
          component.set("v.acctList", accListAux);

          if (
            (accListAux.length == 0 || accListAux.length == null) &&
            !accList.searchAccountIntegration
          ) {
            helper.getCriticalChannels(component, event, helper);            
            if (
              cmbBox == "CPF" &&
              doc &&
              docRadio &&
              !component.get("v.isCom")
            ) {
              component.set("v.errorMessage", "CPF não encontrado.");               
            } else if (
              cmbBox == "CNPJ" &&
              doc &&
              docRadio &&
              !component.get("v.isCom")
            ) {
              component.set("v.errorMessage", "CNPJ não encontrado.");
            } else if (cmbBox == "Contract") {
              component.set("v.errorMessage", "Contrato não encontrado.");
            } else if (cmbBox == "Phone") {
              component.set("v.errorMessage", "Linha não encontrada.");
            } else if (cmbBox == "Name") {
              component.set("v.errorMessage", "Nome não encontrado.");
            }
            helper.displayError(component, event, helper);
          } else {
            component.set(
              "v.totalSize",
              component.get("v.acctList").length - 1
            );
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
            component.set("v.paginationList", paginationList);
            component.set("v.showPaginationList", true);  
            

            component.set("v.spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Sucesso",
              type: "success",
              message: mensagem
            });
            toastEvent.fire();
          }
        } else if (state == "ERROR") {
          component.set("v.spinner", false);
          component.set("v.acctList", null);
          var errors = response.getError();
          component.set("v.errorMessage", errors[0].message);
          helper.displayError(component, event, helper);
        }
      });
      $A.enqueueAction(action);

      action = component.get("c.getPermissionCom");
      action.setCallback(this, function(response) {
        component.set("v.isCom", response.getReturnValue());
      });
      $A.enqueueAction(action);
    }
  },

  handlePesquisa: function(component, helper) {
    component.set("v.showModalPesquisa", true);
  }
});