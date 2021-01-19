/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-29-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_FutureMobileIntegrationTest {

    public static String rtFinancial = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    @testSetup 
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('https://api-test.claro.com.br/mobile/v1/customers/calls/historicals', 'get', 'mobileCallHistoricals', 'Basic OE9ZUENOUDluQXoybzZQWnRCYk9TTWhNcjY4eTVKN1o6RlpKZmdWRWdNNWlEUEdabg=='));
        insert params;

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ContractReferenceNumber__c = '11940309000';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = rtFinancial;
        insert caso;
    }

    @isTest
    private static void makeCalloutMobileTest(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion":"1;2020-10-02","transactionId":"96dd1a35-6a3d-49d0-9121-c169ee1c25ce","data":{"historicals":[{"callId":"200","dateBill":"2020-10-02","dateCall":"2019-01-28T14:00:00","destinationNumber":"43883944","operator":"CLARO","durationCall":0.5,"measuredUnit":"MINUTOS","callType":"LOCAL","chargingType":"NORMAL","priceValue":0.45,"value":23.45,"icmsValue":0.05,"totalValue":23.5,"typeEvent":"Chamadas Locais1","destiny":"Su00e3o Paulo","source":"1191000000","mobileBan":"654321","accountDate":"2019-01-28T14:00:00"}]}}', 200));
        Case objCase = [SELECT ContractBillingAccount__c, ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case WHERE RecordTypeId =: rtFinancial];
        Test.startTest();
            Map<String,Object> mapReturn = Solar_Cross_FutureMobileIntegration.makeCalloutMobile(objCase,6);
        Test.stopTest();
    }

    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String Token){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.Token__c = Token;
        param.Timeout__c = 120000;
        return param;
    }  
}