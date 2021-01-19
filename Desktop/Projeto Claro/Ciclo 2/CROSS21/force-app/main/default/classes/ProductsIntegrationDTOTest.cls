@isTest
public class ProductsIntegrationDTOTest {
    @isTest
    public static void mainTest() {
        system.debug('test');
        ProductsIntegrationDTO.ProductsRequests newProductsRequests = 
            new ProductsIntegrationDTO.ProductsRequests();

        newProductsRequests = 
            new ProductsIntegrationDTO.ProductsRequests( new ProductsIntegrationDTO.ProductsRequest());

        newProductsRequests.data = new ProductsIntegrationDTO.ProductsRequest(
            new ProductsIntegrationDTO.Product(), 
            new ProductsIntegrationDTO.MarketSegments());

        newProductsRequests.data = new ProductsIntegrationDTO.ProductsRequest(
            new ProductsIntegrationDTO.Product(), 
            new ProductsIntegrationDTO.MarketSegments(),
            new ProductsIntegrationDTO.Customer());

        ProductsIntegrationDTO.ProductsResponses newProductsResponses = 
            new ProductsIntegrationDTO.ProductsResponses();

        newProductsResponses.data = new ProductsIntegrationDTO.ProductsResponse();
        newProductsResponses.title = 'teste';
        newProductsResponses.type_z = 'teste';
        newProductsResponses.descriptionPenality = '$12teste1pró-rata';
        newProductsResponses.getAmountPenality();
        system.assert(newProductsResponses.havePenality(), 'Penalidade não retornada');

        newProductsResponses.data.product = new ProductsIntegrationDTO.Product();


        ProductsIntegrationDTO.Salesman newSalesman = new ProductsIntegrationDTO.Salesman();
        newSalesman = 
            new ProductsIntegrationDTO.Salesman(
                'teste',
                new ProductsIntegrationDTO.SalesAgent()
            );

        newSalesman.salesAgent = new ProductsIntegrationDTO.SalesAgent('teste','teste');

        ProductsIntegrationDTO.User newUser = new ProductsIntegrationDTO.User();

        newUser = new ProductsIntegrationDTO.User('test', new List<ProductsIntegrationDTO.Profiles>());

        ProductsIntegrationDTO.Profiles newProfile = new ProductsIntegrationDTO.Profiles();
        newProfile = new ProductsIntegrationDTO.Profiles('test');

        ProductsIntegrationDTO.Customer newCustomer = new ProductsIntegrationDTO.Customer();
        newCustomer = new ProductsIntegrationDTO.Customer(new List<ProductsIntegrationDTO.Address>()); 

        ProductsIntegrationDTO.Address newAddress = new ProductsIntegrationDTO.Address();
        newAddress = new ProductsIntegrationDTO.Address('test');

        ProductsIntegrationDTO.MarketSegments newMarketSegments = new ProductsIntegrationDTO.MarketSegments('test');

        ProductsIntegrationDTO.Category newCategory = new ProductsIntegrationDTO.Category();
        newCategory = new ProductsIntegrationDTO.Category('test', 'test');     

        ProductsIntegrationDTO.Offer newOffer = new ProductsIntegrationDTO.Offer();
        newOffer = new ProductsIntegrationDTO.Offer('test','test');
        newOffer = new ProductsIntegrationDTO.Offer('test', 'test', 'test', 'test', 'test', 'test', new ProductsIntegrationDTO.Category());

        ProductsIntegrationDTO.ProductOffering newProductOffering = new ProductsIntegrationDTO.ProductOffering();
        newProductOffering = new ProductsIntegrationDTO.ProductOffering('test', new List<ProductsIntegrationDTO.Offer>());

        ProductsIntegrationDTO.ProductOffer newProductOffer = new ProductsIntegrationDTO.ProductOffer();
        newProductOffer = new ProductsIntegrationDTO.ProductOffer('test', 'test', 'test');

        ProductsIntegrationDTO.Product newProduct = new ProductsIntegrationDTO.Product();
        newProduct = new ProductsIntegrationDTO.Product('test','test',new ProductsIntegrationDTO.ProductOffering());
        newProduct = new ProductsIntegrationDTO.Product('test', 'test', 'test', new ProductsIntegrationDTO.ProductOffering());

        ProductsIntegrationDTO.Service newService = new ProductsIntegrationDTO.Service();
        newService = new ProductsIntegrationDTO.Service('test', 'test', 'test', new ProductsIntegrationDTO.Category());

        ProductsIntegrationDTO.Promotion newPromotion = new ProductsIntegrationDTO.Promotion();
        newPromotion = new ProductsIntegrationDTO.Promotion('test', 'test', 'test', 'test', 'test',
            new ProductsIntegrationDTO.Category(), new ProductsIntegrationDTO.Category());

        ProductsIntegrationDTO.CustomerAcceptances newCustomerAcceptances = new ProductsIntegrationDTO.CustomerAcceptances();
        newCustomerAcceptances = new ProductsIntegrationDTO.CustomerAcceptances('test');

        ProductsIntegrationDTO.Loyalty newLoyalty = new ProductsIntegrationDTO.Loyalty();
        newLoyalty = new ProductsIntegrationDTO.Loyalty(true);

        ProductsIntegrationDTO.builderCustomer('test');
        ProductsIntegrationDTO.getMainProduct(new List<Product2>());
        ProductsIntegrationDTO.builderProduct(new Product2(), new List<vlocity_cmt__DecompositionRelationship__c>());
        ProductsIntegrationDTO.ProductsRequests retProductsRequests = ProductsIntegrationDTO.buildProductsRequests(new Product2(), 'test', 'test',
            new List<vlocity_cmt__DecompositionRelationship__c>());


        System.assert(retProductsRequests != null,'Objeto não construido');
    }
}