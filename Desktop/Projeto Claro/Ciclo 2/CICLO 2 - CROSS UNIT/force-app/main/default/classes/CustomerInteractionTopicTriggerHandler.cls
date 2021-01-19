public class CustomerInteractionTopicTriggerHandler 
{
	public Map<Id, vlocity_cmt__CustomerInteractionTopic__c> newRecordMap;
    public Map<Id, vlocity_cmt__CustomerInteractionTopic__c> oldRecordMap;
    public List<vlocity_cmt__CustomerInteractionTopic__c> newRecordList;
    public List<vlocity_cmt__CustomerInteractionTopic__c> oldRecordList;
    
    public CustomerInteractionTopicTriggerHandler() 
    {
        this.newRecordMap = new Map<Id, vlocity_cmt__CustomerInteractionTopic__c>();
        this.oldRecordMap = new Map<Id, vlocity_cmt__CustomerInteractionTopic__c>();
        this.newRecordList = new List<vlocity_cmt__CustomerInteractionTopic__c>();
        this.oldRecordList = new List<vlocity_cmt__CustomerInteractionTopic__c>();
    }
    
    public void onAfterInsert()
    {
        createTaskByCase(this.newRecordList);
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
            [SELECT Id, vlocity_cmt__Channel__c, vlocity_cmt__Type__c,Author__c FROM vlocity_cmt__CustomerInteraction__c WHERE Id IN: setCustomerInteractionIds]
        );
        
        Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, ContactId, OwnerId FROM Case WHERE Id IN: setCaseIds]);
        
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