({
	criarListaAparelhos : function(component) {
        try{
            //sessão atual
            let sessao = component.get('v.sessao');
            //tipo de sessão (Local ou Logistica)
            let tipoSessao = sessao.tipoNovo.tipoEntrega == 'Logistica';
            //lista de aparelhos para gerar picklist
            let lstAparelhos = sessao.lstAparelhos;
            if(lstAparelhos){
                //verifica o tipo de sessão, Logistica usa um 'espelho' para trabalhar com o adicionar e remover da picklist
                if(tipoSessao){                  
                    component.set('v.aparelhos', lstAparelhos);
                    component.set('v.aparelhosEspelho', lstAparelhos);
                    component.set('v.afterPreload', true);
                }else{
                    let pickList = [];
                    let pickListColors = [];
                    //percorre os aparelhos e a chave de cada objeto para criar o picklist
                    for(let i = 0; i < lstAparelhos.length; i++){
                        let modelo = '';
                        let chave = '';
                        for(let j in lstAparelhos[i].aparelho){
                            modelo = lstAparelhos[i].aparelho[j];
                            chave = j;
                        }
                        //picklist gerado             
                        pickList.push(this.generatePickList(chave, modelo, lstAparelhos[i].cor, lstAparelhos[i].lstCoresDisponiveis));
                    }
                    component.set('v.aparelhos', pickList);
                }
            }
        }catch(err){
            console.log(err);
        }
	},
    
    onlyNumbers : function(textToFormat) {
        try{
            //verifica se a string está nula ou vazia
            if(textToFormat){
                //REGEX para aceitar apenas números
                let numPattern = /\d+/g;
                let numberText = textToFormat.match(numPattern);
                //caso gere número com vírgulas, remove as vírgulas
                return numberText.toString().replace(/,/g, '');
            }else{
                return '';
            }
        }catch(err){
            console.log(err);
        }
    },
    //verifica se pode habilitar o botão para adicionar o aparelho
    enableBotaoAdicionar: function(component){
        try{
            let aparelhoSelected = component.get("v.aparelhoSelecionado");
            let iccidValue = component.get("v.iccid");
            let imeiValue = component.get("v.imei");
            let imeiMaxLength = component.find("imei").get("v.maxlength");
            let iccidMaxLength = component.find("iccid").get("v.maxlength");
            //verifica se os campos iccid e imei estão vazios
            if(iccidValue && imeiValue && aparelhoSelected != '--'){
                if (iccidValue.length == iccidMaxLength && imeiValue.length == imeiMaxLength) {
                    // Ativa botão incluir
                    component.set('v.desabilitaAdicionar', false);
                }
                else{
                    //desabilita botão incluir
                    component.set('v.desabilitaAdicionar', true);
                }
            }else{
                //desabilita botão incluir
                component.set('v.desabilitaAdicionar', true);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    adicionarAparelho : function(component) {
        try{
            //picklist atual
            let aparelhos = component.get('v.aparelhos');
            //aparelho selecionado
            let aparelhoSelecionado = component.get('v.aparelhoSelecionado');
            console.log('aparelhos: ' + JSON.stringify(aparelhos));
            console.log('aparelhoSelecionado: ' + aparelhoSelecionado);            
            //valores para gerar um novo objeto
            let label = '';
            let value = '';
            let cor = '';
            for(let i = 0; i < aparelhos.length; i++){
                if(aparelhos[i].value == aparelhoSelecionado){
                    label = aparelhos[i].label;
                    value = aparelhos[i].value;
                    cor = aparelhos[i].cor;
                    break;
                }
            }
            //iccid atual
            let iccid = component.get('v.iccid');
            //imei atual
            let imei = component.get('v.imei');
            //aparelho para adicionar a tabela de aparelhos preenchidos
            let aparelho = this.generateAparelho(value, label, iccid, imei, cor);
            //adiciona os aparelhos enriquecidos
            this.addAparelhoItemNovo(component, event, aparelho);
            //remove aparelho da picklist
            this.removeAparelhoPicklist(component, aparelhoSelecionado, aparelhos);
        }catch(err){
            console.log(err);
        }  
    },
    
    addAparelhoItemNovo : function(component, event, aparelho){
        try{
            let sessao = component.get('v.sessao');
            //aparelhos já escolhidos/selecionados
            let aparelhosSelecionados = sessao.tipoNovo.itensTipoNovo;
            //verifica undefined ou null
            if(aparelhosSelecionados){
                aparelhosSelecionados.push(aparelho);
                component.set('v.sessao.tipoNovo.itensTipoNovo', aparelhosSelecionados);
            }else{
                let sessao = component.get('v.sessao');
                //se estiver nulo ou undefined, criar novo atributo e valor
                var itensTipoNovo = [];
                //criação do array para adicionar o aparelho enriquecido
                itensTipoNovo.push(aparelho);
                sessao.tipoNovo.itensTipoNovo = itensTipoNovo;
                component.set('v.sessao', sessao);
            }
            //retirar e atualizar o picklist manualmente quando for logística
            if(sessao.tipoNovo.tipoEntrega == 'Logistica'){
                console.log('remover picklist Logistica: ');
                this.removeAparelhoPicklistLogistica(component, aparelho.chave);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    removeAparelhoPicklistLogistica : function(component, chave){
        try{
            let aparelhosNovos = [];
            let aparelhos = component.get('v.aparelhos');
            console.log('chave: ' + JSON.stringify(chave));
            console.log('aparelhos: ' + JSON.stringify(aparelhos));
            for(let i = 0; i < aparelhos.length; i++){
                for(let j in aparelhos[i].aparelho){
                    if(chave != j){
                        aparelhosNovos.push(aparelhos[i]);
                    }
                }
            }
            console.log('aparelhos novos: ' + JSON.stringify(aparelhosNovos));
            component.set('v.aparelhos', aparelhosNovos);
        }catch(err){
            console.log(err);
        }
    },
    
    removeAparelhoPicklist : function(component, aparelhoSelecionado, aparelhos){
        try{
            //bug fix -> splice não está funcionando bem quando tem apenas 1 item no array.
            if(aparelhos.length <= 1){
                component.set('v.aparelhos', []);
            }else{
                component.set('v.aparelhoSelecionado', aparelhoSelecionado);
                //seleciona apenas os valores de picklist diferentes da chave do aparelho selecionado
                let aparelhosNovo = [];
                for(let i = 0; i < aparelhos.length; i++){
                    if(aparelhos[i].value !== aparelhoSelecionado){
                        aparelhosNovo.push(aparelhos[i]);
                    }
                }
                console.log('aparelhos: ' + JSON.stringify(aparelhos));
                component.set('v.aparelhos', aparelhosNovo);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    removeAparelhoEscolhido : function(component, aparelhoSelecionado) {
        try{
            let aparelhos = component.get('v.sessao.tipoNovo.itensTipoNovo');
            console.log('aparelhos: ' + JSON.stringify(aparelhos));
            //bug fix -> splice não está funcionando bem quando tem apenas 1 item no array.
            if(aparelhos.length <= 1){
                component.set('v.sessao.tipoNovo.itensTipoNovo', []);
            }else{
                let aparelhosNovo = [];
                console.log('aparelho selecionado: ' + JSON.stringify(aparelhoSelecionado));
                //percorre os aparelhos e verifica aonde a chave é diferente e adiciona ao novo array
                for(let i = 0; i < aparelhos.length; i++){
                    if(aparelhos[i].chave != aparelhoSelecionado.chave){
                        aparelhosNovo.push(aparelhos[i]);
                    }
                }
                console.log('aparelhosNovo: ' + JSON.stringify(aparelhosNovo));
                //seta os novos valores de aparelhos selecionados
                component.set('v.sessao.tipoNovo.itensTipoNovo', aparelhosNovo);
            }
            //retorna o valor removido para a picklist
            this.addAparelhoPicklist(component, aparelhoSelecionado);
        }catch(err){
            console.log(err);
        }
    },
    
    addAparelhoPicklist : function(component, aparelhoSelecionado) {
        try{
            //picklist de aparelhos atual
            let aparelhoPickList = component.get('v.aparelhos');
            //tipo de entrega
            let tipoEntrega = component.get('v.sessao.tipoNovo.tipoEntrega') == 'Local';
            //verifica undefined ou null
            console.log('aparelhoPickList: ' + JSON.stringify(aparelhoPickList));
            //console.log('aparelhoSelecionado: ' + JSON.stringify(aparelhoSelecionado));
            if(aparelhoSelecionado){
                //tipo de entrega Local ou Logistica
                if(tipoEntrega){
                    aparelhoPickList.push(this.generatePickList(aparelhoSelecionado.chave, aparelhoSelecionado.modelo, aparelhoSelecionado.cor));
                    component.set('v.aparelhos', aparelhoPickList);
                }else{
                    //cria um valor de picklist específico para o tipo de entrega Logistica
                    let aparelhosEspelho = component.get('v.aparelhosEspelho');
                    //console.log('aparelhosEspelho: ' + JSON.stringify(aparelhosEspelho));
                    let aparelho = undefined;
                    for(let i = 0; i < aparelhosEspelho.length; i++){
                        //console.log('aparelhosEspelho[i].aparelho: ' + JSON.stringify(aparelhosEspelho[i].aparelho));
                        for(let j in aparelhosEspelho[i].aparelho){
                            //console.log('aparelhoSelecionado.chave: ' + JSON.stringify(aparelhoSelecionado.chave));
                            //console.log('chave j: ' +  j);
                            //console.log('aparelhosEspelho[i]: ' + JSON.stringify(aparelhosEspelho[i]));
                            if(aparelhoSelecionado.chave == j){
                                aparelho = aparelhosEspelho[i];
                                break;
                            }
                        }
                    }
                    console.log('aparelho: ' + JSON.stringify(aparelho));
                    aparelhoPickList.push(aparelho);
                    component.set('v.aparelhos', aparelhoPickList);
                }
            }
        }catch(err){
            console.log(err);
        }
    },

    //apagar os valores dos campos e desabilita o botão incluir
    apagarCampos : function(component) {
        component.set('v.iccid', '');
        component.set('v.imei', '');
        component.set('v.aparelhoSelecionado', '--');
        component.set('v.desabilitaAdicionar', true);
    },
    
    generatePickList : function(value, label, cor, coresDisponiveis) {
        let pickListValue = {};
        pickListValue.label = label;
        pickListValue.value = value;
        pickListValue.cor = cor;
        pickListValue.lstCoresDisponiveis = coresDisponiveis;
        return pickListValue;
    },
    
    generateAparelho: function(id, modelo, iccid, imei, cor) {
        let aparelho = {};
        aparelho.chave = id;
        aparelho.cor = cor;
        aparelho.iccid = iccid;
        aparelho.imei = imei;
        aparelho.modelo = modelo;
        aparelho.outraCor = '';
        return aparelho;
    },
    
    generateAparelhoColor: function(id, modelo, cor, outraCor) {
        let aparelho = {};
        aparelho.chave = id;
        aparelho.cor = cor;
        aparelho.iccid = '';
        aparelho.imei = '';
        aparelho.modelo = modelo;
        aparelho.outraCor = outraCor;
        return aparelho;
    },
})