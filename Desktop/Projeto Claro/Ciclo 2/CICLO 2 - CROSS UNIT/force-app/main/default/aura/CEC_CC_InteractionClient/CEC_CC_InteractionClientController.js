/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
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

    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

    create: function (component, event, helper) {
        helper.getCase(component, true);
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
    }
})