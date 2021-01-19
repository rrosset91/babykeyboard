@isTest
public class CEC_ME_CaseButtonsControllerTest {
    @isTest static void testGetCaseOk(){
        Case cs = createCase();
        insert cs;
        Case returnCase = CEC_ME_CaseButtonsController.getCase(cs.id);
        System.assert(returnCase != null);
        System.assert(returnCase.Status.equals('Agendamento'));
    }
    @isTest static void testGetCaseNOk(){
        Case returnCase = CEC_ME_CaseButtonsController.getCase('');
        System.assert(returnCase == null);
    }
    public static Case createCase(){
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mudanca_Endereco').getRecordTypeId();
        return new Case(RecordtypeId = recordTypeId, 
                        Status ='Agendamento', 
                        OccurrenceNumber__c ='232124312',
                        LegacyOcurrencyType__c ='65342',
                        ScheduledDate__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 2));
    }
}