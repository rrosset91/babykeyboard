({
	doInit : function(component, event, helper) {
		helper.getCaseRecord(component);
	},
    doCancelar : function(component, event, helper){
        let caseId = component.get('v.recordId');
        let url = helper.getUrlCancelar(caseId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    doReagendar : function(component, event, helper){
        let caseId = component.get('v.recordId');
        let url = helper.getUrlReagendar(caseId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
})