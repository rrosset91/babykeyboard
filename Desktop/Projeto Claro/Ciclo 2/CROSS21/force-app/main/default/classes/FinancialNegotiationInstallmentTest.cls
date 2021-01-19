/**
 * @description       : US101348
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 11-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
**/
@isTest
public with sharing class FinancialNegotiationInstallmentTest {
    @TestSetup
    static void makeData(){
        List<ServiceParameter__c> lstParams = new List<ServiceParameter__c>();
            ServiceParameter__c customSetting = new ServiceParameter__c(
                Name = 'InvoicesNegotiationOptions',
                EndPoint__c = '00',
                Method__c = 'POST',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
            customSetting = new ServiceParameter__c(
                Name = 'CustomerProconPropensity',
                EndPoint__c = '00',
                Method__c = 'GET',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
            customSetting = new ServiceParameter__c(
                Name = 'CustomerDefaultSegmetation',
                EndPoint__c = '00',
                Method__c = 'GET',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
        insert lstParams;


		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
            Parameters__c parametro = new Parameters__c(
                name = 'Teste Param',
                Channel__c = 'Atendimento',
                RecordTypeId = recordTypeIdParameter,
                Active__c = true,
                Amount__c = 1000,
                Business_Division__c = 'Residencial'
            );
        insert parametro;


        Account contrato = AccountDataFactory.getSingleAccount('Billing');
			contrato.ContractReferenceNumber__c = ('229531991');
			contrato.StatusLegado__c = 'Conectado';
        insert contrato;

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
            Account consumer = new Account(
                DocumentNumber__c = '64204294987',
                DocumentType__c = 'CPF',
                Name = 'MassaInadimplencia Residencial - Consumidor',
                RecordTypeId = consumerRecordType
            );
		insert consumer;

		Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
            Case casoAtual = new Case(
                AccountId = consumer.id,
                ContractBillingAccount__c = contrato.id,
                RecordTypeId = caseRecordType,
                Subject = 'Caso Atual'
            );
		insert casoAtual;
    }
    @IsTest
    static void methodName(){

        Test.startTest();
        Test.stopTest();

    }
}