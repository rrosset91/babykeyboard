({
    doInit : function(component, event, helper) {

        let date = new Date();
        let dateMin = new Date(date.getFullYear(),date.getMonth() - 1,date.getDate());
        let minDate = $A.localizationService.formatDate(dateMin,"yyyy-MM-dd");
        let minDateMessage =  $A.localizationService.formatDate(dateMin,"dd/MM/yyyy");
        let maxDate = $A.localizationService.formatDate(date,"yyyy-MM-dd");
        let maxDateMessage = $A.localizationService.formatDate(date,"dd/MM/yyyy");
        component.set("v.minimunDate" , minDate);
        component.set("v.maxDateFirstDate", maxDate);
        component.set("v.messageMinimumDateStart", 'A data escolhida precisa ser maior que ' + minDateMessage);
        component.set("v.messageMaxDateStart", 'A data escolhida precisa ser menor que ' + maxDateMessage);
        helper.verifyBatchJobsSameDay(component,event,helper);
        
    },

    onChangeMinDate : function(component,event,helper){
        
        let selectedDate =  event.getSource().get("v.value");
        let date = new Date(selectedDate);
        let minDateStart = $A.localizationService.formatDate(date,"yyyy-MM-dd");
        component.set('v.minimunDateFinish',minDateStart);
        date.setDate(date.getDate() + 10);
        let maxDate = $A.localizationService.formatDate(date,"yyyy-MM-dd");
        let minDateMessage = $A.localizationService.formatDate(selectedDate,"dd/MM/yyyy");
        let maxDateMessage = $A.localizationService.formatDate(date,"dd/MM/yyyy");
        component.set("v.maximunDate" , maxDate);
        component.set("v.messageMinDateFinish", 'A data escolhida precisa ser maior que ' + minDateMessage);
        component.set("v.messageMaxDateFinish", 'A data escolhida precisa ser menor que ' + maxDateMessage);

    },
    onClickRepriorizar : function(component,event,helper){
        helper.reprioritize(component,event,helper);
    },
    closeModal : function(component){
        component.set("v.openModal",false);
    }
})