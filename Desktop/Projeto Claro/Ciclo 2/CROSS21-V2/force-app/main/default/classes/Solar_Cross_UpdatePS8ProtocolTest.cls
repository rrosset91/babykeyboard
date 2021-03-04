/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-05-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Solar_Cross_UpdatePS8ProtocolTest {

    public static String rtFinancial = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    public static String rtGeneral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    public static String rtBackOffice = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Backoffice').getRecordTypeId();

    @testSetup 
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('https://api-test.claro.com.br/dataprivacy/v1/customers/interactions', 'put','customersInteractionsUpdate', 'Basic R2tnbmNTc2VHY0hlZHk4ZzBBY096RThHb2lTUjM2cVM6NnY3czVVeHBNb1Bqb2UxWA=='));
        insert params;

        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.ContractReferenceNumber__c = '11940309000';
        insert contrato;

        Case caso = new Case();
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = rtFinancial;
        caso.LegacyProtocol__c = '1234';
        caso.RequestSupport__c = '2341';
        caso.Description = 'Testando';
        caso.Status = 'New';
        insert caso;
    }

    @isTest
    private static void Solar_Cross_UpdatePS8ProtocolTest(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion":"1;2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","data":{"protocolNumber": "XJEET2346FhK"}}', 200));
        Case objCase = [SELECT LegacyProtocol__c, RequestSupport__c, Description, CreatedDate, Status,Resolution__c FROM Case WHERE RecordTypeId =: rtFinancial OR RecordTypeId =: rtGeneral OR RecordTypeId =: rtBackOffice ];
        Test.startTest();
            Solar_Cross_UpdatePS8Protocol.updateProtocol(new List<Case> {objCase});
        Test.stopTest();
    }

    @isTest
    private static void callIntegrationTeste(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion":"1;2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","data":{"protocolNumber": "XJEET2346FhK"}}', 200));
        
        Case objCase = [SELECT LegacyProtocol__c, RequestSupport__c, Description,Resolution__c, CreatedDate FROM Case WHERE RecordTypeId =: rtFinancial OR RecordTypeId =: rtGeneral OR RecordTypeId =: rtBackOffice LIMIT 1];

        Solar_Cross_UpdatePS8Protocol.Data objData = new Solar_Cross_UpdatePS8Protocol.Data();
        Solar_Cross_UpdatePS8Protocol.CustomerInteraction objCustomerInteraction = new Solar_Cross_UpdatePS8Protocol.CustomerInteraction();
        objCustomerInteraction.protocolnumber = objCase.LegacyProtocol__c;
        objCustomerInteraction.status = 'FECHADO';
        objCustomerInteraction.details = objCase.RequestSupport__c;
        objCustomerInteraction.notes = objCase.Description;
        objCustomerInteraction.severity =  'MINIMA';
        objCustomerInteraction.situation = 'NOVO';
        objCustomerInteraction.slaDueDate = objCase.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        System.debug('objCustomerInteraction.slaDueDate: ' +objCustomerInteraction.slaDueDate);
        objCustomerInteraction.priority = 'MEDIA';
        objCustomerInteraction.caseTypeId = '12345';
        objCustomerInteraction.systemRelatedCaseId = 'SalesForce';

        objData.data = objCustomerInteraction;

        String body = JSON.serialize(objData);

        Test.startTest();
        Solar_Cross_UpdatePS8Protocol.callIntegration(body);
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
        return param;
    } 

}