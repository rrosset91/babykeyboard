({
	doInit: function (component, event, helper) {
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var caseId = sURL[sURL.length - 2];
		helper.consultarPerfilRetencao(component, helper);
		helper.isPurple(component, helper);
		helper.consultarOfertas(component, event, helper, caseId);
		helper.getMockTaxas(component);
		component.set('v.controle', '{!$Resource.NBA_Combrate}');
	},
	handleTimeout: function (component, event, helper) {
		var isTimeout = component.get("v.isTimeout");
		if(isTimeout) {
			if(localStorage["TryCount"] <= 1) {
				var sPageURL = ' ' + window.location;
				var sURL = sPageURL.split('/');
				var caseId = sURL[sURL.length - 2];
				helper.consultarOfertas(component, event, helper, caseId);
				component.set("v.isTimeout", false);
			} else {
				component.getEvent("refresh").fire();
			}
		}
	},
	selectTv : function (component, event, helper) {
		var oferta1 = component.get('v.oferta1');
		var oferta2 = component.get('v.oferta2');
		var oferta3 = component.get('v.oferta3');
		var ofertaSelecionada = component.get('v.ofertaSelecionada');
		var tvSelected = component.get('v.selectedTv');
		if (JSON.stringify(oferta1) === JSON.stringify(ofertaSelecionada)) {
			component.set('v.tvSelected1', tvSelected);
		} else if (JSON.stringify(oferta2) === JSON.stringify(ofertaSelecionada)) {
			component.set('v.tvSelected2', tvSelected);
		} else if (JSON.stringify(oferta3) === JSON.stringify(ofertaSelecionada)) {
			component.set('v.tvSelected3', tvSelected);
		}
	},
	/*
    bonusDesconto : function (component, event, helper) {
		//alert('Entrou nesse bloco!');
        //document.getElementById('oferta1').click();
        var itens = [helper.const.PRODUTO_ATUAL, helper.const.OFERTA_1, helper.const.OFERTA_2, helper.const.OFERTA_3, helper.const.OFERTA_4];
        var itemSelecionado = '';
        //## varre as ofertas e posse e ve qual foi selecionado
        for(var i = 0; i < itens.length; i++){
            var aux = document.getElementById(itens[i]);
            if(aux.classList.contains('selected')){
                itemSelecionado = itens[i];
                break;
            }
        }
        document.getElementById(itemSelecionado).click();
    },
    */
	selecionar: function (component, event, helper) {		
		component.find("modalAllOffers").callResetIconAnimation();
		
		var produtoAtual = document.getElementById(helper.const.PRODUTO_ATUAL);
		var oferta1 = document.getElementById(helper.const.OFERTA_1);
		var oferta2 = document.getElementById(helper.const.OFERTA_2);
		var oferta3 = document.getElementById(helper.const.OFERTA_3);
		var ofertas = component.get('v.ofertas');
		if(ofertas.callReason != 'Inadimplente'){
			component.set('v.showAdditionalTv', false);
			component.set('v.showAdditionalBroadband', false);
			component.set('v.showAdditionalPhone', false);
			component.set('v.showAdditionalMobile', false);
			component.set('v.showAdditionalTaxas', false);
			produtoAtual.classList.remove(helper.const.SELECTED);
			oferta1.classList.remove(helper.const.SELECTED);
			oferta2.classList.remove(helper.const.SELECTED);
			oferta3.classList.remove(helper.const.SELECTED);
			component.set('v.' + helper.const.PRODUTO_ATUAL + '.selected', false);
			component.set('v.produtoAntigo.selected', false);
			if(oferta1 != null && ofertas.lstOffers.length >= 1 ){
				component.set('v.' + helper.const.OFERTA_1 + '.selected', false);
			}
			if(oferta2 != null && ofertas.lstOffers.length >= 2 ){
				component.set('v.' + helper.const.OFERTA_2 + '.selected', false);
			}
			if(oferta3 != null && ofertas.lstOffers.length >= 3 ){
				component.set('v.' + helper.const.OFERTA_3 + '.selected', false);
			}
			var ofertaId = event.currentTarget.id;
			var ofertaCmp = document.getElementById(ofertaId);
			if (ofertaId === helper.const.PRODUTO_ATUAL) {
				component.set('v.' + helper.const.PRODUTO_ATUAL + '.selected', true);
				component.set('v.produtoAntigo.selected', true);
				component.set('v.ofertaSelecionada', component.get('v.' + helper.const.PRODUTO_ATUAL));
				component.set('v.selectedTv', component.get('v.' + helper.const.PRODUTO_ATUAL).tv[0]);
				ofertaCmp.classList.add(helper.const.SELECTED);
			} else if (ofertaId === helper.const.OFERTA_1 && ofertas.lstOffers.length >= 1) {
				component.set('v.' + helper.const.OFERTA_1 + '.selected', true);
				component.set('v.ofertaSelecionada', component.get('v.' + helper.const.OFERTA_1));
				component.set('v.selectedTv', component.get('v.tvSelected1'));
				ofertaCmp.classList.add(helper.const.SELECTED);
			} else if (ofertaId === helper.const.OFERTA_2 && ofertas.lstOffers.length >= 2) {
				component.set('v.' + helper.const.OFERTA_2 + '.selected', true);
				component.set('v.ofertaSelecionada', component.get('v.' + helper.const.OFERTA_2));
				component.set('v.selectedTv', component.get('v.tvSelected2'));
				ofertaCmp.classList.add(helper.const.SELECTED);
			} else if (ofertaId === helper.const.OFERTA_3 && ofertas.lstOffers.length >= 3) {
				component.set('v.' + helper.const.OFERTA_3 + '.selected', true);
				component.set('v.ofertaSelecionada', component.get('v.' + helper.const.OFERTA_3));
				component.set('v.selectedTv', component.get('v.tvSelected3'));
				ofertaCmp.classList.add(helper.const.SELECTED);
			}
			var ofertaSelecionada = component.get('v.ofertaSelecionada');
			var ofertaSelecionadaHasTv = ofertaSelecionada.tv[ofertaSelecionada.techSelected].planTv.label;
			var ofertaSelecionadaHasBroadband = ofertaSelecionada.broadband.planBroadband.label;
			var ofertaSelecionadaHasPhone = ofertaSelecionada.phone.planPhone.label;
			var ofertaSelecionadaHasMobile = ofertaSelecionada.mobile.planMobile.label;
			if (ofertaSelecionadaHasTv === 'NÃO POSSUI') {
				component.set('v.showAdditionalTv', true);
			}
			if (ofertaSelecionadaHasBroadband === 'NÃO POSSUI') {
				component.set('v.showAdditionalBroadband', true);
			}
			if (ofertaSelecionadaHasPhone === 'NÃO POSSUI') {
				component.set('v.showAdditionalPhone', true);
			}
			if (ofertaSelecionadaHasMobile === 'NÃO POSSUI') {
				component.set('v.showAdditionalMobile', true);
			}
		}else{
			produtoAtual.classList.add(helper.const.SELECTED);
		}
		helper.desabilitarBotaoTodasOfertasMovelInadimplente(component, event, helper, ofertaSelecionada);
        /*
		//## forca com que toda vez que selecionar uma oferta o campo de bonus e desconto seja reiniciado
		component.set('v.produtoAtual.mobile.descontTitular', 0);
		component.set('v.produtoAtual.mobile.bonusTitular', 0);

		*/

	},
	incluirAdicionaisTV: function (component, event, helper) {
		component.set('v.showAdditionalTv', !component.get('v.showAdditionalTv'));
	},
	closeAdicionalTv: function (component, event, helper) {
		component.set('v.showAdditionalTv', false);
	},
	recalculateOffers: function (component, event, helper) {
		helper.recalculateOffers(component, event, helper);
	},
	recalculateOffersController : function(component, event, helper){
		helper.recalculateCurrentProduct(component, event, helper);
	},
	verificarInadimplencia : function(component, event, helper){
		component.set('v.showSpinner', true );
		helper.checarInadimplencia(component);
	},
	closeModalInadimplencia : function(component, event, helper) {
		helper.desabilitarBotaoTodasOfertasMovelInadimplente(component, event, helper, component.get('v.ofertaSelecionada'));
		component.set('v.exibirModalContratoInadimplente', false);
		component.set('v.showSpinner', false );
	},
	finalizarCaso : function(component, event, helper) {
		helper.encerrarCaso(component, event);
		component.set('v.exibirModalContratoInadimplente', false);
		component.set('v.hasServicoIndisponivelModal', false);
	},
	
	handlePageEvent : function(component, event, helper) {
		if (event.getParam('action') == 'RESET_ORDER') {
			helper.resetOrder(component, event);
		}
	}
})