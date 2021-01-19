({
    onInit : function(component, event, helper) {
        helper.initialLoad(component);   
    },
    closeModal : function(component){
        console.log('entrou no close Modal')
        component.set('v.openModal',false);
    },
    closeWithEsc : function(component,event){
        console.log('entrou no close Modal')
        if(event.keyCode === '27'){
            component.set('v.openModal',false);
        }
    },
    onChangeMinDate : function(component,event,helper){
        
        let selectedDate =  event.getSource().get("v.value");
        let date = new Date(selectedDate);
        let minDateStart = $A.localizationService.formatDate(date,"yyyy-MM-dd");
        component.set('v.minimunDateFinish',minDateStart);
        console.log('minDateStart',minDateStart);
        let maxDateFinish = $A.localizationService.formatDate(date.setDate(date.getDate() + 30),"yyyy-MM-dd");
        component.set('v.maximumDateFinish', maxDateFinish);
        console.log('maxDateStart',maxDateFinish);
    },
    handleSort: function(cmp, event, helper) {
        console.log('Entrou no controller');
        helper.handleSort(cmp, event);
    },
    handleFiltro : function(component,event,helper){
        helper.filterOutages(component,event,helper);
    }
})