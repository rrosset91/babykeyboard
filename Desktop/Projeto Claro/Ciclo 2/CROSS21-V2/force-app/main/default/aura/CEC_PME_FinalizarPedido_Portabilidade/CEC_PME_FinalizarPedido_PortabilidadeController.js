({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showModal",false);
        //cria picklist e estrutura de aparelhos
        helper.criarListaAparelhos(cmp);
        $A.util.addClass(cmp.find("idDevices"), "slds-hide");
        
        var aparelhos = cmp.get("v.aparelhos");
        
        if(aparelhos.length == 0){
            cmp.set("v.sessao.associacaoPendente", 'Não');
        } else {
            cmp.set("v.sessao.associacaoPendente", 'Sim');
        }
    },
    
    openModal : function(cmp, event, helper) {
        cmp.set("v.showModal",true);
    },
    
    closeModal : function(cmp, event, helper) {
        cmp.set("v.msgModal",'');
        cmp.set("v.showModal",false);
    },
    
    incluirLinhas : function(cmp, event, helper) {
        //Não processar caso não seja digitado nada no input.
        if($A.util.isEmpty(cmp.find("inputLinhas").get("v.value"))){
            return;
        }
        var msgs = '';
        var inputLinhas = cmp.find("inputLinhas").get("v.value"); //Dados digitados no modal.
        //var lstLinhas = inputLinhas.replace(/\r?\n|\r/).split('\r');
        var lstLinhas = inputLinhas.trim().split('\n');
        
        for(let i = 0; i < lstLinhas.length; i++){
            lstLinhas[i] = lstLinhas[i].replace(/\n|\r/g, '');
            //lstLinhas[i] = lstLinhas[i].replace('\n', '');
            //lstLinhas[i] = lstLinhas[i].trim();
            if (isNaN(lstLinhas[i])) {
                msgs += '\n' + 'A linha ' + lstLinhas[i].replace('\r','') + ' é inválida. Insira apenas números.';
                lstLinhas.splice(i, 1);
            }
            else if (lstLinhas[i].length != 11) {
                msgs += '\n' + 'A linha ' + lstLinhas[i].replace('\r','') + ' é inválida. O número deve conter, apenas, 11 digitos.';
                lstLinhas.splice(i, 1);
            }
        }
        if (lstLinhas.length > 0) {
            var linhaOperadora = cmp.get("v.linhasOperadora");
            //Adiciona as linhas já importadas junto com as novas que foram digitadas.
            if (linhaOperadora.length) {
                for(let i = 0; i < lstLinhas.length; i++){
                    let currLine = lstLinhas[i].trim();
                    let contains = false;
                    for (let j=0; j < linhaOperadora.length; j++) {
                        if (linhaOperadora[j].linha.trim() == currLine) {
                            contains = true;
                            break;
                        }
                    }
                    if (contains) {
                        lstLinhas.splice(i, 1);
                    }
                }
            }
        }
        cmp.set("v.msgModal", msgs);
        cmp.set("v.linhas", lstLinhas);
        if (lstLinhas.length > 0) {
            helper.obterOperadora(cmp, helper);
        }
    },
    
    removerLinha : function(cmp, event, helper) {
        helper.removerLinha(cmp, event, helper);
        
    },
    
    removerLinhaAparelho : function(cmp, event, helper) {
        helper.removerLinhaAparelho(cmp, event, helper);
        var linhas = cmp.get("v.linhasOperadora");
        $A.get('e.force:refreshView').fire();
        if(linhas.length > 0){
            $A.util.removeClass(cmp.find("idDevices"), "slds-hide");    
        }
    },
    
    removerTodosAparelhos : function(cmp, event, helper){
    	var itemPort = cmp.get("v.sessao.tipoPortabilidade.itensTipoPortabilidade");
        var count = itemPort.length;
    	for(let i = 0; i < count; i++){
            event.getSource().set("v.tabindex",0);
    		helper.removerLinhaAparelho(cmp, event, helper);
		}
        var linhas = cmp.get("v.linhasOperadora");
        if(linhas.length > 0){
            $A.util.removeClass(cmp.find("idDevices"), "slds-hide");    
        }
	}, 
    addAparelhoEvento: function(cmp, event, helper) {
        try{
			cmp.set("v.assocAuto", event.getParam('associacao'));            
            
            var linha = '';
            var operadora = '';
            var linhas = cmp.get("v.linhasOperadora");
          
            if(linhas.length > 0){
                linha = linhas[0].linha;
                operadora = linhas[0].operadora;
                linhas.splice(0,1);
            }
            
            //console.log(event.getParam('value'));
            var aparelho = helper.generateAparelhoColor(event.getParam('value'), 
                                                        event.getParam('label'), 
                                                        event.getParam('color'), 
                                                        event.getParam('colors'),
                                                       	linha,
                                                       	operadora);
            helper.addAparelhoItemNovo(cmp, event, aparelho);
            cmp.set("v.linhasOperadora",linhas);
            
            var aparelhos = cmp.get("v.aparelhos");
            for(let i = 0; i < aparelhos.length ; i++){
                for(let key in aparelhos[i].aparelho){
                    if(aparelho.chave == key){
                        aparelhos.splice(i,1);
                        break;
                    }    
            	}
            }
            
            if(aparelhos.length == 0 && !cmp.get("v.assocAuto")){
                cmp.set("v.sessao.associacaoPendente", 'Não');
            } else {
                cmp.set("v.sessao.associacaoPendente", 'Sim');
            }
            $A.get('e.force:refreshView').fire();
            console.log(cmp.get("v.sessao.associacaoPendente"));
            
            if(linhas.length == 0){
            	$A.util.addClass(cmp.find("idDevices"), "slds-hide");
        	}
            
            helper.toggleAssoAutoDevices(cmp, event, helper);
        }catch(err){
            console.log(err);
        }
    },
    addDeviceList: function(cmp, event, helper) {
        try {  
            var linha = '';
            var operadora = '';
            var aparelho;
            var linhas = cmp.get("v.linhasOperadora");
            var aparelhos = cmp.get("v.devices");
                                
            for (let i=0; i < event.getParam('label').length; i++) {
                if(linhas.length > 0){
                    linha = linhas[i].linha;                        
                    operadora = linhas[i].operadora;
                }                
                
                aparelho = helper.generateAparelhoColor(event.getParam('value')[i], 
                                                        event.getParam('label')[i], 
                                                        event.getParam('color')[i], 
                                                        event.getParam('colors')[i],
                                                        linha,
                                                        operadora);
                //adiciona o aparelho na tabela de selecionados
                helper.addAparelhoItemNovo(cmp, event, aparelho);
            }
            
            linhas = [];
            aparelhos = [];
            
            cmp.set("v.linhasOperadora",linhas);
            cmp.set("v.aparelhos", aparelhos);
			cmp.set("v.sessao.associacaoPendente", 'Não');
            cmp.get("v.assocAuto", false);  
            
            $A.get('e.force:refreshView').fire();
            
            if(linhas.length == 0){
                $A.util.addClass(cmp.find("idDevices"), "slds-hide");
            }                      
        }
        catch(err){
            console.log(err);
        }
    },    
    changeAssocPendente: function(component) {
        try{
            let qtdAparelhos = component.get('v.aparelhos').length;
            console.log('qtdAparelhos: ' + qtdAparelhos);
            let strAssocPendente = '';
            let idElementoAssociacao = component.get('v.idElementoAssociacao');
            if(qtdAparelhos == 0){
                strAssocPendente = 'Não';
            }else{
                strAssocPendente = 'Sim';
            }
            component.set('v.sessao.associacaoPendente', strAssocPendente);
            //envio para o componente principal a mensagem e qual sessão mudar
            var evt = component.getEvent('AssociacaoPendente');
            evt.setParams({
                'associacaoPendente' : strAssocPendente,
                'elemento' : idElementoAssociacao
            });
            evt.fire();
            console.log('assoc pendente: ' + component.get('v.sessao.associacaoPendente'));
        }catch(err){
            console.log(err);
        }
    },
    
    removerTodasLinhas : function (cmp, event, helper){
        var linhas = cmp.get("v.linhasOperadora");
        var count = linhas.length;
        event.getSource().set("v.tabindex",0);
    	for(let i = 0; i < count; i++){
        	helper.removerLinha(cmp, event, helper);
        }
    }
})