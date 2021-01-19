@isTest
public class KB_KnowledgeTriggerTest {
    @isTest static void testKnowledgeTrigger(){
        Knowledge__kav knw = new Knowledge__kav();
        knw.Title = 'testing wololo wololo';
        knw.UrlName = 'testing-wololo-wololo';
        knw.Summary = 'wololo';
        knw.Understand__c = 'wololo';
        knw.Valid_for__c = 'wololo';
        knw.Benefits__c = 'wololo';
        knw.Channels_and_Systems__c = 'wololo';
        knw.How_it_works__c = 'wololo';
        knw.Value__c = 'wololo';
        knw.Know_more__c = 'wololo';        
        insert knw;//After insert instance
       
        Knowledge__kav knwUpdate = [SELECT Know_more__c FROM Knowledge__kav WHERE Id =: knw.Id];
        knwUpdate.Know_more__c += 'wolwolololoolol';
        update knwUpdate;//Before update instance
    }
}