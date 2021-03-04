@isTest
public class Solar_Cross_SendEmailIntegrationTest {
    
    @TestSetup
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/communicationmanagement/send', 'POST', 'OAG_NET_SendEmail', 'MCIDAS', 'OAGClaro'));
        insert params;
        
        Account contrato = new Account(Name = 'Account Test');
        contrato.ExternalID__c = 'Contratot123';
        contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        contrato.BusinessUnit__c = 'NET';
        contrato.CityCode__c = '004';
        contrato.ContractReferenceNumber__c = '12345';
        insert contrato;

        Case caso = new Case();
        caso.accountId = contrato.id;
        caso.ContractBillingAccount__c = contrato.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        caso.invoice__c = '244986912';
        insert caso;
        
    }
    @isTest
    static void sendEmailCase1Test(){
        Case objCase = [SELECT Id, Account.Name, Account.vlocity_cmt__BillingEmailAddress__c , LegacyProtocol__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
        Solar_Cross_SendEmailIntegration.processBuilderVariables pbVar = new Solar_Cross_SendEmailIntegration.processBuilderVariables();      
        pbVar.keyCenario = '1';
        pbVar.contactEmail = 'Teste@teste.com';
        pbVar.protocolNumber = '12345678';
        pbVar.accountName = 'Teste';
        pbVar.caseId = objCase.Id;
        Test.startTest();
        Solar_Cross_SendEmailIntegration.sendStatusEmail(new List<Solar_Cross_SendEmailIntegration.processBuilderVariables>{pbVar});
        Test.stopTest();

    }

    @isTest
    static void makeCallout(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
        Solar_Cross_SendEmailIntegration.processBuilderVariables pbVar = new Solar_Cross_SendEmailIntegration.processBuilderVariables();      
        pbVar.keyCenario = '1';
        pbVar.contactEmail = 'Teste@teste.com';
        pbVar.protocolNumber = '12345678';
        pbVar.accountName = 'Teste';
        Test.startTest();
        Solar_Cross_SendEmailIntegration.makeCallout('OAG_NET_SendEmail',JSON.Serialize(pbVar));
        Test.stopTest();
    }

  /*  @isTest
    static void sendEmailCase2Test(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
        Solar_Cross_SendEmailIntegration.processBuilderVariables pbVar = new Solar_Cross_SendEmailIntegration.processBuilderVariables();      
        pbVar.keyCenario = '2';
        pbVar.contactEmail = 'Teste@teste.com';
        pbVar.protocolNumber = '12345678';
        Test.startTest();
        Solar_Cross_SendEmailIntegration.sendStatusEmail(new List<Solar_Cross_SendEmailIntegration.processBuilderVariables>{pbVar});
        Test.stopTest();

    }


    @isTest
    static void sendEmailCase3Test(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
        Solar_Cross_SendEmailIntegration.processBuilderVariables pbVar = new Solar_Cross_SendEmailIntegration.processBuilderVariables();      
        pbVar.keyCenario = '3';
        pbVar.contactEmail = 'Teste@teste.com';
        pbVar.protocolNumber = '12345678';
        Test.startTest();
        Solar_Cross_SendEmailIntegration.sendStatusEmail(new List<Solar_Cross_SendEmailIntegration.processBuilderVariables>{pbVar});
        Test.stopTest();

    }*/

    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String userName, String namedCredential){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = userName;
        param.NamedCredential__c = namedCredential;
        return param;
    }     
}