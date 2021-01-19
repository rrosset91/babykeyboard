@isTest
public class CEC_Order_RepositoryTest {

 
    @isTest
    static void concatMapsTest(){
        Map<Id, List<vlocity_cmt__DecompositionRelationship__c>> mapDecompositionOffer = new Map<Id, List<vlocity_cmt__DecompositionRelationship__c>>();
        Map<Id, List<vlocity_cmt__DecompositionRelationship__c>> mapDecompositionDependent = new Map<Id, List<vlocity_cmt__DecompositionRelationship__c>>(); 
        List<vlocity_cmt__DecompositionRelationship__c> lstOffer = new List<vlocity_cmt__DecompositionRelationship__c>();
        List<vlocity_cmt__DecompositionRelationship__c> lstDependent = new List<vlocity_cmt__DecompositionRelationship__c>();
        vlocity_cmt__DecompositionRelationship__c decomp1 = new vlocity_cmt__DecompositionRelationship__c(Type__c = 'Promoção');
        vlocity_cmt__DecompositionRelationship__c decomp2 = new vlocity_cmt__DecompositionRelationship__c(Type__c = 'Plano');
        vlocity_cmt__DecompositionRelationship__c decomp3 = new vlocity_cmt__DecompositionRelationship__c(Type__c = 'Plano');
        vlocity_cmt__DecompositionRelationship__c decomp4 = new vlocity_cmt__DecompositionRelationship__c(Type__c = 'Promoção');
        lstOffer.add(decomp1);
        lstOffer.add(decomp2);
        lstDependent.add(decomp3);
        lstDependent.add(decomp4);
        List<Profile> lstId = [SELECT Id FROM Profile LIMIT 2];
        mapDecompositionOffer.put(lstId[0].id,lstOffer);
        mapDecompositionOffer.put(lstId[1].id,lstOffer);
        mapDecompositionDependent.put(lstId[1].id,lstDependent);
        CEC_Order_Repository orderRepository = new CEC_Order_Repository();
        Map<Id, List<vlocity_cmt__DecompositionRelationship__c>> result = orderRepository.concatMaps(mapDecompositionOffer,mapDecompositionDependent);
        System.assertEquals(4, result.get(lstId[1].id).size(), 'concatMaps'); 
    }

   
}