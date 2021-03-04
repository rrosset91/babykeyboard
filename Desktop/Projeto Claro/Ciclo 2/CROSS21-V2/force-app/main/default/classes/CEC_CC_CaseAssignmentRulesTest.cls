@isTest
public class CEC_CC_CaseAssignmentRulesTest {
    
    @isTest
    public static void enableCaseAssignmentRulesSubAreaTest(){
        
        final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        
        Test.startTest();
            Account account = CEC_SobjectFactory.getAccount();
            insert account;
            
            Case caseToAssignToQueue = new Case();
            
            caseToAssignToQueue.RecordTypeId = CEC_CC_Ouvidoria;
            caseToAssignToQueue.AccountId = account.Id;
            caseToAssignToQueue.Grouping__c = 'Ouvidoria';
            caseToAssignToQueue.Channel__c = 'Ouvidoria';
            caseToAssignToQueue.InputType__c = 'Portal';
            caseToAssignToQueue.ServiceArea__c = 'SUPORTE TÉCNICO';
            caseToAssignToQueue.ServiceSubArea__c = 'COP Cabo';
            caseToAssignToQueue.Status = 'New';
            caseToAssignToQueue.SubStatus__c = 'Não Iniciado';
            caseToAssignToQueue.Contract__c = '999/999999999';
            insert caseToAssignToQueue;
        
        Test.stopTest();
        
        Case caseAssignedToQueue = [SELECT 
                                    	OwnerId 
                                    FROM 
                                    	Case 
                                    WHERE 
                                    	Id =:caseToAssignToQueue.Id];
        
        Group queueCOP_CABO = [select Id from Group where Type = 'Queue' AND DeveloperName = 'COP_CABO']; 
        
        System.assertEquals(caseAssignedToQueue.OwnerId,queueCOP_CABO.Id);
        
    }
}