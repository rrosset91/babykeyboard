/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 29-01-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
**/
@istest
public with sharing class FinancialMobileInvoicesConfirmTest {

    @TestSetup
    static void makeData(){
        ServiceParameter__c setting = new ServiceParameter__c();
            setting.Token__c = 'returnedToken';
            setting.Name = 'TestStest';
            setting.EndPoint__c = 'www.google.com';
            setting.Method__c = 'GET';
            setting.Timeout__c = 120000;
        insert setting;
	}
	
    @IsTest
    static void getListContestation(){
        
        Test.startTest();
            FinancialMobileInvoicesConfirmWraper.ResponseWrapper response = FinancialMobileInvoicesConfirmation.getListContestation('');
		Test.stopTest();
		
		System.assertEquals(response.responseCode, 200);
        
    }   
}