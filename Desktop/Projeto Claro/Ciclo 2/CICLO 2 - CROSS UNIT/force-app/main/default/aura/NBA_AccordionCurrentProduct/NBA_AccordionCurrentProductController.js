({
    doInit : function(component, event, helper){
       helper.getList(component, event, helper);    
    },
    
    openAccordion : function(component, event, helper) {
        var id = event.currentTarget.dataset.id;

        if(id === helper.const.TV){
            component.set('v.activeTV', !component.get('v.activeTV'));
            
        } else if(id === helper.const.VIRTUA){
            component.set('v.activeVirtua', !component.get('v.activeVirtua'));
            
        } else if(id === helper.const.NETFONE){
            component.set('v.activeNetFone', !component.get('v.activeNetFone'));
            
        } else if(id === helper.const.NETMOVEL){
            component.set('v.activeNetMovel', !component.get('v.activeNetMovel'));
        }

    }    
})