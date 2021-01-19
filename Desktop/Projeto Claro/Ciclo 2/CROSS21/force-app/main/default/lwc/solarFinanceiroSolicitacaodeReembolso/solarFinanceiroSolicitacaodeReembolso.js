/**
 * @description       : Controller js
 * @author            : Caio Cesar Leite de Oliveira
 * @group             : Financeiro
 * @last modified on  : 01-11-2020
 * @last modified by  : Caio Cesar Leite de Oliveira
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-11-2020   Caio Cesar  Initial Version
**/

//Recursos e componentes
import { LightningElement,wire, track } from 'lwc';
import Utils from "c/solarUtils";


//GetPickList
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import PAYMENTADJUSTMENT_OBJECT from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c';
import REQUESTTYPE_FIELD from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c.RequestType__c';
import PERSONTYPE_FIELD from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c.PersonType__c';
import REFUNDACCOUNT_FIELD from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c.RefundAccount__c';
import BANK_FIELD from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c.Bank__c';
import REFUNDREASON_FIELD from '@salesforce/schema/vlocity_cmt__PaymentAdjustment__c.RefundReason__c';

//Custom Labels


export default class SolarFinanceiroSolicitacaodeReembolso extends LightningElement {

    @track tipoPessoaSelected = '';
    @track layoutPessoaFisica = false;
    @track layoutPessoaJuridica = false;

    @track motivoReembolsoSelected = '';
    @track toggleDisabled = false;

    @track cpf;
    @track cnpj;
    @track statusCpfCnpj;

    @track numero;
    
    @track tipoSolicitacao;
    @track tipoPessoa;
    @track claroOuTerceiro;
    @track bancos;
    @track motivos;
    @track error;
    @track values;

    @track tipoReembolso
    @track tipoSolicitacaoSel
    @track numBanContaSel
    @track tipoPessoaSel
    @track tipoContaSel
    @track nomeClienteSel
    @track valorSel
    @track cpfCnpjSel
    @track bancoSel
    @track banco
    @track agenciaSel
    @track contaCorrenteSel
    @track digitoContaSel
    @track motivoSel
    @track motivo
    @track reembolsoEmDobroSel;
    @track reembolsoEmDobro = 'REEMBOLSO EM DOBRO_NÃO';
    @track ddd1Sel
    @track tel1Sel
    @track ddd2Sel
    @track tel2Sel
    @track emailSel
    @track observacaoSel

    @track superString;

    @wire(getObjectInfo, { objectApiName: PAYMENTADJUSTMENT_OBJECT })

    PaymentAdjustmentMetadata;

    //Get Tipo de solicitação
    @wire(getPicklistValues, {
        recordTypeId : '$PaymentAdjustmentMetadata.data.defaultRecordTypeId',
        fieldApiName : REQUESTTYPE_FIELD
    })
        wiredPickListValue1({ data, error }){
            if(data){
                console.log('Picklist values are ', data.values);
                this.tipoSolicitacao = data.values;
                this.error = undefined;
            }
            if(error){
                console.log(' Error while fetching Picklist values  ${error}');
                this.error = error;
                this.tipoSolicitacao = undefined;
            }
        }

    //Get TipoPessoa
    @wire(getPicklistValues, {
        recordTypeId : '$PaymentAdjustmentMetadata.data.defaultRecordTypeId',
        fieldApiName : PERSONTYPE_FIELD
    })
        wiredPickListValue2({ data, error }){
            if(data){
                console.log('Picklist values are ', data.values);
                this.tipoPessoa = data.values;
                this.error = undefined;
            }
            if(error){
                console.log(' Error while fetching Picklist values  ${error}');
                this.error = error;
                this.tipoPessoa = undefined;
            };
        }

    //Get Cliente Claro ou Terceiro
    @wire(getPicklistValues, {
        recordTypeId : '$PaymentAdjustmentMetadata.data.defaultRecordTypeId',
        fieldApiName : REFUNDACCOUNT_FIELD
    })
    wiredPickListValue3({ data, error }){
        if(data){
            console.log('Picklist values are ', data.values);
            this.claroOuTerceiro = data.values;
            this.error = undefined;
            let arrayToFilter = this.claroOuTerceiro;
            let filteredArray = arrayToFilter.filter( element => element.value != 'Cliente NET');
            this.claroOuTerceiro = filteredArray;
        }
        if(error){
            console.log(' Error while fetching Picklist values  ${error}');
            this.error = error;
            this.claroOuTerceiro = undefined;
        }
        
    }

