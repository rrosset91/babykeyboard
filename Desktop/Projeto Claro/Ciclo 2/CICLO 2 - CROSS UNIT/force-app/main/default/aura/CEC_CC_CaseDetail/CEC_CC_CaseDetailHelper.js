({
    getCase : function(component)
    {
        var action 	= component.get("c.GetCase");   
        action.setParams({ caseId: component.get("v.recordId")});
        action.setCallback(this, function(response) {	
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") { 
                component.set("v.case", result);
                this.getPermissionToRequestRefusal(component);
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.enqueueAction(action);
    },
    
    getPermissionToRequestRefusal : function(component)
    {
        var newCase = component.get("v.case");
        var mapRecType = component.get("v.dependentRecTypeMap");
        if(mapRecType != null && mapRecType['Consumidor_GOV'] == newCase.RecordTypeId)
            component.set("v.canRequestRefusal", true);
    },
    
    getRecordTypeDetail : function(component, callBackFunction)
    {
        var action 	= component.get("c.getRecordTypeDetail");   
        action.setParams({ varObj: 'Case'});
        action.setCallback(this, function(response) {	
            if(response.getState() === "SUCCESS") { 
                component.set("v.dependentRecTypeMap", response.getReturnValue());
            }
            else if(response.getState() === "ERROR" || response.getState() === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
            
            if(callBackFunction) {
                callBackFunction();
            }            
        });
        $A.enqueueAction(action);
    },
    
    requestReject : function(component)
    {
        var newCase = component.get("v.case");       
        
        if(newCase.RejectDescription__c == null || newCase.RejectDescription__c == '') 
        {
            this.methodModal('Preenchimento da descrição é obrigatório!', 'warning', 'Recusa');
            return false;
        }
      
        if(newCase.RejectAmount__c > 3)
        {
            this.methodModal('Quantidade de solicitações de Recusa excedida!', 'warning', 'Recusa');
            return false;
        }
        
        if(newCase.Status != null && newCase.Status.includes('Cancelado') || newCase.Status.includes('Cancel'))
        {
            this.methodModal('Caso Cancelado!', 'warning', 'Recusa');
            return false;
        }
        
        if(newCase.Status != null && newCase.Status.includes('Closed') || newCase.Status.includes('Encerrado'))
        {
            this.methodModal('Caso Encerrado, você não pode solicitar recusa!', 'warning', 'Recusa');
            return false;
        }        
       
        var action 	= component.get("c.RequestReject");          
        action.setParams({ varCase: newCase});
        action.setCallback(this, function(response) 
        {	
            var state = response.getState();
            if(state === "SUCCESS") 
            { 
                $A.get('e.force:refreshView').fire();
                var result = response.getReturnValue();                
                
                this.methodModal(result.message, result.status, result.title);
                $A.get('e.force:refreshView').fire();
                
                if(result.status === 'success')
                	this.closeModal(component);
            }
            else if(response.getState() === "ERROR" || response.getState() === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
      
    editCase : function(component)
    {
        var action 	= component.get("c.GetCase");   
        action.setParams({ caseId: component.get("v.recordId")});
        action.setCallback(this, function(response) {	
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") { 
                component.set("v.case", result);
                var newCase = component.get("v.case");  
                if(newCase.Status != null && newCase.Status.includes('Closed') || newCase.Status.includes('Encerrado'))
                {
                    this.methodModal('Caso Encerrado, você não pode editar!', 'warning', 'Editar Caso');
                }
                else {
                    var editRecordEvent = $A.get("e.force:editRecord");
                    editRecordEvent.setParams({
                        "recordId": component.get("v.recordId")
                    });
                    editRecordEvent.fire();
                }
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.enqueueAction(action);
    },
    
    methodModal : function(message, type, title)
    {
        var modalEvent = $A.get("e.force:showToast");
        modalEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        modalEvent.fire(); 
    },
    
    closeModal : function(component)
    {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    
})