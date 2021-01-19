@isTest
public class CEC_BanksAccountsValidationCtrlTest {
    @testSetup 
    public static void testSetup() {
        insert new ServiceParameter__c(Name = 'CEC_IntegrationBanksAccountsValidation', 
                                       EndPoint__c = 'http://200.169.123.170:9000/corp/banks/accounts/validations', 
                                       Method__c = 'GET');        
    }
    
    @isTest static void testBanks() {
        Boolean retorno;
        
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        lInputMap.put('bic', 'Test');
        lInputMap.put('branchNumber', '0001');
        lInputMap.put('accountNumber', '0001');
        
        CEC_HttpCalloutMockImpl lMockImpl = new CEC_HttpCalloutMockImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, lMockImpl);
        
        CEC_BanksAccountsValidationController lInteg = new CEC_BanksAccountsValidationController();
        
        for (Integer iHttpCode: new list<Integer>{ -1, 200 })
        {
            lMockImpl.httpCode = iHttpCode;
            retorno = lInteg.invokeMethod('banksAccountsValidation', lInputMap, lOutMap, lOptions);
        }
        Test.stopTest();
        
        Object response = lOutMap.get('isAccountValid');
        system.assert(response != null);
    }
    @isTest static void testBanksAccountsValidationResponse() {
        CEC_IntegrationBanksAccountsValidation.BanksAccountsValidationResponse newBanksAccountsValidationResponse = 
            new CEC_IntegrationBanksAccountsValidation.BanksAccountsValidationResponse();
        newBanksAccountsValidationResponse.data.isValid = 'false';
        newBanksAccountsValidationResponse.getValue();
    }
}