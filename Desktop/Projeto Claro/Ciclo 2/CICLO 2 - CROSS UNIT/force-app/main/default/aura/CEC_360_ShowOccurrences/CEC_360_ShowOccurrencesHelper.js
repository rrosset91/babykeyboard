({
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

  validScreen: function(component, event, helper) {
    var startDate = component.get("v.startDate");
    var endDate = component.get("v.endDate");
    var protocolNumber = component.get("v.protocolNumber");

    if (startDate != null && endDate != null) {
      var month1 = startDate.substring(5, 7) - 1;
      var month2 = endDate.substring(5, 7) - 1;
      var date1 = new Date(
        startDate.substring(0, 4),
        month1,
        startDate.substring(8, 10)
      );
      var date2 = new Date(
        endDate.substring(0, 4),
        month2,
        endDate.substring(8, 10)
      );
      var timeDiff = Math.abs(date2.getTime() - date1.getTime());
      var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
      var today = new Date();
      var diffYears = (today.getTime() - date1.getTime()) / 1000;
      diffYears /= 60 * 60 * 24;
      diffYears = Math.abs(Math.round(diffYears / 365.25));
    }

    if (!startDate || !endDate) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Erro",
        type: "Error",
        message: "Por favor, preencha todos os campos."
      });
      toastEvent.fire();
      return false;
    } else if (date1 > date2) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Erro",
        type: "Error",
        message: "A data início não pode ser maior  que  a data fim."
      });
      toastEvent.fire();
    } else if (diffDays > 185) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Erro",
        type: "Error",
        message: "O período máximo de consulta é de seis meses."
      });
      toastEvent.fire();
    } else {
      return true;
    }
  },

  isDateSearch: function(component, event, helper) {
    component.set("v.isSearching", true);
    console.log("startDate: " + component.get("v.startDate"));
    console.log("endDate: " + component.get("v.endDate"));
    console.log("contractNumber: " + component.get("v.contractNumber"));

    var action = component.get("c.getOrdemsfromData");
    action.setParams({
      startDate: component.get("v.startDate"),
      endDate: component.get("v.endDate"),
      contractNumber: component.get("v.contractNumber")
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log('state: ' + state);

      component.set("v.isSearching", false);
      if (state === "SUCCESS") {
       var result = response.getReturnValue();
       console.log('result: ' + JSON.stringify(result));

        if (result.length != 0 && result.length != null) {
          component.set("v.showTable", true);
          component.set("v.ordersItem", result);
          var test = component.get("v.ordersItem");
        } else {
          component.set("v.showTable", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Erro",
            type: "Error",
            message:
              "Não foram encontradas ocorrências para o serviço selecionado."
          });
          toastEvent.fire();
        }
      } else {
        component.set("v.showTable", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Erro",
          type: "Error",
          message: "Não há ordens de serviço para o período selecionado."
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },

  sortBy: function(component, helper) {
    var dateOrderField = "creationDate";
    var sortAsc = component.get("v.sortAsc");
    component.set("v.sortAsc", !sortAsc);
    var records = [];
    records = component.get("v.ordersItem");
    if (records == null || records == undefined || records.length == 0) {
      return;
    }

    records = records.sort(function(a, b) {
      let regex = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2})\:(\d{2})/;
      let day, month, year, hours, minutes;
      let regexResult;

      var dateAString = a[dateOrderField].replace("às ", "");
      regexResult = regex.exec(dateAString);
      day = regexResult[1];
      month = regexResult[2];
      year = regexResult[3];
      hours = regexResult[4];
      minutes = regexResult[5];
      var dateA = new Date(year, month, day, hours, minutes);

      var dateBString = b[dateOrderField].replace("às ", "");
      regexResult = regex.exec(dateBString);
      day = regexResult[1];
      month = regexResult[2];
      year = regexResult[3];
      hours = regexResult[4];
      minutes = regexResult[5];
      var dateB = new Date(year, month, day, hours, minutes);

      if (sortAsc) {
        if (dateA > dateB) {
          return 1;
        }
        if (dateA < dateB) {
          return -1;
        }
      } else {
        if (dateA > dateB) {
          return -1;
        }
        if (dateA < dateB) {
          return 1;
        }
      }
      return 0;
    });
    component.set("v.ordersItem", records);
    var res = component.get("v.ordersItem");
    console.log("dateList inverse: " + JSON.stringify(res));
  }
});