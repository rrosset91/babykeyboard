({
    doInit: function (component, helper) {
        component.set('v.columns', [
            { label: 'Nome', fieldName: 'Name', type: 'Text' },
            { label: 'Saldo', fieldName: 'SaldoExtrato__c', type: 'text' }
        ]);
        
        var actGetSObject = component.get("c.getSObject");
        actGetSObject.setParams({
            recordId: component.get("v.recordId"),
            sObjectName: "Asset"
        });
        
        actGetSObject.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.record", response.getReturnValue());
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(actGetSObject);
    },
    
    showDeviceButton: function(component,helper){
        var actGetSObject = component.get("c.getRecordType");
        actGetSObject.setParams({
            recordId: component.get("v.recordId"),
        });
        
        actGetSObject.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showButtonDevice",response.getReturnValue());
            }
        });
        $A.enqueueAction(actGetSObject);
    },
    
    showAdditionalButton: function(component, helper) {
        var action = component.get("c.getBusinessUnit");
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Net') {
                    component.set("v.showAdditional", true);
                } else {
                    component.set("v.showAdditional", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    loadBalance: function (component, helper) {
        component.set("v.showSpinnerSaldos", true);
        var action = component.get("c.getBalance");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                component.set("v.showSpinnerSaldos", false);
                if (retorno != null) {
                    component.set('v.balance', retorno);
                } else {
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinnerSaldos", false);
                toastEvent.setParams({
                    "title": "Erro",
                    "type": "Error",
                    "message": 'Não foi possível encontrar registros.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getTransactionsLast: function (component, helper) {
        component.set('v.paginationList', null);
        component.set("v.showSpinner", true);
        var pageSize = component.get("v.pageSize");
        var id_msisdn = component.get("v.recordId");
        var action = component.get("c.getTransactionsLast");
        action.setParams({ "recordId": id_msisdn });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var retorno;
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                component.set("v.showTable", true);
                retorno = response.getReturnValue();
                if (retorno.data != null) {
                    component.set("v.dataTransactions", retorno.data.events);
                    component.set("v.totalSize", component.get("v.dataTransactions").length - 1);
                    component.set("v.start", 0);
                    component.set("v.end", pageSize - 1);
                    
                    if (component.get("v.dataTransactions").length < 5) {
                        pageSize = component.get("v.dataTransactions").length;
                    }
                    
                    var paginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        console.log(retorno.data.events[i]);
                        paginationList.push(retorno.data.events[i]);
                    }
                    console.log(JSON.stringify(paginationList));
                    component.set('v.paginationList', paginationList);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não há eventos tarifados nos últimos 15 dias.'
                    });
                    toastEvent.fire();
                    component.set("v.showTable", false);
                    component.set('v.dataTransactions', null);
                    component.set('v.paginationList', null);
                    component.set('v.end', 0);
                    component.set('v.totalSize', 0);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getTransactionsPeriod: function (component, helper) {
        component.set('v.paginationList', null);
        component.set("v.showSpinner", true);
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getTransactionsPeriod");
        
        action.setParams({
            recordId: component.get("v.recordId"),
            dateStart: component.get("v.dataStartValue"),
            dateEnd: component.get("v.dataEndValue"),
            tipo: component.get("v.tipoValue"),
            subTipo: component.get("v.subTipoValue")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var retorno;
            if (state === "SUCCESS") {
                component.set("v.showSpinner", false);
                component.set("v.showTable", true);
                retorno = response.getReturnValue();
                if (retorno.data != null) {
                    component.set("v.dataTransactions", retorno.data.events);
                    component.set("v.totalSize", component.get("v.dataTransactions").length - 1);
                    component.set("v.start", 0);
                    component.set("v.end", pageSize - 1);
                    
                    if (component.get("v.dataTransactions").length < 5) {
                        pageSize = component.get("v.dataTransactions").length;
                    }
                    
                    var paginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        paginationList.push(retorno.data.events[i]);
                    }
                    
                    component.set('v.paginationList', paginationList);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                    component.set("v.showTable", false);
                    component.set('v.dataTransactions', null);
                    component.set('v.paginationList', null);
                    component.set('v.end', 0);
                    component.set('v.totalSize', 0);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    validateField: function (component, helper) {
        var startDate = component.get("v.dataStartValue");
        var endDate = component.get("v.dataEndValue");
        var toastEvent = $A.get("e.force:showToast");
        
        if (!startDate || !endDate) {
            toastEvent.setParams({
                "title": "Erro",
                "type": "Error",
                "message": 'Por favor, preencher os dois campos obrigatórios de data.'
            });
            toastEvent.fire();
            return false;
        }
        
        var date1 = new Date(startDate);
        var date2 = new Date(endDate);
        var timeDiff = Math.abs(date2.getTime() - date1.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
        var today = new Date();
        var diffYears = (today.getTime() - date1.getTime()) / 1000;
        diffYears /= (60 * 60 * 24);
        diffYears = Math.abs(Math.round(diffYears / 365.25));
        
        if (diffYears > 3) {
            toastEvent.setParams({
                "title": "Erro",
                "type": "Error",
                "message": 'A data início não pode ser anterior há 3 anos.'
            });
            toastEvent.fire();
            return false;
        }
        
        if (diffDays > 90) {
            toastEvent.setParams({
                "title": "Erro",
                "type": "Error",
                "message": 'A diferença entre as datas não pode ser maior que 90 dias.'
            });
            toastEvent.fire();
            return false;
        }
        return true;
    },
    
    loadOtherBalances: function (component, helper) {
        component.set("v.showSpinnerSaldos", true);
        var id_msisdn = component.get("v.recordId");
        var action = component.get("c.getOtherBalances");
        action.setParams({ "recordId": id_msisdn });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                component.set("v.showSpinnerSaldos", false);
                if (retorno != null) {
                    component.set('v.dataAccumulators', retorno);
                } else {
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinnerSaldos", false);
                toastEvent.setParams({
                    "title": "Erro",
                    "type": "Error",
                    "message": 'Não foi possível encontrar registros.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    loadOtherBalancesPromotional: function (component, helper) {
        component.set("v.showSpinnerSaldos", true);
        var id_msisdn = component.get("v.recordId");
        var action = component.get("c.getOtherBalancesPromotional");
        action.setParams({ "recordId": id_msisdn });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                component.set("v.showSpinnerSaldos", false);
                if (retorno != null) {
                    component.set('v.dataPromotional', retorno);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível encontrar registros.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinnerSaldos", false);
                toastEvent.setParams({
                    "title": "Erro",
                    "type": "Error",
                    "message": 'Não foi possível encontrar registros.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    showModalDevice: function (component, event, helper) {
        component.set("v.showSpinner1", true);
        var id = component.get("v.recordId");
        var action = component.get("c.getDevice");
        action.setParams({ "recordId": id });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var retorno;
            if (state === "SUCCESS") {
                retorno = response.getReturnValue();
                if (retorno != null) {
                    helper.modalDeviceCall(component, event, helper, retorno);
                    component.set("v.showSpinner1", false);
                } else {
                    component.set("v.showSpinner1", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "type": "Error",
                        "message": 'Não foi possível obter as informações do aparelho.'
                    });
                    toastEvent.fire();
                }
            } else {
                component.set("v.showSpinner1", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro",
                    "type": "Error",
                    "message": 'Não foi possível obter as informações do aparelho.'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    modalDeviceCall: function (component, event, helper, retorno) {
        var modalBody;
        component.set("v.device", retorno);
        $A.createComponent("c:CEC_360_Gadget", {
            recordId: component.get('v.recordId'),
            deviceList: component.get('v.device')
        },
                           function (content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       body: modalBody,
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       closeCallback: function () {
                                       }
                                   })
                               }
                           });
    }
    
})