@istest
public class CEC_ME_CallIntegrationProtocolTest {
    @testSetup static void charge(){
        List<ServiceParameter__c> lstParam = new List<ServiceParameter__c>();
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = 'ProtocolNet';
        param.EndPoint__c = 'https://apiuat.net.com.br:7443/sdp/interactions';
        param.Method__c = 'POST';
        param.Password__c = 'x1234';
        param.User__c = 'APP_TESTE';
        param.IsActive__c = true;
        param.Timeout__c = 10.000;
        lstParam.add(param);
        ServiceParameter__c param2 = new ServiceParameter__c();
        param2.Name = 'CEC_OAG_NET_Protocol';
        param2.EndPoint__c = 'https://apiuat.net.com.br:7443/sdp/interactions';
        param2.Method__c = 'POST';
        param2.Password__c = 'x1234';
        param2.User__c = 'APP_TESTE';
        param2.IsActive__c = true;
        param2.Timeout__c = 10.000;
        lstParam.add(param2);
        insert lstParam;
    }
    
    @isTest static void testCustomerInteraction(){
        Account parentAcc = createAccount(null);
        insert parentAcc;
        Account childAcc = createAccount(parentAcc.Id);
        insert childAcc;
        vlocity_cmt__CustomerInteraction__c customerInteraction = createCustomerInteraction('1234567', '1234567', parentAcc.Id);
        insert customerInteraction;
        //options param
        Map<String,Object> options = new Map<String,Object>();
        options.put('NumeroContrato', '1234567');
        options.put('CodigoOperadora', '1234567');
        options.put('ContextId', childAcc.Id);
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outputMap = new Map<String, Object>();
        Test.startTest();
        CEC_ME_CallIntegrationProtocol testedClass = new CEC_Me_CallIntegrationProtocol();
        testedClass.invokeMethod('CreateProtocolNetService', inputMap, outputMap, options);
        Test.stopTest();
    }
    @isTest static void testProtocolService(){
        Account parentAcc = createAccount(null);
        insert parentAcc;
        Account childAcc = createAccount(parentAcc.Id);
        insert childAcc;
        //options param
        Map<String,Object> options = new Map<String,Object>();
        options.put('NumeroContrato', '1234567');
        options.put('CodigoOperadora', '1234567');
        options.put('ContextId', childAcc.Id);
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outputMap = new Map<String, Object>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallIntegrationProtocol());
        CEC_ME_CallIntegrationProtocol testedClass = new CEC_Me_CallIntegrationProtocol();
        testedClass.invokeMethod('CreateProtocolNetService', inputMap, outputMap, options);
        Test.stopTest();
    }
    //gerar objeto conta
    public static Account createAccount(String parentId){
        return new Account(Name = 'Test' + System.currentTimeMillis(),
                           ParentId = parentId);
    }
    //gerar objeto customer interaction
    public static vlocity_cmt__CustomerInteraction__c createCustomerInteraction(String protocolNum, String docNum, String accountId){
        return new vlocity_cmt__CustomerInteraction__c(Name = 'Test' + System.currentTimeMillis(), 
                                                       ProtocolNumber__c = protocolNum, 
                                                       Document_Number__c = docNum, 
                                                       vlocity_cmt__AccountId__c = accountId);
    }
}