/**
 * Created by gabrysilva on 13/02/2020.
 */
@isTest
public with sharing class CEC_SalesOrder_ServiceTest {
    
    public static final CEC_Order_Repository orderRepository = new CEC_Order_Repository();

    @TestSetup
    static void testSetup(){
        Account varAccount = CEC_SobjectFactory.getAccount();
        varAccount.MothersName__c = 'Maria Silva';
        varAccount.Gender__c = 'Masculino';

        Id pricebookId = Test.getStandardPricebookId();

        insert varAccount;

        vlocity_cmt__PriceList__c vlocityPriceList = new vlocity_cmt__PriceList__c();
        vlocityPriceList.Name = 'Comercial Residencial';
        vlocityPriceList.vlocity_cmt__Code__c = 'Comercial_residencial';
        insert vlocityPriceList;

        Pricebook2 varPrice = new Pricebook2(id = pricebookId);

        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.vlocity_cmt__PriceListId__c = vlocityPriceList.Id;
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.AnaliseCredito__c = 'APROVADO';
        varOrder.Unidade__c = 'Residencial';
        varOrder.Internet_Grupo__c = 'GN';
        varOrder.Fone_Grupo__c = 'G1';
        varOrder.Cart_State__c = 'INDIVIDUAL';
        varOrder.Forma_de_Pagamento__c = 'Boleto';
        varOrder.UF__c = 'SP';
        varOrder.City__c = 'SAO PAULO';
        varOrder.BillingCity = 'SAO PAULO';
        varOrder.TV_Grupo__c = 'G1';
        varOrder.Movel_Grupo__c = 'GN';
        insert varOrder;

        Product2 varProduct = CEC_SobjectFactory.getProduct();
        varProduct.vlocity_cmt__SubType__c = 'Pós-Plano';
        varProduct.vlocity_cmt__Type__c = 'Plano';
        varProduct.Family = 'Internet Fixa';
        varProduct.TemplateOrderId__c = varOrder.Id;
        varProduct.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        insert varProduct;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        system.debug('hh varEntry'+varEntry);
        insert varEntry;
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.vlocity_cmt__Product2Id__c = varItem.Product2Id;
        varItem.vlocity_cmt__AssetReferenceId__c = varItem.Product2Id;
        varItem.Promotion_Log__c = '{\"isPromotion\":true,\"Id\":\"a4n0U0000002TnDQAU\",\"Cart_State__c\":\"INDIVIDUAL\",\"Group__c\":\"G1\",\"Product_Code__c\":\"COM_INT_RES_120MB_000001\",\"Active__c\":true,\"Description__c\":\"Valor Promocional R$119,99 após 3 meses  R$139,99\",\"Promotion__c\":\"R$ 119,99 por 3 meses\",\"Name\":\"000315\",\"PricingValue__c\":119.99,\"RecordTypeId\":\"0120U0000004XMDQA2\"}';
        varItem.DescricaoPromocao__c = 'Testing Promo';
        varItem.vlocity_cmt__LineNumber__c = '0001';
        varItem.Group__c = 'GN';
        varItem.DDD__c = '11';
        insert varItem;
        
        Legacy_Offer__c legacyOffer = new Legacy_Offer__c();
        legacyOffer.Name = 'Dependente Comp Total - Combo';
        legacyOffer.Active__c = true;
        legacyOffer.Billing_Offer_Name__c = 'Dependente Comp Total - Combo';
        legacyOffer.Billing_Offer_Code__c = '414349065';
        insert legacyOffer;

        vlocity_cmt__DecompositionRelationship__c decomposition = new vlocity_cmt__DecompositionRelationship__c();
        decomposition.Type__c = 'Promoção';
        decomposition.Name = 'Claro Controle App 5GB + Minutos Ilimitados';
        decomposition.Legacy_Offer__c = legacyOffer.id;
        decomposition.vlocity_cmt__SourceProductId__c = varProduct.id;
        insert decomposition;
        
        insert new List<ServiceParameter__c>{new ServiceParameter__c(Name = 'CEC_Products', EndPoint__c = 'http://200.169.123.170:9000/corp/products', Method__c = 'POST'),
            new ServiceParameter__c(Name = 'TelephoneNumberReservation', EndPoint__c = 'http://200.169.123.170:9000/corp/telephonenumbers/reservations', Method__c = 'POST'),
            new ServiceParameter__c(Name = 'SalesOrdersMobile', EndPoint__c = 'http://200.169.123.170:9000/corp/salesorders/mobile', Method__c = 'POST'),
            new ServiceParameter__c(name = 'PreAnalysisPortability', EndPoint__c = 'PreAnalysisPortability', Method__c = 'POST'),
            new ServiceParameter__c(name = 'Interactions', EndPoint__c = 'Interactions', Method__c = 'POST')
            };
        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        database.insert(lIbge);
    }

    @isTest
    static void generateSalesOrderTest() {
        Boolean hasError = false;
        try{
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new SalesOrderMock());
            Order varOrder = [Select id, Unidade__c, Cart_State__c FROM Order LIMIT 1];
            system.debug('varOrder: ' + varOrder);
            executesOrderMobile( varOrder.Id );
            test.stopTest();
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError);
       	test.stopTest();    
    }
    
    @isTest
    static void executeProductsIntegrationTest() {
        test.startTest();
        Boolean hasError = false;
        try{
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock());
         Account varAccount = CEC_SobjectFactory.getAccount();
        varAccount.MothersName__c = 'Maria Silva';
        varAccount.Gender__c = 'Masculino';

        Id pricebookId = Test.getStandardPricebookId();

        insert varAccount;

        vlocity_cmt__PriceList__c vlocityPriceList = new vlocity_cmt__PriceList__c();
        vlocityPriceList.Name = 'Comercial Residencial1';
        vlocityPriceList.vlocity_cmt__Code__c = 'Comercial_residencial1';
        insert vlocityPriceList;

        Pricebook2 varPrice = new Pricebook2(id = pricebookId);

        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.vlocity_cmt__PriceListId__c = vlocityPriceList.Id;
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.AnaliseCredito__c = 'APROVADO';
        varOrder.Unidade__c = 'Residencial';
        varOrder.Internet_Grupo__c = 'GN';
        varOrder.Fone_Grupo__c = 'G1';
        varOrder.Cart_State__c = 'INDIVIDUAL';
        varOrder.Forma_de_Pagamento__c = 'Boleto';
        varOrder.UF__c = 'SP';
        varOrder.City__c = 'SAO PAULO';
        varOrder.BillingCity = 'SAO PAULO';
        varOrder.TV_Grupo__c = 'G1';
        varOrder.Movel_Grupo__c = 'GN';
        insert varOrder;

        Product2 varProduct1 = CEC_SobjectFactory.getProduct();
        varProduct1.ProductCode='123';
        varProduct1.vlocity_cmt__SubType__c = 'Pós-Plano';
        varProduct1.vlocity_cmt__Type__c = 'Dependente';
        varProduct1.Family = 'Internet Fixa';
        varProduct1.TemplateOrderId__c = varOrder.Id;
        varProduct1.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        insert varProduct1;
        
        PricebookEntry varEntry1 = CEC_SobjectFactory.getPricebookEntry(varProduct1, varPrice);
        varEntry1.UnitPrice = 1;
        insert varEntry1;

        OrderItem varItem1 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry1);
        varItem1.vlocity_cmt__Product2Id__c = varItem1.Product2Id;
        varItem1.vlocity_cmt__AssetReferenceId__c = varItem1.Product2Id;
        varItem1.Promotion_Log__c = '{\"isPromotion\":true,\"Id\":\"a4n0U0000002TnDQAU\",\"Cart_State__c\":\"INDIVIDUAL\",\"Group__c\":\"G1\",\"Product_Code__c\":\"COM_INT_RES_120MB_000001\",\"Active__c\":true,\"Description__c\":\"Valor Promocional R$119,99 após 3 meses  R$139,99\",\"Promotion__c\":\"R$ 119,99 por 3 meses\",\"Name\":\"000315\",\"PricingValue__c\":119.99,\"RecordTypeId\":\"0120U0000004XMDQA2\"}';
        varItem1.DescricaoPromocao__c = 'Testing Promo';
        varItem1.vlocity_cmt__LineNumber__c = '0001';
        varItem1.Group__c = 'GN';
        varItem1.DDD__c = '11';
        insert varItem1;

        Legacy_Offer__c legacyOffer = new Legacy_Offer__c();
        legacyOffer.Name = 'Dependente Comp Total - Combo';
        legacyOffer.Active__c = true;
        legacyOffer.Billing_Offer_Name__c = 'Dependente Comp Total - Combo';
        legacyOffer.Billing_Offer_Code__c = '414349065';
        insert legacyOffer;

        vlocity_cmt__DecompositionRelationship__c decomposition = new vlocity_cmt__DecompositionRelationship__c();
        decomposition.Type__c = 'Promoção';
        decomposition.Name = 'Claro Controle App 5GB + Minutos Ilimitados';
        decomposition.Legacy_Offer__c = legacyOffer.id;
        decomposition.vlocity_cmt__SourceProductId__c = varProduct1.id;
        insert decomposition;
        
        CEC_SalesOrder_Service service = new CEC_SalesOrder_Service();
        Order order = CEC_SalesOrder_ServiceTest.orderRepository.getOrderById(varOrder.Id);
        service.executeProductsIntegration(order);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError);
       	test.stopTest();
    }
     
    static void executesOrderMobile( Id orderId ){
        CEC_SalesOrder_Service service = new CEC_SalesOrder_Service();
            Map<String, Object> inputMap = new Map<String,Object>();
            inputMap.put('CreditAnalysis' ,JSON.deserializeUntyped('{"data":{"creditSituation":{"creditLimit":"3000.0","dataPolicy":null,"messages":[{"identifier":"0","note":"PRÉ-APROVADO - Limite: 3000.0"}],"policy":null,"reportZ":null,"resultDate":"2019-12-30T16:45:19.768-02:00","status":"Aprovar","typeDecision":null}},"apiVersion":"1;2019-14-01","error":null,"transactionId":"Id-bc450a5e6fbc0d18ade5d178"}'));
            inputMap.put('SalesMan' ,JSON.deserializeUntyped('{"data":{"salesman":{"contact":[{"emailAddress":"aaserf@gmail.com","telephoneNumber":"null","telephoneNumbertype":"CELULAR"}],"id":"CA4K2","marketArea":[{"market":{"numeration":[{"ddd":"11"},{"ddd":"12"},{"ddd":"13"},{"ddd":"14"},{"ddd":"15"},{"ddd":"16"},{"ddd":"17"},{"ddd":"18"},{"ddd":"19"},{"ddd":"21"},{"ddd":"22"},{"ddd":"24"},{"ddd":"27"},{"ddd":"28"},{"ddd":"31"},{"ddd":"32"},{"ddd":"33"},{"ddd":"34"},{"ddd":"35"},{"ddd":"37"},{"ddd":"38"},{"ddd":"41"},{"ddd":"42"},{"ddd":"43"},{"ddd":"44"},{"ddd":"45"},{"ddd":"46"},{"ddd":"47"},{"ddd":"48"},{"ddd":"49"},{"ddd":"51"},{"ddd":"53"},{"ddd":"54"},{"ddd":"55"},{"ddd":"61"},{"ddd":"62"},{"ddd":"63"},{"ddd":"64"},{"ddd":"65"},{"ddd":"66"},{"ddd":"67"},{"ddd":"68"},{"ddd":"69"},{"ddd":"71"},{"ddd":"73"},{"ddd":"74"},{"ddd":"75"},{"ddd":"77"},{"ddd":"79"},{"ddd":"81"},{"ddd":"82"},{"ddd":"83"},{"ddd":"84"},{"ddd":"85"},{"ddd":"86"},{"ddd":"87"},{"ddd":"88"},{"ddd":"89"},{"ddd":"91"},{"ddd":"92"},{"ddd":"93"},{"ddd":"94"},{"ddd":"95"},{"ddd":"96"},{"ddd":"97"},{"ddd":"98"},{"ddd":"99"}]}}],"name":"SARA SILVA SIMOES","partyidentification":{"numberZ":"00000000000","type":"CPF"},"registration":"CA4K2   ","salesAgent":{"address":{"boxNr":"0","city":"SAO PAULO","neighborhood":"AGUA BRANCA","placeId":"SP","postalCode":"05037150","streetName":"HENRIQUE ONGARI","streetNumber":"100","streetType":"N/D","type":null,"urbanPropertySubAddress":"null"},"businessName":"EZCONET","channelId":"AA_TELEVENDAS","description":"Televendas","iwRegionalId":"CLARO_SP1","iwSalesAgentId":"B880","iwTypeId":"20","pointSale":[],"regionalId":"CLARO_SP1"},"situation":"ATIVO","situationDate":"2013-10-25T00:00:00.000-02:00","user":{"description":"Vendedor Vrj Nac. + AA","profiles":null,"roleId":"355","userId":"CA4K2   "}}},"apiVersion":"1;2019-02-22","error":null,"transactionId":"Id-cc330a5e87ac23f2f8c1e559"}'));
            inputMap.put('OrderId', orderId);
    
            String PortabilityPreAnalysisObj = Json.serialize(inputMap.get('PorPreAnalysis'));
            PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis analysisDTO =
                    (PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis) System.JSON.deserialize(PortabilityPreAnalysisObj, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis.class);
    
            String CreditAnalysisObj = Json.serialize(inputMap.get('CreditAnalysis'));
            IntegrationCreditAnalysisMobileDTO.CredAnalysisResp creditAnalysisMobileDTO =
                    (IntegrationCreditAnalysisMobileDTO.CredAnalysisResp) System.JSON.deserialize(CreditAnalysisObj, IntegrationCreditAnalysisMobileDTO.CredAnalysisResp.class);
    
            String SalesManObj = Json.serialize(inputMap.get('SalesMan'));
            SalesManDTO.SalesMan salesManDTO = (SalesManDTO.SalesMan) System.JSON.deserialize(SalesManObj, SalesManDTO.SalesMan.class);
    
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp cred = (new IntegrationCreditAnalysisMobileDTO())
                    .CredAnalysisResp2CredAnalisysMobileResp(creditAnalysisMobileDTO);
    
            SalesOrderIntegrationDTO.SalesOrderMobileResponse retorno = service.executesOrderMobile( (String) orderId );
            system.debug( 'Retorno: ' + retorno );
    
            SalesOrderIntegrationDTO.SalesOrderMobileResponse retorno2 = service.executesOrderMobile(
                    (String) orderId, salesManDTO.data.salesman, cred, analysisDTO);
            system.debug( 'Retorno2: ' + retorno2 );
		
    }

    public class SalesOrderMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            system.debug('request ' + request);
            if(request.getEndpoint() != null && request.getEndpoint().contains('/products')){
                Object obj = JSON.deserializeUntyped('{"apiVersion":"1;2019-08-20","transactionId":"Id-211f0e5e5834e4625df68823","data":{"product":{"type":null,"subType":null,"sharedProductIndicator":"false","offer":{"id":null,"name":null,"price":null},"customer":{"customerAcceptances":{"flagAcceptMarketingMessages":null}},"promotion":{"id":"414403033","name":"Sinalização fidelidade 240","description":null,"discount":"0.0","expirationDate":null,"category":{"id":null},"offer":{"id":"414403033"}},"services":[{"id":"380465365","name":"Claro Conta 3G","contractedService":"true","category":{"id":"63","name":"Pacote Teste Noites em Claro 20G","description":null,"priority":null,"loyalty":{"flagValidity":null}}}],"productOffering":{"type":null,"id":"16442","name":"Claro Controle App 4GB + Minutos Ilimitados + SVA","nickname":null,"description":null,"startDate":null,"expirationDate":null,"price":"64.99","limitAmount":null,"services":[]}}}}');
                res.setBody(JSON.serialize(obj));
            }else if(request.getEndpoint() != null && request.getEndpoint().contains('/telephonenumbers/reservations')){
                Object obj = JSON.deserializeUntyped('{"transactionId":"Id-a3560e5edb526df08ffd937f","error":null,"apiVersion":"1;2019-08-20","data":{"telephoneNumbers":[{"number_z":"11945297497"}]}}');
                res.setBody(JSON.serialize(obj));
            }
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void checkProductsTest() {
        Boolean hasError = false;
        try{
       	test.startTest();
       	ProductsIntegrationDTO.ProductsResponses response = new ProductsIntegrationDTO.ProductsResponses();
        List<ProductsIntegrationDTO.ProductsResponses> responses = new List<ProductsIntegrationDTO.ProductsResponses>();
        response.data = new ProductsIntegrationDTO.ProductsResponse();
        response.data.product = new ProductsIntegrationDTO.Product();
        response.data.product.productOffering = null;
        responses.add(response);
        
       	CEC_SalesOrder_Service salesService = new CEC_SalesOrder_Service();
       	salesService.checkProducts(responses);
        } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError);
       	test.stopTest();
    }
    
    @isTest
    public static void mainTest() {
        CEC_SalesOrder_Service.setError(new Map<String, Object>(),' aMsg');
        new SalesOrderIntegrationDTO.OrderResponse('id', 'interaction');
        new SalesOrderIntegrationDTO.OrderResponse('id', new List<SalesOrderIntegrationDTO.Interaction>());
        new SalesOrderIntegrationDTO.Type_Z();
        new SalesOrderIntegrationDTO.CreditLimitAnalysis('limitExceeded','limitValueExceeded','limitPercentExceeded');
        new SalesOrderIntegrationDTO.Customer();
        new SalesOrderIntegrationDTO.Customer('mobileId', null, null, null,
                                              new SalesOrderIntegrationDTO.Contacts(), new List<SalesOrderIntegrationDTO.Addresses>(), new SalesOrderIntegrationDTO.Individual());
        new SalesOrderIntegrationDTO.ItemTablePrice_Z();
        new SalesOrderIntegrationDTO.ItemTablePrice_Z(null);
        new SalesOrderIntegrationDTO.Result(null, null, null);
        new SalesOrderIntegrationDTO.Result();
        new SalesOrderIntegrationDTO.Addresses();
        new SalesOrderIntegrationDTO.ItemPaymentMixed();
        new SalesOrderIntegrationDTO.ItemPaymentMixed('sequenceNr', null);
        new SalesOrderIntegrationDTO.ProductOffering_Z();
        new SalesOrderIntegrationDTO.ProductOffering_Z(null, null);
        new SalesOrderIntegrationDTO.User_Z();
        new SalesOrderIntegrationDTO.User_Z(null, null);
        new SalesOrderIntegrationDTO.User_Z(null, null, null);
        new SalesOrderIntegrationDTO.User_x();
        new SalesOrderIntegrationDTO.User_x(null, null);
        new SalesOrderIntegrationDTO.CustomerAcceptances();
        new SalesOrderIntegrationDTO.Manufacturer();
        new SalesOrderIntegrationDTO.Manufacturer(null, null, null);
        new SalesOrderIntegrationDTO.Status_Z();
        new SalesOrderIntegrationDTO.Tickets();
        new SalesOrderIntegrationDTO.Tickets(null, null);
        new SalesOrderIntegrationDTO.Items();
        new SalesOrderIntegrationDTO.PointsOfSale();
        new SalesOrderIntegrationDTO.PointsOfSale(null, null) ;
        new SalesOrderIntegrationDTO.Status();
        new SalesOrderIntegrationDTO.Status(null, null, null, null, null);
        new SalesOrderIntegrationDTO.Salesman();
        new SalesOrderIntegrationDTO.Order_z(null, null,null,null,
                                             null, null, null, null,
                                             null, null, null, null,
                                             null, null, null, null, null,
                                             null, null);
        new SalesOrderIntegrationDTO.DigitalInvoice();
        new SalesOrderIntegrationDTO.Interaction();
        new SalesOrderIntegrationDTO.Interaction(null, null, null);
        new SalesOrderIntegrationDTO.ConsolidatedData();
        new SalesOrderIntegrationDTO.CreditAnalysis();
        new SalesOrderIntegrationDTO.Portability(null);
        new SalesOrderIntegrationDTO.CreditAnalysis(null, null, null,
                       null, null, null,
                       null);
        new SalesOrderIntegrationDTO.Availables();
        new SalesOrderIntegrationDTO.Availables(null, null, null,
                                                null);
        new SalesOrderIntegrationDTO.BankingAccount(null, null, null);
        new SalesOrderIntegrationDTO.Payment();
        new SalesOrderIntegrationDTO.Payment(null);
        new SalesOrderIntegrationDTO.AddressAnalysis();
        new SalesOrderIntegrationDTO.AddressAnalysis(null, null);
        new SalesOrderIntegrationDTO.Campaign();
        new SalesOrderIntegrationDTO.Campaign(null, null, null, null, null,
                                              null);
        new SalesOrderIntegrationDTO.Correlations();
        new SalesOrderIntegrationDTO.Individual(null, null, null, null, null,
                null, null);
            new SalesOrderIntegrationDTO.PaymentPlan();
            new SalesOrderIntegrationDTO.PaymentPlan(null, null, null,
                null, null);
            new SalesOrderIntegrationDTO.GracePeriod();
            new SalesOrderIntegrationDTO.GracePeriod(null, null,null, null);
            new SalesOrderIntegrationDTO.ApplicationOperation();
            new SalesOrderIntegrationDTO.ApplicationOperation(null, null);
            new SalesOrderIntegrationDTO.Penalty();
            new SalesOrderIntegrationDTO.Penalty(null,null, null, null);
            new SalesOrderIntegrationDTO.Loyalty() ;
            new SalesOrderIntegrationDTO.Loyalty(null,null,null);
            new SalesOrderIntegrationDTO.SubCampaign() ;
            new SalesOrderIntegrationDTO.SubCampaign(null);
            new SalesOrderIntegrationDTO.SubCampaign(null, null, null);
            new SalesOrderIntegrationDTO.Application();
            new SalesOrderIntegrationDTO.Application(null, null, null,null,
                null, null, null, null);
            new SalesOrderIntegrationDTO.Session(null, null, null);
            new SalesOrderIntegrationDTO.Session();
            new SalesOrderIntegrationDTO.PaymentPlanAuthorized();
            new SalesOrderIntegrationDTO.PaymentPlanAuthorized(null, null);
            new SalesOrderIntegrationDTO.Authority();
            new SalesOrderIntegrationDTO.Authority(null);
            new SalesOrderIntegrationDTO.Operation_Z();
            new SalesOrderIntegrationDTO.Operation_Z(null, null, null);
            new SalesOrderIntegrationDTO.Operation();
            new SalesOrderIntegrationDTO.TelephoneNumberResource(null);
            new SalesOrderIntegrationDTO.ItemTablePrice();
            new SalesOrderIntegrationDTO.ItemTablePrice(null, null);
            new SalesOrderIntegrationDTO.Promotion();
            new SalesOrderIntegrationDTO.EquipmentPaymentPlan();
            new SalesOrderIntegrationDTO.EquipmentPaymentPlan(null, null, null, null,
                null, null, null,
                null, null);
            new SalesOrderIntegrationDTO.Reason(null, null);
            new SalesOrderIntegrationDTO.Profile_z();
            new SalesOrderIntegrationDTO.MarketSegments();
            new SalesOrderIntegrationDTO.Equimpment();
            new SalesOrderIntegrationDTO.Equimpment(null);
        new SalesOrderIntegrationDTO.Employment();
            new SalesOrderIntegrationDTO.BillingAccount();
            new SalesOrderIntegrationDTO.Tickets_Z();
            new SalesOrderIntegrationDTO.Tickets_Z(null);
            new SalesOrderIntegrationDTO.PartyIdentifications();
            new SalesOrderIntegrationDTO.Window(null, null);
            new SalesOrderIntegrationDTO.Installment(null, null, null);
            new SalesOrderIntegrationDTO.Installment();
            new SalesOrderIntegrationDTO.ProductBundle();
            new SalesOrderIntegrationDTO.ProductBundle(null, null, null, null, null,
                null); 
            new SalesOrderIntegrationDTO.Service();
             new SalesOrderIntegrationDTO.SalesAgent();
            new SalesOrderIntegrationDTO.FiscalProfile();
            new SalesOrderIntegrationDTO.ProductSpecification();
            new SalesOrderIntegrationDTO.ProductSpecification(null, null, null, null,
                null);
            new SalesOrderIntegrationDTO.Unavailables();
            new SalesOrderIntegrationDTO.Contacts(null, null, null);
            new SalesOrderIntegrationDTO.Equipment(null, null, null, null, null, null,
                null, null, null);
            new SalesOrderIntegrationDTO.Equipment();
            new SalesOrderIntegrationDTO.Portability_Z(null);
            new SalesOrderIntegrationDTO.Portability_Z();
            new SalesOrderIntegrationDTO.ProductOffering();
            new SalesOrderIntegrationDTO.Model();
            new SalesOrderIntegrationDTO.Model(null, null, null);
            new SalesOrderIntegrationDTO.Contract();
            new SalesOrderIntegrationDTO.Contract(null, null,null);
             new SalesOrderIntegrationDTO.MobileSubType(null);
            new SalesOrderIntegrationDTO.MobileType(null);
            new SalesOrderIntegrationDTO.Passport(null);
            new SalesOrderIntegrationDTO.TargetProduct();
            
    }

}