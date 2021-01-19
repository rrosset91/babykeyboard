@isTest
public class CEC_PME_SendToBackOfficeControllerTest {
    
    @testSetup
    public static void testSetup() {
        Account newAccount = new Account();
        newAccount.Name = 'Test';
        insert newAccount;
        
        Order newOrder = new Order();
        newOrder.Status = 'Contrato Assinado';
        newOrder.EffectiveDate = Date.today().addDays(1);
        newOrder.AccountId = newAccount.Id;
        newOrder.Pricebook2Id = test.getStandardPricebookId();
        newOrder.Name = 'test';
        
        insert newOrder;
    }

    @isTest
    public static void mainTest() {
        Test.startTest();
        
        ApexPages.StandardController standard = new ApexPages.StandardController([SELECT Id FROM Order LIMIT 1]);
        
        CEC_PME_SendToBackOfficeController controller = new CEC_PME_SendToBackOfficeController(standard);
        controller.init();
        String message = controller.message;
        Test.stopTest();
    }
    
    @isTest
    public static void errorId() {
        Test.startTest();
        
        ApexPages.StandardController standard = new ApexPages.StandardController(new Order());
        
        CEC_PME_SendToBackOfficeController controller = new CEC_PME_SendToBackOfficeController(standard);
        controller.init();
        Test.stopTest();
    }
    @isTest
    public static void errorStatus() {
        Test.startTest();
        Order selectOrder = [SELECT Id, Status FROM Order LIMIT 1];
        selectOrder.Status = 'Em Andamento';
        update selectOrder;
        
        ApexPages.StandardController standard = new ApexPages.StandardController(selectOrder);
        
        CEC_PME_SendToBackOfficeController controller = new CEC_PME_SendToBackOfficeController(standard);
        controller.init();
        Test.stopTest();
    }
    
    
}