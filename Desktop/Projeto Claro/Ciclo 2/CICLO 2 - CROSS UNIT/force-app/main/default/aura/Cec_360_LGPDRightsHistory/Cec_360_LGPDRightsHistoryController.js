({
    
    onInit : function(component,event,helper){
 
        var action = component.get("c.getOrdersRightsHistory");
        
       // var columnsButtonExtract = '';
                   var columns = [{type:"text",label:"Protocolo",fieldName:"protocolnumber",sortable: false},
                           { type: 'text', label: 'Data da Criação',  fieldName: 'orderDate', sortable: true },
                           {type:"text",label:"E-mail",fieldName:"email",sortable: true},
                           {type:"text",label:"Tipo de Solitação",fieldName:"orderType",sortable: true},
                           {type:"text",label:"Status",fieldName:"status",sortable: true},
                           {type:"text",label:"Data do fechamento",fieldName:"completionDate", sortable: true},
                           {type: "button", typeAttributes: {
                               label: 'Visualizar',
                               name: 'viewDetails',
                               title: 'viewDetails',
                               disabled: false,
                               value: 'viewDetails',
                               iconPosition: 'left'
                           }, label:"Detalhes da Solicitação"}
                          ];
        component.set("v.columns",columns); 
       
              //verify permisson to Extract
        var actionProfile = component.get("c.getPermissonToExtract");
        actionProfile.setCallback(this, function(response) {

            
            var permisson =  response.getReturnValue();
            if( permisson == true ) {
            var  columns = [{type:"text",label:"Protocolo",fieldName:"protocolnumber",sortable: false},
                            { type: 'text', label: 'Data da Criação',  fieldName: 'orderDate', sortable: true },
                            {type:"text",label:"E-mail",fieldName:"email",sortable: true},
                            {type:"text",label:"Tipo de Solitação",fieldName:"orderType",sortable: true},
                            {type:"text",label:"Status",fieldName:"status",sortable: true},
                            {type:"text",label:"Data do fechamento",fieldName:"completionDate", sortable: true},
                            {type: "button", typeAttributes: {
                                             label: 'Visualizar',
                                             name: 'viewDetails',
                                             title: 'viewDetails',
                                             disabled: false,
                                             value: 'viewDetails',
                                             iconPosition: 'left'
                                  }, label:"Detalhes da Solicitação"},
                           {type: "button", typeAttributes: {
                                            label: 'Visualizar',
                                            name: 'viewExtract',
                                            title: 'viewExtract',
                                            disabled: { fieldName: 'extractAvailable'},
                                            value: 'viewExtract',
                                            iconPosition: 'left',
                                            class: 'btn_next'
                                            }, label:"Extrato"}] ;
           component.set("v.columns",columns);                        
            };        
        });
        $A.enqueueAction(actionProfile);
         
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") { 
                var sample = JSON.parse(JSON.stringify(response.getReturnValue().customerOrders));
                if(sample.length > 0){
               //alert(sample);
                

                component.set("v.historicData",sample);
               component.set("v.filteredData",sample);
                //alert(tableData);
                console.log("SUCCESS" + sample); 
                } else {
                 //   alert("entrei"); 
                    component.set('v.historicData',null);
                    component.set("v.filteredData",null);
                    component.set("v.noRecordFoundMsg",'Nenhum registro de consentimento encontrado.');
                }
            } else {component.set("v.noRecordFoundMsg",'Error de Conexão da API');
                   }
            
        });
   
        $A.enqueueAction(action);
    },
    
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
       filter: function(component, event, helper) {
        var data = component.get("v.historicData"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.id) 
                                  || regex.test(row.email) 
                                  || regex.test(row.orderType)  
                                  || regex.test(row.status) 
                                  || regex.test(row.completionDate)
                                  || regex.test(row.completionDate)
                                  
                                 );
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.filteredData", results);
    },
   
   
   viewRecord : function(component, event, helper) {
        var row = event.getParam('action').name;
        var rec = event.getParam('row');

      

       
       if ( row == 'viewDetails') {
 // Set isModalOpen attribute to true
   var action = component.get("c.getOrdersDetailsRightsHistory");
           action.setParams({
            recordId: rec.id
           
        });
     
        action.setCallback(this, function (response) {
            //var state = JSON.stringify(response.getReturnValue().data.formField35);
            var channel = JSON.parse(JSON.stringify(response.getReturnValue().data.formField29));
            if (response.getReturnValue().data.requestDetails != null){
            var details = JSON.parse(JSON.stringify(response.getReturnValue().data.requestDetails));
            
                component.set("v.details", details);
            }
            //var state = JSON.parse(JSON.stringify(response.getReturnValue().data));
            component.set("v.channel", channel);
          
          
           
        });
      
      $A.enqueueAction(action);
      
      component.set("v.isModalDetails", true);
       
        }
       if ( row == 'viewExtract') {
              var action = component.get("c.getExtractRightsHistory");
           action.setParams({
            recordId: rec.id
           
        });
              action.setCallback(this, function (response) {
            //var state = JSON.stringify(response.getReturnValue().data.formField35);
            var dataExtract = JSON.parse(JSON.stringify(response.getReturnValue().data.dataDiscoveryResultsV2Dtos.content));
               //  alert(dataExtract);
                  component.set("v.dataExtract", dataExtract);
  


        });
           var columnsExtract = [{type:"text",fieldName:"fieldName",cellAttributes: { alignment: 'right', class: 'Extract' }},
                          { type: 'text',  fieldName: 'value'} ];
          // var dataExtract = [{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"Claro combo",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"},{fieldName:"BANDA LARGA",value:"Sim"} ];
           component.set("v.columnsExtract", columnsExtract);
            $A.enqueueAction(action);
           component.set("v.isModalExtract", true);
       }
    },
   
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalDetails", false);
       component.set("v.isModalExtract", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isModalDetails", false);
       component.set("v.isModalExtract", false);
   },
     // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    handleReload : function(component, event, helper) {
        var a = component.get('c.onInit');
        $A.enqueueAction(a);
    }
    
})