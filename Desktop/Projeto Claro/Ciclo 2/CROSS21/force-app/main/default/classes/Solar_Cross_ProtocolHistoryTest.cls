/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe de teste da Solar_Cross_ProtocolHistoryController
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-03      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_ProtocolHistoryTest {
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        
        List<Account> lContractLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '102030', BusinessUnit__c = 'Claro', CityCode__c = '11')};
        insert lContractLst;

        List<Contract> lContract = new List<Contract>{new Contract(Name = '1020304050', AccountId = lContractLst[0].Id),new Contract(Name = '1020304050', AccountId = lContractLst[1].Id)};
        insert lContract;

        List<Case> lCaseLst = new List<Case>{new Case(ContractNumber__c = lContract[0].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[0].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id),new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id)};
        insert lCaseLst;      
    }

    static testMethod void getOrdemsfromData(){
        List<Case> lCaseLst = [SELECT Id, ContractBillingAccount__c FROM Case WHERE Subject = 'Default'];

        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/ocurrences','OcurrenceMock');
        lMultimock.setStaticResource('/protocols','ProtocolsMock');
        lMultimock.setStaticResource('/solics','SolicsMock');
        lMultimock.setStatusCode(200);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        String startDate = String.valueOf(System.today().addDays(-10));
        String endDate = String.valueOf(System.today().addDays(10));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_ProtocolHistoryController.getHistory(lCaseLst[0].Id, startDate, endDate);
        Solar_Cross_ProtocolHistoryController.getHistory(lCaseLst[0].ContractBillingAccount__c, startDate, endDate);
        Test.stopTest();       
    }      

    static testMethod void getOrdemsfromDataBadRequest(){
        List<Case> lCaseLst = [SELECT Id, ContractBillingAccount__c FROM Case WHERE Subject = 'Default'];
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/ocurrences','OcurrenceMock');
        lMultimock.setStaticResource('/protocols','ProtocolsMock');
        lMultimock.setStaticResource('/solics','ProtocolsMock');
        lMultimock.setStatusCode(500);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        String startDate = String.valueOf(System.today().addDays(-10));
        String endDate = String.valueOf(System.today().addDays(10));
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_ProtocolHistoryController.getHistory(lCaseLst[0].Id, startDate, endDate);
        Test.stopTest();
    }
    static testMethod void dateErrors(){
        String startDate = String.valueOf(System.today().addDays(10));
        String endDate = String.valueOf(System.today());
        
        Test.startTest();
        try{
            Solar_Cross_ProtocolHistoryController.getHistory(null, startDate, endDate);
        } 
        catch(exception e){
            //dateError
        } 

        startDate = String.valueOf(System.today().addDays(-365));

        try{
            Solar_Cross_ProtocolHistoryController.getHistory(null, startDate, endDate);
        } 
        catch(exception e){
            //dateError
        }   
        Test.stopTest();
    }
    static testMethod void getOCAndOS(){
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('callout:OAGClaro/orders/workorder?requestID=123&operatorCode=123&contractNumber=123','OCAndOSMock');
        lMultimock.setStaticResource('callout:OAGClaro/orders/configurationorder?requestID=123&operatorCode=123&contractNumber=123','OCAndOSMock');        
        lMultimock.setStatusCode(200);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Solar_Cross_ProtocolHistoryController.DataFields lSolicParameter = new Solar_Cross_ProtocolHistoryController.DataFields();        
        lSolicParameter.OccurrenceNumber = '123';
        lSolicParameter.RequestID = '123';
        lSolicParameter.OperatorCode = '123';

        String lParameter = JSON.serialize(lSolicParameter);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMultimock);        
        Solar_Cross_ProtocolHistoryController.getOCAndOS(lParameter);
        Test.stopTest();
    }
}