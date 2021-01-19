@isTest
public class CEC_SalesOrder_ControllerTest{

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
        //varPrice.Name = 'Teste Pricebook';
        //insert varPrice;
       
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

        insert new ServiceParameter__c(Name = 'CEC_Products', EndPoint__c = 'http://200.169.123.170:9000/corp/products', Method__c = 'POST');
        insert new ServiceParameter__c(Name = 'TelephoneNumberReservation', EndPoint__c = 'http://200.169.123.170:9000/corp/telephonenumbers/reservations', Method__c = 'POST');
        insert new ServiceParameter__c(Name = 'SalesOrdersMobile', EndPoint__c = 'http://200.169.123.170:9000/corp/salesorders/mobile', Method__c = 'POST');

        IBGE__c lIbge = new IBGE__c(UF__c = 'SP', CityName__c = 'SAO PAULO', OperatorCode__c = 3, IBGECode__c = '1');
        database.insert(lIbge);
       
    }

    @isTest
    static void generateSalesOrderTest() {
        test.startTest();
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap.put('CreditAnalysis' ,JSON.deserializeUntyped('{"data":{"creditSituation":{"creditLimit":"3000.0","dataPolicy":null,"messages":[{"identifier":"0","note":"PRÉ-APROVADO - Limite: 3000.0"}],"policy":null,"reportZ":null,"resultDate":"2019-12-30T16:45:19.768-02:00","status":"Aprovar","typeDecision":null}},"apiVersion":"1;2019-14-01","error":null,"transactionId":"Id-bc450a5e6fbc0d18ade5d178"}'));
        inputMap.put('SalesMan' ,JSON.deserializeUntyped('{"data":{"salesman":{"contact":[{"emailAddress":"aaserf@gmail.com","telephoneNumber":"null","telephoneNumbertype":"CELULAR"}],"id":"CA4K2","marketArea":[{"market":{"numeration":[{"ddd":"11"},{"ddd":"12"},{"ddd":"13"},{"ddd":"14"},{"ddd":"15"},{"ddd":"16"},{"ddd":"17"},{"ddd":"18"},{"ddd":"19"},{"ddd":"21"},{"ddd":"22"},{"ddd":"24"},{"ddd":"27"},{"ddd":"28"},{"ddd":"31"},{"ddd":"32"},{"ddd":"33"},{"ddd":"34"},{"ddd":"35"},{"ddd":"37"},{"ddd":"38"},{"ddd":"41"},{"ddd":"42"},{"ddd":"43"},{"ddd":"44"},{"ddd":"45"},{"ddd":"46"},{"ddd":"47"},{"ddd":"48"},{"ddd":"49"},{"ddd":"51"},{"ddd":"53"},{"ddd":"54"},{"ddd":"55"},{"ddd":"61"},{"ddd":"62"},{"ddd":"63"},{"ddd":"64"},{"ddd":"65"},{"ddd":"66"},{"ddd":"67"},{"ddd":"68"},{"ddd":"69"},{"ddd":"71"},{"ddd":"73"},{"ddd":"74"},{"ddd":"75"},{"ddd":"77"},{"ddd":"79"},{"ddd":"81"},{"ddd":"82"},{"ddd":"83"},{"ddd":"84"},{"ddd":"85"},{"ddd":"86"},{"ddd":"87"},{"ddd":"88"},{"ddd":"89"},{"ddd":"91"},{"ddd":"92"},{"ddd":"93"},{"ddd":"94"},{"ddd":"95"},{"ddd":"96"},{"ddd":"97"},{"ddd":"98"},{"ddd":"99"}]}}],"name":"SARA SILVA SIMOES","partyidentification":{"numberZ":"00000000000","type":"CPF"},"registration":"CA4K2   ","salesAgent":{"address":{"boxNr":"0","city":"SAO PAULO","neighborhood":"AGUA BRANCA","placeId":"SP","postalCode":"05037150","streetName":"HENRIQUE ONGARI","streetNumber":"100","streetType":"N/D","type":null,"urbanPropertySubAddress":"null"},"businessName":"EZCONET","channelId":"AA_TELEVENDAS","description":"Televendas","iwRegionalId":"CLARO_SP1","iwSalesAgentId":"B880","iwTypeId":"20","pointSale":[],"regionalId":"CLARO_SP1"},"situation":"ATIVO","situationDate":"2013-10-25T00:00:00.000-02:00","user":{"description":"Vendedor Vrj Nac. + AA","profiles":null,"roleId":"355","userId":"CA4K2   "}}},"apiVersion":"1;2019-02-22","error":null,"transactionId":"Id-cc330a5e87ac23f2f8c1e559"}'));
        Order varOrder = [Select id, Unidade__c, Cart_State__c FROM Order LIMIT 1];
        inputMap.put('OrderId', varOrder.id);
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock());
        CEC_SalesOrder_Controller salesController = new CEC_SalesOrder_Controller();
        salesController.invokeMethod('generateSalesOrder', inputMap, outMap, options);
        test.stopTest();
    }
    
     @isTest
    static void generateSalesOrderTestWithoutGenarateSales() {
        test.startTest();
        Map<String, Object> inputMap = new Map<String,Object>();
        Map<String, Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock());
        CEC_SalesOrder_Controller salesController = new CEC_SalesOrder_Controller();
        salesController.invokeMethod('', inputMap, outMap, options);
        test.stopTest();
    }
    
    @isTest
    static void generateSalesOrderTestWithError() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SalesOrderMock());
        CEC_SalesOrder_Controller salesController = new CEC_SalesOrder_Controller();
        salesController.invokeMethod('generateSalesOrder', null, null, null);
        test.stopTest();
    }


   
   

   public class SalesOrderMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
           
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('/products')){
                Object obj = JSON.deserializeUntyped('{"apiVersion":"1;2019-08-20","transactionId":"Id-211f0e5e5834e4625df68823","data":{"product":{"type":null,"subType":null,"sharedProductIndicator":"false","offer":{"id":null,"name":null,"price":null},"customer":{"customerAcceptances":{"flagAcceptMarketingMessages":null}},"promotion":{"id":"414403033","name":"Sinalização fidelidade 240","description":null,"discount":"0.0","expirationDate":null,"category":{"id":null},"offer":{"id":"414403033"}},"services":[{"id":"380465365","name":"Claro Conta 3G","contractedService":"true","category":{"id":"63","name":"Pacote Teste Noites em Claro 20G","description":null,"priority":null,"loyalty":{"flagValidity":null}}}],"productOffering":{"type":null,"id":"16442","name":"Claro Controle App 4GB + Minutos Ilimitados + SVA","nickname":null,"description":null,"startDate":null,"expirationDate":null,"price":"64.99","limitAmount":null,"services":[]}}}}');
                res.setBody(JSON.serialize(obj));
            }else if(request.getEndpoint().contains('/telephonenumbers/reservations')){
                Object obj = JSON.deserializeUntyped('{"transactionId":"Id-a3560e5edb526df08ffd937f","error":null,"apiVersion":"1;2019-08-20","data":{"telephoneNumbers":[{"number_z":"11945297497"}]}}');
                res.setBody(JSON.serialize(obj));
            }
            res.setStatusCode(200);
            return res;
        }
    }
}