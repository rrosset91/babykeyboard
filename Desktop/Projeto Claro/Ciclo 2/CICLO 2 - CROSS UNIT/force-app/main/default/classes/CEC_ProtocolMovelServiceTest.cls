/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 04/02/2020 
* Descrição: [CEC - Extensão Fase 2] - [Time: SQUAD Canais Criticos - Sprint 17] - [Integração Protocolo PS8]
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
@istest
public class CEC_ProtocolMovelServiceTest {
    
    @testSetup
    private static void setup()
    {

        
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_Claro_Protocol', 
        'https://apiuat.net.com.br:7443/sdp/interactions', 
          'POST','x1234','APP_TESTE');
            varServiceParameter.NamedCredential__c = 'OAGClaro';
        insert varServiceParameter;

        Contact varContact = CEC_SobjectFactory.getContact();
        insert varContact;
                        
        //Reducao da quantidade de casos que serao inseridos devido a erro de DML 101
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{'Claro'}, 
            												  new Set<String>{'Pré', 'Pós Pago', 'Banda Larga'});
        
        List<Case> lstCases = new List<Case>();

        for(CEC_CC_PS8Classification__mdt classification : mapClassification.get('Claro').values()){
            Case varCase = CEC_SobjectFactory.getCase(varContact);
            varCase.Contract__c = '19999999999';
            varCase.Product__c = classification.product__c;
            varCase.BusinessUnit__c = 'Claro';
            lstCases.add(varCase);
        }

        insert lstCases;
    }
    
    @istest 
    private static void createProtocolPS8Test()
    {     
        List<Case> lstCases = [SELECT Id, ContractMSISDN__c FROM Case];
        
        Set<Id> setCasesIds = (new Map<Id,SObject>(lstCases)).keySet();
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
            Map<Id, CEC_ProtocolNetResponse> mapResponses = CEC_ProtocolMovelService.create(setCasesIds);
        
            for(Id caseId : setCasesIds){
                system.assertEquals(true, mapResponses.containsKey(caseId), 'Erro ao processar api para o registro: ' + caseId);
            }
        test.stopTest();
    }
    
    @istest 
    private static void createProtocolPS8ByClosedCasesTest()
    {     
        List<Case> lstCases = [SELECT Id, SubStatus__c, Resolution__c, ContractMSISDN__c, LegacyProtocol__c FROM Case];
        Set<Id> setCasesIds = (new Map<Id,SObject>(lstCases)).keySet();
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        
            for(Case objCase : lstCases){
                objCase.SubStatus__c = 'Encerrado';
                objCase.Resolution__c = 'TESTE RESOLUÇÃO';
            }
        
            Database.SaveResult[] lstSr = Database.update(lstCases, false);
            for(Database.saveResult result: lstSr){
                String errorTxt;
                if(!result.isSuccess())
                    for(Database.Error err : result.getErrors()){
                        errorTxt =+ err.getMessage() + '/n';
                    }
                system.assertEquals(true, setCasesIds.contains(result.getId()), 
                                    'Erro ao processar api no encerramento do registro: ' + result.getId() + '|' + errorTxt);
            }
        test.stopTest();
        
        List<Case> lstCases2  = [SELECT Id, CaseNumber, LegacyProtocol__c FROM Case];
        for(Case objCase : lstCases2)
            system.debug('FIM ## Protocol Case (' + objCase.CaseNumber + '): ' + objCase.LegacyProtocol__c);
    }
    
    @istest 
    private static void createProtocolPS8NOK()
    {     
        List<Case> lstCases = [SELECT Id, SubStatus__c, Resolution__c, ContractMSISDN__c, LegacyProtocol__c FROM Case];
        Set<Id> setCasesIds = (new Map<Id,SObject>(lstCases)).keySet();
        
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseErrorTest());
        
            for(Case objCase : lstCases){
                objCase.SubStatus__c = 'Encerrado';
                objCase.Resolution__c = 'TESTE RESOLUÇÃO';
            }
            
            Database.SaveResult[] lstSr = Database.update(lstCases, false);
            for(Database.saveResult result: lstSr){
                String errorTxt;
                if(!result.isSuccess())
                    for(Database.Error err : result.getErrors()){
                        errorTxt =+ err.getMessage() + '/n';
                    }
                system.assertEquals(true, setCasesIds.contains(result.getId()), 
                                    'Erro ao processar api no encerramento do registro: ' + result.getId() + '|' + errorTxt);
            }
        test.stopTest();
    }
}