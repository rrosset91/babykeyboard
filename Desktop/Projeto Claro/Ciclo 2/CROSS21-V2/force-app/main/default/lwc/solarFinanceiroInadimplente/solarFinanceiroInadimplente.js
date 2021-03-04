import { LightningElement, api, track } from "lwc";
import Utils from "c/solarUtils";
import invoicesPending from "@salesforce/apex/FinancialNegotiationInadimplente.getInvoicesPending";

export default class SolarFinanceiroInadimplente extends LightningElement {
	@api baseAttributes;
	@api baseDetail;
	@api selectedItems = [];
	@track activeSections = ["accordionFatura", "accordionlancamentoFuturos"];
	@track negociationItems = [];
	@track modalItem = {};
	@track reasonContext = {};
	@track hasData = false;
	@track hasError = false;
	@track buttonSimulation = false;
	@track chamadaSemSucesso = false;
	@track error;
	@track negotiationType;
	@track sortBy;
	@track sortDirection;
	@track negotiatonItems = [];
	columns = [
		{ label: "TIPO", fieldName: "type", type: "text", hideDefaultActions: true },
		{ label: "DATA VENCIMENTO", fieldName: "dataVencimento", type: "date", hideDefaultActions: true },
		{ label: "VALOR", fieldName: "invoiceAmount", type: "currency", typeAttributes: { currencyCode: "BRL", step: "0.01" }, hideDefaultActions: true }
	];
	details = {
		billsIdsString: [],
		bills: [],
		selectedBills: [],
		statements: [],
		statementsIdsString: []
	};
	handleSort = {
		sortBills: (evt) => this.handleSortData(evt, "bills"),
		sortStatements: (evt) => this.handleSortData(evt, "statements")
	};

	connectedCallback() {
		console.clear();
		this.fetchDetailsInvoices();
	}

	async fetchDetailsInvoices() {
		const data = await invoicesPending({ operatorCode: this.baseAttributes.operatorId, contractNumber: this.baseAttributes.contractId }).catch((err) => {
			console.log("@@@ Debug da variavel: err", JSON.parse(JSON.stringify(err)));
			this.hasData = false;
			this.hasError = true;
			Utils.showToast(this, "error", null, err.body.message);
		});

		if (this.hasError) return;
		console.log("@@@ Debug da variavel: data", JSON.parse(JSON.stringify(data)));

		this.hasData = true;

		this.details = {
			billsIdsString: [],
			bills: [],
			selectedBills: [],
			statements: [],
			statementsIdsString: []
		};

		data.invoiceItems.forEach((invoice) => {
			invoice.bills.forEach((bill) => {
				this.details.billsIdsString.push(bill.billId);

				this.details.bills.push({
					type: bill.type,
					dataVencimento: bill.dueDate,
					invoiceAmount: Number(bill.valueInvoice.replace(",", ".")),
					billId: bill.billId
				});

				console.log("@@@ Debug da variavel: bill.valueInvoice", JSON.parse(JSON.stringify(bill.valueInvoice)));
				console.log("@@@ Debug da variavel: bill.valueInvoice", JSON.parse(JSON.stringify(Number(bill.valueInvoice.replace(",", ".")))));

				if (bill.isMandatory === "true") this.details.selectedBills.push(bill.billId);
			});

			invoice.statements.forEach((statement) => {
				this.details.statementsIdsString.push(statement.statementId);

				this.details.statements.push({
					type: statement.type,
					dataVencimento: statement.dueDate,
					invoiceAmount: Number(statement.valueInvoice(",", "."))
				});
			});
		});

		console.log("@@@ Debug da variavel: this.details", JSON.parse(JSON.stringify(this.details)));
	}

	handleSortData(event, table) {
		alert("nao implementado" + table);
	}

	handleRowSelection(event) {
		let billIds = [];
		let fullSum = 0;

		event.detail.selectedRows.forEach((b) => {
			fullSum = fullSum + b.invoiceAmount;
			billIds.push(b.billId);
		});

		this.details.statements.forEach((s) => {
			fullSum = fullSum + s.invoiceAmount;
		});

		this.details.fullSumSelectedItems = fullSum;
		this.details.selectedBills = billIds;
		console.log("@@@ Debug da variavel: billIds", JSON.parse(JSON.stringify(this.details)));
	}

	handleSimulation() {
		this.dispatchEvent(new CustomEvent("opensimulacao", { detail: this.details }));
	}

	handleItegrationFalse(event) {
		if (this.chamadaSemSucesso) this.template.querySelector('[data-id="chamadaSemSucesso"]').open();
	}
}