/*
* Autor: Diogo Braga - Deloitte
* Data: 15/08/2019
* Descrição: CEC FASE 1 + SQUAD PME: Utilizada no teste da classe de controle dos botões exibidos na versão mobile da tela de pedido
*/
@isTest
public class CEC_PME_MobileButtonsControllerTest {
    
    public static Id getOrderId() {
        return getOrder().Id;
    }
    
    public static Order getOrder() {
        return [SELECT Id,
                Status,
                SubStatus__c,
                Observacoes__c,
                NumberQuote__c,
                StatusQuote__c,
                ErroMsg__c
                FROM Order];
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */     
    @testSetup
    static void testSetup() {
        Account newAccount = new Account();
        newAccount.name = 'test';
        insert newAccount;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test Contact';
        contact.LastName = 'Contact';
        contact.AccountId = newAccount.Id;
        insert contact;
        
        Product2 newProduct2 = new Product2(Name = 'testProduct2');
        insert newProduct2;
        
        PriceBookEntry newPriceBookEntry = new PriceBookEntry(UnitPrice = 10, 
                                                              Product2Id = newProduct2.Id, 
                                                              Pricebook2Id = Test.getStandardPricebookId());
        insert newPriceBookEntry;
        system.debug('newPriceBookEntry ' + newPriceBookEntry);
        
        Order newOrder = new Order(Status = 'Em Andamento',
                          EffectiveDate = Date.today().addDays(5),
                          AccountId = newAccount.Id, 
                          Pricebook2Id = Test.getStandardPricebookId(),
                          Name = 'test',
                          DocuSignEnvelopeID__c = 'test'                        
                         );
        insert newOrder;

        OrderItem newOrderItem = new OrderItem();
        newOrderItem.OrderId = newOrder.Id; 
        newOrderItem.UnitPrice = 1;
        newOrderItem.Quantity = 2;
        newOrderItem.PriceBookEntryId = newPriceBookEntry.Id;
        insert newOrderItem;
        newOrder.Status = 'Aguardando criação contrato';
        update newOrder;
        DesativarIntegracoes__c integrationSwitch = new DesativarIntegracoes__c();
        integrationSwitch.Name = 'Docusign';
        integrationSwitch.isIntegracaoAtiva__c = true;
        integrationSwitch.Mensagem__c = 'msg';
        insert integrationSwitch;
        
        Integration_Flow__c integrationFlow = new Integration_Flow__c();
        integrationFlow.AccountId__c = 'test';
        integrationFlow.TemplateId__c = 'test';
        insert integrationFlow;
        
        AccountContactRelation relation = [SELECT Id,
                                           AccountId,
                                           Contact.Name,
                                           Email__c,
                                           ResponsibleForTheSignature__c
                                           FROM AccountContactRelation
                                           WHERE AccountId =: newAccount.Id ];
        
        update relation;
        
        List<ServiceParameter__c> lstServParam = new List<ServiceParameter__c>();
        
        ServiceParameter__c serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignListRecipient';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes/{!templateId}/recipients';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000; 
        
        lstServParam.add(serviceParameter);
        
        serviceParameter = new ServiceParameter__c();
        
        serviceParameter.Name = 'CEC_PME_DocuSignDeleteRecipients';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes/{!templateId}/recipients';
        serviceParameter.Method__c = 'GET';
        serviceParameter.Timeout__c = 120.000;   
        
        lstServParam.add(serviceParameter);
        
        insert lstServParam;  
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'someTitle_Completed.pdf', 
            ContentUrl = 'someUrl',
            CEC_Tipo_de_Anexo__c = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().fields.getMap().get('CEC_Tipo_de_Anexo__c').getDescribe().getPicklistValues().get(1).getLabel()
        );
        
        insert contentVersion;
        
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocumentLink docLink = new ContentDocumentLink(
            LinkedEntityId = newOrder.Id, 
            ContentDocumentId = contentVersion.ContentDocumentId, 
            ShareType = 'V');
        insert docLink;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do cancelamento do pedido da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void cancelOrder() {
        CEC_PME_MobileButtonsController.cancelOrder(getOrderId());
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de envio ao backoffice da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void sendToBackofficeSuccess() {
        Order varOrder = getOrder();
        varOrder.Status = 'Território Associado';
        update varOrder;
        CEC_PME_MobileButtonsController.sendToBackoffice(varOrder.Id);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de envio ao backoffice da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void sendToBackofficeError() {
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.sendToBackoffice(getOrderId());
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste da aprovação do pedido da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void approveDocumentationSuccess() {
        Order varOrder = getOrder();
        varOrder.Status = 'Pré Analise da Documentação';
        update varOrder;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        CEC_PME_MobileButtonsController.approveDocumentation(varOrder.Id);
        Test.stopTest();
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de aprovação do pedido da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void approveDocumentationError() {
        Order varOrder = getOrder();
        Boolean hasError = false;
        
        try{
            CEC_PME_MobileButtonsController.approveDocumentation(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de lista opções de uma picklist da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void getPicklistOptions() {
        Order varOrder = getOrder();
        varOrder.Status = 'Pré Analise da Documentação';
        update varOrder;
        CEC_PME_MobileButtonsController.getPicklistOptions(varOrder.Id);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de lista opções de uma picklist da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void getPicklistOptionsError() {
        Boolean hasError = false;
        try {
            CEC_PME_MobileButtonsController.getPicklistOptions(getOrderId());
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de reprovação do pedido da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void disapproveDocumentation() {
        CEC_PME_MobileButtonsController.disapproveDocumentation(getOrderId(),'','');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de assinatura da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void signContractErrorStatus() {
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.signContract(getOrderId());
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de assinatura da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void signContractError() {
        Order varOrder = getOrder();
        varOrder.Status = 'Contrato criado';
        update varOrder;
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.signContract(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de atualização de território da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void updateAccountTerritory() {
        Order varOrder = getOrder();
        varOrder.Status = 'Contrato Assinado';
        update varOrder;
        Test.startTest();
        CEC_PME_MobileButtonsController.updateAccountTerritory(varOrder.Id, null);
        Test.stopTest();
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de lista territórios da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void getListTerritorysRadiosError() {
        Order varOrder = getOrder();
        varOrder.Status = 'Contrato Assinado';
        update varOrder;
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.getListTerritorysRadios(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de envio ao RPA da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void inputOrderError() {
        Order varOrder = getOrder();
        varOrder.Status = 'Documentação Aprovada';
        update varOrder;
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.inputOrder(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
      
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de envio ao RPA da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void inputOrderErrorStatus() {
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.inputOrder(getOrderId());
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de envio ao RPA da classe CEC_PME_MobileButtonsController
	*/     
    @isTest  
    public static void inputOrderErrorValidarTipoAnexo() {
        Boolean hasError = false;
        Order varOrder = getOrder();
        varOrder.Status = 'Documentação Aprovada';
        update varOrder;
        
        ContentVersion varContentVersion = [SELECT Id,
                                            CEC_Tipo_de_Anexo__c
                                            FROM ContentVersion];
        varContentVersion.CEC_Tipo_de_Anexo__c = null;
        update varContentVersion;
        
        try {
            CEC_PME_MobileButtonsController.inputOrder(varOrder.Id);
        } catch(Exception e) { 
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do erro do método de envio ao RPA da classe CEC_PME_MobileButtonsController
	*/     
    @isTest  
    public static void inputOrderErrorisInputManual() {
        Boolean hasError = false;
        Order varOrder = getOrder();
        varOrder.Status = 'Documentação Aprovada';
        update varOrder;
        
        try {
            CEC_PME_MobileButtonsController.inputOrder(varOrder.Id);
        } catch(Exception e) { 
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de criação de contrato da classe CEC_PME_MobileButtonsController
	*/      
    @isTest 
    public static void createContract() {
        Order varOrder = getOrder();
        varOrder.status = 'Aguardando criação contrato';
        update varOrder;
        Boolean hasError = false;
        try{
            Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
            CEC_PME_MobileButtonsController.createContract(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de validação de retorno da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void validateResponse() {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(getOrderId());
        Boolean hasError = false;
        try{
            controller.validateResponse('{"data":{"salesDocuments":[{"test":"test"}]}}');
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de pesquisa de assinadores da classe CEC_PME_MobileButtonsController
	*/     
	@isTest
    static void signatureContactsTest() {
        Boolean hasError = false;
        try{
            Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
            String relations = CEC_PME_MobileButtonsController.getSignatureContacts(getOrderId());            
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');       
    }    
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método de reenvio de pedido da classe CEC_PME_MobileButtonsController
	*/     
    @isTest 
    public static void resendOrderTest() {
        Order varOrder = getOrder();
        varOrder.status = 'Aguardando criação contrato';
        update varOrder;
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.reenviarPedido(varOrder.Id);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }   
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste dos métodos auxiliares da classe CEC_PME_MobileButtonsController
	*/      
	@isTest 
    static void basicMethodsTest() {
        Order ord = getOrder();
        
        Object obj = CEC_PME_MobileButtonsController.getMobileButtonsVO(ord.Id);
        
        System.assertNotEquals(null, obj, 'Tem que retornar um objeto');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método getPicklistStausQuote
	*/      
    @isTest 
    static void getPicklistStausQuote() {
        String picklistStausQuote = CEC_PME_MobileButtonsController.getPicklistStausQuote();  
        
        System.assert(String.isNotBlank(picklistStausQuote), 'Picklist Staus Quote não retornado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método setQuoteStatus
	*/      
    @isTest 
    static void setQuoteStatus() {
        String numberQuote = 'teste';
        Order varOrder = getOrder();
        varOrder.StatusQuote__c = Schema.getGlobalDescribe().get('Order').getDescribe().fields.getMap().get('StatusQuote__c').getDescribe().getPicklistValues().get(0).getLabel();
        varOrder.NumberQuote__c = numberQuote;
        
        CEC_PME_MobileButtonsController.setQuoteStatus(varOrder); 
        
        System.assert(numberQuote.equals(getOrder().NumberQuote__c), 'Pedido não atualizado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método setQuoteStatus
	*/      
    @isTest 
    static void setQuoteStatusError() {
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.setQuoteStatus(getOrder());
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método setNotInputed
	*/      
    @isTest 
    static void setNotInputed() {
        String erroMessage = 'teste';
        Order varOrder = getOrder();
        varOrder.ErroMsg__c = erroMessage;
        
        CEC_PME_MobileButtonsController.setNotInputed(varOrder);  
        
        System.assert(erroMessage.equals(getOrder().ErroMsg__c), 'Pedido não atualizado');
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do método setNotInputed
	*/      
    @isTest 
    static void setNotInputedError() {
        Boolean hasError = false;
        try{
            CEC_PME_MobileButtonsController.setNotInputed(getOrder()); 
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError, 'Erro não disparado');
    }
    
}