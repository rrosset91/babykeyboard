@isTest
public class Solar_SkillsBasedRoutingTest {
    @TestSetup
    static void makeData(){
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        cs.Resolution__c = 'Resolução da Resolução';
        cs.LegacyProtocol__c = '72645152';
        cs.InteractionNumber__c = '37856723673';
        cs.Channel__c = 'Atendimento Pessoal (ATP)';
        cs.Origin = 'Telefone';
        cs.Subject = 'Resolução da Resolução';
        cs.Description = 'Resolução da Resolução';
        cs.Status = 'Novo';
        cs.EntryReason__c = 'Validação de Contestação de Valores';
        cs.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        cs.Type = 'Pergunta';
        cs.CallReason__c = 'Produto';
        cs.RequestSupport__c = 'Descrição';	
        insert cs;
    }
    
    @isTest
    static void testRoutUsingSkills(){
        
        List<Case> lstCase = [SELECT Id FROM Case WHERE Status = 'Novo' ];
        Test.startTest();
        Solar_SkillsBasedRouting.routUsingSkills(lstCase);
        Test.StopTest();
        List<PendingServiceRouting> lstPendingService = [SELECT Id  FROM PendingServiceRouting WHERE WorkItemId =:lstcase[0].id];
        System.assertEquals(true,!lstPendingService.isEmpty());
    }

}