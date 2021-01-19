/*
* Autor: Diego Lima - Deloitte
* Data: 23/05/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [Classe utilizada para criar os registros 
* de metadados necessários para os testes da classe CEC_CTI_DispAttendanceController]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 23/05/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e dos registros de metadados do objeto CEC_CTI_Disparador__mdt]
*/

public class CEC_CTI_GetListDisparadoresURL {
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [O método generateListMetadata 
    * gera uma lista com registros do objeto de Metadados CEC_CTI_Disparador__mdt para que estes possam ser utilizados 
    * na classe de testes]
    */
    
    public static List<CEC_CTI_Disparador__mdt> generateListMetadata(){
        
        List <CEC_CTI_Disparador__mdt> listaDisparador = new List <CEC_CTI_Disparador__mdt>();
        
        CEC_CTI_Disparador__mdt disparadorCustomTest1 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest1.Label = 'SkillCodeTeste';
        disparadorCustomTest1.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest1.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest1.partyIdentificationNumber__c = 'Indiferente';
        disparadorCustomTest1.customerName__c = 'Indiferente';
        disparadorCustomTest1.protocolNumber__c = 'Preenchido';
        disparadorCustomTest1.contractNumber__c = 'Preenchido';
        disparadorCustomTest1.skillId__c = '000123';
        disparadorCustomTest1.vdnOrigin__c = 'VDNTEST';
        disparadorCustomTest1.partyIdentificationType__c = 'TYPETEST';
        disparadorCustomTest1.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest1);
        
        CEC_CTI_Disparador__mdt disparadorCustomTest2 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest2.Label = 'SkillCodeTeste';
        disparadorCustomTest2.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest2.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest2.partyIdentificationNumber__c = 'Preenchido';
        disparadorCustomTest2.customerName__c = 'Preenchido';
        disparadorCustomTest2.protocolNumber__c = 'Indiferente';
        disparadorCustomTest2.contractNumber__c = 'Preenchido';
        disparadorCustomTest2.skillId__c = '000123';
        disparadorCustomTest2.vdnOrigin__c = 'VDNTEST';
        disparadorCustomTest2.partyIdentificationType__c = 'TYPETEST';
        disparadorCustomTest2.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest2);
        
        CEC_CTI_Disparador__mdt disparadorCustomTest3 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest3.Label = 'SkillCodeTeste';
        disparadorCustomTest3.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest3.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest3.partyIdentificationNumber__c = 'Preenchido';
        disparadorCustomTest3.customerName__c = 'Preenchido';
        disparadorCustomTest3.protocolNumber__c = 'Preenchido';
        disparadorCustomTest3.contractNumber__c = 'Indiferente';
        disparadorCustomTest3.skillId__c = '000123';
        disparadorCustomTest3.vdnOrigin__c = 'VDNTEST';
        disparadorCustomTest3.partyIdentificationType__c = 'TYPETEST';
        disparadorCustomTest3.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest3);
        
        CEC_CTI_Disparador__mdt disparadorCustomTest4 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest4.Label = 'SkillCodeTeste';
        disparadorCustomTest4.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest4.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest4.partyIdentificationNumber__c = 'Preenchido';
        disparadorCustomTest4.customerName__c = 'Preenchido';
        disparadorCustomTest4.protocolNumber__c = 'Preenchido';
        disparadorCustomTest4.contractNumber__c = 'Preenchido';
        disparadorCustomTest4.skillId__c = '000123';
        disparadorCustomTest4.vdnOrigin__c = 'VDNTEST1';
        disparadorCustomTest4.partyIdentificationType__c = 'TYPETEST';
        disparadorCustomTest4.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest4);
        
        CEC_CTI_Disparador__mdt disparadorCustomTest5 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest5.Label = 'SkillCodeTeste';
        disparadorCustomTest5.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest5.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest5.partyIdentificationNumber__c = 'Preenchido';
        disparadorCustomTest5.customerName__c = 'Preenchido';
        disparadorCustomTest5.protocolNumber__c = 'Preenchido';
        disparadorCustomTest5.contractNumber__c = 'Preenchido';
        disparadorCustomTest5.skillId__c = '000123';
        disparadorCustomTest5.vdnOrigin__c = 'VDNTEST';
        disparadorCustomTest5.partyIdentificationType__c = 'TYPETEST1';
        disparadorCustomTest5.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest5);
        
        CEC_CTI_Disparador__mdt disparadorCustomTest6 = new CEC_CTI_Disparador__mdt();
        disparadorCustomTest6.Label = 'SkillCodeTeste';
        disparadorCustomTest6.MasterLabel = 'SkillCodeTeste';
        disparadorCustomTest6.mpl__c = String.valueof('Classe de Teste');
        disparadorCustomTest6.partyIdentificationNumber__c = 'Preenchido';
        disparadorCustomTest6.customerName__c = 'Preenchido';
        disparadorCustomTest6.protocolNumber__c = 'Preenchido';
        disparadorCustomTest6.contractNumber__c = 'Preenchido';
        disparadorCustomTest6.skillId__c = '000123';
        disparadorCustomTest6.vdnOrigin__c = 'VDNTEST';
        disparadorCustomTest6.partyIdentificationType__c = 'TYPETEST';
        disparadorCustomTest6.Profile__c = 'Teste Perfil';
        disparadorCustomTest6.URL__c = '/lightning/n/Buscar_Cliente/<<cpfcnpj>>&<<codnet>>&<<codcidade>>';
        listaDisparador.add(disparadorCustomTest6);
        
        return listaDisparador;
        
    }
    
}