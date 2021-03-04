public class SOLAR_PME_TcpjPdfController {
    public class Plan {
        public OrderItem orderItem {get;set;}
        public List<OrderItem> franchises {get; set;}
    }
    
    public class DeviceTotalizer {
        public DeviceTotalizer() {
            totalTripleSimcard = 0;
            totalDetachedTripleSimcard = 0;
        }
        public Decimal totalTripleSimcard {get; set;}
        public Decimal totalDetachedTripleSimcard {get; set;}
    }
    
    public class Administrator {
        public Administrator(Integer admNumber, CEC_PME_SalesDocumentsRequest.Administrators administratorReq) {
            this.administratorReq = administratorReq;
            this.anchor = 'RLSF#00' + admNumber;
        }
        public CEC_PME_SalesDocumentsRequest.Administrators administratorReq {get; set;}
        public String anchor {get; set;}
        public string formatedEmail{get{
            if(string.isNotBlank(this.administratorReq.emailAddress) && this.administratorReq.emailAddress.length()>29 && this.administratorReq.emailAddress.contains('@')){
              string  convt= this.administratorReq.emailAddress.substring(0,29)+'\n'+this.administratorReq.emailAddress.substring(29,this.administratorReq.emailAddress.length());
                return convt;
            }
          return this.administratorReq.emailAddress;  
        }}
        public String mobilePhone {
            get {
                if(administratorReq.phones == null || administratorReq.phones.isEmpty()) {
                    return '---';
                }
                for(CEC_PME_SalesDocumentsRequest.Phones phone : administratorReq.phones) {
                    if(phone.contactMediumRole == 'MOBILE_PHONE') {
                        return phone.formattedNumber;
                    }
                }
                return '---';
            }
            private set; 
        }
        public String phone {
            get {
                if(administratorReq.phones == null || administratorReq.phones.isEmpty()) {
                    return '---';
                }
                for(CEC_PME_SalesDocumentsRequest.Phones phone : administratorReq.phones) {
                    if(phone.contactMediumRole != 'MOBILE_PHONE') {
                        return phone.formattedNumber;
                    }
                }
                return '---';
            }
            private set; 
        }
    }
    
    public Order varOrder {get; set;}
    public User owner {get; set;}
    public CEC_PME_SalesDocumentsRequest.SalesDocuments salesDocuments  {get; set;}
    public AnxContPermModel anxContPermModel {get; set;}
    
    public List<CEC_PME_SalesDocumentsRequest.LineDetails> lineDetails  {get; set;}
    public List<CEC_PME_SalesDocumentsRequest.Simcard> listSimcards  {get; set;}
    
    private Map<String, List<OrderItem>> mapOrderItems;
    private List<OrderItem> listOrderItemWithDonor;   
    public TipoPlano tipoPlano {get; set;}
    
    public SOLAR_PME_TcpjPdfController() {        
        String orderId = ApexPages.currentPage().getParameters().get('id');        
        this.varOrder = getOrder(orderId);
        this.owner = getOwner(varOrder.OwnerId);
        builMapOrderItems();
        setSalesDocumentsReqBody();
        buildAnxContPermModel();
        buildLineDetails();
        this.listOrderItemWithDonor = getListOrderItemWithDonor(); 
        
    }
    
    public void setSalesDocumentsReqBody() {
        
        CEC_PME_SalesDocumentsPayload createPayload = new CEC_PME_SalesDocumentsPayload();
        createPayload.isUseListBonus = true;
        
        CEC_PME_SalesDocumentsRequest.Data data = new CEC_PME_SalesDocumentsRequest.Data();
        this.salesDocuments = new CEC_PME_SalesDocumentsRequest.SalesDocuments();
        User salesmanUser = CEC_PME_SalesDocumentsQuerys.getSalesUser(varOrder.OwnerId);
        Set<Id> setAdmins = CEC_PME_SalesDocumentsPayload.getRelatedContactIdList(varOrder.Related_Contacts__c);
        List<AccountContactRelation> admins = CEC_PME_SalesDocumentsQuerys.getAccountRelations(setAdmins);
        Set<String> setRange = CEC_PME_SalesDocumentsPayload.getRange(varOrder.OrderItems);
        List<Product2> products = CEC_PME_SalesDocumentsQuerys.getRange(setRange);
        Map<String, String> mapRange = CEC_PME_SalesDocumentsPayload.getMapRange(products);               
        this.salesDocuments.salesParty = createPayload.getSalesParty(salesmanUser, varOrder.Account.CommercialSegment__c);
        CEC_PME_SalesDocumentsRequest.customer customer = createPayload.getCustomer(varOrder.Account);
        customer.contactPhone = createPayload.getCustomerContactPhone(varOrder.Account);
        customer.administrators = createPayload.getAdmins(admins);
        customer.addresses = createPayload.getAddresses(varOrder.Account);
        customer.commercialReferences = createPayload.getCommercialReferences();
        customer.billingSpec = createPayload.getBillingSpec(varOrder.Account);
        this.salesDocuments.customer = customer;
        this.salesDocuments.equipmentReceivers = createPayload.getEquipReceivers(varOrder);
        this.salesDocuments.plans = createPayload.getPlans(varOrder.OrderItems, mapRange, varOrder.Account.CommercialSegment__c);
        this.salesDocuments.summary =  createPayload.getSummary(varOrder.Payment_Term__c);
        this.salesDocuments.subscriberAcceptances = createPayload.getSubAcceptances(varOrder);
        
        system.debug(JSON.serializePretty(salesDocuments));
    }
    
    private Order getOrder(String orderId) {
        
        return [SELECT Id, 
                OwnerId,
                toLabel(Payment_Term__c),
                Related_Contacts__c,
                OrderNumber,
                ReceiverFullName1__c,
                ReceiverRG1__c,
                ReceiverMobile1__c,
                ReceiverFullName2__c,
                ReceiverRG2__c,
                ReceiverMobile2__c,
                ReceiverFullName3__c,
                ReceiverRG3__c,
                ReceiverMobile3__c,
                ReceiverPhone1__c, 
                ReceiverPhone2__c, 
                ReceiverPhone3__c,
                LD21__c,
                AccountId,
                Account.Id, 
                Account.Name, 
                Account.StateSubscription__c, 
                Account.MunicipalSubscription__c, 
                Account.CNAE__c, 
                Account.CNAE2__c, 
                Account.DocumentNumber__c, 
                Account.NETClient__c, 
                Account.EmbratelClient__c, 
                Account.NumberOfEmployees, 
                Account.CommercialSegment__c, 
                Account.BillingPostalCode, 
                Account.ShippingPostalCode, 
                Account.BillingStreet, 
                Account.ShippingStreet, 
                Account.CEC_BillingComplement__c, 
                Account.CEC_ShippingComplement__c, 
                Account.CEC_BillingNeighborhood__c, 
                Account.CEC_ShippingNeighborhood__c, 
                Account.CEC_BillingNumber__c,
                Account.BillingCity, 
                Account.ShippingCity, 
                Account.CEC_ShippingNumber__c, 
                Account.CEC_BillingAddressType__c, 
                Account.CEC_ShippingAddressType__c,
                Account.Phone, 
                Account.BillingState, 
                Account.ShippingState, 
                Account.DueDay__c, 
                Account.NETContractNumber__c,
                (SELECT Id,
                 TypeOfRequest__c, 
                 ParentGroup__c,
                 Group__c, 
                 SubGroup__c, 
                 vlocity_cmt__RecurringTotal__c, 
                 Quantity, 
                 Payment_Term__c,
                 ReliesOnReferenceId__c, 
                 vlocity_cmt__AssetReferenceId__c, 
                 PortabilityNumber__c, 
                 DonatorName__c, 
                 DonatorDocumentNumber__c, 
                 DonatorPhone__c,
                 DonatorEmail__c, 
                 Operator__c, 
                 ICCID__c, 
                 vlocity_cmt__RecurringCharge__c, 
                 DeviceSecondOptionColor__c, 
                 AnotherDeviceColor__c, 
                 vlocity_cmt__EffectiveRecurringTotal__c,
                 PlanGroup__c, 
                 TradeIn__c, 
                 Discount_Type__c, 
                 Discount_Values__c, 
                 vlocity_cmt__OverageTotal__c,
                 BonusValue__c, 
                 vlocity_cmt__RecurringDiscountPrice__c, 
                 UnitPrice, 
                 vlocity_cmt__ItemName__c,
                 Product2.Color__c,
                 Product2.SAPID__c,
                 Product2.vlocity_cmt__Type__c,
                 Product2.vlocity_cmt__SubType__c,
                 Product2.ProductCode,
                 Product2.Name,
                 Product2.Model__c,
                 Product2.Manufacturer__c,
                 Product2.vlocity_cmt__JSONAttribute__c,
                 Product2.vlocity_cmt__ObjectTypeId__c,
                 Product2.Family
                 FROM OrderItems)
                FROM Order
                WHERE Id = :orderId];
    }
    
    private User getOwner(Id ownerId) {
        return [SELECT Id,
                Name,
                Resale__c,
                CNPJResale__c,
                ConsultantCode__c,
                ResaleCode__c
                FROM User
                WHERE Id = :ownerId];
    }
    
    private void builMapOrderItems() {
        this.mapOrderItems = new Map<String, List<OrderItem>>();
        for(OrderItem varOrderItem : varOrder.OrderItems) {
            if(this.mapOrderItems.containsKey(varOrderItem.ReliesOnReferenceId__c)) {
                this.mapOrderItems.get(varOrderItem.ReliesOnReferenceId__c).add(varOrderItem);
            } else {
                this.mapOrderItems.put(varOrderItem.ReliesOnReferenceId__c, new List<OrderItem>{varOrderItem});
            }
        }
    }
    
    public String getAccountCNPJ() {
        return formatCNPJ(varOrder.Account.DocumentNumber__c);
    }
    
    public String getCNPJResale() {
        return formatCNPJ(owner.CNPJResale__c);
    }
    
    public String formatCNPJ(String unformattedCNPJ) {
        if(String.isBlank(unformattedCNPJ)) {
            return '---';
        }
        if(unformattedCNPJ.length() == 14) {
            String cnpj = unformattedCNPJ.mid(0, 2) + '.';
            cnpj += unformattedCNPJ.mid(2, 3) + '.';
            cnpj += unformattedCNPJ.mid(5, 3) + '/';
            cnpj += unformattedCNPJ.mid(8, 4) + '-';
            cnpj += unformattedCNPJ.mid(12, 2);
            return cnpj;
        }
        return unformattedCNPJ;
    }
    
    public String getReceiverMobile1() {
        return formatMobileNumbers(varOrder.ReceiverMobile1__c);
    }
    
    public String getReceiverMobile2() {
        return formatMobileNumbers(varOrder.ReceiverMobile2__c);
    }
    
    public String getReceiverMobile3() {
        return formatMobileNumbers(varOrder.ReceiverMobile3__c);
    }
    
    public String getReceiverRG1() {
        return formatRg(varOrder.ReceiverRG1__c);
    }
    
    public String getReceiverRG2() {
        return formatRg(varOrder.ReceiverRG2__c);
    }
    
    public String getReceiverRG3() {
        return formatRg(varOrder.ReceiverRG3__c);
    }
    
    private static String formatMobileNumbers(String mobileUnformatted) {
        String mobileFormatted = '(' + mobileUnformatted.mid(0, 2) + ')';
        mobileFormatted = mobileFormatted + mobileUnformatted.mid(2, 5) + '-';
        mobileFormatted = mobileFormatted + mobileUnformatted.mid(7, 4);
        return mobileFormatted;
    }
    
    public List<Plan> getListPlans() {
        List<Plan> listPlans = new List<Plan>();
        for(OrderItem varOrderItem : mapOrderItems.get(null)) {
            Plan newPlan = new Plan();
            newPlan.orderItem = varOrderItem;
            listPlans.add(newPlan);
        }
        return listPlans;
    }
    
     public List<OrderItem> getListOrderItemWithDonor() { 
        List<String> listDonatorName = new List<String>();
        if(listOrderItemWithDonor != null) {
            
            return this.listOrderItemWithDonor;
        }
        this.listOrderItemWithDonor = new List<OrderItem>();        
													   
        for(OrderItem item : varOrder.OrderItems) {
            if(String.isNotBlank(item.DonatorName__c) && !listDonatorName.contains(item.DonatorName__c)){
                OrderItem donor = new OrderItem();
                donor.DonatorName__c = item.DonatorName__c;
                donor.DonatorDocumentNumber__c = formatCpf(item.DonatorDocumentNumber__c);
                donor.DonatorPhone__c = item.DonatorPhone__c != null ? formatMobileNumbers(item.DonatorPhone__c) : '';
                donor.DonatorEmail__c  = item.DonatorEmail__c;
                this.listOrderItemWithDonor.add(donor);
                listDonatorName.add(item.DonatorName__c);
            }  
        }
        return this.listOrderItemWithDonor;
    }
    
    public Boolean getHasDonor() {
        List<OrderItem> listOrderItemWithDonor = getListOrderItemWithDonor();
        return !listOrderItemWithDonor.isEmpty();
    }
    
    public Boolean getIsLd21() {
        return 'SIM'.equalsIgnoreCase(varOrder.LD21__c);
    }
    
    public List<Administrator> getListAdministrators() {
        List<Administrator> listAdministrators = new List<Administrator>();
        Integer count = 1;
        for(CEC_PME_SalesDocumentsRequest.Administrators varAdministratorsReq : salesDocuments.customer.administrators) {
            listAdministrators.add(new Administrator(count, varAdministratorsReq));
            count++;
        }
        return listAdministrators;
    }
    
    public List<Administrator> getListAdministratorsLegalRep() {
        List<Administrator> listAdministratorsLegalRep = new List<Administrator>();
        Integer count = 1;
        for(CEC_PME_SalesDocumentsRequest.Administrators varAdministratorsReq : salesDocuments.customer.administrators) {
            if(varAdministratorsReq.isLegalRepresentative){
                listAdministratorsLegalRep.add(new Administrator(count, varAdministratorsReq));
                count++;
            }
        }
        return listAdministratorsLegalRep;
    }
    
    public List<String> getListDonorsAnchor() {
        List<String> listDonorsAnchor = new List<String>();
        Integer count = 1;
        for(OrderItem varOrderItem : getListOrderItemWithDonor()) {
            listDonorsAnchor.add('TTSF#00' + count);
            count++;
        }
        
        return listDonorsAnchor;
    }
    
    public DeviceTotalizer getDeviceTotalizer() {
        DeviceTotalizer deviceTotalizer = new DeviceTotalizer();
        for(CEC_PME_SalesDocumentsRequest.SimcardDetails simCard : salesDocuments.summary.simcards) {
            if(String.isNotBlank(simCard.type)){
                if('Triple'.endsWithIgnoreCase(simCard.type)) {
                    deviceTotalizer.totalTripleSimcard += simCard.quantity;
                } else if('Triple Avulso'.endsWithIgnoreCase(simCard.type)) {
                    deviceTotalizer.totalDetachedTripleSimcard += simCard.quantity;
                }
            }
        }
        return deviceTotalizer;
    }
    
    public String getformattedAccountShipPostcode() {
        return formatPostCode(varOrder.Account.ShippingPostalCode);
    }
    
    public String getformattedBillingPostalCode() {
        return formatPostCode(varOrder.Account.BillingPostalCode);
    }
    
    public String formatPostCode(String postCode) {
        if(String.isBlank(postCode)) {
            return '---';
        }
        if(postCode.length() == 8) { 
            return postCode.mid(0, 5) + '-' + postCode.mid(5, 3);
        }
        return postCode;
    }
    
    public String replaceBlankToTrace(String value) {
        if(String.isBlank(value)) {
            return '---';
        } else {
            return value;
        }
    }
    
    public String getShippingAddressType() {
        return replaceBlankToTrace(varOrder.Account.CEC_ShippingAddressType__c);
    }
    
    public String getShippingComplement() {
        return replaceBlankToTrace(varOrder.Account.CEC_ShippingComplement__c);
    }
    
    public String getBillingAddressType() {
        return replaceBlankToTrace(varOrder.Account.CEC_BillingAddressType__c);
    }
    
    public String getBillingComplement() {
        return replaceBlankToTrace(varOrder.Account.CEC_BillingComplement__c);
    }
    
    public String formatRg(String unformattedRg) {
        if(String.isBlank(unformattedRg)) {
            return '---';
        }
        
        String unformattedRgOnlyNum = unformattedRg.replaceAll('[^0-9]+', '');
        
        if(unformattedRgOnlyNum.length() == 9) { 
            return unformattedRgOnlyNum.mid(0, 2) + '.' + unformattedRgOnlyNum.mid(2, 3) + '.' + unformattedRgOnlyNum.mid(5, 3) + '-' + unformattedRgOnlyNum.mid(8, 1);
        }
        if(unformattedRgOnlyNum.length() == 8) { 
            return unformattedRgOnlyNum.mid(0, 2) + '.' + unformattedRgOnlyNum.mid(2, 3) + '.' + unformattedRgOnlyNum.mid(5, 3);
        }
        
        return unformattedRg;
    }
    
    public void buildAnxContPermModel() {
        tipoPlano = new tipoPlano();
        anxContPermModel = new AnxContPermModel();
        anxContPermModel.totalIndividual500MB = '---';
        anxContPermModel.totalIndividual1GB = '---';
        anxContPermModel.totalIndividual2GB = '---';
        anxContPermModel.totalIndividual3GB = '---';
        anxContPermModel.totalIndividual5GB = '---';
        anxContPermModel.totalIndividual7GB = '---';
        anxContPermModel.totalIndividual8GB = '---';
        anxContPermModel.totalIndividual9GB = '---';
        anxContPermModel.totalIndividual10GB = '---';
        anxContPermModel.totalIndividual15GB = '---';
        anxContPermModel.totalIndividual20GB = '---';
        anxContPermModel.totalIndividual30GB = '---';
        anxContPermModel.totalIndividual50GB = '---';
        anxContPermModel.totalIndividual80GB = '---';
        anxContPermModel.celular = '---';
        anxContPermModel.smartphone = '---';
        anxContPermModel.tabletModem = '---';
        anxContPermModel.total5GB = '---';
        anxContPermModel.total10GB = '---';
        anxContPermModel.total20GB = '---';
        anxContPermModel.total30GB = '---';
        anxContPermModel.total40GB = '---';
        anxContPermModel.total50GB = '---';
        anxContPermModel.total60GB = '---';
        anxContPermModel.total70GB = '---';
        anxContPermModel.total80GB = '---';
        anxContPermModel.total90GB = '---';
        anxContPermModel.total100GB = '---';
        anxContPermModel.total150GB = '---';
        anxContPermModel.total200GB = '---';
        anxContPermModel.total300GB = '---';
        anxContPermModel.total400GB = '---';
        anxContPermModel.total500GB = '---';
        anxContPermModel.total600GB = '---';
        anxContPermModel.total700GB = '---';
        anxContPermModel.total800GB = '---';
        anxContPermModel.total900GB = '---';
        anxContPermModel.total1TB = '---';
        anxContPermModel.internetWifi3GB = '---';
        anxContPermModel.internetWifi6GB = '---';
        anxContPermModel.internetWifi7GB = '---';
        anxContPermModel.internetWifi12GB = '---';
        anxContPermModel.internetWifi20GB = '---';
        anxContPermModel.internetWifi40GB = '---';
        anxContPermModel.internetWifi45GB = '---';
        anxContPermModel.internetWifi60GB = '---';
        anxContPermModel.internetWifi100GB = '---';
        anxContPermModel.internetWifi140GB = '---';        
        anxContPermModel.internet3GB = '---';
        anxContPermModel.internet6GB = '---';
        anxContPermModel.internet7GB = '---';
        anxContPermModel.internet12GB = '---';
        anxContPermModel.internet20GB = '---';
        anxContPermModel.internet40GB = '---';
        anxContPermModel.internet45GB = '---';
        anxContPermModel.internet60GB = '---';
        anxContPermModel.internet100GB = '---';
        anxContPermModel.internet140GB = '---';
        
        
            for(CEC_PME_SalesDocumentsRequest.Plans plan : salesDocuments.plans) {
                if('Plano Claro Internet'.equals(plan.name)) {
                 	tipoPlano.internet = true;
                    System.debug('TESTE 1');
                    
                    for(CEC_PME_SalesDocumentsRequest.Groups groups : plan.groups) {                    
                    	if(anxContPermModel.internet3GB.equals('---')){
                            anxContPermModel.internet3GB = getValueByFranchise('3GB', groups);
                        }
                        if(anxContPermModel.internet6GB.equals('---')){
                            anxContPermModel.internet6GB = getValueByFranchise('6GB', groups);
                        }
                        if(anxContPermModel.internet7GB.equals('---')){
                            anxContPermModel.internet7GB = getValueByFranchise('7GB', groups);
                        }
                        if(anxContPermModel.internet12GB.equals('---')){
                            anxContPermModel.internet12GB = getValueByFranchise('12GB', groups);
                        }
                        if(anxContPermModel.internet20GB.equals('---')){
                            anxContPermModel.internet20GB = getValueByFranchise('20GB', groups);
                        }
                        if(anxContPermModel.internet40GB.equals('---')){
                            anxContPermModel.internet40GB = getValueByFranchise('40GB', groups);
                        }
                        if(anxContPermModel.internet45GB.equals('---')){
                            anxContPermModel.internet45GB = getValueByFranchise('45GB', groups);
                        }
                        if(anxContPermModel.internet60GB.equals('---')){
                            anxContPermModel.internet60GB = getValueByFranchise('60GB', groups);
                        }
                        if(anxContPermModel.internet100GB.equals('---')){
                            anxContPermModel.internet100GB = getValueByFranchise('100GB', groups);
                        }
                        if(anxContPermModel.internet140GB.equals('---')){
                            anxContPermModel.internet140GB = getValueByFranchise('140GB', groups);
                        }
                    }
                    
                    
                } else if('Plano Claro Internet Wi-Fi'.equals(plan.name)) {
					tipoPlano.internet = true;
                    System.debug('TESTE 2');
					for(CEC_PME_SalesDocumentsRequest.Groups groups : plan.groups) {                    
                    	if(anxContPermModel.internetWifi3GB.equals('---')){
                            anxContPermModel.internetWifi3GB = getValueByFranchise('3GB', groups);
                        }
                        if(anxContPermModel.internetWifi6GB.equals('---')){
                            anxContPermModel.internetWifi6GB = getValueByFranchise('6GB', groups);
                        }
                        if(anxContPermModel.internetWifi7GB.equals('---')){
                            anxContPermModel.internetWifi7GB = getValueByFranchise('7GB', groups);
                        }
                        if(anxContPermModel.internetWifi12GB.equals('---')){
                            anxContPermModel.internetWifi12GB = getValueByFranchise('12GB', groups);
                        }
                        if(anxContPermModel.internetWifi20GB.equals('---')){
                            anxContPermModel.internetWifi20GB = getValueByFranchise('20GB', groups);
                        }
                        if(anxContPermModel.internetWifi40GB.equals('---')){
                            anxContPermModel.internetWifi40GB = getValueByFranchise('40GB', groups);
                        }
                        if(anxContPermModel.internetWifi45GB.equals('---')){
                            anxContPermModel.internetWifi45GB = getValueByFranchise('45GB', groups);
                        }
                        if(anxContPermModel.internetWifi60GB.equals('---')){
                            anxContPermModel.internetWifi60GB = getValueByFranchise('60GB', groups);
                        }
                        if(anxContPermModel.internetWifi100GB.equals('---')){
                            anxContPermModel.internetWifi100GB = getValueByFranchise('100GB', groups);
                        }
                        if(anxContPermModel.internetWifi140GB.equals('---')){
                            anxContPermModel.internetWifi140GB = getValueByFranchise('140GB', groups);
                        }
                    }
                    
                    
                } else if('Plano Claro Total Compartilhado'.equals(plan.name)) {
                    System.debug('TESTE 3');
                  	tipoPlano.internet = false;
                        for(CEC_PME_SalesDocumentsRequest.Groups groups : plan.groups) {
                            if(anxContPermModel.total5GB.equals('---')){
                                 anxContPermModel.total5GB = getValueByFranchise('5GB', groups);
                            }
                            if(anxContPermModel.total10GB.equals('---')){
                                 anxContPermModel.total10GB = getValueByFranchise('10GB', groups);
                            }
                            if(anxContPermModel.total20GB.equals('---')){
                                 anxContPermModel.total20GB = getValueByFranchise('20GB', groups);
                            }
                            if(anxContPermModel.total30GB.equals('---')){
                                 anxContPermModel.total30GB = getValueByFranchise('30GB', groups);
                            }
                            if(anxContPermModel.total40GB.equals('---')){
                                 anxContPermModel.total40GB = getValueByFranchise('40GB', groups);
                            }
                            if(anxContPermModel.total50GB.equals('---')){
                                 anxContPermModel.total50GB = getValueByFranchise('50GB', groups);
                            }
                            if(anxContPermModel.total60GB.equals('---')){
                                 anxContPermModel.total60GB = getValueByFranchise('60GB', groups);
                            }
                            if(anxContPermModel.total70GB.equals('---')){
                                 anxContPermModel.total70GB = getValueByFranchise('70GB', groups);
                            }
                            if(anxContPermModel.total80GB.equals('---')){
                                 anxContPermModel.total80GB = getValueByFranchise('80GB', groups);
                            }
                            if(anxContPermModel.total90GB.equals('---')){
                                 anxContPermModel.total90GB = getValueByFranchise('90GB', groups);
                            }
                            if(anxContPermModel.total100GB.equals('---')){
                                 anxContPermModel.total100GB = getValueByFranchise('100GB', groups);
                            }
                            if(anxContPermModel.total150GB.equals('---')){
                                 anxContPermModel.total150GB = getValueByFranchise('150GB', groups);
                            }
                            if(anxContPermModel.total200GB.equals('---')){
                                 anxContPermModel.total200GB = getValueByFranchise('200GB', groups);
                            }
                            if(anxContPermModel.total300GB.equals('---')){
                                 anxContPermModel.total300GB = getValueByFranchise('300GB', groups);
                            }
                            if(anxContPermModel.total400GB.equals('---')){
                                 anxContPermModel.total400GB = getValueByFranchise('400GB', groups);
                            }
                            if(anxContPermModel.total500GB.equals('---')){
                             anxContPermModel.total500GB = getValueByFranchise('500GB', groups);
                        	}
                            if(anxContPermModel.total600GB.equals('---')){
                                 anxContPermModel.total600GB = getValueByFranchise('600GB', groups);
                            }
                            if(anxContPermModel.total700GB.equals('---')){
                                 anxContPermModel.total700GB = getValueByFranchise('700GB', groups);
                            }
                            if(anxContPermModel.total800GB.equals('---')){
                                 anxContPermModel.total800GB = getValueByFranchise('800GB', groups);
                            }
                            if(anxContPermModel.total900GB.equals('---')){
                                 anxContPermModel.total900GB = getValueByFranchise('900GB', groups);
                            }
                            if(anxContPermModel.total1TB.equals('---')){
                                 anxContPermModel.total1TB = getValueByFranchise('1TB', groups);
                            }
                            if(groups != null && groups.plugins != null) {
                                for(CEC_PME_SalesDocumentsRequest.Plugin plugin : groups.plugins) {
                                    if('Celular'.equals(plugin.type)) {
                                        anxContPermModel.celular = plugin.formattedValue;
                                    } else if('Tablet e Modem'.equals(plugin.type)){
                                        anxContPermModel.smartphone = plugin.formattedValue;
                                    } else {
                                        anxContPermModel.tabletModem = plugin.formattedValue;
                                    }
                                }
                            }
                            if(groups != null && groups.additionalServices != null) {
                                for(CEC_PME_SalesDocumentsRequest.AdditionalServices additionalServices : groups.additionalServices) {
                                    if('Gestor Online'.equals(additionalServices.name)) {
                                        anxContPermModel.onlineManager = new OnlineManager();
                                        anxContPermModel.onlineManager.type = additionalServices.name;
                                        anxContPermModel.onlineManager.baseValue = 'R$ 19,90';
                                        anxContPermModel.onlineManager.contractedValue = additionalServices.formattedValue;
                                    }
                                }
                            }
                            if(anxContPermModel.onlineManager == null) {
                                anxContPermModel.onlineManager = new OnlineManager();
                                anxContPermModel.onlineManager.type = '---';
                                anxContPermModel.onlineManager.baseValue = '---';
                                anxContPermModel.onlineManager.contractedValue = '---';
                            }
                        }
                    } else {
                        anxContPermModel.onlineManager = new OnlineManager();
                        anxContPermModel.onlineManager.type = 'Gestor Online';
                        anxContPermModel.onlineManager.baseValue = 'R$ 19,90';
                        anxContPermModel.onlineManager.contractedValue = '---';
                    if(plan.groups != null) {										 
                        for(CEC_PME_SalesDocumentsRequest.Groups groups : plan.groups) { 
                            if(anxContPermModel.totalIndividual500MB.equals('---')){
                                anxContPermModel.totalIndividual500MB = getValueByFranchise('500MB', groups);
                            }
                            if( anxContPermModel.totalIndividual1GB.equals('---')){
                                anxContPermModel.totalIndividual1GB = getValueByFranchise('1GB', groups);
                            }
                            if(anxContPermModel.totalIndividual2GB.equals('---')){
                                 anxContPermModel.totalIndividual2GB = getValueByFranchise('2GB', groups);
                            }
                            if(anxContPermModel.totalIndividual3GB.equals('---')){
                                 anxContPermModel.totalIndividual3GB = getValueByFranchise('3GB', groups);
                            }
                            if(anxContPermModel.totalIndividual5GB.equals('---')){
                                 anxContPermModel.totalIndividual5GB = getValueByFranchise('5GB', groups);
                            }
                            if(anxContPermModel.totalIndividual7GB.equals('---')){
                                 anxContPermModel.totalIndividual7GB = getValueByFranchise('7GB', groups);
                            }
                            if(anxContPermModel.totalIndividual9GB.equals('---')){
                                 anxContPermModel.totalIndividual9GB = getValueByFranchise('9GB', groups);
                            }
                            if(anxContPermModel.totalIndividual10GB.equals('---')){
                                 anxContPermModel.totalIndividual10GB = getValueByFranchise('10GB', groups);
                            }
                            if(anxContPermModel.totalIndividual15GB.equals('---')){
                                 anxContPermModel.totalIndividual15GB = getValueByFranchise('15GB', groups);
                            }
                            if(anxContPermModel.totalIndividual20GB.equals('---')){
                                  anxContPermModel.totalIndividual20GB = getValueByFranchise('20GB', groups);
                            }
                            if(anxContPermModel.totalIndividual30GB.equals('---')){
                                anxContPermModel.totalIndividual30GB = getValueByFranchise('30GB', groups);
                            }
                            if(anxContPermModel.totalIndividual50GB.equals('---')){
                                 anxContPermModel.totalIndividual50GB = getValueByFranchise('50GB', groups);
                            }
                            if(anxContPermModel.totalIndividual80GB.equals('---')){
                                 anxContPermModel.totalIndividual80GB = getValueByFranchise('80GB', groups);
                            }                        
                    }
                }
            }
        }    
    }
    
    public String getValueByFranchise(String franchise, CEC_PME_SalesDocumentsRequest.Groups groups) {
        if(franchise.equals(groups.franchise)) {
            if(groups.formattedValueDiscount != null && groups.formattedValueDiscount != '---'){
               return groups.formattedValueDiscount;               
            }
            return groups.formattedValue;
        }
        return '---';
    }
    
    private void buildLineDetails() {
        this.lineDetails = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
        this.listSimcards = new List<CEC_PME_SalesDocumentsRequest.Simcard>();
        CEC_PME_SalesDocumentsRequest.Simcard simCardAux = new CEC_PME_SalesDocumentsRequest.Simcard();
        CEC_PME_SalesDocumentsRequest.Simcard simCardAvulso = new CEC_PME_SalesDocumentsRequest.Simcard();
        
        List<String> listaItensAdicionados = new List<String>();
        List<String> listaItensAdicionadosSimCard = new List<String>();
        Integer contadorAparelhos = 0;
        Integer contadorSimCard = 0;
        Boolean tipoSolicitacaoTT = false;
        for(CEC_PME_SalesDocumentsRequest.Plans plan : salesDocuments.plans) {
            if(plan.Groups != null){  
                for(CEC_PME_SalesDocumentsRequest.Groups groups : plan.Groups) {
                    if(groups.requestType.equals('TT PF/PJ')){
                        tipoSolicitacaoTT = true;
                    }
                    for(CEC_PME_SalesDocumentsRequest.LineDetails line : groups.LineDetails) {
                        contadorSimCard++;
                        if(line.device != null) {
                            contadorAparelhos++;
                        }        
                        if(contadorAparelhos <= 1){
                            simCardAux = line.simcard;
                        }
                        if(line.device != null  && (!listaItensAdicionados.contains(line.device.modelName + line.device.formattedValue))){                       
                            this.lineDetails.add(line);  
                            listaItensAdicionados.add(line.device.modelName + line.device.formattedValue);
                            
                        }
                        if(simCardAux.value != null && simCardAux.value > 0 && !listaItensAdicionadosSimCard.contains(simCardAux.type)){
                            this.listSimcards.add(simCardAux);
                            listaItensAdicionadosSimCard.add(simCardAux.type);
                        }
                  	}            
                }   
            }
															 
											   
        }

       
        if(contadorSimCard > contadorAparelhos){
            simCardAvulso.type = 'Triple Avulso';
            simCardAvulso.baseValue = simCardAux.baseValue;
            simCardAvulso.value = 10.00;
            
            if((this.listSimcards.isEmpty() && !tipoSolicitacaoTT) || simCardAvulso.type != null && !simCardAvulso.type.equals(simCardAux.type) && simCardAvulso.baseValue != simCardAux.baseValue && simCardAvulso.value != simCardAux.value && !tipoSolicitacaoTT){
            	this.listSimcards.add(simCardAvulso);
            }
            
        } 

    }
   
	 
    public class AnxContPermModel {
        public String celular {get; set;}
        public String smartphone {get; set;}
        public String tabletModem {get; set;}
        public String total5GB {get; set;}
        public String total10GB {get; set;}
        public String total20GB {get; set;}
        public String total30GB {get; set;}
        public String total40GB {get; set;}
        public String total50GB {get; set;}
        public String total60GB {get; set;}
        public String total70GB {get; set;}
        public String total80GB {get; set;}
        public String total90GB {get; set;}
        public String total100GB {get; set;}
        public String total150GB {get; set;}
        public String total200GB {get; set;}
        public String total300GB {get; set;}
        public String total400GB {get; set;}
        public String total500GB {get; set;}
        public String total600GB {get; set;}
        public String total700GB {get; set;}
        public String total800GB {get; set;}
        public String total900GB {get; set;}
        public String total1TB {get; set;}
        public String totalIndividual500MB {get; set;}
        public String totalIndividual1GB {get; set;}
        public String totalIndividual2GB {get; set;}
        public String totalIndividual3GB {get; set;}
        public String totalIndividual5GB {get; set;}
        public String totalIndividual7GB {get; set;}
        public String totalIndividual8GB {get; set;}
        public String totalIndividual9GB {get; set;}
        public String totalIndividual10GB {get; set;}
        public String totalIndividual15GB {get; set;}
        public String totalIndividual20GB {get; set;}
        public String totalIndividual30GB {get; set;}
        public String totalIndividual50GB {get; set;}
        public String totalIndividual80GB {get; set;}
        public OnlineManager onlineManager {get; set;}
        public String internetWifi3GB {get; set;}
        public String internetWifi6GB {get; set;}
        public String internetWifi7GB {get; set;}
        public String internetWifi12GB {get; set;}
        public String internetWifi20GB {get; set;}
        public String internetWifi40GB {get; set;}
        public String internetWifi45GB {get; set;}
        public String internetWifi60GB {get; set;}
        public String internetWifi100GB {get; set;}
        public String internetWifi140GB {get; set;}        
        public String internet3GB {get; set;}
        public String internet6GB {get; set;}
        public String internet7GB {get; set;}
        public String internet12GB {get; set;}
        public String internet20GB {get; set;}
        public String internet40GB {get; set;}
        public String internet45GB {get; set;}
        public String internet60GB {get; set;}
        public String internet100GB {get; set;}
        public String internet140GB {get; set;}
        
        
    }
    
    public class OnlineManager {
        public String type {get; set;}
        public String baseValue {get; set;}
        public String contractedValue {get; set;}
    }
    
    public class TipoPlano {
        public Boolean internet {get; set;} 
        public Boolean individual {get; set;}
        public Boolean compartilhado {get; set;}
    }
    
    public Boolean getIsShared() {
        boolean isShared = false;	
        for(CEC_PME_SalesDocumentsRequest.Plans plan : salesDocuments.plans) {	
            isShared |= 'Plano Claro Total Compartilhado'.equals(plan.name);	
        }
        	
        return isShared;	
    }
    
    public static String formatCpf(String unformattedCpf) {
        if(String.isBlank(unformattedCpf)) {
            return '---';
        }
        if(unformattedCpf.length() == 11) { 
            return unformattedCpf.mid(0, 3) + '.' + unformattedCpf.mid(3, 3) + '.' + unformattedCpf.mid(6, 3) + '-' + unformattedCpf.mid(9, 2);
        }
        return unformattedCpf;
    }
    

}