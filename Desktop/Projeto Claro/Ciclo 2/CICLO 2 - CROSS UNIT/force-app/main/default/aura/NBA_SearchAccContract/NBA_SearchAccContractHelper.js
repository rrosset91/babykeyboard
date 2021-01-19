({
    toastEvent: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

	getParameterUrl : function(param) {
        
        var url_string = window.location.href;
        var url = new URL(url_string);
        var c = url.searchParams.get(param);
        return c;
        
    },
    
    getContractId: function(component, event, helper){
        var contractNumber = component.get('v.contractNumber');
        var cityCode = component.get('v.cityCode');
        
        var indexEnv = window.location.href.search('/c/NBA_URA.app');
		var actualEnv = window.location.href.substr(0,indexEnv);
        var vctfound = true;
		
        if(vctfound){
            var action = component.get("c.toRecuperaIdContrato");
            action.setParams({
                "numberContract": contractNumber,
                "codeCity": cityCode
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
				var gotourl = $A.get("e.force:navigateToURL");
				helper.closeFocusedTab(component, helper);
				if (state === "SUCCESS") {
                    var result = response.getReturnValue();
					gotourl.setParams({"url": actualEnv+'/lightning/r/Contract/'+result+'/view'});
                }
				else {
                    alert('Contrato não encontrado!');
                    vctfound = false;
					gotourl.setParams({"url": actualEnv + '/lightning/o/Contract/list'});
                }
				gotourl.fire();
            });
            $A.enqueueAction(action);           
        } 
    },
    
    closeFocusedTab : function(component, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
    
})