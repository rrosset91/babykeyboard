/* 	Autor: Danilo Fucuhara - Deloitte
   	Criação: 22/03/2019
   	Descrição:Classe para interfacear a busca via integração de Saldos.
   	Nome do projeto/ID: CEC FASE - Time: SQUAD 360. 
	Alterações: US17541(17/05/19)  
<!-- Alterações: Ajuste do botao aparecer para asset NET(12/06/19) -->*/

@isTest
private class CEC_360_BalanceControllerTest { 
    
    static CEC_ServiceName__c csServiceName;
    static CEC_ServiceName__c devService;
    
    static {
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Balances';
        csServiceName.ServiceName__c = '/balances';
        Database.insert(csServiceName);
        
        csServiceName = new CEC_ServiceName__c();
        csServiceName.Name = 'Transactions';
        csServiceName.ServiceName__c = '/transactions';
        Database.insert(csServiceName);        
        
        devService = new CEC_ServiceName__c();
        devService.Name = 'Devices';
        devService.ServiceName__c = '/devices';
        insert devService;
        
    }     
    
    static testMethod void testGetSObject() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        Test.startTest();
        CEC_360_BalanceController.getSObject(ast.Id, 'Asset');
        Test.stopTest();
    }
    
    static testMethod void testGetRecordType(){
        Account acc = new Account();
        acc.name = 'Acc1';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'Asset Test';
        ast.AccountId = acc.Id;
        ast.MSISDN__c = '1234567890';
        ast.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();
        insert ast;
        
        Asset ast2 = new Asset();
        ast2.Name = 'Asset Test2';
        ast2.AccountId = acc.Id;
        ast2.MSISDN__c = '1234567880';
        ast2.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECTV').getRecordTypeId();
        insert ast2;
        
        Test.startTest();
        CEC_360_BalanceController.getRecordType(ast.id);
        CEC_360_BalanceController.getRecordType(ast2.id);
        Test.stopTest();
    }
    
    static testMethod void testGetBusinessUnit(){
        Account acc = new Account();
        acc.name = 'Acc1';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'Asset Test';
        ast.AccountId = acc.Id;
        ast.MSISDN__c = '1234567890';
        insert ast;
        
        Test.startTest();
        CEC_360_BalanceController.getBusinessUnit(ast.id);
        Test.stopTest();
    }
    
    static testMethod void testGetBalance1() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointBalances1());
        CEC_360_BalanceController.getBalance(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetBalance2() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id);
        insert ast;
        
        Test.startTest();
        CEC_360_BalanceController.getBalance(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionsLast1() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointTransactions());
        CEC_360_BalanceController.getTransactionsLast(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionsLast2() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id);
        insert ast;
        
        Test.startTest();
        CEC_360_BalanceController.getTransactionsLast(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionsPeriod1() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointTransactions());
        CEC_360_BalanceController.getTransactionsPeriod(ast.Id, '2019-01-01', '2019-01-01', 'RECARGAS', 'Recarga');
        Test.stopTest();
    }
    
    static testMethod void testGetTransactionsPeriod2() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id);
        insert ast;
        
        Test.startTest();
        CEC_360_BalanceController.getTransactionsPeriod(ast.Id, '2019-01-01', '2019-01-01', 'RECARGAS', 'Recarga');
        Test.stopTest();
    }
    
    static testMethod void testGetOtherBalances() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointBalances1());
        CEC_360_BalanceController.getOtherBalances(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetOtherBalancesPromotional1() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointBalances1());
        CEC_360_BalanceController.getOtherBalancesPromotional(ast.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetOtherBalancesPromotional2() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
        Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
              
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointBalances2());
        CEC_360_BalanceController.getOtherBalancesPromotional(ast.Id);
        Test.stopTest();
    }
	
    static testMethod void testGetDevice() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        
       	Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890');
        insert ast;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedEndpointDevices());
        CEC_360_BalanceController.getDevice(ast.Id);
        Test.stopTest();
    }
    
    @TestVisible class AuthorizedEndpointBalances1 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.BalancesMain lstBalances = CEC_360_IntegrationBalances.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstBalances, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestVisible class AuthorizedEndpointBalances2 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.BalancesMain lstBalances = CEC_360_IntegrationBalances.generateMock();
            
            CEC_RestObjects.PromotionalBalances promo = new CEC_RestObjects.PromotionalBalances();
            promo.platformIdentification = '2';
            promo.platformDescription = 'BONUS INTRA-REDE';
            promo.measurementUnit = 'REAIS';
            promo.balance = '10';
            
            lstBalances.data.balances.promotionalBalances.add(promo);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstBalances, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestVisible class AuthorizedEndpointTransactions implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.Transactions lstBalances = CEC_360_IntegrationTransactions.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(lstBalances, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestVisible class AuthorizedEndpointDevices implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            CEC_RestObjects.subscriberLastDeviceResponse mainDevice = CEC_360_IntegrationDevices.generateMock();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(mainDevice, true));
            res.setStatusCode(200);
            return res;
        }
    }
    
}