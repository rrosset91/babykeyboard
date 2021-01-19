/*
* Autor: Squad Canais Criticos - Sysmap
* Data: 17/08/2020
* Description: Teste de cobertura para a classe CEC_InativeUserCasesRouting
* ---------------------------------------------------------------
*/
@isTest
private without sharing class CEC_CC_InativeUserCasesRoutingTest {

    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
    private static final String CEC_CC_ClaroContato = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ClaroContato').getRecordTypeId();
 
    @TestSetup
    private static void setup() {
 
         //Cria um usuario, depois cria alguns casos atrelados a ele e por fim desativa o usuario
 
         User us = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'dummy@gmail.com',
             Username = 'dummy@gmail.com.f' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
         );
         insert us;
 
         Account mainAccount = new Account(
         Name = 'Tony Stark',
         DocumentType__c = 'CPF',
         DocumentNumber__c = '714.607.567-20'
         );
         insert mainAccount;
 
         Account billingAccount = new Account(
             ContractReferenceNumber__c = '1234512345',
             BusinessUnit__c = 'Net',
             vlocity_cmt__Status__c = 'Ativo',
             vlocity_cmt__CustomerValue__c = 'PURPLE',
             CityCode__c = '003',
             Name = '003/1234512345',
             Type = 'Cliente',
             ParentId = mainAccount.Id
         );
         insert billingAccount;
 
         Contact contactDefault = new Contact(
             Gender__c = 'Masculino',
             DocumentType__c = 'CPF',
             Lastname = 'Stark',
             RecordTypeId = CEC_CC_ClaroContato
         );
         insert contactDefault;
 
         List<Case> cases = new List<Case>();
         Case casoOuvidoria1 = new Case(
             RecordTypeId = CEC_CC_Ouvidoria,
             AccountId = mainAccount.Id,
             ContractBillingAccount__c = billingAccount.Id,
             ContactId = contactDefault.Id,
             CriticalChannelOpenDate__c = DateTime.Now(),
             Status = 'New',
             SubStatus__c = 'Não Iniciado',
             ContactPreference__c = 'Whatsapp',
             Channel__c = 'Ouvidoria',
             InputType__c = 'Telefone',
             BusinessUnit__c = 'Claro DTH',
             Description = 'Testando Casos',
             OwnerId = us.Id,
             SupportArea__c = 'CEC_CC_Ouvidoria',
             Skill__c = 'Ouvidoria_OuvidoriaMovelPortal'
         );
         cases.add(casoOuvidoria1);
 
         insert cases;
 
 
    }
 
    @isTest
    private static void testRouting() {
 
        List<User> users = [SELECT Id, LastName, Email from User WHERE Email = 'dummy@gmail.com'];
        Set<Id> userIds = new Map<Id,User>(users).keySet();
 
        //Desativa os usuarios
        for(User us : users) {
           us.IsActive = false;           
        }
 
        List<Case> casesBeforeChangeOwner = [Select Id, OwnerId from Case where OwnerId IN :userIds];
        Set<Id> casesIds = new Map<Id,Case>(casesBeforeChangeOwner).keySet();
 
        update users;
 
        //Coloca o bloco do batch dentro do start para processar de forma sincrona
        Test.startTest();
            CEC_CC_InativeUserCasesRouting.startJob(userIds);
        Test.stopTest();
 
 
        List<PendingServiceRouting> casesPendingRouting = [Select WorkItemId from PendingServiceRouting where WorkItemId IN :casesIds];
 
        //Se tiver a mesma quantidade de itens pendentes de roteamento com a quantidade de casos, esta correto, o job jogou para o roteamento
        System.debug(String.format('CEC_CC_InativeUserCasesRoutingTest.testRouting: casesBeforeChangeOwner.size() = {0} , casesPendingRouting.size() = {1}', new Integer[] {casesBeforeChangeOwner.size(),casesPendingRouting.size()}));
 
        System.assert(casesBeforeChangeOwner.size() == casesPendingRouting.size(), 'Existem casos que não foram roteados.');
    }
     
}