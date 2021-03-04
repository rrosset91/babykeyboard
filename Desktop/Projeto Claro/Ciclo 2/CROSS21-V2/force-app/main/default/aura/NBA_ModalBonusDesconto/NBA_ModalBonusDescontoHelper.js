({
	calculateValuePosse : function(component, currentProduct){

		var listDepAtual = component.get('v.produtoAtual.mobile.listaDependentesMobile');

		for(var index = 0; index < listDepAtual.length; index++){
			if(listDepAtual[index].checked){
				listDepAtual[index].valorProduto -= ((listDepAtual[index].valorProduto * listDepAtual[index].descontoDependente)/100);																	
			}					
		}
		currentProduct.mobile.planMobile.value -= ((currentProduct.mobile.planMobile.value *  currentProduct.mobile.descontTitular)/100);

		for(var x = 0; x < listDepAtual.length; x++){
			if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG'){
				totalDepComDescontoPG	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
				totalDepSemDescontoPG	+= listDepAtual[x].valorProduto;
			}else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL'){
				totalDepComDescontoBL	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
				totalDepSemDescontoBL	+= listDepAtual[x].valorProduto;
			}
		}

		component.set('v.produtoAtual', currentProduct);
		component.set('v.produtoAtual.mobile.listaDependentesMobile', listDepAtual);
		component.set('v.produtoAtual.mobile.mouseOverDependenteSemDescontoPG', 'Valor Após Desconto - ' + totalDepSemDescontoPG);
		component.set('v.produtoAtual.mobile.mouseOverDependenteComDescontoPG', totalDepComDescontoPG);
		component.set('v.produtoAtual.mobile.mouseOverDependenteSemDescontoBL', 'Valor Após Desconto - ' + totalDepSemDescontoBL);
		component.set('v.produtoAtual.mobile.mouseOverDependenteComDescontoBL', totalDepComDescontoBL);	
	},

	calculateValueOferta : function(component, ofertaSelecionada, produtoAtual){

		var listDepAtual 		  = component.get('v.ofertaSelecionada.mobile.listaDependentesMobile');
		var tiularSemDesconto	  = component.get('v.ofertaSelecionada.mobile.valueTitularSemDesconto');
		var totalDepComDescontoPG = 0;
		var totalDepSemDescontoPG = 0;
		var totalDepComDescontoBL = 0;
		var totalDepSemDescontoBL = 0;
		var valorProduto		  = 0;

		for(var index = 0; index < listDepAtual.length; index++){
			if(listDepAtual[index].checked){	
				valorProduto = ((listDepAtual[index].valorProduto * listDepAtual[index].descontoDependente)/100);						
				listDepAtual[index].valorProduto -= valorProduto;
				ofertaSelecionada.totalValue 	 -= valorProduto;
				ofertaSelecionada.totalValue	  = parseFloat(ofertaSelecionada.totalValue.toFixed(2));
				listDepAtual[index].valorProduto  = parseFloat(listDepAtual[index].valorProduto.toFixed(2));	 																
			}				
		}
		ofertaSelecionada.difTotal 	  = ofertaSelecionada.totalValue - produtoAtual.totalValue;
		var titularSemDesconto = ofertaSelecionada.mobile.planMobile.value;
		ofertaSelecionada.mobile.planMobile.value -= ((ofertaSelecionada.mobile.planMobile.value *  ofertaSelecionada.mobile.descontTitular)/100);
		ofertaSelecionada.totalValue 	 -= ((ofertaSelecionada.mobile.planMobile.value *  ofertaSelecionada.mobile.descontTitular)/100);
		ofertaSelecionada.totalValue	  = parseFloat(ofertaSelecionada.totalValue.toFixed(2));

		for(var x = 0; x < listDepAtual.length; x++){
			if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'BANDA_LARGA'){
				totalDepComDescontoPG	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
				totalDepSemDescontoPG	+= listDepAtual[x].valorProduto;
			}else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL'){
				totalDepComDescontoBL	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
				totalDepSemDescontoBL	+= listDepAtual[x].valorProduto;
			}
		}
		
		component.set('v.ofertaSelecionada', ofertaSelecionada);
		component.set('v.ofertaSelecionada.mobile.listaDependentesMobile', listDepAtual);
		//component.set('v.produtoAtual.mobile.listaDependentesMobile', listDepAtual);
		component.set('v.ofertaSelecionada.mobile.mouseOverDependenteSemDescontoPG', 'Valor Após Desconto - ' + totalDepSemDescontoPG);
		component.set('v.ofertaSelecionada.mobile.mouseOverDependenteComDescontoPG', totalDepComDescontoPG);
		component.set('v.ofertaSelecionada.mobile.mouseOverDependenteSemDescontoBL', 'Valor Após Desconto - ' + totalDepSemDescontoBL);
		component.set('v.ofertaSelecionada.mobile.mouseOverDependenteComDescontoBL', totalDepComDescontoBL);
		component.set('v.ofertaSelecionada.mobile.mouseOverValorSemDesconto', titularSemDesconto);	
		
		var telaAtual = component.get('v.controleDeTela');
		component.set('v.controleDeTela', !telaAtual);
	},
    

	verificarChecDesc :function (component, event, helper, index, listDep){
	
		if(listDep){
			if(listDep[index].descontoDependente > 0){
				if(listDep[index].listDescontoDependente){  
					for(var x = 0; x < listDep[index].listDescontoDependente.length; x++){
						if(listDep[index].listDescontoDependente[x].valor != listDep[index].descontoDependente){
							listDep[index].listDescontoDependente[x].check = false;
						}
					}
				}
			}else{
				if(listDep[index].listDescontoDependente){  
					for(var x = 0; x < listDep[index].listDescontoDependente.length; x++){
						listDep[index].listDescontoDependente[x].check = false;
						listDep[index].listDescontoDependente[x].disabled = false;
						//listDep[index].listDescontoDependente[x].valor = 0;
					}
				}
			}
		}
	},
	
	verificarChecBonus :function (component, event, helper, index, listDep){
	
		if(listDep){
			if(listDep[index].bonusDependente > 0){
				if(listDep[index].listBonusDependente){ 
					for(var x = 0; x < listDep[index].listBonusDependente.length; x++){
						if(listDep[index].listBonusDependente[x].valor != listDep[index].bonusDependente){
							listDep[index].listBonusDependente[x].check = false;
						}
					}
				}
			}else{
				if(listDep[index].listBonusDependente){ 
					for(var x = 0; x < listDep[index].listBonusDependente.length; x++){
						listDep[index].listBonusDependente[x].check = false;
						listDep[index].listBonusDependente[x].disabled = false;
						//listDep[index].listBonusDependente[x].valor = 0;
					}
				}
			}
		}
	},

})