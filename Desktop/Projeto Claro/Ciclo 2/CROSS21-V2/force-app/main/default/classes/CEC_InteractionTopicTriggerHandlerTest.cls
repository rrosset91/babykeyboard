@isTest
public class CEC_InteractionTopicTriggerHandlerTest 
{
    @testSetup
    private static void setup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();    
        Database.insert(varAccount);
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        Database.insert(varCase);
        
        vlocity_cmt__CustomerInteraction__c varCustomerInteraction = CEC_SobjectFactory.getCustomerInteraction();
        varCustomerInteraction.TypeInteractionGov__c = 'Protocolo Encerrado Avaliado';
        varCustomerInteraction.Author__c = 'Consumidor';        
        Database.insert(varCustomerInteraction);
    }
    
    @isTest
    private static void createTaskTest()
    {
        vlocity_cmt__CustomerInteraction__c varCustomerInteraction = [SELECT Id, TypeInteractionGov__c FROM vlocity_cmt__CustomerInteraction__c LIMIT 1];
        Case varCase = [SELECT Id FROM Case LIMIT 1];
        
        vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic = CEC_SobjectFactory.getCustomerInteractionTopic(varCustomerInteraction, varCase);
        Test.startTest();
        	Database.SaveResult lSavRes = Database.insert(varCustomerInteractionTopic);
        Test.stopTest();        
        system.assert(lSavRes.isSuccess());
    }
}