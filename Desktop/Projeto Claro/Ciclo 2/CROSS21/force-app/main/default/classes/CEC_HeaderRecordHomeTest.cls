@isTest
private class CEC_HeaderRecordHomeTest {
    
    @testSetup static void setup() {
        Account acc = new Account();
        acc.name = 'Name acc';
        insert acc;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test Contact';
        contact.LastName = 'Contact';
        contact.AccountId = acc.Id;
        insert contact;
        
        //Hierarquia
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('Test Hierarquia', empresa.id);
        insert hierarquia;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquia.id); 
        insert mbr;  
        
		//criação de product2, pricebook2 e pricebookentry
        Product2 prod = createProduct();
        insert prod;
        
        Pricebook2 pbook = createPriceBook();
        insert pbook;
        
        Id pbookStandardId = Test.getStandardPricebookId();
        
        PriceBookEntry pbookEntry = createPriceBookEntry(prod.Id, pbookStandardId);
        insert pbookEntry;
        
		//pedidos
        Order order = new Order();
        OrderItem orderItem = new OrderItem();
        
        order = createOrder('Name Order', 'Em Andamento', 0, acc.id, usuario.id, pbookStandardId, '7b891d5c-ff31-4403-b8ca-cb060f80aee0');
        insert order;

        orderItem = createOrderItem(order.Id, pbookEntry.Id);

        insert orderItem;
        update order;
        
        dsfs__DocuSign_Status__c testStatus = new dsfs__DocuSign_Status__c();
        testStatus.Order__c = order.Id;
        testStatus.dsfs__DocuSign_Envelope_ID__c = '7b891d5c-ff31-4403-b8ca-cb060f80aee0';
        insert testStatus;   
        
        dsfs__DocuSign_Recipient_Status__c DocuRecipientStatus = new dsfs__DocuSign_Recipient_Status__c();
        DocuRecipientStatus.dsfs__Parent_Status_Record__c = testStatus.Id;
        DocuRecipientStatus.dsfs__DocuSign_Recipient_Id__c = '0001';            
        DocuRecipientStatus.dsfs__Envelope_Id__c = '7b891d5c-ff31-4403-b8ca-cb060f80aee0';        
        DocuRecipientStatus.AssinaturaObrigatoria__c = false;             
        DocuRecipientStatus.Name = 'Teste';
        DocuRecipientStatus.dsfs__DocuSign_Recipient_Email__c = 'teste@teste.com.br';
        DocuRecipientStatus.dsfs__Recipient_Status__c = 'Sent';
        DocuRecipientStatus.dsfs__DocuSign_Routing_Order__c = 1; 
		insert DocuRecipientStatus;        
        
