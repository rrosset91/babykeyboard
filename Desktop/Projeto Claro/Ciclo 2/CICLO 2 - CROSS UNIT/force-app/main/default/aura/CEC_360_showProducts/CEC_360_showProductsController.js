({
  doInit: function(component, event, helper) {
    helper.getContracts(component, event, helper);
    helper.getPreAssets(component, event, helper);
    helper.setDates(component, event, helper);
    helper.fillContracts(component, event, helper);
    helper.getlstRecords(component, event, helper);
  },

  sortByDate: function(component, event, helper) {
    helper.sortBy(component, helper, "Cancelado em");
  },

  openDetailPage: function(component, event) {
    var navEvt = $A.get("e.force:navigateToSObject");
    var id = event.target.getAttribute("data-id");
    navEvt.setParams({
      recordId: id
    });

    navEvt.fire();
  },

  expandTable: function(component, event, helper) {
    component.set("v.hasTV", false);
    component.set("v.hasTell", false);
    component.set("v.hasNet", false);
    component.set("v.hasMov", false);
    component.set("v.hasSpinner", true);
    component.set("v.tvList", null);
    component.set("v.tellList", null);
    component.set("v.netList", null);
    component.set("v.movList", null);

    var list = component.get("v.actContracts");
    var index = event.getSource().get("v.value");
    helper.getCleanExpandableContract(component, event, helper, index);

    var contractId = list[index].Id;

    helper.getAssetsTV(component, event, helper, contractId);
    helper.getAssetsTell(component, event, helper, contractId);
    helper.getAssetsNet(component, event, helper, contractId);
    helper.getAssetsMov(component, event, helper, contractId);
    list[index].isExpandable = !list[index].isExpandable;
    component.set("v.actContracts", list);
    component.set("v.hasSpinner", false);
  },

  expandTVSubTable: function(component, event, helper) {
    var list = component.get("v.tvList");
    var index = event.target.getAttribute("data-ex");
    helper.getCleanExpandableTV(component, event, helper, index);
    list[index].isExpandable = !list[index].isExpandable;

    component.set("v.tvList", list);
    var accountId = list[index].AccountId;
    var spotid = list[index].spotid;
    helper.getSubAssetsTV(component, event, helper, accountId, spotid);
  },

  expandTellSubTable: function(component, event, helper) {
    var list = component.get("v.tellList");
    var index = event.target.getAttribute("data-ex");
    list[index].isExpandable = !list[index].isExpandable;
    helper.getCleanExpandableTell(component, event, helper, index);
    component.set("v.tellList", list);
    var accountId = list[index].AccountId;
    var spotid = list[index].spotid;
    helper.getSubAssetsTell(component, event, helper, accountId, spotid);
  },

  expandNetSubTable: function(component, event, helper) {
    var list = component.get("v.netList");
    var index = event.target.getAttribute("data-ex");
    helper.getCleanExpandableNet(component, event, helper, index);
    list[index].isExpandable = !list[index].isExpandable;
    component.set("v.netList", list);
    var accountId = list[index].AccountId;
    var spotid = list[index].spotid;
    helper.getSubAssetsNet(component, event, helper, accountId, spotid);
  },

  expandMovSubTable: function(component, event, helper) {
    var list = component.get("v.movList");
    var index = event.target.getAttribute("data-ex");
    helper.getCleanExpandableMov(component, event, helper, index);
    list[index].isExpandable = !list[index].isExpandable;
    component.set("v.movList", list);
    var msisdn = list[index].msisdn;
    helper.getSubAssetsMov(component, event, helper, msisdn);
  },

  getCancelAssets: function(component, event, helper) {
    component.set("v.hasSpinner2", true);
    var dtInit = component.get("v.startDate");
    console.log("datainit: " + dtInit);
    var dtFin = component.get("v.endDate");
    console.log("dataFin: " + dtFin);

    var action = component.get("c.getCaAssets");

      action.setParams({
        id: component.get("v.recordId"),
        dataIn: component.get("v.startDate"),
        dataFim: component.get("v.endDate"),
        contractNumber: component.get("v.contractNumber")
      });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("sucesso");
        var result = response.getReturnValue();
        
          helper.FormatNumber(component, result);
      
        if (result.length == 0) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Erro",
            type: "Error",
            message: "Não há produtos cancelados para o período buscado."
          });
          toastEvent.fire();
          console.log("erro");
        } else {
          component.set("v.hasCancel", true);
          console.log("erro2");
        }
      }
    });
    $A.enqueueAction(action);
  }
});