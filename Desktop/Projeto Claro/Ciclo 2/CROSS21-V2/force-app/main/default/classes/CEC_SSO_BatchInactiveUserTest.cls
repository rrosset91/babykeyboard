@isTest
private class CEC_SSO_BatchInactiveUserTest
{
    @testSetup static void doTheSetup()
    {
        User usuario1 = CEC_SobjectFactory.getUser();
        database.insert(usuario1);
    }
    
    @isTest static void testBatch()
    {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId = database.executeBatch(new CEC_SSO_BatchInactiveUser(null, null));
        test.stopTest();
        
        system.abortJob(lJobId);
        String user = 'teste@claro.com.br' + UserInfo.getOrganizationId();
        User usuario1 = [SELECT Id, IsActive FROM User WHERE Username = :user  limit 1];

    }
    
    @isTest static void testBatchErro1()
    {
        CEC_SSO_BatchInactiveUser.isTestingError = true;
        
        User lThisUsr = new User(Id = UserInfo.getUserId());
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId;
        system.runAs(lThisUsr)
        {
            lJobId = database.executeBatch(new CEC_SSO_BatchInactiveUser(null, null));
        }
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
        
        list<LogUser__c> lLstLog = [SELECT Id FROM LogUser__c WHERE User__r.UserName = 'teste@claro.com.br' limit 1];
    }
    
    @isTest static void testBatchErro2()
    {
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId = database.executeBatch(new CEC_SSO_BatchInactiveUser(null, null));
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
    }
    
    @isTest static void testSchedule()
    {
        Datetime lSch5 = system.now().addMinutes(5);
        String cron = '0 ' + String.valueOf(lSch5.minute()) + ' ' + String.valueOf(lSch5.hour()) + ' * * ?';
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId = system.schedule('Inativa usuario teste', cron, new CEC_SSO_BatchInactiveUser(null, null));
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
    }
    
    @isTest static void testScheduleJob(){
        String cron = '0 ' + '0 ' + '10 ' + '? ' + '* ' + '2-6';
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId = system.schedule('Inativa usuario teste', cron, new CEC_SSO_BatchInactiveUser(null, null));
        try
        {
            CEC_SSO_BatchInactiveUser.startJob();
        }
        catch(Exception ex)
        {
            //System.debug('#Erro agendamento ' + ex + ' Cause ' + ex.getCause());
            //Classe já está agendada no ambiente atual
            System.assert(ex.getMessage().contains('Inativar usuarios'));
        }
        test.stopTest();
        
        //Foi "Criado" um novo agendamento
        system.abortJob(lJobId);
        system.assert(lJobId != null);       
    }
    
    @isTest static void testScheduleExecute()
    {
       	List<User> aLstUsr = new List<User>();
       	User usuario1 = CEC_SobjectFactory.getUser();
       	aLstUsr.add(usuario1);
        
        CEC_SSO_BatchInactiveUser batch = new CEC_SSO_BatchInactiveUser('2019-11-01', '2019-11-30');
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        String lJobId = database.executeBatch(batch);
        batch.execute(null, aLstUsr);
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
    }
}