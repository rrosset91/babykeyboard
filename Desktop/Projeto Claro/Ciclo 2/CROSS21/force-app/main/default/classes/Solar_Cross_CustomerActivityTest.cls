/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Solar_Cross_CustomerActivity Unit Test
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-17      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_CustomerActivityTest { 
    
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        List<Account> lContractLst = new List<Account>{new Account(AccountActiveSince__c = system.today().addDays(-20), RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '102030', BusinessUnit__c = 'Claro', CityCode__c = '11')};
        insert lContractLst;

        List<Contract> lContract = new List<Contract>{new Contract(Name = '1020304050', AccountId = lContractLst[0].Id),new Contract(Name = '1020304050', AccountId = lContractLst[1].Id)};
        insert lContract;

        List<Case> lCaseLst = new List<Case>{new Case(AccountId = lContractLst[0].Id, ContractNumber__c = lContract[0].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[0].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id),new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id)};
        insert lCaseLst;      
    }
    
    static testMethod void caseActivity(){
        
        List<Case> lCaseLst = [SELECT Id FROM Case];

        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/ocurrences','OcurrenceMock');
        lMultimock.setStaticResource('/protocols','ProtocolsMock');
        lMultimock.setStaticResource('/solics','SolicsMock');
        lMultimock.setStatusCode(200);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_CustomerActivityController.getActivity(lCaseLst[0].Id);
        Test.stopTest();
    }      

    static testMethod void accountActivity(){
        
        List<Account> lAccountLst = [SELECT Id FROM Account WHERE AccountActiveSince__c != null];

        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/ocurrences','OcurrenceMock');
        lMultimock.setStaticResource('/protocols','ProtocolsMock');
        lMultimock.setStaticResource('/solics','SolicsMock');
        lMultimock.setStatusCode(200);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_CustomerActivityController.getActivity(lAccountLst[0].Id);
        Test.stopTest();
    }      

    static testMethod void contractType(){
        Case objCase = [SELECT Id, BusinessUnit__c,ContractBillingAccount__c FROM Case WHERE ContractBillingAccount__r.BusinessUnit__c = 'Net' LIMIT 1];
        Test.startTest();
        Solar_Cross_CustomerActivityController.getContractType(objCase.Id);
        Test.stopTest();
    }
}