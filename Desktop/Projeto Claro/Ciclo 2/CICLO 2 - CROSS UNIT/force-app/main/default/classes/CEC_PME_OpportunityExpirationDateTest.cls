@isTest
public class CEC_PME_OpportunityExpirationDateTest {
	@testSetup
    public static void testSetup() {
        Account accnt = new Account();
        
        accnt.name = 'Test1';
        accnt.CommercialSegment__c = 'AACE';
        
        insert accnt;
        
        Opportunity oppt = new Opportunity();
        
        oppt.Name = 'Test1';
        oppt.StageName = 'Em andamento';
        oppt.CloseDate = System.today().addDays(30);
        oppt.AccountId = accnt.Id;      
        
        insert oppt;
    }
    
    @isTest
    public static void getLimiteExpTest() {
        List<Opportunity> lstOppt = [SELECT Id, CreatorProfile__c, CommercialSegment2__c, Expiration_Date__c, StageName FROM Opportunity];
        Set<Id> setOppt = new Set<Id>();
        
        for (Opportunity oppt : lstOppt) {
        	setOppt.Add(oppt.Id);    
        }
        
        Test.startTest();
        CEC_PME_OpportunityExpirationDate.getExpirationDate(setOppt); 
        Test.stopTest();
    }
    
    @isTest
    public static void updLimiteExpTest() {    
        List<Opportunity> lstOppt = [SELECT Id, CreatorProfile__c,  CommercialSegment2__c, Expiration_Date__c, StageName FROM Opportunity];
        //Set<Id> setOppt = new Set<Id>();
        
        for (Opportunity oppt : lstOppt) {
            oppt.Expiration_Date__c = null;
            //setOppt.Add(oppt.Id);
        }
        
        update lstOppt;
        
        Test.startTest();                
        CEC_PME_OpportunityExpirationDate.updExpirationDate(lstOppt);
        Test.stopTest();
    }
}