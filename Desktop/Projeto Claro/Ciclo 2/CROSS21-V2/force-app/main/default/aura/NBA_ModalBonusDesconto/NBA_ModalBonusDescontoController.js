({
	incluirBonusDesconto : function(component, event, helper){
		var list = [{"valor":"10","check":false,"disabled":false},{"valor":"20","check":false,"disabled":false},{"valor":"30","check":false,"disabled":false},{"valor":"40","check":false,"disabled":false},{"valor":"50","check":false,"disabled":false}];
		component.set('v.listaDesc', list);
		var listbonus = [{"valor":"5","check":false,"disabled":false},{"valor":"8","check":false,"disabled":false},{"valor":"10","check":false,"disabled":false},{"valor":"15","check":false,"disabled":false},{"valor":"20","check":false,"disabled":false},];
		component.set('v.listaBonus', listbonus);
		var disabled = component.get('v.disabledBonusDesconto');
		if(disabled === false ){
			component.set('v.showModalBonusDesconto', true);
		}	
		
	},

	addBonusDescontoTitular : function(component, event, helper){
		var telaAtual = component.get('v.controleDeTela');
		var dep = component.get('v.produtoAtual.mobile.titularMobile.numeroTelefone');

		var listaDesc = component.get('v.ofertaSelecionada.mobile.listDescontoTitular');
		var listaBonus = component.get('v.ofertaSelecionada.mobile.listBonusTitular');

		//## Varre as listas de bonus e desconto desmarcando todos os flags para iniciar a tela de adicionar vazia
		for(var j = 0; j < listaDesc.length; j++){
			listaDesc[j].disabled = false;
			listaDesc[j].check = false;
		}

		for(var j = 0; j < listaBonus.length; j++){
			listaBonus[j].disabled = false;
			listaBonus[j].check = false;
		}

		component.set('v.tipoAdd', 'Titular');
		component.set('v.listaDesc', listaDesc);
		component.set('v.listaBonus', listaBonus);
		component.set('v.dependenteAtual', dep);
		component.set('v.controleDeTela', !telaAtual);
		component.set('v.dependenteTitular', 'TITULAR');

	},

	addBonusDesconto : function(component, event, helper){
		var telaAtual = component.get('v.controleDeTela');
		var index = event.getSource().get("v.name");
		var listDep = component.get('v.produtoAtual.mobile.listaDependentesMobile');
		var listDepPosse = component.get('v.produtoAtual.mobile.listaDependentesMobile');
		var dep = listDepPosse[index].numeroTelefone;
		helper.verificarChecDesc(component, event, helper, index, listDep);
        helper.verificarChecBonus(component, event, helper, index, listDep);
		component.set('v.indexAtual', index);
		component.set('v.tipoAdd', 'Dependente');
		component.set('v.listaDesc', listDep[index].listDescontoDependente);
		component.set('v.listaBonus', listDep[index].listBonusDependente);
		component.set('v.dependenteAtual', dep);
		component.set('v.controleDeTela', !telaAtual);
		component.set('v.dependenteTitular', 'DEPENDENTE');
	},

	desabilitarCheckDesc : function(component, event, helper){

		var ofertaSelecionada = component.get('v.ofertaSelecionada');
		var dependenteTitular = component.get('v.ofertaSelecionada.mobile');
		var depTitularPosse   = component.get('v.produtoAtual.mobile');
		var listDesc    	  = component.get('v.listaDesc');
		var depTitular  	  = component.get('v.dependenteTitular');
		var indexAtual 		  = component.get('v.indexAtual');
		var index 	    	  = event.getSource().get("v.name");
		var selecionado 	  = false;
		
		if(listDesc){
			for(var i = 0; i < listDesc.length; i++){
				if(listDesc[i].check == true){
					selecionado = true;
					if(depTitular == 'DEPENDENTE'){
						dependenteTitular.listaDependentesMobile[indexAtual].descontoDependente = listDesc[i].valor;
						depTitularPosse.listaDependentesMobile[indexAtual].descontoDependente = listDesc[i].valor;
					} else if (depTitular == 'TITULAR'){
						dependenteTitular.descontTitular = listDesc[i].valor;
						depTitularPosse.descontTitular = listDesc[i].valor;
					}
				}
			}
			if(selecionado){
				for(var j = 0; j < listDesc.length; j++){
					if(j != index){
						listDesc[j].disabled = true;
						listDesc[j].check = false;
					}
				}
			}else{
				for(var x = 0; x < listDesc.length; x++){
					listDesc[x].disabled = false;
					if (depTitular == 'TITULAR'){
						ofertaSelecionada.totalValue  += ((dependenteTitular.planMobile.value * dependenteTitular.descontTitular)/100);
						dependenteTitular.descontTitular = 0;
						depTitularPosse.descontTitular = 0;
						dependenteTitular.planMobile.value = dependenteTitular.valueTitularSemDesconto;  
						depTitularPosse.planMobile.value = depTitularPosse.valueTitularSemDesconto; 
					} else if(depTitular == 'DEPENDENTE'){
						ofertaSelecionada.totalValue  += ((dependenteTitular.listaDependentesMobile[indexAtual].valorProduto * dependenteTitular.listaDependentesMobile[indexAtual].descontoDependente)/100);
						dependenteTitular.descontoDependente = 0;
						depTitularPosse.descontoDependente = 0;
						dependenteTitular.listaDependentesMobile[indexAtual].valorProduto = dependenteTitular.listaDependentesMobile[indexAtual].valueDependenteSemDesconto;  
						depTitularPosse.listaDependentesMobile[indexAtual].valorProduto   = dependenteTitular.listaDependentesMobile[indexAtual].valueDependenteSemDesconto; 
					}
				}
			}
		}
		component.set('v.listaDesc', listDesc);
		component.set('v.ofertaSelecionada.mobile', dependenteTitular);
		component.set('v.produtoAtual.mobile', depTitularPosse);
	},

	desabilitarCheckBonus : function(component, event, helper){
		var depTitular = component.get('v.dependenteTitular');
		var dependente = component.get('v.ofertaSelecionada.mobile');
		var dependentePosse = component.get('v.produtoAtual.mobile');
		var listbonus = component.get('v.listaBonus');
		var indexAtual = component.get('v.indexAtual');
		var index = event.getSource().get("v.name");
		var selecionado = false;
		if(listbonus){
			for(var i = 0; i < listbonus.length; i++){
				if(listbonus[i].check == true){
					selecionado = true;
					if(depTitular == 'DEPENDENTE'){
						 dependente.listaDependentesMobile[indexAtual].bonusDependente = listbonus[i].valor;
						 dependentePosse.listaDependentesMobile[indexAtual].bonusDependente = listbonus[i].valor;
					}else if (depTitular == 'TITULAR'){
						dependente.bonusTitular = listbonus[i].valor;
						dependentePosse.bonusTitular = listbonus[i].valor;
					}
				}
			}
			if(selecionado){
				for(var j = 0; j < listbonus.length; j++){
					if(j != index){
						listbonus[j].disabled = true;
						listbonus[j].check = false;
					}
				}
			}else{
				for(var x = 0; x < listbonus.length; x++){
					listbonus[x].disabled = false;
					dependente.bonusTitular = 0;
					dependentePosse.bonusTitular = 0;  
				}
			}
		}
		component.set('v.listaBonus', listbonus);
		component.set('v.ofertaSelecionada.mobile', dependente);
		component.set('v.produtoAtual.mobile', dependentePosse);
	},

	cancelBonusDesconto : function(component, event, helper){
		var telaAtual = component.get('v.controleDeTela');
		component.set('v.controleDeTela', !telaAtual);
	},
	
	closeModal : function(component, event, helper) {
		component.set('v.showModalBonusDesconto', false);
		component.set('v.controleDeTela', true);
	},

	attBonusDesconto : function(component, event, helper){
		var ofertaSelecionada = component.get('v.ofertaSelecionada');
		var produtoAtual = component.get('v.produtoAtual');

		var depTitular      = component.get('v.dependenteTitular');
		var dependente      = component.get('v.ofertaSelecionada.mobile');
		var dependentePosse = component.get('v.produtoAtual.mobile');
		var listbonus       = component.get('v.listaBonus');
		var listDesc    	= component.get('v.listaDesc');
		var indexAtual      = component.get('v.indexAtual');

		//## varre a lista de bonus para ver quais itens estão marcados ou não na tela
		if(listbonus){
			for(var i = 0; i < listbonus.length; i++){
				if(listbonus[i].check == true){
					if(depTitular == 'DEPENDENTE'){
						 dependente.listaDependentesMobile[indexAtual].bonusDependente = listbonus[i].valor;
						 dependentePosse.listaDependentesMobile[indexAtual].bonusDependente = listbonus[i].valor;
					}else if (depTitular == 'TITULAR'){
						dependente.bonusTitular = listbonus[i].valor;
						dependentePosse.bonusTitular = listbonus[i].valor;
					}

					break;
				} else {
					dependente.bonusTitular = 0;
					dependentePosse.bonusTitular = 0;  
				}
			}
		}

		//## varre a lista de desconto para ver quais itens estão marcados ou não na tela
		if(listDesc){
			for(var i = 0; i < listDesc.length; i++){
				if(listDesc[i].check == true){
					if(depTitular == 'DEPENDENTE'){
						dependenteTitular.listaDependentesMobile[indexAtual].descontoDependente = listDesc[i].valor;
						dependentePosse.listaDependentesMobile[indexAtual].descontoDependente = listDesc[i].valor;
					} else if (depTitular == 'TITULAR'){
						dependente.descontTitular = listDesc[i].valor;
						dependentePosse.descontTitular = listDesc[i].valor;
					}
					break;
				} else {
					dependente.descontTitular = 0;
					dependentePosse.descontTitular = 0;
				}
			}
		}
		component.set('v.ofertaSelecionada.mobile', dependente);
		component.set('v.produtoAtual.mobile', dependentePosse);

		helper.calculateValueOferta(component, ofertaSelecionada, produtoAtual);
	}
})