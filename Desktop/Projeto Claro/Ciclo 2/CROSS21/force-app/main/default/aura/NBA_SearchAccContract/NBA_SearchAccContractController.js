({
	doInit: function (component, event, helper) {
		var contractnumber = helper.getParameterUrl('c__contractnumber');
		component.set('v.contractNumber', contractnumber);
        var citycode = helper.getParameterUrl('c__citycode');
        component.set('v.cityCode', citycode);
        
        helper.getContractId(component, event, helper);
	}
})