/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe de teste da CEC_CallCenter_Alerts_Controller
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-05      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public with sharing class CEC_CallCenter_Alerts_ControllerTest {
    private static final Id ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Alerts').getRecordTypeId();

    private static final Id GENERAL_ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('GeneralAlerts').getRecordTypeId();

    private static final Id JUNCTION_RECTYPE = SObjectType.ParametersJunction__c.getRecordTypeInfosByDeveloperName().get('Parameters_Account').getRecordTypeId();
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CONSUMER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    
    @TestSetup
    static void makeData(){

        List<Account> lAccountLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ShippingCity = 'SAO PAULO', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account (RecordTypeId = CONSUMER_RECTYPE, Name = 'Consumer', CityCode__c = '11')};
        insert lAccountLst;       

        Case lCase = new Case(AccountId = lAccountLst[1].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lAccountLst[0].Id, LegacyProtocol__c = '123');
        insert lCase;



        List<Parameters__c> lAlertLst = new List<Parameters__c>{new Parameters__c(RecordTypeId = ALERTS_RECTYPE, StartDate__c = system.today().addDays(-5), EndDate__c = system.today().addDays(5), Reason__c = 'Informação', FeedbackToCustomer__c = 'OK'), 
            new Parameters__c(RecordTypeId = GENERAL_ALERTS_RECTYPE, StartDate__c = system.today().addDays(-5), EndDate__c = system.today().addDays(5), Reason__c = 'Informação', FeedbackToCustomer__c = 'OK', Business_Unit__c = 'Net'),
            new Parameters__c(RecordTypeId = GENERAL_ALERTS_RECTYPE, StartDate__c = system.today().addDays(-5), EndDate__c = system.today().addDays(5), Reason__c = 'Informação', FeedbackToCustomer__c = 'OK', Business_Unit__c = 'Net', GeneralAlertType__c = 'Problemas de Rede')
        };


        insert lAlertLst;

        List<ParametersJunction__c> lJunctionLst = new List<ParametersJunction__c>{new ParametersJunction__c(RecordTypeId = JUNCTION_RECTYPE, Alert__c = lAlertLst[0].Id, Account__c = lAccountLst[0].Id), new ParametersJunction__c(RecordTypeId = JUNCTION_RECTYPE, Alert__c = lAlertLst[0].Id, Account__c = lAccountLst[1].Id)};
        insert lJunctionLst;

        List<vlocity_cmt__CustomerInteraction__c> lInteractionLst = new List<vlocity_cmt__CustomerInteraction__c>{new vlocity_cmt__CustomerInteraction__c(ProtocolNumber__c = '123')};
        insert lInteractionLst;
    }

    static testMethod void getAlerts(){
        Parameters__c lParam = [SELECT Id, StartDate__c, EndDate__c, Reason__c, FeedbackToCustomer__c, RecordTypeId FROM Parameters__c LIMIT 1];
        Case lCase = [SELECT Id FROM Case LIMIT 1];

        CEC_CallCenter_Alerts_Controller.AlertsWrapper lAlertToSerialize = new CEC_CallCenter_Alerts_Controller.AlertsWrapper();
        lAlertToSerialize.lId = lParam.Id;
        lAlertToSerialize.lFeedbackToCustomer = lParam.FeedbackToCustomer__c;
        lAlertToSerialize.lFeedbackToCustomerLimited = lAlertToSerialize.lFeedbackToCustomer.abbreviate(50);
        lAlertToSerialize.lReason = lParam.Reason__c;
        lAlertToSerialize.lRecordTypeDeveloperName = 'Alerts';
        lAlertToSerialize.lShow = false;

        String lSerializedAlert = JSON.serialize(lAlertToSerialize);

        CEC_CallCenter_Alerts_Controller.getAlerts(lCase.Id);
        CEC_CallCenter_Alerts_Controller.concludeAlertApex(lCase.Id,lSerializedAlert);
    }
}