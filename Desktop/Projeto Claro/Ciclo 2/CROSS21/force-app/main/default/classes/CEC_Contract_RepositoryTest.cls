@isTest
public class CEC_Contract_RepositoryTest {
    @testSetup
    public static void testSetup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        
        Contract contract = new Contract(Name = 'Teste1', 
                                         AccountId = varAccount.Id, 
                                         BusinessUnit__c = 'CLARO');
        insert contract;        
    }
    
    @isTest static void testAccountRepository()
    {
        String contractId = [SELECT Id FROM Contract].Id;
        
        CEC_Contract_Repository contractRep = new CEC_Contract_Repository();
        Contract contract = contractRep.getContractById(contractId);
        System.assert(contract != null);
    }
    
    @isTest static void testAccountRepositoryError()
    {
        CEC_Contract_Repository contractRep = new CEC_Contract_Repository();
        Contract contract = contractRep.getContractById('');
        System.assert(contract == null);
    }    
}