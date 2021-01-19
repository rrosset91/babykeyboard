({
    getDataFromApex : function(component, event, helper, startDate, endDate) {
        var action = component.get("c.getHistory");
        action.setParams({  aRecordId : component.get("v.recordId"),
                            aStartDate : startDate,
                            aEndDate : endDate
        });
        var data = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('##################### HISTORY STATE ' + response.getState());
            console.log('##################### HISTORY RETURN ' + JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                var result = response.getReturnValue()
                console.log('result.dataFieldsLst ' + JSON.stringify(result.dataFieldsLst));
                console.log('result.StatusCode ' + result.StatusCode);
                if(result.StatusCode == 200 || result.StatusCode == 201 ||  result.StatusCode == null ||  result.StatusCode == undefined){
                    //sucesso
                    if(result.dataFieldsLst == null || result.dataFieldsLst == undefined || result.dataFieldsLst.length == 0){
                        console.log('Empty Data History');
                        component.set("v.emptyData", true);
                        component.set("v.errorMessage", 'Nenhuma demanda no histórico');
                    }
                    else{

                        for(var i = 0; i < result.dataFieldsLst.length; i++){

                            if(result.dataFieldsLst[i].EndDate == undefined || result.dataFieldsLst[i].EndDate == null || result.dataFieldsLst[i].EndDate == ''){
                                result.dataFieldsLst[i].Status = 'Aberto';
                            }
                            else{
                                result.dataFieldsLst[i].Status = 'Fechado';
                            }
                            // if(result.dataFieldsLst[i].Status != 'Fechado' && result.dataFieldsLst[i].Status != 'Closed'){
                            //     result.dataFieldsLst[i].Status = 'Aberto';
                            // }
                            // else if(result.dataFieldsLst[i].Status == 'Closed'){
                            //     result.dataFieldsLst[i].Status = 'Fechado';
                            // }
                            data.push(result.dataFieldsLst[i]);
                            if(data.length == 6){
                                break;
                            }
                        }
                        component.set("v.data", data);
                        component.set("v.completeHistoryData", result.dataFieldsLst);
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
                        console.log("Error message History: " + 
                                 errors[0].message);
                    }
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Erro ao carregar os protocolos');
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    changeFilter : function(component, event, helper) {
        var completeHistoryData = component.get("v.completeHistoryData");
        if(completeHistoryData == null || completeHistoryData == undefined || completeHistoryData.length == 0) return;
        component.set("v.isLoading", true);
        var filter = component.get("v.viewSelected");
        console.log('filter ' + filter);
        var data = [];
        if(filter == 'Todos'){
            for(var i = 0; i < completeHistoryData.length; i++){
                if(completeHistoryData[i].Status != 'Fechado' && completeHistoryData[i].Status != 'Closed'){
                    completeHistoryData[i].Status = 'Aberto';
                }
                else if(completeHistoryData[i].Status == 'Closed'){
                    completeHistoryData[i].Status = 'Fechado';
                }
                data.push(completeHistoryData[i]);
                if(data.length == 6){
                    break;
                }
            }
        }
        else if(filter == 'Abertos'){
            console.log('entrou');
            for(var i = 0; i < completeHistoryData.length; i++){
                console.log('teste ' + completeHistoryData[i].Status);
                // if(completeHistoryData[i] == undefined) continue;
                if(completeHistoryData[i].Status != 'Fechado' && completeHistoryData[i].Status != 'Closed'){
                    completeHistoryData[i].Status = 'Aberto';
                    data.push(completeHistoryData[i]);
                }                
                if(data.length == 6){
                    break;
                }
                console.log(JSON.stringify(data));
            }
        }
        else{
            for(var i = 0; i <  completeHistoryData.length; i++){
                if(completeHistoryData[i].Status == 'Fechado' || completeHistoryData[i].Status == 'Closed'){
                    completeHistoryData[i].Status = 'Fechado';
                    data.push(completeHistoryData[i]);
                }                
                if(data.length == 6){
                    break;
                }
            }
        }
        component.set("v.data", data);
        component.set("v.isLoading", false);
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
    }
})