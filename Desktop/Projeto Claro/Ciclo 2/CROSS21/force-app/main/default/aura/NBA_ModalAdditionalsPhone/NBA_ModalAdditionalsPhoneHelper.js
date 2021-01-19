({
	updateAdditionalsPhoneHelper : function(component, addOptions, offer, current) {
		offer.phone.addOptions = addOptions;
		return offer;
	},

	calculoPercentualRecalculate: function (component, event, helper, lstPontuacao, ofertaSelecionada, produtoAntigo) {

		if(lstPontuacao && ofertaSelecionada && produtoAntigo){
			var percentual = 100 * (ofertaSelecionada.totalValue / produtoAntigo.totalValue);
			for(var i = 0; i<lstPontuacao.length; i++){
				if(percentual >= lstPontuacao[i].MinPercentage__c && percentual <= lstPontuacao[i].MaxPercentage__c){
					component.set('v.oferta.incentive', lstPontuacao[i].Pointing__c);
					break;
				}
			}
		}
	}, 

		calculateOriginalValue : function(component, currentProduct){
			var descontoBL = 0;
			var descontoPG = 0;
			var descontoTitular = 0;
			if(currentProduct.mobile.planMobile.label != 'NÃO POSSUI'){
				var descontoBL = parseInt(currentProduct.mobile.descontoDependenteBL);
				var descontoPG = parseInt(currentProduct.mobile.descontoDependentePG);
				var descontoTitular = parseInt(currentProduct.mobile.descontoTitular);
			}
			var originalValue = 0;
			var indexMaior = 0;			
			if(currentProduct.lstSteps.length > 0){
				for(var i = 0; i<currentProduct.lstSteps.length; i++){					
					if(currentProduct.lstSteps[i].label != null && parseInt(currentProduct.lstSteps[i].label) > indexMaior){
						indexMaior = parseInt(currentProduct.lstSteps[i].label);
						originalValue = currentProduct.lstSteps[i].value;
						currentProduct.totalValueOriginal = originalValue + descontoBL + descontoPG + descontoTitular;
					}			
				}
			}

			if(indexMaior == 0){
				var totalValue = currentProduct.totalValue;
				currentProduct.totalValueOriginal = totalValue + descontoBL + descontoPG + descontoTitular;
			}		
			
			return currentProduct;		
		},

		calculateOriginalValueOferta : function(component, ofertaSelecionada){
			var originalValue	   = 0;
			var descontoDep		   = 0;
			var descontoTit		   = 0;
			var indexMaior 		   = 0;
			var listDepProduto     = component.get('v.produtoAtual.mobile.listaDependentesMobile');
			var produtoAtual	   = component.get('v.produtoAtual');
			var calculate		   = component.get('v.calculate');

			if(calculate == false){
				for(var index = 0; index<ofertaSelecionada.lstSteps.length; index++){				
					if(ofertaSelecionada.lstSteps[index].label != null && parseInt(ofertaSelecionada.lstSteps[index].label) > indexMaior){
						indexMaior = parseInt(ofertaSelecionada.lstSteps[index].label);
						originalValue = ofertaSelecionada.lstSteps[index].value;
						ofertaSelecionada.totalValueOriginal = originalValue;
						ofertaSelecionada.difTotal = ofertaSelecionada.totalValueOriginal - produtoAtual.totalValue;
					}			
				}				              
        
				if(ofertaSelecionada.mobile.planMobile.label == 'MANTER'){
					if(listDepProduto.length > 0 && listDepProduto != null) {
						for (var index = 0; index < listDepProduto.length; index++) {
							if(listDepProduto[index].checked) {
								if (listDepProduto[index].deducedPrice != null) {
									descontoDep += listDepProduto[index].deducedPrice;
									descontoTit = produtoAtual.mobile.descontoTitular;
								}
							}
						}
					}
				} 
		
				ofertaSelecionada.totalValue -= descontoDep;
				ofertaSelecionada.totalValue -= descontoTit;
                
				if(indexMaior == 0){					
					var totalValue = ofertaSelecionada.totalValue;
					ofertaSelecionada.totalValueOriginal = totalValue + descontoDep + descontoTit;														
				} else {
					ofertaSelecionada.totalValueOriginal += descontoDep + descontoTit;																			
				}
		
				ofertaSelecionada.difTotal = ofertaSelecionada.totalValue - produtoAtual.totalValue;
			}

			return ofertaSelecionada;	


						
		},

})