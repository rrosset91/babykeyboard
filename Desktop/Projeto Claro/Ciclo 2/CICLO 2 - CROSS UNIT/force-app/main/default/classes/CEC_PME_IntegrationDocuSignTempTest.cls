@isTest
public class CEC_PME_IntegrationDocuSignTempTest {
	@testSetup public static void setup(){
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignGetTemplate';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/templates/{!templateId}';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter;
    }
    
    @isTest static void testDocSigTemp()
    {
        CEC_PME_IntegrationDocuSignTemplate docSigTemp;
        String tempId = '001';
        String accntId = '001';
        List<Object> lstObj;
        List<CEC_PME_IntegrationDocuSignObjectFactory.Document> lstDoc;
        
        Test.startTest();
        
        docSigTemp = new CEC_PME_IntegrationDocuSignTemplate();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        docSigTemp.send(tempId, accntId);
            
        lstObj = docSigTemp.getListSigners();
        lstDoc = docSigTemp.getListDocuments();
        
        Test.stopTest();
    }
}