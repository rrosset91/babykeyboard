import { LightningElement, api, track } from "lwc";

export default class solarModalCalculator extends LightningElement {
	@track
	showModal = false;
	@api
	size = "small";
	@api
	header;
	sldsModalSize = "slds-modal_small";

	renderedCallback() {
		if (!this.showModal) return;

		if (this.size === "small") this.sldsModalSize = "slds-modal_small";
		else if (this.size === "medium") this.sldsModalSize = "slds-modal_medium";
		else this.sldsModalSize = "slds-modal_large";

		this.template.querySelector("section").classList.add(this.sldsModalSize);
	}

	@api
	open() {
		this.showModal = true;
	}

	@api
	close() {
		this.showModal = false;
	}

	saveCalculadora(event)
    {
        let calcPerc       = this.calculoTipoPorcentagem;
        let percVal        = (this.calculoTipoPorcentagem) ? this.template.querySelector('[data-id="percentModalCalculo"]').value : 0;
        let daysVal        = (!this.calculoTipoPorcentagem) ? this.template.querySelector('[data-id="qtdModalCalculo"]').value : 0;
        let allItems       = this.template.querySelector('[data-id="valorFinal"]').data;
        let dataCalc       = this.modalItem;
		let orgValue       = JSON.stringify(dataCalc);
        let correctedValue = 0;
        let calculoDias    = this.template.querySelector('[data-id="qtdModalCalculo"]').value;
        
        // Dias
        if (!calcPerc && daysVal > 30)  {Utils.showToast(this, "warning", null, "Dia inválido, o dia não pode ser maior que 30");}
        if (!calcPerc && daysVal <= 0)  {Utils.showToast(this, "warning", null, "Dia inválido, o dia não pode menor ou igual a 0");}   

        // Porcentagem
        if (calcPerc && percVal > 100)  {Utils.showToast(this, "warning", null, "Porcentagem inválida, a porcentagem não pode ser maior que 100");}
        if (calcPerc && percVal <= 0)   {Utils.showToast(this, "warning", null, "Porcentagem inválida, a porcentagem não pode ser menor ou igual a zero");}

        if (calcPerc) {correctedValue = orgValue - (percVal / 100) * dataCalc;}
        else          {correctedValue = orgValue - (daysVal * dataCalc) / 30; }

        if (correctedValue < 0) {Utils.showToast(this, "warning", null, "Valor inválido, o valor corrigido não pode ser negativo");}

        //'set' on proxy: trap returned falsish for property - foi feito esse workaround por que os dados no data-table são read-only... 
        let clonedAllItems = []; //logo, é necessário clonar os objetos do array e processá-los de volta.
        allItems.forEach((x) => {clonedAllItems.push(Object.assign({}, x));});  //clonando os objetos aqui  -- com obj clonados, é possivel alterar seus atributos e valores
        
        clonedAllItems.forEach((z) => 
        {
            if (z.idItem == dataCalc.idItem) 
            {   
                z.calculoDias = orgValue - correctedValue;
                z.valorCorrigido = correctedValue;
			}
        });
        
        //atribuir os valores clonados de volta para os dados do data-table
        this.data = clonedAllItems;
        this.template.querySelector("c-solar-modal-calculator").close(); 
    }
}