@isTest
public class CEC_PME_BatchLimiteExpOrderTest {
    
    @testSetup static void charge(){
        //usuário com perfil específico
        User us = createUser('www.usuario432763.com@gmail.com', 'Televendas PME', 'Televendas PME');
        insert us;
        
        //usuário com perfil específico
        User us2 = createUser('www.usuario4327624.com@gmail.com', 'AACE PME', 'AACE PME');
        insert us2;
        
        //Tipos de registro
        Id recTypeOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('PME_Order').getRecordTypeId();
        Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        
        //conta para os pedidos
        Account acct = createAccount(recTypeAccount, 'CEC_PME_BatchLimiteExpOrder', us.Id);
        insert acct;
        
        //conta para os pedidos
        Account acct2 = createAccount(recTypeAccount, 'CEC_PME_BatchLimiteExpOrder2', us2.Id);
        insert acct2;
        
        //criação de product2, pricebook2 e pricebookentry
        Product2 prod = createProduct();
        insert prod;
        
        Pricebook2 pbook = createPriceBook();
        insert pbook;
        
        Id pbookStandardId = Test.getStandardPricebookId();
        
        PriceBookEntry pbookEntry = createPriceBookEntry(prod.Id, pbookStandardId);
        insert pbookEntry;
        
        //pedidos
        List<Order> lstOrders = new List<Order>();
        List<Order> lstOrders2 = new List<Order>();
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        List<OrderItem> lstOrderItems2 = new List<OrderItem>();
        
        for(Integer i = 0; i < 10; i++){
            lstOrders.add(createOrder(recTypeOrder, 'Em Andamento', 0, acct.Id, us.Id, pbookStandardId));
        }
        for(Integer i = 0; i < 10; i++){
            lstOrders2.add(createOrder(recTypeOrder, 'Em Andamento', 0, acct2.Id, us2.Id, pbookStandardId));
        }
        
        System.runAs(us){
            insert lstOrders;
            for (Order od : lstOrders) {
                lstOrderItems.add(createOrderItem(od.Id, pbookEntry.Id));
            }
            insert lstOrderItems;
            update lstOrders;
        }
        
        System.runAs(us2){
            insert lstOrders2;
            for (Order od : lstOrders2) {
                lstOrderItems2.add(createOrderItem(od.Id, pbookEntry.Id));
            }
            insert lstOrderItems2;
            update lstOrders2;
        }
        
        System.debug('pedidos: ' + lstOrders);
    }
    
    //inicia os testes em lote
    @isTest static void testBatchOrderExecute(){
        Test.startTest();
        Database.executeBatch(new CEC_PME_BatchLimiteExpOrder());
        Test.stopTest();
        
        Order order = [SELECT Status FROM Order LIMIT 1];
        System.assertEquals('Pedido Expirado', order.Status);
    }
    
    //cria parâmetros
    /*private static Map<String, Object> createParams(){
        Map<String, Object> params = new Map<String, Object>();
        params.put('status', new List<String>{'Em Andamento', 'Concluída'});
        params.put('profiles', new List<String>{'Suporte PME', 'Televendas PME'});
        params.put('days', 0);
        params.put('expDate', Date.today());
        params.put('expDateProfile', Date.today());
        params.put('commercialSegments', new List<String>{'Suporte PME', 'Televendas PME'});
        System.debug('pedidos: ' + params);
        return params;
    }*/
    
    //cria objeto de pedido
    /*private static Order createOrder(String recordTypeId, String statusName, Integer days, String accountId){
        return new Order(RecordTypeId = recordTypeId,
                         Status = statusName,
                         EffectiveDate = Date.today().addDays(days),
                         AccountId = accountId);
    }*/
    
    //cria objeto de pedido
    private static Order createOrder(String recordTypeId, String statusName, Integer days, String accountId, String ownerId, Id pbookId){       
        return new Order(RecordTypeId = recordTypeId,
                         Status = statusName,
                         EffectiveDate = Date.today().addDays(days),
                         vlocity_cmt__ExpirationDate__c = Date.today().addDays(-1),
                         AccountId = accountId, 
                         OwnerId = ownerId,
                         Pricebook2Id = pbookId);
    }
    
    //cria objeto order item
    private static OrderItem createOrderItem(Id orderId, Id pbookId) {
        OrderItem od = new OrderItem();
        if (orderId != null) {
            od.OrderId = orderId;
        }
        od.UnitPrice = 5;
        od.Quantity = 2;
        od.PriceBookEntryId = pbookId;
        
        return od;
    }
    
    //cria obj product2
    private static Product2 createProduct() {
        Product2 prod = new Product2(Name = 'testProduct2');
        return prod;
    }
    
    //cria obj pricebook
    private static PriceBook2 createPriceBook() {
        PriceBook2 pb = new PriceBook2(Name='testPricebook2');
        return pb;
    }
    
    //cria obj pricebookentry
    private static PriceBookEntry createPriceBookEntry(Id prodId, Id pbookId) {
        PriceBookEntry pb = new PriceBookEntry(UnitPrice = 10, Product2Id = prodId, Pricebook2Id = pbookId);
        return pb;
    }
    
    //cria objeto de conta
    private static Account createAccount(String recordTypeId, String accName, String ownerId){
        return new Account(RecordTypeId = recordTypeId, Name = accName, OwnerId = ownerId);
    }
    
    //cria usuário com perfil específico
    private static User createUser(String userName, String profileName, String nickName){
        User us = new User();
        us.FirstName = 'Test ' + System.currentTimeMillis();
        us.LastName = 'Test LastName ' + System.currentTimeMillis();
        us.ProfileId = [SELECT id FROM Profile WHERE Name =: profileName].id;
        //us.UserRoleId = role.id;
        us.CommunityNickname = nickName;
        us.Username = userName;
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.EmailEncodingKey = 'UTF-8';
        us.LanguageLocaleKey = 'en_US';
        us.LocaleSidKey = 'en_US';
        us.Title = 'Title';
        us.Alias = 'Alias';
        us.Email = 'dojedojo3@jmail.com';
        return us;
    }
}