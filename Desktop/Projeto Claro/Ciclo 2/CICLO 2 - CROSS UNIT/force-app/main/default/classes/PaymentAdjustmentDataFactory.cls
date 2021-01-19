/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Payment Adjustment (vlocity))
* @date: 16-09-2020
*/
@isTest
public with sharing class PaymentAdjustmentDataFactory {

    //********** Este metodo recebe como parametro o nome do tipo de registro e Id da conta e caso associados e gera um payment adjustment**********
    public static vlocity_cmt__PaymentAdjustment__c getSinglePaymentAdjustment(String recordTypeName, String caseId, String accId){
        vlocity_cmt__PaymentAdjustment__c pmt = new vlocity_cmt__PaymentAdjustment__c();
            pmt.RecordTypeId = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            pmt.vlocity_cmt__DisputeId__c = caseId;
            pmt.vlocity_cmt__AccountId__c = accId;
            pmt.vlocity_cmt__Status__c = 'Pending';
        system.debug('@@SinglePayment -->'+pmt);
        return pmt;
    }
	
   
    //********** Este metodo recebe como parametro o nome do tipo de registro o Id da conta e caso associados e quantidade desejada e gera uma lista com a quantidade de PaymentAdjustments informada**********
    public static List<vlocity_cmt__PaymentAdjustment__c> getMultiplePaymentAdjustments(String recordTypeName, String caseId, String accId, Integer amount){
        Integer x = 1;
        List<vlocity_cmt__PaymentAdjustment__c> paymentList = new List<vlocity_cmt__PaymentAdjustment__c>();
        while (x <= amount){
        vlocity_cmt__PaymentAdjustment__c pmt = new vlocity_cmt__PaymentAdjustment__c();
            pmt.RecordTypeId = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            pmt.vlocity_cmt__DisputeId__c = caseId;
            pmt.vlocity_cmt__AccountId__c = accId;
            pmt.vlocity_cmt__Status__c = 'Pending';
            paymentList.add(pmt);
            x++;
        }
        system.debug('@@@PaymentList -->'+paymentList);
        return paymentList;
    }
}