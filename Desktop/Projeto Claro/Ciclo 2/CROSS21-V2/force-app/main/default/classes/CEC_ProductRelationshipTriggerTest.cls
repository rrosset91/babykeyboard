@isTest
public class CEC_ProductRelationshipTriggerTest {
    static testMethod void ProductRelationshipCreation(){
        // criar um registro de product relationship
        vlocity_cmt__ProductRelationship__c prs = new vlocity_cmt__ProductRelationship__c(
            Name = 'ProductRelationshipCreation', 
        	vlocity_cmt__MinQuantity__c = 1, 
            vlocity_cmt__MaxQuantity__c = 1);
        
        Test.startTest();
        Insert prs;
        Test.stopTest();
        String result = [select id, Chave__c from vlocity_cmt__ProductRelationship__c where Name = 'ProductRelationshipCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }	
}