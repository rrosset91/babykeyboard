import { LightningElement, api } from "lwc";

export default class SolarExceptionContent extends LightningElement {
	@api
	showError = false;
	@api
	showEmpty = false;
	@api
	emptyMessage = "Nenhum registro encontrado.";
	@api
	errorMessage = "Falha ao carregar as informações.";
}