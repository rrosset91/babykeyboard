/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 21-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   13-11-2020   Joao Neves   Initial Version
 **/

import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class SolarExceptionContent extends OmniscriptBaseMixin(LightningElement) {
	@api
	showError = false;
	@api
	showEmpty = false;
	@api
	emptyMessage = "Não há dados disponíveis nessa página.";
	@api
	errorMessage = "Ops, parece que algo deu errado. Por favor, tente novamente mais tarde.";
}