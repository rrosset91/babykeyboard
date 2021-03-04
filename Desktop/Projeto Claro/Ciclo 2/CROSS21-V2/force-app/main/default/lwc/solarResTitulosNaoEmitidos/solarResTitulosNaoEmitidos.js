import { LightningElement, api } from 'lwc';
import Utils from "c/solarUtils";
import getBillDebts from '@salesforce/apex/FinancialBondsNotIssued.getBillDebts';

export default class SolarResTitulosNaoEmitidos extends LightningElement {
    @api baseAttributes;
    dataOnTable; //dados filtrados ou não para o data table
    dataAll; //cópia de todos os dados do data table para refresh caso necessário
    selectedDataRow; // ao clicar no botão "Mais informações", esse atributo é preenchido com o lançamento escolhido 
    loading; //atributo de controle para mostrar ou não o spinner
    hasData; //atributo de controle para mostrar ou não o conteúdo
    //estrutura de colunas para o datatable
    columns = [{ label: "Tipo", fieldName: "itemDescription", type: "text", sortable: true },
               { label: "Data do Lançamento", fieldName: "entryDate", type: "text", sortable: true },
               { label: "Valor", fieldName: "amount", type: "text", sortable: true },
               { label: "", type: "button", typeAttributes: {label: "Ver detalhes", title: "Ver detalhes", name: "view_modal", iconName:"utility:preview", iconPosition:"left"}}];
    //do Init - no carregamento da page
    connectedCallback(){
        this.selectedDataRow = {};
        this.loading = true;
        let historyParams = {
			contractId: this.baseAttributes.contractId, //"054"
			operatorId: this.baseAttributes.operatorId, //"1162015"
			startDate: "",
			endDate: ""
        }
        //serverside callback - Promise
        getBillDebts(historyParams)
        .then(result => {
            if(result){
                if(result.groupDebts.length > 0){
                    this.hasData = true;
                    this.dataOnTable = result;
                    this.dataAll = result;
                }else{
                    this.hasData = false;
                    this.dataOnTable = [];
                    this.dataAll = []; 
                }
            }else{
                this.hasData = false;
                this.dataOnTable = [];
                this.dataAll = [];
            }
            this.loading = false;
        })
        .catch(error => {
            console.log(error);
            this.loading = false;
            Utils.showToast(this, "error", null, "Ops... Algo de errado aconteceu, por favor tente novamente");
        });
    }
    //função chamada no campo de busca, para filtrar os resultados em tela
    handleFiltroBusca(event) {
        //decidir se for usar a tecla enter para busca ou não
        /*const isEnterKey = event.keyCode === 13; //tecla enter
        if (isEnterKey) {}*/
        /*console.log('tamanho do dataAll: ' + JSON.stringify(this.dataAll.groupDebts.length));
        const lista = this.dataAll.groupDebts;
        console.log('tamanho da lista antes: ' + JSON.stringify(lista.length));
        let busca = event.target.value;
        let chave = '';
        let regex = /[áàâãéèêíìîóòôõúù]/g;
        let acento = (busca != '') ? regex.test(busca) : false;    
        if(lista.length > 0){
            let filtrada = lista.filter(function(elem, index, array){
                if(acento){
                    return elem.groupDescription.toUpperCase().startsWith(busca.toUpperCase()) || elem.groupDescription.toUpperCase().includes(busca.toUpperCase());
                }else{
                    chave = elem.groupDescription.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
                    busca = busca.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
                    return chave.toUpperCase().startsWith(busca.toUpperCase()) || chave.toUpperCase().includes(busca.toUpperCase());
                }
            });
            let listaFiltrada = (busca != '') ? filtrada : this.dataAll.groupDebts;
            console.log('tamanho da lista depois: ' + JSON.stringify(listaFiltrada.length));
            this.hasData = false;
            this.dataOnTable.groupDebts = listaFiltrada;
            this.hasData = true;
        }*/
    }
    //ação de click do botão mais informalções
    handleRowAction(event) {
        const row = event.detail.row;
        this.selectedDataRow = row;
        this.handleOpenModal();
    }
    //abre modal
    handleOpenModal() {
        this.template.querySelector("c-solar-modal").open();
      }
    //fecha modal
    handleCloseModal() {
        this.template.querySelector("c-solar-modal").close();
    }
}