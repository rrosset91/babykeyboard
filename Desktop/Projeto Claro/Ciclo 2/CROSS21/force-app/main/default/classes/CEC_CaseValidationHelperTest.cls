/*
* Autor: Squad Canais Criticos - Sysmap
* Data: 23/07/2020
* Description: Classe de test do CEC_CaseValidationHelper
* ---------------------------------------------------------------
*/
@isTest
private class CEC_CaseValidationHelperTest {

    private static final String MSG_FAIL_NOTEQUALS = 'Os valores estão iguais, deveriam ser diferentes';
    private static final String MSG_FAIL_EQUALS = 'Os valores estão diferentes, deveriam ser iguais';
    private static final ID RECORD_TYPE_CONSUMIDOR_GOV_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    
    private static List<Case> createCases(String description) {
        List<Case> cases = new List<Case>();
        
        Case caso = new Case();
        caso.Description = description;
        
        caso.RequestSupport__c = description;
        caso.recordTypeId = RECORD_TYPE_CONSUMIDOR_GOV_ID;
        
        cases.add(caso);        
        return cases;
    }
    
    @isTest	
    private static void testRecordTypes() {
        CEC_CaseValidationHelper.getRecordTypesDescriptionValidation();
    }
    
    @isTest	
    private static void testDiferentDescriptionWithoutSC() {
        List<Case> oldCases = createCases('Descricao 123');
        List<Case> newCases = createCases('Descricao 456');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, false);
        System.assert(invalidCases != null && !invalidCases.isEmpty(), MSG_FAIL_NOTEQUALS);
    }
    
    @isTest	
    private static void testSameDescriptionWithoutSC() {
        List<Case> oldCases = createCases('Descricao 123');
        List<Case> newCases = createCases('Descricao 123');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, false);
        System.assert(invalidCases == null || invalidCases.isEmpty(), MSG_FAIL_EQUALS);        
    }

    @isTest	
    private static void testSameDescriptionWithoutSCWithSpace() {
        List<Case> oldCases = createCases('   Descricao   123   ');
        List<Case> newCases = createCases(' Descricao 123       ');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, false);
        System.assert(invalidCases == null || invalidCases.isEmpty(), MSG_FAIL_EQUALS);        
    }

    @isTest	
    private static void testDiferentDescriptionWithSC() {
        
        String key = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.keySet().iterator().next();
        String value = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.get(key);
        
        List<Case> oldCases = createCases('Descricao 123' + key + ' 456');
        List<Case> newCases = createCases('Descricao 123' + value + ' 789');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, false);
        System.assert(invalidCases != null && !invalidCases.isEmpty(), MSG_FAIL_NOTEQUALS);  
        
    }

    @isTest	
    private static void testSameDescriptionWithSC() {
        
        String key = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.keySet().iterator().next();
        String value = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.get(key);
        
        List<Case> oldCases = createCases('Descricao 123' + key + ' 456');
        List<Case> newCases = createCases('Descricao 123' + value + ' 456');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, false);
        System.assert(invalidCases == null || invalidCases.isEmpty(), MSG_FAIL_EQUALS);        

    }
    
    @isTest	
    private static void testSameDescriptionWithSCNoHelper() {
        
        String key = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.keySet().iterator().next();
        String value = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.get(key);
        
        String oldDescription = 'Descricao 123' + key + ' 456';
        String newDescription = 'Descricao 123' + value + ' 456';
        
        boolean diferent = !oldDescription.equals(newDescription);
        System.assert(diferent, MSG_FAIL_NOTEQUALS);        
    }
    
    @isTest	
    private static void testSucessCallForTrigger() {
        
        String key = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.keySet().iterator().next();
        String value = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.get(key);
        
        List<Case> oldCases = createCases('Descricao 123' + key + ' 456');
        List<Case> newCases = createCases('Descricao 123' + value + ' 456');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases);
        System.assert(!ApexPages.hasMessages(), MSG_FAIL_NOTEQUALS);        
    }
    
    @isTest	
    private static void testFailCallForTrigger() {
        
        String key = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.keySet().iterator().next();
        String value = CEC_CaseValidationHelper.SPECIAL_CHARACTERS.get(key);
        
        List<Case> oldCases = createCases('Descricao 123' + key + ' 456');
        List<Case> newCases = createCases('Descricao 123' + value + ' 789');
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(oldCases, newCases,false, true);
        System.assert(ApexPages.hasMessages(), MSG_FAIL_NOTEQUALS);        
    }

    @isTest	
    private static void testEmptyCall() {
        
        List<Case> invalidCases = CEC_CaseValidationHelper.validateChangeDescription(null, null);
        System.assert(!ApexPages.hasMessages(), 'Os valores foram vazios, deveria passar na validacao');        
    }

}