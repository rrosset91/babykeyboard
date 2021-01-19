@isTest
public class CEC_Account_RepositoryTest {
    @testSetup
    public static void testSetup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
    }
    
    @isTest static void testAccountRepository()
    {
        String accntId = [SELECT Id FROM Account].Id;
        
        CEC_Account_Repository accntRep = new CEC_Account_Repository();
        Account accnt = accntRep.getAccountById(accntId);
        System.assert(accnt != null);
    }
    
    @isTest static void testAccountRepositoryError()
    {
        CEC_Account_Repository accntRep = new CEC_Account_Repository();
        Account accnt = accntRep.getAccountById('');
        System.assert(accnt == null);
    }    
}