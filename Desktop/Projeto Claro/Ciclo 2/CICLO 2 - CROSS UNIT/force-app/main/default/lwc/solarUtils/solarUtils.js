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
}