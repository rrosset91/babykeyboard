({
    expand: function (component, event, helper) {
        component.set('v.expanded', !component.get('v.expanded'));      
		
		//Alexandre Amaro
		var valorAtual = 0;
		var listaDepAtualSelected = component.get('v.oferta.mobile.listaDependentesMobilePosse');  
		for(var x = 0; x < listaDepAtualSelected.length; x++ ){
			if(!listaDepAtualSelected[x].checked){
				valorAtual = valorAtual + listaDepAtualSelected[x].valorProduto; 
			}
		}

		component.set('v.footerValueDepAtual', valorAtual);
    },

	changePaymentMethodUpgrade : function (component, event, helper) {
		var oferta = component.get('v.oferta');
		oferta.paymentMethodUpgrade = event.currentTarget.value;
		component.set('v.oferta', oferta);
	},

	changePaymentMethodMembership : function (component, event, helper) {
		var oferta = component.get('v.oferta');
		oferta.paymentMethodMembership = event.currentTarget.value;
		component.set('v.oferta', oferta);
	},

})