/*
* Autor: Marcos Silva - Deloitte
* Data: 15/05/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de teste da classe CEC_PME_FilePreviewController
*/








@isTest
public class CEC_PME_FilePreviewControllerTest {
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Criação dos dados para execução dos testes
    */    

   
    @isTest
    private static void testClass()
    {
	CEC_PME_FilePreviewController controller = new CEC_PME_FilePreviewController() ;
    }
    
    
    
    @testSetup 
    static void testSetup() {
        Account accnt = new Account();
        accnt.Name = 'Teste Envelope';
        insert accnt;
        
        Order order = new Order();
        order.Status = 'Em Andamento';
        order.EffectiveDate = System.today().addDays(-1);
        order.AccountId = accnt.Id;
        insert order;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'someTitle';
        contentVersion.ContentUrl = 'someUrl';
        insert contentVersion;
        
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.LinkedEntityId = order.Id;
        docLink.ContentDocumentId = contentVersion.ContentDocumentId;
        docLink.ShareType = 'V';
        insert docLink;
        
        DesativarIntegracoes__c integrationSwitch = new DesativarIntegracoes__c();
        integrationSwitch.Mensagem__c = 'test';
        integrationSwitch.Name = 'Docusign';
        insert integrationSwitch;
	}
	
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Execução dos testes
    */     
    @isTest
	public static void mainTest() {
        Id orderId = [SELECT Id FROM Order].Id;
		CEC_PME_FilePreviewController.carregar(orderId);
        CEC_PME_FilePreviewController.fetchUser(orderId);
        CEC_PME_FilePreviewController.isNotActiveIntegration();
        CEC_PME_FilePreviewController.saveTipoAnexo(orderId, CEC_PME_FilePreviewController.obterPickListValues().get(1), 'someTitle');
        CEC_PME_FilePreviewController.isPMEAdmin();
        
	}    
}