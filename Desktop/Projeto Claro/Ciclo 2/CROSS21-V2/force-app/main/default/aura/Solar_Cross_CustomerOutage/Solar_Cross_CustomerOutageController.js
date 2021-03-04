({
    onInit : function(component, event, helper) {
        component.set('v.iconUsed',"utility:clear");
        component.set('v.variantUsed','error');
       // sessionStorage.setItem('teste','teste');
        helper.getContract(component,event,helper);
    },
    openMoreInfo : function(component,event,helper){
        component.set('v.openModal',true);
        console.log('entrou aqui no openMoreInfo')
    }
})