@isTest
public class CEC_PME_IntegrationDocuSignEnvelopeTest {
	@testSetup public static void setup(){
        Account accnt = new Account();
        accnt.Name = 'Teste Envelope';
        insert accnt;
        
        Order order = new Order();
        order.Status = 'Em Andamento';
        order.EffectiveDate = System.today().addDays(-1);
        order.AccountId = accnt.Id;
        insert order;
        
        List<serviceParameter__c> lstParameter = new List<serviceParameter__c>();
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignCreateEnvelope';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes';
        serviceParameter.Method__c = 'POST';
        serviceParameter.Timeout__c = 120.000;
        
        lstParameter.add(serviceParameter);
        
        serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignGetTemplate';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/templates/{!templateId}';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        lstParameter.add(serviceParameter);
        
        serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignGetDocument';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/templates/{!templateId}/documents/{!documentId}';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        lstParameter.add(serviceParameter);        
        
        insert lstParameter;      
    }
    
    @isTest static void testDocSigEnvEmb()
    {
        CEC_PME_IntegrationDocuSignEnvelope docSigEnv;
		CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope respEnv;        
        
		CEC_PME_IntegrationDocuSignEnvelope.SendParameters sendParameters = new CEC_PME_IntegrationDocuSignEnvelope.SendParameters();
        
		List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> clients = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        clients.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient('Teste','test@test.com','RLSF#001'));
        
        List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> bos = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        bos.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient('BO','dbraga@deloitte.com', null));
        
        sendParameters.listClients = clients;        
        sendParameters.listUsersBackOffice = bos;
        sendParameters.accountId = '7277010';
        sendParameters.isSigningRequired = true;
        sendParameters.isEmbedded = true;
        sendParameters.templateId = '935bb54b-16e4-40de-9f4b-caf8bfb20a9c';  
		sendParameters.owner = new CEC_PME_IntegrationDocuSignEnvelope.Recipient('owner','dbraga@deloitte.com', null);
		sendParameters.orderId = String.valueOf([SELECT Id FROM Order Limit 1].Id);
        
        Test.startTest();
        
        docSigEnv = new CEC_PME_IntegrationDocuSignEnvelope();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        respEnv = docSigEnv.send(sendParameters);
        
        Test.stopTest();
    }
    
	@isTest static void testDocSigEnv()
    {
        CEC_PME_IntegrationDocuSignEnvelope docSigEnv;
		CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope respEnv;        
        
		CEC_PME_IntegrationDocuSignEnvelope.SendParameters sendParameters = new CEC_PME_IntegrationDocuSignEnvelope.SendParameters();
        
		List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> clients = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        clients.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient('Teste','test@test.com','RLSF#001'));
        
        List<CEC_PME_IntegrationDocuSignEnvelope.Recipient> bos = new List<CEC_PME_IntegrationDocuSignEnvelope.Recipient>();
        bos.add(new CEC_PME_IntegrationDocuSignEnvelope.Recipient('BO','dbraga@deloitte.com', null));
        
        sendParameters.listClients = clients;        
        sendParameters.listUsersBackOffice = bos;
        sendParameters.accountId = '7277010';
        sendParameters.isSigningRequired = true;
        sendParameters.isEmbedded = false;
        sendParameters.templateId = '935bb54b-16e4-40de-9f4b-caf8bfb20a9c';  
		sendParameters.owner = new CEC_PME_IntegrationDocuSignEnvelope.Recipient('owner','dbraga@deloitte.com', null);
		sendParameters.orderId = String.valueOf([SELECT Id FROM Order Limit 1].Id);
        
        Test.startTest();
        
        docSigEnv = new CEC_PME_IntegrationDocuSignEnvelope();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        respEnv = docSigEnv.send(sendParameters);
        
        Test.stopTest();
    }    
}