({
	doInit : function(component, event, helper) {
		helper.loadAccount(component, helper);
    },
    
    buscarCepCob : function(component, event, helper) {
        helper.buscarCepCob(component, helper);
    },
    
    buscarCepEnt : function(component, event, helper) {
        helper.buscarCepEnt(component, helper);
    },
    
    save : function(component, event, helper) {
        helper.save(component, helper);
    }
})