/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe de teste para a controller CEC_360_MemoController.apxc.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*/

@isTest
public class CEC_360_MemoControllerTest {
    
    static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();    
    static ServiceParameter__c invService;
    
    static CEC_ServiceName__c csServiceName;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Memos';
        csServiceName.ServiceName__c = '/memos';
        Database.insert(csServiceName);
    }   
    
    static testMethod void getMsisnd(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ativo = new Asset();
        ativo.name = 'ast';
        ativo.AccountId = acc.id;
        ativo.MSISDN__c = '1199999999';
        insert ativo;
        
        Test.startTest();
        String msisdn = CEC_360_MemoController.getMsisdn(ativo.Id);
        System.assertEquals(msisdn,'1199999999');
        test.stopTest();
        
    }
    
    static testMethod void getMemosAssetTest(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ativo = new Asset();
        ativo.name = 'ast';
        ativo.AccountId = acc.id;
        ativo.MSISDN__c = '1199999999';
        insert ativo;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_MemoController.getMemosAsset(ativo.Id,'2019-01-01','2019-02-01');
        Test.stopTest();
        
    }
    
    static testMethod void getMemosContract(){
        Account acc = new Account(Name = 'Acc ');
        insert acc;
        
        Account accBilling = new Account(Name='AccBilling',recordTypeId = recTypeBillingAccount,
                                         ContractReferenceNumber__c = '119999999', parentId=acc.Id);
        insert accBilling;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_MemoController.getMemosContract(accBilling.Id,'2019-01-01','2019-02-01');
        Test.stopTest();
        
    }
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.memosMain memos = CEC_360_IntegrationMemos.generateMockMemosAssinante();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(memos, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
}