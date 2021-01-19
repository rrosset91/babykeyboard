@isTest
public class CEC_PME_IntegrationDocuSignEmbeddedTest { 
    @testSetup public static void setup(){
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignEmbedded';
        serviceParameter.Method__c = 'POST';
        serviceParameter.EndPoint__c = 'http://recipient';        
        serviceParameter.User__c = 'User';
        serviceParameter.Password__c = 'password';
        serviceParameter.Token__c = 'token';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter;
    }
    
    @isTest static void testDocSigEmb()
    {
        CEC_PME_IntegrationDocuSignEmbedded docSigEmb;
        String accntId = '001';
        String envId = '001';
        
        Test.startTest();
        
        docSigEmb = new CEC_PME_IntegrationDocuSignEmbedded();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        String lURL = docSigEmb.send(accntId, envId, new AccountContactRelation());
        System.assertEquals('https://demo.docusign.net/Signing/StartInSession.aspx?t=340b6b75-b904-4eb4-926d-044cafacdf94', lURL);
        
        Test.stopTest();
    }
}