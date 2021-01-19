@isTest
private class CEC_PME_IntegrationDocuSignRmvSgnrsTest {
    
    @testSetup
    static void setup(){
        Integration_Flow__c integrationFlow = new Integration_Flow__c();
        integrationFlow.AccountId__c = 'test';
        integrationFlow.TemplateId__c = 'test';
        insert integrationFlow;
        
        List<ServiceParameter__c> newParameters = new List<ServiceParameter__c>();
        
        ServiceParameter__c newServiceParameter1 = new ServiceParameter__c();
        newServiceParameter1.name = 'CEC_PME_DocuSignListRecipient';
        newServiceParameter1.User__c = 'Test';
        newServiceParameter1.Password__c = 'secretKey123!';
        newServiceParameter1.Token__c = '123456';
        newServiceParameter1.EndPoint__c = 'test';
        newServiceParameter1.Method__c = 'test';
        newServiceParameter1.Timeout__c = 2000.00;
        
        newParameters.add(newServiceParameter1);
        
        ServiceParameter__c newServiceParameter2 = new ServiceParameter__c();
        newServiceParameter2.name = 'CEC_PME_DocuSignDeleteRecipients';
        newServiceParameter2.User__c = 'Test';
        newServiceParameter2.Password__c = 'secretKey123!';
        newServiceParameter2.Token__c = '123456';
        newServiceParameter2.EndPoint__c = 'test';
        newServiceParameter2.Method__c = 'test';
        newServiceParameter2.Timeout__c = 2000.00;
        
        newParameters.add(newServiceParameter2);
        
        insert newParameters;        
        
        
        Account newAccount = new Account(
        Name = 'Test Account'
        );
        
        insert newAccount;

        Order newOrder = new Order(
        	Name = 'Test Order',
            AccountId = newAccount.id,
            EffectiveDate = Date.today(),
            Status = 'Em Andamento',
            DocuSignEnvelopeID__c = 'teste'
        );
                insert newOrder;

    }

    @isTest
    static void DocuSignIntegrationTest(){

        Order newOrder = [SELECT Id, Name FROM Order WHERE Name ='Test Order'];
        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
         Test.startTest();
		CEC_PME_IntegrationDocuSIgnRemoveSigners.SaveResult result = new CEC_PME_IntegrationDocuSignRemoveSigners(newOrder.Id).removeAllStatusSent();
        Test.stopTest();
    }
    
}