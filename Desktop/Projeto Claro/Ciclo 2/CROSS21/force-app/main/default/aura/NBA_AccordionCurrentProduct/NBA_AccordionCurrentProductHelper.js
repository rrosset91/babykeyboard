({
    const: {
        'TV': 'tv',
        'VIRTUA': 'virtua',
        'NETFONE': 'netfone',
        'NETMOVEL': 'netmovel'
    },

    getList: function (component, event, helper) {
        var CECFixo = [];
        var CECInternet = [];
        var CECMovel = [];
        var CECTV = [];
        var i;
        var action = component.get("c.lista");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                for (i = 0; i < response.getReturnValue().length; i++) {
                    if (!(response.getReturnValue()[i].RecordType == null || response.getReturnValue()[i].RecordType.DeveloperName == null || response.getReturnValue()[i].RecordType.DeveloperName === "" || response.getReturnValue()[i].RecordType.DeveloperName === undefined)) {
                        switch (response.getReturnValue()[i].RecordType.DeveloperName) {
                            case 'CECFixo':
                                CECFixo.push(response.getReturnValue()[i]);
                                component.set("v.NetFone", CECFixo);
                                component.set("v.isNetFoneVisible", true);
                                break;
                            case 'CECInternet':
                            case 'CECInternetFixa':
                                CECInternet.push(response.getReturnValue()[i]);
                                component.set("v.Virtua", CECInternet);
                                component.set("v.isVirtuaVisible", true);
                                break;
                            case 'CECMovel':
                            case "CECInternetMovel":
                            case "CECMovelPreControle":
                                CECMovel.push(response.getReturnValue()[i]);
                                component.set("v.Movel", CECMovel);
                                component.set("v.isMovelVisible", true);
                                break;
                            case 'CECTV':
                                CECTV.push(response.getReturnValue()[i]);
                                component.set("v.TV", CECTV);
                                component.set("v.isTVVisible", true);
                                break;
							default:
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})