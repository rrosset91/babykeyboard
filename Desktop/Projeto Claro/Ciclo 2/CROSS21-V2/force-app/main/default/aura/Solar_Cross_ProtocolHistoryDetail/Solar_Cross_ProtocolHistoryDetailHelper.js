({
    changeTabIcon : function(component, event, helper) {
        //adicionado delay de 1seg pois a lógica abaixo pega o Id da tab que está selecionada. Sem o delay, o Id é pego antes da geração da nova tab, ou seja, é pego o Id da tab anterior, alterando assim o nome e o ícone da tab do caso.
        var delay=1000; 
        setTimeout(function() {
            var workspaceAPI = component.find("workspace");
            console.log('workspace ' + JSON.stringify(workspaceAPI));
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                console.log('focusedTabId ' + focusedTabId);
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:date_time",
                    iconAlt: "Approval"
                });
 
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Histórico de demandas"
                    });
                })
             })
            .catch(function(error) {
                console.log(error);
            });
         }, delay);
    },

    getDataFromApex : function(component, event, helper, startDate, endDate, status) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        
        component.set("v.recordId", recordId);
        console.log('####################### recordId ' + component.get("v.recordId"));
        var action = component.get("c.getHistory");
        action.setParams({  aRecordId : component.get("v.recordId"),
                            aStartDate : startDate,
                            aEndDate : endDate
        });

        var data = [];
        var completeHistoryData = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {

                var result = response.getReturnValue()
                console.log('result.dataFieldsLst ' + JSON.stringify(result.dataFieldsLst));
                console.log('result.StatusCode: ' + result.StatusCode);
                if(result.StatusCode == 200 || result.StatusCode == 201 ||  result.StatusCode == null ||  result.StatusCode == undefined){
                    component.set("v.dataLoadSucess", true);
                    //sucesso
                    if(result.dataFieldsLst == null || result.dataFieldsLst == undefined || result.dataFieldsLst.length == 0){
                        console.log('Empty Data History');
                    }
                    else{
                        for(var i = 0; i < result.dataFieldsLst.length; i++){                            
                            if(result.dataFieldsLst[i].EndDate == undefined || result.dataFieldsLst[i].EndDate == null || result.dataFieldsLst[i].EndDate == ''){
                                result.dataFieldsLst[i].Status = 'Aberto';
                            }
                            else{
                                result.dataFieldsLst[i].Status = 'Fechado';
                            }                          

                            if(status == 'Todos'){
                                data.push(result.dataFieldsLst[i]);
                            }
                            else if(status == result.dataFieldsLst[i].Status){
                                data.push(result.dataFieldsLst[i]);
                            }
                            
                            completeHistoryData.push(result.dataFieldsLst[i]);
                        }
                        component.set("v.data", data);
                        component.set("v.completeHistoryData",completeHistoryData);
                        // console.log('completeHistoryData first call ' + JSON.stringify(completeHistoryData));

                        component.set('v.staticBeginDate', startDate);
                        component.set('v.staticEndDate', endDate);
                    }
                }
                else if(result.StatusCode == 401 || result.StatusCode == 403){
                    //erro de autenticação
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Não foi possível trazer os protocolos');
                }
                else if(result.StatusCode == 408){
                    //erro de time out
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Tempo excedido ao tentar carregar os protocolos');
                }
                else{
                    //demais erros
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Erro ao carregar os protocolos');
                }       
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        if(errors[0].message == 'O período máximo permitido para consulta é de 6 meses' || errors[0].message == 'Data início não pode ser maior que a data fim'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": errors[0].message,
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                        console.log("Error message HistoryDetail: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
                        
            var dataLength = component.get("v.data");
            if(dataLength == null || dataLength == undefined || dataLength.length == 0){
                component.set("v.itemString", 'Nenhum item a ser exibido');
                component.set("v.itensNumber", null);
                
            }
            else if(dataLength.length == 0){
                component.set("v.itensNumber", dataLength.length);
                component.set("v.itemString", ' item');
            }
            else{
                component.set("v.itensNumber", dataLength.length);
                component.set("v.itemString", ' itens');
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    getDate : function(component, event, helper, subtractDays) {
        // Populando vigência com a data de hoje
        var today = new Date();
        today.setDate(today.getDate() - subtractDays);
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        today = yyyy + '-' + mm + '-' + dd;
        return today;
    },
    
    changeFilter : function(component, event, helper) {
        var completeHistoryData = component.get("v.completeHistoryData");
        
        if(completeHistoryData == null || completeHistoryData == undefined || completeHistoryData.length == 0) return;
        // console.log('completeHistoryData ' + JSON.stringify(completeHistoryData));
        component.set("v.isLoading", true);
        var filter = component.get("v.viewSelected");
        console.log('filter ' + filter);

        var ps8FilterToogle = component.get("v.ps8Filter");
        var netsmsFilterToogle = component.get("v.netsmsFilter");
        var solarFilterToogle = component.get("v.solarFilter");

        var data = [];
        for(var i = 0; i < completeHistoryData.length; i++){     
            console.log('completeHistoryData ' + JSON.stringify(completeHistoryData));           
            if((completeHistoryData[i].Base == 'PS8' && ps8FilterToogle == true) || (completeHistoryData[i].Base == 'NET SMS' && netsmsFilterToogle == true) || (completeHistoryData[i].Base == 'Solar' && solarFilterToogle == true)){
                if(filter == 'Todos'){
                    data.push(completeHistoryData[i]); 
                }
                else if(filter == 'Abertos'){
                    if(completeHistoryData[i].Status == 'Aberto' || completeHistoryData[i].Status == 'Open'){
                        data.push(completeHistoryData[i]);
                    }                
                }
                else{
                    if(completeHistoryData[i].Status == 'Fechado' || completeHistoryData[i].Status == 'Closed'){
                        data.push(completeHistoryData[i]);
                    }
                }
            }
        }
        component.set("v.data", data);
        component.set("v.isLoading", false);
    }, 

    openModal: function (component, event, helper) {
        var cmpTarget = component.find('DescriptionModal');
        var cmpBack = component.find('ModalDescription');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },

    closeModal: function (component, event, helper) {
        var cmpTarget = component.find('DescriptionModal');
        var cmpBack = component.find('ModalDescription');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },

    getOSAndOCFromApex : function(component, event, helper, requisition) {
		var action = component.get("c.getOCAndOS");
        action.setParams({ "aSolic" : JSON.stringify(requisition) });
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                console.log('OS and OC loaded successful!');
                var result = response.getReturnValue();
                if(result.listWorkOrder.length == 0 && result.listConfigOrder.length == 0){
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "OSs e OCs",
                        "type": "warning",
                        "message": "Nenhuma OS ou OC encontrada para essa Solicitação"
                    });
                    resultsToast.fire();
                    component.set("v.modalText", null);
                    component.set("v.modalTitle", null);
                }
                else{
                    console.log('OC And OS log: '+ JSON.stringify(result));
                    component.set('v.requisition', result)
                    this.openModal(component, event, helper);
                }
            } 
            else {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;

                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Erro ao tentar carregar as OSs e OCs. Entre em contato com o administrador do sistema",
                        "type": "error",
                        "message": message
                    });
                    resultsToast.fire();
                    component.set("v.modalText", null);
                    component.set("v.modalTitle", null);
                }                
            }
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    getMoreInfoFromApex : function(component, event, helper, protocolNumber) {
		var action = component.get("c.getMoreInfo");
        action.setParams({ "aProtocol" : protocolNumber});
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                console.log('PS8 Protocol More Info successful!');
                var result = response.getReturnValue();
                console.log('PS8 Protocol More Info ' + JSON.stringify(result));

                if(!result){ //cai nessa condição caso a API retorne qualquer código diferente de 200 e 201
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Erro ao tentar carregar as informações do Protocolo PS8. Entre em contato com o administrador do sistema",
                        "type": "error",
                        "message": message
                    });
                    resultsToast.fire();
                    component.set("v.ps8MoreInfo", null);
                }
                else if(!result.data.attendances || result.data.attendances.length == 0 || (!result.data.attendances[0].reasonCode1 && !result.data.attendances[0].reasonCode2 && !result.data.attendances[0].reasonCode3 && !result.data.attendances[0].reasonCode4 && !result.data.attendances[0].reasonCode5 && !result.data.attendances[0].memo)){
                    //Entra nessa condição caso a lista venha vazia, ou venha preenchida mas os campos que são usados no componente estajam todos vazios/nulos
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Protocolo PS8",
                        "type": "warning",
                        "message": "Nenhuma informação adicional para exibir"
                    });
                    resultsToast.fire();
                    component.set("v.ps8MoreInfo", null);
                }
                else{
                    component.set('v.ps8MoreInfo', result)
                    this.openModal(component, event, helper);
                }
            } 
            else {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    message = errors[0].message;

                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Erro ao tentar carregar as informações adicionais do Protocolo PS8. Entre em contato com o administrador do sistema",
                        "type": "error",
                        "message": message
                    });
                    resultsToast.fire();
                    component.set("v.ps8MoreInfo", null);
                }                
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
	}
})