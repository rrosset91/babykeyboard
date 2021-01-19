/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-01-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-01-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_OutageMovelTest {
    
    @TestSetup
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('callout:APIClaroResidential/billingaccounts/outageperiods', 'GET', 'MobileOutages', 'Basic OTlBTm5BdzBRTHN2Y2F4QmRHQUU1UldoSlpQdXd0QUc6YlR4aGdHOEM4NXRkN1N1Yw=='));
        insert params;

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ContractReferenceNumber__c = '11940309';
        contrato.BusinessUnit__c = 'Claro';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        insert caso;
    }


    @isTest
    static void callIntegationTest(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion": "1","transactionId": "Id-2d0384f0823434","data":{"impact": true,"expectedRegularizationDt": "2019-10-31T10:10:10-03:00"}}', 200));
        Account objContract = [SELECT Id FROM Account WHERE ExternalID__c = 'Contratot123' LIMIT 1];
        Case objCase = [SELECT Id,ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c FROM Case WHERE ContractBillingAccount__c = : objContract.Id LIMIT 1];
        Test.startTest();
            Map<String,Object> mapReturn = Solar_Cross_OutageMovel.getOutagesMobile(objCase.Id);
        Test.StopTest();
        System.assertEquals(true,mapReturn.get('success'));

    }

    @isTest
    static void callIntegationTestError(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion": "1","transactionId": "Id-2d0384f0823434","data":{"impact": true,"expectedRegularizationDt": "2019-10-31T10:10:10-03:00"}}', 422));
        Account objContract = [SELECT Id FROM Account WHERE ExternalID__c = 'Contratot123' LIMIT 1];
        Case objCase = [SELECT Id,ContractBillingAccount__r.BusinessUnit__c,ContractBillingAccount__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c FROM Case WHERE ContractBillingAccount__c = : objContract.Id LIMIT 1];
        Test.startTest();
            Map<String,Object> mapReturn = Solar_Cross_OutageMovel.getOutagesMobile(objCase.Id);
        Test.StopTest();
        System.assertEquals(false,mapReturn.get('success'));
    }



    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String Token){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.Token__c = Token;
        param.Timeout__c = 120000;
        param.User__c =   'APP_TESTE';
        param.Password__c = 'claro#123';
        return param;
    }  



}