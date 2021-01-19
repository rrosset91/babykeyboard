@isTest
public class CEC_IntegrationSalesTest {
@testSetup
    public static void testSetup()
    {
        User varUser = new User();
        varUser.FirstName = 'Omae';
        varUser.LastName = 'Inshidiro';
        varUser.Email = 'test@testing.com';
        varUser.Alias = 'NANI';
        varUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Vendedor Televendas' LIMIT 1].Id;
        varUser.Username = 'logical@mytologichal.com';
        varUser.Channel__c = 'TELEVENDAS';
        varUser.SalesTeamNET__c = 'CRN NACIONAL';
        varUser.NetServicos__c = '92037524';
        varUser.TimeZoneSidKey = 'GMT';
        varUser.LanguageLocaleKey = 'en_US';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.LocaleSidKey = 'en_US';
        
        varUser.Claro__c = '92037524';
        
        insert varUser;
    }    
    
    @isTest static void testIntegrationSales() {
		insert new ServiceParameter__c(Name = 'SalesMan', EndPoint__c = 'http://200.169.123.170:9000/corp/salesmen', Method__c = 'GET');                
        
        User varUser = [SELECT Id, Claro__c FROM User LIMIT 1];
        
        System.runAs(varUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
            SalesManDTO.SalesMan integration = CEC_IntegrationSales.consultar(varUser.Claro__c);    
            Test.stopTest();            
        }
    }
    
	@isTest 
    static void testIntegrationSalesMock()
    {
		insert new ServiceParameter__c(Name = 'SalesMan', EndPoint__c = 'http://200.169.123.170:9000/corp/salesmen', Method__c = 'GET');        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpCalloutMockImpl(200));
        CEC_IntegrationSales integration = new CEC_IntegrationSales();
        SalesManDTO.SalesMan mock = integration.generateMock();
        system.assert(mock != null);
        
        Test.stopTest();
    }
}