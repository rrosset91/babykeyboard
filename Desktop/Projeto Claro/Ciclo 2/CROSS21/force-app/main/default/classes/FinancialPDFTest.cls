/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 11-12-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-12-2020   Diego Almeida   Initial Version
 * 1.0   07-12-2020   Diego Almeida   MobilePDF
**/

@isTest
public with sharing class FinancialPDFTest {

    @TestSetup static void charge(){
        ServiceParameter__c setting = new ServiceParameter__c();
        setting.Token__c = 'returnedToken';
        setting.Name = 'MobileInvoicesPDF';

        setting.EndPoint__c = 'Test/MobileInvoicesPDF';
        setting.Method__c = 'GET';
        setting.Timeout__c = 120000;
        insert setting;

        setting = new ServiceParameter__c();
        setting.Token__c = 'returnedToken';
        setting.Name = 'ResidencialInvoicesPDF';
        setting.EndPoint__c = 'Test/ResidencialInvoicesPDF';
        setting.Method__c = 'GET';
        setting.Timeout__c = 120000;

        insert setting;

    }

    @isTest

    public static void getPdf64Test(){
        InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{"apiVersion":"1;2019-01-28","transactionId":"Id-e0c6b75f61f9ef4a9dcd8447","error":{"httpCode":"422","errorCode":"API-INVOICESPDF-008","message":"Unprocessable Entity","detailedMessage":"OSB-CUSTOMER-00082 - Documento não foi encontrado.","link":{"rel":"related","href":"https://apiuat.net.com.br/docs/error_codes.html"}}}',
			200
		);

		Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

        	FinancialPDF.ResponseWrapper responseReturn = new FinancialPDF.ResponseWrapper();
        
            responseReturn = FinancialPDF.getPDFBase64('RESIDENCIAL', '171984374', '055', '');
   			

            Test.stopTest();
        System.assertEquals(responseReturn.hasError,false);
    }

    @isTest
    public static void getPdfUrlTest(){
        InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{"apiVersion":"1;2019-01-28","transactionId":"Id-e47bd35f8bd5008e79d65756","data":{"invoicePDF":{"invoiceURL":"http://brux0802:20060/BillImage/bf.blim_302858888_001_M1_PS.TAMB.pdf"}}}',
			200
		);

		Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        	FinancialPDF.ResponseWrapper responseReturn = new FinancialPDF.ResponseWrapper();

            responseReturn = FinancialPDF.getPDFURL('MOVEL','2020-12-02', '125890801');

            Test.stopTest();
        System.assertEquals(responseReturn.hasError,false);

    }
}