({
    getDeviceList : function(cmp) {
        // Forma uma lista de aparelhos própria para o lightning:Select
        try {
            var devices = cmp.get("v.sessao").lstAparelhos;          
            var deviceOptions = [];
            for (let i=0; i < devices.length; i++) {
                deviceOptions.push(this.getAparelhoKeys(devices[i].aparelho));               
            }
            cmp.set("v.deviceOptions", deviceOptions);
            cmp.set("v.deviceList", devices);
        } catch(ex) {
            console.log(ex);
        }
    },
    pendenteChanged : function(cmp, event) {
        return;
        console.log("%c Triggered Pendente Changed", "background-color:#FFF;");
        let donatorList = cmp.get("v.donatorList");
        let lineCount = 0;
        for (let i=0; i < donatorList.length; i++) {
            lineCount += donatorList[i].lineList.length;
        }
        let sessao = cmp.get("v.sessao");
        
        let associacaoText = lineCount == sessao.lstAparelhos.length ? "Não" : "Sim";
        
        //let associacaoText = cmp.get("v.totalAddedLines") == 0 ? "Não" : "Sim";
        cmp.set("v.sessao.associacaoPendente", associacaoText);
    },
    bloqueioNumeroDuplicado : function(numero, listaNum, listaDoador) {
        // Verifica se o numero está duplicado no grupo
        if (listaDoador) {
            for (let i=0; i < listaDoador.length; i++) {
                listaNum = listaNum.concat(listaDoador[i].lineList);
            }
        }
        for (let i=0; i < listaNum.length; i++) {
            if (numero == listaNum[i].Linha) {
                return true;
            }
        }
        return false;
    },
	bloqueioICCIDDuplicado : function(numero, listaNum, listaDoador) {              
        // Verifica se o LCCID está duplicado no grupo
        if (listaDoador) {
            for (let i=0; i < listaDoador.length; i++) {
                listaNum = listaNum.concat(listaDoador[i].lineList);
            }
        }
        for (let i=0; i < listaNum.length; i++) {
            if (numero == listaNum[i].ICCID) {
                return true;
            }
        }
        return false;
    },    
    verificarCpf : function(rawValue) {
        let filteredValue = rawValue;
        if (filteredValue.length == 11) {
            // Regex de repetição de números (999... | 888... etc) :
            if (/\b(\d)\1+\b/.test(filteredValue)) { 
                return false; 
            }
            let firstVerifyNumbers = filteredValue.substring(0, 9).split('');
            let firstVerified = 0;
            let secondVerifyNumbers = filteredValue.substring(0, 10).split('');
            let secondVerified = 0;
            
            // Calculo para verificação do primeiro digito
            for (let i=0,j=10; i < firstVerifyNumbers.length; i++,j--) {
                firstVerified += (firstVerifyNumbers[i] * j);
            }
            // Calculo para verificação do segundo digito
            for (let i=0,j=11; i < secondVerifyNumbers.length; i++,j--) {
                secondVerified += (secondVerifyNumbers[i] * j);
            }
            
            let firstMod = (firstVerified * 10) % 11; // Resultado do primeiro digito verificador
            firstMod = firstMod == 10 ? 0 : firstMod;
            let secondMod = (secondVerified * 10) % 11; // Resultado do segundo digito verificador
            secondMod = secondMod == 10 ? 0 : secondMod;
            // Se os dois resultados forem iguais aos dois ultimos digitos do Cpf digitado
            return (firstMod == filteredValue[9]) && (secondMod == filteredValue[10]);
        }
        return false;
    },
    verificarCamposLinha : function(cmp, event) {
        let tipoEntrega = cmp.get("v.sessao.tipoTransferencia.tipoEntrega");
        let lineNumber = cmp.get("v.lineNumberRaw"); // Numero da linha
        let lineICCID = cmp.get("v.lineICCID"); // ICCID
        let lineIMEI = cmp.get("v.lineIMEI"); // IMEI
        let deviceSelected = cmp.get("v.deviceSelected");
        let lineNumberMax = cmp.get("v.lineNumberMax");
        let lineICCIDMax = cmp.get("v.lineICCIDMax");
        let lineIMEIMax = cmp.get("v.lineIMEIMax");
        let valido = true;
        
        if (!lineNumber || lineNumber.length != lineNumberMax || !lineICCID || lineICCID.length != lineICCIDMax) {
            valido = false; 
            return valido;
        }
        if (/^([0-9]{2})([9]{1})(\d)(?!\3+$)\d*$/.test(lineNumber) == false) {
            let errorMsg = "O número da linha informado não é válido" + "\n";
            cmp.set("v.msgModalError", errorMsg + "\n" + "Por favor, corrija os problemas e tente novamente.");
            cmp.set("v.showModalError", true);
            valido = false;
            return valido;
        }
        if (tipoEntrega == 'Local' && (!lineIMEI || lineIMEI.length != lineIMEIMax)) {
            valido = false;
            return valido;
        }
        if (typeof deviceSelected === undefined || deviceSelected === null || deviceSelected == "") {
            valido = false;
            return valido;
        }
        return valido;
        
    },
    verificarCamposDoador : function(cmp, event) {
        let donatorName = "donatorName";
        let donatorCpf = "donatorCpf";
        let donatorPhone = "donatorPhone";
        let donatorEmail = "donatorEmail";
        
        let donatorNameMax = cmp.find(donatorName).get("v.maxlength");
        let donatorCpfMax = cmp.find(donatorCpf).get("v.maxlength");
        let donatorPhoneMax = cmp.find(donatorPhone).get("v.maxlength");
        let donatorEmailMax = cmp.find(donatorEmail).get("v.maxlength");
        let valueName = cmp.get("v." + donatorName);
        let valueCpf = cmp.get("v." + donatorCpf+"Raw");
        let valuePhone = cmp.get("v." + donatorPhone+"Raw");
        let valueEmail = cmp.get("v." + donatorEmail);
        let valid = false;
        let errorMsg = "";
        if (!(valueName.length > 2 && valueName.length <= donatorNameMax)) {
            errorMsg += "O nome do doador é inválido." + "\n";
        }
        if (valuePhone.length != 11
           || /^([0-9]{2})([9]{1})(\d)(?!\3+$)\d*$/.test(valuePhone) == false) {
            errorMsg += "O número de celular informado não é válido" + "\n";
        }
        if (!(valueEmail.length > 7 && valueEmail.length <= donatorEmailMax)) {
            errorMsg += "O E-mail informado é invalido ou muito curto" + "\n";
        }
        if (!(valueCpf.length == 11)) {
            errorMsg += "O CPF informado não possui 11 digitos." + "\n";
        }
        if (!this.verificarCpf(cmp.get("v.donatorCpfRaw"))) {
            errorMsg += "O CPF informado não é válido." + "\n";
        }
        if (errorMsg.length == 0) {
            return true;
        }
        cmp.set("v.msgModalError", errorMsg + "\n" + "Por favor, corrija os problemas e tente novamente.");
        cmp.set("v.showModalError", true);
        return false;
            
    },
    limparValoresDoador : function(cmp) {
        // Limpa os valores dos campos de Doador
        cmp.set("v.donatorName", "");
        cmp.set("v.donatorCpf", "");
        cmp.set("v.donatorPhone", "");
        cmp.set("v.donatorEmail", "");
        cmp.set("v.lineList", []);
        
    },
    // Autor: Rafael de Campos - Deloitte
    onlyNumbers : function(textToFormat) {
        try{
            //verifica se a string está nula ou vazia
            if(textToFormat){
                //REGEX para aceitar apenas números
                let numPattern = /\d+/g;
                let numberText = textToFormat.match(numPattern);
                //caso gere número com vírgulas, remove as vírgulas
                return numberText === null ? "" : numberText.toString().replace(/,/g, '');
            }else{
                return "";
            }
        }catch(err){
            console.log(err);
        }
    },
    getAparelhoPorChave : function(deviceKey, devices) {
        // Função que retorna um objeto com 'Label' e 'Chave' do aparelho
        for(let i = 0; i < devices.length; i++) {
            let key = Object.keys(devices[i].aparelho)[0];
            if (key == deviceKey) { 
                return devices[i];
            }
        }
        return {aparelho: null};
	},
    
    getAparelhoKeys : function(aparelho) {
        let aparelhoKey = Object.keys(aparelho)[0];
        // Using 'deviceKey' to return corresponding value from 'aparelho'
       
        return { label: aparelho[aparelhoKey], key: aparelhoKey };
    },
    removeAparelhoLogic : function(cmp, aparelhos, lineList, isDonator, addToList) {
        // Alterar para receber uma lista de aparelhos
        let removedDevices = [];
        if (isDonator) {
            lineList = lineList.concat(aparelhos);
        	cmp.set("v.lineList", lineList);
        }
        
        for (let i=0; i < aparelhos.length; i++) {
            for (let j=0; j < lineList.length; j++) {
                if (lineList[j] == aparelhos[i]) {
                    removedDevices.push({ label: aparelhos[i].Modelo, key: aparelhos[i].Chave });
                    lineList.splice(j, 1);
                    break;
                }
            }
        }
        if (removedDevices.length > 0
            //&& cmp.get("v.sessao.tipoTransferencia.tipoEntrega") != 'Local'
           ) {
            let colorCmp = cmp.find("seletorDeCores");
            let colorCmpDeviceOptions = colorCmp.get("v.deviceOptions");
            for (let i=0; i < removedDevices.length; i++) {
                colorCmpDeviceOptions.push(removedDevices[i]);
            }
            colorCmp.set("v.deviceOptions", colorCmpDeviceOptions);
        }
        let deviceOptions = cmp.get("v.deviceOptions");
        for (let i=0; i < removedDevices.length; i++) {
            deviceOptions.push(removedDevices[i]);
        }
        cmp.set("v.deviceOptions", deviceOptions);
        if (addToList) {
            cmp.set("v.lineList", lineList);
        }
    },
    undoAparelhoRemoved : function(cmp, aparelho) {
        console.log("\n \n \n \n >>>>>>>>>>>>>>>>>");
        console.log(aparelho);
        // Alterar para receber uma lista de aparelhos
        let aparelhoFull = this.getAparelhoPorChave(aparelho, cmp.get("v.sessao.lstAparelhos"))
        let aparelhoObject = { label: aparelhoFull.aparelho[aparelho], key: aparelho };
        
        let colorCmp = cmp.find("seletorDeCores");
        let colorCmpDeviceOptions = colorCmp.get("v.deviceOptions");
        console.log(colorCmpDeviceOptions);
        colorCmpDeviceOptions.push(aparelhoObject);
        colorCmp.set("v.deviceOptions", colorCmpDeviceOptions);
        colorCmp.set("v.deviceSelected", { label: "--Selecione--", key: "--" });
        
        let deviceOptions = cmp.get("v.deviceOptions");
        deviceOptions.push(aparelhoObject);
        cmp.set("v.deviceOptions", deviceOptions);
        cmp.set("v.deviceSelected", { label: "--Selecione--", key: "--" });
    },
    aparelhoAdicionadoToTable : function(cmp, event, label, value, color, colors) {
        // Função de adicionar aparelho para tabela
        let lineNumber = cmp.get("v.lineNumber"); // Numero da linha
        let lineICCID = cmp.get("v.lineICCID"); // ICCID
        let lineIMEI = cmp.get("v.lineIMEI"); // IMEI
        let deviceKey = value; // Chave do aparelho
        let deviceOptions = cmp.get("v.deviceOptions"); // Opções de aparelhos no lightning:select
        let deviceList = cmp.get("v.deviceList"); // Lista de aparelhos original do JSON
        let lineList = cmp.get("v.lineList"); // Lista de linhas que viram itens de tabela
        
        // Adiciona na lista um objeto com os dados da tabela
        lineList.push({ Linha: lineNumber, 
            			ICCID: lineICCID, 
            			IMEI: lineIMEI, 
            			Modelo: label, 
            			Cor: color, 
            			Cores: colors, 
            			Chave: value });
        
        // Remove da lista de opções
        for (let i=0; i < deviceOptions.length; i++) {
            if (deviceOptions[i].key == value) {
                deviceOptions.splice(i,1);
                break;
            }
        }
        
        // Atualiza os atributos
        cmp.set("v.lineList", lineList);
        cmp.set("v.deviceOptions", deviceOptions);
    }
})