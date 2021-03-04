/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_IntegrationPromoDiscTest {

    static Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetFixa').getRecordTypeId();

    @TestSetup
    static void makeData(){


        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('callout:APIClaroResidential/billingaccounts/outageperiods', 'GET', 'ResidentialPromotionsDiscounts', 'Basic OTlBTm5BdzBRTHN2Y2F4QmRHQUU1UldoSlpQdXd0QUc6YlR4aGdHOEM4NXRkN1N1Yw=='));
        insert params;


        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ContractReferenceNumber__c = '11940309';
        contrato.CityCode__c    = '011';
        contrato.BusinessUnit__c = 'Net';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        insert caso;

        Asset ast = new Asset(Name = 'Asset Test', AccountId = contrato.Id,status = 'Ativo', MSISDN__c = '1234567890', RecordTypeId = recordTypeAsset,vlocity_cmt__BillingAccountId__c = contrato.Id, CodigoProdutoLegado__c = '65214');
		insert ast;
    }

    @isTest
    static void getPromotionsAndDiscountsCase(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion":"1;2020-07-01","transactionId":"Id-34fcb05c6d1923e35cef248d","data":{"operatorCode":"003","contractNumber":"98465123","bonusAmount":1600,"promotions":[{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":9.99,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2019-10-25T15:00:00.000Z"},{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":9.99,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2022-10-25T15:00:00.000Z"},{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":9.99,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2022-10-25T15:00:00.000Z"},{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":20.00,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-27T15:00:00.000Z","endDate":"2019-10-26T15:00:00.000Z"}],"discounts":[{"discountType":1,"descriptionDiscount":"aa","discountValue":9.99,"pointId":11603,"pointType":"P","productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2021-11-25T15:00:00.000Z"},{"discountType":1,"descriptionDiscount":"PORCENTAGEM","discountValue":100.00,"pointId":11603,"pointType":"P","productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-03-25T15:00:00.000Z","endDate":"2019-04-25T15:00:00.000Z"},{"discountType":1,"descriptionDiscount":"","discountValue":100.00,"pointId":11603,"pointType":"P","productId":122123,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-01-25T15:00:00.000Z","endDate":"2021-04-24T15:00:00.000Z"},{"discountType":1,"descriptionDiscount":"","discountValue":100.00,"pointId":11603,"pointType":"P","productId":122123,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-01-25T15:00:00.000Z","endDate":"2021-04-24T15:00:00.000Z"}]}}', 200));
        Case objCase = [SELECT Id FROM CASE LIMIT 1];
        Test.startTest();
        Map<String,Object> mapReturn = Solar_Cross_IntegrationPromotionDiscount.getPromotionsAndDiscounts(objCase.id);
        Test.stopTest();
        System.assertEquals(true,mapReturn.get('success'));
    }

    @isTest
    static void getPromotionsAndDiscountsCaseError(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion":"1;2020-07-01","transactionId":"Id-34fcb05c6d1923e35cef248d","data":{"operatorCode":"003","contractNumber":"98465123","bonusAmount":1600,"promotions":[{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":9.99,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2019-10-25T15:00:00.000Z"},{"promotionName":"INTERNET - FUTEBOL","pointId":11603,"pointType":"P","promotionValue":20.00,"totalMonthsDiscount":12,"productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-27T15:00:00.000Z","endDate":"2019-10-26T15:00:00.000Z"}],"discounts":[{"discountType":1,"descriptionDiscount":"aa","discountValue":9.99,"pointId":11603,"pointType":"P","productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-10-25T15:00:00.000Z","endDate":"2021-11-25T15:00:00.000Z"},{"discountType":1,"descriptionDiscount":"PORCENTAGEM","discountValue":100.00,"pointId":11603,"pointType":"P","productId":65214,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-03-25T15:00:00.000Z","endDate":"2019-04-25T15:00:00.000Z"},{"discountType":1,"descriptionDiscount":"","discountValue":100.00,"pointId":11603,"pointType":"P","productId":122123,"productDescription":"FONE+NET FALE SIMPLES","startDate":"2019-01-25T15:00:00.000Z","endDate":"2021-04-24T15:00:00.000Z"}]}}', 422));
        Case objCase = [SELECT Id FROM CASE LIMIT 1];
        Test.startTest();
        Map<String,Object> mapReturn = Solar_Cross_IntegrationPromotionDiscount.getPromotionsAndDiscounts(objCase.id);
        Test.stopTest();
    }
    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String Token){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.Token__c = Token;
        param.Timeout__c = 120000;
        param.User__c =   'APP_TESTE';
        param.Password__c = 'claro#123';
        return param;
    }  
}