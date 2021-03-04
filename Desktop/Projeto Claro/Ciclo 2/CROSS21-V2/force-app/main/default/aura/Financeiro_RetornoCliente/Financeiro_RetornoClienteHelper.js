({
	initialLoad : function(component) {
		this.showWarning(component);
	},
    
           
    showWarning : function (component, event, helper) {
    var showWarning = component.get('v.showWarning');
        if(!showWarning)
        return helper.showToast('Contestação inválida para BackOffice', 'Os valores selecionados para contestação estão acima de sua alçada.', 'warning');
    }  
})