({
	setAllCheckboxesToChecked: function(component, helper, consents) {
        for(var key in consents){
            consents[key].checked = true;
        }
        component.set('v.consents', consents);
	},
    
    
    //[Claro-Solar]Task TU7
    setTypeObject: function(component, helper){
        var actionTypeObject = component.get("c.getRecordTypeObject");
        actionTypeObject.setParams({
            recordId: component.get("v.recordId")
        });
        actionTypeObject.setCallback(this, function(response) {
            console.log('response', response);
            component.set("v.typeObject", response.getReturnValue());
            if(response.getReturnValue() == 'Case'){
                component.set('v.exibeTituloLGPD', true);
            }
            console.log('setTypeObject', component.get("v.typeObject"));
        });
        $A.enqueueAction(actionTypeObject);
    },
    
    verifyAllToggleValues:function(component,helper,consents,isDoInit){
        //console.log("verifyAllToggleValues");
        if(!isDoInit){
			component.set("v.wasChanged", true);
        }
        
        var isProfileWithEditPermission = component.get("v.isProfileWithEditPermission");
        
        if(isProfileWithEditPermission){
        
            var toggleAllButton = component.find("toggleAllButton").get("v.checked");
            var checkToggleAllButton = true;
    
            for(var key in consents){
                if(consents[key].checked === false){ 
                    checkToggleAllButton = false;
                }
            }
            
            if(toggleAllButton != checkToggleAllButton){ 
                component.find("toggleAllButton").set("v.checked",checkToggleAllButton);
                if(checkToggleAllButton === true){
                    component.find("toggleAllButton").set("v.disabled",true); 
                }else{
                    component.find("toggleAllButton").set("v.disabled",false);
                }
            }
            
        }
    }
    
})