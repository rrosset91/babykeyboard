/*
* Autor: Diego Almeida(IBM).
* Data: 07/07/2020
* [Claro SOLAR] [Time: CRM]
* Descrição: [PU18- Sprint 0] - Realizar contestação de itens da Fatura.
* ------------------------------------- Alterações -----------------------------------
* Data: .
* Autor: .
* [Descrição]: . 
* 
*/
@isTest
public with sharing class Solar_Cross_CasesControllerTest {
    @testSetup
    static void makeData()
    {
        
        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.ContractReferenceNumber__c = 'Contratot123';
        contrato.CityCode__c  = '123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.BusinessUnit__c = 'NET';
        insert contrato;

        Account conta = new Account(Name = 'Account Test');
        conta.ExternalID__c = 'Conta123';
        insert conta;

        Contact contact = new Contact();
        contact.LastName = 'teste';
        contact.AccountId = conta.Id;
        contact.ContactType__c = 'Titular';
        insert contact;

        contrato = new Account(Name = 'Account error Test');
        contrato.ExternalID__c = 'contract000';
        insert contrato;

        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/interactions', 'POST', 'CEC_OAG_Claro_ProtocolNETSMS', 'MCIDAS', 'OAGNet'));
        params.add(getServiceParameter('/interactions', 'POST', 'CEC_OAG_Claro_Protocol', 'MCIDAS', 'OAGClaro'));
        insert params;
    }

    @isTest
    static void SolarCasesControllerTest() {
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"transactionId":null,"data":{"reasonId":"1","protocolNumber":"12345","operatorCode":"004","contractNumber":"010332171"}}', 200));
        Solar_Cross_CasesController.SolarCaseRequestWrapper wrapper = new Solar_Cross_CasesController.SolarCaseRequestWrapper();
            wrapper.idCliente = 'Conta123';
            wrapper.idContrato = '123/Contratot123';
            wrapper.canal = 'Digital'; //URA
            wrapper.idExterno = 'Conta123';
            wrapper.codigoProcesso = 'RealizarContestacao';//MappingCaseManagement__mdt.ProcessCode__c GERAL
            wrapper.motivoContato = 'Financeiro';//caso.CallReason__c
        Test.startTest();
            Solar_Cross_CasesController.SolarCaseResponseWrapper response = Solar_Cross_CasesController.SolarCreateCase(wrapper);
            System.assertEquals(response.codigo, 200);
            System.debug(response);
        Test.stopTest();
            
    }
    @isTest
    static void SolarCasesControllerTestErrorMetaData() {
        Solar_Cross_CasesController.SolarCaseRequestWrapper wrapper = new Solar_Cross_CasesController.SolarCaseRequestWrapper();
            wrapper.idCliente = 'Conta123';
            wrapper.idContrato = 'contract000';
            wrapper.idExterno = 'contract000';
            wrapper.canal = 'xpto';
        Test.startTest();
        Solar_Cross_CasesController.SolarCaseResponseWrapper response = Solar_Cross_CasesController.SolarCreateCase(wrapper);
            System.assertEquals(response.codigo, 400);
            System.debug(response);
        Test.stopTest();
            
    }

    @isTest
    static void SolarCasesControllerTestErrorContract() {
        Solar_Cross_CasesController.SolarCaseRequestWrapper wrapper = new Solar_Cross_CasesController.SolarCaseRequestWrapper();
            wrapper.idCliente = 'Conta123';
            wrapper.idContrato = 'xxxads';
            wrapper.idExterno = 'xxxads';
            wrapper.canal = 'URA';
            wrapper.codigoProcesso = 'Geral';//MappingCaseManagement__mdt.ProcessCode__c
            wrapper.motivoContato = 'Financeiro';//caso.CallReason__c
        Test.startTest();
            Solar_Cross_CasesController.SolarCaseResponseWrapper response = Solar_Cross_CasesController.SolarCreateCase(wrapper);
            System.assertEquals(response.codigo, 500);
            System.debug(response);
        Test.stopTest();
    }

    @TestVisible
    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String userName, String namedCredential){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = userName;
        param.NamedCredential__c = namedCredential;
        return param;
    }   
}