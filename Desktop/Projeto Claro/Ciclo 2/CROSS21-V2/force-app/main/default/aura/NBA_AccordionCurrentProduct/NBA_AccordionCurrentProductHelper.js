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
                var assets = response.getReturnValue();
                for (i = 0; i < assets.length; i++) {
                    if (assets[i].RecordType!=null && assets[i].RecordType.DeveloperName!=null) {
                        switch (assets[i].RecordType.DeveloperName) {
                            case 'CECFixo':
                                CECFixo.push(assets[i]);
                                break;
                            case 'CECInternet':
                            case 'CECInternetFixa':
                                CECInternet.push(assets[i]);
                                break;
                            case 'CECMovel':
                            case "CECInternetMovel":
                            case "CECMovelPreControle":
                                CECMovel.push(assets[i]);
                                break;
                            case 'CECTV':
                                CECTV.push(assets[i]);
                                break;
							default:
                        }
                    }
                }
                if (CECFixo.length>0){
                    component.set("v.NetFone", CECFixo);
                    component.set("v.isNetFoneVisible", true);
            }
                if (CECInternet.length>0){
                    component.set("v.Virtua", CECInternet);
                    component.set("v.isVirtuaVisible", true);
                }
                if (CECMovel.length>0){
                    component.set("v.Movel", CECMovel);
                    component.set("v.isMovelVisible", true);
                }
                if (CECTV.length>0){
                    component.set("v.TV", CECTV);
                    component.set("v.isTVVisible", true);
                }
        
            }

        });
        $A.enqueueAction(action);
    }
})