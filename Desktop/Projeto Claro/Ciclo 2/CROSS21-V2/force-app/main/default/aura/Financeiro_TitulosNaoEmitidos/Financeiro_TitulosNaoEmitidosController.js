({
	doInit: function(component, event, helper) {
        // @note  83484 - Dados "Itens Títulos Não Emitidos"
        console.clear();
		helper.initialLoad(component);
	},
    
	onSort: function(component, event, helper){
		let fieldName = event.getParam('fieldName');
		const sortDirection = event.getParam('sortDirection');

		component.set('v.sortedBy', fieldName);
		component.set('v.sortedDirection', sortDirection);

		let allInvoices = component.get('v.wrapper.groupDebts');

		if(!allInvoices)
            return;
            
		helper.sortData(component, fieldName, sortDirection, allInvoices);
    },
    
    handleRowAction: function (component, event, helper) {
        // debugger;
		const selectedRows = event.getParam('selectedRows');
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.showRowDetails(component, event, helper, row);
                break;
            
            default:
                helper.showRowDetails(component, event, helper, row);
                break;
        }
    },
    closeModal: function(component, event, helper){
		component.find('detailModal').close();
    },
})