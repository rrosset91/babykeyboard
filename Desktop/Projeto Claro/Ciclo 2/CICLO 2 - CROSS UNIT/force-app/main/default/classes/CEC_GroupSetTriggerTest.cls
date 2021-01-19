@isTest
public class CEC_GroupSetTriggerTest {
    static testMethod void GroupSetCreation(){
        // criar um registro de product relationship
        Group_Set__c prs = new Group_Set__c(
            Name = 'GroupSetCreation',
        	Start_Date__c = date.valueOf('2020-04-01'),
            End_Date__c = date.valueOf('2020-05-01'));
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from Group_Set__c where Name = 'GroupSetCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}