({
    loadOptions: function (component, event, helper) {
        helper.getOptions(component,event,helper);
    },
    handleChange: function (component, event) {
        var selectedOptionValue = event.getParam("value");
        component.set('v.valueSelected', selectedOptionValue);
    },
    changeRec: function (component, event,helper) {
        helper.changeRecord(component,event,helper);
    },
    openModal: function(component,event){
        let selectedOptionValue = component.get('v.valueSelected');
        if(selectedOptionValue == 'Canais_Criticos'){
            component.set('v.oldValueSelected',selectedOptionValue);
            component.set('v.openModalCanaisCriticos',true);
        }else{
            component.set('v.openModal',true);
        }
    },
    closeModal: function(component,event){
        component.set('v.openModal',false);
    },
    closeModalCanais: function(component,event){
        let oldValue = component.get('v.oldValueSelected');
        component.set('v.openModalCanaisCriticos',false);
        component.set('v.valueSelected',oldValue);
    },
    closeModalError: function(component,event){
        component.set('v.openModalError',false);
        
    }
})