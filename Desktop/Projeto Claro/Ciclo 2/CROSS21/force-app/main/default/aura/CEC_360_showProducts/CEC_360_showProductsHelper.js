({
  getContracts: function(component, event, helper) {
    var action = component.get("c.getBillingAccount");
    action.setParams({
      parentId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        for (var i = 0; i < result.length; i++) {
          var str = result[i].contractNumber;
          if (result[i].street != null) {
            str += " - " + result[i].street;
          } else if (result[i].numberAd != null) {
            str += ", " + result[i].numberAd;
          } else if (result[i].complement != null) {
            str += " - " + result[i].complement;
          } else {
            result[i].contractNumber = str;
          }
          result[i].contractNumber = str;
        }
        component.set("v.actContracts", result);
        if (result.length != 0) {
          component.set("v.noAsset", false);
        } else {
          component.set("v.noAsset", true);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getPreAssets: function(component, event, helper) {
    var action = component.get("c.getPreAssets");
    action.setParams({
      id: component.get("v.recordId"),
      recordType: "CECMovelPreControle"
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          component.set("v.hasMovPre", true);
          component.set("v.noAssetPre", false);
          for (var i = 0; i < result.length; i++) {
            result[i].Msisdn__c = this.formatMSISDN(result[i].Msisdn__c);
            result[i].MSISDN__c = this.formatMSISDN(result[i].MSISDN__c);
          }
          component.set("v.movpreList", result);
          console.dir(result);
        } else {
          component.set("v.noAssetPre", true);
        }
      }
    });
    $A.enqueueAction(action);
  },

  FormatNumber: function(component, result) {
    for (var i = 0; i < result.length; i++) {
      result[i].msisdn = this.formatMSISDN(result[i].msisdn);
    }
    console.dir(result);
    component.set("v.cancContracts", result);
    component.set("v.hasSpinner2", false);
  },

  getCleanExpandableContract: function(component, event, helper, index) {
    var list = component.get("v.actContracts");

    for (var i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isExpandable = false;
      }
    }
    component.set("v.actContracts", list);
    console.log("contracts 2: " + JSON.stringify(list));
    console.dir(list);
  },

  getCleanExpandableTV: function(component, event, helper, index) {
    var list = component.get("v.tvList");
    component.set("v.tvSubList", null);
    for (var i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isExpandable = false;
      }
    }
    component.set("v.tvList", list);
    console.dir(list);
  },

  getCleanExpandableTell: function(component, event, helper, index) {
    var list = component.get("v.tellList");
    component.set("v.tellSubList", null);
    for (var i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isExpandable = false;
      }
    }
    component.set("v.tellList", list);
    console.dir(list);
  },

  getCleanExpandableNet: function(component, event, helper, index) {
    var list = component.get("v.netList");
    component.set("v.netSubList", null);
    for (var i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isExpandable = false;
        list[i].msisdn = this.formatMSISDN(list[i].msisdn);
      }
    }
    component.set("v.netList", list);
    console.dir(list);
  },

  getCleanExpandableMov: function(component, event, helper, index) {
    var list = component.get("v.movList");
    component.set("v.movSubList", null);
    for (var i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isExpandable = false;
      }
    }
    component.set("v.movList", list);
    console.dir(list);
  },

  /* ----------------------- Resgatando Informações  -----------------------*/
  getAssetsTV: function(component, event, helper, contractId) {
    console.log("getAssetsTV");
    var action = component.get("c.getAssets");
    action.setParams({
      id: contractId,
      recordType: "CECTV"
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("state: " + state);
        var result = response.getReturnValue();
        console.log("result: " + result);
        if (result.length != 0) {
            for (var i = 0; i < result.length; i++) {
                result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                var res = result[i].Preco;
                if (res != null) {
                  result[i].Preco = res.toFixed(2);
                  var rep = result[i].Preco.replace(".", ",");
                  res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                  var cash = "R$";
                  result[i].Preco = cash.concat(res);
                }
              }
          component.set("v.hasTV", true);
          component.set("v.tvList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getAssetsTell: function(component, event, helper, contractId) {
    console.log("getAssetsTell");
    var action = component.get("c.getAssets");
    action.setParams({
      id: contractId,
      recordType: "CECFixo"
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          for (var i = 0; i < result.length; i++) {
            result[i].msisdn = this.formatMSISDN(result[i].msisdn);
            var res = result[i].Preco;
            if (res != null) {
              result[i].Preco = res.toFixed(2);
              var rep = result[i].Preco.replace(".", ",");
              res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
              var cash = "R$";
              result[i].Preco = cash.concat(res);
            }
          }
          component.set("v.hasTell", true);
          component.set("v.tellList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getSubAssetsTV: function(component, event, helper, accountId, spotid) {
    console.log("getSubAssetsTV");
    var action = component.get("c.getSubAssetsRes");
    action.setParams({
      AccountId: accountId,
      SpotId: spotid
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("getSubAssetsTV Result: " +JSON.stringify(result));
        if (result.length != 0) {
          for (var i = 0; i < result.length; i++) {
            var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
            }
          }
          component.set("v.hasSubTV", true);
          component.set("v.tvSubList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getAssetsNet: function(component, event, helper, contractId) {
    console.log("getAssetsNet");
    var action = component.get("c.getAssets");
    action.setParams({
      id: contractId,
      recordType: "CECInternetFixa"
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
            for (var i = 0; i < result.length; i++) {
                result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                var res = result[i].Preco;
                if (res != null) {
                  result[i].Preco = res.toFixed(2);
                  var rep = result[i].Preco.replace(".", ",");
                  res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                  var cash = "R$";
                  result[i].Preco = cash.concat(res);
                }
              }
          component.set("v.netList", result);
          component.set("v.hasNet", true);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getSubAssetsTell: function(component, event, helper, accountId, spotid) {
    console.log("getSubAssetsTell");
    var action = component.get("c.getSubAssetsRes");
    action.setParams({
      AccountId: accountId,
      SpotId: spotid
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          for (var i = 0; i < result.length; i++) {
            result[i].msisdn = this.formatMSISDN(result[i].msisdn);
            var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
            }
          }
          component.set("v.hasSubTell", true);
          component.set("v.tellSubList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getSubAssetsNet: function(component, event, helper, accountId, spotid) {
    console.log("getSubAssetsNet");
    var action = component.get("c.getSubAssetsRes");
    action.setParams({
      AccountId: accountId,
      SpotId: spotid
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          for (var i = 0; i < result.length; i++) {
            result[i].msisdn = this.formatMSISDN(result[i].msisdn);
            var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
            }
          }
          component.set("v.hasSubNet", true);
          component.set("v.netSubList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getAssetsMov: function(component, event, helper, contractId) {
    console.log("getAssetsMov");
    console.log("contractId: " + contractId);
    var recordType = component.get("v.recordList");
    console.log("recordType: " + recordType);
    var action = component.get("c.getAssets");
    action.setParams({
      id: contractId,
      recordType: recordType
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();

        console.log("resultMOV: " + JSON.stringify(result));

        if (result.length != 0) {
          component.set("v.hasMov", true);
          for (var i = 0; i < result.length; i++) {
            result[i].msisdn = this.formatMSISDN(result[i].msisdn);
            var res = result[i].Preco;
            if (res != null) {
              result[i].Preco = res.toFixed(2);
              var rep = result[i].Preco.replace(".", ",");
              res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
              var cash = "R$";
              result[i].Preco = cash.concat(res);
            }
          }
          component.set("v.movList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getSubAssetsMov: function(component, event, helper, msisdn) {
    console.log("getSubAssetsMov");
    var action = component.get("c.getSubAssetsMov");
    action.setParams({
      msisdn: msisdn
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          for (var i = 0; i < result.length; i++) {
            result[i].msisdn = this.formatMSISDN(result[i].msisdn);
            var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
            }
          }
          component.set("v.hasSubMov", true);
          component.set("v.movSubList", result);
        }
      }
    });
    $A.enqueueAction(action);
  },

  getlstRecords: function(component, event, helper) {
    var action = component.get("c.getRecordType");
    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result.length != 0) {
          component.set("v.hasSubMov", true);
          component.set("v.recordList", result);
          console.log("lstRecords: " + JSON.stringify(result));
        }
      }
    });
    $A.enqueueAction(action);
  },

  /* ----------------------- Métodos de Tratativa de Dados ----------------------- */
  formatMSISDN: function(msi) {
    console.log("formatMSISDN" + msi);
    console.log(msi);
    var inputValue = msi;
    if (msi) {
      var rep = msi.replace(/[^0-9]/g, "");
      var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
      inputValue = res.substring(0, 15);
      if (msi.length >= 11) {
        var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
        inputValue = res.substring(0, 15);
      }
    }
    console.log(inputValue);
    return inputValue;
  },

  formatCash: function(cash) {
    console.log("formatCash: " + cash);
    var inputValue = cash;
    var lastChar = cash.substring(cash.length - 1);
    if (cash.includes(".")) {
      console.log("entrou cash: " + cash);
    }
    console.log(inputValue);
    return inputValue;
  },

  setDates: function(component, event, helper) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var todaySubtract = new Date();
    var todayPlus = new Date();
    todayPlus = $A.localizationService.formatDate(todayPlus, "YYYY-MM-DD");
    todaySubtract.setDate(todaySubtract.getDate() - 60);
    todaySubtract = $A.localizationService.formatDate(
      todaySubtract,
      "YYYY-MM-DD"
    );
    component.set("v.startDate", todaySubtract);
    component.set("v.endDate", todayPlus);
    var todayYear = new Date();
    todayYear.setYear(todayYear.getFullYear() - 5);
    todayYear = $A.localizationService.formatDate(todayYear, "YYYY-MM-DD");
    var todaySum = new Date();
    todaySum.setDate(todaySum.getDate() + 30);
    todaySum = $A.localizationService.formatDate(todaySum, "YYYY-MM-DD");
    component.set("v.minDate", todayYear);
    component.set("v.maxDate", todaySum);
  },

  fillContracts: function(component, event, helper) {
    var action = component.get("c.fillContracts");
    action.setParams({
      parentId: component.get("v.recordId")
    });
    var opts = [];
    action.setCallback(this, function(action) {
      console.dir(action.getReturnValue());
      for (var i = 0; i < action.getReturnValue().length; i++) {
        opts.push({
          class: "optionClass",
          label: action.getReturnValue()[i],
          value: action.getReturnValue()[i]
        });
      }
      component.set("v.options", opts);
      component.set("v.contSpinner", false);
    });
    $A.enqueueAction(action);
  },

  sortBy: function(component, helper, field) {
    var sortAsc = component.get("v.sortAsc");
    console.log("sortAsc: " + sortAsc);
    var records = component.get("v.cancContracts");
    console.log("cancContracts: " + JSON.stringify(records));
    component.set("v.sortAsc", !sortAsc);
    console.log("sortAsc revese: " + !sortAsc);

    if (records == null || records == undefined || records.length == 0) {
      console.log("entrou: " + !sortAsc);
      return;
    }

    records.sort(function(a, b) {
      if (sortAsc) {
        if (a[field] > b[field]) {
          console.log("entrou2: ");
          return 1;
        }
        if (a[field] < b[field]) {
          console.log("entrou3: ");
          return -1;
        }
      } else {
        if (a[field] > b[field]) {
          console.log("entrou4: ");
          return -1;
        }
        if (a[field] < b[field]) {
          console.log("entrou5: ");
          return 1;
        }
      }
      return 0;
    });

    console.log("entrou6");
    component.set("v.sortField", field);
    console.log("sortField full: ");
    component.set("v.cancContracts", records);
  }
});