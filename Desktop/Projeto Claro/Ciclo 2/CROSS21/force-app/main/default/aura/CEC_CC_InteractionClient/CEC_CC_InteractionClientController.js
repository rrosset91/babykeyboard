/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-10-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-02-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
 **/
({
    doInit: function (component, event, helper) {
        helper.fetchLeadSourcePicklist(component, component.get("v.ObjectName"),
            component.get("v.caseReject"),
            component.get('v.filterInteraction'));
        helper.getInteration(component);
        helper.getCase(component, false);
        helper.setCaseType(component);
    },

    changeAction: function (component, event, helper) {
        helper.handleChangesByInteration(component, event, helper)
    },

    changeActionMeiosContato: function (component, event, helper) {
        helper.handleMeiosContato(component, event, helper)
    },

    handleUploadFinished: function (component, event, helper) {

        var lstDocumentId = component.get("v.lstDocumentId");

        if (lstDocumentId != null && lstDocumentId.length > 0) {
            helper.clearAllAttachmentInserted(lstDocumentId, component);
        }

        var uploadedFiles = event.getParam("files");
        var listNewDocumet = new Array();
        for (var i = 0; i < uploadedFiles.length; i++) {
            listNewDocumet.push(uploadedFiles[i].documentId);
        }
        component.set("v.lstDocumentId", listNewDocumet);
    },

    handleFilesChange: function (component, event) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

    create: function (component, event, helper) {
        var contactMethod = component.get("v.meioDeContatoValue");

        if(contactMethod != undefined && contactMethod == 'Notificação digital (push)'){
            helper.sendPush(component, event);
        }
        else{
            helper.getCase(component, true);
        }

    },

    openModal: function (component, event, helper) {
        component.set("v.isOpenModal", true);
        helper.openFile(component, event);
    },

    closeModal: function (component, event, helper) {
        component.set("v.isOpenModal", false);
    },

    showSpinner: function (component, event, helper) {
        component.set("v.Spinner", true);
    },

    hideSpinner: function (component, event, helper) {
        component.set("v.Spinner", false);
    },

    validateEmail: function (component, event, helper) {
        helper.validateEmail(component, event, helper);
    },

    validateTel: function (component, event, helper) {
        helper.validateTel(component, event, helper);
    },

    changeCategory: function (component, event, helper) {
        helper.populateMessageField(component);
    },

    changeMessage: function (component, event, helper) {
        var message = component.get("v.messageValue");
        component.set("v.pushMessage", message);
    },
    onClickToDial: function (component, event, helper) {
        // clickToDialService is for internal use only.
        // Use sforce.opencti.onClickToDial() in your org.
        // https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_onclicktodial_lex.htm
        console.log("Entrou no click to Dial Lucas");
        sforce.opencti.onClickToDial();
        //});
    },
 
    noPhonesFound: function(component, event,helper){
        console.log("netrou no nophones")
        component.set("v.newLayoutVersion", false);
        component.set("v.liberaTelefone", true);
        component.set("v.liberaEmail", false); 
        component.set("v.openInteractionNoPhone", true); 

        

    }
})