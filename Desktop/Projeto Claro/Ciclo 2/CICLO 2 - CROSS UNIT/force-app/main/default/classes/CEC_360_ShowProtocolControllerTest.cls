/*
* Autor: [Cintia Sousa e Vitor Araújo] + Squad V360 - Deloitte
* Data: [16/12/2019]
* Descrição: [Nome do projeto/ID: CEC FASE Extensão 1 ] 
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
@isTest
public class CEC_360_ShowProtocolControllerTest {  
    
    @isTest
    public static void getContracBusinessUnitTest() {
        
        Account acc = new Account(Name = 'AccPrincipal');
        insert acc;
        
        Test.startTest();
        CEC_360_ShowProtocolController.getContracBusinessUnit(acc.Id);
        Test.stopTest();        
    }
    
    @isTest
    public static void getAssetsByBillingAccount() {
        
        Account acc = new Account(Name = 'AccPrincipal');
        insert acc;
        Asset ass = new Asset(Name = 'assPrincipal', AccountId = acc.Id, businessunit__c = 'Claro', msisdn__c = '11954434501',
                              vlocity_cmt__BillingAccountId__c = acc.Id);
        insert ass;
        
        Test.startTest();
        CEC_360_ShowProtocolController.getAssetsByBillingAccount(acc.Id);
        Test.stopTest();        
    }
    
    static testMethod void getOrdemsfromData(){
        Account acc = new Account(Name = 'Acc',
                                  ContractReferenceNumber__c = '004/34933869',
                                  CityCode__c = '003');
        insert acc;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ShowProtocolController.integrationProtocolsResidential('2017-01-01', '2017-06-01', acc.Id);
        Test.stopTest();
    }
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.Protocols lstOcurrences = CEC_360_IntegrationMobileProtocols.generateMock();
            String body = JSON.serialize(lstOcurrences, true);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }        
    }
    
    static testMethod void getOrdemsMovDataTest(){
        Account acc = new Account(Name = 'Acc'
                                 );
        insert acc;
        Asset ass = new Asset(Name = 'Ass',
                              msisdn__c = '11954434501',
                              AccountId = acc.Id
                             );
        insert ass;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint());
        CEC_360_ShowProtocolController.integrationMobileProtocols('2017-01-01', '2017-06-01', '11954434501');
        Test.stopTest();
    }   
    
}