({
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    
    endDateChange: function(component, event, helper) {
        helper.setSearchButtonDisabled(component, event, helper);
    },
    
    startDateChange: function(component, event, helper) {
		helper.setSearchButtonDisabled(component, event, helper);
    },
    
    search: function(component, event, helper) {
        helper.search(component, event, helper);
    },
    
    changeAccordion: function(component, event, helper) {
        var accordionId = event.getSource().get("v.value");
        var listRequisitions = component.get("v.table.listRequisitions");
        console.log(accordionId); 
        for(var i = 0; i < listRequisitions.length; i++) {
            console.log(listRequisitions[i].id == accordionId);
            if(listRequisitions[i].id == accordionId) {
                console.log('listRequisitions isSelected' + listRequisitions[i].isSelected); 
                listRequisitions[i].isSelected = !listRequisitions[i].isSelected;
                console.log('listRequisitions isSelected' + listRequisitions[i].isSelected); 
            }
        }
        
        component.set("v.table.listRequisitions", listRequisitions);
    },
    
    
})