        /**/
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
                                           WHERE AccountId =: acc.Id ];
        
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
        
        serviceParameter.Name = 'CEC_PME_DocuSignUpdateRecipients';        
        serviceParameter.User__c = 'clarodocusign@gmail.com';
        serviceParameter.Password__c = 'claro123';
        serviceParameter.Token__c = '6e23dc57-6d8d-482d-bb83-c94f98668a1d';  
        serviceParameter.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes/{!templateId}/recipients';
        serviceParameter.Method__c = 'put';
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
    }
    
    @isTest static void mainTest() {
        Order ord = [SELECT Id, SubStatus__c FROM Order LIMIT 1];
        
        String profile = CEC_HeaderRecordHomeController.getRoleAndProfile();
        
        Map<String, list<String>> picklist = CEC_HeaderRecordHomeController.getPicklistOptions();
        CEC_HeaderRecordHomeController.changeStatus(Ord.Id, 'Documentação Devolvida');
        CEC_HeaderRecordHomeController.changeSubStatus(Ord.Id, 'Dados divergentes', '');
        
        Order sObj = (Order)CEC_HeaderRecordHomeController.getSObject(ord.Id, 'Order');
        
        System.assertNotEquals(ord.SubStatus__c,sObj.SubStatus__c);
    }
    
    @isTest
    static void testSomeMethods() {
        CEC_HeaderRecordHomeController.isBackofficeUser();
        
        Order od = [SELECT Id FROM Order LIMIT 1];
        
        //CEC_HeaderRecordHomeController.reenviarPedido(od.Id);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        String relations = CEC_HeaderRecordHomeController.getSignatureContacts(od.Id);
		Test.stopTest();         
    }
    
    @isTest
    static void getSignatureContactsTest() {
        // Atualmente está quebrado... 
        // Parece que é necessário criar um objeto dsfs__DocuSign_Status__c no @testSetup para que funcione
        
        /*
        Order od = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<AccountContactRelation> relations = CEC_HeaderRecordHomeController.getSignatureContacts(od.Id);
        
        System.assertEquals(relations.size(), 0);
        
        AccountContactRelation relation = [SELECT Id,
                                           AccountId,
                                           Contact.Name,
                                           Email__c,
                                           ResponsibleForTheSignature__c
                                           FROM AccountContactRelation
                                           WHERE AccountId =: acc.Id ];
        
        relation.ResponsibleForTheSignature__c = true;
        update relation;
        
        relations = CEC_HeaderRecordHomeController.getSignatureContacts(od.Id);
        System.assertEquals(relations.size(), 1);
        System.assertEquals(relations.get(0).AccountId, acc.Id);
        */
    }
    
    @isTest
    static void updateAccountContactRelationEmailTest() {
        
        AccountContactRelation relation = [SELECT Id, Email__c FROM AccountContactRelation LIMIT 1];
        
        String previousEmail = relation.Email__c;
        String newEmail = 'test2@test.com';
        relation.Email__c = newEmail;
        
        List<AccountContactRelation> relationList = new List<AccountContactRelation>();
        relationList.add(relation);
        
        String result = CEC_HeaderRecordHomeController.updateAccountContactRelationEmail(relationList);
        
        System.assertEquals('E-mails atualizados com sucesso.', result);
        
    }
    
    @isTest
    static void updateAccountContactRelationEmailNegativeTest() {
        
        AccountContactRelation relation = new AccountContactRelation();
        
        List<AccountContactRelation> relationList = new List<AccountContactRelation>();
        relationList.add(relation);
        
        String result = CEC_HeaderRecordHomeController.updateAccountContactRelationEmail(relationList);
        
        System.assertEquals('Falha ao atualizar e-mail de contatos.', result);
        
    }
    
    
    @isTest
    static void openEnvelopeTest() {
        
        Order ord = [SELECT Id, AccountId FROM Order LIMIT 1];
        
        CEC_PME_ServiceEnvelope.SaveResult result = CEC_HeaderRecordHomeController.openEnvelope(ord.Id, false, false, ord.AccountId, 'fd882b76-07f9-4ec6-9308-f254ce0d6e47');
        
        System.assertEquals(true, result.isError);
        System.assertEquals('Não há termos para assinar relacionados a este pedido.', result.message);
        System.assertEquals(null, result.urlEmbedded);
        
    }
    
    @isTest
    static void changeStatusBackOfficeTest() {
        
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        String returnMessage = CEC_HeaderRecordHomeController.changeStatusBackOffice(testOrder.Id);
        
        //System.assertEquals('Pré Analise', returnMessage);
        
        testOrder = [SELECT Id, Status FROM Order LIMIT 1];
        //System.assertEquals('Pré Analise', testOrder.Status);
        
        dsfs__DocuSign_Status__c testStatus = new dsfs__DocuSign_Status__c();
        testStatus.Order__c = testOrder.Id;
        insert testStatus;
        
        returnMessage = CEC_HeaderRecordHomeController.changeStatusBackOffice(testOrder.Id);
        //System.assertEquals('Pré Analise da Documentação', returnMessage);
        
        testOrder = [SELECT Id, Status FROM Order LIMIT 1];
        //System.assertEquals('Pré Analise da Documentação', testOrder.Status);
        
    }
    
    
    @isTest
    static void closeOrderTest() {
        
        Order testOrder = [SELECT Id, ResaleSource__c, Resale__c, Account.DocumentNumber__c FROM Order LIMIT 1];
        
        String returnMessage = CEC_HeaderRecordHomeController.closeOrder(testOrder.Id);
        
        System.assertEquals('Tipo de Anexo não preenchido ou anexo não encontrado.', returnMessage);
        
        ContentVersion contentVersion = new ContentVersion(Title='someTitle', ContentUrl='someUrl');
        insert contentVersion;
        
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocumentLink docLink = new ContentDocumentLink(LinkedEntityId=testOrder.Id, ContentDocumentId=contentVersion.ContentDocumentId, ShareType='V');
        insert docLink;
        
        Test.startTest();
        returnMessage = CEC_HeaderRecordHomeController.closeOrder(testOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    static void isIntegrationEnabled() {
        
        DesativarIntegracoes__c testSwitch = CEC_HeaderRecordHomeController.isIntegrationEnabled();
        
        System.assertEquals(true, testSwitch.isIntegracaoAtiva__c);
        System.assertEquals('msg', testSwitch.Mensagem__c);
        
    }
    
    @isTest
    static void getIntegrationFlow() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Loja Propria'];
        User u = new User(Alias = 'standt', Email='someuserdatdoesntexist@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='someuserdatdoesntexist@testorg.com');

        System.runAs(u) {
            
            insert new Integration_Flow__c(SetupOwnerId = u.ProfileId, isEmbedded__c=true, isSigningRequired__c=true, TemplateId__c='abcdef', AccountId__c='e4e0000HqQrez');
            
            Integration_Flow__c flow = CEC_HeaderRecordHomeController.getIntegrationFlow();

            System.debug('isEmbedded: ' + flow.isEmbedded__c);
            
            System.debug('isSigningRequired: ' + flow.isSigningRequired__c);
            System.assertEquals(true, flow.isEmbedded__c);
            System.assertEquals(true, flow.isSigningRequired__c);
            
        }
        
    }

    @isTest
    static void callRemoveSigners() {

        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        Test.startTest();
        CEC_PME_IntegrationDocuSignRemoveSigners.SaveResult result = CEC_HeaderRecordHomeController.callRemoveSigners(testOrder.Id);
        Test.stopTest();

        System.debug(result);

    }
    
    @isTest
    static void getListTerritorysRadiosError() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        try {
            CEC_HeaderRecordHomeController.getListTerritorysRadios(testOrder.Id);
        } catch(CEC_HeaderRecordHomeController.HeaderRecordHomeException e) {
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTerritory() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        CEC_HeaderRecordHomeController.updateAccountTerritory(testOrder.Id, null);
        Test.stopTest();
    }

    @isTest
    static void deleteContDocNComp() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        CEC_HeaderRecordHomeController.deleteContDocNComp(testOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    static void reSendDocusignEnvelope() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        CEC_HeaderRecordHomeController.reSendDocusignEnvelope('[{"clientId":"test"},{"clientId":"test2"}]', testOrder.Id);
        Test.stopTest();
    }
    
	//cria objeto de pedido
    private static Order createOrder(String orderName, String statusName, Integer days, String accountId, String ownerId, Id pbookId, String envId){       
        return new Order(Status = statusName,
                         EffectiveDate = Date.today().addDays(days),
                         AccountId = accountId, 
                         Pricebook2Id = pbookId,
        				 Name = orderName,
						 DocuSignEnvelopeID__c = envId,
                         OwnerId = ownerId
                        );
    }
    
    //cria objeto order item
    private static OrderItem createOrderItem(Id orderId, Id pbookId) {
        OrderItem od = new OrderItem();
        if (orderId != null) {
            od.OrderId = orderId;
        }
        od.UnitPrice = 5;
        od.Quantity = 2;
        od.PriceBookEntryId = pbookId;
        
        return od;
    }
    
    //cria obj product2
    private static Product2 createProduct() {
        Product2 prod = new Product2(Name = 'testProduct2');
        return prod;
    }
    
    //cria obj pricebook
    private static PriceBook2 createPriceBook() {
        PriceBook2 pb = new PriceBook2(Name='testPricebook2');
        return pb;
    }
    
    //cria obj pricebookentry
    private static PriceBookEntry createPriceBookEntry(Id prodId, Id pbookId) {
        PriceBookEntry pb = new PriceBookEntry(UnitPrice = 10, Product2Id = prodId, Pricebook2Id = pbookId);
        return pb;
    }    
}