@isTest
public class CEC_PME_IntegrationDocuSignDocTest {
	@testSetup public static void setup(){
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignGetDocument';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/templates/{!templateId}/documents/{!documentId}';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter;
    }
    
    @isTest static void testDocSigEmb()
    {
        CEC_PME_IntegrationDocuSignDocument docSig;
        String tempId = '001';
        String docId = '001';
        String accntId = '001';
        
        Test.startTest();
        
        docSig = new CEC_PME_IntegrationDocuSignDocument();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        String lResp = docSig.send(tempId, docId, accntId);
        System.assertEquals('test', lResp);
        
        Test.stopTest();
    }
}