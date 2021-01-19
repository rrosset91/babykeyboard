({
	doInit : function(component, event, helper) {
        var CEC_OmniScript;
        var action = component.get("c.getParametersByOmniscriptName");
        action.setParams({
            omniscriptName: "Atendimiento Sem Cliente"
        });
        action.setCallback(this, function(response) {
            CEC_OmniScript = response.getReturnValue();            
            var urlEvent = $A.get("e.force:navigateToURL");
            var url;
           
            url = "/apex/CEC_OmniScriptPage?strOmniScriptType="+CEC_OmniScript.strOmniScriptType__c+"&strOmniScriptSubType="+CEC_OmniScript.strOmniScriptSubType__c+"&strOmniScriptLang="+CEC_OmniScript.strOmniScriptLang__c+"&OSname="+CEC_OmniScript.MasterLabel;            

            urlEvent.setParams({
                "url": url,
                "isredirect": "true"
            });
            urlEvent.fire();
 
            //location = "/apex/CEC_OmniScriptPage?strOmniScriptType="+CEC_OmniScript.strOmniScriptType__c+"&strOmniScriptSubType="+CEC_OmniScript.strOmniScriptSubType__c+"&strOmniScriptLang="+CEC_OmniScript.strOmniScriptLang__c+"&OSname="+CEC_OmniScript.MasterLabel;
        });
        $A.enqueueAction(action);
	   
	}
})