({
	createCase : function(component, event, helper) {
     /*   var createRecordEvent = $A.get('e.force:createRecord');
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'Case',
                'defaultFieldValues': {
                   
                }
            });
            createRecordEvent.fire();
        }*/
        
       
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/lightning/o/Case/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=MRU_LIST"
    });
    urlEvent.fire();
}
    
})