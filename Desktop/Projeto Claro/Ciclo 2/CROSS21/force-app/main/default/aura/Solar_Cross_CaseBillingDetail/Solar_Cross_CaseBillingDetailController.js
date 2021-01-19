({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        console.log('Solar_AccBillingDetails', 'doInit' );
        helper.fillContractData(component, event, helper);
    },

    onCLickPDF : function(component, event, helper) {
        let bu = component.get("v.businessUnit");
        console.log('onCLickPDF', bu);
        var dataIdd = event.target.getAttribute('data-id');
        var dateEndd = event.target.getAttribute('data-end');
        if(bu == 'Net'){
            helper.getPDFInvoiceRes(component,event,helper,dataIdd);
        }
        else if(bu =='Claro'){
            helper.getPDFInvoiceMov(component,event,helper,dateEndd);
        }
    },

    toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    handleClickFinanceiro: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Erro!", 
            "type": "Error", 
            "message":'Componente financeiro não especificado.'
        });
        toastEvent.fire();
    },
})