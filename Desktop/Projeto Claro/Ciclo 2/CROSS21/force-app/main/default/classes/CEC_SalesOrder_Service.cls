/**
 * Created by 93668256 on 04/11/2019.
 */

global with sharing class CEC_SalesOrder_Service {

    private OrderItem orderMain = new OrderItem();
    private List<OrderItem> dependents = new List<OrderItem>();

    private final CEC_Order_Repository orderRepository;
    private final CEC_User_Repository userRepository;
    private final CEC_Account_Repository accountRepository;
    private final CEC_IBGE_Repository ibgeRepository;

    private final CEC_SalesOrder_Integration integrationSalesOrder;
    private final CEC_IntegrationProducts integrationProducts;
    private final CEC_IntegrationPortabilitiesPreAnalysis integrationPortability;
    private final CEC_IntegrationPhoneNumberReservation integrationPhoneNumberReservation;
    private final CEC_IntegrationSales integrationSales;
    private final CEC_IntegrationInteractions integrationInteractions;
    private final CEC_IntegrationCreditAnalysisMobile integrationCreditAnalysis;
    private final Map<Id, String> mapItemsIdAndName = new Map<Id, String>();
    private final Map<Id, String> mapItemsIdAndProdName = new Map<Id, String>();

    public CEC_SalesOrder_Service() {
        this.orderRepository = new CEC_Order_Repository();
        this.accountRepository = new CEC_Account_Repository();
        this.userRepository = new CEC_User_Repository();
        this.ibgeRepository = new CEC_IBGE_Repository();
        this.integrationSalesOrder = new CEC_SalesOrder_Integration();
        this.integrationProducts = new CEC_IntegrationProducts();
        this.integrationPortability = new CEC_IntegrationPortabilitiesPreAnalysis();
        this.integrationPhoneNumberReservation = new CEC_IntegrationPhoneNumberReservation();
        this.integrationSales = new CEC_IntegrationSales();
        this.integrationInteractions = new CEC_IntegrationInteractions();
        this.integrationCreditAnalysis = new CEC_IntegrationCreditAnalysisMobile();
    }

    public String getTotalNumberToReservation(List<OrderItem> orderItems) {
        Integer count = 0;
        for (OrderItem o : orderItems) {
            if (o.Product2.vlocity_cmt__Type__c.equals('Plano') || o.Product2.vlocity_cmt__Type__c.equals('Dependente'))
                count++;
        }
        return '' + 1;
    }

    private void getOrderMain(Order order){
        for (Integer i =0; i < order.orderItems.size();i++) {
            if (order.orderItems.get(i).Product2.vlocity_cmt__Type__c.equals('Plano')) {
                this.orderMain = order.orderItems.get(i);
            }
        }
    }
    
    private Order setInteractionInOrder(Order order,
                                       Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> mapItemsAndNumber){
                
                                 
                                           
           /*if(mapItemsAndNumber.get(orderMain.Id).error != null)
           {
              return order; 
           }*/
        try {
        	order.NumProtocolo__c = integrationInteractions.consultar(
            mapItemsAndNumber.get(orderMain.Id).getOneNumber(),
            orderMain.Product2.vlocity_cmt__subType__c.equals('Pós-Pago') ? true : false
        	).data.protocolNumber;  
        } catch(exception e) {
            order.NumProtocolo__c = null;
        }                           
    	
        return order;
    }

    public List<ProductsIntegrationDTO.ProductsResponses> executeProductsIntegration(Order order) {
        Map<String, Product2> itemProduct = new Map<String, Product2>();
        Map<String, Decimal> itemPrice = new Map<String, Decimal>();
        String city = order.BillingCity;
        Map<String, Id> mapItems = new Map<String, Id>();

		Integer counter = 1;
                
        for (Integer i =0; i < order.orderItems.size();i++) {
            Product2 temp = orderRepository.getProductById(order.orderItems.get(i).Product2Id);
            decimal prodValue = order.orderItems.get(i).vlocity_cmt__RecurringCharge__c;
            temp.DescricaoMulta__c = order.orderItems.get(i).DescricaoMulta__c;
            if (order.orderItems.get(i).Product2.vlocity_cmt__Type__c.equals('Plano')) {
                itemProduct.put('TITULAR',temp);
                itemPrice.put('TITULAR',prodValue);
                this.orderMain = order.orderItems.get(i);
                mapItems.put('TITULAR', order.orderItems.get(i).Id);
                mapItemsIdAndName.put(order.orderItems.get(i).Id, 'TITULAR');
                mapItemsIdAndProdName.put(order.orderItems.get(i).Id, order.orderItems.get(i).Product2.Name);
            }
            if (order.orderItems.get(i).Product2.vlocity_cmt__Type__c.equals('Dependente')) {
                itemProduct.put('DEP'+counter,temp);
                itemPrice.put('DEP'+counter,prodValue);
                mapItems.put('DEP'+counter, order.orderItems.get(i).Id);
                mapItemsIdAndName.put(order.orderItems.get(i).Id, 'DEP'+counter);
				mapItemsIdAndProdName.put(order.orderItems.get(i).Id, order.orderItems.get(i).Product2.Name);
                counter++;
            }
        }
        map<Id, List<vlocity_cmt__DecompositionRelationship__c>> drs = orderRepository.getDecompositionRelationshipByLitsProduct2(
                order.orderItems, orderMain.Portabilidade__c, orderMain.Fidelidade__c);
        List<ProductsIntegrationDTO.ProductsResponses> responses = new List<ProductsIntegrationDTO.ProductsResponses>();
        
        for(String key : itemProduct.keySet())
        {
            ProductsIntegrationDTO.ProductsRequests o = ProductsIntegrationDTO.buildProductsRequests(itemProduct.get(key), city, order.Account.vlocity_cmt__PremisesId__r.DDD__c, drs.get(mapItems.get(key)));
            ProductsIntegrationDTO.ProductsResponses response = integrationProducts.consultar(o);
            response.title = key;
            response.type_z=itemProduct.get(key).vlocity_cmt__SubType__c;
            response.descriptionPenality = itemProduct.get(key).DescricaoMulta__c;
            response.orderprice = String.valueOf(itemPrice.get(key));
            response.itemId = mapItems.get(key);
            responses.add(response);
        }
        checkProducts(responses);
        return responses;
    }

    public SalesOrderIntegrationDTO.SalesOrderMobileResponse executesOrderMobile(String idOrder,SalesManDTO.SalesMen salesMen,
            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp creditAnalysis, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portabilty) {
        Order order = orderRepository.getOrderById(idOrder);
        getOrderMain(order);
        User user = userRepository.getUserById(order.OwnerId);
        Profile profile = userRepository.getProfileByUserId(user.ProfileId);
                
        IBGE__c ibge = ibgeRepository.getIBGEByCityNameAndDD(order.BillingCity,order.UF__c);
        List<ProductsIntegrationDTO.ProductsResponses> productsResponses = executeProductsIntegration(order);
        Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> mapItemsAndNumber = new Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo>();
                for(OrderItem item : order.OrderItems)
                {
                    if(item.Product2.vlocity_cmt__Type__c == 'Plano' || item.Product2.vlocity_cmt__Type__c == 'Dependente')
                    {
                        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo numberReservation = new PhoneNumberReservationDTO.IntegrationTestTelephoneInfo();
                        numberReservation.data = new PhoneNumberReservationDTO.IntegrationTestTelephoneValue();
                        numberReservation.data.telephoneNumbers = new List<PhoneNumberReservationDTO.PhoneNumber>();
                        if(item.NumeroProvisorio__c && item.Portabilidade__c)
                        {
                            numberReservation = integrationPhoneNumberReservation.consultar(order.Account.vlocity_cmt__PremisesId__r.DDD__c, getTotalNumberToReservation(order.OrderItems));
                            List<PhoneNumberReservationDTO.PhoneNumber> lstNumbers = numberReservation.data.telephoneNumbers;
                            PhoneNumberReservationDTO.PhoneNumber phoneNumber = new PhoneNumberReservationDTO.PhoneNumber();
                            phoneNumber.number_z = order.Account.vlocity_cmt__PremisesId__r.DDD__c + item.vlocity_cmt__SerialNumber__c;
                            lstNumbers.add(phoneNumber);
                            numberReservation.data.telephoneNumbers = lstNumbers;
                            
                            mapItemsAndNumber.put(item.Id, numberReservation);
                        }
                        else if(!item.NumeroProvisorio__c && item.Portabilidade__c)
                        {
                            List<PhoneNumberReservationDTO.PhoneNumber> lstNumbers = new List<PhoneNumberReservationDTO.PhoneNumber>();
                            PhoneNumberReservationDTO.PhoneNumber phoneNumber = new PhoneNumberReservationDTO.PhoneNumber();
                            phoneNumber.number_z = order.Account.vlocity_cmt__PremisesId__r.DDD__c + item.vlocity_cmt__SerialNumber__c;
                            lstNumbers.add(phoneNumber);
                            numberReservation.data.telephoneNumbers = lstNumbers;
                            mapItemsAndNumber.put(item.Id, numberReservation);   
                        }
                        else if(!item.Portabilidade__c && !item.NumeroProvisorio__c)
                        {

                            numberReservation = integrationPhoneNumberReservation.consultar(order.Account.vlocity_cmt__PremisesId__r.DDD__c, getTotalNumberToReservation(order.OrderItems));

                            mapItemsAndNumber.put(item.Id, numberReservation);   
                        }
                        if(numberReservation.error != null)
                        {
                            SalesOrderIntegrationDTO.SalesOrderMobileResponse responseError = new SalesOrderIntegrationDTO.SalesOrderMobileResponse();
                            CEC_RestObjects.Error error = new CEC_RestObjects.Error();
                            error.detailedMessage = Label.CEC_PoolUnavailable;
                            error.errorCode = numberReservation.error.errorCode;
                            error.httpCode = numberReservation.error.httpCode;
                            error.link = numberReservation.error.link;
                            error.message = numberReservation.error.message;
                            
                            responseError.error = error;

                            return responseError;
                        } 
                    }
                }

		order = setInteractionInOrder(order,mapItemsAndNumber);
                try {
                    SalesOrderIntegrationDTO.SalesOrderMobileResponse response = 
                        integrationSalesOrder.executeSalesOrderMobile(order, user, profile, creditAnalysis,
                                                                      portabilty, productsResponses, salesMen, mapItemsAndNumber, ibge);
                    system.debug( 'Retorno: ' + response );

                    List<SalesOrderIntegrationDTO.telephoneDetails> lstFoneDetails = 
                        getFoneDetailments(mapItemsAndNumber, mapItemsIdAndName, mapItemsIdAndProdName); 
                    response.data.order.telephonesDetails = lstFoneDetails;
                    response.data.order.id = CEC_Utils.normalizeReturnSalesOrderMobile(response.data.order.id);
                    response.data.order.interaction = order.NumProtocolo__c;
                    
                    // Update Order.IdPedidoWA__c field
                    order.Id = idOrder;
                    order.Status = 'Enviado ao Legado';
                    order.IdPedidoWA__c = response.data.order.id;
                    Database.update(order, true);
                    return response; 
                } catch(Exception e) {
                    throw new IllegalArgumentException(e.getMessage());
                }
   }

    public List<SalesOrderIntegrationDTO.telephoneDetails> getFoneDetailments (Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> mapItemsAndNumber,
                                                                               Map<Id, String> mapItemsIdAndName,
                                                                               Map<Id, String> mapItemsIdAndProdName)
    {
        List<SalesOrderIntegrationDTO.telephoneDetails> lstFoneDetails = new List<SalesOrderIntegrationDTO.telephoneDetails>();
        for(Id itemId : mapItemsAndNumber.keySet())
        {
            String itemClassification = mapItemsIdAndName.get(itemId);
            String productName = mapItemsIdAndProdName.get(itemId);
            PhoneNumberReservationDTO.IntegrationTestTelephoneInfo telefoneResource = mapItemsAndNumber.get(itemId);
            SalesOrderIntegrationDTO.TelephoneNumber_Z fones = new SalesOrderIntegrationDTO.TelephoneNumber_Z();
            if(telefoneResource.data.telephoneNumbers.size() == 2)
            {
                fones.temporaryNumber = telefoneResource.data.telephoneNumbers[0].number_z;
                fones.number_z = telefoneResource.data.telephoneNumbers[1].number_z;
            }
            else
            {
                fones.number_z = telefoneResource.data.telephoneNumbers[0].number_z;
            }
            SalesOrderIntegrationDTO.telephoneDetails telDetail = new SalesOrderIntegrationDTO.telephoneDetails();
            telDetail.itemClassification = itemClassification;
            telDetail.productName = productName;
            telDetail.fones = fones;
            lstFoneDetails.add(telDetail);
        }
        return lstFoneDetails;
    }
    
    public SalesOrderIntegrationDTO.SalesOrderMobileResponse executesOrderMobile(String idOrder) {
        Order order = orderRepository.getOrderById(idOrder);
        getOrderMain(order);
        User user = userRepository.getUserById(order.OwnerId);
        Profile profile = userRepository.getProfileByUserId(user.ProfileId);
        IBGE__c ibge = ibgeRepository.getIBGEByCityNameAndDD(order.BillingCity,'11');

        List<ProductsIntegrationDTO.ProductsResponses> productsResponses = executeProductsIntegration(order);
        Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> mapItemsAndNumber = new Map<Id, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo>();
        
        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo numberReservation = new PhoneNumberReservationDTO.IntegrationTestTelephoneInfo();
        if(this.orderMain.NumeroProvisorio__c && this.orderMain.Portabilidade__c)
        {
            numberReservation = integrationPhoneNumberReservation.consultar(order.Account.vlocity_cmt__PremisesId__r.DDD__c, getTotalNumberToReservation(order.OrderItems));
            List<PhoneNumberReservationDTO.PhoneNumber> lstNumbers = numberReservation.data.telephoneNumbers;
            PhoneNumberReservationDTO.PhoneNumber phoneNumber = new PhoneNumberReservationDTO.PhoneNumber();
            phoneNumber.number_z = this.orderMain.vlocity_cmt__SerialNumber__c;
            lstNumbers.add(phoneNumber);
            numberReservation.data.telephoneNumbers = lstNumbers;
            mapItemsAndNumber.put(this.orderMain.Id, numberReservation);
        }
        else if(!this.orderMain.NumeroProvisorio__c && this.orderMain.Portabilidade__c)
        {
            List<PhoneNumberReservationDTO.PhoneNumber> lstNumbers = numberReservation.data.telephoneNumbers;
            PhoneNumberReservationDTO.PhoneNumber phoneNumber = new PhoneNumberReservationDTO.PhoneNumber();
            phoneNumber.number_z = this.orderMain.vlocity_cmt__SerialNumber__c;
            lstNumbers.add(phoneNumber);
            numberReservation.data.telephoneNumbers = lstNumbers;
            mapItemsAndNumber.put(this.orderMain.Id, numberReservation);   
        }
        else if(!this.orderMain.Portabilidade__c)
        {
            numberReservation = integrationPhoneNumberReservation.consultar(order.Account.vlocity_cmt__PremisesId__r.DDD__c, getTotalNumberToReservation(order.OrderItems));
            mapItemsAndNumber.put(this.orderMain.Id, numberReservation);   
        }

        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portabilityPreAnalysis = integrationPortability
                .consultar('63981147622',true);

        SalesManDTO.SalesMan salesMan = integrationSales.generateMock();

        return integrationSalesOrder.executeSalesOrderMobile(order, user, profile, null,
                portabilityPreAnalysis, productsResponses, salesMan.data.salesman, mapItemsAndNumber, ibge);
    }
    
    @testVisible
    private static Boolean setError(Map<String, Object> outMap, String aMsg)
    {
        if (outMap != null 
            && String.isNotBlank(aMsg)) {
            outMap.put('error', aMsg);
        }
        return false;
    }
	
    /*
	* Autor: João Torres - OSF DIGITAL
	* Descrição: Solar FASE 1 - Squad Evolutivas - Sprint FASE 1 
	* Método com o objetivo de verificar se o serviço getProducts teve um retorno válido. 
	*/
    public void checkProducts(List<ProductsIntegrationDTO.ProductsResponses> responses){
        for(ProductsIntegrationDTO.ProductsResponses response : responses)
        {
            if(response.data.product.productOffering==null || response.data.product.productOffering.id==null)
            {
                throw new SObjectException('Tente novamente, ou abra um chamado informando o código: API-GetProducts-099 - Oferta não localizada!');
            }            
        }
    }

}