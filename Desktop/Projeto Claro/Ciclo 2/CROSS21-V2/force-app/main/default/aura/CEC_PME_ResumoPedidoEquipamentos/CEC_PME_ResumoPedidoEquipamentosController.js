({
	doInit : function(cmp, event, helper) {
		let plano = cmp.get("v.plano");
        let equipList = plano.equipamentos;
        let equipTotal = 0;
        let tipoPlano = plano.tipoPlano.replace("Plano ", "");
        for(let e in equipList) {
            equipTotal += e.valor;
        }
        cmp.set("v.equipTotal", equipTotal);
        cmp.set("v.tipoPlano", tipoPlano);
	},
    /* Função chamada ao clicar num label/header --> executa função de esconder a secao relacionada
     Exemplo de uso: 
     <h2 id="headerAlgo" onclick="{!toggleSecao}"> Algo </h2> 
     <div id="secaoAlgo"> ... </div>
     O div será escondido/mostrado ao clicar no h2
     */
	toggleSecao : function(cmp, event, helper) {
        var headerId = event.currentTarget.id;
        if (!headerId) { 
            return null;
        } // Se for nulo, não fazer nada
        
        headerId = headerId.replace("header", ""); // Passando apenas o nome base sem prefixo
        helper.toggleVisibilidadeSecao(cmp, headerId); // Passando o nome base + prefixo do div
	}
})