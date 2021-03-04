({
	onClickFirst: function (component, event, helper) {
		const func = component.get("v.onClickFirst");

		if (func) $A.enqueueAction(func);
	},

	onClickSecond: function (component, event, helper) {
		const func = component.get("v.onClickSecond");

		if (func) $A.enqueueAction(func);
	},

	showPDF: function (component, event, helper) {
		const func = component.get("v.onClickPDF");

		if (func) $A.enqueueAction(func);
	},

	onClickCompare: function (component, event, helper) {
		const func = component.get("v.onClickCompare");

		if (func) $A.enqueueAction(func);
	}
});