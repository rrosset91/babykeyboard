({
    onInit : function(component, event, helper) {
        component.set("v.isLoading", true);

        helper.changeTabIcon(component, event, helper);

        var startDate = helper.getDate(component, event, helper, 180);
        var endDate = helper.getDate(component, event, helper, 0);
        component.set('v.beginDate', startDate);
        component.set('v.endDate', endDate);
        component.set('v.minDate', startDate);
        component.set('v.maxDate', endDate);
        component.set('v.staticBeginDate', startDate); // valor usada para verificar se houve alteração no range de datas da última integração, evitando busca pelo controlador apex caso o range não tenha sido alterado
        component.set('v.staticEndDate', endDate); // valor usada para verificar se houve alteração no range de datas da última integração, evitando busca pelo controlador apex caso o range não tenha sido alterado
        var status = component.get('v.viewSelected');
        console.log('startDate ------------> ' + startDate);
        console.log('endDate ------------> ' + endDate);
        helper.getDataFromApex(component, event, helper, startDate, endDate, status);        
        // component.set("v.isLoading", false);
    },

    descriptionModal : function(component, event, helper) {
        //listener utilizado para fechar o modal com ESC
        window.addEventListener("keydown", function(event) {
            var kcode = event.code;
            if(kcode == 'Escape'){
                console.log('esccape id press - Outer Component');
                var a = component.get('c.closeDescriptionModal');
                $A.enqueueAction(a);        
            }
        }, true);

        var modalText = event.getSource().get("v.value");
        var modalTitle = event.getSource().get("v.name");
        console.log('modalTitle ' + modalTitle);
        component.set("v.modalTitle",modalTitle);
        
        console.log('modalText ' + modalText);
        component.set("v.modalText", modalText);
        
        if(modalTitle == 'Protocolo PS8'){
            component.set("v.isLoading", true);
            helper.getMoreInfoFromApex(component, event, helper, modalText.ProtocolNumber);
        }        
        else if(modalTitle == 'OSs e OCs'){
            component.set("v.isLoading", true);
            helper.getOSAndOCFromApex(component, event, helper, modalText);
            // helper.openModal(component, event, helper);            
        }
        else{
            helper.openModal(component, event, helper);
        }
    },

    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            component.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            component.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    closeDescriptionModal: function (component, event, helper) {
        helper.closeModal(component, event, helper);      
        component.set("v.modalText", null);
        component.set("v.modalTitle", null);
    },

    searchData: function(component, event, helper) {
        component.set("v.isLoading", true);

        var startDate = component.get('v.beginDate');
        var endDate = component.get('v.endDate');
        var staticStartDate = component.get('v.staticBeginDate');
        var staticEndDate = component.get('v.staticEndDate');
        var status = component.get('v.viewSelected');

        if((startDate == staticStartDate) && (endDate == staticEndDate)){
            helper.changeFilter(component, event, helper);
            component.set("v.isLoading", false);

            var dataLength = component.get("v.data");
            if(dataLength == null || dataLength == undefined || dataLength.length == 0){
                component.set("v.itensNumber", null);
                component.set("v.itemString", 'Nenhum item a ser exibido');
                
            }
            else if(dataLength.length == 0){
                component.set("v.itensNumber", dataLength.length);
                component.set("v.itemString", ' item');
            }
            else{
                component.set("v.itensNumber", dataLength.length);
                component.set("v.itemString", ' itens');
            }
        }
        else{            
            helper.getDataFromApex(component, event, helper, startDate, endDate, status);
            component.set("v.ps8Filter", true);
            component.set("v.netsmsFilter", true);
            component.set("v.solarFilter", true);
            
            // component.set('v.staticBeginDate', startDate);
            // component.set('v.staticEndDate', endDate);
        }
    },
})