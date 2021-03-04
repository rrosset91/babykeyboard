({
	init : function(component, event, helper) {
		

		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var recordId = sURL[sURL.length - 2];

		// console.log(recordId);
		// console.log(component.get('v.recordId'));
		if(recordId == 'Case') return;
		component.set('v.showSpinner', true);

		var action = component.get('c.init');
		 action.setParams({
           "recordId": recordId
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.retorno', data);
				this.verificarOrgaoEmissor(component, data);
				this.verificarRG(component, data);                         
            } else if (state === "ERROR") {
				var errors = action.getError();
				if (errors) {
					if (errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {
						if (errors[0].pageErrors[0].message) {
							helper.toastEvent('Erro!', errors[0].pageErrors[0].message, 'error');
						} else if (errors[0].message) {
							helper.toastEvent('Erro!', errors[0].message, 'error');
						}
					}
				}
			}
			component.set('v.showSpinner', false);
			//component.set('v.ShowModal', true); FALTANDO ATTRIBUTE
        });
        $A.enqueueAction(action);

	},

	verificarPreenchimento : function(component, event, helper){ 

		var preencheu = false;
		var campo1 = component.find('nomeDaMae').get('v.value') != undefined && component.find('nomeDaMae').get('v.value') != '' ? true : false;
		var campo2 = component.find('rg').get('v.value') != undefined && component.find('rg').get('v.value') != '' ? true : false;
		var campo3 = component.find('dataEmissaoDoRG').get('v.value') != undefined && component.find('dataEmissaoDoRG').get('v.value') != '' ? true : false;
		var campo4 = component.find('orgaoEmissorRG').get('v.value') != undefined && component.find('orgaoEmissorRG').get('v.value') != '' ? true : false;
		var campo5 = component.find('dataeNascimentodoTitular').get('v.value') != undefined && component.find('dataeNascimentodoTitular').get('v.value') != '' ? true : false;

		if(campo1 && campo2 && campo3 && campo4 && campo5){
			preencheu = true;
		}
	
			return preencheu;
	},

	verificarOrgaoEmissor : function(component, retorno){
		var lstOrgaosEmissores = retorno.orgaosEmissores;
		var orgaoEmissorRG = retorno.orgaoEmissorRG;

		if(orgaoEmissorRG != undefined && orgaoEmissorRG != '' && orgaoEmissorRG != null && lstOrgaosEmissores != null && lstOrgaosEmissores.length > 0){
			for(var index = 0; index < lstOrgaosEmissores.length; index++){
				if(orgaoEmissorRG != lstOrgaosEmissores[index].Label){
					component.set('v.orgaoEmissor', 'Valor Inválido');
				} else {
					component.set('v.orgaoEmissor', orgaoEmissorRG);
					break;
				}
			}
		}	
	},

	verificarRG : function(component, retorno){ 
		var numeroRG = retorno.numeroDoRG;

		if(numeroRG != undefined && numeroRG != '' && numeroRG != null){
			if(numeroRG.match(/[^0-9]/)){
				component.set('v.numeroRg', false);
			} else {
				component.set('v.numeroRg', true);
			}
		}	
	},
			
	 toastEvent: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
})