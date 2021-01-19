/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe CEC_PME_SalesDocumentsService.
*/

@isTest
public class CEC_PME_SalesDocumentsServiceTest {
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */  
    @testSetup 
    public static void setup() {
		CEC_PME_OrderTestMethods.generateAllData();
        
        Profile profileId = [SELECT Id FROM Profile WHERE name = 'AACE PME'];
        
        User varUser = new User();
        varUser.ProfileId = profileId.Id;
        varUser.FirstName = 'Teste';
        varUser.LastName = 'Test';
        varUser.Alias = 'Test';
        varUser.Email = 'usertest@teste.com';
        varUser.Username = 'usertest@teste.com';
        varUser.CommunityNickname = 'UserTest';
        varUser.LocaleSidKey = 'pt_BR';
        varUser.LanguageLocaleKey = 'pt_BR';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.TimeZoneSidKey = 'America/Sao_Paulo';
        
        insert varUser;  
        
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_SalesDocuments';        
        serviceParameter.User__c = 'APP_TESTE';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '';  
        serviceParameter.EndPoint__c = 'http://200.169.123.170:9000/corp/salesdocuments';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;
        
        insert serviceParameter;        
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Teste para pedido preenchido.
    */ 
    @isTest static void testSalesDocs() {
        Order varOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_SalesDocumentsServiceMock());
        String retorno = CEC_PME_SalesDocumentsService.getDocuments(varOrder.Id);
        System.assertNotEquals(null, retorno);
        Test.stopTest();       
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Teste com pedido em branco.
    */ 
    @isTest static void testSalesDocsBranco() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_SalesDocumentsServiceMock());
        String retorno = CEC_PME_SalesDocumentsService.getDocuments('');
        System.assertEquals('Id do pedido não pode estar em branco.', retorno);
        Test.stopTest();       
    } 
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Teste com pedido inexistente
    */     
    @isTest static void testSalesDocsPedInv() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_SalesDocumentsServiceMock());
        String retorno = CEC_PME_SalesDocumentsService.getDocuments('12345');
        System.assert(retorno.contains('Erro na integração'));
        Test.stopTest();       
    }    
}