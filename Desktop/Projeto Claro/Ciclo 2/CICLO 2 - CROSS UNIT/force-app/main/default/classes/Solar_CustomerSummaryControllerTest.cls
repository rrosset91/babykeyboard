@isTest
public class Solar_CustomerSummaryControllerTest {
    @testSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'Account A';
		acc.DocumentNumber__c = '010101';
        insert acc;
        
        Case cs = new Case();
        cs.Status = 'Novo';
		cs.ProductTV__c = true;
		cs.AccountId = acc.Id;
		cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        insert cs;
    } 
    
    @IsTest
    static void loadDataTest(){
        Case caso = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
            Map<String, Object> response = Solar_CustomerSummaryController.loadData(caso.id,'Case');
            System.debug('TESt ' + response.get('customerData'));
            Account result = (Account)response.get('customerData');
            System.debug('TESt ' + result);
            System.assertEquals('Account A', result.Name);
        Test.stopTest();
        
    }

    @IsTest
    static void loadDataTest2(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
            Map<String, Object> response = Solar_CustomerSummaryController.loadData(acc.id,'Account');
            System.debug('TESt ' + response.get('customerData'));
            Account result = (Account)response.get('customerData');
            System.debug('TESt ' + result);
            System.assertEquals('Account A', result.Name);
        Test.stopTest();
        
    }
}