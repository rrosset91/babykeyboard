/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 29-10-2020
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   29-10-2020   Diego Almeida   Initial Version
**/
@isTest
public with sharing class FinancialMobileInvoicesDetailsTest {
    @testSetup 
    static void charge(){
        ServiceParameter__c setting = new ServiceParameter__c();
            setting.Token__c = 'returnedToken';
            setting.Name = 'TestStest';
            setting.EndPoint__c = 'www.google.com';
            setting.Method__c = 'GET';
            setting.ReturnMock__c = true;
            setting.Timeout__c = 120000;
        insert setting;
    }
    @isTest
    public static void getListInvoiceDetails_Test(){
        test.startTest();
            FinancialMobileInvoicesDetailsWrapper.ResponseWrapper response = new FinancialMobileInvoicesDetailsWrapper.ResponseWrapper();
            response = FinancialMobileInvoicesDetailsController.getListInvoiceDetails('');
            System.assertEquals(response.responseCode, 200);
        test.stopTest();
    }

}