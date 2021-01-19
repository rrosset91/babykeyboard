@isTest
public class CEC_ProductAvailabilityTriggerTest {
	static testMethod void ProductAvailabilityCreation(){
        vlocity_cmt__ProductAvailability__c prs = new vlocity_cmt__ProductAvailability__c(
            Name = 'ProductAvailabilityCreation');
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from vlocity_cmt__ProductAvailability__c where Name = 'ProductAvailabilityCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}