({
    
    getCase : function(component)
    {
        var action 	= component.get("c.getCase");   
        action.setParams({ caseId: component.get("v.recordId")});
        action.setCallback(this, function(response) {	
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") { 
                component.set("v.parentCase", result);
                var parentCase = component.get("v.parentCase");
                
                if(result != null && result.RecordType.DeveloperName == 'Consumidor_GOV')
                    component.set("v.isToShowCompany", true);
                else 
                    component.set("v.isToShowCompany", false);
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal('', errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchPicklistValues : function(component)
    {
        var lRecord = component.get("v.recordId");
        var action = component.get("c.getField");
        
        action.setParams({
            pRecord : lRecord
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") 
            {
                var result = response.getReturnValue();               
                component.set("v.dependentFieldMap",result);
                
                var listOfKeys = [];
                var controllerField = [];
                
                for(var singlKey in result){
                    listOfKeys.push(singlKey);     
                }
                
                if(listOfKeys != undefined && listOfKeys.length > 0) {
                    controllerField.push('Selecionar');    
                }
                
                for(var i =0; i < listOfKeys.length; i++) {
                    controllerField.push(listOfKeys[i]);        
                }
                                
                component.set("v.listAreaValues",controllerField);
            }
            else if(state === "ERROR" || state === "INCOMPLETE") {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.showToast(component, 'info', errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    fetchPicklist : function(component)
    {      
        var lRecord = component.get("v.recordId"); 
        var action = component.get("c.getField");
        
        action.setParams({
            pRecord : lRecord        
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS")
            {
                var result = a.getReturnValue();
                var controllerField = [];
                
                if(result != undefined && result.length > 0) {
                    controllerField.push('Selecionar');    
                }
                
                for(var i =0; i < result.length; i++) {
                    controllerField.push(result[i]);        
                }
                
                component.set("v.TypePicklist", controllerField); 
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDependentValues : function(component,listDependent)
    {
        var dependentFields = [];
         
        for(var i =0; i < listDependent.length; i++) {
            dependentFields.push(listDependent[i]);        
        }
        
        dependentFields.sort();
        dependentFields.push('Selecionar');
        
        component.set("v.listDependentValues",dependentFields);
    },
    
    fetchQuestionValues : function(component,event,controllerValeuKey)
    {
        var lArea = component.find("lArea").get("v.value");
        var businessUnit = component.find("bUnit").get("v.value");
        var action = component.get("c.getQuestion");	
        
        action.setParams({
            pArea : lArea,
            pValueKey : controllerValeuKey,
            pBU : businessUnit
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") 
            {
                var result = response.getReturnValue();               
                component.set("v.listQuestion",result);
                if(result.length > 0) component.set("v.isOpen",true);
                
                else this.methodModal('Este campo não possui questionário cadastrado!', 'warning', '');
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchReopenSubject : function(component)
    {
        var action = component.get('c.getReopenSubject');        
        // Set up the callback
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if(state === "SUCCESS"){               
                component.set('v.listReopenSubject', response.getReturnValue());
            } else if (state === "ERROR") {        
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', '');
            }
        }));
        $A.enqueueAction(action);        
    },
    
    createCaseChild : function(component)
    {
        //Obtem os valores do formulario
        var requestSupport = component.find("numberOrder").get("v.value"); 
        var supportArea = component.find("lArea").get("v.value"); 
        var supportAreaSub = component.find("lSubArea").get("v.value");
        var idCase = component.get("v.recordId");
        
        //Validações
        if(requestSupport == null || requestSupport == "" ) 
        {
            this.methodModal('Preencha o campo: "Descrição da solicitação" ', 'warning', 'Caso Filho');
            return;
        }
        else if(supportArea == null || supportArea == "" ) 
        {
            this.methodModal('Campo "Área" não preenchido ou Area não cadastrada no Questionário. ', 'warning', 'Caso Filho');
            return;
        }
        else if(supportAreaSub == null || supportAreaSub == "" ) 
        {
            this.methodModal('Campo "Sub Área" não preenchido ou Sub Área não cadastrada no Questionário. ', 'warning', 'Caso Filho');
            return;
        }
        
        //Instancia do Case Object
        var caso = ({'sobjectType':'Case',
                     'SupportArea__c':''+supportArea+'',
                     'SupportAreaSub__c':''+supportAreaSub+'',
                     'RequestSupport__c':''+requestSupport+'',
                     'Id':''+idCase
                    });
        
        component.set("v.disableBtnCadastrar",true);
        
        //Obtem a controller server side 
        var action = component.get("c.CreateCaseChild");
        action.setParams({ formCase : caso });        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();               
                var lCheck = 'warning';
                
                if(result.includes('Cadastro'))
                {
                    component.set("v.isOpen",false);
                    component.set("v.isCaseChild",false);
                    component.set("v.bDisabledDependentFld",true); 
                    component.set("v.listQuestion",null);
                    lCheck = 'success'; 
                }
                
                component.set("v.disableBtnCadastrar",false);
                
                this.methodModal(result, lCheck, 'Caso Filho');
                $A.get('e.force:refreshView').fire();
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                var errors = response.getError();
                if (errors[0] && errors[0].message) 
                    this.methodModal(errors[0].message, 'info', 'Caso Filho');
            }
        });
        $A.enqueueAction(action);
    },
    
    createCaseReopen : function(component)
    {
        //Obtem os valores do formulario
        var reopenSubject = component.find("reopenSubject");
        var requestSupport = component.find("numberOrder");
        var openCriticalChannel = component.find("openCriticalChannel");
        var parentCase = component.get("v.parentCase");
        var idCase = component.get("v.recordId");
        
        var isValid = false;
        
        if(requestSupport.get("v.value") == null || requestSupport.get("v.value") == "" ){
            requestSupport.set("v.errors", [{message:"Preencher esse campo"}]);
            isValid = false;
        }
        else {
            requestSupport.set("v.errors", null);
            isValid = true;
        }
        
        if(openCriticalChannel.get("v.value") == null || openCriticalChannel.get("v.value") == "" ){
           openCriticalChannel.set("v.errors", [{message:"Preencher esse campo"}]);
           isValid = false;
        }
        else if(openCriticalChannel.get("v.value") != null &&
                openCriticalChannel.get("v.value")  < 
                $A.localizationService.formatDate(parentCase.CriticalChannelOpenDate__c, "YYYY-MM-DD"))
        {
            openCriticalChannel.set("v.errors", [{message:"A data informada deve ser maior que a do caso pai"}]);
            isValid = false;
        }
        else if(openCriticalChannel.get("v.value") != null &&
                $A.localizationService.formatDate(openCriticalChannel.get("v.value"), "YYYY-MM-DD") > 
                $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"))
        {
            openCriticalChannel.set("v.errors", [{message:"A data informada não pode ser futura"}]);
            isValid = false;
        }
        else
            openCriticalChannel.set("v.errors", null);

        if(isValid)
        {
            component.set("v.disableBtnCadastrar",true);

            //Instancia do Case Object
            var caso = ({'sobjectType':'Case',
                         'RequestSupport__c':'' + requestSupport.get("v.value") + '',
                         'CriticalChannelOpenDate__c':'' + openCriticalChannel.get("v.value") + '',
                         'Input_Subject__c':'' + reopenSubject.get("v.value") + '',
                         'Id':'' + idCase });
            
            //Obtem a controller server side 
            var action = component.get("c.CreateCaseReopen");
            action.setParams({ formCase : caso });        
            action.setCallback(this, function(response) 
            {
               debugger;
               var state = response.getState();
               if(state === "SUCCESS") {
                   
                   var result = response.getReturnValue();               
                   var lCheck = 'warning';
                   
                   if(result.includes('Cadastro'))
                   {
                       component.set("v.isOpen",false);
                       component.set("v.isCaseReopen",false);
                       lCheck = 'success'; 
                   }
                    
                   component.set("v.disableBtnCadastrar",false);
                   
                   this.methodModal(result, lCheck, 'Caso Reabertura');
                   $A.get('e.force:refreshView').fire();
               }
               else if(state === "ERROR" || state === "INCOMPLETE")
               {
                   component.set("v.disableBtnCadastrar",false);
                   var errors = response.getError();
                   if (errors[0] && errors[0].message) 
                       this.methodModal(errors[0].message, 'info', 'Caso Reabertura');
               }
            });
            $A.enqueueAction(action);
        }
        
    },

    createCaseSupport : function(component)
    {
        //Obtem os valores do formulario
        var idCase = component.get("v.recordId");
        var isToShowCompany = component.get('v.isToShowCompany');
        var companyName = (isToShowCompany) ? component.find("company").get("v.value") : '';
        var requestSupport = component.find("numberOrder").get("v.value");
        var contractNumber = component.find("contract").get("v.value"); 
        var businessUnit = component.find("bUnit").get("v.value"); 
        var product;
        
        if(businessUnit == 'Claro'){
            product = component.find("productClaro").get("v.value"); 
        }else if(businessUnit == 'Claro DTH'){
            product = component.find("productDTH").get("v.value");
        }else if(businessUnit == 'Embratel'){
            product = component.find("productEmbratel").get("v.value");
        }else if(businessUnit == 'NET' ){
            product = component.find("productNET").get("v.value");
        }
                    
        //Validações
        if(requestSupport == null || requestSupport == "" ){
            this.methodModal('A informação de Descrição da solicitação deve ser preenchida.', 'warning', 'Caso Apoio');
            return;
        }
        else if(businessUnit == null || businessUnit == "" || businessUnit == "Selecionar" ){
            this.methodModal('A informação de Unidade de Negócio deve ser preenchida.', 'warning', 'Caso Apoio');
            return;
        }   
        else if(product == null || product == "" || product == "Selecionar" ){
            this.methodModal('A informação de Produto deve ser preenchida.', 'warning', 'Caso Apoio');
            return;
        }     
        else if(isToShowCompany && (companyName == null || companyName == "" || companyName == "Selecionar")) 
        {
            this.methodModal('A informação de Empresa deve ser prenchida.', 'warning', 'Caso Apoio');
            return;
        }    
        
        component.set("v.disableBtnCadastrar",true);
        
        //Instancia do Case Object
        var caso = ({'sobjectType':'Case',
                     'BusinessUnit__c':''+ businessUnit + '',
                     'Company__c':'' + (isToShowCompany) ? companyName  : '' + '',
                     'Contract__c':'' + contractNumber + '',
                     'Product__c':'' + product + '',
                     'RequestSupport__c':'' + requestSupport + '',
                     'Id':'' + idCase
                    });
        
        //Obtem a controller server side 
        var action = component.get("c.CreateCaseSupport");
        
        action.setParams({
            formCase : caso
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
                        
            if(state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var result = response.getReturnValue();               
                var lCheck = 'warning';
                
                if(result.includes('Cadastro'))
                {
                    component.set("v.isOpen",false);
                    component.set("v.isCaseSupport",false);
                    component.set("v.bDisabledDependentFld",true); 
                    component.set("v.listQuestion",null);
                    lCheck = 'success';
                }
                
                component.set("v.disableBtnCadastrar",false);
                
                this.methodModal(result, lCheck, 'Caso Apoio');
                $A.get('e.force:refreshView').fire();
            }
            else if(state === "ERROR" || state === "INCOMPLETE")
            {
                var errors = response.getError();
                if (errors[0] && errors[0].messageSupport) 
                    this.methodModal(errors[0].message, 'info', 'Caso Apoio');
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecordTypeDetail : function(component)
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
                    this.methodModal('', errors[0].message, 'info');
            }
        });
        $A.enqueueAction(action);
    },
    
    methodModal : function(messageModal, typeModal, typeObject) 
    {
        var modalEvent = $A.get("e.force:showToast");
        modalEvent.setParams({
            title: typeObject,
            message: messageModal,
            type: typeModal
        });
        modalEvent.fire(); 
    }
})