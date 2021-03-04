/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 28-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   28-01-2021   Joao Neves   Initial Version
 **/
@isTest
public without sharing class FinancialCaseManagementTest {
	@testSetup
	static void makeData() {
		Account contrato = new Account(Name = 'Account Test');
		contrato.ExternalID__c = 'Contratot123';
		contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		contrato.ContractReferenceNumber__c = '004/12345';
		insert contrato;

		Case caso = new Case();
		caso.ContractBillingAccount__c = contrato.id;
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		insert caso;
	}
	@isTest
	static void SolarCaseRequestWrapperTest() {
		SolarCaseRequestWrapper reqSolarCase = new SolarCaseRequestWrapper();
		Account acc = new Account();
		acc.Name = 'Valor';

		insert acc;

		reqSolarCase.idCliente = acc.Id;
		reqSolarCase.idContrato = '1027935';
		reqSolarCase.operatorCode = '004';
		reqSolarCase.protocolo = '09812719826';
		Test.startTest();
		FinancialCaseManagement.createSolarCase(reqSolarCase);
		Test.stopTest();
	}

	@isTest
	static CEC_DisputeInvoice.DisputeInvoiceRequest disputeInvoiceTeste() {
		List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
		CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
		invoiceItems.idInvoiceItem = '1579031159';
		invoiceItems.idGroupItem = '1';
		invoiceItems.reason = '1';
		invoiceItems.originalValue = 308.42;
		invoiceItems.wishedValue = 15.42;
		invoiceItems.disputePercentage = 5;
		invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
		invoiceItems.notes = 'Observação da contestação';
		invoiceItems.status = 'EM ABERTO';
		lst.add(invoiceItems);

		CEC_DisputeInvoice.DisputeInvoiceRequest invoice = new CEC_DisputeInvoice.DisputeInvoiceRequest();
		invoice.contractNumber = '1027935';
		invoice.operatorCode = '004';
		invoice.channel = 'L';
		invoice.idInvoice = '245961436';
		invoice.userName = 'MCIDA';
		invoice.source = 1;
		invoice.type = 'R';
		invoice.invoiceItems = lst;
		return invoice;
	}

	@isTest
	static void createPaymentItems() {
		List<vlocity_cmt__PaymentAdjustment__c> retList = new List<vlocity_cmt__PaymentAdjustment__c>();

		CEC_DisputeInvoice.DisputeInvoiceRequest invoice = disputeInvoiceTeste();

		SolarCaseRequestWrapper reqSolarCase = new SolarCaseRequestWrapper();

		Account acc = new Account();
		acc.Name = 'Valor';
		insert acc;

		reqSolarCase.idCliente = acc.Id;
		reqSolarCase.idContrato = '1027935';
		reqSolarCase.operatorCode = '004';
		reqSolarCase.protocolo = '09812719826';
		String csId = FinancialCaseManagement.createSolarCase(reqSolarCase).casoId;

		Test.startTest();
		try {
			FinancialCaseManagement.createPaymentItems(true, invoice, csId, acc.Id, 'Itens_Contestados');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@IsTest
	static void updateCaseAPIErrorContestationTest() {
		String casoId = [SELECT Id FROM Case LIMIT 1].Id;
		CEC_DisputeInvoice.DisputeInvoiceRequest invoice = disputeInvoiceTeste();
		invoice.caseId = casoId;

		Test.startTest();
		FinancialCaseManagement.updateCaseAPIErrorContestation(invoice);

		Test.stopTest();
	}

	@IsTest
	static void isBackofficeN2Test() {
		Test.startTest();
		FinancialCaseManagement.isBackofficeN2();
		Test.stopTest();
	}

	/*@IsTest
    static void updateCaseContestationTest(){
		// Error on Class.CEC_HttpReq.sendReq: line 105, column 1 
		// Class.Solar_Cross_SendEmailIntegration.makeCallout: line 50, column 1
		// 
      String casoId = [SELECT Id FROM Case  LIMIT 1].Id;
      CEC_DisputeInvoice.DisputeInvoiceRequest invoice = disputeInvoiceTeste();
      
      Test.startTest();
      try {
				FinancialCaseManagement.updateCaseContestation(invoice, casoId, null, null, true);
				FinancialCaseManagement.updateCaseContestation(invoice, casoId, null, null, false);
      } catch (Exception ex) {
        System.debug('Task:: variable ==>'+ ex);
      }
      Test.stopTest();
      
    }*/
}