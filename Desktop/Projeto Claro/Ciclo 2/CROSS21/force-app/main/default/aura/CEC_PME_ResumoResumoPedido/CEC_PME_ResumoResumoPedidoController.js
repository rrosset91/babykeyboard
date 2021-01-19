({
    doInit : function(cmp, helper) {
        let planos = cmp.get("v.resumoPedido.planos");
        let tipoPlanoList = []
        let equipList = [];
        for (let e in planos) {
            if (!tipoPlanoList.includes(e.tipoPlano)) {
                tipoPlanoList.push(e.tipoPlano);
            }
        }
        
    },
	// Função chamada ao clicar num label/header --> executa função de esconder a secao relacionada
    // Exemplo de uso: 
    // <h2 id="headerAlgo" onclick="{!toggleSecao}"> Algo </h2> 
    // <div aura:id="secaoAlgo"> ... </div>
    // O div será escondido/mostrado ao clicar no h2
	toggleSecao : function(cmp, event, helper) {
        let headerId = event.currentTarget.id;
        if (!headerId) { return; } // Se for nulo, não fazer nada
        headerId = headerId.replace("header", ""); // Passando apenas o nome base sem prefixo
        helper.toggleVisibilidadeSecao(cmp, headerId, "secao"); // Passando o nome base + prefixo do div
	}
})