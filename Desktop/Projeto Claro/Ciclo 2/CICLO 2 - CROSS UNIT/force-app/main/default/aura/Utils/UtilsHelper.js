({
    showToast : function(title, message, type, duration) {
		title = title || '';
		message = message || '';
		type = type || 'error';
		duration = duration || 2000;

		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title,
			message,
			type,
			duration
		});
		toastEvent.fire();
	},

	sortData : function(fieldName, direction, list){
		const reverse = direction != 'asc';

		if(!list)
			return list;

		list.sort((x, y) => {
            if (!x[fieldName] && y[fieldName])
                return reverse ? 1 : -1;

            if (x[fieldName] && !y[fieldName])
                return reverse ? -1 : 1;

            if (x[fieldName] > y[fieldName])
                return reverse ? -1 : 1;

            if (x[fieldName] == y[fieldName])
                return 0;

            if (x[fieldName] < y[fieldName])
                return reverse ? 1 : -1;
        });

		return list;
	},
	
})