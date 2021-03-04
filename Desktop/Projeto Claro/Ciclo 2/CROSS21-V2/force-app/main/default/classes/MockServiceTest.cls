@isTest
public with sharing class MockServiceTest {
    @testSetup static void charge(){
        List<ServiceParameter__c> lstServices = new List<ServiceParameter__c>();
		ServiceParameter__c eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'Invoices';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'SendDuplicate';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'PostDuplicate';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'InvoiceDetails';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'InvoiceElegibility';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'InvoiceAuthority';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);
        
        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetBillDebts';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetRequestFees';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetCustomerPpv';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetOutAge';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetOccurrence';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetReadjustments';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'GetNewProducts';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        lstServices.add(eventsSettings);


		insert lstServices;        
    }

    @isTest
    private static void MockServiceTest() {
        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('contractNumber', '229531991');
        queryParams.put('contractNumber', '229531991');
        queryParams.put('operatorCode', '229531991');
        queryParams.put('billId', '229531991');
        queryParams.put('invoiceId', '229531991');
        queryParams.put('contractId', '1027935');
        for (ServiceParameter__c service : [SELECT Name, Method__c FROM ServiceParameter__c]) {
            Map<String, String> mock = new MockService(queryParams, service.Method__c).getMock(service.Name);
            System.debug('MockServiceTest:: '+service.Name+' ==>'+ mock.containsKey('statusCode'));
            System.assertEquals(true, mock.containsKey('statusCode'));
        }

        
    }

    @isTest
    private static void MockServiceTestError() {
        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('contractNumber', '0');
        queryParams.put('contractNumber', '0');
        queryParams.put('operatorCode', '0');
        queryParams.put('billId', '0');
        queryParams.put('invoiceId', '0');
        queryParams.put('contractId', '0');
        for (ServiceParameter__c service : [SELECT Name, Method__c FROM ServiceParameter__c]) {
            Map<String, String> mock = new MockService(queryParams, service.Method__c).getMock(service.Name);
            
            System.debug('MockServiceTestError:: '+service.Name+' ==>'+ mock.containsKey('statusCode'));
            // System.assertEquals('400', mock.get('statusCode'));
        }

        
    }
}