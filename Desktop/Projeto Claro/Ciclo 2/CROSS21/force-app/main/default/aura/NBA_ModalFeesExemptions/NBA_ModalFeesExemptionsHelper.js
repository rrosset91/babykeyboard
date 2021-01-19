({
	updateFeesExemptions: function (component, event, helper) {
		var feesExemptions = component.get("v.feesExemptions");
		var oferta = component.get("v.ofertaSelecionada");
		var listT = component.get("v.lstIsencaoTaxa");
		var check = false;
		for (var i = 0; i < listT.length; i++) {
			if(listT[i].checked){
				check = true;
				if(listT[i].label == "Isenção de Taxa de Adesão de Wifi"){
					feesExemptions.wifi = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Mudança de Endereço"){
					feesExemptions.address = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Visita Técnica"){
					feesExemptions.visit = true;
				}
				else if(listT[i].label == "Isenção de Taxa de Migração do Docsis 2.0 para 3.0"){
					feesExemptions.docsis = true;
				}
			} 
		}
		if (oferta) {
			oferta.free = check;//feesExemptions.wifi || feesExemptions.address || feesExemptions.visit || feesExemptions.docsis;
		}

		component.set("v.feesExemptions", feesExemptions);
		component.set("v.showFeesExemptions", false);
		component.set("v.ofertaSelecionada", oferta);
		//component.set("v.lstIsencaoTaxa",listT);
	},
})