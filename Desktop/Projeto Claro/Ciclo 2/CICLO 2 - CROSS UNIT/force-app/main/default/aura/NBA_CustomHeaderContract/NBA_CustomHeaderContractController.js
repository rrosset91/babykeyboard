({
    doInit : function(component, event, helper){
   
      helper.searchContract(component, event);   
   },
   
   handleClick : function(component, event, helper){
   
      helper.getAccount(component, event);   
   },
    
	editRecord : function(component, event, helper) {
		var editRecordEvent = $A.get("e.force:editRecord");
		editRecordEvent.setParams({
         "recordId": component.get("v.recordId")
		});
    editRecordEvent.fire();
	}
})