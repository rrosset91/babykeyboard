/**************************************************************************************************************
* IBM - Bluewolf
* @author           Lucas Soldi (lucas.soldi@ibm.com)
* Project:          Solar
* Description:     
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-18     Lucas Soldi          	class created 
**************************************************************************************************************/
public without sharing class Solar_Cross_PriorityRoutingBatch implements Database.Batchable<sObject>,Database.stateful {
    public final String Query;
    public final Datetime minDate;
    public final Datetime maxDate;
    public final String priority;
    public final String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    public set<id> allFailedId=new set<id>();
    public set<id> allSuccessId=new set<id>();
	public Boolean sendEmail = false;    
    
    public Solar_Cross_PriorityRoutingBatch(Datetime minDate, Datetime maxDate, String priority){
        this.minDate = minDate;
        this.maxDate = maxDate;
        this.priority = priority;
        System.debug('min Date: '+minDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        System.debug('min Date: '+maxDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        
        this.Query = 'SELECT Id FROM Case WHERE CreatedDate >='+minDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') +' AND CreatedDate <='+ maxDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' AND isClosed = false AND RecordTypeId = \'' + recordTypeId+'\'';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<PendingServiceRouting> newlstPendingService = new List<PendingServiceRouting>();
        set<String> oldPendingService = new set<String>();

        //filtrar também por tipo de registro financeiro
        Map<Id,Case> mapCases = new Map<Id,Case>((List<case>)scope); 
        Map<String, PendingServiceRouting> lstServiceRoutin = new map<String,PendingServiceRouting>([SELECT Id,CapacityWeight, ServiceChannelId,IsReadyForRouting,Name, OwnerId,RoutingType,WorkItemId,RoutingPriority,RoutingModel FROM PendingServiceRouting WHERE WorkItemId IN :mapCases.keyset()]);
        //Clone PendingServiceRouting and 
        for(PendingServiceRouting objServiceRouting : lstServiceRoutin.values()){
            PendingServiceRouting newObjPendingService = new PendingServiceRouting();
            newObjPendingService =  objServiceRouting.clone(false,false,false,true);
            newObjPendingService.RoutingPriority = Integer.valueOf(priority);
            newObjPendingService.IsReadyForRouting = false;
            newlstPendingService.add(newObjPendingService); 
        }

        Map<String,String> mapSkills = new map<String,String>();
        List<SkillRequirement> lstNewSkillRequisite = new List<SkillRequirement>();

        List<SkillRequirement> lstSkillRequirement = [SELECT Id, RelatedRecordId,RelatedRecord.Name,SkillId FROM SkillRequirement WHERE RelatedRecordId IN : lstServiceRoutin.keyset()];

        for(SkillRequirement objSkill: lstSkillRequirement){
            mapSkills.put(objSkill.RelatedRecord.Name, objSkill.SkillId);
        }

        Savepoint sp = Database.setSavepoint();
        try{
            delete lstServiceRoutin.values();

            insert newlstPendingService;

            List<PendingServiceRouting> toBeUpdatedPendingService = new List<PendingServiceRouting>();
            for(PendingServiceRouting objServiceRouting : newlstPendingService){
                SkillRequirement objSkillRec =  new SkillRequirement();
                objSkillRec.SkillId = mapSkills.get(objServiceRouting.name);
                objSkillRec.RelatedRecordId = objServiceRouting.Id;
                lstNewSkillRequisite.add(objSkillRec);
                objServiceRouting.IsReadyForRouting = true;
                toBeUpdatedPendingService.add(objServiceRouting);
            }

            //Insert Skill Requisite
            insert lstNewSkillRequisite;
            
            if(!toBeUpdatedPendingService.isEmpty()){
                database.SaveResult[] myResult = database.update(toBeUpdatedPendingService,false);
                for(Integer i=0; i < myResult.size(); i++) {
                    if(myResult.get(i).isSuccess()) {
                        allSuccessId.add(toBeUpdatedPendingService.get(i).Id);
                    } 
                    else if(!myResult.get(i).isSuccess()) {
                        Database.Error errors =  myResult.get(i).getErrors().get(0);
                        allFailedId.add(toBeUpdatedPendingService.get(i).Id);
                    }
                }
            }else{ 
                //Just in case of we have no records, it prevent the system from locking the functionality
                System.debug('force eror:');
                toBeUpdatedPendingService[0].RoutingPriority = 0;
            }           


        }catch(Exception e){
            Database.rollBack(sp);
            sendEmail = true;
            if(!Test.isRunningTest())
                throw e;
        }

    }
    
    public void finish(Database.BatchableContext BC){

        if(sendEmail || allFailedId.size() > 0){

            Integer total = allFailedId.size()+allSuccessId.size();
            String[] emailAddress = Label.Solar_Cross_PriorityEmailSenders.split(';');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddress);
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('Status processo repriorização: ');
            mail.setPlainTextBody('Seu processo de repriorização foi realizado:\n\nNúmero de sucessos: ' + allSuccessId.size() + '\nNúmero de falhas: ' + allFailedId.size() +' \nTotal: ' + total);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}