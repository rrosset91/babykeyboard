({
	// Função para esconder uma seção ao clicar em outro elemento (como um header/label)
	toggleVisibilidadeSecao: function(cmp, headerName, prefix) {
        let element = cmp.find(prefix + headerName);
        $A.util.toggleClass(element, "slds-hide");
	}
})