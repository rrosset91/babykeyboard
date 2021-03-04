({
    doInit : function(component, event, helper) {       
        helper.getContractsActiveAsset(component, event, helper);
        helper.getRecordtype(component,event,helper);
        helper.getContactPrimary(component,event,helper);
        helper.getCriticalChannels(component, event, helper);
    },


    openDetailPage: function(component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.getAttribute("data-id");
        navEvt.setParams({
          recordId: id
        });
    
        navEvt.fire();
      },

    onChange : function(component, event, helper) 
    {      
      let recordTypeLabel = event.getSource().get("v.name");
      component.set('v.selectedRecordTypeName', recordTypeLabel); 

      let idRecordtype = event.getSource().get("v.text");
      component.set('v.selectedRecordType', idRecordtype);
      
    },

    createNewCaseAsset: function(component, event, helper)
    {
        let action = component.get("c.getRecordTypeLabel");
        let recordTypeLabel = component.get('v.selectedRecordTypeName'); 
        let idAsset = event.target.getAttribute("data-id"); 
    
          
        
        action.setParams
        ({
            "recordTypeLabel": recordTypeLabel
        });

        action.setCallback(this, function(response)
        {
            let state = response.getState();
            if (state === "SUCCESS")
            {
            let createEvent = $A.get("e.force:createRecord");
            let RecTypeID  = response.getReturnValue(); 
                            
            createEvent.setParams
            ({
                "entityApiName": 'Case',
                "recordTypeId" :  RecTypeID,  
                
                'defaultFieldValues': 
                {
                    "OwnerId": component.get("v.userId"),
                    "AccountId" : component.get("v.recordId"),
                    "LineNumber__c" : component.get("v.idAsset"),                     
                    "ContactId" :  component.get("v.idContact")                                  
                },            
            });        
            createEvent.fire();             
            component.set("v.isOpen", false);
                
            } else if (state == "INCOMPLETE")
            {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Oops!",
                "message": "No Internet Connection"
            });
            toastEvent.fire();

            } else if (state == "ERROR")
            {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please contact your administrator"
            });
            toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    openModal: function(component, event, helper)
    {  
     let Assetid = event.target.getAttribute("data-id");     
     component.set("v.idAsset", Assetid);
      let action = component.get("c.getProfileSupervisorOrRepresentatives");     
      action.setCallback(this, function(response)
      {
          let state = response.getState();
          if(state === "SUCCESS")
          {
              let result = response.getReturnValue();             

              if(result === 'Representantes Ilha de Input' || result === 'Supervisor Gov')
              { 
               
               let createEvent = $A.get("e.force:createRecord");

               createEvent.setParams
               ({
                  "entityApiName": 'Case',
                  'defaultFieldValues': 
                  {
                        "OwnerId": component.get("v.userId"),
                        "AccountId" : component.get("v.recordId"),
                        "LineNumber__c" : component.get("v.idAsset"),
                        "ContactId" :  component.get("v.idContact")
                  },            
               });        
               createEvent.fire(); 
            }
              else
              {
                 component.set("v.isOpen", true);
              }
          }
          else if(state === "ERROR" || state === "INCOMPLETE")
          {
              let errors = response.getError();
              let customMessagemErro;
              if (errors && errors[0] && errors[0].message)
              {                   
                  customMessagemErro = errors[0].message;
              }
          }
      });	
      $A.enqueueAction(action);      
    },

    closeModal: function(component, event, helper)
    {
       component.set("v.isOpen", false);
    },    
    collapseRelatedCasesByAssetTable: function(component, event, helper){
        let tableToToggle = document.getElementById(event.target.dataset.relatedCases);
  
        if(tableToToggle.dataset.originalHeight == undefined){
           tableToToggle.dataset.originalHeight = tableToToggle.offsetHeight;
        }
        
        if(tableToToggle.classList.contains('ocultarTabela')){
           tableToToggle.classList.remove('ocultarTabela');
           event.target.innerHTML = 'Ocultar casos';
        }else{
           tableToToggle.style.height = `${tableToToggle.dataset.originalHeight}px`;
           tableToToggle.classList.add('ocultarTabela');
           event.target.innerHTML = 'Exibir casos';
        }
      }
});