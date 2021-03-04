@isTest
public class CEC_PME_BatchLimiteExpOppTest {
    @testSetup static void charge(){ 
        
        //Tipo de registro
        Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id recTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_PME').getRecordTypeId();
        
        Account accnt = new Account(RecordTypeId = recTypeAccount, 
                                    Name = 'Teste', 
                                    CommercialSegment__c = 'Televendas AACE');
        
        insert accnt;
        
		Opportunity oppt = new Opportunity(RecordTypeId = recTypeOpp, 
                               Name = 'CEC_PME_BatchLimiteExpOppTest', 
                               StageName = 'Em andamento', 
                               CloseDate = Date.today().addDays(1), 
                               Expiration_Date__c = Date.today().addDays(-1),
                               CommercialSegment__c = 'AACE', 
                               AccountId = accnt.Id);   
        insert oppt;
        
        oppt.Expiration_Date__c = Date.today().addDays(-1);
        update oppt;
        
        /*
        
        //usuário com perfil específico
        User us = createUser('www.usuario76253.com@gmail.com', 'Televendas PME');
        insert us;
        
        Account acct = createAccount(recTypeAccount, 'CEC_PME_BatchLimiteExpOrder', us.Id);
        insert acct;
        
        //lista para inserção
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Opportunity> lstOppOwner = new List<Opportunity>();
        
        for(Integer i = 0; i < 10; i++){
            lstOpp.add(createOpportunity(recTypeOpp, 'CEC_PME_BatchLimiteExpOppTest-' + i, 'Em andamento', 5, acct.Id));
        }
        
        for(Integer i = 0; i < 10; i++){
            lstOppOwner.add(createOpportunity(recTypeOpp, 'CEC_PME_BatchLimiteExpOppTest2-' + i, 'Em andamento', 5, us.Id, acct.Id));
        }
       
        insert lstOpp;
        
        System.runAs(us){
        	insert lstOppOwner;

        	lstOppOwner = [SELECT Expiration_Date__c, OwnerId FROM Opportunity WHERE OwnerId = :us.Id];
        
            for (Opportunity oppt : lstOppOwner) {
                oppt.Expiration_Date__c = Date.today().addDays(-1); 
            }
            
            update lstOppOwner;
        }*/
   
        //System.debug('Oportunidades inseridas com sucesso: ' + lstOpp);
    }
    
    //cria parâmetros
    /*private static Map<String, Object> createParams(){
        Map<String, Object> params = new Map<String, Object>();
        
        params.put('status', new List<String>{'Em andamento', 'Concluída'});
        params.put('profiles', new List<String>{'AA Claro Movel PME', 'AA NET Fixo PME', 'Televendas PME'});
        params.put('days', 0);
        params.put('expDate', Date.today());
        params.put('expDateProfile', Date.today());
        params.put('commercialSegments', new List<String>{'AACE', 'D2D', 'AA Claro Movel'});
        
        return params;
    }*/
    
    //cria objeto de oportunidade
    /*private static Opportunity createOpportunity(String recTypeId, String oppName, String stage, Integer days, String accountId){
        return new Opportunity(RecordTypeId = recTypeId, 
                               Name = oppName, 
                               StageName = stage, 
                               CloseDate = Date.today().addDays(days), 
                               Expiration_Date__c = Date.today().addDays(-1),
                               CommercialSegment__c = 'AACE', 
                               AccountId = accountId);
    }*/
    
    //cria objeto de oportunidade
    /*private static Opportunity createOpportunity(String recTypeId, String oppName, String stage, Integer days, String ownerId, String accountId){
        return new Opportunity(RecordTypeId = recTypeId, Name = oppName, 
                               StageName = stage, 
                               CloseDate = Date.today().addDays(days), 
                               Expiration_Date__c = Date.today().addDays(-1),
                               CommercialSegment__c = 'AACE',
                               OwnerId = ownerId, 
                               AccountId = accountId);
    }*/
    
    //cria usuário com perfil específico
    /*private static User createUser(String userName, String profileName){
        User us = new User();
        us.FirstName = 'Test ' + System.currentTimeMillis();
        us.LastName = 'Test LastName ' + System.currentTimeMillis();
        us.ProfileId = [SELECT id FROM Profile WHERE Name =: profileName].id;
        //us.UserRoleId = role.id;
        us.CommunityNickname = 'Dojead2minofdojo';
        us.Username = userName;
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.EmailEncodingKey = 'UTF-8';
        us.LanguageLocaleKey = 'en_US';
        us.LocaleSidKey = 'en_US';
        us.Title = 'Title';
        us.Alias = 'Alias';
        us.Email = 'dojedojo3@jmail.com';
        return us;
    }*/
    
    //cria objeto de conta
    /*private static Account createAccount(String recordTypeId, String accName, String ownerId){
        return new Account(RecordTypeId = recordTypeId, Name = accName, OwnerId = ownerId, CommercialSegment__c = 'Televendas AACE');
    }*/
     
    //inicia os testes
    @isTest static void testBatchOppExecute(){
        Test.startTest();       
        Database.executeBatch(new CEC_PME_BatchLimiteExpOpp());
        Test.stopTest();
        
        Opportunity oppt = [SELECT StageName FROM Opportunity LIMIT 1];
        System.assertEquals('Expirada', oppt.StageName);
    }
    
    //inicia os testes
    /*@isTest static void testBatchOppExecuteComPerfil(){
        Test.startTest();
        Database.executeBatch(new CEC_PME_BatchLimiteExpOpp());
        Test.stopTest();
        
        Opportunity oppt = [SELECT StageName FROM Opportunity LIMIT 1];
        System.assertEquals('Expirada', oppt.StageName);        
    }*/    
}