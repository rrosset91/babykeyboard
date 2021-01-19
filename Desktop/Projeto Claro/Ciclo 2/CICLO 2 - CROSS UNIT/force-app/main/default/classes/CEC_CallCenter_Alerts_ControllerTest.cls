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
    private static final Id JUNCTION_RECTYPE = SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('Alert').getRecordTypeId();
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CONSUMER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    
    @TestSetup
    static void makeData(){

        List<Account> lAccountLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account (RecordTypeId = CONSUMER_RECTYPE, Name = 'Consumer', CityCode__c = '11')};
        insert lAccountLst;       

        Case lCase = new Case(AccountId = lAccountLst[1].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lAccountLst[0].Id);
        insert lCase;


        List<Parameters__c> lAlertLst = new List<Parameters__c>{new Parameters__c(RecordTypeId = ALERTS_RECTYPE, StartDate__c = system.today().addDays(-5), EndDate__c = system.today().addDays(5), Reason__c = 'reparo', FeedbackToCustomer__c = 'OK'), new Parameters__c(RecordTypeId = ALERTS_RECTYPE, StartDate__c = system.today().addDays(-10), EndDate__c = system.today().addDays(10), Reason__c = 'atendimento', FeedbackToCustomer__c = 'OK 2')};

        insert lAlertLst;

        List<vlocity_cmt__CustomerInteraction__c> lJunctionLst = new List<vlocity_cmt__CustomerInteraction__c>{new vlocity_cmt__CustomerInteraction__c(RecordTypeId = JUNCTION_RECTYPE, Name = 'First Junction', Alert__c = lAlertLst[0].Id, vlocity_cmt__AccountId__c = lAccountLst[0].Id), new vlocity_cmt__CustomerInteraction__c(RecordTypeId = JUNCTION_RECTYPE, Name = 'Second Junction', Alert__c = lAlertLst[1].Id, vlocity_cmt__AccountId__c = lAccountLst[1].Id)};
        insert lJunctionLst;
    }

    static testMethod void getAlerts(){
        Parameters__c lParam = [SELECT Id FROM Parameters__c LIMIT 1];
        Case lCase = [SELECT Id FROM Case LIMIT 1];
        CEC_CallCenter_Alerts_Controller.getAlerts(lCase.Id);
        CEC_CallCenter_Alerts_Controller.concludeAlertApex(lParam.Id,lCase.Id);
    }
}