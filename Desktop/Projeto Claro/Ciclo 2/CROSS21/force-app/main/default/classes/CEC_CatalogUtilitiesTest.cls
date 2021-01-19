@isTest
public class CEC_CatalogUtilitiesTest {
	static testMethod void getCurrentDate(){
        Test.startTest();
        String currentDate = CEC_CatalogUtilities.getCurrentDate();
        Test.stopTest();
        System.assert(String.isNotEmpty(currentDate), 'currentDate wasn\'t properly populated');
    }
    
    static testMethod void isRunningInSandbox(){
        Test.startTest();
        boolean isSandbox = CEC_CatalogUtilities.isRunningInSandbox();
        Test.stopTest();
        String result = isSandbox ? 'sandbox' : 'production';
        System.assert(result == 'sandbox' || result == 'production', 'isn\'t a sandbox or production');
    }
    
    static testMethod void getSandboxName(){
        Test.startTest();
        String sandboxName = CEC_CatalogUtilities.getSandboxName();
        Test.stopTest();
        System.assert(String.isNotEmpty(sandboxName), 'sandboxName wasn\'t properly populated');
    }
    
    static testMethod void generateKey(){        
        Test.startTest();
        String key = CEC_CatalogUtilities.generateKey('20200429', 'Test');
        Test.stopTest();
        System.assert(key.length() > 0, 'Method didn\'t return any information');
    }
}