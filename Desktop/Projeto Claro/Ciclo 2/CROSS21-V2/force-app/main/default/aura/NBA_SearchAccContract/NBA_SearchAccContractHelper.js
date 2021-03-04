({
    navigate: function (component, event, helper) {
        var action = component.get("c.toRecuperaIdContrato");
        action.setParams({
            "numberContract": component.get("v.pageReference.state.c__contractnumber"),
            "codeCity": component.get("v.pageReference.state.c__citycode")
        });
        action.setCallback(this, function (responseBack) {
            var workspaceAPI = component.find("workspaceAPI");
            var navService = component.find("navService");
            workspaceAPI.getFocusedTabInfo().then(function (responseTab) {
                workspaceAPI.closeTab({ tabId: responseTab.tabId });
                if (responseBack.getState() === "SUCCESS")
                    workspaceAPI.openTab({ url: '#/sObject/' + responseBack.getReturnValue() + '/view', focus: true });
                else {
                    alert('Contrato não encontrado!');
                    navService.navigate({ type: 'standard__objectPage', attributes: { objectApiName: 'Contract', actionName: 'home' } });
                }
            });
        });
        $A.enqueueAction(action);
    }
})