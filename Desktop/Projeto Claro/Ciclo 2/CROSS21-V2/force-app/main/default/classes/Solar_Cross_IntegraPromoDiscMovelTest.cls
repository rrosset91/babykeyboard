@isTest
public class Solar_Cross_IntegraPromoDiscMovelTest {

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

        Asset asset = new Asset();
        asset.name = 'asset Teste';
        asset.AccountId = contrato.id;
        asset.MSISDN__c = '11999999999';
        asset.vlocity_cmt__BillingAccountId__c = contrato.id;
        asset.Status = 'Ativo';
        insert asset;

        ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'MobilePromotionsDiscounts';
		customSetting.EndPoint__c = 'callout:oagClaro';
		customSetting.Method__c = 'GET';
        customSetting.Timeout__c = 120;
        insert customSetting;
    }

    @isTest
    static void getPromotionsAndDiscountsTest(){
        Case objCase = [SELECT Id, ContractBillingAccount__c FROM Case LIMIT 1];
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/Subscriber','SubscriberMock');
        lMultimock.setStaticResource('/MobilePromotion','MobilePromotionDiscountMock');
        lMultimock.setStatusCode(200);
		lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Test.startTest();
        Solar_Cross_IntegrationPromoDiscMovel.getPromotionsAndDiscounts(objCase.Id);
        Test.stopTest();
       // lMultimock.setStaticResource('/InvoiceEvents','InvoiceEventsMock');

    }
}