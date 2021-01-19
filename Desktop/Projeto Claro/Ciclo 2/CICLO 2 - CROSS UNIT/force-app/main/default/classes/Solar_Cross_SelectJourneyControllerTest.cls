@isTest
public class Solar_Cross_SelectJourneyControllerTest {
    
    @testSetup
    static void makeData()
    {
        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert contrato;
        
    }
    
    @istest
    static void testGetMetadata(){
        Account conta = [SELECT Id FROM Account WHERE Name = 'Account Test'];
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        
        Case caso = new Case(AccountId = conta.Id, RecordTypeId = caseRecordTypeId);
        insert caso;
        Test.startTest();
       	List<Solar_Cross_SelectJourneyController.metadataSolarJourney> lstmetadata = Solar_Cross_SelectJourneyController.getMetadata(caso.Id);
        Test.stopTest();
        System.assertEquals(true, !lstmetadata.isEmpty());
    }
    
    @istest
    static void testChangeRecordTypeError(){
        
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        
        Account conta = [SELECT Id FROM Account WHERE Name = 'Account Test'];
        
        Case caso = new Case(AccountId = conta.Id, RecordTypeId = caseRecordTypeId);
        insert caso;
        
        Test.startTest();
        String ret = Solar_Cross_SelectJourneyController.changeRecordType(caso.Id,'Financial');
        Test.stopTest();
        System.assertEquals('Error',ret);
    }
    
    @istest
    static void testChangeRecordTypeSuccess(){
        
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        
        Account conta = [SELECT Id FROM Account WHERE Name = 'Account Test'];
        
        Case caso = new Case(AccountId = conta.Id, RecordTypeId = caseRecordTypeId);
        insert caso;
        
        Test.startTest();
        String ret = Solar_Cross_SelectJourneyController.changeRecordType(caso.Id,'CEC_CC_Anatel');
        Test.stopTest();
        System.assertEquals('Ok',ret);
    }
    	
}