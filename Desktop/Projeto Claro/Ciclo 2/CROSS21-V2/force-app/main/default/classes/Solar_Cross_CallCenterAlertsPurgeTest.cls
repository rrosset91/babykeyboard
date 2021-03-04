/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Unit test by Solar_Cross_CallCenterAlertsPurgeBatch
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-11-02      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_CallCenterAlertsPurgeTest {
    private static final Id ALERTS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Alerts').getRecordTypeId();  
    private static final Id JUNCTION_RECTYPE = SObjectType.ParametersJunction__c.getRecordTypeInfosByDeveloperName().get('Parameters_Account').getRecordTypeId();
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CONSUMER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();

    
    @TestSetup
    static void makeData(){

        List<Account> lAccountLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account (RecordTypeId = CONSUMER_RECTYPE, Name = 'Consumer', CityCode__c = '11')};
        insert lAccountLst;

        List<Parameters__c> lAlertLst = new List<Parameters__c>{new Parameters__c(RecordTypeId = ALERTS_RECTYPE, StartDate__c = system.today().addDays(-5), EndDate__c = system.today().addDays(-3), Reason__c = 'reparo', FeedbackToCustomer__c = 'OK'), new Parameters__c(RecordTypeId = ALERTS_RECTYPE, StartDate__c = system.today().addDays(-10), Reason__c = 'atendimento', FeedbackToCustomer__c = 'OK 2')};
        insert lAlertLst;

        List<ParametersJunction__c> lJunctionLst = new List<ParametersJunction__c>{new ParametersJunction__c(RecordTypeId = JUNCTION_RECTYPE, Alert__c = lAlertLst[0].Id, Account__c = lAccountLst[0].Id), new ParametersJunction__c(RecordTypeId = JUNCTION_RECTYPE, Alert__c = lAlertLst[1].Id, Account__c = lAccountLst[1].Id)};
        insert lJunctionLst;
    }

    static testMethod void runBatch(){
        Test.startTest();
        Solar_Cross_CallCenterAlertsPurgeBatch lSb = new Solar_Cross_CallCenterAlertsPurgeBatch();
        String lSch = '0 0 1 * * ? *';
        String jobID = system.schedule('Call Center Alert Purge', lSch, lSb);
        Test.stopTest();
    }
}