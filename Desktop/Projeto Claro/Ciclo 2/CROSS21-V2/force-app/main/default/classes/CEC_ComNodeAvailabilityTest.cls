@isTest
public class CEC_ComNodeAvailabilityTest {



    @TestSetup
    static void setupNodeAvailabity(){
        Account newAccount = new Account();
        newAccount.name = 'Test1';
        insert newAccount;

        Product2 produto = new Product2();
        produto.Name = '50 MB';
        produto.ProductCode = '001';
        produto.vlocity_cmt__Type__c = 'Plano';
        insert produto;
        
        Product2 produtoRestricao = new Product2();
        produtoRestricao.Name = '50 REST MB';
        produtoRestricao.ProductCode = '50_REST_001';
        produtoRestricao.vlocity_cmt__Type__c = 'Plano';
        insert produtoRestricao;

        List<Order> lstOrder = new List<Order>();
        Order ord = new Order();
        ord.City__c = 'Massachussets Brasileira';
        ord.Node__c = 'TECNIC';
        ord.AccountId = newAccount.id;
        ord.Status = 'Em Andamento';
        ord.EffectiveDate = System.today();

        Order ord2 = new Order();
        ord2.City__c = 'Green Hill Zone';
        ord2.Node__c = 'SONIC';
        ord2.AccountId = newAccount.id;
        ord2.Status = 'Em Andamento';
        ord2.EffectiveDate = System.today();

        lstOrder.add(ord);
        lstOrder.add(ord2);
        insert lstOrder;

        List<Group_Set__c> lstGroupSet = new List<Group_Set__c>();
        Group_Set__c gSetNode = new Group_Set__c();
        gSetNode.City__c = 'Green Hill Zone';
        gSetNode.Node__c = 'SONIC';
        gsetNode.Start_Date__c = System.today().addDays(-2);
        gSetNode.RecordTypeId = Schema.SObjectType.Group_Set__c.getRecordTypeInfosByName().get('Node').getRecordTypeId();
        lstGroupSet.add(gSetNode);

        Group_Set__c gsetCity = new Group_Set__c();
        gsetCity.City__c = 'Massachussets Brasileira';
        gsetCity.Start_Date__c = System.today().addDays(-2);
        gsetCity.RecordTypeId =  Schema.SObjectType.Group_Set__c.getRecordTypeInfosByName().get('City').getRecordTypeId();
        lstGroupSet.add(gsetCity);
        system.debug('cidade>>'+gsetCity);
        insert lstGroupSet;

        List<vlocity_cmt__ProductAvailability__c> lstAvailability = new List<vlocity_cmt__ProductAvailability__c>();
        vlocity_cmt__ProductAvailability__c ordAvailability = new vlocity_cmt__ProductAvailability__c();
        ordAvailability.Type__c = 'Available';
        ordAvailability.Group_Set__c = gSetNode.id;
        ordAvailability.Family__c = 'Internet Fixa';
        ordAvailability.vlocity_cmt__Product2Id__c = produto.id;
        lstAvailability.add(ordAvailability);

        vlocity_cmt__ProductAvailability__c ordAvailability2 = new vlocity_cmt__ProductAvailability__c();
        ordAvailability2.Type__c = 'Available';
        ordAvailability2.Group_Set__c = gsetCity.id;
        ordAvailability2.Family__c = 'Internet Fixa';
        ordAvailability2.vlocity_cmt__Product2Id__c = produto.id;
        lstAvailability.add(ordAvailability2);
     
        
        vlocity_cmt__ProductAvailability__c ordAvailability3 = new vlocity_cmt__ProductAvailability__c();
        ordAvailability3.Type__c = 'Available';
        ordAvailability3.Group_Set__c = gSetNode.id;
        ordAvailability3.Family__c = 'Internet Fixa';
        ordAvailability3.vlocity_cmt__Product2Id__c = produtoRestricao.id;
        lstAvailability.add(ordAvailability3);

        insert lstAvailability;

    }


    @isTest
    static void getProductsIdWithNodeAvailable_CityTest(){
        Order ord = [SELECT Node__c, City__c FROM Order WHERE City__c = 'Massachussets Brasileira' AND Node__c = 'TECNIC' LIMIT 1];
        CEC_ComNodeAvailability nodeAvailability = new CEC_ComNodeAvailability();
        Map<String, Object> inputMap = new Map<String, Object>();
        Product2 produto = [SELECT id, Name FROM Product2 WHERE Name = '50 MB' LIMIT 1];
        inputMap.put('city',ord.City__c);
        inputMap.put('OrderId', ord.Id);
        inputMap.put('restricao', false);
        Set<Id> prodIDs = nodeAvailability.getProductsIdWithNodeAvailable(inputMap);
        System.assertEquals(true,prodIDs.contains(produto.id));

    }


    @isTest
    static void getProductsIdWithNodeAvailable_NodeTest(){
        Order ord = [SELECT Node__c, City__c FROM Order WHERE City__c = 'Green Hill Zone' AND Node__c = 'SONIC' LIMIT 1];
        CEC_ComNodeAvailability nodeAvailability = new CEC_ComNodeAvailability();
        Map<String, Object> inputMap = new Map<String, Object>();
        Product2 produto = [SELECT id, Name FROM Product2 WHERE Name = '50 MB' LIMIT 1];
        inputMap.put('city',ord.City__c);
        inputMap.put('OrderId', ord.Id);
        inputMap.put('restricao', false);
        Set<Id> prodIDs = nodeAvailability.getProductsIdWithNodeAvailable(inputMap);
        System.assertEquals(true,prodIDs.contains(produto.id));

    }
@isTest
    static void getProductsIdWithNodeAvailable_NodeTestRestricao(){
        Order ord = [SELECT Node__c, City__c FROM Order WHERE City__c = 'Green Hill Zone' AND Node__c = 'SONIC' LIMIT 1];
        CEC_ComNodeAvailability nodeAvailability = new CEC_ComNodeAvailability();
        Map<String, Object> inputMap = new Map<String, Object>();
        Product2 produto = [SELECT id, Name FROM Product2 WHERE Name = '50 REST MB' LIMIT 1];
        
        system.debug('PRODT: '+produto);
        inputMap.put('city',ord.City__c);
        inputMap.put('OrderId', ord.Id);
        inputMap.put('restricao', true);
        Set<Id> prodIDs = nodeAvailability.getProductsIdWithNodeAvailable(inputMap);
        System.assertEquals(true,prodIDs.contains(produto.id));

    }

    


}