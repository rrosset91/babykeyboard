@isTest
public class CEC_CatalogRelationshipTriggerTest {
	static testMethod void CatalogRelationshipCreation(){
        
        Test.startTest();
        vlocity_cmt__Catalog__c crParent = new vlocity_cmt__Catalog__c(
            Name = 'CatalogTestParent');
        
        vlocity_cmt__Catalog__c crChild = new vlocity_cmt__Catalog__c(
            Name = 'CatalogTestChild');
        
        Insert crParent;
        Insert crChild;
        
        vlocity_cmt__CatalogRelationship__c prs = new vlocity_cmt__CatalogRelationship__c(
            Name = 'CatalogPRTestName',
        	vlocity_cmt__ParentCatalogId__c = crParent.Id,
        	vlocity_cmt__ChildCatalogId__c = crChild.Id);
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from vlocity_cmt__CatalogRelationship__c where Name = 'CatalogPRTestName'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }
}