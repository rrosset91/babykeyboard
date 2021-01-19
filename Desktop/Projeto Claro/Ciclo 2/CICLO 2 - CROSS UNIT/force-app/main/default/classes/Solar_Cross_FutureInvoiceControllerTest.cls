/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-30-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-30-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public  class Solar_Cross_FutureInvoiceControllerTest {

    @testSetup 
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('https://api-test.claro.com.br/residential/v1/customers/financialaccounts', 'get', 'historyEvents', 'MCIDAS'));
        insert params;

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.BusinessUnit__c = 'NET';
        contrato.CityCode__c = '004';
        contrato.ContractReferenceNumber__c = '12345';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        insert caso;
    }

    @isTest
    static void getContractIdTest(){
        Case caso = [SELECT Id, ContractBillingAccount__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case LIMIT 1];
        Case objCaseRet;
        Test.startTest();
        objCaseRet = Solar_Cross_FutureInvoiceController.getContractId(caso.Id);
        Test.stopTest();
       // System.assertEquals('004000012345',objCaseRet);

    }

    @isTest
    static void getHistoryEventsTest(){
        Case caso = [SELECT Id, ContractBillingAccount__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"billDocumentList":[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]}', 200));
        Test.startTest();
        Map<String,Object> mapRet = new Map<String,Object>();
        mapRet = Solar_Cross_FutureInvoiceController.getHistoryByPeriod(caso.ContractBillingAccount__r.ContractNumber__c,'FUTURE_RELEASE',24);
        Test.stopTest();
        System.assertEquals(false,mapRet.isEmpty());
    }

    @isTest
    static void getHistoryEvents2Test(){
        Case caso = [SELECT Id, ContractBillingAccount__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('["billDocumentList",[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]]', 200));
        Test.startTest();
        Map<String,Object> mapRet = new Map<String,Object>();
        mapRet = Solar_Cross_FutureInvoiceController.getHistoryByPeriod(caso.ContractBillingAccount__r.ContractNumber__c,'FUTURE_RELEASE',24);
        Test.stopTest();
        System.assertEquals(false,mapRet.isEmpty());
    }

    @isTest
    static void getHistoryEventsErrorTest(){
        Case caso = [SELECT Id, ContractBillingAccount__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"billDocumentList":[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]}', 400));
        Test.startTest();
        Map<String,Object> mapRet = new Map<String,Object>();
        mapRet = Solar_Cross_FutureInvoiceController.getHistoryByPeriod(caso.ContractBillingAccount__r.ContractNumber__c,'FUTURE_RELEASE',24);
        Test.stopTest();
        System.assertEquals(false,mapRet.isEmpty());
    }

    @isTest
    static void callCorrectIntegrationTestNotMobile(){
        Case caso = [SELECT Id, ContractBillingAccount__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.ContractNumber__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"billDocumentList":[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]}', 400));
        Test.startTest();
        Map<String,Object> mapRet = new Map<String,Object>();
        mapRet = Solar_Cross_FutureInvoiceController.callCorrectIntegration(caso,false);
        Test.stopTest();
        System.assertEquals(false,mapRet.isEmpty());

    }

    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String userName){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = userName;
        param.Timeout__c = 120000;
        return param;
    }  
}