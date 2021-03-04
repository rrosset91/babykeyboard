/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   04-11-2020   Joao Neves   Initial Version
 **/
import { LightningElement, api } from "lwc";


export default class SolarFaturaHeader extends LightningElement {
	@api
	header = "N/A";
	@api
	vencimento = "N/A";
	@api
	valor = "N/A";
	@api
	status = "N/A";
	@api
	formaPagamento = "N/A";
	@api
	modoEnvio = "N/A";
	@api
	enderecoCobranca = "N/A";
	@api
	numerocaso = "N/A";
	@api
	tipocaso = "N/A";
	@api
	layoutn2 = false;

}