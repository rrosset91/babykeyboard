({
	doInit: function(component, event, helper) {
        //cria picklist e estrutura de aparelhos
        helper.criarListaAparelhos(component); 
	},
    validateFields: function(component, event, helper){
        try{
            //valor do campo
            let value = event.getSource().get('v.value');
            //aura:Id
            let auraId = event.getSource().getLocalId();
            //tamanho máximo do campo
            let maxLength = event.getSource().get('v.maxlength');
            //texto formatado para apenas números
            let formatedNumber = helper.onlyNumbers(value);
            //setar o valor no input
            component.find(auraId).set('v.value', formatedNumber);
            //outra verificação para habilitar o botão de adicionar
            helper.enableBotaoAdicionar(component);
        }
        catch(err){
            console.log(err);
        }
    },
    aparelhoChanged : function(cmp, event, helper) {
        try{
            helper.enableBotaoAdicionar(cmp);
        }
        catch (ex) {
            console.log(ex);
        }
    },
    incluirAparelho: function(component, event, helper) {       
        //adiciona o aparelho na tabela de selecionados e remove da picklist
        helper.adicionarAparelho(component);       
        //apaga os campos iccid, imei e desabilita o botão incluir
        helper.apagarCampos(component);
    },

    removerAparelho: function(component, event, helper) {
        try{
			//seta o índice do iteration
            let index = event.getSource().get('v.value');
            //seta o aparelho escolhido
            let aparelhoSelecionado = component.get('v.sessao.tipoNovo.itensTipoNovo')[index];
            //remove o aparelho da linha na tabela
            helper.removeAparelhoEscolhido(component, aparelhoSelecionado);
        }catch(err){
            console.log(err);
        }
    },
    
    addAparelhoEvento: function(component, event, helper) {
        try{
            //seta os parametros do evento customizado (CEC_PME_AdicionarAparelho)
            var aparelho = helper.generateAparelhoColor(event.getParam('value'), 
                                                        event.getParam('label'), 
                                                        event.getParam('color'), 
                                                        event.getParam('colors'));
            //adiciona o aparelho na tabela de selecionados
            helper.addAparelhoItemNovo(component, event, aparelho);
        }catch(err){
            console.log(err);
        }
    },
    addDeviceList: function(component, event, helper) {
        try{          
            //seta os parametros do evento customizado (CEC_PME_AdicionarLoadCMP)
            var aparelho;
            
            for (let i=0; i < event.getParam('label').length; i++) {
            	aparelho = helper.generateAparelhoColor(event.getParam('value')[i], 
                                                        event.getParam('label')[i], 
                                                        event.getParam('color')[i], 
                                                        event.getParam('colors')[i]);
            	//adiciona o aparelho na tabela de selecionados
            	helper.addAparelhoItemNovo(component, event, aparelho);                
            }
        }catch(err){
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
    }
})