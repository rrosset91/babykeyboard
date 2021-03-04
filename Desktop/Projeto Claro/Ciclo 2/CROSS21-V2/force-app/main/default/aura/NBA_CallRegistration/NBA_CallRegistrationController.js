({
	doInit: function (component, event, helper) {
		helper.consultarPerfilHelper(component);
		helper.cdBase(component);
		helper.consultarPerfilRetencaoHelper(component);
		helper.getCaseDetails (component);
		helper.checkHasChangesT (component);
	},

	recalcularTabulacao: function(component, event){
		component.set('v.recalcularTabulacao',true);
		component.set('v.descricao', component.find('Description').get('v.value'));
		component.find('formularioCaso').submit({"CallReason__c": component.find('callReason').get('v.value'), "Subreason__c": component.find('callSubReason').get('v.value')});
	},

	handleChangeLevel1: function(component, event, helper) {
		helper.checkHasChanges(component, event, helper);
		helper.copyLevel(component, event);
	},
	handleChangeLevel2: function(component, event, helper) {
		helper.copyLevel(component, event);
	},

	handleChangeLevel3: function(component, event, helper) {
		helper.copyLevel(component, event);
	}, 


	handleSubmit : function(component, event, helper) {
		component.set('v.showSpinner', true);
    },
    verifyRetained : function(component, event, helper) {
		helper.checkHasChanges(component, event, helper);
	},
    handleSuccess : function(component, event, helper) {
		if(!component.get('v.recalcularTabulacao')){
			let bln1 			= component.find('bln1').get("v.value");
			let bln2 			= component.find('bln2').get("v.value");
			let bln3 			= component.find('bln3').get("v.value");
			let tvn1 			= component.find('tvn1').get("v.value");
			let tvn2 			= component.find('tvn2').get("v.value");
			let tvn3 			= component.find('tvn3').get("v.value");
			let phonen1 		= component.find('phonen1').get("v.value");
			let phonen2 		= component.find('phonen2').get("v.value");
			let phonen3 		= component.find('phonen3').get("v.value");
			let mobilen1 		= component.find('mobilen1').get("v.value");
			let mobilen2 		= component.find('mobilen2').get("v.value");
			let mobilen3 		= component.find('mobilen3').get("v.value");
			let lctn1 			= component.find('lctn1').get("v.value");
			let lctn2 			= component.find('lctn2').get("v.value");
			let lctn3 			= component.find('lctn3').get("v.value");
			let cansend			= false;
			let totalCancelation = component.get('v.totalCancelation');
			let isRetencao 		= component.get('v.isRetencao');
            let isPME 		= component.get('v.isContractPME');
			let caseOrder = component.get('v.caseOrder');
			let caseStatus		= component.get('v.caseStatus');
			if(isRetencao && !isPME && ($A.util.isEmpty(caseOrder.TVMovement__c) || caseOrder.TVMovement__c == 'Nenhum') && (
				$A.util.isEmpty(caseOrder.MobileMovement__c) || caseOrder.MobileMovement__c == 'Nenhum') && 
				($A.util.isEmpty(caseOrder.VirtuaMovement__c) || caseOrder.VirtuaMovement__c == 'Nenhum') && 
				($A.util.isEmpty(caseOrder.NETFoneMovement__c) || caseOrder.NETFoneMovement__c == 'Nenhum') && 
				($A.util.isEmpty(caseOrder.ALaCarteMoviment__c) || caseOrder.ALaCarteMoviment__c == 'Nenhum')){	
			// INICIO VALIDAÇÃO DE TABULAÇÃO PARA TV //
			if(tvn1 == 'RETIDO' && tvn2 == 'SEM MOVIMENTACAO/OFERTA' && tvn3 == 'DEGUSTACAO'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'SEM MOVIMENTACAO/OFERTA' && tvn3 == 'ADICIONAL'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'SEM MOVIMENTACAO/OFERTA' && tvn3 == 'N/A'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'PROMESSA DE PAGAMENTO'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'DECLARAÇÃO DE QUITAÇÃO DE DÉBITOS'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'ACORDO DA DÍVIDA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'VAI LIGAR PARA AGÊNCIA DE COBRANÇA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'EMISSÃO DE 2º VIA FATURA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'CONTESTAÇÃO DE VALORES'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'ALTERAÇÃO DE CADASTRO (VENCIMENTO OU FORMA DE PAGAMENTO)'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'REEMBOLSO'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'DETALHAMENTO DE FATURA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'AGENDAMENTO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'RESOLUÇÃO TÉCNICA (RESOLVEU COM PROCEDIMENTOS DA ÁRVORE)'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'PRIORIZAÇÃO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'MUDANÇA DE ENDEREÇO'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'COM AÇÃO RET' && tvn3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'ARGUMENTAÇÃO' && tvn3 == 'DECISÃO ADIADA (FICOU DE DECIDIR SOBRE CANCELAMENTO)'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'ARGUMENTAÇÃO' && tvn3 == 'NÃO RESPONDE PELO CONTRATO'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'ARGUMENTAÇÃO' && tvn3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(tvn1 == 'RETIDO' && tvn2 == 'ARGUMENTAÇÃO' && tvn3 == 'MULTA DE FIDELIDADE'){
				cansend = true;
			}
			// FIM VALIDAÇÃO DE TABULAÇÃO PARA TV //
			// INICIO VALIDAÇÃO DE TABULAÇÃO PARA BANDA LARGA //
			if(bln1 == 'RETIDO' && bln2 == 'SEM MOVIMENTACAO/OFERTA' && bln3 == 'DEGUSTACAO'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'SEM MOVIMENTACAO/OFERTA' && bln3 == 'ADICIONAL'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'SEM MOVIMENTACAO/OFERTA' && bln2 == 'N/A'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'PROMESSA DE PAGAMENTO'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'DECLARAÇÃO DE QUITAÇÃO DE DÉBITOS'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'ACORDO DA DÍVIDA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'VAI LIGAR PARA AGÊNCIA DE COBRANÇA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'EMISSÃO DE 2º VIA FATURA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'CONTESTAÇÃO DE VALORES'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'ALTERAÇÃO DE CADASTRO (VENCIMENTO OU FORMA DE PAGAMENTO)'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'REEMBOLSO'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'DETALHAMENTO DE FATURA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'AGENDAMENTO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'RESOLUÇÃO TÉCNICA (RESOLVEU COM PROCEDIMENTOS DA ÁRVORE)'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'PRIORIZAÇÃO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'MUDANÇA DE ENDEREÇO'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'COM AÇÃO RET' && bln3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'ARGUMENTAÇÃO' && bln3 == 'DECISÃO ADIADA (FICOU DE DECIDIR SOBRE CANCELAMENTO)'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'ARGUMENTAÇÃO' && bln3 == 'NÃO RESPONDE PELO CONTRATO'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'ARGUMENTAÇÃO' && bln3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(bln1 == 'RETIDO' && bln2 == 'ARGUMENTAÇÃO' && bln3 == 'MULTA DE FIDELIDADE'){
				cansend = true;
			}	
			// FIM VALIDAÇÃO DE TABULAÇÃO PARA BANDA LARGA //
			// INICIO VALIDAÇÃO DE TABULAÇÃO PARA TELEFONE //
			if(phonen1 == 'RETIDO' && phonen2 == 'SEM MOVIMENTACAO/OFERTA' && phonen3 == 'DEGUSTACAO'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'SEM MOVIMENTACAO/OFERTA' && phonen3 == 'ADICIONAL'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'SEM MOVIMENTACAO/OFERTA' && phonen3 == 'N/A'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'PROMESSA DE PAGAMENTO'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'DECLARAÇÃO DE QUITAÇÃO DE DÉBITOS'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'ACORDO DA DÍVIDA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'VAI LIGAR PARA AGÊNCIA DE COBRANÇA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'EMISSÃO DE 2º VIA FATURA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'CONTESTAÇÃO DE VALORES'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'ALTERAÇÃO DE CADASTRO (VENCIMENTO OU FORMA DE PAGAMENTO)'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'REEMBOLSO'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'DETALHAMENTO DE FATURA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'AGENDAMENTO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'RESOLUÇÃO TÉCNICA (RESOLVEU COM PROCEDIMENTOS DA ÁRVORE)'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'PRIORIZAÇÃO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'MUDANÇA DE ENDEREÇO'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'COM AÇÃO RET' && phonen3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'ARGUMENTAÇÃO' && phonen3 == 'DECISÃO ADIADA (FICOU DE DECIDIR SOBRE CANCELAMENTO)'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'ARGUMENTAÇÃO' && phonen3 == 'NÃO RESPONDE PELO CONTRATO'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'ARGUMENTAÇÃO' && phonen3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(phonen1 == 'RETIDO' && phonen2 == 'ARGUMENTAÇÃO' && phonen3 == 'MULTA DE FIDELIDADE'){
				cansend = true;
			}	
			// FIM VALIDAÇÃO DE TABULAÇÃO PARA TELEFONE//
			// INICIO VALIDAÇÃO DE TABULAÇÃO PARA MÓVEL //
			if(mobilen1 == 'RETIDO' && mobilen2 == 'SEM MOVIMENTACAO/OFERTA' && mobilen3 == 'DEGUSTACAO'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'SEM MOVIMENTACAO/OFERTA' && mobilen3 == 'ADICIONAL'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'SEM MOVIMENTACAO/OFERTA' && mobilen3 == 'N/A'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'PROMESSA DE PAGAMENTO'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'DECLARAÇÃO DE QUITAÇÃO DE DÉBITOS'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'ACORDO DA DÍVIDA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'VAI LIGAR PARA AGÊNCIA DE COBRANÇA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'EMISSÃO DE 2º VIA FATURA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'CONTESTAÇÃO DE VALORES'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'ALTERAÇÃO DE CADASTRO (VENCIMENTO OU FORMA DE PAGAMENTO)'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'REEMBOLSO'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'DETALHAMENTO DE FATURA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'AGENDAMENTO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'RESOLUÇÃO TÉCNICA (RESOLVEU COM PROCEDIMENTOS DA ÁRVORE)'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'PRIORIZAÇÃO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'MUDANÇA DE ENDEREÇO'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'COM AÇÃO RET' && mobilen3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'ARGUMENTAÇÃO' && mobilen3 == 'DECISÃO ADIADA (FICOU DE DECIDIR SOBRE CANCELAMENTO)'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'ARGUMENTAÇÃO' && mobilen3 == 'NÃO RESPONDE PELO CONTRATO'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'ARGUMENTAÇÃO' && mobilen3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(mobilen1 == 'RETIDO' && mobilen2 == 'ARGUMENTAÇÃO' && mobilen3 == 'MULTA DE FIDELIDADE'){
				cansend = true;
			}	
			// FIM VALIDAÇÃO DE TABULAÇÃO PARA MÓVEL//
			// INICIO VALIDAÇÃO DE TABULAÇÃO PARA A LA CARTE //
			if(lctn1 == 'RETIDO' && lctn2 == 'SEM MOVIMENTACAO/OFERTA' && lctn3 == 'DEGUSTACAO'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'SEM MOVIMENTACAO/OFERTA' && lctn3 == 'ADICIONAL'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'SEM MOVIMENTACAO/OFERTA' && lctn3 == 'N/A'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'PROMESSA DE PAGAMENTO'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'DECLARAÇÃO DE QUITAÇÃO DE DÉBITOS'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'ACORDO DA DÍVIDA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'VAI LIGAR PARA AGÊNCIA DE COBRANÇA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'EMISSÃO DE 2º VIA FATURA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'CONTESTAÇÃO DE VALORES'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'ALTERAÇÃO DE CADASTRO (VENCIMENTO OU FORMA DE PAGAMENTO)'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'REEMBOLSO'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'DETALHAMENTO DE FATURA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'AGENDAMENTO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'RESOLUÇÃO TÉCNICA (RESOLVEU COM PROCEDIMENTOS DA ÁRVORE)'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'PRIORIZAÇÃO DE VISITA TÉCNICA'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'MUDANÇA DE ENDEREÇO'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'COM AÇÃO RET' && lctn3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'ARGUMENTAÇÃO' && lctn3 == 'DECISÃO ADIADA (FICOU DE DECIDIR SOBRE CANCELAMENTO)'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'ARGUMENTAÇÃO' && lctn3 == 'NÃO RESPONDE PELO CONTRATO'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'ARGUMENTAÇÃO' && lctn3 == 'MUDANÇA DE TITULARIDADE'){
				cansend = true;
			}
			else if(lctn1 == 'RETIDO' && lctn2 == 'ARGUMENTAÇÃO' && lctn3 == 'MULTA DE FIDELIDADE'){
				cansend = true;
			}	
			// FIM VALIDAÇÃO DE TABULAÇÃO PARA A LA CARTE//
				if(cansend && caseStatus != 'Encerrado'){
					helper.dispatchRetained(component, event, helper);
				}
				else{
					helper.toGetOrderIDCase(component, event, helper);
				}
			}else{	//NAO É RETIDO - VOLTAR PARA CONTRATO
				helper.toGetOrderIDCase(component, event, helper);
			}	
		}
		else
			component.find('Description').set('v.value', component.get('v.descricao'));
		component.set('v.recalcularTabulacao',false);
	},	
	handleOrder :function name(component, event, helper) {
		component.set('v.validaRetido', false);
		component.set('v.msgRetido', '');
		helper.toGetOrderIDCase(component, event, helper);
	},
	handleError : function(component, event, helper) {
		if(!component.get('v.recalcularTabulacao')){
			component.set('v.disabled', false);
			component.set('v.showSpinner', false);
		}
		component.set('v.recalcularTabulacao',false);
	}
})