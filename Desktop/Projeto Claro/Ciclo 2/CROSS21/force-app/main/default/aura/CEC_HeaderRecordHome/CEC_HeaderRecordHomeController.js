({
	doInit : function(component, event, helper) {
	    helper.doInit(component);
        helper.backofficeUser(component);
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.fire();
    }, 
    
    navigateToAccount : function() {
		/*Implementar*/        
    }, 
    
    editCart : function(component) {
        
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/ClaroHybridCPQ?id=" + component.get("v.recordId")
        });
        urlEvent.fire();*/
        
        window.open("/apex/ClaroHybridCPQ?id=" + component.get("v.recordId"), '_top');
        
    }, 
    
    editAccount : function() {
        
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/vlocity_cmt__OmniScriptUniversalPageConsole?id={0}&layout=lightning#/OmniScriptType/PME/OmniScriptSubType/CompleteAccountContactInfo/OmniScriptLang/Portuguese (Brazil)/ContextId/{0}/PrefillDataRaptorBundle//true"
        });
        urlEvent.fire();*/

		window.open("/apex/vlocity_cmt__OmniScriptUniversalPageConsole?id={0}&layout=lightning#/OmniScriptType/PME/OmniScriptSubType/CompleteAccountContactInfo/OmniScriptLang/Portuguese (Brazil)/ContextId/{0}/PrefillDataRaptorBundle//true", '_top');        
        
    }, 
    
    cancelOrder : function(component, event, helper) {
        helper.changeOrderStatus(component, "Cancelado");
    }, 

    navigateToResume : function(component) {
        
        //var evt = $A.get("e.force:navigateToComponent");
        //evt.setParams({
        //    componentDef : "c:CEC_PME_OppLineItemCustom",
        //componentAttributes: {
        //    recordId : component.get("v.recordId")
        //}
        //});
        //evt.fire();
        console.log("attt 1");
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
            "url": "/apex/CEC_PME_ResumoPedido?id=" + component.get("v.recordId")
        });
        eUrl.fire();

        
    },

    sendToDocusign : function(component, event, helper) {
        console.log("att 2");
        helper.toggleButton('btnAssinar');
        helper.checkAndSendToDocusign(component);
        
    }, 
    
    showTerritoryAssociation : function(component, event, helper) {
        helper.showTerritoryAssociation(component);
    },
    
    closeTerritoryAssociationModal : function(component, event, helper) {
        component.set('v.isShowTerritoryAssociationModal', false);
    },
    
    salveTerritory : function(component, event, helper) {
        helper.salveTerritory(component);
    },
    
    showAlterEmailModal : function(component, event, helper) {
      
        component.set('v.contactsTableColumns', [
            {label: 'Contato admnistrador', fieldName: 'clientName', type: 'text', editable: false, typeAttributes: { required: true }},
            {label: 'Email', fieldName: 'clientEmail', type: 'email', editable: true, typeAttributes: { maxlength: 20, required: true }, initialWidth: 250},
        ]);

        helper.toggleButton('btnReenviar');
        helper.showAlterEmailModal(component);
        
    },

    showTable : function(component) {

        var button = component.find('updateEmailsBtn');
        $A.util.addClass(button, 'slds-hide');

        var table = component.find('emailTable');
        $A.util.removeClass(table, 'slds-hide');

    },

    handleSaveTableEdit : function(component, event, helper) {
        helper.saveTableData(component, event.getParam('draftValues'));
    },

    closeAlterEmailModal : function(component, event, helper) {

        helper.closeAlterEmailModal(component);

    },

    updateSelectedContact : function(component, event, helper) {

        var picklist = document.getElementById('contacts-select');
        component.set('v.selectedContact', component.get('v.signatureContacts')[picklist.selectedIndex]);

    },

    updateEmail : function(component, event, helper) {
        
        helper.updateEmail(component);
        
    },
    
    reSendEnvelope : function(component, event, helper) {
        console.log('controller reSendEnvelope');
        helper.reSendEnvelope(component);
        
    },

    validateBackoffice : function(component, event, helper) {
        
        helper.validateBackoffice(component);
        
    }, 

    JScloseOrder : function(component, event, helper) {
        component.set("v.realizandoInput",true);
        helper.closeOrder(component);
    }, 
    
    approveDoc : function(component, event, helper) {
        
        helper.callIntegRemoveSigners(component);
        
    },
    
    setStatus : function(component, event, helper) {
        
        helper.setStatus(component);
        
    }, 

    setSubStatus : function(component, event, helper) {
        
        component.set("v.showSubStatus", true);
        
    }, 
    
    closeSubStatus : function(component, event, helper) {
       
        component.set("v.showSubStatus", false);
        helper.closeSubStatus(component);
        helper.setSubStatus(component);
        
    },
    
    closeModalMessage : function(component) {
        component.set("v.message", '');
    },
    
    JSStatusChange: function(component, event, helper) {
        component.set('v.isOpen', true);
        var flow = component.find('flow');
        var inputVariables = [
             {
                name : "recordId",
                type : "SObject",
                value : component.get("v.recordId")
              }
           ];
		flow.startFlow('PME_Order_Status', inputVariables);
    },
    
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },

	closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    },
    
    createContract : function (component, event, helper){
        component.set("v.disabled", true); 
        component.set("v.processingModal", true);
        helper.createContractCall(component);        
	},
    
    resendOrder : function (cmp, event, helper){
    	helper.reenviarPedido(cmp, helper);
        cmp.set("v.resendMsgModal",'');
	},
    
    closeResendModal : function(cmp){
        cmp.set("v.resendMsgModal",'');
    },
    
    showResendModel : function(cmp){
        cmp.set("v.resendMsgModal",'Caso seja necessário adicionar documento, adicionar manualmente.');
    }
})