/*
* Autor: Squad Canais Criticos - Sysmap
* Data: 17/08/2020
* Description: Processo batch para realizar o re-roteaomento dos casos de usuarios inativos
* ---------------------------------------------------------------
*/
global without sharing class CEC_CC_InativeUserCasesRouting implements Database.Batchable<SObject> {
    
    private static final String[] SUBSTATUS_QUERY = new String[] {'Encerrado'};

    private static final Set<String> RECORD_TYPES_CASES_CC = new Set<String>{
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_AtendimentoPessoal').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Canais_Eletronicos').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_ReaberturaAnatel').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId()
    };

    private Set<ID> userIds;

    global CEC_CC_InativeUserCasesRouting()
    {
         
    }

    global CEC_CC_InativeUserCasesRouting(Set<ID> userIds)
    {
         this.userIds = userIds;
    }
 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('CEC_CC_InativeUserCasesRouting Start');
        System.debug('User list:');
        System.debug(this.userIds);

        String query = 'SELECT Id FROM Case WHERE IsClosed = false AND SubStatus__c NOT IN :SUBSTATUS_QUERY AND Skill__c != null AND RecordTypeId IN :RECORD_TYPES_CASES_CC ';

        if(this.userIds != null && this.userIds.size() > 0) 
        {
            query += 'AND OwnerId IN :userIds';
        }
        else 
        {
            //Se nao tiver user id, busca pelos owners nos casos que estao inativos
            query += 'AND Owner.IsActive = false';
        }
 
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext bc, List<Case> lCases)
    {
         System.debug('CEC_CC_InativeUserCasesRouting Execute');
         System.debug('Case list:');
         System.debug(lCases);
         if(lCases != null && lCases.size() > 0)
         {
             //Realiza o roteamento dos casos usado a classe de roteamento por skill
             List<Id> lCasesIds = new List<Id>(new Map<Id,Case>(lCases).keySet());
             CEC_SkillsBasedRouting.routeUsingSkills(lCasesIds);
         }
    }
 
    global void finish(Database.BatchableContext bc)
    {
          System.debug('CEC_CC_InativeUserCasesRouting FINISH');
    }
 
    global static void startJob(Set<Id> userIds)
    {
        Database.executeBatch(new CEC_CC_InativeUserCasesRouting(userIds));
    }

}