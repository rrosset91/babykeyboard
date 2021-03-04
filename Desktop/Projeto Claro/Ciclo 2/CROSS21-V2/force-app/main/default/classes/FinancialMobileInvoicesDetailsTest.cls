/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 

 * @last modified on  : 18-12-2020

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

            setting.Name = 'FinancialMobileBilledChargesDetails';
            setting.EndPoint__c = 'www.test.com';
            setting.Method__c = 'GET';
            setting.Timeout__c = 120000;
        insert setting;
    }
    @IsTest
    static void getInvoiceDetails_Test(){
        InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{"apiVersion":"1;2020-09-28","transactionId":"96dd1a35-6a3d-49d0-9121-c169ee1c25ce","data":{"billedCharged":[{"chargeId":"160588836313714428","payChannelId":"265.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Controle ","subscriberNo":"316,728,671","chargeSeqNo":"313,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
                +'{"chargeId":"170588836313714428","payChannelId":"266.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Pós ","subscriberNo":"317,728,671","chargeSeqNo":"314,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
                +'{"chargeId":"180588836313714428","payChannelId":"267.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":0,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Pré ","subscriberNo":"318,728,671","chargeSeqNo":"315,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
                +'{"chargeId":"190588836313714428","payChannelId":"268.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Full ","subscriberNo":"319,728,671","chargeSeqNo":"316,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"}'
                +']}}',
			200
		);

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper response = FinancialMobileInvoicesDetailsController.getInvoiceDetails('108680617');
            System.debug('getInvoiceDetails_Test: '+ response);
            System.assertEquals(response.responseCode, 200);
        Test.stopTest();

    }

}