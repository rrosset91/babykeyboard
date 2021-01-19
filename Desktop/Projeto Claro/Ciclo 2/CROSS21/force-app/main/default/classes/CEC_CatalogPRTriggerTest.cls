@isTest
public class CEC_CatalogPRTriggerTest {
	static testMethod void CatalogPRCreation(){
        
        Test.startTest();
        vlocity_cmt__Catalog__c cpr = new vlocity_cmt__Catalog__c(
            Name = 'CatalogTestName');
        Insert cpr;
        
        vlocity_cmt__CatalogProductRelationship__c prs = new vlocity_cmt__CatalogProductRelationship__c(
            Name = 'CatalogPRTestName',
        	vlocity_cmt__CatalogId__c = cpr.Id);
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c, vlocity_cmt__CatalogId__c from vlocity_cmt__CatalogProductRelationship__c where Name = 'CatalogPRTestName'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }
}