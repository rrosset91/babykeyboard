@isTest
public class CEC_PME_SalesDocumentsQuerysTest 
{
	@testSetup
    public static void testSetup()
    {
        CEC_PME_OrderTestMethods.generateAllData();
        
        Profile profileId = [SELECT Id FROM Profile WHERE name = 'AACE PME'];
        
        User varUser = new User();
        varUser.ProfileId = profileId.Id;
        varUser.FirstName = 'Teste';
        varUser.LastName = 'Test';
        varUser.Alias = 'Test';
        varUser.Email = 'usertest@teste.com';
        varUser.Username = 'usertest@teste.com';
        varUser.CommunityNickname = 'UserTest';
        varUser.LocaleSidKey = 'pt_BR';
        varUser.LanguageLocaleKey = 'pt_BR';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.TimeZoneSidKey = 'America/Sao_Paulo';
        
        insert varUser;
    }
    
    @isTest
    public static void getOrderTest()
    {
        Order varOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getOrder(varOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getOrderItensTest()
    {
        Order varOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getOrderItens(varOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getSalesUserTest()
    {
        User varUser = [SELECT Id FROM User LIMIT 1];
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getSalesUser(varUser.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getCustomerAccountTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getCustomerAccount(varAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountRelationsTest()
    {
        Order varOrder = [SELECT Id, Related_Contacts__c FROM Order LIMIT 1];
        Set<Id> setIds = CEC_PME_SalesDocumentsPayload.getRelatedContactIdList(varOrder.Related_Contacts__c);
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getAccountRelations(setIds);
        Test.stopTest();
    }
    
    @isTest
    public static void getRangeTest()
    {
        Set<String> setRange = new Set<String>();
        
        Test.startTest();
        	CEC_PME_SalesDocumentsQuerys.getRange(setRange);
        Test.stopTest();
    }    
}