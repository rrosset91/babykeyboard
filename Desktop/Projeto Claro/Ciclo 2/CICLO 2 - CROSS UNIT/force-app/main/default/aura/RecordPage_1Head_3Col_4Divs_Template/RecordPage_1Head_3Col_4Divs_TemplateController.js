({
	toggleSectionHeader : function(component, event, helper) {
        component.set('v.isHeaderCollapsed', !component.get('v.isHeaderCollapsed'));
    },

	toggleSectionSidebarLeft : function(component, event, helper) {
        component.set('v.isSidebarLeftCollapsed', !component.get('v.isSidebarLeftCollapsed'));
    },
    
    toggleSectionSidebarRight : function(component, event, helper) {
        component.set('v.isSidebarRightCollapsed', !component.get('v.isSidebarRightCollapsed'));
    },

	expandContractAll : function(component, event, helper){
		component.set('v.isAllCollapsed', !component.get('v.isAllCollapsed'));
		if(component.get('v.isAllCollapsed')){
			component.set('v.isHeaderCollapsed', true);
			component.set('v.isSidebarLeftCollapsed', true);
			component.set('v.isSidebarRightCollapsed', true);
		}
		else {
			component.set('v.isHeaderCollapsed', false);
			component.set('v.isSidebarLeftCollapsed', false);
			component.set('v.isSidebarRightCollapsed', false);
		}		
	},
	
    updateLayout: function(component, event, helper){
		if(component.get('v.caseRecord').Time_of_Service__c == 'Sondagem')
			component.set('v.isPolling', true);
		else if(component.get('v.caseRecord').Time_of_Service__c == 'Ação')
			component.set('v.isAction', true);
		else if(component.get('v.caseRecord').Time_of_Service__c == 'Ofertas')
			component.set('v.isOffer', true);
		else if(component.get('v.caseRecord').Time_of_Service__c == 'Encerramento do atendimento')
			component.set('v.isEnding', true);
		
        if(component.get('v.isFirstMoment'))
            component.set('v.isFirstMoment', false);
        else{
            component.set('v.showPath', false);
            component.set('v.showPath', true);
        }
    },
    
    updateMoment: function(component, event, helper){
		component.set('v.isPolling', false);
		component.set('v.isAction', false);
		component.set('v.isOffer', false);
		component.set('v.isEnding', false);
		
		component.find('recordData').reloadRecord(true); 
    }

})