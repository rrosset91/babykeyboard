({
    doInit : function(component, event, helper)
    {
        helper.getCase(component);
        helper.fetchPicklistValues(component);    
        helper.getRecordTypeDetail(component);
    },
    
    onControllerFieldChange : function(component, event, helper)
    {
        var controllerValeuKey = event.getSource().get("v.value");
        var lDependent = component.get("v.dependentFieldMap");
        
        if(controllerValeuKey != 'Selecionar')
        {
            var listDependent =  lDependent[controllerValeuKey];
            if(listDependent.length > 0)
            {
                component.set("v.bDisabledDependentFld",false);
                console.dir(listDependent);
                helper.fetchDependentValues(component,listDependent);    
            }else
            {
                component.set("v.bDisabledDependentFld",true);
                component.set("v.listDependentValues",'Selecionar');
            }
        }else
        {
            component.set("v.listDependentValues",'Selecionar');
            component.set("v.bDisabledDependentFld",true);  
            component.set("v.isOpen",false); 
        }
    },
    
    enableField : function(component, event, helper)
    {
        var bUnit = component.find("bUnit").get("v.value");
        if(bUnit != 'Selecionar')
        {
            if(bUnit == 'Claro')
            {
                component.set("v.productClaro",true);
                component.set("v.productDTH",false);
                component.set("v.productEmbratel",false);
                component.set("v.productNET",false);
                
            }if(bUnit == 'Claro DTH')
            {
                component.set("v.productClaro",false);
                component.set("v.productDTH",true);
                component.set("v.productEmbratel",false);
                component.set("v.productNET",false);
                
            }if(bUnit == 'Embratel' )
            {
                component.set("v.productClaro",false);
                component.set("v.productDTH",false);
                component.set("v.productEmbratel",true);
                component.set("v.productNET",false);
                
            }if(bUnit == 'NET' )
            {
                component.set("v.productClaro",false);
                component.set("v.productDTH",false);
                component.set("v.productEmbratel",false);
                component.set("v.productNET",true);
            }
            
            component.set("v.bDisabledDependentFld",false);
        }    
    },
    
    
    fetchQuestion : function(component,event,helper)
    {
        component.set("v.isOpen",true);
    },
    
    caseSelectChild: function(component, event, helper) 
    {
        component.set("v.isCaseChild", true);
        component.set("v.caseSelect", false);
    },
    
    caseSelectSupport: function(component, event, helper) 
    {
        component.set("v.isCaseSupport", true);
        component.set("v.caseSelect", false);
    },
    
    caseSelectReopen: function(component, event, helper) 
    {
        helper.fetchReopenSubject(component);
        component.set("v.isCaseReopen", true);
        component.set("v.caseSelect", false);
    },
    
    createCaseChild : function(component,event,helper)
    {     
        helper.createCaseChild(component);  
    },
    
    createCaseReopen : function(component,event,helper)
    {     
        helper.createCaseReopen(component);        
    },
    
    createCaseSupport : function(component,event,helper)
    {     
        helper.createCaseSupport(component);        
    },    
       
    openModel: function(component, event, helper) 
    {
        var parentCase = component.get("v.parentCase");
        
        if(parentCase.Grouping__c != null && parentCase.Grouping__c == 'Anatel' &&
           parentCase.Channel__c != null && parentCase.Channel__c == 'Anatel') {
            component.set("v.enableReopenCase", true);
        }
        	
        component.set("v.caseSelect",true);
    },
    
    closeModel: function(component, event, helper) 
    {  
        component.set("v.isCaseChild", false);
        component.set("v.isCaseReopen", false);
        component.set("v.isCaseSupport", false);
        component.set("v.caseSelect",false);
        component.set("v.isOpen",false);
        component.set("v.bDisabledDependentFld",true); 
        component.set("v.listQuestion",null);
    },
    
    showSpinner: function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper)
    { 
        component.set("v.Spinner", false);
    },  
    
    backModel : function(component,event,helper)
    { 
        component.set("v.isCaseChild", false);
        component.set("v.isCaseSupport", false);
        component.set("v.isCaseReopen", false);
        component.set("v.caseSelect",true);
    }, 
    
})