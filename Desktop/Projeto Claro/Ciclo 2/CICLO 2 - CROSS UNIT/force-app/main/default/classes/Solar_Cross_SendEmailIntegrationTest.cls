@isTest
public class Solar_Cross_SendEmailIntegrationTest {
    
    @TestSetup
    static void makeData(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/communicationmanagement/send', 'POST', 'OAG_NET_SendEmail', 'MCIDAS', 'OAGClaro'));
        insert params;
    }
    @isTest
    static void sendEmailCase1Test(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
        Solar_Cross_SendEmailIntegration.processBuilderVariables pbVar = new Solar_Cross_SendEmailIntegration.processBuilderVariables();      
        pbVar.keyCenario = '1';
        pbVar.contactEmail = 'Teste@teste.com';
        pbVar.protocolNumber = '12345678';
        pbVar.accountName = 'Teste';
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