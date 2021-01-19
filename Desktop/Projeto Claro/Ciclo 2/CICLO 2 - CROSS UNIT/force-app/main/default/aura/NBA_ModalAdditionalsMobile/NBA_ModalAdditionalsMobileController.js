({	
	
	forceAdditionalMobile : function(component, event, helper){
		if(component.get('v.forceAdditionalMobile')==true){
			$A.enqueueAction(component.get('c.incluirAdicionaisMobile'));
			$A.enqueueAction(component.get('c.updateAdditionalsMobile'));
			component.set('v.forceAdditionalMobile', false);
		}
	},
    
	loadAdditionalMobile : function(component, event, helper){
		if(component.get('v.oferta')!=null){
			helper.carregarAdicionaisMobile(component, event, helper);
			$A.enqueueAction(component.get('c.updateAdditionalsMobile'));
		}
	},
    
	incluirAdicionaisMobile : function(component, event, helper){
		var disabled = component.get('v.disabledMobile');
		if(disabled===false)
			component.set('v.showAdditionalMobile', true);
		helper.carregarAdicionaisMobile(component, event, helper);
	},
    
	closeAdicionalMobile : function(component, event, helper){
		component.set('v.showAdditionalMobile', false);
		$A.enqueueAction(component.get('c.updateAdditionalsMobile'));
	},
	
	resetOfferId : function(component, event, helper){
		if(component.get('v.showAdditionalMobile')==false)
			component.set('v.offerId', '');
    },

	updateAdditionalsMobile : function(component, event, helper){
		if(component.get('v.showAdditionalMobile')) component.set('v.showSpinner', true);

		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.oferta');
		var produtoAtual = component.get('v.produtoAtual');
		var lstPontuacao = component.get('v.lstPontuacao');
		var lstAdditionals = ofertaSelecionada.mobile.addOptions.lstAdditionals;
		var ofertaSelecionadaPosseAtual = true ;
		
		var closeModal = true;
		var isPortabilidade = false;
		if(component.get('v.showAdditionalMobile')){
			var phone = component.get("v.numeroTelefoneTitularOferta").replace(/[^0-9]+/g,'');
			
			if(component.find("origemTitularOferta")){
				isPortabilidade = component.find("origemTitularOferta").get("v.value") == 'Portabilidade';
			}
		
			if( isPortabilidade && phone.length != 11){
				closeModal = false;
				component.set('v.showSpinner', false);
				component.set('v.msgportabilidade' , 'Número da linha incompleto, por favor inserir um número com 11 caracteres incluindo o DDD');
				component.set('v.numeroTelefoneTitularOferta','');
				component.set('v.portabilidade' , true);
			}else if ( isPortabilidade ){
				closeModal = false;
				helper.checkPortability(component, event, helper);
			}
		}

		if(ofertaSelecionada === produtoAtual) {
			ofertaSelecionadaPosseAtual = false;
			produtoAtual = helper.updateAdditionalsMobileHelper(component, lstAdditionals, produtoAtual, produtoAtual, ofertaSelecionadaPosseAtual);
			produtoAtual = helper.calculateOriginalValue(component, produtoAtual);

			//CALC MOBILE
			//helper.calculoTeste(component, event, produtoAtual);
			component.set('v.produtoAtual', produtoAtual);
		}
		
		//helper.getValuesDep(component);
		if(oferta1 === ofertaSelecionada){
			if(oferta1.mobile.planMobile.label != "NÃO POSSUI"){
				oferta1 = helper.updateAdditionalsMobileHelper(component, lstAdditionals, oferta1, produtoAtual, ofertaSelecionadaPosseAtual);
				oferta1 = helper.calculateOriginalValueOferta(component, oferta1);
				oferta1 = helper.validateDifStepAdditionals(produtoAtual, oferta1);
				oferta1 = helper.validateDifStepTotalValue(produtoAtual, oferta1);
			}
		}
		if(oferta2 === ofertaSelecionada){
			if(oferta2.mobile.planMobile.label != "NÃO POSSUI"){
				oferta2 = helper.updateAdditionalsMobileHelper(component, lstAdditionals, oferta2, produtoAtual, ofertaSelecionadaPosseAtual);
				oferta2 = helper.calculateOriginalValueOferta(component, oferta2);
				oferta2 = helper.validateDifStepAdditionals(produtoAtual, oferta2);
				oferta2 = helper.validateDifStepTotalValue(produtoAtual, oferta2);
			}
		}
		if(oferta3 === ofertaSelecionada){
			oferta3 = helper.updateAdditionalsMobileHelper(component, lstAdditionals, oferta3, produtoAtual, ofertaSelecionadaPosseAtual);
			oferta3 = helper.calculateOriginalValueOferta(component, oferta3);
			oferta3 = helper.validateDifStepAdditionals(produtoAtual, oferta3);
			oferta3 = helper.validateDifStepTotalValue(produtoAtual, oferta3);
		}

		helper.calculoPercentualRecalculate(component, event, helper, lstPontuacao, ofertaSelecionada, produtoAtual);
		
		component.set('v.oferta1', oferta1);
		component.set('v.oferta2', oferta2);
		component.set('v.oferta3', oferta3);		
		
		if (component.get('v.showAdditionalMobile') && !isPortabilidade) component.set('v.showSpinner', false);	
		
		if (closeModal)component.set('v.showAdditionalMobile', false);
	},
    
    closemodalportabilidade : function(component, event, helper){
	
      	component.set('v.portabilidade' , false);	  
    },
	addPoint : function(component, event, helper){
		var checkOrder = event.getSource().get("v.name");
		var addOptions = component.get('v.oferta.tv.addOptions');
		
		if(checkOrder === '1'){
			addOptions.firstPoint.disabled = !addOptions.firstPoint.disabled;
			if(!addOptions.firstPoint.checked){
				addOptions.firstPoint.label = '';
			}
		
		} else if(checkOrder === '2'){
			if(addOptions.firstPoint.label !== ''){
				addOptions.secondPoint.disabled = !addOptions.secondPoint.disabled;
			}
			if(!addOptions.secondPoint.checked){
				addOptions.secondPoint.label = '';
			}
		
		} else if(checkOrder === '3'){
			if(addOptions.secondPoint.label !== ''){
				addOptions.thirdPoint.disabled = !addOptions.thirdPoint.disabled;
			}
			if(!addOptions.thirdPoint.checked){
				addOptions.thirdPoint.label = '';
			}

		} else if(checkOrder === '4'){
			if(addOptions.thirdPoint.label !== ''){
				addOptions.fourthPoint.disabled = !addOptions.fourthPoint.disabled;
			}
			if(!addOptions.fourthPoint.checked){
				addOptions.fourthPoint.label = '';
			}

		} else {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Campos obrigatórios!",
				"message": "Necessário preencher todas informações do ponto para passar para o próximo",
				"type": "error"
			});
			toastEvent.fire();
		}

		helper.updateOptionalPoints(component, addOptions);
		component.set('v.disabled', false);
		component.set('v.disabled', true);
	},
	updateListDependentesMobile : function(component, event, helper){
		
		var novo = component.find('new').get('v.checked');

		if(novo){
			var listDependentesAPI = component.get('v.oferta.mobile.listaDependentesMobile');
		
			var objNovo = {"disabled":false,"checked":false,"disabledNew":true,"feeProducts":[],"listBeneficiosDoPlano":[],"listProdutosAdicionais":[],"nomePlano":"","numeroTelefone":"","operadora":"Claro","origem":"Novo","promoSelected":"","technology":"","valorProduto":0} ;

			listDependentesAPI.push(objNovo);

			component.set('v.oferta.mobile.listaDependentesMobile', listDependentesAPI);

			component.set('v.atualizarlista', false);
			component.set('v.atualizarlista', true);

			component.find('new').set('v.checked', false);

		}

	},

	removeDep : function(component, event, helper){

		var checked = event.getSource().get("v.checked");
        var list;
        var index;
		if(checked === true){
			index = event.getSource().get("v.name");
			list = component.get('v.listDep');        
        
			if(list){                            
                
				for (let i = 0; i < list.length; i++){
					if(i === index){
						list[i].disabled = !checked;
					}            
				}    
			}    
			//list[index].disabled = !checked;
			component.set('v.listDep', list);
			component.set('v.atualizarlista2', false);
			component.set('v.atualizarlista2', true);
		}else{
			list = component.get('v.listDep');
			index = event.getSource().get("v.name");
            // var valorRemove = list[index].value;
            // var valortotalSemDesconto = component.get('v.oferta.totalValueOriginal');
            // var valortotalComDesconto = component.get('v.oferta.totalValue');
            // var valorR =  valortotalSemDesconto - valorRemove;
            // var valorOriginal =  valortotalComDesconto - valorRemove;
			// component.set('v.oferta.totalValueOriginal', valorR );
			// component.set('v.oferta.totalValue', valorOriginal );
			list.splice(index, 1);
			component.set('v.produtoAtual.mobile.numeroMaxDep', component.get('v.produtoAtual.mobile.numeroMaxDep') - 1 );
			component.set('v.listDep', list);
			component.set('v.atualizarlista2', false);
			component.set('v.atualizarlista2', true);

		}

	},

	updateAttChecked : function(component, event, helper){

		var movimentacaoAtual		= component.get('v.controleMovimentacaoDep');
		var controleMovimentacao	= '';
		var lstDepRemove			= [];
		var lstDepAdd				= [];
		var lstDepAtual				= component.get('v.produtoAtual.mobile.listaDependentesMobile');
		var mov						= event.getSource().get("v.checked");

		/* if(mov){
			if(movimentacaoAtual.includes("|")){
				var movArr = movimentacaoAtual.split('|', 2);
				
				if(movArr != null && movArr.size() > 0 && movArr[0] == 'Remove'){
					controleMovimentacao = movArr[0] + '|' + 'Add';
				}else if(movArr != null && movArr.size() > 0 && movArr[0] == 'Add'){
					controleMovimentacao = movArr[0] + '|' + 'Remove';
				}
			}else if(movimentacaoAtual == 'Remove'){
				controleMovimentacao = movimentacaoAtual + '|' + 'Add';
			}else if(movimentacaoAtual == 'Add'){
				controleMovimentacao = movimentacaoAtual + '|' + 'Remove';
			}else {
				controleMovimentacao = 'Add';
			}

			var index = event.getSource().get("v.name");
			for(let i = 0; i < lstDepAtual.length; i++){
				if(i === index){
					var dep = new Object();
					dep.Dependente		= lstDepAtual[i];
					dep.DataAdicao		= 
				}            
			}


		}else {
			if(movimentacaoAtual.includes("|")){
				var movArr = movimentacaoAtual.split('|', 2);
				
				if(movArr != null && movArr.size() > 0 && movArr[0] == 'Remove'){
					controleMovimentacao = movArr[0] + '|' + 'Add';
				}else if(movArr != null && movArr.size() > 0 && movArr[0] == 'Add'){
					controleMovimentacao = movArr[0] + '|' + 'Remove';
				}
			}else if(movimentacaoAtual == 'Remove'){
				controleMovimentacao = movimentacaoAtual + '|' + 'Add';
			}else if(movimentacaoAtual == 'Add'){
				controleMovimentacao = movimentacaoAtual + '|' + 'Remove';
			}else {
				controleMovimentacao = 'Remove';
			}


		}*/

		component.set('v.controleMovimentacaoDep', controleMovimentacao);

		var dep = new Object();

		component.set('v.checkUpdateInFiledChecked', true);
		var valorDep = component.get('v.lstValueDepSelected');
		var valorDepDesconto = component.get('v.lstValueDescontoDepSelected');
		
		var index;
		var list;
		var checked = event.getSource().get("v.checked");

		if(checked){
			
			index = event.getSource().get("v.name");
			
			// if(index == 0){
			// 	valorDep.splice(index, 1);
			// 	valorDepDesconto.splice(index, 1);

			// }else {
			// 	valorDep.splice(index - 1, 1);
			// 	valorDepDesconto.splice(index - 1, 1);
			// }

			list  = component.get('v.produtoAtual.mobile.listaDependentesMobile');        
                
			for(let i = 0; i < list.length; i++){
				if(i === index){
					valorDep.push( list[i].valorProduto );
					valorDepDesconto.push( list[i].deducedPrice );
				}            
			}        

		}else {
			
			list  = component.get('v.produtoAtual.mobile.listaDependentesMobile');        

			if(list.length == valorDep.length){
			
				index = event.getSource().get("v.name");
				if(index == 0){
					valorDep.splice(index, 1);
					valorDepDesconto.splice(index, 1);
				}else {
					valorDep.splice(index - 1, 1);
					valorDepDesconto.splice(index - 1, 1);
				}
			}else if(list.length > valorDep.length) {
				index = event.getSource().get("v.name");
				if(index == 0){
					valorDep.splice(index, 1);
					valorDepDesconto.splice(index, 1);
				}else {
					valorDep.splice(index, 1);
					valorDepDesconto.splice(index, 1);
				}
			}

		}

		component.set('v.lstValueDepSelected', valorDep);
		component.set('v.lstValueDescontoDepSelected', valorDepDesconto);

	},

	addDep : function(component, event,  helper){ 
		
		component.set('v.checkUpdateInFiledChecked', true);
		var listOld = component.get('v.listDep');
		var objNovo = {"disabled":true, "checked":false, "Origem":"Novo","operadora":"","numeroTelefone": "","utilizacao":"","promocao":"","value":0,"idDep":"","listaUtilizacao":[''],"listaPromocao":[''],"beneficios":[]};
		var numeroPosseAtual = component.get('v.produtoAtual.mobile.numeroMaxDep');
		var frist = component.get('v.frist');
		if(frist){
			component.set("v.oldMaxDep", numeroPosseAtual);
		}
		component.set('v.frist', false);
		var numeroMax = 10;//component.get('v.oferta.mobile.numeroMaxDep');
		var lengthListDep = component.get('v.oferta.mobile.listaDependentesMobile.length');
		if(lengthListDep === null || lengthListDep === 0 ){
			
			helper.showToast('Não disponivel ','Não existe dependentes disponiveis para essa oferta!','error');

		} else if(numeroMax > numeroPosseAtual){
				listOld.push(objNovo);
				component.set('v.produtoAtual.mobile.numeroMaxDep', component.get('v.produtoAtual.mobile.numeroMaxDep') + 1 );
		}else{
			
			helper.showToast('Número maximo de Dependentes','Você Atingiu o número maximo de Dependentes!','error');
		}

		component.set('v.listDep', listOld);
		component.set('v.atualizarlista2', false);
		component.set('v.atualizarlista2', true);

	},

	onchageOrigem : function(component, event, helper){
		
		var index = event.getSource().get('v.name');
		var lista = component.get('v.listDep');
		var origem = lista[index].origem;
		lista[index].operadora =  'Claro';
		lista[index].utilizacao = '';
		lista[index].promocao = '';
		lista[index].value = 0;
		lista[index].numeroTelefone = '';
		component.set('v.listDep', lista);
		helper.getUtilizacao(component, origem, index);
	},
	
	onchageOrigemTitular : function(component, event, helper){
		var origem = component.get('v.origemTitular');
		helper.getPromocaoTitularOferta(component, origem);
	},

	onchageUtilizacao : function(component, event, helper){
		
		var index = event.getSource().get('v.name');
		var lista = component.get('v.listDep');
		var origem = lista[index].origem;
		var utilizacao = lista[index].utilizacao;

		helper.getPromocao(component, origem, utilizacao, index);
	
	},

	onchangePromocao : function(component, event){
		var index = event.getSource().get('v.name');
		var dep = component.get('v.oferta.mobile.listaDependentesMobile');
		var newDep = component.get('v.listDep');
		var origem = newDep[index].origem;
		var utilizacao = newDep[index].utilizacao;
		var promocao = newDep[index].promocao;

		for(var x = 0; x < dep.length; x++){
			var params1 = dep[x].portabilityRequestType;
			var params2 = dep[x].nomePlano;
			
			if(params1 == '1' || params1 == '2')
				params1 = "Novo";
			else if(params1 === '8' || params1 === '9')
				params1 = "Portabilidade";

			if(params2 === 'BANDA_LARGA'){
				params2 = 'DADOS';
			}else if(params2 === 'POS_PAGO'){
				params2 = 'VOZ+DADOS';
			}

			if(params1 === origem && params2 === utilizacao && dep[x].promoSelected === promocao){
				newDep[index].value = dep[x].valorProduto;
				newDep[index].idDep = dep[x].newId;
				newDep[index].beneficios = dep[x].listBeneficiosDoPlano;
				component.set('v.listDep', newDep);
			}
		}
	},

	onchagePromocaoTitular : function(component, event, helper){
		var promocao = component.get('v.promocaoTitular');

		component.set('v.oferta.mobile.titularMobile.promocao', promocao);

		var valor = 0;
		var beneficios = [];

		var listBeneficiosDoPlano = (component.get('v.oferta.mobile.planMobile.label')!='MANTER' ? component.get('v.oferta.mobile.titularMobile.listBeneficiosDoPlano') : component.get('v.produtoAtual.mobile.titularMobile.listBeneficiosDoPlano'))  ;
		if(listBeneficiosDoPlano!=null && listBeneficiosDoPlano.length>0)
			beneficios = beneficios.concat(listBeneficiosDoPlano).filter(Boolean);  
		
		var listaTitulares = component.get('v.oferta.mobile.titularesOferta');
		component.set('v.idTitularOferta', '');
		for(var x = 0; x < listaTitulares.length; x++){
			if(listaTitulares[x].promoSelected === promocao ){
				valor = listaTitulares[x].valorProduto;	
				beneficios = listaTitulares[x].listBeneficiosDoPlano;
				component.set('v.idTitularOferta', listaTitulares[x].newId);
			}
		}
		if(component.get('v.showAdditionalMobile')){
			if(valor > 0)
				component.find('valorPromocaoTitular').set('v.value', valor);
			else
				component.find('valorPromocaoTitular').set('v.value', component.get('v.oferta.mobile.planMobile.originalValue'));
		}
		component.set('v.beneficionsPromocaoTitular', beneficios);
	},

	onchagePromocaoTitularOferta : function(component, event, helper){
		var origem = component.get('v.origemTitular');
		var promocao = component.get('v.promocaoTitularOferta');
		
		component.set('v.oferta.mobile.titularMobile.promocao', promocao);
		var listaTitulares = component.get('v.oferta.mobile.titularesOferta');
		var valor = 0;
		var beneficios = [];
		component.set('v.idTitularOferta', '');
		for(var x = 0; x < listaTitulares.length; x++){
			var portabilityRequestType = helper.formatOrigem(listaTitulares[x].portabilityRequestType);
				if(listaTitulares[x].promoSelected === promocao && portabilityRequestType === origem){
					valor = listaTitulares[x].valorProduto - listaTitulares[x].discountPromo;	
					beneficios = listaTitulares[x].listBeneficiosDoPlano;
					component.set('v.idTitularOferta', listaTitulares[x].newId);
				}
		}
		if(component.get('v.showAdditionalMobile')){
			if(valor > 0)
				component.find('valorPromocaoTitular').set('v.value', valor);
			else
				component.find('valorPromocaoTitular').set('v.value', component.get('v.oferta.mobile.planMobile.originalValue'));
		}
		component.set('v.beneficionsPromocaoTitular', beneficios);
	},

	mascaraTelefone : function(component, event){
		
		var list = component.get('v.listDep');
		var index = event.getSource().get('v.name');
		var valor = event.getSource().get('v.value');	
		var valorNovo = valor.replace(/[^0-9]/, '').replace(/(\d{2})(\d{5})(\d{4})/,"(\$1)\$2-\$3");
		for(var x = 0; x < list.length; x++){
			if(x === index){
				list[x].numeroTelefone = valorNovo;			
			}
		}
		component.set('v.listDep', list);
	},

	mascaraTelefoneTitular : function(component, event){
		
		var valor = event.getSource().get('v.value');	
		var valorNovo = valor.replace(/[^0-9]/, '').replace(/(\d{2})(\d{5})(\d{4})/,"(\$1)\$2-\$3");
		component.find('numeroTelefoneTitular').set('v.value', valorNovo);
	},

})