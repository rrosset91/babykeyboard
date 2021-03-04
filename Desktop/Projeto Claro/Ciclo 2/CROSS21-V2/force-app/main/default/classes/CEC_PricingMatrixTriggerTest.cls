@isTest
public class CEC_PricingMatrixTriggerTest {
    static testMethod void PricingMatrixCreation(){
        Pricing_Matrix__c prs = new Pricing_Matrix__c(
            Promotion__c = 'PricingMatrixCreation');
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from Pricing_Matrix__c where Promotion__c = 'PricingMatrixCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}