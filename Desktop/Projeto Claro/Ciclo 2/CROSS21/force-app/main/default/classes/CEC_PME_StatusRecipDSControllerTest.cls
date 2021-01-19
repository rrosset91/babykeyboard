@isTest
public class CEC_PME_StatusRecipDSControllerTest {

    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */     
    @testSetup
    public static void testSetup() {     
        Order newOrder = CEC_OrderTriggerTest.builderOrder();
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = newOrder.Id;
        insert status;
    }
    
    @isTest
    public static void mainTest() {
        String envelop = CEC_PME_StatusRecipDocusignController.getEnvelop([SELECT Id FROM Order].Id);
        System.assert(String.isNotBlank(envelop), 'Envelope não retornado');       
    }
}