({
  doInit: function(component, event, helper) {
    helper.setDates(component, event, helper);
    var action = component.get("c.getContractNumberBillingAccount");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.contractNumber", response.getReturnValue());
      }
    });

    $A.enqueueAction(action);
  },

  retInvoiceData: function(component, event, helper) {
    component.set("v.showTable", true);
    var validScreen = helper.validScreen(component, event, helper);
    if (validScreen) {
      helper.isDateSearch(component, event, helper);
    
    }
  },

  expandDetails: function(component, event, helper) {
    var list = component.get("v.ordersItem");
    var index = event.getSource().get("v.value");
    list[index].showDetails = !list[index].showDetails;
    console.log('result: ' + JSON.stringify(list));
    component.set("v.ordersItem", list);
    for(var i=0; i < list; i++)
          {
            var numberZ = list[i].number_Z;
            console.log('log do number_Z: ' + numberZ);
                    }
  },

  sortByDate: function(component, event, helper) {
    helper.sortBy(component, helper);
},
});