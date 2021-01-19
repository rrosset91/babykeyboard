@isTest
public class CEC_BonusTriggerTest {
	static testMethod void BonusCreation(){
        Bonus__c   prs = new Bonus__c (
            Name = 'BonusCreation',
            Start_Date__c = date.valueOf('2020-04-01'),
            End_Date__c = date.valueOf('2020-05-01'));
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from Bonus__c   where Name = 'BonusCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}