    //Get Bancos
    @wire(getPicklistValues, {
        recordTypeId : '$PaymentAdjustmentMetadata.data.defaultRecordTypeId',
        fieldApiName : BANK_FIELD
    })
    wiredPickListValue4({ data, error }){
        if(data){
            console.log('Picklist values are ', data.values);
            this.bancos = data.values;
            this.error = undefined;
        }
        if(error){
            console.log(' Error while fetching Picklist values  ${error}');
            this.error = error;
            this.bancos = undefined;
        }
    }

    //Get Motivos
    @wire(getPicklistValues, {
        recordTypeId : '$PaymentAdjustmentMetadata.data.defaultRecordTypeId',
        fieldApiName : REFUNDREASON_FIELD
    })
    wiredPickListValue5({ data, error }){
        if(data){
            console.log('Picklist values are ', data.values);
            this.motivos = data.values;
            this.error = undefined;
            let arrayToFilter = this.motivos;
            let filteredArray = arrayToFilter.filter( element => element.value != 'Danos Causados');
            this.motivos = filteredArray;
        }
        if(error){
            console.log(' Error while fetching Picklist values  ${error}');
            this.error = error;
            this.motivos = undefined;
        }
    }

    //OnLoad
    connectedCallback() {
    }
    
    renderedCallback() {
        
    }

    get reembolso() {
        return [
            { label: 'Conta Corrente', value: 'CC' },
            { label: 'Ordem de pagamento', value: 'OP'},
        ];
    }


    //Função para resgatar o tipo de pessoa selecionada e apresentar o DOC de acordo
    handleChangeTipoPessoa(event) {

        this.tipoPessoaSelected = event.detail.value;
        this.tipoPessoaSel = event.detail.value;

        if(this.tipoPessoaSelected=='Pessoa Física'){
            this.layoutPessoaFisica = true;
            this.layoutPessoaJuridica = false;
        }
        else{
            this.layoutPessoaJuridica = true;
            this.layoutPessoaFisica = false;
        }

    }

    //Função para resgatar o motivo de reembolso e desabilitar o toggle de acordo com o motivo selecionado
    handleChangeMotivoReembolso(event) {

        this.motivoReembolsoSelected = event.detail.value;
        this.motivoSel = this.motivoReembolsoSelected;

        if(this.motivoReembolsoSelected=='Cliente pagou em duplicidade'){
            this.toggleDisabled = true;
        }
        else{
            this.toggleDisabled = false;
        }

        let motivoShort = new Map();
        motivoShort.set("Cliente pagou em duplicidade", "CLIENTE PAGOU EM DUPLICIDADE");
        motivoShort.set("Contrato cancelado gerando faturas(Desconexão Por Opção)", "DESCONEXÃO POR OPÇÃO");
        motivoShort.set("Cobrança de valores incorretos na fatura", "ERROS DE COBRANÇA");
        motivoShort.set("Produto/serviço cobrado e não solicitado", "DESACORDO NA VENDA");
        motivoShort.set("Cobrança de ligações não reconhecidas", "CHAMADAS CLARO MOVEL");
        motivoShort.set("Débito em conta corrente de Terceiro(DCC indevido)", "DCC EM CONTA DE TERCEIRO");
        this.motivo = motivoShort.get(this.motivoSel);

    }

