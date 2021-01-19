@isTest
public class CEC_PME_NavigateToOppControllerTest {

    @isTest
    public static void mainTest() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        insert newAccount;
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.Name = 'test';
        newOpportunity.StageName = 'draft';
        newOpportunity.CloseDate = System.today();
        insert newOpportunity;
         
        CEC_PME_NavigateToOppController.validate(newOpportunity.Id);
    }
}