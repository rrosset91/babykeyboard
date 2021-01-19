({
  buildData: function(component, helper) {
    var data = [];
    var pageNumber = component.get("v.currentPageNumber");
    var pageSize = component.get("v.pageSize");
    var allData = component.get("v.allData");
    var x = (pageNumber - 1) * pageSize;
    for (; x < pageNumber * pageSize; x++) {
      if (allData[x]) {
        data.push(allData[x]);
      }
    }
    component.set("v.data", data);

    helper.generatePageList(component, pageNumber);
  },

  clearTable: function(component, event, helper) {
    component.set("v.totalPages", 1);
    component.set("v.allData", null);
    component.set("v.data", null);
    component.set("v.currentPageNumber", 1);
  },

  generatePageList: function(component, pageNumber) {
    pageNumber = parseInt(pageNumber);
    var pageList = [];
    var totalPages = component.get("v.totalPages");
    if (totalPages > 1) {
      if (totalPages <= 10) {
        var counter = 2;
        for (; counter < totalPages; counter++) {
          pageList.push(counter);
        }
      } else {
        if (pageNumber < 5) {
          pageList.push(2, 3, 4, 5, 6);
        } else {
          if (pageNumber > totalPages - 5) {
            pageList.push(
              totalPages - 5,
              totalPages - 4,
              totalPages - 3,
              totalPages - 2,
              totalPages - 1
            );
          } else {
            pageList.push(
              pageNumber - 2,
              pageNumber - 1,
              pageNumber,
              pageNumber + 1,
              pageNumber + 2
            );
          }
        }
      }
    }
    component.set("v.pageList", pageList);
  },

  sortBy: function(component, helper, field) {
    var records = component.get("v.data");

    if (field == "confirmationDate") {
      var sortAsc = component.get("v.sortAscConfirm");
      component.set("v.sortAscConfirm", !sortAsc);
    }

    if (field == "cancellationDate") {
      var sortAsc = component.get("v.sortAscCancel");
      component.set("v.sortAscCancel", !sortAsc);
    }

    if (field == "expirationDate") {
      var sortAsc = component.get("v.sortAscExpiration");
      component.set("v.sortAscExpiration", !sortAsc);
    }

    if (records == null || records == undefined || records.length == 0) {
      return;
    }

    records.sort(function(a, b) {
      if (sortAsc) {
        if (a[field] > b[field]) {
          return 1;
        }
        if (a[field] < b[field]) {
          return -1;
        }
      } else {
        if (a[field] > b[field]) {
          return -1;
        }
        if (a[field] < b[field]) {
          return 1;
        }
      }
      return 0;
    });

    component.set("v.data", records);
  }
});