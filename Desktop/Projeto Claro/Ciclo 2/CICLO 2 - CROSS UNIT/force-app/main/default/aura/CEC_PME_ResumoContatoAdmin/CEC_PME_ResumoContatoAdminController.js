({
	onContatosChanged : function(cmp, event, helper) {
		let contatos = cmp.get("v.contatosAdministrador");
        
        for (let i=0; i < contatos.length; i++)  {
            if (contatos[i].celular) {
                let mask = contatos[i].celular.replace(/\D/g, '').match(/(\d{2})(\d{5})(\d{4})/);
                contatos[i].celular = mask[1] + ' ' + mask[2] + '-' + mask[3];
            }
            if (contatos[i].telefone){
                let mask = contatos[i].telefone.replace(/\D/g, '').match(/(\d{2})(\d{4})(\d{4})/);
                contatos[i].telefone = mask[1] + ' ' + mask[2] + '-' + mask[3];
            }
        }
        
        cmp.set("v.contatos", contatos);
	}
})