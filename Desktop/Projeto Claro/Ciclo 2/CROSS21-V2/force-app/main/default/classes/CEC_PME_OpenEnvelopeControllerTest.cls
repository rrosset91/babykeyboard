@isTest
public class CEC_PME_OpenEnvelopeControllerTest {

    @isTest
    public static void mainTest() {
        Test.startTest();
        Account newAccount = new Account();
        newAccount.Name = 'Test Smith';
        insert newAccount;

        Order newOrder = new Order();
        newOrder.status = 'Draft';
        newOrder.AccountId = newAccount.Id;
        newOrder.EffectiveDate = Date.today();
        newOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert newOrder;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'test';
        insert newProduct2;
        
        PricebookEntry newPricebookEntry = new PricebookEntry();
        newPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        newPricebookEntry.UnitPrice = 1;
        newPricebookEntry.Product2Id = newProduct2.Id;
        insert newPricebookEntry;
        
        OrderItem newOrderItem = new OrderItem();
        newOrderItem.UnitPrice = 1;
        newOrderItem.OrderId = newOrder.Id;
        newOrderItem.Quantity = 1;
        newOrderItem.PricebookEntryId = newPricebookEntry.Id;
        insert newOrderItem; 
        
        newOrder.Status = 'Contrato criado';
        update newOrder; 
        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        
        ApexPages.StandardController standard = new ApexPages.StandardController(newOrder);
        
        CEC_PME_OpenEnvelopeController controller = new CEC_PME_OpenEnvelopeController(standard);
        controller.open();
        Test.stopTest();
    }
}