({
    doInit : function(cmp, event, helper) {
        // Função que roda na inicialização do component
        var sessao = cmp.get("v.sessao");

        cmp.set("v.sessao.associacaoPendente", "Sim");
        //cmp.set("v.sessao.associacaoPendente", "Sim");
        // Debug pra testar logistica manualmente
        /*
        var entrega = 'Logística'
        
        sessao.tipoTransferencia.tipoEntrega = entrega;
        cmp.set("v.sessao", sessao);
        console.table(Object.keys(cmp.find("seletorDeCores")));
        */
        var qtdLinha = sessao.qtdLinha;
        cmp.set("v.qtdLinhaInicial", qtdLinha);
        helper.getDeviceList(cmp);
        console.log("%c TIPO ENTREGA: ", "color:#FA0; background-color:#222; font-weight: 600", sessao.tipoTransferencia.tipoEntrega);
        
    },
    changeAssocPendente: function(component) {
        try{
            //let qtdAparelhos = component.get('v.deviceList').length;
            //let qtdAparelhos = component.get("v.totalAddedLines");
            let qtdAparelhos = component.find("seletorDeCores").get("v.deviceOptions");
            qtdAparelhos = qtdAparelhos.length;
            console.log('qtdAparelhos: ' + qtdAparelhos);
            let strAssocPendente = '';
            let idElementoAssociacao = component.get('v.idElementoAssociacao');
            strAssocPendente = qtdAparelhos == 0 ? 'Não' : 'Sim';
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
    closeModalError : function(cmp, event){
        cmp.set("v.showModalError", false);
        cmp.set("v.msgModalError", " ");
        
    },
    aparelhoAdicionado : function(cmp, event, helper) {       
        // Função disparada quando botão Inserir do componente de cores é clicado
        let deviceSelectedKey = cmp.find("seletorDeCores").get("v.deviceSelected");
        if (deviceSelectedKey.key) {
            deviceSelectedKey = deviceSelectedKey.key;
        }      
        if (deviceSelectedKey == "--" || deviceSelectedKey == null) {
            helper.undoAparelhoRemoved(cmp, deviceSelectedKey);
            cmp.find("seletorDeCores").set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            return;
        }
        let aparelho = helper.getAparelhoPorChave(deviceSelectedKey, cmp.get("v.deviceList"));
        cmp.set("v.deviceSelected", aparelho);
        let fieldsValid = helper.verificarCamposLinha(cmp, event);
        if (!fieldsValid) {
            // >> removeAparelhoLogic aqui <<
            helper.undoAparelhoRemoved(cmp, deviceSelectedKey);
            cmp.find("seletorDeCores").set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            return;
        }
        // Não adiciona caso já haja uma linha inserida com o numero atual
        if (helper.bloqueioNumeroDuplicado(cmp.get("v.lineNumber"), cmp.get("v.lineList"), cmp.get("v.donatorList")))
        {
            //alert("Número duplicado. Por favor, corrigir e enviar novamente.");
            //Exibir mensagem na tela, no lugar de um alert!
            let errorMsg = "Número duplicado. Por favor, corrigir e enviar novamente.";
            cmp.set("v.msgModalError", errorMsg);
            cmp.set("v.showModalError", true);
            helper.undoAparelhoRemoved(cmp, deviceSelectedKey);
            cmp.find("seletorDeCores").set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            return;
        }
        // Não adiciona caso já haja um LCCID inserida com o numero atual
        if (helper.bloqueioICCIDDuplicado(cmp.get("v.lineICCID"), cmp.get("v.lineList"), cmp.get("v.donatorList")))
        {
            let errorMsg = "ICCID duplicado. Por favor, corrigir e enviar novamente.";
            cmp.set("v.msgModalError", errorMsg);
            cmp.set("v.showModalError", true);
            helper.undoAparelhoRemoved(cmp, deviceSelectedKey);
            cmp.find("seletorDeCores").set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            return;
        }        
        let tipoEntrega = cmp.get("v.sessao.tipoTransferencia.tipoEntrega");
        let label = null;
        let value = null;
        let color = null;
        let colors = null;
        try {
            if (tipoEntrega != 'Local') {
                label = event.getParam('label'); // Nome|Descricao do aparelho
                value = event.getParam('value'); // Chave de identificação do aparelho
                color = event.getParam('color'); // Cor do aparelho
                colors = event.getParam('colors'); // Cores em ordem de prioridade. Pode ser vazio
                if (colors.length == 0) {
                    colors = "Não" // Nenhuma cor escolhida, logo valor 'Não' no campo 'Cores'
                }
                helper.aparelhoAdicionadoToTable(cmp, event, label, value, color, colors);
                
            }
            else {
                label = event.getParam('label'); // Nome|Descricao do aparelho
                value = event.getParam('value'); // Chave de identificação do aparelho
                color = event.getParam('color'); // Cor do aparelho
                colors = "Não" // Nenhuma cor escolhida, logo valor 'Não' no campo 'Cores'
                helper.aparelhoAdicionadoToTable(cmp, event, label, value, color, colors);
                /*
                helper.aparelhoAdicionadoToTable(cmp, event, 
                                                 aparelho.aparelho[aparelhoKey], 
                                                 aparelhoKey, 
                                                 aparelho.cor, 
                                                 "Não");
				*/
            }
            cmp.find("seletorDeCores").set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            //cmp.set("v.deviceSelected", { label: "--Selecione--", key: "--" });
            //let disableEdit = cmp.get("v.disableEditButton");
            //cmp.set("v.disableEditButton", true);
        } 
        catch (ex) {
            console.log(ex);
        }
        //helper.limpaAparelhosAdicionados();
    },
    deviceSelectChanged : function(cmp, event, helper) {
        let option = event.getSource();
        console.log(option.get("v.value"));
    },
	validateDonatorFields : function(cmp, event, helper) {
        let field = event.getSource();
        let filteredValue = field.get("v.value");
        let fieldName = field.get("v.name");
        if (field == cmp.find("donatorCpf") || field == cmp.find("donatorPhone")) {
            filteredValue = helper.onlyNumbers(filteredValue);
            cmp.set("v."+fieldName+"Raw", filteredValue); // Guarda o valor sem formatação nos atributos RAW
            if (typeof filteredValue === 'undefined') {
                filteredValue = "";
            }
            else {
                let maxlength = field.get('v.maxlength');
                if (!maxlength) { maxlength = 12; } // Previnindo eventuais problemas
                filteredValue.substring(0, maxlength);
            }
            if (field == cmp.find("donatorPhone")) {
                if (filteredValue.length == 11) {
                    let mask = filteredValue.replace(/\D/g, '').match(/(\d{2})(\d{5})(\d{4})/);
                    filteredValue = mask[1] + ' ' + mask[2] + '-' + mask[3];
                }
                /*
                else if (filteredValue.length == 10) {
                    let mask = filteredValue.replace(/\D/g, '').match(/(\d{2})(\d{4})(\d{4})/);
                    filteredValue =  mask[1] + ' ' + mask[2] + '-' + mask[3];
                }
                */
                cmp.set("v.donatorPhone", filteredValue); return;
            }
            field.set("v.value", filteredValue);
        }
        else {
            cmp.set("v."+fieldName+"Raw", filteredValue); // Guarda o valor sem formatação nos atributos RAW
        }
	},
    validateLineFields : function(cmp, event, helper) {
		let field = event.getSource();
        let fieldName = field.get("v.name");
        let filteredValue = field.get("v.value");
        if (	field == cmp.find("lineICCIDLocal") 
         	|| 	field == cmp.find("lineICCIDLogistica")
           	||  field == cmp.find("lineIMEI")	
            //||  field == cmp.find("lineNumberLocal")
            ||  field == cmp.find("lineNumber")	) {
            
            filteredValue = helper.onlyNumbers(filteredValue);
            let maxlength = field.get('v.maxlength');
            if (!maxlength) { maxlength = 12; } // Evitar problemas
            filteredValue.substring(0, maxlength);
            cmp.set("v."+fieldName+"Raw", filteredValue); // Guarda o valor sem formatação nos atributos RAW
            if (typeof filteredValue === 'undefined') {
                filteredValue = "";
            }
            if (fieldName == "lineNumber") {
                if (filteredValue.length == 11) {
                    let mask = filteredValue.replace(/\D/g, '').match(/(\d{2})(\d{5})(\d{4})/);
                    filteredValue = mask[1] + ' ' + mask[2] + '-' + mask[3];
                }
            }
            else {
                let maxlength = field.get('v.maxlength');
                if (!maxlength) { maxlength = 12; } // Evitar problemas
                filteredValue.substring(0, maxlength);
            }
            field.set("v.value", filteredValue);
        }
        
	},
    removeDevice : function(cmp, event, helper) {
		var removeButton = event.getSource();
        var value = []; 
        value.push(removeButton.get("v.value"));
        var lineList = cmp.get("v.lineList");
        helper.removeAparelhoLogic(cmp, value, lineList, false, true);
	},
    removeDonator : function(cmp, event, helper) {
        // Remove doador da tabela final
		var removeButton = event.getSource();
        var value = removeButton.get("v.value");
        var donatorList = cmp.get("v.donatorList");
        var donatorLineList = value.lineList;
        let currentLineList = cmp.get("v.lineList");
        
        helper.removeAparelhoLogic(cmp, donatorLineList, currentLineList, true, true);
        
        for(let i=0; i < donatorList.length; i++) {
            if (donatorList[i] == value) {
                donatorList.splice(i, 1);
                cmp.set("v.totalAddedLines", cmp.get("v.totalAddedLines") + donatorLineList.length);
            	break;
            }
        }
        cmp.set("v.donatorList", donatorList);
        // Atualizar o status da sessao.associacaoAparelhos:
        helper.pendenteChanged(cmp, event);
        $A.get('e.force:refreshView').fire(); 
	},
    editarDoador : function(cmp, event, helper) {
        // Edita doador
        // Ao clicar, os valores da tabela serão retornados aos inputs
        // e a linha da tabela a ser editada será removida
        let table = event.getSource(); // Botão editar da tabela
        let tableContents = table.get("v.value"); // Valor do botão editar (conteudo da tabela)
        let name = tableContents.name;
        let cpf = tableContents.cpf;
        let phone = tableContents.phone;
        let email = tableContents.email;
        let lineList = tableContents.lineList; // Lista de linhas mantidas pelo doador (valores da tabela)
        //let lineListLength = lineList ? lineList.length : 0;
        
        var donatorList = cmp.get("v.donatorList"); // Lista atual de doadores
        
        // Precisa ser executado antes de remover o doador da lista caso contrário não vai encontrar itens na lista
        //helper.pendenteChanged(cmp, event);
        
        
        // Procura na lista de doadores o conteúdo que é igual ao do valor trazido do botão Editar
        for(let i=0; i < donatorList.length; i++) {
            if (donatorList[i] == tableContents) {
                donatorList.splice(i, 1);
                cmp.set("v.totalAddedLines", cmp.get("v.totalAddedLines") + lineList.length);
            	break;
            }
        }
        // Atualizar o status da sessao.associacaoAparelhos:
        $A.get('e.force:refreshView').fire();
        // Setando os valores dos atributos do component
        cmp.set("v.donatorList", donatorList);
        cmp.set("v.donatorName", name);
        cmp.set("v.donatorCpf", cpf);
        cmp.set("v.donatorPhone", phone);
        cmp.set("v.donatorEmail", email);
        cmp.set("v.lineList", lineList);
        
    },
    addDonatorTableButtonClicked : function(cmp, event, helper) {
        // Função disparada ao acionar o botão de Incluir um doador
        let lineList = cmp.get("v.lineList");
        let raw = "Raw";
        let donatorList = cmp.get("v.donatorList");
        let donatorName = cmp.get("v.donatorName");
        let donatorCpf = cmp.get("v.donatorCpf" + raw);
        let donatorPhone = cmp.get("v.donatorPhone" + raw);
        let donatorEmail = cmp.get("v.donatorEmail");
        if (!donatorName || !donatorCpf || !donatorPhone || !donatorEmail) {
            cmp.set("v.msgModalError", "Há campos que estão vazios." + "\n" + 
                    "Por favor, antes de incluir, preencha todos os campos corretamente.");
            cmp.set("v.showModalError", true);
            return;
        }
        
        let valid = helper.verificarCamposDoador(cmp, event);
        
        if (!valid) {
            return;
        }
        // Define o objeto Doador:
        let donator = { 
                        name: 		donatorName,
                        cpf: 		donatorCpf,
                        phone: 		donatorPhone,
                        email: 		donatorEmail,
                        lineList: 	lineList
                      };
        
        // Inclui o objeto Doador na lista de doadores
        donatorList.push(donator);
        
        // Seta os atributos:
        // Limpa a lista de linhas
        cmp.set("v.lineList", []);
        cmp.set("v.donatorList", donatorList);
        
        // Doadores formatados para backend
        let doadoresSessao = [];
        for (let i=0; i < donatorList.length; i++) {
            let doador = donatorList[i];
            let doadorAparelhos = [];
            for (let j=0; j < doador.lineList.length; j++) {
                var linhas = doador.lineList[j];
                doadorAparelhos.push({
                                        chave: 		linhas.Chave,
                                        linha: 		linhas.Linha,
                                        iccid: 		linhas.ICCID,
                                        modelo: 	linhas.Modelo,
                                        imei: 		linhas.IMEI,
                                        cor: 		linhas.Cor,
                                        outraCor: 	linhas.Cores
                                     });
            }
            doadoresSessao.push({nomeDoador: doador.name,
                                 cpf: doador.cpf,
                                 telefone: doador.phone,
                                 email: doador.email,
                                 aparelhoTransferencia: doadorAparelhos
                                })
        }
        
        cmp.set("v.sessao.tipoTransferencia.itemTipoTransferencia", doadoresSessao);
        
        // Atualizar o status da sessao.associacaoAparelhos:
        helper.pendenteChanged(cmp, event);
        // Limpa os campos de doador
        helper.limparValoresDoador(cmp);
        $A.get('e.force:refreshView').fire();
    },
    lineListChanged : function(cmp, event) {
        let donatorList = cmp.get("v.donatorList");
        let unassignedLines = cmp.get("v.qtdLinhaInicial");
        let totalLines = 0;
        if (donatorList && donatorList.length > 0) {
            for (let i=0; i < donatorList.length; i++) {
                totalLines += donatorList[i].lineList.length;
            }
        }
        let lineList = cmp.get("v.lineList");
        
        if (!lineList || lineList.length == 0) {
            cmp.set("v.disableEditButton", false);
        }
        else {
            totalLines += lineList.length;
            cmp.set("v.disableEditButton", true);
        }
        cmp.set("v.totalAddedLines", unassignedLines - totalLines);
    },
    onLineNumberFocus : function(cmp, event) {
        // Limpa formatação dos dados quando o campo ganha foco
        let input = event.getSource();
        let number = input.get("v.value");
        if (number) {
            number = number.replace(" ", "").replace("-", "");
        }
        input.set("v.value", number);
    }
})