/**
 * Created by 93668256 on 25/11/2019.
 */

public class ProductsIntegrationDTO {

    public class ProductsRequests {
        public ProductsRequest data;

        public ProductsRequests(ProductsRequest data) {
            this.data = data;
        }

        public ProductsRequests() {

        }
    }

    public class ProductsRequest {
        public Product product ;
        public Salesman salesman ;
        public User user ;
        public MarketSegments marketSegments ;
        public Customer customer ;

        public ProductsRequest() {
        }

        public ProductsRequest(Product product, MarketSegments marketSegments) {
            this.product = product;
            this.marketSegments = marketSegments;
        }

        public ProductsRequest(Product product, MarketSegments marketSegments, Customer customer) {
            this.product = product;
            this.marketSegments = marketSegments;
            this.customer = customer;
        }
    }

    public class ProductsResponses extends CEC_RestObjects.ResponseGen {
        public ProductsResponse data;
        public String itemId;
        public String title;
        public String orderprice;
        public String type_z;
        public String descriptionPenality;
        
        public Boolean havePenality(){
            return this.descriptionPenality != null && this.descriptionPenality != 'Não possui fidelidade' ? true : false;
        }

        public String getAmountPenality(){
            if(havePenality())
            {
                Integer init = this.descriptionPenality.lastIndexOf('$')+2;
                Integer last = (this.descriptionPenality.lastIndexOf('pró-rata'))-1;
                String retorno =  this.descriptionPenality.substring(init,last);
                return retorno.replace(',','.');
            }
            else
            {
                return '';
            }
        }
    }

    public class ProductsResponse {
        public Product product ;

    }

    public class Salesman {
        public String id ;
        public SalesAgent salesAgent ;

        public Salesman() {
        }

        public Salesman(String id, SalesAgent salesAgent) {
            this.id = id;
            this.salesAgent = salesAgent;
        }
    }

    public class SalesAgent {
        public String id ;
        public String channel ;

        public SalesAgent() {
        }

        public SalesAgent(String id, String channel) {
            this.id = id;
            this.channel = channel;
        }
    }

    public class User {
        public String id ;
        public List<Profiles> profiles ;

        public User() {
        }

        public User(String id, List<Profiles> profiles) {
            this.id = id;
            this.profiles = profiles;
        }
    }

    public class Profiles {
        public String id ;

        public Profiles() {
        }

        public Profiles(String id) {
            this.id = id;
        }
    }

    public class Customer {
        public List<Address> address ;
        public CustomerAcceptances customerAcceptances ;

        public Customer() {
        }

        public Customer(List<Address> address) {
            this.address = address;
        }
    }

    public class Address {
        public String city ;

        public Address() {
        }

        public Address(String city) {
            this.city = city;
        }
    }

    public class MarketSegments {
        public String areaCode ;

        public MarketSegments() {
        }

        public MarketSegments(String areaCode) {
            this.areaCode = areaCode;
        }
    }

    public class Category {
        public String id ;
        public String levelId ;
        public String name ;
        public String description ;
        public String priority ;
        public Loyalty loyalty ;

        public Category() {
        }

        public Category(String id, String levelId) {
            this.id = id;
            this.levelId = levelId;
        }
    }

    public class Offer {
        public String id ;
        public String name ;
        public String startDate ;
        public String expirationDate ;
        public String price ;
        public String type_Z ; // in json: type
        public Category category ;


        public Offer() {
        }

        public Offer(String id, String type_Z) {
            this.id = id;
            this.type_Z = type_Z;
        }

        public Offer(String id, String name, String startDate, String expirationDate, String price, String type_Z, Category category) {
            this.id = id;
            this.name = name;
            this.startDate = startDate;
            this.expirationDate = expirationDate;
            this.price = price;
            this.type_Z = type_Z;
            this.category = category;
        }
    }

