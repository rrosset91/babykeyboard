({
    doInit : function(component, event, helper) {
        component.set("v.isDate.",false);
        helper.setDates(component,event,helper);
        var action = component.get("c.getContracts");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        var inputsel = component.find("cmbContract");
        var opts=[];
        action.setCallback(this, function(action) {
            for(var i=0;i< action.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: action.getReturnValue()[i], value: action.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);
        });
        $A.enqueueAction(action);
        
    },
    
    enableData : function(component,event,helper){
        component.set("v.isDate",false);
        component.set("v.isNumber",true);
        component.set("v.protocolNumber",null);
        helper.setDates(component,event,helper);
    },
    
    enableNumber : function(component,event,helper){
        component.set("v.isDate",true);
        component.set("v.isNumber",false);
        component.set("v.protocolNumber",null);
        component.set("v.startDate",null);
        component.set("v.endDate",null);
    },
    
    getOrders : function(component,event, helper){
        component.set("v.showTable",false);
        var validScreen = helper.validScreen(component,event,helper);
        if(validScreen){
            if(component.get("v.isDate") == false){
                helper.isDateSearch(component,event,helper);
            }else{
                helper.isProtocolSearch(component,event,helper);
            }
        }
     },
    
    expandDetails : function(component,event,helper){
        var list = component.get("v.ordersItem");
        var index = event.getSource().get("v.value");
        list[index].showDetails = !list[index].showDetails;
        component.set("v.ordersItem",list);
    },
    
    enableSearch : function(component,event,helper){
        component.set("v.enableSearch",false);
    }
    
    
    
})