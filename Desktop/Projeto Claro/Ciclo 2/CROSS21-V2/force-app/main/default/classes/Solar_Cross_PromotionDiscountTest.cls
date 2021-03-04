/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-15-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_PromotionDiscountTest {

    static Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetFixa').getRecordTypeId();

    @TestSetup
    static void makeData(){

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ContractReferenceNumber__c = '11940309';
        contrato.BusinessUnit__c = 'Claro';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        insert caso;

        Asset ast = new Asset(Name = 'Asset Test', AccountId = contrato.Id, MSISDN__c = '1234567890', RecordTypeId = recordTypeAsset,vlocity_cmt__BillingAccountId__c = contrato.Id);
		insert ast;
    }

    @isTest
    static void getPromotionsAndDiscountsCase(){
        Case objCase = [SELECT Id FROM CASE LIMIT 1];
        Map<String,Object> mapReturn = Solar_Cross_PromotionDiscountController.getPromotionsAndDiscounts(objCase.id);
    }

    @isTest
    static void getPromotionsAndDiscountsAccount(){
        Account objAccount = [SELECT Id,BusinessUnit__c  FROM Account WHERE Name = 'Account Test' LIMIT 1];
        Map<String,Object> mapReturn = Solar_Cross_PromotionDiscountController.getPromotionsAndDiscounts(objAccount.id);
    }
}