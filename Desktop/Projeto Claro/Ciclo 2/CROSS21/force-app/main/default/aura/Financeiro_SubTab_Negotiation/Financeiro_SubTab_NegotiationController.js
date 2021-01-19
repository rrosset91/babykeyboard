({
    init: function (component, event, helper) {
      var pageReference = component.get("v.pageReference");
      var rId = pageReference.state.c__crecordId;
      component.set("v.crecordId", rId);
    }
  });