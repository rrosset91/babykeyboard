@isTest
public class CEC_DecompositionRelationshipTriggerTest {
    static testMethod void DecompositionRelationshipCreation(){
        Legacy_Offer__c loId = new Legacy_Offer__c (
            Billing_Offer_Name__c = 'BOExample',
            Billing_Offer_Code__c = '10000000000');
        
        Insert loId;
             
        vlocity_cmt__DecompositionRelationship__c  prs = new vlocity_cmt__DecompositionRelationship__c (
            Name = 'DecompositionRelationshipCreation',
        	Legacy_Offer__c = loId.id);
        
        Test.startTest();        
        Insert prs;
        Test.stopTest();
        
        String result = [select id, Chave__c from vlocity_cmt__DecompositionRelationship__c  where Name = 'DecompositionRelationshipCreation'].Chave__c;
        System.assert(String.isNotEmpty(result), 'Chave__c Field wasn\'t properly populated');
    }
}