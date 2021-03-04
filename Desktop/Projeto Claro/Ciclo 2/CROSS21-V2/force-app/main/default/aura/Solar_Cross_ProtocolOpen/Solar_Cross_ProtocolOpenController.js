({
    onInit : function(component, event, helper) {
        var message = "O protocolo será enviado para o BackOffice:";
        component.set("v.message", message);
        helper.populatePicklist(component, event, helper, 1);
    },

    cancel : function(component, event, helper) {
        component.set("v.loadingSave",true);        

        component.set("v.categoryValue", null);
        // component.set("v.productValue", null);
        component.set("v.modalityValue", null);
        component.set("v.entryValue", null);
        component.set("v.leaveValue", null);
        component.set("v.resolutionValue", null);
        component.set("v.descriptionValue", null);
        component.set("v.radioOfferValue","");

        component.set("v.categoryOptions", null);        
        component.set("v.productOptions", null);
        component.set("v.modalityOptions", null);
        component.set("v.entryOptions", null);
        component.set("v.leaveOptions", null);

        component.set("v.productShow", false);
        component.set("v.modalityShow", false);
        component.set("v.entryShow", false);
        component.set("v.leaveShow", false);
        component.set("v.showBKO", false);
        component.set("v.showFCR", false);
        component.set("v.showOffer", false);
        component.set("v.enableUpdate",true);

        helper.populatePicklist(component, event, helper, 1);
    },    
    
    categoryEvt : function(component, event, helper) {
        component.set("v.loadingSave",true);
        
        component.set("v.productValue", null);
        component.set("v.modalityValue", null);
        component.set("v.entryValue", null);
        component.set("v.leaveValue", null);
        component.set("v.resolutionValue", null);
        component.set("v.descriptionValue", null);
        component.set("v.radioOfferValue","");
        
        component.set("v.productOptions", null);
        component.set("v.modalityOptions", null);
        component.set("v.entryOptions", null);
        component.set("v.leaveOptions", null);

        helper.populatePicklist(component, event, helper, 2);
    },

    modalityEvt : function(component, event, helper) {
        component.set("v.loadingSave",true);
        
        component.set("v.entryValue", null);
        component.set("v.leaveValue", null);
        component.set("v.resolutionValue", null);
        component.set("v.descriptionValue", null);
        component.set("v.radioOfferValue","");
        
        component.set("v.entryOptions", null);
        component.set("v.leaveOptions", null);

        helper.populatePicklist(component, event, helper, 3);
    },

    entryEvt : function(component, event, helper) {
        component.set("v.loadingSave",true);
        component.set("v.resolutionValue", null);
        component.set("v.descriptionValue", null);
        component.set("v.radioOfferValue","");
        
        component.set("v.leaveValue", null);
        component.set("v.leaveOptions", null);
        
        helper.populatePicklist(component, event, helper, 4);

    },

    leaveEvt : function(component, event, helper) {
        component.set("v.loadingSave",true);
        component.set("v.showBKO", false);
        component.set("v.showFCR", false);
        component.set("v.showOffer", false);
        component.set("v.resolutionValue", null);
        component.set("v.descriptionValue", null);
        component.set("v.radioOfferValue","");

        helper.firstCallResolution(component, event, helper);

    },

    updateContextCase : function(component, event, helper) {
        component.set("v.loadingSave",true);
        helper.updateCase(component, event, helper);
    },

    validateStringField : function(component, event, helper) {
        var resolutionValue = component.get("v.resolutionValue");
        var descriptionValue = component.get("v.descriptionValue");
        var radioOfferValue = component.get("v.radioOfferValue");
        var hasPermissionOfferCallCenter = component.get('v.hasPermissionOfferCallCenter');
        var offer = component.get("v.showOffer");
 
        console.log('resolutionValue ' + resolutionValue);
        console.log('descriptionValue ' + descriptionValue);
        console.log('radioOfferValue ' + radioOfferValue);

        if((((resolutionValue == null || resolutionValue.match(/^ *$/)  !== null || radioOfferValue == "") && offer  && hasPermissionOfferCallCenter) || (!offer && (resolutionValue == null || resolutionValue.match(/^ *$/)  !== null))) && (descriptionValue == null || descriptionValue.match(/^ *$/) !== null)){
            component.set("v.enableUpdate",true);
        }
        else{
            component.set("v.enableUpdate",false);
        }
    },


    openModal: function (component, event, helper) {
        component.set("v.viewModal",true);
        var cmpTarget = component.find('ConcludeModal');
        var cmpBack = component.find('ModalConclude');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    closeModal: function (component, event, helper) {
        component.set("v.viewModal",false);
        var cmpTarget = component.find('ConcludeModal');
        var cmpBack = component.find('ModalConclude');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },

})