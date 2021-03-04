({
	doInit: function (component, event, helper) {
		helper.initialLoad(component);
		helper.verifyDuplicatePermission(component);
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
	
	handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    
    handleSelectedInvoice: function (component, event, helper) {
		const selectedRows = event.getParam("selectedRows");
		console.log('selectedRows ' + component.get("v.selectedRows"));
		console.log('selectedRows string ' + JSON.stringify(component.get("v.selectedRows")));
		if (!selectedRows) {
			component.set("v.disabledGen", true);
			component.set("v.disabledView", true);
			return component.set("v.selectedInvoices", []);
		}
		component.set("v.disabledView", false);
		component.set("v.selectedInvoices", selectedRows);

		console.log("valor do agora -> " +  JSON.stringify(component.get("v.selectedInvoices")));

		let invoiceStatus = component.get("v.selectedInvoices[0].status");
		if( component.get("v.duplicatePermission") == true){
			if (invoiceStatus == "Em Aberto") {
				component.set("v.disabledGen", false);
			} else {
				component.set("v.disabledGen", true);
			}
		}
	},
    
    onSort: function (component, event, helper) {
		let fieldName = event.getParam("fieldName");
		const sortDirection = event.getParam("sortDirection");

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		let allInvoices = component.get("v.invoices");

		if (!allInvoices) return;

		if (fieldName == "valor") fieldName = "realValue";

		if (fieldName == "dataVencimento") fieldName = "realDate";

		component.set(
			"v.invoices",
			helper.sortData(fieldName, sortDirection, allInvoices)
		);
	},
    
    clickGenDuplicate: function (component, event, helper) {
		let selectedInvoice = component.get("v.selectedInvoices");
		helper.closeEventModalhelper(component, event);
		component.find("duplicateModal").open();
		component.set("v.isLoadingModal", true);
		component.set('v.toastShowed',false);
		helper.getInvoiceDuplicates(
			component,
			selectedInvoice[0],
			(success, error) => {
				if (error) 
                		component.find("duplicateModal").close();
						component.set("v.isLoadingModal", false);
                		return;
                if ((component.get("v.sendReasonOptions").length < 1 || component.get("v.sendMethodOptions").length < 1)  && component.get('v.toastShowed')==false) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_cant_send");
					helper.showToast(component, message);
                    component.set('v.toastShowed',true);
				}
				if (component.get("v.duplicate.userHasAccess") != "SIM" && component.get('v.toastShowed')==false) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_userHas_access");
					helper.showToast(component, message);
                	component.set('v.toastShowed',true);
				}
				if (component.get("v.sendMethodOptions").length < 1 && component.get('v.toastShowed')==false) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_send_NoMethods");
					helper.showToast(component, message);
            		component.set('v.toastShowed',true);
				}
				if (component.get("v.duplicate.billAllowsSending") != "SIM" && component.get('v.toastShowed')==false) {
					component.find("duplicateModal").close();
					let message = $A.get("$Label.c.Fin_cant_send");
					helper.showToast(component, message);
                    component.set('v.toastShowed',true);
				}
			}
		);
        
	},
 
      clickViewBill: function (component, event, helper) {
		component.set("v.isLoading", true);
		const selectedInvoice = component.get("v.selectedInvoices");
		if (!selectedInvoice) return;

		helper.findInvoiceDetails(
			component,
			selectedInvoice[0],
			(success, error) => {
				if (error) return;

				const cmpEvent = component.getEvent("Financeiro_ComponentEvent");

				cmpEvent.setParams({
					message: "OPENBILLDETAIL",
					payload: success
				});
				component.set("v.isLoading", false);
				cmpEvent.fire();
			}
		);
	},
        
        handleSelectedSendMethod: function (component, event) {
		var SelectedSendMethod = event.getParam("value");
		switch (SelectedSendMethod) {
			//case "E":
            case "3":
                component.set("v.selectedEmail", true);
				component.set("v.selectedSMS", false);
				component.set("v.selectedCorreio", false);
				//component.set("v.selectedSendMethod", "E");
				component.set("v.selectedSendMethod", "3");
				break;
			//case "S":
            case "5":
				component.set("v.selectedSMS", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedCorreio", false);
				//component.set("v.selectedSendMethod", "S");
				component.set("v.selectedSendMethod", "5");
				break;
			//case "C":
            case "2":
				component.set("v.selectedCorreio", true);
				component.set("v.selectedEmail", false);
				component.set("v.selectedSMS", false);
				//component.set("v.selectedSendMethod", "C");
				component.set("v.selectedSendMethod", "2");
				break;
			default:
				SelectedSendMethod = undefined;
				break;
		}
		if (
			component.get("v.selectedSendReason") === undefined ||
			SelectedSendMethod === undefined
		) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
		return SelectedSendMethod;
	},
	handleSelectedSendReason: function (component, event) {
		var SelectedSendReason = event.getParam("value");
		if (
			component.get("v.selectedSendMethod") === undefined ||
			SelectedSendReason === undefined
		) {
			component.set("v.disabledSend", true);
		} else {
			component.set("v.disabledSend", false);
		}
		return SelectedSendReason;
	},

	handleRowAction: function (component, event, helper) {
		var action = event.getParam("action");
		var selection = event.getParam("selection");
		var row = event.getParam("row");
		console.log('chamooou!!!!!!!' + action.name + ' --- ' + JSON.stringify(selection));
		switch (action.name) {
			case "view_modal":
				component.find("detailModal").open();
				component.set("v.isLoadingModal", true);

				helper.findInvoiceDetails(component, row, (success, error) => {
					if (error) component.find("detailModal").close();

					component.set("v.isLoadingModal", false);
				});
				break;
			default:
				break;
		}
	},

	sendDuplicate: function (component, event, helper) {
		component.set("v.disabledSend", false);
        component.set('v.isLoadingModal',true);
		const selectedInvoice = component.get("v.selectedInvoices");
		console.log(
			"selected invoice -> ",
			JSON.parse(JSON.stringify(selectedInvoice[0]))
		);

		helper.postInvoiceDuplicates(
			component,
			selectedInvoice[0],
			helper,
			(sucess, error) => {
				if (error) {
					alert("ERRO ao tentar enviar Segunda Via");
					component.find("Solar_Cross_modalMessage").close();
                	component.set('v.dialogModal',false);
				}
			}
		);
	},

	closeModalSegundaVia: function (component) {
		component.find("Solar_Cross_modalMessage").close();
        component.set('v.dialogModal',false);
	},
        
    fetchData: function (component, event, helper) {
		if (component.get("v.contractId") && component.get("v.contractId")) {
			helper.callOpenInvoices(component);
		}
	},

    onCloseModal: function (component, event, helper) {
		component.set("v.selectedSendReason", null);
		component.set("v.selectedSendMethod", null);
		component.set("v.selectedEmail", false);
		component.set("v.selectedSMS", false);
		component.set("v.selectedCorreio", false);
		component.set("v.disabledSend", true);
	},
    
    closeModal: function (component, event, helper) {
		component.find("detailModal").close();
	},

	cancelModal: function (component, event, helper) {
		component.find("duplicateModal").close();
	},

	closeEventModal: function (component, event, helper) {
		helper.closeEventModalhelper(component, event);
	},
	
	openEventModal: function (component, event, helper) {
		helper.openEventModalHelper(component, event);
    },
})