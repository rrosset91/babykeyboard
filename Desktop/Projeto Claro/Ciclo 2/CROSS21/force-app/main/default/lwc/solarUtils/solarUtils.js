/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 20-01-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   04-11-2020   Joao Neves   Initial Version
 **/
import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class SolarAcessarFicha extends LightningElement {
	static showToast(context, severity, title, message) {
		//Severity = info, warning, success, error
		const evt = new ShowToastEvent({
			title: title,
			message: message,
			variant: severity,
			mode: "dismissable"
		});
		context.dispatchEvent(evt);
	}

	static isEmptyString(content) {
		return content == null || content === undefined || content === "";
	}

	static isEmptyArray(content) {
		return content == null || content === undefined || content.length === 0;
	}

	static sortData(fieldname, direction, data) {
		let parseData = JSON.parse(JSON.stringify(data));
		console.log(parseData + " DIOGO");
		console.log("sortData: parseData", parseData);

		let keyValue = (a) => {
			return a[fieldname];
		};

		let isReverse = direction === "asc" ? 1 : -1;

		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : "";
			y = keyValue(y) ? keyValue(y) : "";

			return isReverse * ((x > y) - (y > x));
		});

		data = parseData;
		return data;
	}

	static getMonthName(dt) {
		return dt.toLocaleString("pt-BR", { month: "long" });
	}
	static getPtBrMonthName(monthNumber) {
		switch (monthNumber) {
			case "01":
				return "Janeiro";
			case "02":
				return "Fevereiro";
			case "03":
				return "Março";
			case "04":
				return "Abril";
			case "05":
				return "Maio";
			case "06":
				return "Junho";
			case "07":
				return "Julho";
			case "08":
				return "Agosto";
			case "09":
				return "Setembro";
			case "10":
				return "Outubro";
			case "11":
				return "Novembro";
			case "12":
				return "Dezembro";
			default:
				break;
		}
	}
	static jsonLogger(value) {
		return JSON.parse(JSON.stringify(value));
	}
}
