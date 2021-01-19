({
	rerender : function(component, helper) {
		this.superRerender();
		sessionStorage.setItem('newProduct', JSON.stringify(component.get('v.produtoAtual')));
	}
})