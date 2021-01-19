/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe CEC_PME_SalesDocumentsPayload
*/
@isTest
public class CEC_PME_SalesDocumentsPayloadTest 
{
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */       
	@testSetup
    public static void testSetup()
    {
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
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento dos campos apiVersion e transactionId
    */      
    @isTest
    public static void getApiVersionTest()
    {        
        Test.startTest();
		Order varOrder = [SELECT Id FROM ORDER LIMIT 1];
        
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        
        String apiVersion = salesDocumentsPayload.getApiVersion();
        String transactionId = salesDocumentsPayload.getTransactionId(varOrder.Id);
        System.assert(apiVersion == '');
        System.assert(transactionId != null);
        Test.stopTest();
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento dos campos do parceiro
    */     
    @isTest
    public static void getSalesPartyTest()
    {        
        User varUser = [SELECT Id, ConsultantCode__c, Name, Resale__c, CNPJResale__c, Channel__c, ResaleCode__c FROM User LIMIT 1];
        Account varAccount = [SELECT Id, CommercialSegment__c FROM Account LIMIT 1];
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        CEC_PME_SalesDocumentsRequest.SalesParty salesParty = salesDocumentsPayload.getSalesParty(varUser, varAccount.CommercialSegment__c);
        System.assert(salesParty != null);
        Test.stopTest();
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó de clientes
    */     
    @isTest
    public static void getCustomerTest()
    {
        Account varAccount = [SELECT Id, Name, StateSubscription__c, MunicipalSubscription__c, CNAE__c, CNAE2__c, DocumentNumber__c, NETClient__c, EmbratelClient__c, NumberOfEmployees, NETContractNumber__c FROM Account LIMIT 1];
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        CEC_PME_SalesDocumentsRequest.customer varCustomer = salesDocumentsPayload.getCustomer(varAccount);
        System.assert(varCustomer != null);
        Test.stopTest();
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do telefone do cliente 
    */     
    @isTest
    public static void getCustomerContactPhoneTest()
    {
        Account varAccount = [SELECT Id, Phone FROM Account LIMIT 1];
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        CEC_PME_SalesDocumentsRequest.ContactPhone customerContactPhone = salesDocumentsPayload.getCustomerContactPhone(varAccount);
        System.assert(customerContactPhone != null);
        Test.stopTest();
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do endereço do cliente
    */     
    @isTest
    public static void getAddressesTest()
    {
        Order varOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
        Account varAccount = CEC_PME_SalesDocumentsQuerys.getCustomerAccount(varOrder.AccountId);
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        List<CEC_PME_SalesDocumentsRequest.Addresses> lstAddress = salesDocumentsPayload.getAddresses(varAccount);
        List<CEC_PME_SalesDocumentsRequest.CommercialReferences> lstCommercialReference = salesDocumentsPayload.getCommercialReferences();
        CEC_PME_SalesDocumentsRequest.BillingSpec varBillingSpec = salesDocumentsPayload.getBillingSpec(varAccount);
        System.assert(lstAddress != null);
        System.assert(lstCommercialReference != null);
        System.assert(salesDocumentsPayload != null);
        Test.stopTest();
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó de administradores
    */     
    @isTest
    public static void getAdminsTest()
    {
        Order varOrder = [SELECT AccountId, Related_Contacts__c FROM ORDER LIMIT 1];
        Set<Id> setIds = CEC_PME_SalesDocumentsPayload.getRelatedContactIdList(varOrder.Related_Contacts__c);
        List<AccountContactRelation> lstAcr = CEC_PME_SalesDocumentsQuerys.getAccountRelations(setIds);

        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        List<CEC_PME_SalesDocumentsRequest.Administrators> lstAdmins = salesDocumentsPayload.getAdmins(lstAcr);
        System.assert(lstAdmins != null);
        Test.stopTest();
    } 
  
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó de equipamentos
    */     
    @isTest
    public static void getEquipRecTest()
    {
        Order ord = [SELECT Id FROM ORDER LIMIT 1];
        Order varOrder = CEC_PME_SalesDocumentsQuerys.getOrder(ord.Id);

        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers> equipReceivers = salesDocumentsPayload.getEquipReceivers(varOrder);
        System.assert(equipReceivers != null);
        Test.stopTest();
    }    
    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó planos e dos campos faixa e score
    */     
    @isTest
    public static void getPlansTest()
    {
        Order varOrder = [SELECT Id FROM ORDER LIMIT 1];
        Account varAccount = [SELECT Id, CommercialSegment__c FROM Account LIMIT 1];
        
		List<OrderItem> orderItens = CEC_PME_SalesDocumentsQuerys.getOrderItens(varOrder.Id);
        System.debug('orderItens >> '+orderItens.size());

        //Score
        Set<String> setRange = CEC_PME_SalesDocumentsPayload.getRange(orderItens);
        List<Product2> products = CEC_PME_SalesDocumentsQuerys.getRange(setRange);
        Map<String, String> mapRange = CEC_PME_SalesDocumentsPayload.getMapRange(products);          
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        List<CEC_PME_SalesDocumentsRequest.Plans> lstPlans = salesDocumentsPayload.getPlans(orderItens, mapRange, varAccount.CommercialSegment__c);
        System.assert(lstPlans != null);
        Test.stopTest();
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó de resumo
    */     
    @isTest
    public static void getSummaryTest()
    {
        Order varOrder = [SELECT Id, Payment_Term__c FROM ORDER LIMIT 1];
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        CEC_PME_SalesDocumentsRequest.Summary varSummary = salesDocumentsPayload.getSummary(varOrder.Payment_Term__c);
        System.assert(varSummary != null);
        Test.stopTest();
    }     
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no teste do preenchimento do nó subacceptances
    */     
    @isTest
    public static void getSubAccptTest()
    {
		Order varOrder = [SELECT Id, LD21__c FROM ORDER LIMIT 1];  
        
        Test.startTest();
        CEC_PME_SalesDocumentsPayload salesDocumentsPayload = new CEC_PME_SalesDocumentsPayload();
        CEC_PME_SalesDocumentsRequest.SubscriberAcceptances subAcceptance = salesDocumentsPayload.getSubAcceptances(varOrder);
        System.assert(subAcceptance != null);
        Test.stopTest();
    }   
    
    @isTest
    public static void getBonus() {
        CEC_PME_SalesDocumentsPayload playload = new CEC_PME_SalesDocumentsPayload();
		playload.buildListBonus(new OrderItem(), new Map<String, List<OrderItem>>() );
        playload.buildBonus(new Product2(), '');
        playload.getOnJSON('{"ATT_CAT_FRANQ":[{"attributeuniquecode__c":"ATT_PME_BonusValue","attribute":"value"}]}','attribute');
    }   
}