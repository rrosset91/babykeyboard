@isTest 
public class CEC_OrderTriggerTest {
    
    public static Account builderAccount() {
        Account newAccount = new Account();
        
        newAccount.name = 'Test1';
        newAccount.CommercialSegment__c = 'AACE';
        
        insert newAccount;
        return newAccount;
    }
    
    public static Order builderOrder() {
        Account newAccount = builderAccount();
        
        return builderOrder(newAccount.Id);
    }
    
    public static Order builderOrder(Id accountId) {
        Order newOrder = new Order();
        
        newOrder.Status = 'Em Andamento';
        newOrder.EffectiveDate = System.today().addDays(30);
        newOrder.AccountId = accountId;      
        
        insert newOrder;
        return newOrder;
    }
    
    @testSetup
    public static void testSetup() {     
        builderOrder();
    }
    
    @isTest
    public static void updLimiteExpTest() {
        Order order = [SELECT Status FROM Order];
        
        Test.startTest();
        order.Status = 'Em Andamento';
        update order;
        Test.stopTest();
    }
}