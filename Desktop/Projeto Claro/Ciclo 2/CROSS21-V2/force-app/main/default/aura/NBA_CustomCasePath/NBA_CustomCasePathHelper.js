({
    consultarCase: function (component, event, changeType) {
		console.log('#### consultarCase');
		var action = component.get('c.consultarCase');
        action.setParams({"recordId": component.get('v.recordId')});
        action.setCallback(this, function (response) {
            if(response.getState()==="SUCCESS") {
                component.set('v.case', response.getReturnValue());
				this.consultarStagesHelper(component, event);
			}
			else{
				component.set('v.showSpinner', false);
                var errors = action.getError();
                if (errors)
                    if (errors[0] && errors[0].message)
                        this.toastEvent('Erro ao consultar!', errors[0].message, 'error')
            }
        });
        $A.enqueueAction(action);
    },
    consultarStagesHelper: function (component, event) {
		console.log('#### consultarStagesHelper');
        var action = component.get('c.consultarStages');
        action.setParams({ "caseSerial": JSON.stringify(component.get("v.case")) });
        action.setCallback(this, function (response){
            if (response.getState() === "SUCCESS") 
                component.set('v.stages', response.getReturnValue());
			else{
                var errors = action.getError();
                if (errors)
                    if (errors[0] && errors[0].message)
                        this.toastEvent('Erro ao consultar!', errors[0].message, 'error')
            }
			component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    updateStageHelper: function (component, index) {

        let currentStage = component.get('v.stages')[index].label;        
        if (currentStage == "Encerramento do atendimento" && component.get('v.showModal')== false) {
            component.set('v.showSpinner', false);
            component.set('v.showModal', true);
        }else{
            this.updateStageHelperCallback(component, index);
        }
    },
    updateStageHelperCallback: function (component, index) {
        component.set('v.showSpinner', true);

        var action = component.get("c.updateStageCase");
        action.setParams({
            "valor": component.get('v.stages')[index].label,
            "caseId": component.get('v.recordId'),
            "stages": JSON.stringify(component.get('v.stages'))
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.stages', response.getReturnValue());
                this.toastEvent('Sucesso!', 'Momento do atendimento alterado com sucesso!', 'success');
				console.log('#### refresh 1');
                component.getEvent("refresh").fire();
            }
			else {
                var errors = action.getError();
                if (errors)
                    if (errors[0] && errors[0].message)
                        this.toastEvent('Erro ao consultar!', errors[0].message, 'error')
            }
            component.set('v.showSpinner', false);

            component.set('v.showModal', false);

        });
        $A.enqueueAction(action);
    },
	/* #### REVER ####*/
    refreshFocusedTab: function (component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            workspaceAPI.refreshTab({
                tabId: response.tabId,
                includeAllSubtabs: true
            });
        }).catch(function (error) {});
    },	
	/* #### REVER ####*/
	toastEvent: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})