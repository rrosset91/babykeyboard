({
    doInit : function(component, event, helper) {
        
        helper.getAssetsTV(component,event,helper);
        helper.getAssetsTell(component,event,helper);
        helper.getAssetsNet(component,event,helper);
        helper.getAssetsMov(component,event,helper);        
    },
    
    openDetailPage: function(component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.getAttribute("data-id");
        navEvt.setParams({
          recordId: id
        });
    
        navEvt.fire();
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
})