({
	doInit : function(cmp, event, helper) {
        let recebedores = cmp.get("v.recebedor");
        console.log(recebedores);
        
		return;
    },
    onRecebedorChanged : function(cmp, event) {
        // replace(/\D/g, '').match(/(\d{2})(\d{5})(\d{4})/);
        if (cmp.get("v.isFiltered")) {
            return;
        }
        let recebedores = cmp.get("v.recebedor.recebedores");
        console.log(">>", recebedores);
        if (!recebedores || recebedores.length == 0) {
            return;
        }
        let filteredList = [];
        
        for (let i=0; i < recebedores.length; i++) {
            if (recebedores[i].nomeCompleto){
                filteredList.push(recebedores[i]);
            }
        }
        
        for (let i=0; i < filteredList.length; i++) {
            console.log(filteredList[i]);
            if (filteredList[i].celular) {
                let mask = filteredList[i].celular.replace(/\D/g, '').match(/(\d{2})(\d{5})(\d{4})/);
                filteredList[i].celular = mask[1] + ' ' + mask[2] + '-' + mask[3];
            }
            if (filteredList[i].telefone) {
                let mask = filteredList[i].telefone.replace(/\D/g, '').match(/(\d{2})(\d{4})(\d{4})/);
                filteredList[i].telefone = mask[1] + ' ' + mask[2] + '-' + mask[3];
            }
        }
        
        cmp.set("v.recebedores", filteredList);
        cmp.set("v.isFiltered", true);
    }
})