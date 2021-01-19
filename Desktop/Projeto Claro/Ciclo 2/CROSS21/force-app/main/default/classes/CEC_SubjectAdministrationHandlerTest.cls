/*
* Autor: Squad Canais Criticos + Deloitte
* Data: 24/07/2018
* Descrição: [CEC - Release 1 ] + [Time: SQUAD Canais Criticos - Sprint 10] + [Regras de Casos]
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
@isTest
public class CEC_SubjectAdministrationHandlerTest {
    
    @testSetup
    private static void setup()
    {      
		SubjectAdministration__c lSubjectAdministration = CEC_SobjectFactory.getSubjectAdministration();       
        insert lSubjectAdministration;
    }     
    
    
    @isTest static void insertSubjectAdministration()
    {    
        SubjectAdministration__c lSubjectAdministration = new SubjectAdministration__c();
        lSubjectAdministration.Name = 'Atendimento > Consumidor não consegue falar com atendente';
        lSubjectAdministration.Reason__c = 'Atendimento';
        lSubjectAdministration.SubReason__c = 'Consumidor não consegue falar com atendente';
        lSubjectAdministration.BusinessUnit__c = 'Claro;Claro DTH;Embratel;NET';
        lSubjectAdministration.Classification__c = 'TUP;Banda Larga;Claro Fone';
        
        Test.startTest();
        insert lSubjectAdministration; 
        Test.stopTest();
        
        system.debug('lSubjectAdministration' + lSubjectAdministration);
    }
    
    @isTest static void updateSubjectAdministration()
    {    
       SubjectAdministration__c lSubjectAdministration = [SELECT Id, BusinessUnit__c, Classification__c 
                                        FROM SubjectAdministration__c LIMIT 1];
       lSubjectAdministration.BusinessUnit__c = 'Claro;Claro DTH;Embratel;NET'; 
        
        Test.startTest();
        update lSubjectAdministration; 
        Test.stopTest();
        
        system.debug('lSubjectAdministration' + lSubjectAdministration);
    }
    
}