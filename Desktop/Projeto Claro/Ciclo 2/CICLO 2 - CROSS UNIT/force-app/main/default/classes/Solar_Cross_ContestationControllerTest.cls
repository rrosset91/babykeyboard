@isTest
public class Solar_Cross_ContestationControllerTest {
    
    @TestSetup
    static void dataSetup(){

        Account contrato = new Account(Name = 'Account Test');
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert contrato;

        Case caso = new Case();
        caso.AccountId = contrato.id;
        caso.ContractBillingAccount__c = contrato.id;
        caso.LegacyProtocol__c  = '123456789';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        insert caso;

        vlocity_cmt__PaymentAdjustment__c paymentAdjust = new vlocity_cmt__PaymentAdjustment__c();
        paymentAdjust.RecordTypeId = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get('Itens_Contestados').getRecordTypeId();
        paymentAdjust.vlocity_cmt__AccountId__c = contrato.id;
        paymentAdjust.vlocity_cmt__DisputeId__c = caso.id;
        paymentAdjust.vlocity_cmt__Status__c = 'Approved';
        paymentAdjust.vlocity_cmt__Date__c = Date.today();
        paymentAdjust.ContestedAmount__c = 10;
        insert paymentAdjust;

    }

    @isTest
    static void getContestationsTest(){
        Account objAccount = [SELECT Id, Name FROM Account WHERE Name = 'Account Test' LIMIT 1];
        Case objCase = [SELECT id, Account.Id, LegacyProtocol__c FROM Case WHERE LegacyProtocol__c = '123456789' LIMIT 1];
        Test.startTest();
            List<Solar_Cross_ContestationController.contestationWrapper> lstReturn = Solar_Cross_ContestationController.getContestations(objAccount.Id);
            List<Solar_Cross_ContestationController.contestationWrapper> lstReturn2 = Solar_Cross_ContestationController.getContestations(objCase.Id);
        Test.stopTest();
        System.assertEquals(!lstReturn.isEmpty(),true);
        System.assertEquals(!lstReturn2.isEmpty(),true);


    }

}