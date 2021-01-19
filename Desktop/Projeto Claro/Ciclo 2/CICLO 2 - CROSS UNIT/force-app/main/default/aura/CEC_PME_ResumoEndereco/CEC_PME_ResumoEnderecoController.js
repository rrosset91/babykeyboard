({
	onEnderecoChanged : function(cmp, event, helper) {
		let cep = cmp.get("v.endereco.cep");
        
        let mask = cep.replace(/\D/g, '').match(/(\d{5})(\d{3})/);
        let cepMask = mask[1] + '-' + mask[2];
        
        cmp.set("v.endereco.cep", cepMask);
	}
})