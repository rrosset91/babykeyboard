({
    onInit : function(component,event,helper){
        
        component.set("v.noRecordFoundMsg","Buscando registros de consentimento...");
        
        // Setting column information.To make a column sortable,set sortable as true on component load
        /*var sample = [{protocol:"123456",  channel:"Digital",   name:"Formação de perfil do cliente",            date:"01/05/2020",status:"Autorizado",CloseDate:"15/05/2020"},
                      {protocol:"7778990", channel:"Digital",   name:"Uso de geolocalização",                    date:"01/05/2020",status:"Autorizado",CloseDate:"15/05/2020"},
                      {protocol:"235435",  channel:"Salesforce",name:"Aplicativos, produtos e serviços infantis",date:"01/05/2020",status:"Autorizado",CloseDate:"15/05/2020"},
                      {protocol:"65454567",channel:"Salesforce",name:"Formação de perfil do cliente",            date:"10/11/2019",status:"Autorizado",CloseDate:"25/11/2019"},
                      {protocol:"6786969", channel:"Digital",   name:"Uso de geolocalização",                    date:"10/11/2019",status:"Não Autorizado",CloseDate:"25/11/2019"},
                      {protocol:"745463",  channel:"Salesforce",name:"Aplicativos, produtos e serviços infantis",date:"10/11/2019",status:"Não Autorizado",CloseDate:"25/11/2019"},
                      {protocol:"732663",  channel:"Digital",   name:"Formação de perfil do cliente",            date:"19/07/2018",status:"Autorizado",CloseDate:"27/07/2018"},
                      {protocol:"436373",  channel:"Digital",   name:"Uso de geolocalização",                    date:"19/07/2018",status:"Autorizado",CloseDate:"27/07/2018"},
                      {protocol:"346356",  channel:"Salesforce",name:"Aplicativos, produtos e serviços infantis",date:"19/07/2018",status:"Autorizado",CloseDate:"27/07/2018"},
                      {protocol:"1045646", channel:"Digital",   name:"Formação de perfil do cliente",            date:"10/04/2017",status:"Não Autorizado",CloseDate:"30/04/2017"},
                      {protocol:"116456",  channel:"Salesforce",name:"Uso de geolocalização",                    date:"10/04/2017",status:"Não Autorizado",CloseDate:"30/04/2017"},
                      {protocol:"411225",  channel:"Salesforce",name:"Aplicativos, produtos e serviços infantis",date:"10/04/2017",status:"Não Autorizado",CloseDate:"30/04/2017"}
                     ];*/
        
        component.set("v.consentsColumns",[{type:"text",label:"Protocolo", fieldName:"protocol", sortable: true},
                                           {type:"text",label:"Canal",     fieldName:"channel",  sortable: true},
                                           {type:"text",label:"Finalidade",fieldName:"name",     sortable: true},
                                           {type:"text",label:"Status",    fieldName:"status",   sortable: true},
                                           {type:"text",label:"Data/hora", fieldName:"consentCreationDate",     sortable: true}]);
        
        var action = component.get("c.getConsentsHistory");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state: ' + state);
            if(state === "SUCCESS") {
                if(response.getReturnValue().data != null){
                    component.set("v.noRecordFoundMsg",null);
                    var sample = JSON.parse(JSON.stringify(response.getReturnValue().data));
                    console.log('sample', sample);
                    var tableData = [];
                    for (var data in sample) {
                        for (var record in sample[data].agreements) {
                            var registro = sample[data].agreements[record];
                            if(registro.name != null){
                                if(sample[data].notes != null){
                                    var reason = JSON.parse(sample[data].notes).Reason.split('|')
                                    registro.protocol = reason[0];
                                    registro.channel = reason[1];
                                }
                                if(registro.options && registro.options.length > 0 && registro.options[0].label == 'Sim'){
                                    registro.status = 'Autorizado';
                                }
                                else {
                                    registro.status = 'Não Autorizado';
                                }
                                if(sample[data].consentCreationDate != null){                                 
								    registro.originalDate = new Date(sample[data].consentCreationDate);
									var diffUTC =registro.originalDate.getUTCHours() - registro.originalDate.getHours();
                                    registro.timestamp = registro.originalDate.setHours(registro.originalDate.getHours() - diffUTC);
                                    registro.consentCreationDate = registro.originalDate.toLocaleString();
                                }
                                tableData.push(registro);

                            }
                        }
                    }
                    console.log('tableData', tableData);
                    component.set("v.consentsData",tableData);
                	component.set("v.filteredData",tableData);
                	// component.set("v.consentsData",sample[0].agreements);
                	// component.set("v.filteredData",sample[0].agreements);
                	// console.log("SUCCESS" + sample[0].agreements);
                    
                } else{
                    component.set('v.consentsData',null);
                	component.set("v.filteredData",null);
                	component.set("v.noRecordFoundMsg",'Nenhum registro de consentimento encontrado.');
                }
            } else {
                component.set('v.consentsData',null);
                component.set("v.filteredData",null);
                component.set("v.noRecordFoundMsg",null);
                console.log("----->>>>> ERROR");
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        // call helper function to fetch consents data from apex
        //component.set("v.consentsData",sample);
        //component.set("v.filteredData", sample);
    },
    
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        // if(sortBy == 'consentCreationDate'){
        //     sortBy = 'timestamp';
        // }
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
    
    filter: function(component, event, helper) {
        var data = component.get("v.consentsData"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.name)  
                                  || (row.status != null && regex.test(row.status.toString()))
                                  || (row.protocol != null && regex.test(row.protocol.toString()))
                                  || (row.channel != null && regex.test(row.channel.toString()))
                                  || (row.consentCreationDate != null && regex.test(row.consentCreationDate.toString()))
                                 );
        } catch(e) {
            // invalid regex, use full list
            console.log('exception', e);
        }
        component.set("v.filteredData", results);
    },

    handleReload : function(component, event, helper) {
        var a = component.get('c.onInit');
        $A.enqueueAction(a);
    },
    
})