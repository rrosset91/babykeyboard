public class CEC_InteractionTopicTriggerHandler 
{
    public Map<Id, vlocity_cmt__CustomerInteractionTopic__c> newRecordMap;
    public Map<Id, vlocity_cmt__CustomerInteractionTopic__c> oldRecordMap;
    public List<vlocity_cmt__CustomerInteractionTopic__c> newRecordList;
    public List<vlocity_cmt__CustomerInteractionTopic__c> oldRecordList;
    
    public CEC_InteractionTopicTriggerHandler() 
    {
        this.newRecordMap  = new Map<Id, vlocity_cmt__CustomerInteractionTopic__c>();
        this.oldRecordMap  = new Map<Id, vlocity_cmt__CustomerInteractionTopic__c>();
        this.newRecordList = new List<vlocity_cmt__CustomerInteractionTopic__c>();
        this.oldRecordList = new List<vlocity_cmt__CustomerInteractionTopic__c>();
    }
    
    public void onAfterInsert()
    {
        createTaskByCase(this.newRecordList);  
        updateCase(this.newRecordList);
    }
    
    public void onAfterUpdate()
    {
        
    }
    
    public void onBeforeUpdate(){System.debug('Before Update');}
    public void onBeforeInsert(){System.debug('Before Insert');}
    
    private void updateCase(List<vlocity_cmt__CustomerInteractionTopic__c> listNewCustomerInteractionTopic)
    {
        System.debug('>> updateCase');
        
        List<Case> lstCase = new List<Case>();
        List<Case> lstCaseUpdate = new List<Case>();
        List<Task> listTaskToInsert = new List<Task>();        
        Set<Id> setCustomerInteractionIds = new Set<Id>();
        Set<Id> setCaseIds = new Set<Id>();
        
        Map<Id, Map<Id, vlocity_cmt__CustomerInteraction__c>> mapInteractionFromTopic = 
            new Map<Id, Map<Id, vlocity_cmt__CustomerInteraction__c>>();        
        Map<Id, vlocity_cmt__CustomerInteraction__c> mapInteraction = 
            new Map<Id, vlocity_cmt__CustomerInteraction__c>();
        Map<Id, vlocity_cmt__CustomerInteraction__c> mapByIdCaseInteraction = 
            new Map<Id, vlocity_cmt__CustomerInteraction__c>();
        
        for(vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic : listNewCustomerInteractionTopic)
        {
            setCustomerInteractionIds.add(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c);
        }
            
        List<vlocity_cmt__CustomerInteraction__c> lstInteraction = [SELECT Id, Description__c, TypeInteractionGov__c
                                                                    FROM vlocity_cmt__CustomerInteraction__c
                                                                    WHERE Id IN: setCustomerInteractionIds];
        
        System.debug('>>lstInteraction: '+lstInteraction);
        
        for(vlocity_cmt__CustomerInteraction__c varInteraction : lstInteraction)
        {
            mapInteraction.put(varInteraction.Id, varInteraction);
        }
        
             
        for(vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic : listNewCustomerInteractionTopic)
        {
            System.debug('varCustomerInteractionTopic >>>>>>>>> '+varCustomerInteractionTopic);
            
			mapInteractionFromTopic.put(varCustomerInteractionTopic.Id, mapInteraction);
                
            if(String.isNotBlank(varCustomerInteractionTopic.vlocity_cmt__CaseId__c))
            {
                System.debug('mapInteractionFromTopic >>>>>>>>> '+mapInteractionFromTopic);
                
                if(mapInteractionFromTopic.get(varCustomerInteractionTopic.Id)
                   .get(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c)
                   .TypeInteractionGov__c != null)
                {
                    if(mapInteractionFromTopic.get(varCustomerInteractionTopic.Id)
                       .get(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c)
                       .TypeInteractionGov__c.EqualsIgnoreCase('Protocolo Encerrado Avaliado'))
                    {
                        System.debug(' Aqui >>>>>>>>>>>>>>>>>>>>>>>>>>.');
                        setCaseIds.add(varCustomerInteractionTopic.vlocity_cmt__CaseId__c);
                        mapByIdCaseInteraction.put(varCustomerInteractionTopic.vlocity_cmt__CaseId__c, mapInteractionFromTopic
                                                   .get(varCustomerInteractionTopic.Id)
                                                   .get(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c));
                    }
                }
            }
        }
        
        if(!setCaseIds.IsEmpty())
        {
            lstCase = [SELECT Id, ContactId, OwnerId, Raiting__c, Solved__c FROM Case WHERE Id IN: setCaseIds];
        }        
        
        System.debug('before for lstCases: '+lstCase);
        
        for(Case varCase : lstCase)
        {    
           	string valor = mapByIdCaseInteraction.get(varCase.Id).Description__c;
            string valorResolvida;
            string valorAvaliacao;
            
            try
            {
                valorResolvida = valor.substringAfter('Resolvida:').substringBefore('Nota de Avaliação:').Trim();
                if(valorResolvida.contains('Sim') || valorResolvida.contains('Nao'))
                {
                    valorResolvida = valorResolvida.substring(0,3);    
                }
                
                valorAvaliacao = valor.substringAfter('Nota de Avaliação:').Trim();                
                valorAvaliacao = valorAvaliacao.substring(0,1);
                
                System.debug('>> valorResolvida: '+valorResolvida);
                System.debug('>> valorAvaliacao: '+valorAvaliacao);
                
                varCase.Solved__c = valorResolvida;
                varCase.Raiting__c = Decimal.valueOf(valorAvaliacao);
                
                System.debug('varCase: '+varCase);
                
                lstCaseUpdate.add(varCase);
            }
            catch(Exception ex)
            {
                System.debug('Messager Error: '+ex.getMessage());
                System.debug('Line Error: '+ex.getStackTraceString());
            }
        }
        
        System.debug('after for lstCases: '+lstCaseUpdate);
        
        if(!lstCaseUpdate.isEmpty())
        {
            Database.update(lstCaseUpdate);
        }        
    }
    
    private void createTaskByCase(List<vlocity_cmt__CustomerInteractionTopic__c> listNewCustomerInteractionTopic)
    {
        List<Task> listTaskToInsert = new List<Task>();
        Set<Id> setCustomerInteractionIds = new Set<Id>();
        Set<Id> setCaseIds = new Set<Id>();
        List<vlocity_cmt__CustomerInteractionTopic__c> listNewCustomerInteractionTopicAux = new List<vlocity_cmt__CustomerInteractionTopic__c>();
        
        for(vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic : listNewCustomerInteractionTopic)
        {
            setCustomerInteractionIds.add(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c);
            if(String.isNotBlank(varCustomerInteractionTopic.vlocity_cmt__CaseId__c))
            {
                setCaseIds.add(varCustomerInteractionTopic.vlocity_cmt__CaseId__c);
            }
        }
        
        Map<Id, vlocity_cmt__CustomerInteraction__c > mapCustomerInteractions = new Map<Id, vlocity_cmt__CustomerInteraction__c>
            (
                [SELECT Id, vlocity_cmt__Channel__c, vlocity_cmt__Type__c, Author__c 
                 FROM vlocity_cmt__CustomerInteraction__c 
                 WHERE Id IN: setCustomerInteractionIds]
            );
        
        Map<Id, Case> mapCases = 
            new Map<Id, Case>([SELECT Id, ContactId, OwnerId,
                               Raiting__c, Solved__c
                               FROM Case 
                               WHERE Id IN: setCaseIds]);
        
        for(Case iCase : mapCases.values())
        {
            if(iCase.OwnerID.getsobjecttype() != User.sobjecttype) mapCases.remove(iCase.Id);
        }        
        
        if(!mapCustomerInteractions.isEmpty())
        {
            for(vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic : listNewCustomerInteractionTopic)
            {
                if(mapCustomerInteractions.containsKey(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c))
                {
                    vlocity_cmt__CustomerInteraction__c varCustomerInteractionAux = mapCustomerInteractions.get(varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c);
                    if(String.isNotBlank(varCustomerInteractionAux.vlocity_cmt__Channel__c) &&
                       String.isNotBlank(varCustomerInteractionAux.vlocity_cmt__Type__c))
                    {
                        if(varCustomerInteractionAux.vlocity_cmt__Channel__c.equalsIgnoreCase('Web') &&
                           varCustomerInteractionAux.vlocity_cmt__Type__c.equalsIgnoreCase('Consumidor.gov') &&
                           varCustomerInteractionAux.Author__c.equalsIgnoreCase('Consumidor'))
                        {
                            listNewCustomerInteractionTopicAux.add(varCustomerInteractionTopic);
                        }
                    }                    
                }
            }
        }        
        
        if(!mapCases.isEmpty())
        {
            for(vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic : listNewCustomerInteractionTopicAux)
            {
                if(String.isNotBlank(varCustomerInteractionTopic.vlocity_cmt__CaseId__c))
                {
                    if(mapCases.containsKey(varCustomerInteractionTopic.vlocity_cmt__CaseId__c))
                    {
                        Task varTask = createTask(mapCases.get(varCustomerInteractionTopic.vlocity_cmt__CaseId__c));
                        listTaskToInsert.add(varTask);
                    }
                    setCaseIds.add(varCustomerInteractionTopic.vlocity_cmt__CaseId__c);
                }
            }
        }  
        
        if(!listTaskToInsert.isEmpty())
        {
            Database.insert(listTaskToInsert);
        }
    }
    
    private Task createTask(Case varCase)
    {
        Task varTask = new Task();
        varTask.WhoId = varCase.ContactId;
        varTask.Priority = 'Alta';
        varTask.Status = 'Aberto';
        varTask.Subject = 'Interação GOV';
        varTask.Description = 'Uma nova interação foi incluída no caso. Favor verificar.';
        varTask.IsReminderSet = true;          
        varTask.ReminderDateTime = System.now().addDays(1);
        varTask.ActivityDate = System.today().addDays(1);
        varTask.OwnerId = varCase.OwnerId;
        varTask.WhatId = varCase.Id;
        
        return varTask;
    }
}