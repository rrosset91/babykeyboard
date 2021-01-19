@isTest
public class CEC_CatalogTriggerTest {
	static testMethod void CatalogCreation(){
        vlocity_cmt__Catalog__c prs = new vlocity_cmt__Catalog__c(
            Name = 'CatalogTestName');
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from vlocity_cmt__Catalog__c where Name = 'CatalogTestName'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}