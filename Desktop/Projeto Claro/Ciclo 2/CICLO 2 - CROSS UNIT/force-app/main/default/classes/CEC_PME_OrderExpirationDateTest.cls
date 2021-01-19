@isTest
public class CEC_PME_OrderExpirationDateTest {
	@testSetup
    public static void testSetup() {     
        Account accnt = new Account();
        
        accnt.name = 'Test1';
        accnt.CommercialSegment__c = 'AACE';
        
        insert accnt;
        
        Order order = new Order();
        
        order.Status = 'Em Andamento';
        order.EffectiveDate = System.today().addDays(30);
        order.AccountId = accnt.Id;      
        
        insert order;
    }
    
    @isTest
    public static void getLimiteExpTest() {
        List<Order> lstOrd = [SELECT Id, CreatorProfile__c, Segmento_Comercial__c, vlocity_cmt__ExpirationDate__c, Status FROM Order];
        Set<Id> setOrder = new Set<Id>();
        
        for (Order order : lstOrd) {
            setOrder.Add(order.Id);
        }
        
        Test.startTest();
        CEC_PME_OrderExpirationDate.getExpirationDate(setOrder);  
        Test.stopTest();
    }
    
    @isTest
    public static void updLimiteExpTest() {    
        List<Order> lstOrd = [SELECT Id, CreatorProfile__c,  Segmento_Comercial__c, vlocity_cmt__ExpirationDate__c, Status FROM Order];
        //Set<Id> setOrder = new Set<Id>();
        
        for (Order order : lstOrd) {
            order.vlocity_cmt__ExpirationDate__c = null;
            //setOrder.Add(order.Id);
        }
        
        update lstOrd;
        
        Test.startTest();
        //CEC_PME_OrderExpirationDate.updExpirationDate(setOrder);
        CEC_PME_OrderExpirationDate.updExpirationDate(lstOrd);
        Test.stopTest();
    }
}