@isTest
public class CEC_LegacyOfferTriggerTest {
	static testMethod void LegacyOfferCreation(){
        Legacy_Offer__c  prs = new Legacy_Offer__c (
            Name = 'LegacyOfferCreation',
            Billing_Offer_Name__c = 'BOExample',
            Billing_Offer_Code__c = '10000000000');
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from Legacy_Offer__c  where Name = 'LegacyOfferCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}