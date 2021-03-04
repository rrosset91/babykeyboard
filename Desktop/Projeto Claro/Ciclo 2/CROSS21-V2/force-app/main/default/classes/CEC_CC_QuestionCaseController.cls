/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Questionario Controller Case]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe 
* ---------------------------------------------------------------
* Data: 03/06/2019  
* Autor: Squad Canais Criticos
* Alterações: Inclusão do método de CreateCaseSupport (Caso de Apoio)
* ---------------------------------------------------------------
* Data: 23/12/2020   
* Autor: Squad Canais Criticos
* Alterações: Alterações nos campos Status e Sub-Status do Caso (Melhorias Ouvidoria)
* ---------------------------------------------------------------
*/

public with sharing class CEC_CC_QuestionCaseController 
{
    @AuraEnabled
    public static Case getCase(String caseId) 
    {
        return [SELECT Id, Account.Phone, Account.CellPhone__c, RecordTypeId, RecordType.DeveloperName, Channel__c, Grouping__c, CriticalChannelOpenDate__c, Input_Subject__c, Subject, ContactId
                FROM Case 
                WHERE Id = : caseId 
                LIMIT 1];
    }
    
	@AuraEnabled
    public static Map<String,Id>  getRecordTypeDetail(String varObj) 
    {
        Map<String,Id> mapRecordTypeDeveloperNameId = CEC_CC_Util.getRecordTypeInfoByObj(varObj); 
        return mapRecordTypeDeveloperNameId;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getField(String pRecord)
    {
        Map<String, List<String>> mapPickList = new Map<String, List<String>>();
        
        Case varCase = [SELECT Id, BusinessUnit__c
                      	FROM Case 
                        WHERE Id = : pRecord LIMIT 1];
        
        List<Quiz__c> lstQuiz = [SELECT Name,SubArea__c 
                                FROM Quiz__c 
                                WHERE Active__c = TRUE 
                             	AND BusinessUnit__c INCLUDES (:varCase.BusinessUnit__c)
                                ORDER BY Name DESC];
        
        for(Quiz__c iQuiz : lstQuiz)
        {
            if(mapPickList.containsKey(iQuiz.Name)) {
                List<String> lSub = mapPickList.get(iQuiz.Name);
                lSub.add(iQuiz.SubArea__c);
                mapPickList.put(iQuiz.Name, lSub);
                
            } else {
                mapPickList.put(iQuiz.Name, new List<String> { iQuiz.SubArea__c });
            }
        }
        return mapPickList;
    }
    
    @AuraEnabled
    public static list<ParamQuestion__c> getQuestion(String pArea, String pValueKey)
    {
        list<ParamQuestion__c> lQuestion = new list<ParamQuestion__c>(); 
        for(ParamQuestion__c lParamQuestion : [SELECT id,Name, TypeQuestion__c FROM ParamQuestion__c 
                                               WHERE Questionario__r.Name = : pArea
                                               AND Questionario__r.SubArea__c =:  pValueKey
                                              ])
        {
            if(lParamQuestion.TypeQuestion__c == null) continue;
            lQuestion.add(lParamQuestion);      
        }
        return lQuestion;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> getReopenSubject()
    {
        List<Map<String, String>> reopenSubjectItems = new List<Map<String, String>>(); 
        for(SubjectAdministration__c subject : [SELECT Id, SubReason__c FROM SubjectAdministration__c WHERE ReopeningSubject__c = TRUE])
        {
            reopenSubjectItems.add(new Map<String, String>{'value' => subject.Id, 'label' => subject.SubReason__c});
        }
        return reopenSubjectItems;
    }
    
    @AuraEnabled
    public static String CreateCaseChild(Case formCase)
    {
        String message='';
        try
        {
            //Ativa AssigmentRule
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            
            //Obtem Case
            Case varCase = [SELECT	
                            AccountId,
                            BusinessUnit__c,
                            Channel__c,
                            ContactId, 
                            ContactPreference__c, 
                            Contract__c,
                            LineNumber__c, 
                            ContractBillingAccount__c,
                            CriticalChannelOpenDate__c, 
                            Description, 
                            Input_Subject__c,
                            Origin, 
                            Product__c,
                            SituationCase__c, 
                            Subject,
                            Status,
                            SubStatus__c,
                            RecordTypeId
                            FROM Case 
                            WHERE Id = : formCase.Id 
                            LIMIT 1];
            
            Id childrenCasesRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
            
            Case caseChild  = varCase.clone(false, false, false, false);
            
            caseChild.RecordTypeId 		= childrenCasesRecTypeId;
            caseChild.ParentId 			= formCase.Id;
            caseChild.SupportArea__c 	= formCase.SupportArea__c;
            caseChild.SupportAreaSub__c = formCase.SupportAreaSub__c;
            caseChild.RequestSupport__c = formCase.RequestSupport__c;           
            caseChild.Input_Subject__c = varCase.Input_Subject__c;
            caseChild.Status = 'New';
            caseChild.SubStatus__c = 'Não Iniciado';            
            
            caseChild.setOptions(dmo);
            
            insert caseChild; 

            
            //Alterações de melhorias ouvidoria

            Id CEC_CC_Anatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId();
            Id CEC_CC_CanaisInternos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId();
            Id CEC_CC_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId();
            Id CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
            Id CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
            Id CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();

            Set<Id> recordTypesIds = new Set<Id>{CEC_CC_Anatel, CEC_CC_CanaisInternos, CEC_CC_JEC, CEC_CC_Ouvidoria,
                                                CEC_CC_Pre_JEC, CEC_CC_Procon};

            if((varCase.Status == 'New' || varCase.SubStatus__c != 'Encerrado') &&
                recordTypesIds.contains(varCase.RecordTypeId))
            {
                varCase.Status = 'In Progress';
                varCase.SubStatus__c = 'Pendente com Área';
                update varCase;
            }            

            message = 'Cadastro realizado com sucesso!';

        }
        catch(Exception ex)
        {
            message = 'Erro contate um Administrador:  ' + ex;
        }
        
        return message;
    }
    
    @AuraEnabled
    public static String CreateCaseSupport(Case formCase)
    {
        String message='';
        try
        {
            //Ativa AssigmentRule
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            
            //Obtem Case
            Case varCase = [SELECT 
                            AccountId, 
                            AdditionalInformation__c,
                            Channel__c,
                            CompanyProtocols__c,
                            CompanyRequest__c, 
                            ContactId,
                            ContactPreference__c, 
                            CriticalChannelOpenDate__c,
                            Description,
                            Input_Subject__c,
                            InputType__c,
                            Manager__c,
                            Origin, 
                            Subject
                            FROM Case 
                            WHERE Id = : formCase.Id 
                            LIMIT 1];
            
            Id supportCasesRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId();
            
            Case caseSupport  = varCase.clone(false, false, false, false);
            
            caseSupport.RecordTypeId 		= supportCasesRecTypeId;
            caseSupport.SituationCase__c 	= 'Open';
            caseSupport.ParentId 		 	= formCase.Id;
            caseSupport.Contract__c      	= formCase.Contract__c;
            caseSupport.Company__c 			= formCase.Company__c;
            caseSupport.RequestSupport__c 	= formCase.RequestSupport__c;
            caseSupport.BusinessUnit__c     = formCase.BusinessUnit__c;
            caseSupport.Product__c          = formCase.Product__c;
            
            caseSupport.Input_Subject__c 	= varCase.Input_Subject__c;
            caseSupport.AdditionalInformation__c = varCase.AdditionalInformation__c;
            caseSupport.setOptions(dmo);
            
            insert caseSupport; 
            message = 'Cadastro realizado com sucesso!';
        }
        catch(Exception ex){
            message = 'Erro contate um Administrador:  ' + ex;
        }
        
        return message;
    }  
    
    @AuraEnabled
    public static String CreateCaseReopen(Case formCase)
    {
        String message='';
        try
        {
            //Ativa AssigmentRule
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            
            //Obtem Case
            Case varCase = [SELECT	SituationCase__c, AccountId, ContactId, Origin, Subject, Description, 
                            CriticalChannelOpenDate__c, BusinessUnit__c, Product__c, CriticalChannelProtocol__c,
                            Contract__c, LineNumber__c, ContractBillingAccount__c, Channel__c
                            FROM Case 
                            WHERE Id = : formCase.Id 
                            LIMIT 1];
            
            Id ReopenRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_ReaberturaAnatel').getRecordTypeId();
            
            Case caseReopen  = varCase.clone(false, false, false, false);
                       
            caseReopen.RecordTypeId 		      = ReopenRecTypeId;
            caseReopen.ParentId 			      = formCase.Id;
            caseReopen.RequestSupport__c 		  = formCase.RequestSupport__c;
            caseReopen.CriticalChannelOpenDate__c = formCase.CriticalChannelOpenDate__c;
            caseReopen.Input_Subject__c           = formCase.Input_Subject__c;
            caseReopen.setOptions(dmo);
            
            system.debug('Input_Subject: ' + formCase.Input_Subject__c);
            
            insert caseReopen; 
            message = 'Cadastro realizado com sucesso!';
        }
        catch(Exception ex)
        {
            message = 'Erro contate um Administrador:  ' + ex;
        }
        
        return message;
    }
}