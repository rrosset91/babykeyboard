({
    doInit : function(component, event, helper) {
        var payload = event.getParams();
        console.log('payload ' + JSON.stringify(payload));
        var ura = '<b>URA:&nbsp&nbsp </b>';
        component.set("v.ura", ura);
        
        if(payload.recordUi.record.id == null){
            component.set("v.requestSupportTitle", null);
            component.set("v.isLoading", false);            
            console.log('Load Breadcrumb error');
            return;
        }
        var recordTypeName = payload.recordUi.record.recordTypeInfo.name;
        component.set("v.recordTypeName", recordTypeName);

        var requestSupport = payload.recordUi.record.fields.RequestSupport__c.value
        console.log('requestSupport ==============================> ' + requestSupport);
        var title;
        title = requestSupport != null && requestSupport != undefined && requestSupport.length > 200 ? requestSupport.substring(0,200) + '...' : requestSupport;
        component.set("v.requestSupportLabel", title);
        component.set("v.requestSupportTitle", requestSupport);
        component.set("v.isLoading", false);
    }
})