    public class ProductOffering {
        public String type_Z ; // in json: type
        public List<Offer> offer ;
        public String id ;
        public String name ;
        public String nickname ;
        public String description ;
        public String startDate ;
        public String expirationDate ;
        public String price ;
        public String limitAmount ;
        public List<Service> services ;

        public ProductOffering() {
        }

        public ProductOffering(String type_Z, List<Offer> offer) {
            this.type_Z = type_Z;
            this.offer = offer;
        }
    }

    public class ProductOffer {
        public String id ;
        public String name ;
        public String price ;

        public ProductOffer() {
        }

        public ProductOffer(String id, String name, String price) {
            this.id = id;
            this.name = name;
            this.price = price;
        }
    }

    public class Product {
        public String type_Z ; // in json: type
        public String subType ;
        public String sharedProductIndicator ;
        public Offer offer ;
        public Customer customer ;
        public Promotion promotion ;
        public List<Service> services ;
        public ProductOffering productOffering ;

        public Product() {
        }

        public Product(String type_Z, String subType, ProductOffering productOffering) {
            this.type_Z = type_Z;
            this.subType = subType;
            this.productOffering = productOffering;
        }

        public Product(String type_Z, String subType, String sharedProductIndicator, ProductOffering productOffering) {
            this.type_Z = type_Z;
            this.subType = subType;
            this.productOffering = productOffering;
        }
    }

    public class Service {
        public String id ;
        public String name ;
        public String contractedService ;
        public Category category ;

        public Service() {
        }

        public Service(String id, String name, String contractedService, Category category) {
            this.id = id;
            this.name = name;
            this.contractedService = contractedService;
            this.category = category;
        }
    }

    public class Promotion {
        public String id ;
        public String name ;
        public String description ;
        public String discount ;
        public String expirationDate ;
        public Category category ;
        public Category offer ;

        public Promotion() {
        }

        public Promotion(String id, String name, String description, String discount, String expirationDate,
                Category category, Category offer) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.discount = discount;
            this.expirationDate = expirationDate;
            this.category = category;
            this.offer = offer;
        }
    }

    public class CustomerAcceptances {
        public String flagAcceptMarketingMessages ;

        public CustomerAcceptances() {
        }

        public CustomerAcceptances(String flagAcceptMarketingMessages) {
            this.flagAcceptMarketingMessages = flagAcceptMarketingMessages;
        }
    }

    public class Loyalty {
        public Boolean flagValidity ;

        public Loyalty(Boolean flagValidity) {
            this.flagValidity = flagValidity;
        }

        public Loyalty() {
        }
    }

    public static Customer builderCustomer(String city) {
        List<Address> adds = new List<Address>();
        adds.add(new Address(city));

        return new Customer(adds);
    }

    @testVisible
    private static Product2 getMainProduct(List<Product2> products2) {
        for (Product2 p : products2) {
            if (p.vlocity_cmt__Type__c.equals('Plano'))
                return p;
        }
        return null;
    }
    
    @testVisible
    private static Product builderProduct(Product2 product, List<vlocity_cmt__DecompositionRelationship__c> drs) {
        List<Offer> offers = new List<Offer>();

        for (vlocity_cmt__DecompositionRelationship__c dr : drs) {
            offers.add(new Offer(dr.Legacy_Offer__r.Billing_Offer_Code__c, dr.Type__c));
        }

        system.debug(product.vlocity_cmt__SubType__c);
        system.debug(offers);
        return new Product('VOZ', 'MOVEL',
                new ProductOffering(product.vlocity_cmt__SubType__c, offers));
    }

    public static ProductsRequests buildProductsRequests(Product2 product, String city, String areaCode,
            List<vlocity_cmt__DecompositionRelationship__c> drs) {

        system.debug('PRODUTO'+product);
        system.debug('DECOMPOSITION'+drs);


        ProductsRequest productsRequest = new ProductsRequest(
                builderProduct(product, drs),
                new MarketSegments(areaCode)
        );

        return new ProductsRequests(productsRequest);
    }
}