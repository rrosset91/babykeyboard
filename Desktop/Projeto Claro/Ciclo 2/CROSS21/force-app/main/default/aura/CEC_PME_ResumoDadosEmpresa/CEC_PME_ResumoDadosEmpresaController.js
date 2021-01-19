({
	doInit : function(cmp, event, helper) {
        // Carregando dados temporários (para testes apenas):
        // helper.loadTemporaryDadosEmpresa(cmp);
        
        // 
		let possuiServicos = cmp.get("v.dadosEmpresa.possuiServicos");
        console.log(possuiServicos);
        if (possuiServicos == null) {
            console.log("[dados] == null")
            return;
        }
        let possuiOptions = [];
        let possuiSelected = [];
        for (let i=0; i < possuiServicos.length; i++) {
            possuiOptions.push( { label: possuiServicos[i].nome, value: possuiServicos[i].valor } );
            if (possuiServicos[i].valor){
                possuiSelected.push(possuiServicos[i].nome);
            }
        }
        console.table(possuiOptions);
        console.table(possuiSelected);
        cmp.set("v.possuiServicosOptions", possuiOptions);
        cmp.set("v.possuiServicosValues", possuiSelected);
        
	}
    
})