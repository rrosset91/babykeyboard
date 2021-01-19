({
    obterOperadora : function(component, helper) {
        var action = component.get("c.getOperadora");
        action.setParams({
            'lstLinhas': component.get("v.linhas")
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            component.set("v.msgModalStyle", 'color: black;');
            if (state === "SUCCESS") {
                var tempLinhas = [];
                var mapLinhas = response.getReturnValue();
                // Mapa veio nulo, criamos no lugar uma lista vazia para seguir a função
                if (mapLinhas == null) { 
                    mapLinhas = []; 
                }
                //console.table(mapLinhas);
                
                let pendentes = this.getPendenteValue(component);
                if (pendentes == 0 && !component.get("v.assocAuto")) {
                    component.set("v.msgModal", 'Não é possível inserir mais linhas pois não há mais pendências.');
                    return;
                }
                var qtdLinha = component.get("v.sessao.qtdLinha");
                var qtdAparelho = component.get("v.sessao.tipoPortabilidade.itensTipoPortabilidade").length;
                var qtdApEspelho = component.get("v.aparelhosEspelho");
                let msgs = component.get("v.msgModal");
                if (msgs == 'undefined' || msgs == null) {
                    msgs ='';
                }
                //let msgs = ''; //component.get("v.msgModal");
                
                var cont = 0; // Contagem de itens inseridos na lista temp, provida esta do input TextArea
                
                // Verificando cada item do mapa de linhas e inserindo-os em uma lista temp
                // Neste caso tudo que houver tag [REJECTED] será ignorado por não ser válido
                for(var key in mapLinhas){
                    //if(qtdLinha - qtdAparelho - cont <= 0 ){
                    //    continue;
                    //}
                    let linhaOp = mapLinhas[key];
                    if (linhaOp.includes('[REJECTED]')) {
                        msgs += '\n' + 'A linha  ' + key.replace('\r','') + '  é inválida ou está indisponível';
                    }
                    else if(isNaN(key)){
                            msgs += '\n' + 'Linha ' + key.replace('\r','') + ' inválida. Insira apenas números.\r';
                    }
                    else if (key.length != 11 && key.length != 0) {
                            msgs += '\n' + 'Linha ' + key.replace('\r','') + ' não possuí a quantidade de dígitos correta!\r ';
                    }
                    else if(this.isLinhaDuplicada(component, key)) {
                            msgs += '\n' + 'Linha ' + key.replace('\r','') + ' já existe! Por favor, corrigir e enviar novamente.\r ';
                    }
                    else {
                        tempLinhas.push(this.generateLinhaOperadora(key, linhaOp));  
                        
                        cont++;
                    }
                }
                if (cont == 0 && Object.keys(mapLinhas).length > 0) {
                    component.set("v.msgModal", msgs);
                    return;
                }
                
                if(qtdAparelho == qtdApEspelho.length){
                    console.log('Não é possível importar mais linhas.');
                    return;
                } 
                // Map de linhas é nulo ou não retornou itens:
                if (mapLinhas == null || Object.keys(mapLinhas).length == 0) {
                    // Problema na comunicação com o serviço!
                    msgs = 'Erro ao carregar as linhas, tente novamente em alguns minutos. Se persistir, por favor, abra um chamado.';
                    component.set("v.msgModal", msgs);
                    component.set("v.msgModalStyle", 'color:red;');
                    return; // Retorna o método e impede de continuar o processo
                    
                    let linhasList = component.get("v.linhas");
                    for (var linha in linhasList) {
                        if(qtdLinha - qtdAparelho - cont <= 0 ) {
                            continue;
                        }
                        tempLinhas.push(this.generateLinhaOperadora(linhasList[linha], '--'));
                        cont++;
                    }
                }
                // Lista atual de linhas+operadora:
                var linhasOperadora = component.get("v.linhasOperadora");
                
                // Iterando as linhas que retornaram do serviço e checando se já existem
                // Caso existam, ignorar inserção, caso contrário, inserir enquanto o numero de pendentes for maior que 0
                for (let i=0; i < tempLinhas.length; i++) {
                    let line = tempLinhas[i].linha;
                    let op = tempLinhas[i].operadora;
                    let contains = false;
                    for (let j=0; j < linhasOperadora.length; j++) {
                        if (line == linhasOperadora[j].linha) {
                            contains = true;
                            break;
                        }
                    }
                    if (!contains) {
                        if (pendentes == 0) {
                            msgs += '\n' + 'A linha  ' + line.replace('\n', '') + '  não pode ser inserida pois não há mais pendências.';
                        }
                        else {
                            linhasOperadora.push(this.generateLinhaOperadora(line, op));
                            pendentes--;
                        }
                    }
                }
                
                // Atualiza atributos da tela:
                component.set("v.msgModal", msgs);
                component.set("v.linhasOperadora", linhasOperadora);   
                //$A.util.removeClass(component.find("idDevices"), "slds-hide");
				this.toggleAssoAutoDevices(component, event, helper);
                
            }
        }));
        $A.enqueueAction(action);
    },
    generateLinhaOperadora : function(linha, operadora){
        let lnOperadora = {};
        lnOperadora.linha = linha;
        lnOperadora.operadora = operadora;
        if (operadora != '--') {
            lnOperadora.descricao = operadora + ' - ' + linha;
        }
        else {
            lnOperadora.descricao = linha;
        }
        return lnOperadora;
    },
    
    criarListaAparelhos : function(component) {
        try{
            let sessao = component.get('v.sessao');
            let lstAparelhos = sessao.lstAparelhos;
            console.log('lista de aparelhos port: ' + JSON.stringify(lstAparelhos));
            if(lstAparelhos){
                component.set('v.aparelhos', lstAparelhos);
                component.set('v.aparelhosEspelho', lstAparelhos);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    generatePickList : function(value, label, cor) {
        let pickListValue = {};
        pickListValue.label = label;
        pickListValue.value = value;
        pickListValue.cor = cor;
        return pickListValue;
    },
    
    addAparelhoItemNovo : function(component, event, aparelho) {
        
        try{
            var sessao = component.get('v.sessao');
            var itensPortabilidade = sessao.tipoPortabilidade.itensTipoPortabilidade;
            sessao.tipoPortabilidade.itensTipoPortabilidade.push(aparelho);
            
            component.set('v.sessao', sessao);
        }catch(err){
            console.log(err);
        }
    },
    
    generateAparelhoColor: function(id, modelo, cor, outraCor, linha, operadora) {
        let aparelho = {};
        aparelho.chave = id;
        aparelho.modelo = modelo;
        aparelho.cor = cor;
        aparelho.outraCor = outraCor;
        aparelho.linha = linha;
        aparelho.operadora = operadora;
        
        return aparelho;
    },
    
    validarInputLinha : function(cmp, lstLinhas){
        var retorno = true;
        cmp.set("v.msgModal",'');
        for(let i = 0; i < lstLinhas.length; i++){
            if(isNaN(lstLinhas[i])){
                retorno = false;
                cmp.set("v.msgModal",cmp.get("v.msgModal") + 'Linha ' + lstLinhas[i].replace('\r','') + ' inválida. Insira apenas números.\r');
            }
            if(lstLinhas[i].length != 11 && lstLinhas[i].length != 0){
                retorno = false;
                cmp.set("v.msgModal",cmp.get("v.msgModal") + 'Linha ' + lstLinhas[i].replace('\r','') + ' não possuí a quantidade de dígitos correta!\r ');
            }
            if(this.isLinhaDuplicada(cmp, lstLinhas[i])){
                retorno = false;
                cmp.set("v.msgModal",cmp.get("v.msgModal") + lstLinhas[i].replace('\r','') + ' duplicado! Por favor, corrigir e enviar novamente.\r ');
            }
        }
        return retorno;
    },
    
    isLinhaDuplicada : function(cmp, linha){
        var retorno = false;
        var lnOperadora = cmp.get("v.linhasOperadora");
        
        if($A.util.isEmpty(lnOperadora)){
            console.log('Lista Linha Operadora Vazia');
        } else {
            for(let i = 0; i < lnOperadora.length; i++){
                if(lnOperadora[i].linha == linha){
                    return true;
                }
            }    
        }
        
        var itensPort = cmp.get("v.sessao.tipoPortabilidade.itensTipoPortabilidade");
        if($A.util.isEmpty(itensPort)){
            console.log('Lista Itens Vazia');
        } else {
            for(let i = 0; i < itensPort.length; i++){
                if(itensPort[i].linha == linha){
                    return true;
                }
            }    
        }
        
        return retorno;
    },
    
    removerLinhaAparelho : function(cmp, event, helper) {
        var index = event.getSource().get("v.tabindex");
        var itemPort = cmp.get("v.sessao.tipoPortabilidade.itensTipoPortabilidade");
        
        var linhaOperadora = cmp.get("v.linhasOperadora");
        var linha = helper.generateLinhaOperadora(itemPort[index].linha,itemPort[index].operadora);
        
        linhaOperadora.push(linha);
        cmp.set("v.linhasOperadora",linhaOperadora);
        
        var aparelhos = cmp.get("v.aparelhos");
        var aparelhoEspelho = cmp.get("v.aparelhosEspelho");
        
        var exitFor = false;
        
        for(let i = 0; i < aparelhoEspelho.length ; i++){
            if(exitFor){
                break;
            }
          
            for(var key in aparelhoEspelho[i].aparelho){
                if(itemPort[index].chave == key){
                    aparelhos.push(aparelhoEspelho[i]);
                    exitFor = true;
                     
                    if (this.getAparelhoLabel(aparelhoEspelho[i].aparelho) == 'SimCard Avulso') {
                        cmp.set("v.assocAuto", true);
                    }                    
                    
                    break;
                }    
            }
        }

        for(let i = 0; i < aparelhos.length ; i++){
            if (this.getAparelhoLabel(aparelhos[i].aparelho) != 'SimCard Avulso') {
                cmp.set("v.assocAuto", false);
            } 
        }        
       
        cmp.set("v.aparelhos",aparelhos);
        
        itemPort.splice(index,1);
        cmp.set("v.sessao.tipoPortabilidade.itensTipoPortabilidade", itemPort);
        
    },
    
    removerLinha : function(cmp, event, helper) {
        var index = event.getSource().get("v.tabindex");
        var linhas = cmp.get("v.linhasOperadora");
        linhas.splice(index,1);
        cmp.set("v.linhasOperadora", linhas);
        
        //if(linhas.length == 0){
            //$A.util.addClass(cmp.find("idDevices"), "slds-hide");
            this.toggleAssoAutoDevices(cmp, event, helper);
        //}
    },
    
    getPendenteValue : function(cmp) {
        let portLength = Number(cmp.get('v.sessao.tipoPortabilidade.itensTipoPortabilidade.length'));
        let OpLength = Number(cmp.get('v.linhasOperadora.length'));
        let qtdLinha = Number(cmp.get('v.sessao.qtdLinha'));
        let value = qtdLinha - OpLength - portLength;
        return value;
    },
    getAparelhoLabel : function(aparelho) {
        let aparelhoKey = Object.keys(aparelho)[0];

        // Using 'deviceKey' to return corresponding value from 'aparelho'
        return aparelho[aparelhoKey];
    },
    toggleAssoAutoDevices : function(cmp, event, helper) {
        var assocAuto = cmp.get("v.assocAuto");
        var iAparelhos = cmp.get("v.aparelhos").length;
        var iLinhas = cmp.get("v.linhasOperadora").length;
     
        if (assocAuto) {
            if (iAparelhos != iLinhas) {
                $A.util.addClass(cmp.find("idDevices"), "slds-hide");
            } else if (iAparelhos > 0) {
                $A.util.removeClass(cmp.find("idDevices"), "slds-hide");  
            }
        } else {           
            if (iLinhas > 0) {
                if (iAparelhos > 0) {
                    $A.util.removeClass(cmp.find("idDevices"), "slds-hide");
                }
            } else {
                $A.util.addClass(cmp.find("idDevices"), "slds-hide");
            }
        }
    }    
})