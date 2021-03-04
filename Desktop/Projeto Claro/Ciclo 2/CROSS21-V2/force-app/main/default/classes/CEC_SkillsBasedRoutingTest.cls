/*
 * ---------------------------------------------------------------
 * --- Controle de Versão
 * ---------------------------------------------------------------------------------------------------------
 *  Author: Squad LGPD - Sysmap Solutions
 *  Description: teste dos metodos de roteamento baseado em habilidade
 *  Date: 08/01/2021
-------------------------------------------------------------------------------------------------------*/

@isTest
private class CEC_SkillsBasedRoutingTest {
    
    @isTest public static void routeUsingSkillsTest() {
       
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        Contact lContact = CEC_SobjectFactory.getContact();
        insert lContact;
        
        Case lCase = CEC_SobjectFactory.getCase(lContact);
        insert lCase;
        
        test.startTest();
        	Database.SaveResult lSavRes = database.update(lCase);
        test.stopTest();
        system.assert(lSavRes.isSuccess());
    }

    @isTest
    public static void givenACaseShouldReturnAMapIndexedByCaseSubject() {
        Contact contact = CEC_SobjectFactory.getContact();
        insert contact;
        
        Case caze = CEC_SobjectFactory.getCase(contact);
        caze.Subject = 'teste';
        insert caze;
        
        Test.startTest();

        Map<String, List<Case>> casesBySubject = CEC_SkillsBasedRouting.getCasesBySubject(new List<Case>{caze});

        Test.stopTest();

        System.assert(!casesBySubject.isEmpty());
        System.assert(casesBySubject.get('teste').size() == 1);
        System.assert(casesBySubject.get('teste').get(0).Id == caze.Id);
    }

    @isTest
    public static void givenASubjectShouldReturnAConfigMapIndexedBySubject() {        
        CEC_LGPDdsar__mdt config = [SELECT Id FROM CEC_LGPDdsar__mdt WHERE rightName__c = 'Revisão decisão automatizada' LIMIT 1];

        Test.startTest();

        Map<String, CEC_LGPDdsar__mdt> configBySubject = CEC_SkillsBasedRouting.getConfigBySubject(new Set<String>{'Revisão decisão automatizada'});

        Test.stopTest();

        System.assert(!configBySubject.isEmpty());
        System.assert(configBySubject.get('Revisão decisão automatizada').Id == config.Id);
    }

    @isTest
    public static void givenAConfigShouldReturnSkillByDeveloperName() {        
        CEC_LGPDdsar__mdt config = [SELECT Id, Skills__c FROM CEC_LGPDdsar__mdt WHERE rightName__c = 'Revisão decisão automatizada' LIMIT 1];

        Test.startTest();

        Map<String, Skill> skillByDeveloperName = CEC_SkillsBasedRouting.getSkillByDeveloperName(new List<CEC_LGPDdsar__mdt>{config});

        Test.stopTest();

        System.assert(!skillByDeveloperName.isEmpty());
        System.assert(skillByDeveloperName.get('LGPD_DAC') != null);
        System.assert(skillByDeveloperName.get('LGPD_OUVIDORIA') != null);
    }

    @isTest
    public static void givenACaseShouldExecuteSkillBasedRouting() {
        
        Contact contact = CEC_SobjectFactory.getContact();
        insert contact;
        
        Case caze = CEC_SobjectFactory.getCaseLGPD(contact);
        caze.Subject = 'Revisão decisão automatizada';
        insert caze;
        
        Test.startTest();

        CEC_SkillsBasedRouting.routeUsingSkills(new List<String>{caze.Id});

        Test.stopTest();

        List<PendingServiceRouting> pendingServiceRoutings = [SELECT Id FROM PendingServiceRouting];
        List<SkillRequirement> skillRequirements = [SELECT Id FROM SkillRequirement];

        System.assert(!pendingServiceRoutings.isEmpty());
        System.assert(!skillRequirements.isEmpty());
    }
}