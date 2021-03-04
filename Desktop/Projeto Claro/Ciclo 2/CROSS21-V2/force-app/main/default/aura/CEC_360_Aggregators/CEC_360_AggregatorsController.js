({
  doInit: function(component, event, helper) {
    var toastEvent;
    var options = [
      { value: "Pendente", label: "Pendente" },
      { value: "Ativo", label: "Ativo" },
      { value: "Cancelado", label: "Cancelado" },
      { value: "Expirado", label: "Expirado" }
    ];
    component.set("v.statusOptions", options);
  },

  getSubscriber: function(component, event, helper) {
    var dateStart = component.get("v.startDate");
    component.set("v.hasAggreggators", false);
    var dateEnd = component.get("v.endDate");

    var toastEvent;
    component.set("v.showSpinner", true);
    helper.clearTable(component, helper);

    if (!dateStart || !dateEnd) {
      component.set("v.showSpinner", false);
      toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Erro",
        type: "Error",
        message: "Por favor, preencha os dois campos de data"
      });
      toastEvent.fire();
    } else {
      if (dateStart > dateEnd) {
        component.set("v.showSpinner", false);
        toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Erro",
          type: "Error",
          message: "A data de início não pode ser maior que a data fim"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.getAggregators");
        action.setParams({
          recordId: component.get("v.recordId"),
          startDate: component.get("v.startDate"),
          endDate: component.get("v.endDate"),
          status: component.find("cmbStatus").get("v.value")
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          component.set("v.showSpinner", false);
          console.log("aggregatos state: " + state);
          if (state === "SUCCESS") {
            console.log(
              "aggregatos result: " + JSON.stringify(response.getReturnValue())
            );
            if (response.getReturnValue().data != null) {
              component.set(
                "v.totalPages",
                Math.ceil(
                  response.getReturnValue().data.subscribersVas.length /
                    component.get("v.pageSize")
                )
              );
              component.set(
                "v.allData",
                response.getReturnValue().data.subscribersVas
              );
              component.set("v.currentPageNumber", 1);
              component.set("v.hasAggreggators", true);
              helper.buildData(component, helper);
            } 
            else 
            {
              let errors = response.getError();
              console.log("aggregator error. Details: " + JSON.stringify(errors));
              component.set("v.totalPages", 1);
              component.set("v.hasAggreggators", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                title: "Erro",
                type: "Error",
                message: "Não há serviços agregadores para este assinante"
              });
              toastEvent.fire();              
            }
          } else {
            let errors = response.getError();
            console.log("aggregator error. Details: " + JSON.stringify(errors));
            component.set("v.totalPages", 1);
            component.set("v.hasAggreggators", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Erro",
              type: "Error",
              message: "Não há serviços agregadores para este assinante"
            });
            toastEvent.fire();
          }
        });
        $A.enqueueAction(action);
      }
    }
  },

  openDetail: function(component, event, helper) {
    var modalBody;
    $A.createComponent(
      "c:CEC_360_AggregatorsDetails",
      {
        dataAggregator: event.target.getAttribute("data-Aggregator"),
        requestDescription: event.target.getAttribute(
          "data-requestDescription"
        ),
        expirationDate: event.target.getAttribute("data-expirationDate"),
        confirmationDate: event.target.getAttribute("data-confirmationDate"),
        cancellationDate: event.target.getAttribute("data-cancellationDate")
      },
      function(content, status) {
        if (status === "SUCCESS") {
          modalBody = content;
          component.find("overlayLib").showCustomModal({
            body: modalBody,
            showCloseButton: false,
            cssClass: "mymodal slds-modal_small",
            closeCallback: function() {}
          });
        }
      }
    );
  },

  onNext: function(component, event, helper) {
    var pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber + 1);
    helper.buildData(component, helper);
  },

  onPrev: function(component, event, helper) {
    var pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber - 1);
    helper.buildData(component, helper);
  },

  processMe: function(component, event, helper) {
    component.set("v.currentPageNumber", parseInt(event.target.name));
    helper.buildData(component, helper);
  },

  onFirst: function(component, event, helper) {
    component.set("v.currentPageNumber", 1);
    helper.buildData(component, helper);
  },

  onLast: function(component, event, helper) {
    component.set("v.currentPageNumber", component.get("v.totalPages"));
    helper.buildData(component, helper);
  },

  sortByDateConfirmationDate: function(component, event, helper) {
    helper.sortBy(component, helper, "confirmationDate");
  },

  sortByDateCancellation: function(component, event, helper) {
    helper.sortBy(component, helper, "cancellationDate");
  },

  sortByDateExpirationDate: function(component, event, helper) {
    helper.sortBy(component, helper, "expirationDate");
  }
});