@isTest
public class Solar_Cross_ContestationControllerTest {
    
    @TestSetup
    static void dataSetup(){

		Account conta = new Account(Name = 'Account Test 1');
        conta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert conta;        
        
        Account contrato = new Account(Name = 'Account Test');
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ParentId = conta.id;
        insert contrato;

        Case caso = new Case();
        caso.AccountId = conta.id;
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
        String BillingRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Account objAccount = [SELECT Id, Name FROM Account WHERE Name = 'Account Test 1' LIMIT 1];
        List<Account> lstBillingAccount = [SELECT Id FROM Account WHERE ParentId =: objAccount.id ];
        Case objCase = [SELECT id, Account.Id, LegacyProtocol__c, ContractBillingAccount__c FROM Case WHERE LegacyProtocol__c = '123456789' LIMIT 1];
        Test.startTest();
            List<Solar_Cross_ContestationController.contestationWrapper> lstReturn = Solar_Cross_ContestationController.getContestations(objAccount.Id);
            List<Solar_Cross_ContestationController.contestationWrapper> lstReturn2 = Solar_Cross_ContestationController.getContestations(objCase.Id);
        Test.stopTest();
        System.assertEquals(!lstReturn.isEmpty(),true);
        System.assertEquals(!lstReturn2.isEmpty(),true);


    }

}