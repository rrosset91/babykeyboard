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
    
   
   
    getOrders : function(component,event, helper){
        component.set("v.showTable",false);
        var validScreen = helper.validScreen(component,event,helper);
        if(validScreen){
            helper.isDateSearch(component,event,helper);
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