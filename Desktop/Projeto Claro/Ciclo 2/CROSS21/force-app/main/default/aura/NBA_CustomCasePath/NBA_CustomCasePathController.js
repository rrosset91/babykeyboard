({
	doInit: function (component, event, helper) {
		component.set('v.showSpinner', true);
        helper.consultarCase(component, event, event.getParams().changeType);

	},
    closemodal: function(component, event, helper){
		component.set('v.showModal', false);
		component.set('v.showSpinner', false);

	},
    updateStage: function(component, event, helper){
		component.set('v.showSpinner', true);
		var index = event.currentTarget.id;
		if(index == undefined){
			let stages = component.get('v.stages');
			index = stages.findIndex(stage => stage.label == 'Encerramento do atendimento');
		}
		helper.updateStageHelper(component, index);
	},

	checkAction: function(component, event, helper) {
		let stages = component.get('v.stages');

		let currentStage = stages.find(stage => stage.current);

		if (currentStage.label == 'Ofertas') {
			component.set('v.showSpinner', true);
			
			let pageEvent = $A.get('e.c:NBA_PageEvent');
			pageEvent.setParams({'action' : 'RESET_ORDER'});

			pageEvent.fire();
		} else {
			let index = stages.findIndex(stage => stage.label == 'Encerramento do atendimento');
			helper.updateStageHelper(component, index);
		}
	},

	/* #### REVER ####*/
    refreshFocusedTab : function(component, event, helper){
        helper.refreshFocusedTab(component, event);
    },
	/* #### REVER ####*/
    recordUpdated: function(component, event, helper){
        helper.consultarCase(component, event, event.getParams().changeType);
	},

	handlePageEvent: function(component, event, helper) {
		if (event.getParam('action') == 'FINISH_CASE') {
			let stages = component.get('v.stages');
			let index = stages.findIndex(stage => stage.label == 'Encerramento do atendimento');
			helper.updateStageHelper(component, index);
		}
    }
})