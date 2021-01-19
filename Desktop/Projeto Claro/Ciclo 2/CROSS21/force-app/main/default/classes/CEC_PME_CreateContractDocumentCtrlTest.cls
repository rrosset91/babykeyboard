@isTest
public class CEC_PME_CreateContractDocumentCtrlTest {
    
    @testSetup
    public static void testSetup() {
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Smith';
        insert newAccount;
        
        /*Order newOrder = new Order();
        newOrder.status = 'draft';
        newOrder.AccountId = newAccount.Id;
        newOrder.EffectiveDate = Date.today();
        insert newOrder;
        newOrder.Status = 'Aguardando criação contrato';
        update newOrder;*/
        
		//criação de product2, pricebook2 e pricebookentry
        Product2 prod = createProduct();
        insert prod;
        
        Pricebook2 pbook = createPriceBook();
        insert pbook;
        
        Id pbookStandardId = Test.getStandardPricebookId();
        
        PriceBookEntry pbookEntry = createPriceBookEntry(prod.Id, pbookStandardId);
        insert pbookEntry;
        
		//pedidos
        Order order = new Order();
        OrderItem orderItem = new OrderItem();
        
        order = createOrder('Name Order', 'draft', 0, newAccount.id, pbookStandardId);
        insert order;

        orderItem = createOrderItem(order.Id, pbookEntry.Id, prod.Id);
        insert orderItem;
        
        order.Status = 'Aguardando criação contrato';
        update order;       
        
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_SalesDocuments';        
        serviceParameter.User__c = 'APP_TESTE';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '';  
        serviceParameter.EndPoint__c = 'http://200.169.123.170:9000/corp/salesdocuments';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter; 
    }
    
    @isTest
    public static void mainTest() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_SalesDocumentsServiceMock());
        
        ApexPages.StandardController standard = new ApexPages.StandardController([SELECT Id FROM Order]);
        
        CEC_PME_CreateContractDocumentController controller = new CEC_PME_CreateContractDocumentController(standard);
        controller.init();
        Test.stopTest();
    }
    
    @isTest
    public static void errorNull() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_SalesDocumentsServiceMock());
        
        ApexPages.StandardController standard = new ApexPages.StandardController(new Order());
        
        CEC_PME_CreateContractDocumentController controller = new CEC_PME_CreateContractDocumentController(standard);
        controller.init();
        Test.stopTest();
    }
    
//cria objeto de pedido
    private static Order createOrder(String orderName, String statusName, Integer days, String accountId, Id pbookId){       
        return new Order(Status = statusName,
                         EffectiveDate = Date.today().addDays(days),
                         AccountId = accountId, 
                         Pricebook2Id = pbookId,
        				 Name = orderName                      
                        );
    }
    
    //cria objeto order item
    private static OrderItem createOrderItem(Id orderId, Id pbookId, Id prodId) {
        OrderItem od = new OrderItem();
        if (orderId != null) {
            od.OrderId = orderId;
        }
        od.UnitPrice = 5;
        od.Quantity = 2;
        od.Product2Id = prodId;
        od.PriceBookEntryId = pbookId;
        
        return od;
    }
    
    //cria obj product2
    private static Product2 createProduct() {
        Product2 prod = new Product2(Name = 'testProduct2', ProductCode = 'PME_PlanoClaroTotalIndividual_0001');
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
}