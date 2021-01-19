/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Creation Date: 18/10/2019
--- Author: Squad Canais Críticos
--- Description: [CEC - Extensção Fase 1] - Serviço que retorna o histórico do caso 
-------------------------------------------------------------------------------------------------------*/

@RestResource(urlMapping='/api/caseService/*')
global with sharing class CEC_CC_CaseService 
{
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
    
    private static final String CEC_CC_Interaction = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('ConsumerInteractionGov').getRecordTypeId();
    
    private static final String CEC_CC_BillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    @HttpPost
    global static Response doPost(Request request) 
    {
        Set<Id> setUsers = getUsersToBeNotify();
        List<Task> lstNewTasks = new List<Task>();
        
        Response response = new Response();
        response.results = new List<CaseResult>(); 
        CaseResult result = new CaseResult();
        List<Case> createCase =  new List<Case>(); 
        List<Case> validateCase = new List<Case>();
		List<Case> createInteraction =  new List<Case>();
        
        List<string> numContratos = new List<string>();
        List<string> numTelefones = new List<string>();
        
        for(CEC_CC_CaseService.Cases itemCase : request.cases)
        {
            Case newCase = new Case();
            List<Account> account = new List<Account>();
            List<Contact> contact = new List<Contact>();
            
            if(itemCase.accountIdentifier == null || String.isEmpty(itemCase.accountIdentifier) )
            {
                result.isSuccess = false;
                result.message = 'Erro ao inserir caso, CPF não informado!';
                response.results.add(result);
                continue;
            }
            
            if(itemCase.criticalChannelProtocol == null)
            {
                result.isSuccess = false;
                result.message = 'Erro ao inserir caso, Protocolo não informado!';
                response.results.add(result);
                continue;
            }
            
            if(itemCase.accountIdentifier != null || String.isNotEmpty(itemCase.accountIdentifier) )
            {
                account = [SELECT Id FROM Account  WHERE DocumentNumber__c =: itemCase.accountIdentifier  LIMIT 1];
                
                if(account.size() > 0)
                {
                    newCase.AccountId = account[0].Id;                    
                    contact = [SELECT Id FROM Contact WHERE AccountId =: newCase.AccountId LIMIT 1];
                    if(contact.size() > 0)
                        newCase.ContactId = contact[0].Id;
                    
                } else {
                    result.isSuccess = false;
                    result.message = 'Erro ao inserir caso, CPF não cadastrado!';
                    response.results.add(result);
                    lstNewTasks.addAll(createTask(setUsers, itemCase));
                    continue;   
                }
            }
            
            newCase.RecordTypeId = CEC_CC_Ouvidoria;
            newCase.Contract__c = itemCase.contractNumber;
            newCase.AdditionalInformation__c = itemCase.additionalInformation;
            newCase.CriticalChannelProtocol__c = itemCase.criticalChannelProtocol;
            newCase.Description =  itemCase.reason + ' \r\n ' +  itemCase.description;
            newCase.Category__c = itemCase.reason;
            newCase.Subject = itemCase.reason;
            newCase.BusinessUnit__c = itemCase.businessUnit;
            
            if(itemCase.businessUnit.toUpperCase() == 'CLARO' && !String.isBlank(itemCase.msisdn)){
                numTelefones.add(itemCase.msisdn);
                newCase.Contract__c = itemCase.msisdn;
            }
            else if (!String.isBlank(itemCase.contractNumber)){
                numContratos.add(itemCase.contractNumber);
            }
            
            newCase.Channel__c = 'Ouvidoria';
            newCase.Grouping__c = 'Ouvidoria';
            newCase.InputType__c = 'Portal';
            newCase.Status = 'New';
            newCase.SubStatus__c ='Não Iniciado';
            newCase.CriticalChannelOpenDate__c = Datetime.now();
            newCase.ContactPreference__c = 'E-mail';
            createCase.add(newCase);
        }
        
        Map<string, Account> listaContratos = new Map<string, Account>();
        if(numContratos.size() > 0){
            List<Account> tmpContratos = [Select Id, Name FROM Account WHERE RecordTypeId = :CEC_CC_BillingAccount AND Name in :numContratos];
            for(Account c : tmpContratos){
                listaContratos.put(c.Name, c);
            }
        }
        
        Map<string, Asset> listaTelefones = new Map<string, Asset>();
        if(numTelefones.size() > 0){
            List<Asset> tmpTelefones = [Select Id, Name FROM Asset WHERE Name in :numTelefones];
            for(Asset a : tmpTelefones){
                listaTelefones.put(a.Name, a);
            }
        }
        
        for(Case c : createCase){
            if(c.BusinessUnit__c.toUpperCase() == 'CLARO' && listaTelefones.containsKey(c.Contract__c)){
                c.LineNumber__c = listaTelefones.get(c.Contract__c).Id;
                c.Contract__c = null;
            }
            else if (listaContratos.containsKey(c.Contract__c)){
                c.ContractBillingAccount__c = listaContratos.get(c.Contract__c).Id;
                c.Contract__c = null;
            }
        }
        
        System.debug('createCase: '+createCase);
        
        
        List<CaseResult> caseResult = new List<CaseResult>();
        
        //valida se existe caso em aberto
        validateCase = validateOpenCase(createCase);
        
        if(validateCase.size() > 0)
        {
            System.debug('validateOpenCase: Existe caso em aberto');
            
            for(Case varCaseNew : validateCase)
            {
                for(Case varCase : createCase)
                {
                    varCaseNew.RecordTypeId = varCase.RecordTypeId;
                    varCaseNew.Contract__c = varCase.Contract__c;
                    varCaseNew.AdditionalInformation__c = varCase.AdditionalInformation__c;
                    varCaseNew.CriticalChannelProtocol__c = varCase.CriticalChannelProtocol__c;
                    varCaseNew.Description =  varCase.Description;
                    varCaseNew.Category__c = varCase.Category__c;
                    varCaseNew.Subject = varCase.Subject;
                    varCaseNew.BusinessUnit__c = varCase.BusinessUnit__c;
                    varCaseNew.Channel__c = varCase.Channel__c;
                    varCaseNew.Grouping__c = varCase.Grouping__c;
                    varCaseNew.InputType__c = varCase.InputType__c;
                    varCaseNew.Status = varCase.Status;
                    varCaseNew.SubStatus__c = varCase.SubStatus__c;
                    varCaseNew.CriticalChannelOpenDate__c = varCase.CriticalChannelOpenDate__c;
                    varCaseNew.ContactPreference__c = varCase.ContactPreference__c;
                    createInteraction.add(varCaseNew);
                }
            }
            
            createInteraction(createInteraction);
            caseResult = getCases(createInteraction, false);
            
        }else
        {
            System.debug('validateOpenCase: Não existe caso em aberto');
            
            caseResult = getCases(createCase, true);
        }
        
        //faz depara do response 
        response.results.addAll(caseResult);
        
        if(!lstNewTasks.isEmpty())
            insert lstNewTasks;
        
        return response;
    }    
    
    @testVisible
    private static void createInteraction(List<Case> caso)
    {
        System.debug('createInteraction >> caso: '+caso);
        
        vlocity_cmt__CustomerInteraction__c objCustomerInteraction = 
            new vlocity_cmt__CustomerInteraction__c(Name = 'Interação ouvidoria', 
                                                    vlocity_cmt__Status__c = 'Completed',
                                                    vlocity_cmt__Type__c = 'Other', //'Consumidor.gov', 
                                                    vlocity_cmt__Channel__c = 'Contact', 
                                                    Author__c = 'Empresa');
        objCustomerInteraction.RecordTypeId = CEC_CC_Interaction;
        objCustomerInteraction.Description__c = caso[0].Description;
        objCustomerInteraction.vlocity_cmt__EndDateTime__c = System.now();
        objCustomerInteraction.vlocity_cmt__StartDateTime__c = System.now();
        objCustomerInteraction.TypeInteractionGov__c = 'Ouvidoria Contato';
        //objCustomerInteraction.vlocity_cmt__Status__c = (typeInteraction == 'Cobra Retorno' || typeInteraction == 'Tentativa de Contato') ?
        //  statusInteraction : 'Pendente de sincronismo';
        //objCustomerInteraction.vlocity_cmt__Type__c = 'Interna';
        objCustomerInteraction.Attachment__c = false;
        
        System.debug('before insert objCustomerInteraction : '+objCustomerInteraction);
        
        Database.insert(objCustomerInteraction);
        
        vlocity_cmt__CustomerInteractionTopic__c objInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        objInteractionTopic.vlocity_cmt__CustomerInteractionId__c =  objCustomerInteraction.Id;
        objInteractionTopic.vlocity_cmt__CaseId__c = caso[0].Id;
        
        System.debug('before insert objInteractionTopic: '+objCustomerInteraction);
        
        Database.insert(objInteractionTopic);
    }
    
    @testVisible
    private static List<Case> validateOpenCase(List<Case> lstCases)
    {
        Set<Id> accounts = new Set<Id>();
        
        for(Case item : lstCases)
        {
            accounts.add(item.AccountId);
        }
        
        return [SELECT Id, Description 
                FROM Case 
                WHERE AccountId IN : (accounts)
                AND Channel__c = 'Ouvidoria'
                AND Grouping__c = 'Ouvidoria'
                AND InputType__c = 'Portal'
                AND Status != 'Closed'];
    }
    
    @testVisible
    private static List<CaseResult> getCases(List<Case> lstCases, boolean isCreateCase)
    {
        Response response = new Response();
        response.results = new List<CaseResult>();
        Set<Id> setCaseIds = new Set<Id>();
        
        if(isCreateCase)
        {
            Database.SaveResult[] saveResult = Database.insert(lstCases, false);
            for (Database.SaveResult sr : saveResult) 
            {
                if (sr.isSuccess()) {
                    setCaseIds.add(sr.id);
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        CaseResult result = new CaseResult(); 
                        result.isSuccess = false;
                        result.message = 'Erro na inserção do Caso: ' + err.getMessage() + ' \r\n ' +
                            'Campos Afetados: ' + err.getFields();
                        response.results.add(result);
                    }
                }
            }
            
            
        }else
        {
            for(Case varCase : lstCases)
            {
                setCaseIds.add(varCase.id);
            }
        }
        
        for(Case varCase : [ SELECT Id, CaseNumber, CriticalChannelProtocol__c 
                            FROM Case 
                            WHERE Id IN : (setCaseIds) ])
        {
            CaseResult result = new CaseResult(); 
            result.caseNumber = varCase.CaseNumber;
            result.criticalChannelProtocol = varCase.CriticalChannelProtocol__c;
            result.isSuccess = true;
            result.message = isCreateCase ? 'Caso ' + result.caseNumber + ' cadastrado com sucesso!' : 'Existe uma solicitação em aberto. Caso ' + result.caseNumber + ' não foi encerrado.' ;
            response.results.add(result);
        }
        
        
        return response.results;
    }
    
    @testVisible
    private static List<Task> createTask(Set<Id> setUsersId, CEC_CC_CaseService.Cases itemCase)
    {
        List<Task> lstNewTasks = new List<Task>();
        for(Id userId : setUsersId)
        {
            Task varTask = new Task(Priority = 'Normal', Status = 'Open');
            varTask.Subject = 'Cliente não encontrado. CPF: ' + itemCase.accountIdentifier;
            
            varTask.Description = 'CPF: ' + itemCase.accountIdentifier + ' \r\n ' + 
                'Nome completo: ' + itemCase.accountName + ' \r\n ' + 
                'Telefone reclamado: ' + itemCase.contractNumber + ' \r\n ' +
                'Telefone para contato: ' + itemCase.AdditionalInformation + ' \r\n ' +
                'E-mail para contato: ' + itemCase.accountEmail + ' \r\n ' +
                'Protocolo de atendimento: ' + itemCase.criticalChannelProtocol + ' \r\n ' +  
                'Descrição da reclamação: ' + itemCase.description; 
            
            varTask.ActivityDate = System.today();
            varTask.OwnerId = userId;
            lstNewTasks.add(varTask);
        }
        
        return lstNewTasks;
    }
    
    @testVisible
    private static Set<Id> getUserstoBeNotify()
    {           
        Set<Id> setUsersId = new Set<Id>();
        
        List<GroupMember> lstGroupMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN (SELECT Id FROM Group WHERE DeveloperName = 'SemIdentificacaoPortais' AND Type = 'Queue')];
        
        for(GroupMember gm : lstGroupMember){
            setUsersId.add(gm.UserOrGroupId);
        }
        
        return setUsersId;
    }
    
    global class Request {
        global List<Cases> cases {get;set;}
    }
    
    global class Response {
        global List<CaseResult> results {get;set;}         
    }    
    
    global class CaseResult {
        @testVisible Boolean isSuccess {get;set;}
        @testVisible String caseNumber {get;set;}
        @testVisible String message {get;set;}
        @testVisible String criticalChannelProtocol {get;set;}
    }
    
    global class Cases {
        @testVisible String recordType {get;set;}
        @testVisible String contractNumber {get;set;}
        @testVisible String accountName {get;set;}//obrigatorio
        @testVisible String accountEmail {get;set;}//somente quando criarmos conta
        @testVisible String additionalInformation {get;set;}
        @testVisible String accountIdentifier {get;set;}////obrigatorio
        @testVisible String criticalChannelProtocol {get;set;}// //obrigatorio
        @testVisible String reason {get;set;}// validar se é o campo assunto 
        @testVisible String description {get;set;}////obrigatorio  
        @testVisible String inputType {get;set;}  
        @testVisible String channel {get;set;}  
        @testVisible String grouping {get;set;}  
        @testVisible String businessUnit {get;set;}        
        @testVisible String msisdn {get;set;}
    }  
}