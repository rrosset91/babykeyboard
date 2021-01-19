({
  doInit: function (component, event, helper) {
    //Alterar para chamar somente uma vez o back e retornar todas as opcoes
    //dados preenchidos?

    helper.initialLoad(component);

    var data = new Object();
    component.set("v.data", data);
  },

  handleChangeReason: function (component, event) {
    // This will contain the string of the "value" attribute of the selected option
    var selectedOptionValue = event.getParam("value");
    component.set("v.motivoReemb", selectedOptionValue);
  },

  handleChangeTitular: function (component, event) {
    // This will contain the string of the "value" attribute of the selected option
    var selectedOptionValue = event.getParam("value");
    component.set("v.titular", selectedOptionValue);
  },

  handleChangeBanco: function (component, event) {
    // This will contain the string of the "value" attribute of the selected option
    var selectedOptionValue = event.getParam("value");
    component.set("v.banco", selectedOptionValue);
  },

  onClickButton2: function (component, event) {
    $A.get("e.force:refreshView").fire();
  },

  handleChangeTipoPessoa: function (component, event) {
    // This will contain the string of the "value" attribute of the selected option
    var selectedOptionValue = event.getParam("value");

    component.set(
      "v.layoutTipoPessoaFisica",
      selectedOptionValue == "Pessoa FÃ­sica"
    );
    component.set(
      "v.layoutTipoPessoaJuridica",
      selectedOptionValue == "Pessoa JurÃ­dica"
    );
  },

  handleClick: function (component, event, helper) {
    var validaCampos = component
      .find("field")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.get("v.validity").valid;
      }, true);
    if (validaCampos) {
      helper.postRefund(component, event, helper, (sucess, error) => {
        if (error) {
          component.set("v.dialogModal", false);
          component.find("modalMessage").close();
        }
      });
    } else {
      component.set("v.dialogModal", true);
      component.set("v.title", "AtenÃ§Ã£o");
      component.set("v.typeIcon", "utility:warning");
      component.set("v.typeVariant", "warning");
      component.set("v.message", "Os campos em vermelho sÃ£o obrigatÃ³rios");
      component.set("v.showButton1", false);
      component.set("v.showButton2", false);
      component.set("v.showButtonX", true);
      component.find("modalMessage").open();
    }
  },

  closeModal: function (component, event, helper) {
    component.set("v.dialogModal", false);
    component.find("modalMessage").close();
  },

  closeModalFicha: function (component, event, helper) {
    component.set("v.dialogModal", false);
    component.find("modalMessage").close();
  }
});