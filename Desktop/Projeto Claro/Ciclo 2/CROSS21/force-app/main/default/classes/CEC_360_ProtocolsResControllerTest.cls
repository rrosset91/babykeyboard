@isTest
public class CEC_360_ProtocolsResControllerTest {
    
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Interactions';
        csServiceName.ServiceName__c = '/interactions';
        Database.insert(csServiceName);
    }  
    
    
    
    static testMethod void getContracts(){
        Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Account accT = new Account();
        accT.name = 'parentId';
        insert accT;
        
        Account acc = new Account();
        acc.name = 'son1';
        acc.RecordTypeId = recTypeBillingAccount;
        acc.ParentId = accT.id;
        acc.ContractReferenceNumber__c = '12345';
        acc.CityCode__c = '003';
        insert acc;
        
        Test.startTest();
        CEC_360_ProtocolsResidentialController.getContracts(accT.id);
        Test.stopTest();
    }
    
    
    static testMethod void getProtocols (){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ProtocolsResidentialController.getProtocols('003/1234567','2019-01-01','2019-01-02');
        Test.stopTest(); 
    }
    
    static testMethod void getProtocolsNumber (){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ProtocolsResidentialController.getProtocolsNumber('003','123456780');
        Test.stopTest(); 
    }
    
    static testMethod void formatData (){
        Test.startTest();
        List<CEC_RestObjects.attendences> lstAtt = CEC_360_ProtocolsResidentialController.generateMock();
        CEC_360_ProtocolsResidentialController.formatData(lstAtt);
        Test.stopTest();
    }
    
    static testMethod void getDetails(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        List <CEC_RestObjects.attendences> fullProtocols = CEC_360_ProtocolsResidentialController.getDetails('123456789', '123456789');
        Test.stopTest();
    }
    
    static testMethod void formatDetails(){
        Test.startTest();
        List<CEC_RestObjects.attendences> lstAtt = CEC_360_ProtocolsResidentialController.generateMock();
        lstAtt = CEC_360_ProtocolsResidentialController.formatDetails('102', lstAtt);
        test.stopTest();
    }
    
    
    @TestVisible class UnauthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint');
            throw e;
        }
        
    }
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.Protocols lstProtocols = CEC_360_Integration_ProtocolsResidential.generateMock();
            String body = JSON.serialize(lstProtocols, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
        
    }
}