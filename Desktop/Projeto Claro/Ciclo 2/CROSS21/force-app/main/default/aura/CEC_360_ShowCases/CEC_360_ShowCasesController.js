({
    doInit: function(component, event, helper)
    {
        helper.setDates(component, event, helper);
        helper.getPicklistValueByLabel(component, event, helper);
        helper.getCriticalChannels(component, event, helper);
        //helper.setCaseType(component, event, helper);
        helper.setIsMobile(component, event, helper);        
    },
    
    retCaseData: function(component, event, helper)
    {       
        helper.setCase(component, event, helper); 
                         
    },
    
    handleChangesDate: function(component, event, helper) 
    {
        console.log(component.find("startDate").get("v.value"));
        console.log(component.find("endDate").get("v.value"));
        if(component.find("startDate").get("v.value") == null || component.find("endDate").get("v.value") == null)
            component.set("v.isSearch", true);
        else 
            component.set("v.isSearch", false);
    },
    
    expandDetails: function(component, event, helper) {
        var list = component.get("v.lstCases");
        var index = event.getSource().get("v.value");
        list[index].showDetails = !list[index].showDetails;
        component.set("v.lstCases", list);
    },
    
    makeAction: function(component, event, helper)
    {
        component.set("v.hasValue", true);
    },
    
    createNewCase: function(component, event, helper)
    {
       /* var windowRedirect = window.location.href; 
       
        var createEvent = $A.get("e.force:createRecord");
        createEvent.setParams({
            "entityApiName": 'Case',
            'defaultFieldValues': {
                "OwnerId": component.get("v.userId"),
                "AccountId" : component.get("v.recordId")
            },
            "panelOnDestroyCallback": function(event) {
                window.location.href = windowRedirect; 
            }
        });
        createEvent.fire();*/
        let createEvent = $A.get("e.force:navigateToURL");
        createEvent.setParams({
          "url": "/lightning/o/Case/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=MRU_LIST"
        });
        createEvent.fire();
    }
})