    //Função clique do botão solicitar reembolso
    handleClick(event) {

        const inputField = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        const comboBox = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        const textArea = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
            }, true);

        if (inputField && comboBox && textArea && this.statusCpfCnpj==true){
            if(this.tipoReembolso == "CC"){
                Utils.showToast(this,"success",null,"Contestação e solicitação de reembolso realizadas com sucesso.");
                console.log(this.tipoReembolso + '#' + this.tipoSolicitacaoSel.replaceAll(' ','_').toUpperCase().replace('DE_','') + '#' + this.numBanContaSel + '#'  + this.valorSel + 'NaN' + this.tipoPessoaSel.replaceAll(' ','_').toUpperCase().replace('Í','I') + '#' + this.tipoContaSel.toUpperCase() + '#' + this.nomeClienteSel.toUpperCase() + '#' + this.cpfCnpjSel + '#' + this.banco + '#' + this.agenciaSel + '#'+this.contaCorrenteSel +  '#'+ this.digitoContaSel + '#' + this.motivo + '#' + this.reembolsoEmDobro + '#' + this.observacaoSel.toUpperCase() + '#' + this.ddd1Sel + '-' + this.tel1Sel + '#' + this.ddd2Sel + '-' + this.tel2Sel + '#' + this.emailSel + '#');
            }
            else{
                Utils.showToast(this,"success",null,"Contestação e solicitação de reembolso realizadas com sucesso.");
                console.log(this.tipoReembolso + '#' + this.tipoSolicitacaoSel.replaceAll(' ','_').toUpperCase().replace('DE_','') + '#' + this.numBanContaSel + '#'  + this.valorSel + 'NaN' + this.tipoPessoaSel.replaceAll(' ','_').toUpperCase().replace('Í','I') + '#' + this.tipoContaSel.toUpperCase() + '#' + this.nomeClienteSel.toUpperCase() + '#' + this.cpfCnpjSel + '#' + '#' + '#'+ '#' + '#' + this.motivo + '#' + this.reembolsoEmDobro + '#' + this.observacaoSel.toUpperCase() + '#' + this.ddd1Sel + '-' + this.tel1Sel + '#' + this.ddd2Sel + '-' + this.tel2Sel + '#' + this.emailSel + '#');
            }
        }else{
            Utils.showToast(this,"warning",null,"Preencha todos os campos obrigatórios de forma correta");
        }
    }

    //Função para validar CPF
    validaCPF(event) {
        this.cpf = event.target.value;
        let resto;
        let soma = 0;
        let i;
        // Elimina CPFs invalidos conhecidos
        switch (this.cpf) {
            case '00000000000':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '11111111111':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '22222222222':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '33333333333':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '44444444444':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '55555555555':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '66666666666':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '77777777777':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '88888888888':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");

            case '99999999999':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CPF inválido");
            default:
                break;
        }

        for (i=1; i<=9; i++) soma = soma + parseInt(this.cpf.substring(i-1, i)) * (11 - i);
        resto = (soma * 10) % 11;

        if ((resto == 10) || (resto == 11))
            resto = 0;

        if (resto != parseInt(this.cpf.substring(9, 10)) ){
            this.statusCpfCnpj = false; 
            return Utils.showToast(this,"warning",null,"CPF inválido");
        };
        soma = 0;
        for (i = 1; i <= 10; i++) soma = soma + parseInt(this.cpf.substring(i-1, i)) * (12 - i);
        resto = (soma * 10) % 11;
        if ((resto == 10) || (resto == 11)){
            resto = 0;
        }
        if (resto != parseInt(this.cpf.substring(10, 11) ) ){
            this.statusCpfCnpj = false;
            return Utils.showToast(this,"warning",null,"CPF inválido");
        };
        this.statusCpfCnpj = true;
        return Utils.showToast(this,"success",null,"CPF válido");
            
    }

    //Função para validar CNPJ
    validaCNPJ(event){
        this.cnpj = event.target.value;
        let tamanho = this.cnpj.length - 2
        let numeros = this.cnpj.substring(0,tamanho);
        let digitos = this.cnpj.substring(tamanho);
        let soma = 0;
        let pos = tamanho - 7;
        let resultado
        let i;

        // Elimina CNPJs invalidos conhecidos
        switch (this.cnpj) {
            case '':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '00000000000000':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '11111111111111':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '22222222222222':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '33333333333333':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '44444444444444':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '55555555555555':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '66666666666666':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '77777777777777':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '88888888888888':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");

            case '99999999999999':
                this.statusCpfCnpj = false;
                return Utils.showToast(this,"warning",null,"CNPJ inválido");
            default:
                break;
        }
        
        for (i = tamanho; i >= 1; i--) {
        soma += numeros.charAt(tamanho - i) * pos--;
        if (pos < 2)
                pos = 9;
        }
        resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        if (resultado != digitos.charAt(0)){
            this.statusCpfCnpj = false; 
            return Utils.showToast(this,"warning",null,"CNPJ inválido");
        }
        tamanho = tamanho + 1;
        numeros = this.cnpj.substring(0,tamanho);
        soma = 0;
        pos = tamanho - 7;
        for (i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2){
                pos = 9;
            }  
        }
        resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        if (resultado != digitos.charAt(1)){
            this.statusCpfCnpj = false; 
            return Utils.showToast(this,"warning",null,"CNPJ inválido");
        }
        this.statusCpfCnpj = true;
        return Utils.showToast(this,"success",null,"CNPJ válido"); 
    }

    somenteNumeros(event){
        let numeroAtual = event.target.value;
        let numeroAtualizado = numeroAtual.replace(/\D/g,'');
        event.target.value = numeroAtualizado;
    }

    naoImplementado(event){
        return Utils.showToast(this,"warning",null,"Não Implementado");
    }

    //Funções para resgatar e formatar valores do formulário
    getTipoReembolso(event){
        this.tipoReembolso = event.detail.value;
    }

    getValueTipoSolicitacao(event){
        this.tipoSolicitacaoSel = event.detail.value;
    }

    getValueNumBanConta(event){
        this.numBanContaSel = event.detail.value;
    }

    //ValueTipoPessoa esta sendo pego na handleChangeTipoPessoa

    getValueTipoConta(event){
        this.tipoContaSel = event.detail.value;
        if(this.tipoContaSel == 'Cliente NET')
        {
            this.tipoContaSel = 'CLIENTE'
        }
        
    }

    getValueNomeCliente(event){
        this.nomeClienteSel = event.detail.value;
        
    }

    getValueValor(event){
        this.valorSel = event.detail.value;
        
    }

    getValueCpfCnpj(event){
        this.cpfCnpjSel = event.detail.value;
        
    }

    getValueAgencia(event){
        this.agenciaSel = event.detail.value;
        
    }

    getValueContaCorrente(event){
        this.contaCorrenteSel = event.detail.value;
        
    }

    getValueDigitoConta(event){
        this.digitoContaSel = event.detail.value;
        
    }

    //getValueMotivo esta pegando no handleChangeMotivoReembolso

    getValueReembolsoEmDobro(event){
        this.reembolsoEmDobroSel = event.target.checked;
        if(this.reembolsoEmDobroSel == true){
            this.reembolsoEmDobro = 'REEMBOLSO EM DOBRO_SIM';
        }
        else{
            this.reembolsoEmDobro = 'REEMBOLSO EM DOBRO_NÃO';
        }
    }

    getValueDdd1(event){
        this.ddd1Sel = event.detail.value;
    }

    getValueTel1(event){
        this.tel1Sel = event.detail.value;
    }

    getValueDdd2(event){
        this.ddd2Sel = event.detail.value;
    }

    getValueTel2(event){
        this.tel2Sel = event.detail.value;
    }

    getValueEmail(event){
        this.emailSel = event.detail.value;
    }

    getValueObservacao(event){
        this.observacaoSel = event.detail.value;
    }

    getValueBanco(event){
        this.bancoSel = event.detail.value;

        let bankCode = new Map();
		bankCode.set("Banco ABC Brasil S.A.", "246");
		bankCode.set("Banco Alfa S.A.", "025");
		bankCode.set("Banco Alvorada S.A.", "641");
		bankCode.set("Banco Banestado S.A.", "038");
		bankCode.set("Banco Barclays S.A.", "740");
		bankCode.set("Banco BBM S.A.", "107");
		bankCode.set("Banco Beg S.A.", "031");
		bankCode.set("Banco BM&F de Serviços de Liquidação e Custódia S.A", "096");
		bankCode.set("Banco BNP Paribas Brasil S.A.", "752");
		bankCode.set("Banco Boavista Interatlântico S.A.", "248");
		bankCode.set("Banco Brascan S.A.", "225");
		bankCode.set("Banco BVA S.A.", "044");
		bankCode.set("Banco Cacique S.A.", "263");
		bankCode.set("Banco Calyon Brasil S.A.", "222");
		bankCode.set("Banco Cargill S.A.", "040");
		bankCode.set("Banco Comercial e de Investimento Sudameris S.A.", "215");
		bankCode.set("Banco Cooperativo do Brasil S.A. - BANCOOB", "756");
		bankCode.set("Banco Cooperativo Sicredi S.A.", "748");
		bankCode.set("Banco Credit Suisse (Brasil) S.A.", "505");
		bankCode.set("Banco Cruzeiro do Sul", "229");
		bankCode.set("Banco da Amazônia S.A.", "003");
		bankCode.set("Banco Daycoval S.A.", "707");
		bankCode.set("Banco de Pernambuco S.A. - BANDEPE", "024");
		bankCode.set("Banco de Tokyo-Mitsubishi UFJ Brasil S.A.", "456");
		bankCode.set("Banco Dibens S.A.", "214");
		bankCode.set("Banco do Brasil", "001");
		bankCode.set("Banco do Estado de Santa Catarina S.A.", "027");
		bankCode.set("Banco do Estado de Sergipe S.A.", "047");
		bankCode.set("Banco do Estado do Pará S.A.", "037");
		bankCode.set("Banco do Nordeste do Brasil S.A.", "004");
		bankCode.set("Banco Fator S.A.", "265");
		bankCode.set("Banco Fibra S.A.", "224");
		bankCode.set("Banco Ficsa S.A.", "626");
		bankCode.set("Banco Finasa S.A.", "175");
		bankCode.set("Banco Fininvest S.A.", "252");
		bankCode.set("Banco GE Capital S.A.", "233");
		bankCode.set("Banco Gerdau S.A.", "734");
		bankCode.set("Banco Guanabara S.A.", "612");
		bankCode.set("Banco Ibi S.A. Banco Múltiplo", "063");
		bankCode.set("Banco Industrial do Brasil S.A.", "604");
		bankCode.set("Banco Industrial e Comercial S.A.", "320");
		bankCode.set("Banco Indusval S.A.", "653");
		bankCode.set("BANCO INTER", "077");
		bankCode.set("Banco Intercap S.A.", "630");
		bankCode.set("Banco J. P. Morgan S.A.", "376");
		bankCode.set("Banco J. Safra S.A.", "074");
		bankCode.set("Banco Luso Brasileiro S.A.", "600");
		bankCode.set("Banco Mercantil do Brasil S.A.", "389");
		bankCode.set("Banco Merrill Lynch de Investimentos S.A.", "755");
		bankCode.set("Banco Opportunity S.A.", "045");
		bankCode.set("BANCO ORIGINAL S.A.", "212");
		bankCode.set("Banco Panamericano S.A.", "623");
		bankCode.set("Banco Paulista S.A.", "611");
		bankCode.set("Banco Pine S.A.", "643");
		bankCode.set("Banco Prosper S.A.", "638");
		bankCode.set("Banco Rabobank International Brasil S.A.", "747");
		bankCode.set("Banco Rendimento S.A.", "633");
		bankCode.set("Banco Rural Mais S.A.", "072");
		bankCode.set("Banco Rural S.A.", "453");
		bankCode.set("Banco Safra S.A.", "422");
		bankCode.set("Banco Schahin S.A.", "250");
		bankCode.set("Banco Simples S.A.", "749");
		bankCode.set("Banco Société Générale Brasil S.A.", "366");
		bankCode.set("Banco Sofisa S.A.", "637");
		bankCode.set("Banco Sumitomo Mitsui Brasileiro S.A.", "464");
		bankCode.set("Banco Triângulo S.A.", "634");
		bankCode.set("Banco UBS Pactual S.A.", "208");
		bankCode.set("Banco Único S.A.", "116");
		bankCode.set("Banco Votorantim S.A.", "655");
		bankCode.set("Banco VR S.A.", "610");
		bankCode.set("Banco WestLB do Brasil S.A.", "370");
		bankCode.set("BANESTES S.A. Banco do Estado do Espírito Santo", "021");
		bankCode.set("Banif-Banco Internacional do Funchal (Brasil)S.A.", "719");
		bankCode.set("Bankpar Banco Multiplo S.A..", "204");
		bankCode.set("Banrisul", "041");
		bankCode.set("BB Banco Popular do Brasil S.A.", "073");
		bankCode.set("BPN Brasil Banco Mútiplo S.A.", "069");
		bankCode.set("BRB - Banco de Brasília S.A.", "070");
		bankCode.set("Caixa Econômica Federal", "104");
		bankCode.set("Citibank", "745");
		bankCode.set("Deutsche Bank S.A. - Banco Alemão", "487");
		bankCode.set("Dresdner Bank Brasil S.A. - Banco Múltiplo", "751");
		bankCode.set("Hipercard Banco Múltiplo S.A.", "062");
		bankCode.set("ING Bank N.V.", "492");
		bankCode.set("Itaú", "341");
		bankCode.set("JPMorgan Chase Bank", "488");
		bankCode.set("NuBank", "260");
		bankCode.set("Ordem de Pagamento", "000");
		bankCode.set("Santander", "033");
		bankCode.set("Unibanco", "409");
		bankCode.set("Unicard Banco Múltiplo S.A.", "230");
        bankCode.set("Bradesco", "237");
        this.banco = bankCode.get(this.bancoSel);
    }

}