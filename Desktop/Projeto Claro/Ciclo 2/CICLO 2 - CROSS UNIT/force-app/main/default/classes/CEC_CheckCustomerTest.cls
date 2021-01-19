/*
* Autor: RLdO
* Data: 30-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe de teste e cobertura da classe CEC_CheckCustomer
> Henrique Almeida 
- Test Setup e testCheckExpiredOrderItens - 26/03
- addressCityTest - 28/05 
*/
@isTest
private class CEC_CheckCustomerTest 
{
    private static Id orderId;
    private static String cpf;
    @testSetup
    public static void testSetup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        
        
        User varUser = new User();
        varUser.FirstName = 'Omae';
        varUser.LastName = 'Inshidiro';
        varUser.Email = 'test@testing.com';
        varUser.Alias = 'NANI';
        varUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Vendedor Televendas' LIMIT 1].Id;
        varUser.Username = 'logical@mytologichal.com';
        varUser.Channel__c = 'TELEVENDAS';
        varUser.SalesTeamNET__c = 'CRN NACIONAL';
        varUser.NetServicos__c = '92037524';
        varUser.TimeZoneSidKey = 'GMT';
        varUser.LanguageLocaleKey = 'en_US';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.LocaleSidKey = 'en_US';
        insert varUser;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
        
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        insert varProduct;
        
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.TV_Grupo__c = 'G1A'; 
        varOrder.Fone_Grupo__c = 'G1';
        varOrder.Internet_Grupo__c = 'G1B';
        insert varOrder;
        
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        insert varEntryStd;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        insert varEntry;
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.Fidelidade__c = false;
        insert varItem;
        
        //Pricing_Matrix__c pricingMatrix = CEC_SobjectFactory.getMatrixCom(varProduct, 'G1');

        Id recordTypeId =Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Politica_Commercial').getRecordTypeId();
        
        Pricing_Matrix__c matrix = new Pricing_Matrix__c();
        matrix.RecordTypeId = recordTypeId;
        matrix.Duration__c = 0;
        matrix.Group__c = 'G1';
        matrix.Source_Product__c = varProduct.Id;
        matrix.Single__c = 35.99;
        matrix.Promotion__c = '30 R$';
        matrix.Double__c = 30.99;
        matrix.Triple__c = 25.90;
        matrix.Combo_Multi__c = 0;
        
        
        insert matrix;
        
        ServiceParameter__c newServiceParameter = new ServiceParameter__c();
        newServiceParameter.Name = 'GeoLocationNew';
        newServiceParameter.EndPoint__c = 'GeoLocationNew';
        newServiceParameter.Method__c = 'GeoLocationNew';
        newServiceParameter.Timeout__c = 10;
        insert newServiceParameter;
        
