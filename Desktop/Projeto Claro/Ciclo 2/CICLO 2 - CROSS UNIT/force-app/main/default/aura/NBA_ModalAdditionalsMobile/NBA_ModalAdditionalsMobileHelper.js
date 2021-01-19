({	
	carregarAdicionaisMobile : function(component, event, helper){
		this.getOrigem(component);
		
		// só busca quando é aquisição, pois quando já tem na posse, os valores estão fixos
		if(component.get('v.produtoAtual.mobile.planMobile.label') == 'NÃO POSSUI')
			this.getOrigemTitular(component);
		
		this.numeroDeDependentes(component);

		// só busca quando já tem na posse, pois quanto é aquisição, a propria origem dispara o carregamento das promos
		if(component.get('v.produtoAtual.mobile.planMobile.label') != 'NÃO POSSUI')
			this.getPromocaoTitular(component);
	},
	
	checkValidateCepPortability : function(component, event, helper){
		var caseId = component.get("v.caseId");
		var phone = component.get("v.numeroTelefoneTitularOferta").replace(/[^0-9]+/g,''); 
		var action = component.get("c.checkValidateCepPortability");
		
		 action.setParams({
		 	"caseId": caseId
		 });
		 action.setCallback(this, function(response) {
			 var state = response.getState();
			 
			component.set('v.showSpinner', false);
		 	if (state === "SUCCESS") {
				 var result = JSON.parse(response.getReturnValue());
				 
				 if(result.success){
					let body = JSON.parse(result.body);
					let dddSF = phone.substring(0,2);
					let dddApi = body.data.address[0].ddd;
					let cidadeApi = body.data.address[0].city;
					
                    if(dddApi == dddSF){
						component.set('v.showAdditionalMobile' , false);
						component.set('v.dddOk' , true);
						
                    }else{
						component.set('v.showAdditionalMobile' , true);
						component.set('v.dddOk' , false);
						component.set('v.msgportabilidade' , 'O DDD da linha é divergente do endereço Residencial, não sendo possível prosseguir com a Oferta. Por favor orientar o cliente a utilizar uma linha com DDD igual ao da residência ou oferecer uma nova linha' + '.');
						component.set('v.numeroTelefoneTitularOferta','');
						component.set('v.portabilidade' , true);
						
                    }
                }else{
					component.set('v.showAdditionalMobile' , false);
					component.set('v.dddOk' , false);
					component.set('v.msgportabilidade' , 'O Sistema que valida o número está indisponível, antes de prosseguir com a portabilidade, confirme com o cliente o número e o DDD e se a cidade é compatível ao DDD' + '.');
					component.set('v.portabilidade' , true);
			}
                
                
		 	}
		 });
		 $A.enqueueAction(action);
	
	},
	FormatNumberphone: function (str){
		
			//Filter only numbers from the input
			let cleaned = ('' + str).replace(/\D/g, '');
			
			//Check if the input is of correct length
			let match = cleaned.match(/^(\d{2})(\d{5})(\d{4})$/);
		  
			if (match) {
			  return '(' + match[1] + ') ' + match[2] + '-' + match[3]
			};
		  
			return null
	},
		
	
	checkPortability : function(component, event, helper){
		var phone = component.get("v.numeroTelefoneTitularOferta");
		var action = component.get("c.checkPortability");
		
		 action.setParams({
		 	"celular": phone
		 });

		 action.setCallback(this, function(response) {
			 var state = response.getState();
			 component.set('v.showSpinner', false);
			
		 	if (state === "SUCCESS") {
				 var result = JSON.parse(response.getReturnValue());
				
                if(result.success){
					let body = JSON.parse(result.body);
					
					
					
					if(!body.data.portabilty.unavailables){
					 	helper.checkValidateCepPortability(component , event , helper);
					

					}else if(body.data.portabilty.unavailables.reasonId == "BILHETE_PRE_EXISTENTE"){
						let phonenumber = body.data.portabilty.unavailables.tickets[0].telephoneNumber.number
						component.set('v.msgportabilidade' , 'Já foi solicitado a portabilidade deste número ' +  helper.FormatNumberphone(phonenumber)  + ' por favor, orientar cliente a aguardar a janela de portabilidade!');
						component.set('v.portabilidade', true);
						component.set('v.numeroTelefoneTitularOferta','');

					}else if(body.data.portabilty.unavailables == undefined || body.data.portabilty.unavailables== '' ||  body.data.portabilty.unavailables== null){
						//component.set('v.showAdditionalMobile' , false);
						helper.checkValidateCepPortability(component , event , helper);
					

					}else if(body.data.portabilty.unavailables.reasonId == "PREFIXO_NAO_CADASTRADO"){
						component.set('v.msgportabilidade' , 'Número de telefone inválido.');
						component.set('v.portabilidade' , true);
						component.set('v.numeroTelefoneTitularOferta','');
  					
                    }else{
						component.set('v.msgportabilidade' , 'Essa linha consta na base da Claro, portanto seguir com a venda no sistema legado.');
						component.set('v.numeroTelefoneTitularOferta','');
						component.set('v.portabilidade' , true);
					}

				}else{
						component.set('v.showAdditionalMobile' , false);
						component.set('v.dddOk' , false);
						component.set('v.msgportabilidade' , 'O Sistema que valida o número está indisponível, favor confirmar DDD número e cidade compatível com o DDD' + '.');
						component.set('v.portabilidade' , true);
				}
                console.log(result);
                
		 	}
		 });
		 $A.enqueueAction(action);
		 
	},

	updateAdditionalsMobileHelper : function(component, lstAdditionals, offer, current, ofertaSelecionadaPosseAtual) {
		this.dependentesPosseAtual(component);
		offer.totalValue -= Math.abs(offer.mobile.totalDependentesSelected);
		offer.totalValue -= Math.abs(current.mobile.totalDependentes);
		offer.totalValue += Math.abs(offer.mobile.titularMobile.discountPromo);
		offer.totalValueOriginal -= Math.abs(offer.mobile.totalDependentesSelected);
		offer.totalValueOriginal += Math.abs(offer.mobile.titularMobile.discountPromo);


		this.getValuesDep(component);
		offer.mobile.numeroDependentesVozDados = offer.mobile.numeroDependentesVozDadosOriginal;
		offer.mobile.numeroDependentesDados = offer.mobile.numeroDependentesDadosOriginal;
		offer.mobile.totalVozDados = 0;
		offer.mobile.totalDados = 0;

		var steps = offer.lstSteps;
		if(steps.length > 0){
			for(var step = 0; step < steps.length; step++){
				steps[step].value += offer.mobile.totalDependentesSelected;
			}
		}
		this.dependentesPosseAtual(component);

		offer.totalValue += offer.mobile.totalDependentesSelected;
		offer.totalValue -= offer.mobile.titularMobile.discountPromo;
		offer.totalValueOriginal  += offer.mobile.totalDependentesSelected;
		offer.totalValueOriginal -= offer.mobile.titularMobile.discountPromo;
		offer.difTotal = offer.totalValue - current.totalValue;
		offer.mobile.difProducts = offer.mobile.planMobile.value - current.mobile.planMobile.value;
		
		return offer;
	},

	calcDependenteMobile : function(component, event, offer){
		var jsonOffer = JSON.stringify(offer);
		var action = component.get("c.calculateDependenteMobile");
		action.setParams({
			"jsonProdutoAtual": jsonOffer
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var data = response.getReturnValue();
			}
		});
		$A.enqueueAction(action);
		component.set('v.produtoAtual', produtoAtual);
		return offer;
	},

	validateDifAdditionals : function(current, offer){
		var lstAdditionalsOffer = offer.mobile.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.mobile.addOptions.lstAdditionals;

		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;
		
		for(var i in lstAdditionalsCurrent) {
			var add = lstAdditionalsCurrent[i];
			if (add.checked) {
				if (add.promoSelected) {
					totalAdditionalsCurrent += add.lstPromotions[add.promoSelected].value;
				} else {
					totalAdditionalsCurrent += add.value;
				}
			}
		}

		for(var i in lstAdditionalsOffer) {
			var add = lstAdditionalsOffer[i];
			if (add.checked) {
				if (add.promoSelected) {
					totalAdditionalsOffer += add.lstPromotions[add.promoSelected].value;
				} else {
					totalAdditionalsOffer += add.value;
				}
			}
		}

		var difAdditionals = totalAdditionalsOffer - totalAdditionalsCurrent;

		return difAdditionals;
	},

	validateDifStepAdditionals : function(current, offer){
		var lstAdditionalsOffer = offer.mobile.addOptions.lstAdditionals;
		var lstAdditionalsCurrent = current.mobile.addOptions.lstAdditionals;

		var totalAdditionalsCurrent = 0;
		var totalAdditionalsOffer = 0;
		
		var valids = [];
		for(var i in lstAdditionalsCurrent) {
			var add = lstAdditionalsCurrent[i];
			if (add.checked) {
				if (add.promoSelected) {
					valids.push(add.lstPromotions[add.promoSelected].valid);
				}
				totalAdditionalsCurrent += add.value;
			}
		}

		for(var i in lstAdditionalsOffer) {
			var add = lstAdditionalsOffer[i];
			if (add.checked) {
				if (add.promoSelected) {
					valids.push(add.lstPromotions[add.promoSelected].valid);
				}
				totalAdditionalsOffer += add.value;
			}
		}

		var maxValid = 0;

		if (valids.length > 0) {
			for (var x in valids) {
				if (parseInt(valids[x]) > maxValid)  {
					maxValid = parseInt(valids[x]);
				}
			}
		}

		if (current.mobile.dependentsMobile) {
			offer.mobile.difAdditionalsStep.value -= current.mobile.dependentsMobile.value;
		}

		if (offer.mobile.dependentsMobile) {
			offer.mobile.difAdditionalsStep.value += offer.mobile.dependentsMobile.value;
		}

		offer.mobile.difAdditionalsStep.label = maxValid > 0 ? maxValid : '';
		offer.mobile.difAdditionalsStep.value = (totalAdditionalsOffer - totalAdditionalsCurrent).toFixed(2);

		return offer;
	},

	validateDifStepTotalValue : function(current, offer){
		var lstStepsOffer = offer.lstSteps;
		var lstStepsCurrent = current.lstSteps;
		var lastStepOffer;
		var lastStepCurrent;

		if (lstStepsOffer) {
			lastStepOffer = lstStepsOffer[lstStepsOffer.length - 1];
		}

		if (lstStepsCurrent) {
			lastStepCurrent = lstStepsCurrent[lstStepsCurrent.length - 1];
		}

		if (lastStepOffer && lastStepCurrent) {
			if (lastStepOffer.value > 0 && lastStepCurrent.value > 0) {
				offer.difTotalStep.value = (lastStepOffer.value - lastStepCurrent.value).toFixed(2);
			} else if (lastStepOffer.value > 0) {
				offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
			} else if (lastStepCurrent.value > 0) {
				offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
			}
		} else if (lastStepOffer) {
			offer.difTotalStep.value = (lastStepOffer.value - current.totalValue).toFixed(2);
		} else if (lastStepCurrent) {
			offer.difTotalStep.value = (offer.totalValue - lastStepCurrent.value).toFixed(2);
		}

		var valids = [];
		for (var off in lstStepsOffer) {
			var step = lstStepsOffer[off];

			valids.push(step.label);
		}

		for (var cur in lstStepsCurrent) {
			var step = lstStepsCurrent[cur];

			valids.push(step.label);
		}

		var maxValid = 0;

		if (valids.length > 0) {
			for (var x in valids) {
				if (parseInt(valids[x]) > maxValid)  {
					maxValid = parseInt(valids[x]);
				}
			}
		}

		offer.difTotalStep.label = maxValid > 0 ? maxValid : '';

		return offer;
	},

	numeroDeDependentes : function(component){
		var listaNovos = component.get('v.oferta.mobile.listaDependentesMobileSelected');
		var listaInical = [];
		if(listaNovos){
			for(var x = 0; x < listaNovos.length; x++){
				var obj = {"disabled":true, "checked":false, "Origem":"Novo","operadora":"","numeroTelefone": "","utilizacao":"","promocao":"","value":0,"idDep":"","listaUtilizacao":[''],"listaPromocao":[''],"beneficios":[]};
				obj.checked = listaNovos[x].checked;
				obj.origem = this.formatOrigem(listaNovos[x].portabilityRequestType);
				obj.operadora = listaNovos[x].operadora;
				obj.numeroTelefone = listaNovos[x].numeroTelefone;
				obj.utilizacao = this.formatUtilizacao(listaNovos[x].nomePlano);
				obj.promocao = listaNovos[x].promoSelected;
				obj.value = listaNovos[x].valorProduto;
				obj.idDep = listaNovos[x].newId;
				obj.listaUtilizacao.push(this.formatUtilizacao(listaNovos[x].nomePlano));
				obj.listaPromocao.push(listaNovos[x].promoSelected);
				obj.beneficios = listaNovos[x].listBeneficiosDoPlano;

				listaInical.push(obj);
			}
			component.set('v.listDep', listaInical);
		}else{
			component.set('v.listDep', listaInical);
		}
		var oldMaxDep = component.get('v.oldMaxDep');
		if(oldMaxDep){
			component.set('v.produtoAtual.mobile.numeroMaxDep', oldMaxDep);
		}
	},
	
	showToast: function (title, message, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message,
			"type": type
		});
		toastEvent.fire();
	},

	getOrigem : function(component){
		
		var dependentes = component.get('v.oferta.mobile.listaDependentesMobile');
		var listaOrigem = [];

		for(var x = 0; x < dependentes.length; x++){
			if(dependentes[x].portabilityRequestType == '1' || dependentes[x].portabilityRequestType == '2')
				listaOrigem.push("Novo");
			else if(dependentes[x].portabilityRequestType == '8' || dependentes[x].portabilityRequestType == '9')
				listaOrigem.push("Portabilidade");
		}
		this.dependentesPosseAtual(component);
		var listaOrigemNew = this.duplicate(listaOrigem);
		component.set('v.listaOrigem', listaOrigemNew);
	},

	getOrigemTitular : function(component){
		var dependentes = component.get('v.oferta.mobile.titularesOferta');
		var listaOrigem = [];
		for(var x = 0; x < dependentes.length; x++){
			if(dependentes[x].portabilityRequestType == '1' || dependentes[x].portabilityRequestType == '2')
				listaOrigem.push("Novo");
			else if(dependentes[x].portabilityRequestType == '8' || dependentes[x].portabilityRequestType == '9')
				listaOrigem.push("Portabilidade");
		}
		var listaOrigemNew = this.duplicate(listaOrigem);
		component.set('v.listaOrigemTitular', listaOrigemNew);
		
		if(component.get('v.oferta.mobile.titularMobile.origem')!=null && component.get('v.oferta.mobile.titularMobile.origem')==component.get('v.origemTitular'))
			this.getPromocaoTitularOferta(component, component.get('v.origemTitular'));
		else if(component.get('v.oferta.mobile.titularMobile.origem')!=null)
			component.set('v.origemTitular', component.get('v.oferta.mobile.titularMobile.origem'));
		else if(listaOrigemNew.length>0){
			if(component.get('v.origemTitular')==listaOrigemNew[0])
				this.getPromocaoTitularOferta(component, component.get('v.origemTitular'));
			else
				component.set('v.origemTitular', listaOrigemNew[0]);
		}
	},

	getUtilizacao : function(component, origem, index){
		
		if(origem != ''){
			var dependentes = component.get('v.oferta.mobile.listaDependentesMobile');
			var listaUtilizacao = [''];

			for(var x = 0; x < dependentes.length; x++){
				var params1 = dependentes[x].portabilityRequestType;
			
				if(params1 == '1' || params1 == '2')
					params1 = "Novo";
				else if(params1 == '8' || params1 == '9')
					params1 = "Portabilidade";

				if(params1 === origem && dependentes[x].nomePlano === 'POS_PAGO'){
					listaUtilizacao.push("VOZ+DADOS");
				}else if(params1 === origem && dependentes[x].nomePlano === 'BANDA_LARGA'){
					listaUtilizacao.push("DADOS");
				}
			}
			var listaUtilizacaoNew = this.duplicate(listaUtilizacao);
			var newList = component.get('v.listDep');
			newList[index].listaUtilizacao = listaUtilizacaoNew;
			component.set('v.listDep', newList);
			component.set('v.enableUtilizacao', false);
		}else{
			component.set('v.enableUtilizacao', true);
		}
	},

	getPromocao : function(component, origem, utilizacao, index){
		
		if(origem != '' && utilizacao != ''){
			var dependentes = component.get('v.oferta.mobile.listaDependentesMobile');
			var listaPromocao = [''];

			for(var x = 0; x < dependentes.length; x++ ){
				var params1 = dependentes[x].portabilityRequestType;
				var params2 = dependentes[x].nomePlano;
			
				if(params1 == '1' || params1 == '2')
					params1 = "Novo";
				else if(params1 == '8' || params1 == '9')
					params1 = "Portabilidade";

				if(params2 === 'BANDA_LARGA'){
					params2 = 'DADOS';
				}else if(params2 === 'POS_PAGO'){
					params2 = 'VOZ+DADOS';
				}

				if(params1 === origem && params2 === utilizacao){
					listaPromocao.push(dependentes[x].promoSelected);		
				}
			}
			var listaPromocaoNew = this.duplicate(listaPromocao);
			var newList = component.get('v.listDep');
			newList[index].listaPromocao = listaPromocaoNew;
			newList[index].value = 0;
			newList[index].promocao = '';
			component.set('v.listDep', newList);
			component.set('v.enablePromocao', false);
		}else{
			component.set('v.enablePromocao', true);
		}
	},

	duplicate : function(list){
		var newList = [];
		for(var x = 0; x < list.length; x++){
			if(! newList.includes(list[x])){
				newList.push(list[x]);
			}
		}
		return newList;
	},
	
	getPromocaoTitular : function(component){
		component.set('v.showPromocao',false);
		var listaTitular = component.get('v.oferta.mobile.titularesOferta');
		var listaPromocaoTitular = [];
		for(var x = 0; x < listaTitular.length; x++){
			if(!listaPromocaoTitular.includes(listaTitular[x].promoSelected)){
				listaPromocaoTitular.push(listaTitular[x].promoSelected);
			}
		}
		component.set('v.listaPromocaoTitular', listaPromocaoTitular);

		if(component.get('v.offerId')==component.get('v.oferta.key'))
			component.set('v.oferta.mobile.titularMobile.promocao', null);
		if(component.get('v.showAdditionalMobile'))
			component.set('v.offerId', component.get('v.oferta.key'));
		else
			component.set('v.offerId', '');

		if(component.get('v.oferta.mobile.titularMobile.promocao')!=null && component.get('v.oferta.mobile.titularMobile.promocao')==component.get('v.promocaoTitular'))
			$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
		else if(component.get('v.oferta.mobile.titularMobile.promocao')!=null)
			component.set('v.promocaoTitular', component.get('v.oferta.mobile.titularMobile.promocao'));
		else if(listaPromocaoTitular.length>0){
			if(component.get('v.promocaoTitular')==listaPromocaoTitular[0])
				$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
			else
				component.set('v.promocaoTitular', listaPromocaoTitular[0]);
		}
		else{
			component.set('v.promocaoTitular', '');
			$A.enqueueAction(component.get('c.onchagePromocaoTitular'));
		}

		component.set('v.showPromocao',true);
	},

	getPromocaoTitularOferta : function(component, origem){
		component.set('v.oferta.mobile.titularMobile.origem', origem);
		
		if(component.get('v.showAdditionalMobile')){
			if(origem=='Portabilidade' && component.get('v.oferta.mobile.titularMobile.numeroTelefone')!=null){
				component.find('operadoraTitular').set('v.value',component.get('v.oferta.mobile.titularMobile.operadora'));
				component.find('numeroTelefoneTitular').set('v.value',component.get('v.oferta.mobile.titularMobile.numeroTelefone'));
			}else{
				component.find('operadoraTitular').set('v.value','Claro');
				component.find('numeroTelefoneTitular').set('v.value','');
			}
		}

		component.set('v.showPromocao',false);
		var listaTitular = component.get('v.oferta.mobile.titularesOferta');
		var listaPromocaoTitular = [];
		for(var x = 0; x < listaTitular.length; x++){
			var portabilityRequestType = this.formatOrigem(listaTitular[x].portabilityRequestType);
			if(portabilityRequestType === origem && !listaPromocaoTitular.includes(listaTitular[x].promoSelected)){
				listaPromocaoTitular.push(listaTitular[x].promoSelected);
			}
		}
		component.set('v.listaPromocaoTitular', listaPromocaoTitular);

		if(component.get('v.offerId')==component.get('v.oferta.key'))
			component.set('v.oferta.mobile.titularMobile.promocao', null);
		if(component.get('v.showAdditionalMobile'))
			component.set('v.offerId', component.get('v.oferta.key'));
		else
			component.set('v.offerId', '');

		if(component.get('v.oferta.mobile.titularMobile.promocao')!=null && component.get('v.oferta.mobile.titularMobile.promocao')==component.get('v.promocaoTitularOferta'))
			$A.enqueueAction(component.get('c.onchagePromocaoTitularOferta'));
		else if(component.get('v.oferta.mobile.titularMobile.promocao')!=null)
			component.set('v.promocaoTitularOferta', component.get('v.oferta.mobile.titularMobile.promocao'));
		else if(listaPromocaoTitular.length>0){
			if(component.get('v.promocaoTitularOferta')==listaPromocaoTitular[0])
				$A.enqueueAction(component.get('c.onchagePromocaoTitularOferta'));
			else
				component.set('v.promocaoTitularOferta', listaPromocaoTitular[0]);
		}

		component.set('v.showPromocao',true);
		
	},

	formatOrigem : function(origem){
		var retorno = '';
		if(origem == '1' || origem == '2')
			retorno = "Novo";
		else if(origem == '8' || origem == '9')
			retorno = "Portabilidade";
		
		
		return retorno ;	
	},

	formatUtilizacao : function(utilizacao){
		var retorno = '';
		if(utilizacao === 'POS_PAGO'){
			retorno = "VOZ+DADOS";
		}else if(utilizacao === 'BANDA_LARGA'){
			retorno = "DADOS";
		}

		return retorno;
	},
	
	dependentesPosseAtual : function(component){
		
		var listDepAtual = component.get('v.produtoAtual.mobile.listaDependentesMobile');
		var listDepAtualRefactored = [];
		var numeroDadosVoz = 0;
		var numeroDados = 0;
		var numeroControle = 0;
		var totalDadosVoz = 0;
		var totalDados = 0;
		var totalControle = 0;
		var totalDependentes = 0;

		var setDependentes = new Set();
		for(var x = 0; x < listDepAtual.length; x++){
			if(listDepAtual[x].valorProduto > 0){
				var valorDependente = false;
				for(var y = 0; y <listDepAtualRefactored.length; y++){
					if(listDepAtual[x].numeroTelefone == listDepAtualRefactored[y].numeroTelefone){
						valorDependente = true;
						listDepAtualRefactored[y].valorProduto+=listDepAtual[x].valorProduto;
					}
				}
				if(!valorDependente){
					if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG'){				
						numeroDadosVoz++;
						totalDadosVoz = totalDadosVoz + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
					else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL'){
						numeroDados++;
						totalDados = totalDados + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
					else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'CONTROLE'){
						numeroControle++;
						totalControle = totalControle + listDepAtual[x].valorProduto;
						totalDependentes = totalDependentes + listDepAtual[x].valorProduto;
						listDepAtual[x].promoSelected = '';
					}
					listDepAtualRefactored.push(listDepAtual[x]);
				}  
			}
		}

		component.set('v.produtoAtual.mobile.listaDependentesMobile', listDepAtualRefactored);
		component.set('v.produtoAtual.mobile.totalDependentes', totalDependentes);
		component.set('v.produtoAtual.mobile.numeroDependentesVozDados',numeroDadosVoz);
		component.set('v.produtoAtual.mobile.numeroDependentesDados',numeroDados);
		component.set('v.produtoAtual.mobile.totalVozDados',totalDadosVoz);
		component.set('v.produtoAtual.mobile.totalDados',totalDados);	
	},

	getValuesDep : function(component){
		
		var ofertaSelecionada = component.get('v.oferta');
		
		var steps = ofertaSelecionada.lstSteps;
		if(steps){
			for(var x = 0; x < steps.length; x++){
				steps[x].value -= ofertaSelecionada.mobile.totalDependentesSelected;
			}
		}
		component.set('v.oferta.lstSteps', steps);
		component.set('v.oferta.mobile.numeroDependentesVozDadosSelected', 0);
		component.set('v.oferta.mobile.totalVozDadosSelected', 0);
		component.set('v.oferta.mobile.numeroDependentesDadosSelected', 0);
		component.set('v.oferta.mobile.totalDadosSelected', 0);
		component.set('v.oferta.mobile.totalDependentesSelected', 0);
		component.set('v.oferta.mobile.totalDependentes', 0);
		var totalDep = 0;

		//Alexandre Amaro (adicionar dependentes)
		var newDep = component.get('v.listDep');
		var newList = [];
		if(newDep){
			for(var x = 0; x < newDep.length; x++){
				if(newDep[x].idDep != ''){
					var idDependente = newDep[x].idDep;
					for(var y = 0; y < ofertaSelecionada.mobile.listaDependentesMobile.length; y++){
						if(ofertaSelecionada.mobile.listaDependentesMobile[y].newId === idDependente){
							ofertaSelecionada.mobile.listaDependentesMobile[y].numeroTelefone = newDep[x].numeroTelefone;
							ofertaSelecionada.mobile.listaDependentesMobile[y].origem = newDep[x].origem;
							ofertaSelecionada.mobile.listaDependentesMobile[y].operadora = newDep[x].operadora;
							newList.push(ofertaSelecionada.mobile.listaDependentesMobile[y]);
							if(ofertaSelecionada.mobile.listaDependentesMobile[y].nomePlano === 'POS_PAGO'){
								component.set('v.oferta.mobile.numeroDependentesVozDadosSelected', component.get('v.oferta.mobile.numeroDependentesVozDadosSelected') + 1);
								component.set('v.oferta.mobile.totalVozDadosSelected', component.get('v.oferta.mobile.totalVozDadosSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto );
								//component.set('v.oferta.mobile.dependentslMobile.value', component.get('v.oferta.mobile.dependentslMobile.value') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
								totalDep += ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto;
								component.set('v.oferta.mobile.totalDependentesSelected',component.get('v.oferta.mobile.totalDependentesSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
							}else if(ofertaSelecionada.mobile.listaDependentesMobile[y].nomePlano === 'BANDA_LARGA'){
								component.set('v.oferta.mobile.numeroDependentesDadosSelected', component.get('v.oferta.mobile.numeroDependentesDadosSelected') + 1);
								component.set('v.oferta.mobile.totalDadosSelected', component.get('v.oferta.mobile.totalDadosSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto );
								//component.set('v.oferta.mobile.dependentslMobile.value', component.get('v.oferta.mobile.dependentslMobile.value') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
								totalDep += ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto;
								component.set('v.oferta.mobile.totalDependentesSelected',component.get('v.oferta.mobile.totalDependentesSelected') + ofertaSelecionada.mobile.listaDependentesMobile[y].valorProduto);
							}	
						}
					}
				}
			}
			
			var listTitulares = component.get('v.oferta.mobile.titularesOferta');
			var newIdTittular = component.get('v.idTitularOferta');
			var promo = {valid:0,discount:0,value:0,label:''};
			var lstPromo = [];//component.get('v.oferta.mobile.planMobile.lstPromotions');
			var telefoneAnterior  = component.get('v.oferta.mobile.titularMobile.numeroTelefone');
			var operadoraAnterior = component.get('v.oferta.mobile.titularMobile.operadora');

			for(var x = 0; x < listTitulares.length; x++){
				if(newIdTittular === listTitulares[x].newId){
					promo.valid = listTitulares[x].validFor;
					promo.discount = listTitulares[x].discountPromo;
					promo.label = listTitulares[x].promoSelected;
					promo.value = listTitulares[x].valorProduto;
					component.set('v.oferta.mobile.titularMobile', listTitulares[x]);
					component.set('v.oferta.mobile.titularMobile.promocao', listTitulares[x].promoSelected);
					component.set('v.oferta.mobile.planMobile.value', listTitulares[x].valorProduto - listTitulares[x].discountPromo);
					lstPromo = [promo];
				}
			}
			
			if(component.find('numeroTelefoneTitular')!==undefined && component.get('v.showAdditionalMobile')){
				if(component.find('numeroTelefoneTitular').get('v.value')!=''){
					component.set('v.oferta.mobile.titularMobile.numeroTelefone', component.find('numeroTelefoneTitular').get('v.value') );
					component.set('v.oferta.mobile.titularMobile.operadora', component.find('operadoraTitular').get('v.value'));
				}else if(telefoneAnterior!=null){
					component.set('v.oferta.mobile.titularMobile.numeroTelefone', telefoneAnterior);
					component.set('v.oferta.mobile.titularMobile.operadora', operadoraAnterior);
				}
			}
			
			if(component.find('origemTitularOferta') !== undefined){
				var origemTitularOferta = component.find('origemTitularOferta').get('v.value');
				if(origemTitularOferta){
					component.set('v.oferta.mobile.titularMobile.origem', origemTitularOferta );
				}
			}

			component.set('v.oferta.mobile.planMobile.lstPromotions', lstPromo);
			//this.dependentesPosseAtual(component);
			component.set('v.oferta.mobile.totalDependentes', totalDep);
			component.set('v.oferta.mobile.listaDependentesMobileSelected', newList);
		}
	
	},

		calculoPercentualRecalculate: function (component, event, helper, lstPontuacao, ofertaSelecionada, produtoAntigo) {

			if(lstPontuacao && ofertaSelecionada && produtoAntigo ){
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
			var checkedDepDesconto		= 0;
			var checkedDepSemDesconto	= 0; 
			var sumDependente			= 0;
			var sumDependenteCheked		= 0;
			var uncheckedDepDesconto	= 0;
			var ofertaSelecionada		= component.get('v.ofertaSelecionada');
			var listDepAtual			= component.get('v.produtoAtual.mobile.listaDependentesMobile');
			var update							= component.get('v.checkUpdateInFiledChecked');
			var oldValueComDesconto				= component.get('v.oldValueComDesconto');
			var oldValueSemDesconto				= component.get('v.oldValueSemDesconto');
			var oldValueComDescontoChecked		= component.get('v.oldValueComDescontoChecked');
			var oldValueSemDescontoChecked		= component.get('v.oldValueSemDescontoChecked');
			var lstOfertas						= component.get('v.lstOfertas.lstOffers');

			if(update){
			var originalValue = 0;
			var indexMaior = 0;			
			if(currentProduct.lstSteps.length > 0){
				for(var i = 0; i<currentProduct.lstSteps.length; i++){					
					if(currentProduct.lstSteps[i].label != null && parseInt(currentProduct.lstSteps[i].label) > indexMaior){
						indexMaior = parseInt(currentProduct.lstSteps[i].label);
						originalValue = currentProduct.lstSteps[i].value;
						currentProduct.totalValueOriginal = originalValue;
					}			
				}
			}

			for(var index = 0; index < listDepAtual.length; index++){
				if(listDepAtual[index].checked){
					if(listDepAtual[index].deducedPrice != null){
							checkedDepDesconto += listDepAtual[index].deducedPrice;	
					}				
						sumDependenteCheked	+= listDepAtual[index].valorProduto;	
				} else {
					sumDependente += listDepAtual[index].valorProduto;
						uncheckedDepDesconto += listDepAtual[index].deducedPrice;
				}
			}


			if(indexMaior == 0){
					if(uncheckedDepDesconto > oldValueSemDesconto){
						currentProduct.totalValue = currentProduct.totalValue - ((sumDependente - uncheckedDepDesconto) - oldValueSemDesconto);
						currentProduct.totalValue += oldValueComDesconto;
					} else if (sumDependente > 0 && uncheckedDepDesconto == 0){
						currentProduct.totalValue = currentProduct.totalValue - sumDependente;
			} 	

					if(sumDependente > oldValueComDesconto){
						currentProduct.totalValueOriginal = currentProduct.totalValueOriginal - (sumDependente - oldValueComDesconto);
					}

					var lstDepValorProduto	= 0;
					var lstTotalValorDep	= component.get('v.lstValueDepSelected');
					for(var index = 0; index < lstTotalValorDep.length; index++){
						lstDepValorProduto += lstTotalValorDep[index];
					}

					var lstDepDesconto	= 0;
					var lstTotalDeducedDep	= component.get('v.lstValueDescontoDepSelected');
					for(var index = 0; index < lstTotalDeducedDep.length; index++){
						lstDepDesconto += lstTotalDeducedDep[index];
					}

					//DESCONTO POSSE - DIEGO
					if (oldValueSemDesconto > 0 &&  oldValueSemDesconto < lstDepDesconto && oldValueSemDesconto < checkedDepDesconto){
						currentProduct.totalValue = currentProduct.totalValue + (lstDepDesconto - oldValueSemDesconto);
					}else if(lstDepDesconto > oldValueSemDesconto){
						currentProduct.totalValue = currentProduct.totalValue - ( lstDepDesconto - oldValueSemDesconto );
					} else if (lstDepDesconto != oldValueSemDesconto){
						currentProduct.totalValue = currentProduct.totalValue + lstDepDesconto;
					} else if (lstDepDesconto == oldValueSemDesconto){
						currentProduct.totalValue = currentProduct.totalValue + (lstDepValorProduto - lstDepDesconto);
					}  

					if(lstDepValorProduto > oldValueSemDescontoChecked && lstDepValorProduto > sumDependente){
						currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + (lstDepValorProduto - oldValueSemDescontoChecked);
					}else if(lstDepValorProduto < oldValueSemDescontoChecked) {
						var sumFinal = 0;
						
						if(lstDepValorProduto > 0 && sumDependente > 0){
							sumFinal = oldValueSemDescontoChecked - lstDepValorProduto;
							currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + sumFinal;
						}else if(lstDepValorProduto > 0){
							sumFinal = oldValueSemDescontoChecked - lstDepValorProduto;
							currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + (sumFinal - sumDependente);
						}else if(sumDependente > 0) {
							sumFinal = oldValueSemDescontoChecked - sumDependente;
							if(oldValueSemDescontoChecked == sumDependente){
								currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + sumFinal;
							}else {
								currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + (sumFinal - sumDependente);
							}
						}

						if(sumDependente > 0 && lstDepValorProduto == 0){
							lstDepValorProduto = sumFinal;
						}else if(sumDependente > 0){
							lstDepValorProduto += sumDependente;
						}else if(sumFinal > 0){
							lstDepValorProduto += sumFinal;
						}

					}else {
						if(lstDepValorProduto > sumDependente){
							currentProduct.totalValueOriginal = currentProduct.totalValueOriginal + lstDepValorProduto;
							lstDepValorProduto = lstDepValorProduto + lstDepValorProduto; 
						}
					}

				} else {
					if(uncheckedDepDesconto > oldValueSemDesconto){
			currentProduct.totalValue -= uncheckedDepDesconto;
					}

					currentProduct.totalValueOriginal  = currentProduct.totalValueOriginal + currentProduct.totalValue;

					if(sumDependente > oldValueComDesconto){
			currentProduct.totalValueOriginal -= sumDependente;
					}
				}
			
				//NEW - 26/01/2020 - DIEGO
				var totalDepComDescontoPG  = 0;
				var totalDepSemDescontoPG  = 0;
				var totalDepComDescontoBL  = 0;
				var totalDepSemDescontoBL  = 0;
				var descontoDependenteBL  = 0;
				var descontoDependentePG  = 0;

				for(var x = 0; x < listDepAtual.length; x++){
					if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG'){
						totalDepComDescontoPG	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
						totalDepSemDescontoPG	+= listDepAtual[x].valorProduto;
						descontoDependentePG 	+= listDepAtual[x].deducedPrice;
					}else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL'){
						totalDepComDescontoBL	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
						totalDepSemDescontoBL	+= listDepAtual[x].valorProduto;
						descontoDependenteBL 	+= listDepAtual[x].deducedPrice;
					}
				}

				component.set('v.produtoAtual.mobile.mouseOverDependenteSemDescontoPG', 'Valor Após Desconto - ' + totalDepSemDescontoPG);
				component.set('v.produtoAtual.mobile.mouseOverDependenteComDescontoPG', totalDepComDescontoPG);
				component.set('v.produtoAtual.mobile.mouseOverDependenteSemDescontoBL', 'Valor Após Desconto - ' + totalDepSemDescontoBL);
				component.set('v.produtoAtual.mobile.mouseOverDependenteComDescontoBL', totalDepComDescontoBL);	
				component.set('v.produtoAtual.mobile.descontoDependenteBL', descontoDependenteBL);
				component.set('v.produtoAtual.mobile.descontoDependentePG', descontoDependentePG);

				component.set('v.checkUpdateInFiledChecked', false);	
				component.set('v.oldValueSemDesconto', uncheckedDepDesconto);
				component.set('v.oldValueComDesconto', sumDependente);
				component.set('v.oldValueComDescontoChecked', checkedDepDesconto);
				component.set('v.oldValueSemDescontoChecked', lstDepValorProduto);
				//FIM

				if(ofertaSelecionada == currentProduct){
					this.calculateOriginalValueTodasAsOfertas(component, lstOfertas, currentProduct);
				}
			}

			return currentProduct;	
		},

		calculateOriginalValueOferta : function(component, ofertaSelecionada){
			var lstOfertas						= component.get('v.lstOfertas');
			var originalValue			= 0;
			var sumDependenteCheked 			= 0;
			var indexMaior				= 0;		
			var checkedDepDesconto		= 0;
			var sumDependente			= 0;
			var uncheckedDepDesconto	= 0;
			var listDepAtual			= component.get('v.produtoAtual.mobile.listaDependentesMobile');	
			var listDepOferta					= ofertaSelecionada.mobile.listaDependentesMobileSelected;	
			var listDepOfertaAtual				= component.get('v.produtoAtual.mobile.listaDependentesMobile');	
			var produtoAtual			= component.get('v.produtoAtual');
        	var update							= component.get('v.checkUpdateInFiledChecked');
			var oldValueComDesconto				= component.get('v.oldValueComDesconto');
			var oldValueSemDesconto				= component.get('v.oldValueSemDesconto');
			var oldValueComDescontoChecked		= component.get('v.oldValueComDescontoChecked');
			var oldValueSemDescontoChecked		= component.get('v.oldValueSemDescontoChecked');
			var calculate						= component.get('v.calculate');
            var depOffer						= false;
			
            if(update && calculate == false){
			if(ofertaSelecionada.lstSteps.length > 0){
					indexMaior = 0;						
                    for(var i = 0; i<ofertaSelecionada.lstSteps.length; i++){
					   if(ofertaSelecionada.lstSteps[i].label != null && parseInt(ofertaSelecionada.lstSteps[i].label) > indexMaior){
						indexMaior = parseInt(ofertaSelecionada.lstSteps[i].label);
						originalValue = ofertaSelecionada.lstSteps[i].value;
						ofertaSelecionada.totalValueOriginal = originalValue;
					}			
				}
			}

				if(ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER'){
			for(var index = 0; index < listDepAtual.length; index++){
				if(listDepAtual[index].checked){
					if(listDepAtual[index].deducedPrice != null){
						checkedDepDesconto += parseInt(listDepAtual[index].deducedPrice);	
					}				
							sumDependenteCheked	+= listDepAtual[index].valorProduto;	
				} else {
					sumDependente += listDepAtual[index].valorProduto;
							uncheckedDepDesconto += listDepAtual[index].deducedPrice;
				}
			}
				} else {

					for(var index = 0; index < listDepOfertaAtual.length; index++){
						if(listDepOfertaAtual[index].checked){							
							sumDependenteCheked	+= listDepOfertaAtual[index].valorProduto;	
						} else {
							sumDependente += listDepOfertaAtual[index].valorProduto;
							uncheckedDepDesconto += listDepOfertaAtual[index].valorProduto;
						}
						depOffer = true; 
					}
				}

				if(listDepOferta != null && listDepOferta.length > 0) {
					for(var index = 0; index < listDepOferta.length; index++){
						if(listDepOferta[index].checked){
							if(listDepOferta[index].deducedPrice != null){
								checkedDepDesconto += parseInt(listDepOferta[index].deducedPrice);	
							}	
							sumDependenteCheked	+= listDepOferta[index].valorProduto;	
						} else {
							sumDependente += listDepOferta[index].valorProduto;
							uncheckedDepDesconto += listDepOferta[index].deducedPrice;
						}
					}
				}

				// RENATO

			if(indexMaior == 0){
					if(uncheckedDepDesconto > oldValueSemDesconto){
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - ((sumDependente - uncheckedDepDesconto) - oldValueSemDesconto);
						ofertaSelecionada.totalValue += oldValueComDesconto;
					} 
                    
                    if(depOffer == true){
						ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - sumDependente;
					}

					if(sumDependente > oldValueComDesconto){
						ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal - (sumDependente - oldValueComDesconto);
						if(uncheckedDepDesconto == 0){
							ofertaSelecionada.totalValue = ofertaSelecionada.totalValue - sumDependente;
						}
					}

					var lstDepValorProduto	= 0;
					var lstTotalValorDep	= component.get('v.lstValueDepSelected');
					for(var index = 0; index < lstTotalValorDep.length; index++){
						lstDepValorProduto += lstTotalValorDep[index];
					}

					var lstDepDesconto	= 0;
					var lstTotalDeducedDep	= component.get('v.lstValueDescontoDepSelected');
					for(var index = 0; index < lstTotalDeducedDep.length; index++){
						lstDepDesconto += lstTotalDeducedDep[index];
					}

					//DESCONTO POSSE - DIEGO
					if(ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER'){
						if(lstDepDesconto > 0){
							ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + (lstDepValorProduto - lstDepDesconto);
						}
					}else{
						if(lstDepDesconto > 0){
							ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + lstDepValorProduto;
						}
					}

					if(lstDepValorProduto > oldValueSemDescontoChecked){
						ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (lstDepValorProduto - oldValueSemDescontoChecked);
						if(lstDepDesconto <= 0){
							ofertaSelecionada.totalValue	 = ofertaSelecionada.totalValue + (lstDepValorProduto - oldValueSemDescontoChecked);
						}
                    }else if(lstDepValorProduto < oldValueSemDescontoChecked) {
						var sumFinal = 0;
						
						if(lstDepValorProduto > 0 && sumDependente > 0){
							sumFinal = oldValueSemDescontoChecked - lstDepValorProduto;
							ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + sumFinal;
						}else if(lstDepValorProduto > 0){
							sumFinal = oldValueSemDescontoChecked - lstDepValorProduto;
							ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (sumFinal - sumDependente);
						}else if(sumDependente > 0) {
							sumFinal = oldValueSemDescontoChecked - sumDependente;
							if(oldValueSemDescontoChecked == sumDependente){
								ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + sumFinal;
							}else {
								ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + (sumFinal - sumDependente);
							}
						}

						if(sumDependente > 0 && lstDepValorProduto == 0){
							lstDepValorProduto = sumFinal;
						}else if(sumDependente > 0){
							lstDepValorProduto += sumDependente;
						}else if(sumFinal > 0){
							lstDepValorProduto += sumFinal;
						}

					}else {
						ofertaSelecionada.totalValueOriginal = ofertaSelecionada.totalValueOriginal + lstDepValorProduto;
						lstDepValorProduto = lstDepValorProduto + lstDepValorProduto; 
					}

			} else {
					if(uncheckedDepDesconto > oldValueSemDesconto){
						ofertaSelecionada.totalValue -= (sumDependente - uncheckedDepDesconto);
						ofertaSelecionada.totalValue  = parseFloat(ofertaSelecionada.totalValue.toFixed(2));
			}	

					var lstDepValorProduto	= 0;
					var lstTotalValorDep	= component.get('v.lstValueDepSelected');
					for(var index = 0; index < lstTotalValorDep.length; index++){
						lstDepValorProduto += lstTotalValorDep[index];
					}

					var lstDepDesconto	= 0;
					var lstTotalDeducedDep	= component.get('v.lstValueDescontoDepSelected');
					for(var index = 0; index < lstTotalDeducedDep.length; index++){
						lstDepDesconto += lstTotalDeducedDep[index];
					}

					//DESCONTO POSSE - DIEGO
					if(ofertaSelecionada == produtoAtual || ofertaSelecionada.mobile.planMobile.label == 'MANTER'){
						if(lstDepDesconto > 0){
							ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + (lstDepValorProduto - lstDepDesconto);
						}
					}else{
						if(lstDepDesconto > 0){
							ofertaSelecionada.totalValue = ofertaSelecionada.totalValue + lstDepValorProduto;
						}
					}

					//ofertaSelecionada.totalValueOriginal  = ofertaSelecionada.totalValueOriginal + ofertaSelecionada.totalValue;

					if(sumDependente > oldValueComDesconto){
				ofertaSelecionada.totalValueOriginal -= sumDependente;
					}
				}

				if(ofertaSelecionada.automaticDebitDiscount > 0){
					//ofertaSelecionada.totalValueOriginal -= ofertaSelecionada.automaticDebitDiscount;
			}

				//NEW - 26/01/2020 - DIEGO
				var totalDepComDescontoPG  = 0;
				var totalDepSemDescontoPG  = 0;
				var totalDepComDescontoBL  = 0;
				var totalDepSemDescontoBL  = 0;

				for(var x = 0; x < listDepAtual.length; x++){
					if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS PG'){
						totalDepComDescontoPG	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
						totalDepSemDescontoPG	+= listDepAtual[x].valorProduto;
					}else if(listDepAtual[x].checked && listDepAtual[x].nomePlano === 'POS BL'){
						totalDepComDescontoBL	+= (listDepAtual[x].valorProduto - listDepAtual[x].deducedPrice);
						totalDepSemDescontoBL	+= listDepAtual[x].valorProduto;
					}
				}

					if(ofertaSelecionada.mobile.planMobile.label == 'MANTER'){				
						this.calculateOriginalValue(component, produtoAtual);
			}

					if(lstOfertas != null && lstOfertas.lstOffers.length > 0){
						for(var index = 0; index < lstOfertas.lstOffers.length; index++){
							if(lstOfertas.lstOffers[index].mobile.planMobile.label == 'MANTER'){
								this.calculateOriginalValueOferta(component, lstOfertas.lstOffers[index]);
							}					
						}
					}
			}

			return ofertaSelecionada;			
				
		},

		
	calculateOriginalValueTodasAsOfertas: function(component, lstOffers, produtoAtual) {
		var originalValue	   = 0;
		var descontoDep		   = 0;
		var descontoTit		   = 0;
		var indexMaior 		   = 0;
		var listDepOffer	   = 0;
		var listDepProduto     = 0;
		
		if(lstOffers){
			for(var x = 0; x<lstOffers.length; x++ ){			
				listDepOffer   = lstOffers[x].mobile.listaDependentesMobile;
				listDepProduto = produtoAtual.mobile.listaDependentesMobile;
				indexMaior = 0;
				descontoDep = 0;
				descontoTit = 0;

				if(lstOffers[x].lstSteps.length > 0){
					for(var i = 0; i<lstOffers[x].lstSteps.length; i++){				
						if(lstOffers[x].lstSteps[i].label != null && parseInt(lstOffers[x].lstSteps[i].label) > indexMaior){
							indexMaior = parseInt(lstOffers[x].lstSteps[i].label);
							originalValue = lstOffers[x].lstSteps[i].value;
							lstOffers[x].totalValueOriginal = originalValue;
							lstOffers[x].difTotal = lstOffers[x].totalValueOriginal - produtoAtual.totalValue;
						}			
					}	
				}

				if(lstOffers[x].mobile.planMobile.label != 'MANTER'){
					if(listDepOffer.length > 0 && listDepOffer != null) {
						for (var index = 0; index < listDepOffer.length; index++) {
							if (listDepOffer[index].checked) {
								if (listDepOffer[index].deducedPrice != null) {
									descontoDep += listDepOffer[index].deducedPrice;
								}
							}
						}
					}
				} else if (listDepProduto.length > 0 && listDepProduto != null) {
					for (var index = 0; index < listDepProduto.length; index++) {
						if (listDepProduto[index].checked) {
							if (listDepProduto[index].deducedPrice != null) {
								descontoDep += listDepProduto[index].deducedPrice;
								descontoTit = produtoAtual.mobile.descontoTitular;
							}
						}
					}
				}

				lstOffers[x].totalValue -= descontoDep;
				//lstOffers[x].totalValue -= descontoTit;

				if(indexMaior == 0){					
					var totalValue = lstOffers[x].totalValue;
					lstOffers[x].totalValueOriginal = totalValue + descontoDep + descontoTit;														
				} else {
					lstOffers[x].totalValueOriginal += descontoDep + descontoTit;																			
				}
					lstOffers[x].difTotal = lstOffers[x].totalValue - produtoAtual.totalValue;
                	lstOffers[x].mobile.difProducts = lstOffers[x].mobile.planMobile.value - produtoAtual.mobile.planMobile.value;

			}
		}

		component.set('v.lstOfertas.lstOffers', lstOffers);

		return lstOffers;
	},

	calculoTeste : function(component, event, produtoAtual){
		var action = component.get('c.calculateDependenteMobile');
		action.setParams({
			"jsonProdutoAtual": JSON.stringify(produtoAtual)
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				component.set('v.produtoAtual', data);
			}
		});
		$A.enqueueAction(action);
			}
		

})