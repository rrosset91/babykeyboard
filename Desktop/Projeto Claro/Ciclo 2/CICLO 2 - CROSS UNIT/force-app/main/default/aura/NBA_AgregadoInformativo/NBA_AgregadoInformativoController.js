({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	maskNomeDaMae : function(component, event, helper){

		var nomeDaMae =  event.getSource().get('v.value');
		var value = nomeDaMae.replace(/[^A-Za-z ]/, '');
        component.set('v.retorno.nomeDaMae', value.toUpperCase());        
    }, 
			
	maskRG : function(component, event, helper){

        var rg = event.getSource().get('v.value');
		var value = rg.replace(/[^0-9]/, '');
        component.set('v.retorno.numeroDoRG', value);        
    }, 
	
	cancel : function(component, event, helper){
		component.set('v.showModalAgregado', false);
	},

	
	handleSave : function(component, event, helper){
		var retorno = component.get('v.retorno');
		var preencheu = helper.verificarPreenchimento(component, event, helper);
		helper.verificarOrgaoEmissor(component, retorno);
		helper.verificarRG(component, retorno);
		var numeroRg = component.get('v.numeroRg');
		var orgaoEmissor = component.get('v.orgaoEmissor');

		 if(orgaoEmissor != 'Valor Inválido'){
			if(numeroRg){
				if(preencheu){
				var agregadoInformativo = component.get('v.ofertaSelecionada.AgregadoInformativo');
				agregadoInformativo.nomeDaMae = component.find('nomeDaMae').get('v.value');
				agregadoInformativo.rg = component.find('rg').get('v.value');
				agregadoInformativo.orgaoEmissorRG = component.find('orgaoEmissorRG').get('v.value');
				agregadoInformativo.dataEmissaoDoRG = component.find('dataEmissaoDoRG').get('v.value');
				agregadoInformativo.dataeNascimentodoTitular = component.find('dataeNascimentodoTitular').get('v.value');

				component.set('v.ofertaSelecionada.AgregadoInformativo', agregadoInformativo );

				component.set('v.showModalAgregado', false);
				component.set('v.componentSelectOffer', true);	
		
				} else {
					helper.toastEvent('Preencha todos os campos', 'Você precisa preencher todos os campos da tela.', 'error');
				}
			} else {
				helper.toastEvent('RG Inválido', 'RG deve conter apenas números.', 'error');
			}	
		 } else {
			helper.toastEvent('Orgão Emissor Inválido', 'Preencha o campo com algum valor da lista de orgãos emissores.', 'error');
		 }


	},


})