        ServiceParameter__c hpAnalysys = new ServiceParameter__c();
        hpAnalysys.Name = 'CreateHPAnalysis';
        hpAnalysys.EndPoint__c = 'https://test.createHPAnalysis.com';
        hpAnalysys.Method__c = 'POST';
        hpAnalysys.Timeout__c = 50000;
        insert hpAnalysys;
    }
    
    @isTest static void testProspect()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        String lCPFIn = '72194603093';
        lOptions.put('CPF', lCPFIn);
        lOptions.put('documentNumberCPF', lCPFIn);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        
        CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
        lInteg.invokeMethod('checkProspect', lInputMap, lOutMap, lOptions);
        
        Test.stopTest();
        
        Account lAcc = (Account)lOutMap.get('account');
        system.assert(lAcc != null);
    }
    
    @isTest static void testGetAddrList()
    {
        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        database.insert(lIbge);
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('uf', lIbge.UF__c);
        lInputMap.put('cidade', lIbge.CityName__c);
        lInputMap.put('cep', '01234-567');
        lInputMap.put('streetid', '13');
        lInputMap.put('domicileid', '1234');
        lInputMap.put('operatorCodeNet','003');
        lInputMap.put('domicileIdNet','1234');
        
        CEC_HttpCalloutMockImpl lMockImpl = new CEC_HttpCalloutMockImpl();
        
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, lMockImpl);
            
            CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
            for (Integer iHttpCode: new list<Integer>{ -1, 401, 200 })
            {
                lMockImpl.httpCode = iHttpCode;
                lInteg.invokeMethod('getAddressList', lInputMap, lOutMap, lOptions);
                lInteg.invokeMethod('getDomiciles', lInputMap, lOutMap, lOptions);
                lInteg.invokeMethod('getTechViability', lInputMap, lOutMap, lOptions);
            }
            Test.stopTest();
        }
        
        Object lAddrList = lOutMap.get('addressList'), lDomiciles = lOutMap.get('domiciles'),
            lTechViability = lOutMap.get('techViability');
        system.assert(lAddrList != null);
        system.assert(lDomiciles != null);
        system.assert(lTechViability != null);
    }
    
    @isTest static void testCred()
    {
        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3,
                                    IBGECode__c = '1', CityCode__c = 2);
        database.insert(lIbge);
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        map<String, String> lMapAcc = new map<String, String>{'CellPhone__c' => '11987654321',
            'Phone' => '1123456789', 'Email__c' => 'teste@dominio.com', 'BillingPostalCode' => '13060354',
            'Origin__c' => 'SEM ORIGEM', 'SalaryRange__c' => 'De R$3.000,00 ate R$4.000,00',
            'MothersName__c' => 'MAE PROSPECT', 'MaritalStatus__c' => 'Casado', 'Gender__c' => 'MASCULINO',
            'Schooling__c' => 'Ensino Superior', 'Occupation__c' => 'AUDITOR', 'RGEmitter__c' => 'SSP-SP',
            'RG__c' => '111111', 'DocumentType__c' => 'CPF', 'Name' => 'JOAO PROSPECT',
            'DocumentNumber__c' => '00000016195', 'BirthDate__c' => '1950-04-08T03:00:00.000Z',
            'BillingCity' => lIbge.CityName__c, 'BillingState' => lIbge.UF__c
            };
                lInputMap.put('conta', lMapAcc);
        lInputMap.put('nroprotocolo', system.now().format('yyyyMMddHHmmss'));
        
        Object lCredAnalysis;
        CEC_HttpCalloutMockImpl lMockImpl = new CEC_HttpCalloutMockImpl();
        
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, lMockImpl);
            
            CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
            for (Integer iHttpCode: new list<Integer>{ -1, 200 })
            {
                lMockImpl.httpCode = iHttpCode;
                lInputMap.put('servico', 'NET');
                lInteg.invokeMethod('getCreditAnalysis', lInputMap, lOutMap, lOptions);
                
                lCredAnalysis = lOutMap.remove('creditAnalysis');
                system.assert(lCredAnalysis != null);
                
                lInputMap.put('servico', 'MOVEL');
                lInteg.invokeMethod('getCreditAnalysis', lInputMap, lOutMap, lOptions);
                
                lCredAnalysis = lOutMap.remove('creditAnalysis');
                system.assert(lCredAnalysis != null);
            }
            Test.stopTest();
        }
    }
    
    @isTest static void testPortability()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('number', '11987654321');
       
        
        CEC_HttpCalloutMockImpl lMockImpl = new CEC_HttpCalloutMockImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMockImpl);
        
        CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
        for (Integer iHttpCode: new list<Integer>{ -1, 200 })
        {
            lMockImpl.httpCode = iHttpCode;
            lInteg.invokeMethod('getPortabilityOperator', lInputMap, lOutMap, lOptions);
        }
        Test.stopTest();
        
        Object lPortOperator = lOutMap.get('portabilityOperator');
        system.assert(lPortOperator != null);
    }
    
    @isTest static void testPortWindow()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        CEC_HttpCalloutMockImpl lMockImpl = new CEC_HttpCalloutMockImpl(-1);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMockImpl);
        
        CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
        for (Integer iHttpCode: new list<Integer>{ -1, 200 })
        {
            lMockImpl.httpCode = iHttpCode;
            lInteg.invokeMethod('getPortabilityWindows', lInputMap, lOutMap, lOptions);
        }
        Test.stopTest();
        
        Object lPortWindows = lOutMap.get('portabilityWindows');
        system.assert(lPortWindows != null);
    }
    
    @isTest static void testError()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        String lCPFIn = '72194603093';
        lOptions.put('CPF', lCPFIn);
        lOptions.put('documentNumberCPF', lCPFIn);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(-1));
        
        CEC_CheckCustomer lInteg = new CEC_CheckCustomer();
        Boolean lNoMethod = lInteg.invokeMethod(null, lInputMap, lOutMap, lOptions);
        lInteg.invokeMethod('checkProspect', lInputMap, lOutMap, lOptions);
        
        Test.stopTest();
        
        system.assert(!lNoMethod);
        Account lAcc = (Account)lOutMap.get('account');
        system.assert(lAcc != null);
    }
    @isTest static void testCheckExpiredOrderItens()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id FROM Order];
        lInputMap.put('cartId', (String)varOrder.Id);
        
        Test.startTest();
        
        CEC_CheckCustomer controller1 = new CEC_CheckCustomer();
        Boolean returnFalse = controller1.invokeMethod('getExpiredOrderItens', lInputMap, lOutMap, lOptions);
        
        Product2 varProduct = [SELECT Id, isActive FROM Product2];
        varProduct.IsActive = false;
        update varProduct;
        
        CEC_CheckCustomer controller2 = new CEC_CheckCustomer();
        Boolean returnTrue = controller2.invokeMethod('getExpiredOrderItens', lInputMap, lOutMap, lOptions);
        
        system.assert(lOutMap.get('error') != null);
        
        Test.stopTest();
    }
    @isTest static void testCheckOrderOwner()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id, OwnerId FROM Order];
        
        lInputMap.put('cartId', (String)varOrder.Id);
        lInputMap.put('OrderId', (String)varOrder.Id);
        Test.startTest();
        
        CEC_CheckCustomer controller1 = new CEC_CheckCustomer();
        controller1.invokeMethod('criptoCartId', lInputMap, lOutMap, lOptions);
        
        system.assert(lOutMap.get('cartIdCripto') != null);
        
        Test.stopTest();
    }
    
    @isTest static void testOrderStatus()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id, Status FROM Order];
        varOrder.Status = 'Cancelada';
        update varOrder;
        
        lInputMap.put('cartId', (String)varOrder.Id);
        
        Test.startTest();
        
        CEC_CheckCustomer controller1 = new CEC_CheckCustomer();
        Boolean returnTrue = controller1.invokeMethod('getExpiredOrderItens', lInputMap, lOutMap, lOptions);
        
        system.assert(lOutMap.get('error') != null);
        
        
        Test.stopTest();
    }
    @isTest static void testupdateDadosVendedor()
    {     
        // Setup user
        User varUser = [SELECT Id, Claro__c FROM User Where FirstName = 'Omae' LIMIT 1];
        varUser.Claro__c = '92037524';
        update varUser;        

        System.runAs(varUser) {
            IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
            database.insert(lIbge);            
        }        
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id FROM Order];
        lInputMap.put('cartId', (String)varOrder.Id); 

        Test.startTest();              
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        lOptions.put('cidade', 'SAO PAULO');
        Boolean returnTrue = controller.invokeMethod('updateDadosVendedor', lInputMap, lOutMap, lOptions);
        
        varUser = [SELECT Id, Channel__c FROM User Where FirstName = 'Omae' LIMIT 1];
        system.assertEquals('TELEVENDAS', varUser.Channel__c );
        
        Test.stopTest();
    }
    @isTest static void testupdateDadosVendedorNet()
    {       
        // Setup user
        User varUser = [SELECT Id, SalesTeamNET__c FROM User  Where FirstName = 'Omae' LIMIT 1];
        varUser.NetServicos__c = '92037524'; 
        update varUser;
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('operatorCode', '003');        
        lInputMap.put('login', 'IISOARES');
        lOptions.put('cidade', 'SAO PAULO');
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnTrue = controller.invokeMethod('updateDadosVendedor', lInputMap, lOutMap, lOptions);           
        
        varUser = [SELECT Id, SalesTeamNET__c FROM User  Where FirstName = 'Omae' LIMIT 1];
        system.assertEquals('CRN NACIONAL', varUser.SalesTeamNET__c);
        
        Test.stopTest();
    }  
    @isTest static void testupdateDadosVendedorFederation()
    {       
        // Setup user
        User varUser = [SELECT Id, Claro__c , SalesTeamNET__c, FederationIdentifier FROM User  Where FirstName = 'Omae' LIMIT 1];
        varUser.Claro__c = null;
        varUser.NetServicos__c = null;
        varUser.FederationIdentifier = '0001';
        update varUser;
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id FROM Order];
        lInputMap.put('cartId', (String)varOrder.Id); 
        
        lInputMap.put('operatorCode', '003');        
        lInputMap.put('login', 'IISOARES');
        lOptions.put('cidade', 'SAO PAULO');
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl());
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnTrue = controller.invokeMethod('updateDadosVendedor', lInputMap, lOutMap, lOptions);           
        
        varUser = [SELECT Id, SalesTeamNET__c, Channel__c FROM User  Where FirstName = 'Omae' LIMIT 1];
        system.assertEquals('TELEVENDAS', varUser.Channel__c );
        system.assertEquals('CRN NACIONAL', varUser.SalesTeamNET__c);
        
        Test.stopTest();
    }    
    
    @isTest static void testGetDadosVendedorResidencial()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('login', 'T1037791');
        lInputMap.put('operatorCode', '11');
        lOptions.put('CPF', '048.773.370-32');
        
        Test.startTest();
        
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        
        //for (Integer iHttpCode: new list<Integer>{ -1, 200, 404, 500 })
        for (Integer iHttpCode: new list<Integer>{200})
        {
            Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(iHttpCode));
            if(iHttpCode == 404)
            {
                Boolean returnValue = controller.invokeMethod('', lInputMap, lOutMap, lOptions);
                system.assertEquals(lOutMap.get('error'), null);
            }
            else if(iHttpCode == 500)
            {
                Boolean returnValue = controller.invokeMethod('QualquerCoisa', lInputMap, lOutMap, lOptions);
                system.assertEquals(lOutMap.get('error'), null);
                
            }
            else if(iHttpCode == 200)
            {
                Boolean returnValue = controller.invokeMethod('getDadosVendedorResidencial', lInputMap, lOutMap, lOptions); 
                system.assertEquals(lOutMap.get('error'), null);
            }
            else if(iHttpCode == -1)
            {
                Boolean returnValue = controller.invokeMethod('getDadosVendedorResidencial', lInputMap, lOutMap, lOptions); 
                system.assertEquals(lOutMap.get('error'), null);
            }
        }
        
        Test.stopTest();
    }
    @isTest static void testGetHistoryProposal()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('operatorCode', 'N123456');
        lInputMap.put('idProposal', '1234');
        
        Test.startTest();
        
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        
        for (Integer iHttpCode: new list<Integer>{ -1, 200, 404, 500 })
        {
            Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(iHttpCode));
            if(iHttpCode == 404)
            {
                Boolean returnValue = controller.invokeMethod('', lInputMap, lOutMap, lOptions);
                system.assertNotEquals(lOutMap.get('error'), null);
            }
            else if(iHttpCode == 200)
            {
                Boolean returnValue = controller.invokeMethod('getHistoryProposal', lInputMap, lOutMap, lOptions); 
                system.assertNotEquals(lOutMap.get('error'), null);
            }
            else if(iHttpCode == -1)
            {
                Boolean returnValue = controller.invokeMethod('getHistoryProposal', lInputMap, lOutMap, lOptions); 
                system.assertNotEquals(lOutMap.get('error'), null);
            }
        }
        
        Test.stopTest();
    }
    @isTest static void testGetDomicileHistory()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('operatorCode', 'N123456');
        lInputMap.put('idDomicile', '1234');
        
        Test.startTest();
        
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        
        for (Integer iHttpCode: new list<Integer>{ -1, 200, 404, 500 })
        {
            Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(iHttpCode));
            if(iHttpCode == 404)
            {
                Boolean returnValue = controller.invokeMethod('', lInputMap, lOutMap, lOptions);
                system.assertNotEquals(lOutMap.get('error'), null);
            }
            else if(iHttpCode == 200)
            {
                Boolean returnValue = controller.invokeMethod('getDomicileHistory', lInputMap, lOutMap, lOptions); 
                system.assertNotEquals(lOutMap.get('error'), null);            }
            else if(iHttpCode == -1)
            {
                Boolean returnValue = controller.invokeMethod('getDomicileHistory', lInputMap, lOutMap, lOptions); 
                system.assertNotEquals(lOutMap.get('error'), null);            }
        }
        
        Test.stopTest();
    }
    @isTest static void testGetCity()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        database.insert(lIbge);
        
        lInputMap.put('zipCode', '04914020');
        lInputMap.put('pageSize', '1');
        lInputMap.put('pageNumber', '1');
        lInputMap.put('cidade', 'SAO PAULO');
        lInputMap.put('uf', 'SP');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller1 = new CEC_CheckCustomer();
        Boolean returnTrue = controller1.invokeMethod('getCity', lInputMap, lOutMap, lOptions);
        
        system.assertEquals((String)lOutMap.get('uf'), 'SP');
        
        Test.stopTest();
    }
    @isTest static void testGetCityError()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('zipCode', '04914020');
        lInputMap.put('pageSize', '1');
        lInputMap.put('pageNumber', '1');
        
        Test.startTest();
        CEC_CheckCustomer controller1 = new CEC_CheckCustomer();
        Boolean returnTrue = controller1.invokeMethod('getCity', lInputMap, lOutMap, lOptions);
        
        system.assert((String)lOutMap.get('error') != null);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testDeleteCartItens()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
        
        lInputMap.put('OrderId', lstOrder[0].Id);
        
        Test.startTest();
        
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        
        Boolean returnValue = controller.invokeMethod('deleteCartItens', lInputMap, lOutMap, lOptions); 
        List<OrderItem> lstItemOrder = [SELECT Id FROM OrderItem LIMIT 1];
        system.assertEquals(lstItemOrder.size(), 0);
        Test.stopTest();
    }
    //LB - Modelo de dados para teste de preenchimento do método
    public class robotTest{
        public String sIdVenda {get; set;}
        public String sCPF {get; set;}
    }
    //LB - Cria massa de produtos, order, order item e pricebook
    static private testmethod void testProductSetup(){
        
        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='Claro Pos Play 10GB', ProductCode = 'COM_POS_10GB_000001', vlocity_cmt__Type__c = 'Plano');
        sObjList.add(prod1);
        
        insert new ServiceParameter__c(Name = 'ProposalDXC', EndPoint__c = 'https://teste.com', Method__c = 'POST');
        
        insert sObjList;
        sObjList.clear();
        
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
        insert testPricebook;
        
        //Inserting into standard Pricebook
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                  Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe11);
        //insert sObjList;
        
        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);
        
        insert sObjList;
        sObjList.clear();
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        
        Account a = new Account(Name='Account Test', BirthDate__c = Date.newInstance(1977,11,30), Gender__c = 'Feminino', 
                                MothersName__c = 'mãe', Email__c = 'teste@dtt.com', DocumentNumber__c = '08808327388', MaritalStatus__c = 'Casado', DocumentType__c = 'CPF',
                                Occupation__c = 'ASSISTENTE COMERCIAL', SalaryRange__c = 'De R$3.000,00 ate R$4.000,00', Phone = '1158967584');
        cpf = a.DocumentNumber__c;
        insert a;
        
        Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(), Forma_de_Pagamento__c='Boleto',
                                    status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, NovoEndereco__c = true, 
                                    BillingNumber__c = '233', NumeroHP__c = '1234567864', BillingStreet = 'RUA A', Complemento1__c = '12342123',
                                    Complemento2__c = '12342123', Complemento3__c = '12342123',
                                    Complemento4__c = '12342123', Pricebook2Id = testPricebook.Id, BillingPostalCode ='04836250');
        insert testOrder;
        orderId = testOrder.Id;
        
        List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;
        
        OrderItem odtem = new OrderItem();
        odtem.OrderId = testOrder.Id;
        odtem.PricebookEntryId = pbe1.Id;
        odtem.Fidelidade__c = true;
        odtem.Quantity = 1;
        odtem.vlocity_cmt__LineNumber__c = '0001';
        odtem.UnitPrice = 100;
        odtem.vlocity_cmt__ProvisioningStatus__c = 'New';
        sObjList.add(odtem);
        
        insert sObjList;
    }
    //LB -Método de teste da classe CEC_SendToRobotController
    static testmethod void getObjects(){
        Test.startTest();
        testProductSetup();
        
         map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Order varOrder = [SELECT Id FROM Order WHERE Name ='Test Order'];
        lInputMap.put('OrderId', varOrder.Id);
        lInputMap.put('cartId', varOrder.Id);
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnValue = controller.invokeMethod('getObjectToRobot', lInputMap, lOutMap, lOptions);
        Boolean returnValue2 = controller.invokeMethod('getInstallments', lInputMap, lOutMap, lOptions);
        
        system.assertEquals(lOutMap.get('error'), null);
        
        Test.stopTest();
    }
        @isTest static void testCreateHP()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        database.insert(lIbge);
        
        map<String, Object> obj = new map<String, Object>();
        
        lInputMap.put('description1', 'Vita');
        lInputMap.put('name1', 'ACAD');
        lInputMap.put('description2', '03');
        lInputMap.put('name2', 'BL');
        lInputMap.put('description3', 'GIRASSOL');
        lInputMap.put('name3', 'AND');
        lInputMap.put('description4', '03');
        lInputMap.put('name4', 'LT');
        lInputMap.put('cidade', 'SAO PAULO');
        lInputMap.put('uf', 'SP');
        lInputMap.put('neighborhoodId', '19269');
        lInputMap.put('streetId', '11919');
        lInputMap.put('streetNr', '1822');
        lInputMap.put('cityId', '88412');
        lInputMap.put('buildingType', 'U');
        lInputMap.put('buildingId', '300054455');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnTrue = controller.invokeMethod('createNewHP', lInputMap, lOutMap, lOptions);
        system.assertEquals(lOutMap.get('error'), null);
         
        
        Test.stopTest();
    }

    @isTest static void testCreateHPAnalysis(){
        Map<String, Object> lInputMap = new map<String, Object>();
        Map<String, Object> lOutMap = new map<String, Object>();
        Map<String, Object> lOptions = new map<String, Object>();
        
        lInputMap.put('buildingId', 'SAO PAULO');
        lInputMap.put('proposalId', 'SAO PAULO');
        lInputMap.put('id', 'SAO PAULO');
        lInputMap.put('placeId', 'SAO PAULO');
        lInputMap.put('cityId', 'SAO PAULO');
        lInputMap.put('city', 'SAO PAULO');
        lInputMap.put('neighborhood', '19269');
        lInputMap.put('postalCode', '19269');
        lInputMap.put('streetName', '11919');
        lInputMap.put('streetNr', '1822');
        lInputMap.put('note', '88412');
        lInputMap.put('clientName', 'U');
        lInputMap.put('areaCode', '300054455');
        lInputMap.put('name1', '');
        lInputMap.put('name2', '');
        lInputMap.put('name3', '');
        lInputMap.put('name4', '');
        lInputMap.put('number', '257');
        lInputMap.put('description1', '');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnTrue = controller.invokeMethod('createNewHPAnalysis', lInputMap, lOutMap, lOptions);
        System.assertEquals(lOutMap.get('error'), null);
        
        Test.stopTest();
    }

    @isTest static void testSendProposal()
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Test.startTest();
        testProductSetup();
        lInputMap.put('OrderId', [SELECT Id FROM Order WHERE Name ='Test Order'].Id);
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean returnTrue = controller.invokeMethod('sendProposal', lInputMap, lOutMap, lOptions);
        system.assertNotEquals(lOutMap.get('error'), null);
         
        
        Test.stopTest();
    }
	@isTest static void testBillingCycles()
    {
		insert new ServiceParameter__c(Name = 'BillingCycles', EndPoint__c = 'http://200.169.123.170:9000/corp/billingcycles', Method__c = 'GET');        
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean retorno = controller.invokeMethod('getBillingCycles', lInputMap, lOutMap, lOptions);
        system.assert(retorno != null);
        
        Test.stopTest();
    } 
	@isTest static void testBillingCyclesInit()
    {
		CEC_IntegrationBillingCycles.BillingCycle bc = new CEC_IntegrationBillingCycles.BillingCycle('0001', 'Teste', 'true', '15', '20', 'Type', 'Subtype');              
		CEC_IntegrationBillingCycles.BillingCyclesResponse bcResponse = CEC_IntegrationBillingCycles.testResponse();        
    } 
	@isTest static void testPortabilityPre()
    {
		insert new ServiceParameter__c(Name = 'PreAnalysisPortability', EndPoint__c = 'http://200.169.123.170:9000/corp/portabilities/preanalysis', Method__c = 'POST');        
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('number', '19999000000');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_CheckCustomer controller = new CEC_CheckCustomer();
        Boolean retorno = controller.invokeMethod('portabilitiesPreAnalysis', lInputMap, lOutMap, lOptions);
        system.assert(retorno != null);
        
        Test.stopTest();
    } 
	@isTest static void testPortabilityPreRmv()
    {
		insert new ServiceParameter__c(Name = 'PreAnalysisPortability', EndPoint__c = 'http://200.169.123.170:9000/corp/portabilities/preanalysis', Method__c = 'POST');        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_IntegrationPortabilitiesPreAnalysis integration = new CEC_IntegrationPortabilitiesPreAnalysis();
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis response = integration.consultar('19999000000', false);
        
        Test.stopTest();
    } 
    
    @isTest static void cartValidated() {
        CEC_CheckCustomer.cartValidated(new Map<String, Object>{'cartId'=>[SELECT Id FROM Order LIMIT 1].Id},new Map<String, Object>{},
                                          new Map<String, Object>{});
    }
    
    @isTest static void getProducts() {
        CEC_CheckCustomer.getProducts('', '');
    }
}