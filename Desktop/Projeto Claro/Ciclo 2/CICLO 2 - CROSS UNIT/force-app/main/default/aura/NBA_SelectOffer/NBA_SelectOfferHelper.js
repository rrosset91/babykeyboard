({
	saveClickSelectOffer: function (component, event){
		let caseId = component.get('v.recordId');
		var action = component.get('c.saveClickAllOffers');	
		action.setParams({
			"recordId" : caseId
		});

		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('Campo Gravado com Sucesso');
            } else if (state === "ERROR") {
				var errors = action.getError();
				if (errors && errors[0] && errors[0].message) 
					helper.toastEvent('Erro!', errors[0].message, 'error');
			}
    
        });
        $A.enqueueAction(action);

	},
	
	
	toastEvent: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

	endCase: function (component, event, helper) {
        component.set('v.showSpinner', true);
        
        var descriptionSchedule = component.get('v.description');
		var myDate = component.get('v.myDate');
		var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2];
        var ofertaSelecionada = component.get('v.ofertaSelecionada');
        var produtoAntigo = component.get('v.produtoAntigo');		
		var produtoAtual = component.get('v.produtoAtual');
        var lstIsencoes = component.get('v.lstIsencoes');
        var subscriberId = component.get('v.subscriberId');	
        var offerValidationRequest = component.get('v.OfferValidationRequest');		
        var action = component.get('c.endCase');
        action.setParams({
            "recordId" : caseId,
            "oferta" : JSON.stringify(ofertaSelecionada),
            "produtoAtual" : JSON.stringify(produtoAtual),
            "descriptionSchedule" : descriptionSchedule,
            "dateSchedule" : myDate,
            "isencoes" : JSON.stringify(lstIsencoes),
			"produtoAntigo" : JSON.stringify(produtoAntigo),
			"subscriberId" : subscriberId,
			"offerValidationRequest" : (offerValidationRequest==''  ? '' : JSON.stringify(offerValidationRequest))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var Exceptions = '';
                var lstOfertas = component.get('v.lstOfertas');
                if(lstOfertas.lenght < 3){
                    Exceptions = 'MENOS QUE 3 OFERTAS';
                }
                this.trocarstage(component, event, Exceptions);                          
            } else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {
						if (errors[0].pageErrors[0].message) {
							helper.toastEvent('Erro!', errors[0].pageErrors[0].message, 'error');
						} else if (errors[0].message) {
							helper.toastEvent('Erro!', errors[0].message, 'error');
						}
					}
				}
			}
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    
    trocarstage : function (component, event, Exceptions){
        
        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 
        
        var action = component.get("c.updateStage");
        action.setParams({
            "recordId" : caseId,
            "Exceptions": Exceptions
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.getEvent("refresh").fire();
                
            }
        });
        $A.enqueueAction(action);
    },

	encerrarCaso: function(component) {
        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 
        
        var action = component.get("c.encerramentoCaso");
        action.setParams({
            "recordId"		: caseId,
			"isRetencao"	: component.get('v.isRetencao')
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               component.getEvent("refresh").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
	varrerProdutos: function(component) {
        
        var oferta = component.get('v.ofertaSelecionada');
        var antigo = component.get('v.produtoAntigo');
		var atual = component.get('v.produtoAtual');
        // var feesExemptions = component.get('v.feesExemptions');
        var productsPenalty = '';
        var productsRenovation = '';
        var productsNoPenalty = '';
        var hasRenovation = {};
		var hasCancelamento = false ;
		var hasPenalty = {};
		var DiscountPenalty = 0;
		// var hasFidelity = {};
		// var exclusive = oferta.exclusive;
		// var fidelity = oferta.broadband.planBroadband.fidelity.hasFidelity || oferta.mobile.planMobile.fidelity.hasFidelity || oferta.phone.planPhone.fidelity.hasFidelity || oferta.tv[oferta.techSelected].planTv.fidelity.hasFidelity;
		// var exclusiveFidelity = oferta.exclusive || fidelity;
        
		if(oferta.movimentBroadband === 'Cancelamento' || oferta.movimentTv === 'Cancelamento' || oferta.movimentPhone === 'Cancelamento' || oferta.movimenteMobile === 'Cancelamento'){
			hasCancelamento = true;
		}

		hasPenalty = { 
			broadband : antigo.broadband.planBroadband.fidelity.hasPenalty,
			tv :  antigo.tv[0].planTv.fidelity.hasPenalty, 
			mobile : antigo.mobile.planMobile.fidelity.hasPenalty,
			phone :  antigo.phone.planPhone.fidelity.hasPenalty
		};
        
        // Verificação de produtos com fidelidade
		if ((!oferta.movimentBroadband || oferta.movimentBroadband === 'Aquisição' || oferta.movimentBroadband === 'Mantido' || oferta.movimentBroadband === 'Lateral' || oferta.movimentBroadband === 'Upgrade' || oferta.movimentBroadband === 'Downgrade') && (oferta.broadband.planBroadband.fidelity.hasFidelity === true)) {
			hasRenovation.broadband = true;
		} else {
			hasRenovation.broadband = false;
		}
    
		if((!oferta.movimentTv || oferta.movimentTv === 'Aquisição' || oferta.movimentTv === 'Mantido' || oferta.movimentTv === 'Lateral' || oferta.movimentTv === 'Upgrade' || oferta.movimentTv === 'Downgrade') && (oferta.tv[oferta.techSelected].planTv.fidelity.hasFidelity === true)){
			hasRenovation.tv = true;
		} else {
			hasRenovation.tv = false;
		}
    
		if((!oferta.movimentPhone || oferta.movimentPhone === 'Aquisição' || oferta.movimentPhone === 'Mantido' || oferta.movimentPhone === 'Lateral' || oferta.movimentPhone === 'Upgrade' || oferta.movimentPhone === 'Downgrade') && (oferta.phone.planPhone.fidelity.hasFidelity === true)) {
			hasRenovation.phone = true;
		} else {
			hasRenovation.phone = false;
		} 

        // Verificação de produtos com multa de cancelamento
		if (oferta.movimentBroadband && oferta.movimentBroadband === 'Cancelamento' && antigo.broadband.planBroadband.fidelity.hasPenalty === true) {
			hasPenalty.broadband = true;
		} else {
			hasPenalty.broadband = false;
		}
    
		if(oferta.movimentTv && oferta.movimentTv === 'Cancelamento' && antigo.tv[0].planTv.fidelity.hasPenalty === true) {
			hasPenalty.tv = true;
		} else {
			hasPenalty.tv = false;
		} 
    
		if(oferta.movimentPhone && oferta.movimentPhone === 'Cancelamento' && antigo.phone.planPhone.fidelity.hasPenalty === true) {
			hasPenalty.phone = true;
		} else {
			hasPenalty.phone = false;
		}

        antigo.showTotalPenalty = antigo.totalPenalty;
		atual.showTotalPenalty = antigo.totalPenalty;
        
        if(!hasPenalty.broadband) {
            antigo.showTotalPenalty -= antigo.broadband.planBroadband.fidelity.penalty;
			 atual.showTotalPenalty -= antigo.broadband.planBroadband.fidelity.penalty;
        }
        
        if(!hasPenalty.tv) {
            antigo.showTotalPenalty -= antigo.tv[0].planTv.fidelity.penalty;
			atual.showTotalPenalty -= antigo.tv[0].planTv.fidelity.penalty;
        }
        
        if(!hasPenalty.phone) {
            antigo.showTotalPenalty -= antigo.phone.planPhone.fidelity.penalty;
			  atual.showTotalPenalty -= antigo.phone.planPhone.fidelity.penalty;
        }
        
        if(!hasPenalty.mobile) {
            antigo.showTotalPenalty -= antigo.mobile.planMobile.fidelity.penalty;
			 atual.showTotalPenalty -= antigo.mobile.planMobile.fidelity.penalty;
        }
        
        //Preencher produtos que tem penalidade na oferta 
        if(hasPenalty.tv && !hasRenovation.tv){
        	productsPenalty += 'TV ';
        }
        if(hasPenalty.broadband && !hasRenovation.broadband){
        	productsPenalty += 'BL ';
        }
        if(hasPenalty.phone && !hasRenovation.phone){
        	productsPenalty += 'FN ';
        }
        //if(hasPenalty.mobile && !hasRenovation.mobile){ products += 'Móvel '; }
        
        productsPenalty = productsPenalty.trim().replace(/ /g, ' + ');
        
        // Preencher produtos que tem renovação
        if(hasRenovation.tv){
        	productsRenovation += 'TV ';
        }
        if(hasRenovation.broadband){
        	productsRenovation += 'BL ';
        }
        if(hasRenovation.phone){
        	productsRenovation += 'FN ';
        }
        
        productsRenovation = productsRenovation.trim().replace(/ /g, ' + ');
        
        // Preencher produtos que não tem penalidade
        if(!hasPenalty.tv){
        	productsNoPenalty += 'TV ';
        }
        if(!hasPenalty.broadband){
        	productsNoPenalty += 'BL ';
        }
        if(!hasPenalty.phone){
        	productsNoPenalty += 'FN ';
        }
        
        productsNoPenalty = productsNoPenalty.trim().replace(/ /g, ' + ');

		// BÔNUS E DESCONTOS
		// for(var i=0; i<oferta.mobile.listDescontoTitular.length; i++)
		// 	if(oferta.mobile.listDescontoTitular[i].check)
		// 		DiscountPenalty += oferta.mobile.listDescontoTitular[i].multa;
		
		for(var i=0; i<oferta.mobile.listaDependentesMobileSelected.length; i++)
			for(var j=0; j<oferta.mobile.listaDependentesMobileSelected[i].listDescontoDependente.length; j++)
				DiscountPenalty += oferta.mobile.listaDependentesMobileSelected[i].listDescontoDependente[j].multa;
        
        component.set('v.hasPenalty', hasPenalty);
		component.set('v.DiscountPenalty', DiscountPenalty);
        component.set('v.hasRenovation', hasRenovation);
        
        component.set('v.hasProductsPenalty', productsPenalty);
        component.set('v.hasProductsRenovation', productsRenovation);
        component.set('v.hasProductsNoPenalty', productsNoPenalty);
		component.set('v.hasCancelamento', hasCancelamento);
        
        component.set('v.produtoAntigo', antigo);
        
    },
    
	consultarContract: function(component) {
        component.set('v.showSpinner', true );
        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 
        
        var action = component.get("c.consultContract2");
        action.setParams({
            "recordId" : caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.formaPagamento', data.data.recordContract.paymentMethod);
                component.set('v.formaEnvio', data.data.recordContract.billDeliveryMethod);
				if(data.data.recordContact.idContact != '' && data.data.recordContact.idRecordTypeCont != ''){
					component.set('v.objCustom', 'Contact');
					component.set('v.recordIdObj', data.data.recordContact.idContact);
					component.set('v.recordTypeIdObj', data.data.recordContact.idRecordTypeCont);
				}else if(data.data.recordAccount.idAccount != '' && data.data.recordAccount.idRecordTypeAcc != ''){
					component.set('v.objCustom', 'Account');
					component.set('v.recordIdObj', data.data.recordAccount.idAccount);
					component.set('v.recordTypeIdObj', data.data.recordAccount.idRecordTypeAcc);
				}

				//component.set('v.recordTypeId', data.RecordType.Id);
                component.set('v.showSpinner', false );
            }
        });
        $A.enqueueAction(action);
    },
	
	OfferValidationHelper : function (component, event){
		component.set('v.OfferValidationScheduling', false);
		component.set('v.OfferValidationMessage', '');
		if(component.get("v.subscriberId")==null) component.set("v.subscriberId", '');
		
        var action = component.get("c.OfferValidation");
        action.setParams({
            "posseParm" : JSON.stringify(component.get('v.produtoAntigo')),
            "ofertaParm" : JSON.stringify(component.get('v.ofertaSelecionada')),
            "subscriberId" : component.get("v.subscriberId"),
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
			var contractAPIFail = "Não será possível prosseguir com a efetivação da oferta. Favor salvar evidência do erro e enviar para análise. Se necessário efetue as alterações nos sistemas legados.";
			var validationAPIFail = "Não foi possível validar a Mudança de Pacote, favor salvar evidência e enviar para análise. Se necessário efetue as alterações nos sistemas legados. (erro de chamada)";
			var technicalError = "Não foi possível validar a Mudança de Pacote, favor salvar evidência e enviar para análise. Se necessário efetue as alterações nos sistemas legados";
			var businessError = "Erro de parametrização entre os produtos, por favor selecionar outra oferta";
            
            if (response.getState() === "SUCCESS"){
				var data = JSON.parse(response.getReturnValue());
				if(data.validationNeeded){
					if(component.get("v.subscriberId")=='')
						component.set('v.OfferValidationMessage', contractAPIFail);
					else{
						if(data.statusCode==200){
							component.set('v.OfferValidationScheduling', data.content.data.scheduling);
							component.set('v.OfferValidationRequest', data.request);
						}
						else if(data.statusCode==400 || data.statusCode==403 || data.statusCode==500)
							component.set('v.OfferValidationMessage', technicalError + ' (erro: '+ data.statusCode.toString() +')');
						else if(data.statusCode==409 || data.statusCode==422)
							component.set('v.OfferValidationMessage', businessError + ' (erro: '+ data.statusCode.toString() +')');
						else
							component.set('v.OfferValidationMessage', validationAPIFail);
					}
				}
				else{
					component.set('v.OfferValidationScheduling', true);
				}
            }
			else{
				component.set('v.OfferValidationMessage', validationAPIFail);
			}
			$A.enqueueAction(component.get('c.incluirModal'));
        });
        $A.enqueueAction(action);
	},

	hasAgendamento : function (component, event){
        
		var ofertaSelecionada = component.get('v.ofertaSelecionada');
		var produtoAntigo = component.get('v.produtoAntigo');
        var Atual = produtoAntigo.tv[0].technology;
		var cityCode = component.get('v.cityCode');
		var idProduto = {
			"idTv":"",
			"idBl":"",
			"idFn":"",
			"idTvPosse":"",
			"idBlPosse":"",
			"idFnPosse":""
		};
        var solicitationType;
		var solicitationTypeTV = ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType;
        var solicitationTypeBroadband = component.get('v.ofertaSelecionada.broadband.solicitationType');
		var solicitationTypeMobile = component.get('v.ofertaSelecionada.mobile.solicitationsType');
		var solicitationTypePhone = component.get('v.ofertaSelecionada.phone.solicitationsType');
        var codePriority;
		var idTv;
		var idBroadband;

		if(!cityCode){
			cityCode = '';
		}
		cityCode = cityCode.length > 0 ? '0'.repeat(5 - cityCode.length) + cityCode : '';
        if(ofertaSelecionada.movimentTv === 'Aquisição' || ofertaSelecionada.movimentBroadband === 'Aquisição' ||
           ofertaSelecionada.movimentPhone === 'Aquisição' || ofertaSelecionada.movimentTv === 'Cancelamento' ||
           ofertaSelecionada.movimentBroadband === 'Cancelamento' || ofertaSelecionada.movimentBroadband === 'Upgrade' ||
           ofertaSelecionada.movimentBroadband === 'Downgrade' || ofertaSelecionada.movimentBroadband === 'Lateral'){
            component.set('v.isAgendamento', true);
        }else{
			component.set('v.isAgendamento', true);
			solicitationTypeTV = '4|RETIRAR PONTO';
			//VerificaÃ§Ã£o das prioridades do solicitationType - Alexandre
			codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
			solicitationType = codePriority;
		}
        
        if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === 'HD' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === 'HD Max' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === 'HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD Max' && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD Max' && ofertaSelecionada.tv[ofertaSelecionada.techSelected].technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }
        
        component.set('v.showSpinner', true );
        component.set('v.ShowModal', false );

		//Validação para cenário de cancelamento de BL - Kleverton Fortunato
		if((solicitationTypeBroadband == undefined || solicitationTypeBroadband == '' || solicitationTypeBroadband == null) && ofertaSelecionada.movimentBroadband === 'Cancelamento'){
			solicitationTypeBroadband = '899|DESCONEXAO OPCAO C/ RETIRADA DE EQUIPAMENTO';
			idTv = component.get('v.produtoAntigo.tv.planTv.key');
			idBroadband = component.get('v.produtoAntigo.broadband.planBroadband.key');
			codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
			solicitationType = codePriority;
		}else{
			idTv = component.get('v.ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.key');
			idBroadband = component.get('v.ofertaSelecionada.broadband.planBroadband.key');
		}   

		if(ofertaSelecionada.movimentTv === 'Lateral' && ofertaSelecionada.movimentBroadband === 'Cancelamento' && ofertaSelecionada.movimentPhone === 'Cancelamento' || 
           (ofertaSelecionada.movimentTv === 'Lateral' || ofertaSelecionada.movimentTv === 'Upgrade' || ofertaSelecionada.movimentTv === 'Downgrade' || ofertaSelecionada.movimentTv === 'Cancelamento') && ofertaSelecionada.movimentBroadband === 'Cancelamento' && (ofertaSelecionada.movimentPhone === 'Upgrade' || ofertaSelecionada.movimentPhone === 'Downgrade'  || ofertaSelecionada.movimentPhone === 'Lateral')){
            solicitationTypeTV = '4|RETIRAR PONTO';
            //Verificação das prioridades do solicitationType - Alexandre
            codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
            solicitationType = codePriority;
		}else if((solicitationTypePhone == undefined || solicitationTypePhone == '' || solicitationTypePhone == null) && ofertaSelecionada.movimentPhone === 'Cancelamento'){
            solicitationTypePhone = '924|DESCONEXAO POR OPCAO EBT';
            //Verificação das prioridades do solicitationType - Alexandre
            codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
            solicitationType = codePriority;
		}	

		//Validacao de A la Carte
		/*var listAddPosseAtual = produtoAntigo.tv[0].addOptions.lstAdditionals;
		var listAddOfertas = ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstAdditionals;

		for(var i = 0; i < listAddOfertas.length; i++){
			var itensChecadosPosse = false;
			for(var j = 0; j < listAddPosseAtual.length; j++){
				if(listAddOfertas[i].label === listAddPosseAtual[j].label){
					itensChecadosPosse = true;
					break;
				}
			}//Aquisicao de A La Carte
			if(listAddOfertas[i].checked && !itensChecadosPosse){
				solicitationTypeTV = '26|CONTRATACAO DE CANAL A LA CARTE';
				//Verificação das prioridades do solicitationType - Alexandre
				var codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
				solicitationType = codePriority;
			}else if(!listAddOfertas[i].checked && itensChecadosPosse){
				solicitationTypeTV = '27|CANCELAMENTO DE CANAL A LA CARTE';
				//Verificação das prioridades do solicitationType - Alexandre
				var codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
				solicitationType = codePriority;
			}		
		}*/
			
		//Validacao de Ponto Opcional
		var listPOPosseAtual = produtoAntigo.tv[0].addOptions.lstOptionalPointsRPA;
		var listPOOfertas = ofertaSelecionada.tv[ofertaSelecionada.techSelected].addOptions.lstOptionalPointsRPA;
		var tamPAList = listPOPosseAtual.length;
		var tamOfertaList = listPOOfertas.length - 1;
		
		if(tamPAList > tamOfertaList){
			solicitationTypeTV = '4|RETIRAR PONTO';
			//VerificaÃ§Ã£o das prioridades do solicitationType - Alexandre
			codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
			solicitationType = codePriority;
		}else if (tamPAList < tamOfertaList){
			solicitationTypeTV = '3|ADESAO - INSTALAR PONTO ADICIONAL';
			//VerificaÃ§Ã£o das prioridades do solicitationType - Alexandre
			codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
			solicitationType = codePriority;
		}

		/*for(var i = 0; i < listPOOfertas.length; i++){
			var itensChecadosPosse = false;
			for(var j = 0; j < listPOPosseAtual.length; j++){
				if(listPOOfertas[i].nameLegacy === listPOPosseAtual[j].label){
					itensChecadosPosse = true;
					break;
				}
			}//Aquisicao de Ponto Opcional
			if(listPOOfertas[i].checked && !itensChecadosPosse){
				solicitationTypeTV = '3|ADESAO - INSTALAR PONTO ADICIONAL';
				//Verificação das prioridades do solicitationType - Alexandre
				var codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
				solicitationType = codePriority;
			}else if(!listPOOfertas[i].checked && itensChecadosPosse){
				solicitationTypeTV = '24|MUDANCA DE PACOTE';
				//Verificação das prioridades do solicitationType - Alexandre
				var codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
				solicitationType = codePriority;
			}		
		}*/

		//Verificação das prioridades do solicitationType - Alexandre
		codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone);
		solicitationType = codePriority;

        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 

		if (idTv != '' && idTv != undefined) {
          //  idProduto	= idTv;
		} else if (idBroadband != '') {
          //  idProduto = idBroadband;
        }

		var ofertaEscolhida = component.get('v.ofertaSelecionada');
        var posse = component.get('v.produtoAntigo');

		idProduto.idTv = ofertaEscolhida.tv[ofertaEscolhida.techSelected].planTv.key;
		idProduto.idBl = ofertaEscolhida.broadband.planBroadband.key;
		idProduto.idFn = ofertaEscolhida.phone.planPhone.key;
		idProduto.idTvPosse = posse.tv[posse.techSelected].planTv.key;
		idProduto.idBlPosse = posse.broadband.planBroadband.key;
		idProduto.idFnPosse = posse.phone.planPhone.key;

	//	if(ofertaEscolhida.tv[0].planTv.label == posse.tv[0].planTv.label &&
	//	   ofertaEscolhida.broadband.planBroadband.label == posse.broadband.planBroadband.label &&
	//	   ofertaEscolhida.phone.planPhone.label == posse.phone.planPhone.label &&
	//	   ofertaEscolhida.mobile.planMobile.label == posse.mobile.planMobile.label ){
	//		component.set('v.ofertaSelecionada.movimentTv', 'Cancelamento');
	//	}
        
        if(idProduto && solicitationType && component.get('v.isAgendamento')){        
            var action = component.get("c.consultarAgendamento");
            action.setParams({
                "recordId" : caseId,
                "ofertaId" : JSON.stringify(idProduto),
                "solicitationType" : solicitationType,
				"cityCode" : cityCode,
				"codePriority" : codePriority,
				"ofertaSelecionada" : JSON.stringify(component.get('v.ofertaSelecionada')),
				"produtoAntigo" : JSON.stringify(component.get('v.produtoAntigo'))
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if(data.data.schedule.length === 0 || data.data.schedule === null){
                        component.set('v.hasDates', false );
						component.set('v.listEmpty', true );
						component.set('v.semDatasAgendamento', true);
						//component.set('v.isAgendamento', false);
                        this.toastEvent('Lista de datas vazia', 'Não existe agendamento disponivel.', 'error');
                    }
                    var maxDate ;
                    var minDate ;
					if (data.data.schedule != null) {
                        for(var i =0; i < data.data.schedule.length ; i++){
                            minDate = minDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
                            maxDate = maxDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
                            if(data.data.schedule[i].dateSchedule > maxDate){
                                maxDate = data.data.schedule[i].dateSchedule;
                            }
                            if(data.data.schedule[i].dateSchedule < minDate ){
                                minDate = data.data.schedule[i].dateSchedule;
                            }
                        }
                        component.set('v.dateMin', minDate);
                        component.set('v.dateMax', maxDate);
                        component.set('v.schedule', data);

						this.getRemainingDays(component, event);
                    }   
                }
                if(state === "ERROR"){
                    component.set('v.isAgendamento', false );
					//this.toastEvent('Erro!', $A.get('{$Label.c.ERRO_AGENDAMENTO}'), 'error');
					this.toastEvent('Erro!', $A.get("$Label.c.ERRO_AGENDAMENTO"), 'error');
					/*var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.toastEvent('Erro de consulta', errors[0].message, 'error');
                        }
                    }*/	
					this.getRemainingDays(component, event);
                }
				component.set('v.showSpinner', false);
				component.set('v.ShowModal', true);

            });
            $A.enqueueAction(action);
        } else {
			component.set('v.showSpinner', false);
			component.set('v.ShowModal', true);
		}
    },

	getPriorityCodeSolicitation : function(component, tv, bl, mv, fn){
	
		var listCode = [];
		if (tv != undefined && tv.includes("|")){
			var codeTV = tv.split('|');
			listCode.push(codeTV[0]);
		}
		if (bl != undefined && bl.includes("|")){
			var codeBL = bl.split('|');
			listCode.push(codeBL[0]);
		}
		if (fn != undefined && fn.includes("|")){
			var codeFN = fn.split('|');
			listCode.push(codeFN[0]);
		}
		if (mv != undefined && mv.includes("|")){
			var codeMV = mv.split('|');
			listCode.push(codeMV[0]);
		}

		var codePriority = '';
	
		for(var x = 0; x < listCode.length; x++ ){
			if(listCode[x] === '2' || listCode[x] === '3'|| listCode[x] === '4'|| listCode[x] === '48'|| listCode[x] === '899'){ // Muito Alta
				codePriority = listCode[x];
				break;
			}else if(listCode[x] === '24'|| listCode[x] === '923'|| listCode[x] === '924'){  //  Alta
			codePriority = listCode[x];
			}else if(listCode[x] === '26'|| listCode[x] === '27'){ // nao tem 
			codePriority = listCode[x];
			}else{
			codePriority = listCode[x];
			}
		}

		return codePriority;


	},

	getRemainingDays: function(component) {

		var remainingDaysTV = component.get('v.produtoAntigo.tv[0].planTv.fidelity.remainingDays');
		var remainingDaysBL = component.get('v.produtoAntigo.broadband.planBroadband.fidelity.remainingDays');
		var remainingDaysFone = component.get('v.produtoAntigo.phone.planPhone.fidelity.remainingDays');
		var remainingDaysMovel = component.get('v.produtoAntigo.mobile.planMobile.fidelity.remainingDays');
		//var remainingDate = Date.today().add(365);
		var result = new Date();
		result.setDate(result.getDate() + 365);
		var today = $A.localizationService.formatDate(result, "dd/MM/yyyy");
		component.set('v.today', today);

		var remainingDaysList = [];
		var hasPenalty = component.get('v.hasPenalty');
		if(hasPenalty.tv)
			remainingDaysList.push(remainingDaysTV);
		if(hasPenalty.broadband)
			remainingDaysList.push(remainingDaysBL);
		if(hasPenalty.phone)
			remainingDaysList.push(remainingDaysFone);
		if(hasPenalty.mobile)
			remainingDaysList.push(remainingDaysMovel);
		
		var order = remainingDaysList.sort(function(a, b) {
			return b - a;
		});
	    component.set('v.remainingDays', order[0]);

	},

	hasGestorCredito : function (component, event, helper, hasAgendamento, dataAgendamento, periodoAgendamento, periodo, semDatas){
		var sPageURL			= ' ' + window.location;
        var sURL				= sPageURL.split('/');
        var caseId				= sURL[sURL.length - 2];
		var ofertaSelecionada	= component.get('v.ofertaSelecionada');
		
		var action				= component.get("c.gestorCredito");
		action.setParams({
			"recordId"			: caseId,
			"ofertaSelecionada" : JSON.stringify(ofertaSelecionada)
		});

		action.setCallback(this, function(response){
			var state			= response.getState();
			if (state === "SUCCESS") {
				var data		= response.getReturnValue();
				var dataResult	= JSON.parse(data);

				if(!dataResult.analiseError){
					if(dataResult.creditSituation.status != "APROVADO"){
						component.set('v.ShowModal', false);
						component.set('v.isAnaliseCreditoModalOpen', true);
					}else if(dataResult.creditSituation.status == "APROVADO") {
						component.set('v.showSpinner', false );
						component.set('v.hasAnalise', true);

							var hasAgendamento			= component.get('v.isAgendamento');
							var dataAgendamento			= component.get('v.myDate') !== null ? true : false ;
							var periodoAgendamento		= component.get('v.description') !== 'false' ? true : false ; 
							var periodo					= component.get('v.periodoChecked') ? true : false ; 		
							var semDatas				= component.get('v.semDatasAgendamento');

						if(semDatas){
							dataAgendamento = true;
							periodoAgendamento = true;
							periodo = true;
						}
						if(hasAgendamento && dataAgendamento && periodo){
							this.endCase(component, event, helper);
							component.set('v.confirmed', true);
							component.set('v.ShowModal', false);
							return null;
						}else if(hasAgendamento === false ){
							this.endCase(component, event, helper);
							component.set('v.confirmed', true);
							component.set('v.ShowModal', false);
							return null;
						}else if(!periodo){
							this.toastEvent('Agendamento não solicitado', 'Adicione uma data para agendamento.', 'error');
						}

					}   
				}else {
					component.set('v.ShowModal', false);
					component.set('v.isAnaliseCreditoModalOpen', false);
					component.set('v.hasAnaliseError', true);
				}
			}
		});
		$A.enqueueAction(action);
	}

    /*hasAgendamento : function (component, event){
        
        var ofertaSelecionada = component.get('v.ofertaSelecionada');
        var Atual = component.get('v.produtoAntigo.tv.technology');
		var cityCode = component.get('v.cityCode');
		if(!cityCode){
			cityCode = '';
		}
		cityCode = cityCode.length > 0 ? '0'.repeat(5 - cityCode.length) + cityCode : '';
        if(ofertaSelecionada.movimentTv === 'Aquisição' || ofertaSelecionada.movimentBroadband === 'Aquisição' ||
           ofertaSelecionada.movimentPhone === 'Aquisição' || ofertaSelecionada.movimentTv === 'Cancelamento' ||
           ofertaSelecionada.movimentBroadband === 'Cancelamento' || ofertaSelecionada.movimentBroadband === 'Upgrade' ||
           ofertaSelecionada.movimentBroadband === 'Downgrade' || ofertaSelecionada.movimentBroadband === 'Lateral'){
            component.set('v.isAgendamento', true);
        }
        
        if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv.technology === 'HD' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv.technology === 'HD Max' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv.technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if((Atual === 'SD' || Atual === 'DIGITAL') && ofertaSelecionada.tv.technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv.technology === 'HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv.technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD' && ofertaSelecionada.tv.technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD Max' && ofertaSelecionada.tv.technology === '4k' ){
            component.set('v.isAgendamento', true);
        }else if(Atual === 'HD Max' && ofertaSelecionada.tv.technology === '4k HD Max' ){
            component.set('v.isAgendamento', true);
        }
        
        component.set('v.showSpinner', true );
        component.set('v.ShowModal', false );
        
        var solicitationTypeTV = component.get('v.ofertaSelecionada.tv.solicitationType');
        var solicitationTypeBroadband = component.get('v.ofertaSelecionada.broadband.solicitationType');
        var idTv = component.get('v.ofertaSelecionada.tv.planTv.key');
        var idBroadband = component.get('v.ofertaSelecionada.broadband.planBroadband.key');
		/*var solicitationTypeTV = ofertaSelecionada.tv[ofertaSelecionada.techSelected].solicitationType;
        var solicitationTypeBroadband = component.get('v.ofertaSelecionada.broadband.solicitationType');
        var solicitationTypeMobile = component.get('v.ofertaSelecionada.mobile.solicitationsType');
		var solicitationTypePhone = component.get('v.ofertaSelecionada.phone.solicitationsType');
		var idTv = component.get('v.ofertaSelecionada.tv.planTv.key');
        var idBroadband = component.get('v.ofertaSelecionada.broadband.planBroadband.key');
		
		var codePriority = this.getPriorityCodeSolicitation(component,solicitationTypeTV,solicitationTypeBroadband,solicitationTypeMobile,solicitationTypePhone );
        
        var idProduto ;
        var solicitationType ;
        
        if(idTv !== '' ){
            idProduto	= idTv;
        }else if(idBroadband !== ''){
            idProduto = idBroadband;
        }
        
		//AJUSTE REALIZADO PARA ENVIAR UM SOLICITATION TYPE VALIDO - Kleverton - 24/07/2019
        /*if(solicitationTypeTV !== ''){
            solicitationType = solicitationTypeTV;
        }else if(solicitationTypeBroadband !== '' ){
            solicitationType = solicitationTypeBroadband;
        }

		if(solicitationTypeTV !== '' || solicitationTypeTV !== undefined || solicitationTypeTV !== null){
            solicitationType = solicitationTypeTV;
			if(solicitationType == '' || solicitationTypeTV == undefined || solicitationTypeTV == null){
				if(solicitationTypeBroadband !== '' || solicitationTypeBroadband !== undefined || solicitationTypeBroadband !== null){
					solicitationType = solicitationTypeBroadband;
				}
			}
        }
        
        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 
        
        if(idProduto && solicitationType && component.get('v.isAgendamento')){        
            var action = component.get("c.consultarAgendamento");
            action.setParams({
                "recordId" : caseId,
                "ofertaId" : idProduto,
                "solicitationType" : solicitationType,
				"cityCode" : cityCode,
				"codigoDoAgendamento" : codigoAgendamento //Alexandre Amaro correção agendamento
                
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if(data.data.schedule.length === 0 || data.data.schedule === null){
                        component.set('v.hasDates', false );
						component.set('v.listEmpty', true );
                        this.toastEvent('Lista de datas vazia', 'Não existe agendamento disponivel.', 'error');
                    }
                    var maxDate ;
                    var minDate ;
                    if(data.data.schedule !== null){
                        for(var i =0; i < data.data.schedule.length ; i++){
                            minDate = minDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
                            maxDate = maxDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
                            if(data.data.schedule[i].dateSchedule > maxDate){
                                maxDate = data.data.schedule[i].dateSchedule;
                            }
                            if(data.data.schedule[i].dateSchedule < minDate ){
                                minDate = data.data.schedule[i].dateSchedule;
                            }
                        }
                        component.set('v.dateMin', minDate);
                        component.set('v.dateMax', maxDate);
                        component.set('v.schedule', data);
                    }   
                }
                if(state === "ERROR"){
                    component.set('v.isAgendamento', false );
					//this.triggerToast($A.get('{$Label.c.ERRO_INTEGRACAO}'), 'error', 'dismissible');
					this.toastEvent('Erro!', $A.get("$Label.c.ERRO_AGENDAMENTO"), 'error');
                    //var errors = action.getError();
                    //if (errors) {
                      //  if (errors[0] && errors[0].message) {
                        //    this.toastEvent('Erro de consulta', errors[0].message, 'error');
                        //}
                    //}	
                }
                component.set('v.showSpinner', false);
        		component.set('v.ShowModal', true);
            });
            $A.enqueueAction(action);
        } else {
         	component.set('v.showSpinner', false);
        	component.set('v.ShowModal', true);   
        }
    },
	/*getPriorityCodeSolicitation : function(component, tv, bl, mv, fn){
	
		var listCode = [];
		if(tv){
			var codeTV = tv.split('|');
			listCode.push(codeTV[0]);
		}
		if(bl){
			var codeBL = bl.split('|');
			listCode.push(codeBL[0]);
		}
		if(fn){
			var codeFN = fn.split('|');
			listCode.push(codeFN[0]);
		}
		if(mv){
			var codeMV = mv.split('|');
			listCode.push(codeMV[0]);
		}

		var codePriority = '';
	
		for(var x = 0; x < listCode.length; x++ ){
			if(listCode[x] === '2' || listCode[x] === '3'|| listCode[x] === '4'|| listCode[x] === '48'|| listCode[x] === '899'){ // Muito Alta
				codePriority = listCode[x];
				break;
			}else if(listCode[x] === '24'|| listCode[x] === '923'|| listCode[x] === '924'){  //  Alta
			codePriority = listCode[x];
			}else if(listCode[x] === '26'|| listCode[x] === '27'){ // nao tem 
			codePriority = listCode[x];
			}else{
			codePriority = listCode[x];
			}
		}

		return codePriority;


	},*/
})