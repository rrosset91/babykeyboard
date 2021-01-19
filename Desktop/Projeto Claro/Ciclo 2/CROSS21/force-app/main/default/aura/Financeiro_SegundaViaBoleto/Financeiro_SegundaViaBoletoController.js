({
    handleSelectedSendMethod: function (component, event) {
        console.log('handleSelectedSendMethod');
        var selectedSendMethod = event.getParam("value");
        switch (selectedSendMethod) {
            case "3":
                component.set("v.selectedEmail", true);
                component.set("v.selectedSMS", false);
                component.set("v.selectedCorreio", false);
                component.set("v.selectedSendMethod", "3");
                break;
            case "5":
                component.set("v.selectedSMS", true);
                component.set("v.selectedEmail", false);
                component.set("v.selectedCorreio", false);
                component.set("v.selectedSendMethod", "5");
                break;
            case "2":
                component.set("v.selectedCorreio", true);
                component.set("v.selectedEmail", false);
                component.set("v.selectedSMS", false);
                component.set("v.selectedSendMethod", "2");
                break;
            default:
                selectedSendMethod = undefined;
                break;
        }
        if (
            component.get("v.selectedSendReason") === undefined ||
            selectedSendMethod === undefined
        ) {
            component.set("v.disabledSend", true);
        } else {
            component.set("v.disabledSend", false);
        }
    },
    
    handleSelectedSendReason: function (component, event) {
        var selectedSendReason = event.getParam("value");
        if (
            component.get("v.selectedSendMethod") === undefined ||
            selectedSendReason === undefined
        ) {
            component.set("v.disabledSend", true);
        } else {
            component.set("v.disabledSend", false);
        }
    },
    //disparar para o componente pai "Financeiro_FaturasEmAberto" fechar a modal
    cancelModal: function (component, event, helper) {
		component.find("duplicateModal").close();
	},
    
    sendDuplicate: function (component, event, helper) {
		component.set("v.disabledSend", false);
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
					//alert("ERRO ao tentar enviar Segunda Via");
					//component.find("modalMessage").close();
				}
			}
		);
	},
})