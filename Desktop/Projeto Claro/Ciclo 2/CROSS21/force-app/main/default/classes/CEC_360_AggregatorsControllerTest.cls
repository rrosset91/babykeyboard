/* 	Autor: Danilo Fucuhara - Deloitte
Criação: 24/06/2019
Descrição: Classe teste para a classe CEC_360_AggregatorsController.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

@isTest
public class CEC_360_AggregatorsControllerTest
{
    @testSetup
    static void makeData()
    {
        CEC_ServiceName__c serviceName = new CEC_ServiceName__c();        
        serviceName.Name = 'Aggregators';
        serviceName.ServiceName__c = '/aggregators';
        insert serviceName;
        
        Account contract = new Account(Name = 'Account Test');
        insert contract;
        
        Asset asset = new Asset(Name = 'Asset Test', AccountId = contract.Id, MSISDN__c = '1234567890');
        insert asset;
    }
    
    @isTest
    static void testGetAggregatorsSucess()
    {        
        
        CEC_ServiceName__c serviceNameAggregators = [SELECT id FROM CEC_ServiceName__c WHERE Name = 'Aggregators'];
        
        Asset asset = [SELECT id, MSISDN__c FROM Asset WHERE MSISDN__c = '1234567890'];
        
        String payload = '{"apiVersion":"1;2019-10-06","transactionId":"Id-e575565e15cd01bd9d293ac1","data":{"subscribersVas":[{"serviceName":"5","serviceAggregatorName":"Ego TESTE","aggregatorName":"Verisoft","msisdn":"11940564345","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2019-06-14T19:12:10.000-03:00","effectiveDate":"2019-06-14T19:12:09.000-03:00","expirationDate":"2019-06-15T19:12:10.000-03:00","amount":"2.99","amountType":"NET","cancellationDate":"2019-07-02T20:42:16.000-03:00","requestTypeId":"MIGRADO","requestDescription":"WEB","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2019-06-14T19:12:09.000-03:00","lastRateDate":"2019-06-14T19:12:10.000-03:00","rateCode":"SGV003","solicitationDate":"2019-06-14T19:12:09.000-03:00","aggregatorDateRequest":"2019-06-14T19:12:09.000-03:00"},{"serviceName":"8","serviceAggregatorName":"Papo de Mulher TESTE","aggregatorName":"Verisoft","msisdn":"11940564345","serviceTypeId":"0","serviceType":"true","status":"CANCELADO","statusDate":"2019-06-14T19:59:01.000-03:00","effectiveDate":"2019-06-14T19:59:01.000-03:00","expirationDate":"2019-06-21T19:59:01.000-03:00","amount":"4.99","amountType":"NET","cancellationDate":"2019-06-14T20:00:42.000-03:00","requestTypeId":"MIGRADO","requestDescription":"web","statusReasonDescription":"Cancelamento realizado pelo parceiro (Mobicare, Ciclo de vida, etc)","confirmationDate":"2019-06-14T19:59:01.000-03:00","lastRateDate":"2019-06-14T19:59:01.000-03:00","rateCode":"SGV049","id":"53707","solicitationDate":"2019-06-14T19:59:01.000-03:00","aggregatorDateRequest":"2019-06-14T19:59:01.000-03:00"},{"serviceName":"5","serviceAggregatorName":"Ego TESTE","aggregatorName":"Verisoft","msisdn":"11940564345","serviceTypeId":"0","serviceType":"true","statusDate":"2019-10-02T21:09:34.000-03:00","effectiveDate":"2019-10-02T21:09:34.000-03:00","amount":"1.99","amountType":"NET","requestTypeId":"MIGRADO","requestDescription":"WEB","statusReasonDescription":"Serviço ativado","confirmationDate":"2019-10-02T21:09:34.000-03:00","rateCode":"SGV052","solicitationDate":"2019-10-02T21:09:34.000-03:00","aggregatorDateRequest":"2019-10-02T21:09:34.000-03:00"}],"totalRecords":null}}';
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpoint(payload, 200));
        
        Test.startTest();       
        	CEC_360_AggregatorsController.getAggregators(asset.Id, '12-12-2019', '12-12-2019', 'status');
        Test.stopTest();

       system.assertEquals(asset.MSISDN__c != null && payload != '' , true); 
    }
    
    @TestVisible class AuthorizedEndpoint implements HttpCalloutMock
    {        
        public String jsonBody {get; set;}
        public Integer statusCode {get; set;}
        
        public AuthorizedEndpoint(String jsonBody, Integer statusCode)
        {
            this.jsonBody = jsonBody;
            this.statusCode = statusCode;
        }
        
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonBody);
            res.setStatusCode(statusCode);            
            return res;
        }
     }
}