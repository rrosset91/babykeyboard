@isTest 
public class CEC_OpportunityTriggerTest {
    
    public static Opportunity builderOpportunity() {
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.Name = 'Test1';
        newOpportunity.StageName = 'Pedido Criado';
        newOpportunity.CloseDate = System.today().addDays(30);
        newOpportunity.AccountId = CEC_OrderTriggerTest.builderAccount().Id;      
        
        insert newOpportunity;
        return newOpportunity;
    }
    
	@testSetup
    public static void testSetup() {
        builderOpportunity();
    }
    
    @isTest
    public static void updLimiteExpTest() {
        Opportunity oppt = [SELECT StageName, CommercialSegment2__c FROM Opportunity];
        
        Test.startTest();
        oppt.StageName = 'Em andamento';
        update oppt;
        Test.stopTest();
    }    
}