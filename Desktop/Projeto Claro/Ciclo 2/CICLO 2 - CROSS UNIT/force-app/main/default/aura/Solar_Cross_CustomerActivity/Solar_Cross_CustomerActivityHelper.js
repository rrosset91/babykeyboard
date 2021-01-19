({
    getDataFromApex : function(component, event, helper) {
        
        var action = component.get("c.getActivity");
        action.setParams({  aRecordId : component.get("v.recordId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('##################### ACTIVITY STATE ' + response.getState());
            console.log('##################### ACTIVITY RETURN ' + JSON.stringify(response.getReturnValue()));

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.StatusCode == 200 || result.StatusCode == 201 ||  result.StatusCode == null ||  result.StatusCode == undefined){
                    //sucesso
                    if(result.ContactFrequency == 0){
                        console.log('Empty Data History');
                        component.set("v.emptyData", true);
                        component.set("v.errorMessage", 'Nenhum histórico de atividade.');                        
                    }
                    else{
                        component.set("v.data", result);
                        var daysBetweenToday;
                        if(result.LastContactBetween > 1){
                            daysBetweenToday = ' -- há ' + result.LastContactBetween + ' dias'
                            component.set("v.dayMessageString", daysBetweenToday);
                        }
                        else if(result.LastContactBetween == 1){
                            daysBetweenToday = ' -- há ' + result.LastContactBetween + ' dia'
                            component.set("v.dayMessageString", daysBetweenToday);
                        }
                        else if(result.LastContactBetween == 0){
                            daysBetweenToday = ' -- (hoje)'
                            component.set("v.dayMessageString", daysBetweenToday);
                        }
                        else{
                            component.set("v.dayMessageString", '');
                        }

                        var frequenceString;
                        if(result.ContactFrequency > 1){
                            frequenceString = result.ContactFrequency + ' registros nos últimos 30 dias'
                            component.set("v.frequenceString", frequenceString);
                        }
                        else if(result.ContactFrequency == 1){
                            frequenceString = result.ContactFrequency + ' registro nos últimos 30 dias'
                            component.set("v.frequenceString", frequenceString);
                        }
                        else if(result.ContactFrequency == 0){
                            frequenceString = 'nenhum registro nos últimos 30 dias'
                            component.set("v.frequenceString", frequenceString);
                        }    
                        
                        console.log('LastContact ----------------------> ' + result.LastContact);
                        console.log('result.LastContactBetween ----------------------> ' + result.LastContactBetween);
                    }
                }
                else if(result.StatusCode == 401 || result.StatusCode == 403){
                    //erro de autenticação
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Não foi possível trazer as atividades');
                }
                else if(result.StatusCode == 408){
                    //erro de time out
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Tempo excedido ao tentar carregar as atividades');
                }
                else{
                    //demais erros
                    component.set("v.dataLoadSucess", false);
                    component.set("v.errorMessage", 'Erro ao carregar as atividades');
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
                    component.set("v.errorMessage", 'Erro ao carregar as atividades');
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
})