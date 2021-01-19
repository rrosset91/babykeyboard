({
    reSendEnvelope : function(component, event, helper) {
        console.log('helper reSendEnvelope');
        
        var action = component.get('c.reSendDocusignEnvelope');
        var signers = JSON.stringify(component.get('v.contactsTableData'));
        var recordId = component.get("v.recordId");

        action.setParams({
            signers : signers,
            orderId : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                helper.showToast('Sucesso:', 'SUCCESS', $A.get("$Label.c.CEC_PME_MobileButtonsResendRequest_6"));
            } else {
                helper.showToast('Erro:', 'ERROR', response.getError()[0].message);
            }
            helper.closeAction(component, event, helper);
        });
        
        $A.enqueueAction(action);
    },
    
    saveTableData : function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        var contactsTableData = component.get('v.contactsTableData');
        
        for(var i = 0; i < draftValues.length; ++i) {
            var draftValue = draftValues[i];
            for(var j = 0; j < contactsTableData.length; ++j) {
                var contactTableData = contactsTableData[j];
                if(contactTableData.Id == draftValue.Id) {
                    contactTableData.clientEmail = draftValue.clientEmail;
                }
            }
        }

        component.set("v.draftValues", []);
        component.set("v.contactsTableData", contactsTableData);
    },
    
    getSignatureContacts : function(component, event, helper) {
        var getContactsAction = component.get('c.getSignatureContacts');
        
        getContactsAction.setParams({
            orderId : component.get("v.recordId")
        });
        
        getContactsAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                var tableData = [];
                console.log(JSON.parse(response.getReturnValue()));
                
                var list = JSON.parse(response.getReturnValue()); 
                
                for(var i = 0; i < list.length; ++i) {
                    var contact = list[i];
                    var tableRow = {
                        Id: contact.recipientId + '-' + i,
                        clientId: contact.recipientId,
                        clientName:  contact.name,
                        clientEmail: contact.email
                    };
                    tableData.push(tableRow);
                }
                console.log(tableData);
                component.set('v.contactsTableData', tableData);
                component.set('v.selectedContact', list[0]);
                
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                
            } else {
                helper.showToast('Erro', 'ERROR', response.getError()[0].message);
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                
                helper.closeAction(component, event, helper);
            }
        });
        
        $A.enqueueAction(getContactsAction);
    },
    
    showToast : function(messageTitle, messageType, message) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": messageTitle,
            "type": messageType,
            "message": message
        });
        resultsToast.fire();
    },
    
    closeAction : function(component, event, helper) {
        if(component.get("v.isQuickAction")) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "Detail"
            });
            navEvt.fire();
            
            $A.get("e.force:closeQuickAction").fire();
        } else {
            helper.fireComponentEvent(component, event, helper);
        }
    },
    
    fireComponentEvent : function(component, event, helper) {
        var appEvent = $A.get("e.c:CEC_PME_MobileButtonEvt");
        appEvent.fire();
    }   
})