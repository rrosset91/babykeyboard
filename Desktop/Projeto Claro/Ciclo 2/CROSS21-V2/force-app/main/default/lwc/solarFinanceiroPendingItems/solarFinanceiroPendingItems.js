import { LightningElement, api, track } from "lwc";
import invoicesPending from "@salesforce/apex/FinancialNegotiationInadimplente.getInvoicesPending";
import Utils from "c/solarUtils";
import { NavigationMixin } from "lightning/navigation";
//Ordenação
//Regras dos criterios de aceite

export default class SolarFinanceiroInadimplente extends NavigationMixin(LightningElement) {
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
	@track error;
	@track negotiationType;
	@track sortBy;
	@track sortDirection;
	@track negotiatonItems = [];
	@track
	sortBy;
	@track
	sortDirection;
	columns = [
		{ label: "TIPO", fieldName: "type", type: "text", cellAttributes: { alignment: "left" }, hideDefaultActions: true, sortable: "true" },
		{ label: "DATA VENCIMENTO", fieldName: "dataVencimento", type: "text", cellAttributes: { alignment: "left" }, hideDefaultActions: true, sortable: "true" },
		{
			label: "VALOR",
			fieldName: "invoiceAmount",
			type: "currency",
			cellAttributes: { alignment: "left" },
			typeAttributes: { currencyCode: "BRL", step: "0.01" },
			hideDefaultActions: true,
			sortable: "true"
		}
	];
	@track
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
	isLoading = false;

	connectedCallback() {
		console.clear();
		this.fetchDetailsInvoices();
	}

	async fetchDetailsInvoices() {
		this.isLoading = true;
		console.log("@@@ Debug da variavel: this.baseAttributes", JSON.parse(JSON.stringify(this.baseAttributes)));

		const data = await invoicesPending({ operatorCode: this.baseAttributes.operatorId, contractNumber: this.baseAttributes.contractId }).catch((err) => {
			console.log("@@@ Debug da variavel: err", JSON.parse(JSON.stringify(err)));

			this.hasData = false;
			this.hasError = true;

			const rawMessage = err.body.message;
			let msgError = err.body.message.toLowerCase();

			if (msgError.includes("o cliente não possui fatura aberta vencida.")) {
				msgError = "Realizar tratamento conforme procedimento de negociação";
			} else if (msgError.includes("prazo de carência não ultrapassado") || msgError.includes("operadora ou status do contrato não permitem renegociação.")) {
				msgError = "Acordo anterior não cumprido.";
			} else if (msgError.includes("a renegociação do cliente com alguma fatura ou contrato em sistema externo de cobrança, não está liberada.")) {
				msgError = "Realizar tratamento conforme procedimento de negociação.";
			} else {
				msgError = rawMessage;
			}

			this.errorMessage = msgError;
			this.template.querySelector("c-solar-modal").open();
		});

		if (this.hasError) return (this.isLoading = false);
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

				let rawDate = 0;
				if (bill.dueDate) rawDate = new Date(bill.dueDate[2], bill.dueDate[1], bill.dueDate[0]).getTime();

				this.details.bills.push({
					type: bill.type,
					dataVencimento: bill.dueDate,
					invoiceAmount: Number(bill.valueInvoice.replace(",", ".")),
					billId: bill.billId,
					isMandatory: bill.isMandatory,
					rawDate
				});

				console.log("@@@ Debug da variavel: bill.valueInvoice", JSON.parse(JSON.stringify(bill.valueInvoice)));
				console.log("@@@ Debug da variavel: bill.valueInvoice", JSON.parse(JSON.stringify(Number(bill.valueInvoice.replace(",", ".")))));

				if (bill.isMandatory) this.details.selectedBills.push(bill.billId);
			});

			invoice.statements.forEach((statement) => {
				this.details.statementsIdsString.push(statement.statementId);

				let rawDate = 0;
				if (statement.dueDate) rawDate = new Date(statement.dueDate[2], statement.dueDate[1], statement.dueDate[0]).getTime();

				this.details.statements.push({
					type: statement.type,
					dataVencimento: statement.dueDate,
					invoiceAmount: Number(statement.valueInvoice.replace(",", ".")),
					rawDate
				});
			});
		});

		this.handleRowSelection(null, true);

		this.isLoading = false;

		console.log("@@@ Debug da variavel: this.details", JSON.parse(JSON.stringify(this.details)));
		return null;
	}

	handleSortData(event, table) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;

		let sortField = this.sortBy;
		if (this.sortBy === "dataVencimento") sortField = "rawDate";

		let data = table === "bills" ? this.details.bills : this.details.statements;

		data = Utils.sortData(sortField, this.sortDirection, data);

		if (table === "bills") {
			this.details.bills = data;
		} else {
			this.details.statements = data;
		}
	}

	handleClose() {
		this.template.querySelector("c-solar-modal").close();
		this.closeTab();
	}

	closeTab() {
		this.invokeWorkspaceAPI("isConsoleNavigation").then((isConsole) => {
			if (isConsole) {
				this.invokeWorkspaceAPI("getFocusedTabInfo").then((focusedTab) => {
					this.invokeWorkspaceAPI("closeTab", {
						tabId: focusedTab.tabId
					}).then((tabId) => {
						console.log("Tab fechada :", tabId);
					});
				});
			}
		});
	}

	invokeWorkspaceAPI(methodName, methodArgs) {
		return new Promise((resolve, reject) => {
			const apiEvent = new CustomEvent("internalapievent", {
				bubbles: true,
				composed: true,
				cancelable: false,
				detail: {
					category: "workspaceAPI",
					methodName: methodName,
					methodArgs: methodArgs,
					callback: (err, response) => {
						if (err) {
							return reject(err);
						} else {
							return resolve(response);
						}
					}
				}
			});
			window.dispatchEvent(apiEvent);
		});
	}

	handleRowSelection(event, renderCall) {
		let billIds = [];
		let fullSum = 0;

		let iterationList = [];
		if (renderCall) {
			console.log("renderCall");
			this.details.bills.forEach((b) => {
				if (b.isMandatory) iterationList.push(b);
			});
		} else {
			iterationList = event.detail.selectedRows;
		}

		iterationList.forEach((b) => {
			fullSum = fullSum + b.invoiceAmount;
			billIds.push(b.billId);
		});

		this.details.statements.forEach((s) => {
			fullSum = fullSum + s.invoiceAmount;
		});

		this.details.fullSumSelectedItems = fullSum;
		this.details.fullSumFormattedBrl = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 2, minimumFractionDigits: 2, style: "currency", currency: "BRL" }).format(fullSum);
		this.details.selectedBills = billIds;

		let disabledButton = false;
		this.details.bills.forEach((b) => {
			if (b.isMandatory) if (!this.details.selectedBills.includes(b.billId)) disabledButton = true;
		});
		this.buttonSimulation = this.details.selectedBills.length === 0 ? true : disabledButton;

		console.log("@@@ Debug da variavel: billIds", JSON.parse(JSON.stringify(this.details)));
	}

	handleSimulation() {
		this.dispatchEvent(new CustomEvent("opensimulacao", { detail: this.details }));
	}
}