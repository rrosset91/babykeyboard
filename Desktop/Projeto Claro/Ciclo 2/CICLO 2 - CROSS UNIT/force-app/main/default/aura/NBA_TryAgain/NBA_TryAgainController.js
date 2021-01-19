({
	setTimeout: function (component, event, helper) {

		var count =  localStorage["TryCount"];

		if (!count) {
			localStorage["TryCount"] = 1;
		}

		component.set("v.showTryAgain", false);
		component.set("v.isTimeout", true);
		component.set("v.countTimeout", localStorage["TryCount"]);
	},

	closeModal: function (component, event, helper) {
		//location.reload();
		component.set("v.showTryAgain", false);
	}
})