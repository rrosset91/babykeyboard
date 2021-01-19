/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para montagem do json a ser enviado ao GGD.
*/

public class CEC_PME_SalesDocumentsPayload 
{
    //constantes
    static final String INTERNATIONAL_CODE = '55';
    static final String CONST_HOME_PHONE = 'HOME_PHONE';
    static final String CONST_MOBILE_PHONE = 'MOBILE_PHONE';
	static final String CONST_SIM = 'Sim'; 
    static final String CONST_NAO = 'Nao'; 
    static final String PLANO_COMP = 'Compartilhado';
    static final String TIPO_PROD_PLUGIN = 'Plug-In';
    static final String TIPO_PROD_PASSAPORTE = 'Passaporte';
    static final String TIPO_PROD_SERVICO = 'Serviço';
    static final String TIPO_PROD_BACKUP = 'Backup Online';
    static final String TIPO_PROD_GESTOR = 'Gestor Online';
    static final String TIPO_PROD_APARELHO = 'Aparelho';
    static final String TIPO_PROD_APARELHOS = 'Aparelhos';
    static final String PROD_TABLET1 = 'Tablet & Modem';
    static final String PROD_TABLET2 = 'Tablet e Modem';
    static final String PROD_SIMCARD_AVULSO = 'SimCard Avulso';
    static final String TIPO_REQ_TRANSF = 'TT PF/PJ';
    static final String MET_PAG_VISTA = 'À Vista';
    static final String TIPO_DESCONTO = 'Pontos';
    static final String RANGE_FAIXA = 'Faixa ';
    static final String RANGE_PTS = 'PTS';
    
    //atributos do objeto
    private Integer lineQuantity = 0;
    private Integer deviceQuantity = 0;
    private Decimal totalValueOfEquipments = 0.00;
    private Decimal totalValueOfServices = 0.00;
    private String paymentMethod = '';
    private Integer simcardTripleQuantity = 0;
    private Integer simcardAvulsoQuantity = 0;    
    
    private Map<String, OrderItem> mapOrderItens;
    private Map<String, OrderItem> mapOrderRelies;
    private Map<String, List<CEC_PME_SalesDocumentsRequest.Groups>> mapIdPlanGroup;
    private Map<String, List<CEC_PME_SalesDocumentsRequest.AdditionalServices>> mapIdGroupAddServices;
    private Map<String, List<CEC_PME_SalesDocumentsRequest.IncludedServices>> mapIdGroupIncServices;
    private Map<String, List<CEC_PME_SalesDocumentsRequest.LineDetails>> mapIdGroupLineDetails;
    private Map<String, List<CEC_PME_SalesDocumentsRequest.Plugin>> mapIdGroupPlugin;
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento da propriedade API version
    */    
    public String getApiVersion()
    {
        return '';
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento da propriedade transactionId
    */      
    public String getTransactionId(String orderId)
    {
        return 'id-'+orderId;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó sales party 
    */       
    public CEC_PME_SalesDocumentsRequest.SalesParty getSalesParty(User salesmanUser, String segment)
    {
        CEC_PME_SalesDocumentsRequest.SalesParty salesParty = new CEC_PME_SalesDocumentsRequest.SalesParty();
        
        try {
            salesParty.salesmanId = salesmanUser.ConsultantCode__c;
            salesParty.salesmanName = salesmanUser.Name;
            salesParty.companyName = salesmanUser.Resale__c;
            salesParty.cnpj = salesmanUser.CNPJResale__c;
            salesParty.vendorId = salesmanUser.ResaleCode__c;
            salesParty.salesChannelId = segment;
            salesParty.segment = Label.CEC_PME_GGD_Segmento;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return salesParty;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó contato
    */       
    public CEC_PME_SalesDocumentsRequest.Customer getCustomer(Account customerAccount)
    {
        CEC_PME_SalesDocumentsRequest.customer varCustomer = new CEC_PME_SalesDocumentsRequest.customer();
        
        try {
            varCustomer.companyName = customerAccount.Name;
            varCustomer.stateRegistration = customerAccount.StateSubscription__c;
            varCustomer.municipalRegistration = customerAccount.MunicipalSubscription__c;
            varCustomer.primaryCNAE = customerAccount.CNAE__c;
            varCustomer.secondaryCNAE = customerAccount.CNAE2__c;
            varCustomer.cnpj = customerAccount.DocumentNumber__c;
            varCustomer.flagNetSubscriber = customerAccount.NETClient__c;
            varCustomer.flagEmbratelSubscriber = customerAccount.EmbratelClient__c;
            varCustomer.customerAccountId = customerAccount.NETContractNumber__c;
            varCustomer.employeeQuantity = customerAccount.NumberOfEmployees;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varCustomer;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do telefone do contato
    */       
    public CEC_PME_SalesDocumentsRequest.ContactPhone getCustomerContactPhone(Account customerAccount)
    {
        CEC_PME_SalesDocumentsRequest.ContactPhone customerContactPhone = new CEC_PME_SalesDocumentsRequest.ContactPhone();
        
        try {
            customerContactPhone.telephoneNumber = String.isNotEmpty(customerAccount.Phone) ? customerAccount.Phone.substring(2, customerAccount.Phone.length()) : '';
            customerContactPhone.areaCode = String.isNotEmpty(customerAccount.Phone) ? customerAccount.Phone.substring(0, 2) : '';
            customerContactPhone.internationalCode = INTERNATIONAL_CODE; 
            customerContactPhone.contactMediumRole = CONST_HOME_PHONE;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
               
        return customerContactPhone;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó administradores
    */       
    public List<CEC_PME_SalesDocumentsRequest.Administrators> getAdmins(List<AccountContactRelation> accRelations)
    {
        List<CEC_PME_SalesDocumentsRequest.Administrators> lstAdmins = new List<CEC_PME_SalesDocumentsRequest.Administrators>();
        
        try {
            for(AccountContactRelation accRel : accRelations)
            {
                if (accRel.Contact.DocumentNumber__c != null) {
                    CEC_PME_SalesDocumentsRequest.Administrators varAdmin = new CEC_PME_SalesDocumentsRequest.Administrators();
                    varAdmin.name = accRel.Contact.Name;
                    varAdmin.cpf = accRel.Contact.DocumentNumber__c;
                    varAdmin.emailAddress = accRel.Email__c;
                    varAdmin.isLegalRepresentative = accRel.ResponsibleForTheSignature__c;
                    varAdmin.jobTitle = accRel.Roles;
                    varAdmin.phones = getPhones(accRel.Phone__c, accRel.MobilePhone__c);
                    lstAdmins.add(varAdmin);                
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return lstAdmins;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento de telefones de administradores
    */       
    public List<CEC_PME_SalesDocumentsRequest.Phones> getPhones(String phoneNum, String mobilePhoneNum)
    {
        List<CEC_PME_SalesDocumentsRequest.Phones> lstPhone = new List<CEC_PME_SalesDocumentsRequest.Phones>();
        
        try {
            if(String.isNotEmpty(phoneNum))
            {
                CEC_PME_SalesDocumentsRequest.Phones varPhone = new CEC_PME_SalesDocumentsRequest.Phones();
                varPhone.telephoneNumber = String.isNotEmpty(phoneNum) ? phoneNum.substring(2, phoneNum.length()) : '';
                varPhone.areaCode = phoneNum.substring(0, 2);
                varPhone.internationalCode = INTERNATIONAL_CODE;
                varPhone.contactMediumRole = CONST_HOME_PHONE;
                lstPhone.add(varPhone);
            }
            
            if(String.isNotEmpty(mobilePhoneNum))
            {
                CEC_PME_SalesDocumentsRequest.Phones mobilePhone = new CEC_PME_SalesDocumentsRequest.Phones();
                mobilePhone.telephoneNumber = String.isNotEmpty(mobilePhoneNum) ? mobilePhoneNum.substring(2, mobilePhoneNum.length()) : '';
                mobilePhone.areaCode = mobilePhoneNum.substring(0, 2);
                mobilePhone.internationalCode = INTERNATIONAL_CODE;
                mobilePhone.contactMediumRole = CONST_MOBILE_PHONE;
                lstPhone.add(mobilePhone);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return lstPhone;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento de um único telefone
    */       
    public CEC_PME_SalesDocumentsRequest.Phones getPhone(String mobilePhone)
    {
        CEC_PME_SalesDocumentsRequest.Phones phone = new CEC_PME_SalesDocumentsRequest.Phones();
        
        try {
            phone.telephoneNumber = String.isNotEmpty(mobilePhone) ? mobilePhone.substring(2, mobilePhone.length()) : '';
            phone.areaCode = String.isNotEmpty(mobilePhone) ? mobilePhone.substring(0, 2) : '';
            phone.internationalCode = INTERNATIONAL_CODE;
            phone.contactMediumRole = CONST_MOBILE_PHONE;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return phone;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento dos endereços 
    */       
    public List<CEC_PME_SalesDocumentsRequest.Addresses> getAddresses(Account customerAccount)
    {
        List<CEC_PME_SalesDocumentsRequest.Addresses> lstAddress = new List<CEC_PME_SalesDocumentsRequest.Addresses>();
        
        try {
            if(String.isNotEmpty(customerAccount.BillingPostalCode))
            {
                CEC_PME_SalesDocumentsRequest.Addresses varAddress = new CEC_PME_SalesDocumentsRequest.Addresses();
                varAddress.postcode = customerAccount.BillingPostalCode;
                varAddress.streetType = customerAccount.CEC_BillingAddressType__c;
                varAddress.streetName = customerAccount.BillingStreet;
                varAddress.streetNr = customerAccount.CEC_BillingNumber__c;
                varAddress.complement = customerAccount.CEC_BillingComplement__c;
                varAddress.neighborhood = customerAccount.CEC_BillingNeighborhood__c;
                varAddress.cityName = customerAccount.BillingCity;
                varAddress.addressType = Label.CEC_PME_GGD_End_Cob;                                        
                varAddress.stateAbbreviation = customerAccount.BillingState;           
                
                lstAddress.add(varAddress);
            }
            
            if(String.isNotEmpty(customerAccount.ShippingPostalCode))
            {
                CEC_PME_SalesDocumentsRequest.Addresses varAddress = new CEC_PME_SalesDocumentsRequest.Addresses();
                varAddress.postcode = customerAccount.ShippingPostalCode;
                varAddress.streetType = customerAccount.CEC_ShippingAddressType__c;
                varAddress.streetName = customerAccount.ShippingStreet;
                varAddress.streetNr = customerAccount.CEC_ShippingNumber__c;
                varAddress.complement = customerAccount.CEC_ShippingComplement__c;
                varAddress.neighborhood = customerAccount.CEC_ShippingNeighborhood__c;
                varAddress.cityName = customerAccount.ShippingCity;
                varAddress.addressType = Label.CEC_PME_GGD_End_Princ;                                   
                varAddress.stateAbbreviation = customerAccount.ShippingState;
                
                lstAddress.add(varAddress);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return lstAddress;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento de recebedores
    */       
    public List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers> getEquipReceivers(Order varOrder)
    {
        List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers> equipReceivers = new List<CEC_PME_SalesDocumentsRequest.EquipmentReceivers>();
        
        try {
            this.paymentMethod = varOrder.Payment_Term__c;
            
            if(String.isNotEmpty(varOrder.ReceiverFullName1__c))
            {
                CEC_PME_SalesDocumentsRequest.EquipmentReceivers equipRec1 = new CEC_PME_SalesDocumentsRequest.EquipmentReceivers();
                equipRec1.name = varOrder.ReceiverFullName1__c;
                equipRec1.rg = varOrder.ReceiverRG1__c;
                equipRec1.phones = getPhone(varOrder.ReceiverMobile1__c);
                equipReceivers.add(equipRec1);
            }
            
            if(String.isNotEmpty(varOrder.ReceiverFullName2__c))
            {
                CEC_PME_SalesDocumentsRequest.EquipmentReceivers equipRec2 = new CEC_PME_SalesDocumentsRequest.EquipmentReceivers();
                equipRec2.name = varOrder.ReceiverFullName2__c;
                equipRec2.rg = varOrder.ReceiverRG2__c;
                equipRec2.phones = getPhone(varOrder.ReceiverMobile2__c);
                equipReceivers.add(equipRec2);
            }
            
            if(String.isNotEmpty(varOrder.ReceiverFullName3__c))
            {
                CEC_PME_SalesDocumentsRequest.EquipmentReceivers equipRec3 = new CEC_PME_SalesDocumentsRequest.EquipmentReceivers();
                equipRec3.name = varOrder.ReceiverFullName3__c;
                equipRec3.rg = varOrder.ReceiverRG3__c;
                equipRec3.phones = getPhone(varOrder.ReceiverMobile3__c);
                equipReceivers.add(equipRec3);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return equipReceivers;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó planos 
    */       
    public List<CEC_PME_SalesDocumentsRequest.Plans> getPlans(List<OrderItem> lstOrderItens, Map<String, String> mapRange, String segment)
    {
        List<CEC_PME_SalesDocumentsRequest.Plans> lstPlans = new List<CEC_PME_SalesDocumentsRequest.Plans>();
        
        try {
            mapOrderItens = new Map<String, OrderItem>();
            mapOrderRelies = new Map<String, OrderItem>();
            
            List<OrderItem> lstOrderPlans = new List<OrderItem>();
            
            Map<String, CEC_PME_SalesDocumentsRequest.Plans> mapIdPlan = new Map<String, CEC_PME_SalesDocumentsRequest.Plans>();
            mapIdPlanGroup = new Map<String, List<CEC_PME_SalesDocumentsRequest.Groups>>();
            
            Set<String> setIdsPlansInd = new Set<String>();   
            Set<String> setIdsPlansComp = new Set<String>();   
            List<OrderItem> lstOrderItensAux = new List<OrderItem>();
            
            for(OrderItem varOrder : lstOrderItens)
            {
                mapOrderItens.put(varOrder.vlocity_cmt__AssetReferenceId__c, varOrder);
                
                if (String.isNotBlank(varOrder.ReliesOnReferenceId__c)) {
                    mapOrderRelies.put(varOrder.ReliesOnReferenceId__c, varOrder);
                }
                
                if(String.isBlank(varOrder.ReliesOnReferenceId__c))
                {
                    CEC_PME_SalesDocumentsRequest.Plans varPlan = new CEC_PME_SalesDocumentsRequest.Plans();
                    varPlan.name = varOrder.Product2.Name;
                    
                        if (segment == 'TOP PME') {
                        	varPlan.tradeIn = varOrder.TradeIn__c;
                        }
                    
                    if(varOrder.Product2.ProductCode.contains(PLANO_COMP))
                    {
                        varPlan.flagSharedPlan = true; 
                        setIdsPlansComp.add(varOrder.vlocity_cmt__AssetReferenceId__c);                    
                    } else
                    {
                        varPlan.flagSharedPlan = false;
                        setIdsPlansInd.add(varOrder.vlocity_cmt__AssetReferenceId__c);                    
                    }
                    
                    mapIdPlan.put(varOrder.vlocity_cmt__AssetReferenceId__c, varPlan);
                    
                    lstOrderPlans.add(varOrder);
                    
                    lstPlans.add(varPlan);
                } else
                {
                    lstOrderItensAux.add(varOrder);
                }
            }
            
            getGroups(setIdsPlansInd, lstOrderItensAux, mapRange);
            getGroupsComp(setIdsPlansComp, lstOrderItensAux);
            
            for(OrderItem varOrderPlan : lstOrderPlans)
            {
                if(mapIdPlan.containsKey(varOrderPlan.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdPlan.get(varOrderPlan.vlocity_cmt__AssetReferenceId__c).groups = mapIdPlanGroup.get(varOrderPlan.vlocity_cmt__AssetReferenceId__c);              
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return lstPlans;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó grupos para planos individuais 
    */       
    public void getGroups(Set<String> setIdsPlans, List<OrderItem> lstOrderItens, Map<String, String> mapRange)
    {
        List<OrderItem> lstGroups = new List<OrderItem>();
        List<OrderItem> lstOrderItensAux = new List<OrderItem>();
        List<OrderItem> lstOrderItensPlugin = new List<OrderItem>();
        Map<String, CEC_PME_SalesDocumentsRequest.Groups> mapIdGroup = new Map<String, CEC_PME_SalesDocumentsRequest.Groups>();
        Map<String, String> mapIdPluginIdGroup = new Map<String, String>();
        
        mapIdGroupAddServices = new Map<String, List<CEC_PME_SalesDocumentsRequest.AdditionalServices>>();
        mapIdGroupIncServices = new Map<String, List<CEC_PME_SalesDocumentsRequest.IncludedServices>>();
        mapIdGroupLineDetails = new Map<String, List<CEC_PME_SalesDocumentsRequest.LineDetails>>();
        mapIdGroupPlugin = new Map<String, List<CEC_PME_SalesDocumentsRequest.Plugin>>();

        try {
            for(OrderItem varOrder : lstOrderItens)
            {
                // Franquia
                if(setIdsPlans.contains(varOrder.ReliesOnReferenceId__c))
                { 
                    CEC_PME_SalesDocumentsRequest.Groups varGroup = new CEC_PME_SalesDocumentsRequest.Groups();
                    //varGroup.tradeIn = varOrder.TradeIn__c;
                    varGroup.name = varOrder.PlanGroup__c; 
                    varGroup.requestType = varOrder.TypeOfRequest__c;
                    varGroup.regional = varOrder.ParentGroup__c;
                    varGroup.stateAbbreviation = varOrder.Group__c;
                    varGroup.areaCode = varOrder.SubGroup__c;
                    varGroup.franchise = varOrder.Product2.Name;
                    varGroup.kit = varOrder.vlocity_cmt__ItemName__c != null ? varOrder.vlocity_cmt__ItemName__c.replace('Kit ', '') : null;
                    
                    /* Bonus e desconto progressivo */
					//varGroup.value = varOrder.vlocity_cmt__RecurringCharge__c;                     
                    varGroup.value = varOrder.vlocity_cmt__RecurringDiscountPrice__c != null ? varOrder.UnitPrice : varOrder.vlocity_cmt__RecurringCharge__c;
                    varGroup.bonus = varOrder.BonusValue__c;                                        
                    varGroup.progressiveDiscount = varOrder.vlocity_cmt__RecurringDiscountPrice__c;
                    varGroup.valueDiscount = varOrder.vlocity_cmt__RecurringCharge__c;
                    
                    varGroup.paymentMethod = this.paymentMethod;
                    
                    varGroup.additionalServices = new List<CEC_PME_SalesDocumentsRequest.AdditionalServices>();
                    varGroup.includedServices = new List<CEC_PME_SalesDocumentsRequest.IncludedServices>();
                    varGroup.lineDetails = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
                    
                    if(mapIdPlanGroup.containsKey(varOrder.ReliesOnReferenceId__c))
                    {
                        mapIdPlanGroup.get(varOrder.ReliesOnReferenceId__c).add(varGroup);
                    } else
                    {
                        List<CEC_PME_SalesDocumentsRequest.Groups> lstGroupAux = new List<CEC_PME_SalesDocumentsRequest.Groups>();
                        lstGroupAux.add(varGroup);
                        mapIdPlanGroup.put(varOrder.ReliesOnReferenceId__c, lstGroupAux);
                    }
                    
                    lstGroups.add(varOrder);
                    mapIdGroup.put(varOrder.vlocity_cmt__AssetReferenceId__c, varGroup);
                    
                    this.totalValueOfServices += varOrder.vlocity_cmt__RecurringTotal__c;
                } else    
                {   
                    // Plug in 
                    if (varOrder.Product2.vlocity_cmt__Type__c != null)
                    {
                        if(!varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_PLUGIN))
                        {
                            lstOrderItensAux.add(varOrder);
                        }
                    }
                }
            }
            
            getServices(lstOrderItensAux, mapRange);
            
            for(OrderItem varOrderGroup : lstOrderItens)
            {                
                if(mapIdGroupPlugin.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    // 
                }
                
                if(mapIdGroupAddServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).additionalServices = mapIdGroupAddServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                } else if(mapIdPluginIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroupAddServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).additionalServices.addAll(mapIdGroupAddServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c));
                }
                
                if(mapIdGroupIncServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).includedServices = mapIdGroupIncServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                } else if(mapIdPluginIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroupIncServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).includedServices.addAll(mapIdGroupIncServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c));
                }
                
                // mapIdGroupLineDetails = Aparelho
                // mapIdGroup = Franquias
                // mapIdPluginIdGroup = Plugin
                if(mapIdGroupLineDetails.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) 
                   && mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c) != null
                   && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).lineDetails = mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).lineAmount = String.valueOf(mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).size());
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó grupo para planos compartilhados 
    */       
	public void getGroupsComp(Set<String> setIdsPlans, List<OrderItem> lstOrderItens)
    {
        List<OrderItem> lstGroups = new List<OrderItem>();
        List<OrderItem> lstOrderItensAux = new List<OrderItem>();
        List<OrderItem> lstOrderItensPlugin = new List<OrderItem>();
        
        List<CEC_PME_SalesDocumentsRequest.Groups> lstGroupAux = new List<CEC_PME_SalesDocumentsRequest.Groups>();
        
        Map<String, CEC_PME_SalesDocumentsRequest.Groups> mapIdGroup = new Map<String, CEC_PME_SalesDocumentsRequest.Groups>();
        Map<String, String> mapIdPluginIdGroup = new Map<String, String>();
        Map<String, OrderItem> mapFranquia = new Map<String, OrderItem>();
        Map<String, String> mapPluginFranquia = new Map<String, String>();      
       
        try {
            for(OrderItem varOrder : lstOrderItens)
            {
                // Franquia
                if(setIdsPlans.contains(varOrder.ReliesOnReferenceId__c)) {
                    mapFranquia.put(varOrder.vlocity_cmt__AssetReferenceId__c, varOrder);               
                }
                else if (varOrder.Product2.vlocity_cmt__Type__c != null) { 
                    if(varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_PLUGIN)) {
                        lstOrderItensPlugin.add(varOrder);
                        mapPluginFranquia.put(varOrder.vlocity_cmt__AssetReferenceId__c, varOrder.ReliesOnReferenceId__c);
                    } else {
                        lstOrderItensAux.add(varOrder); 
                    }
                } else
                {
                    lstOrderItensAux.add(varOrder);                
                }            
            }  
            
            for(OrderItem varPlugin : lstOrderItensPlugin)
            {
                CEC_PME_SalesDocumentsRequest.Groups varGroup = new CEC_PME_SalesDocumentsRequest.Groups();
                varGroup.regional = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).ParentGroup__c;
                varGroup.stateAbbreviation = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).Group__c;
                varGroup.franchise = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).Product2.Name; 
                //varGroup.tradeIn = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).TradeIn__c;  
                
                /* Bonus e desconto progressivo */
                varGroup.value = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).vlocity_cmt__RecurringCharge__c;                
                
                /*varGroup.value = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).vlocity_cmt__RecurringDiscountPrice__c != null ? mapFranquia.get(varPlugin.ReliesOnReferenceId__c).UnitPrice : mapFranquia.get(varPlugin.ReliesOnReferenceId__c).vlocity_cmt__RecurringCharge__c;
                varGroup.bonus = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).BonusValue__c;                                 
                varGroup.progressiveDiscount = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).vlocity_cmt__RecurringDiscountPrice__c;
                varGroup.valueDiscount = mapFranquia.get(varPlugin.ReliesOnReferenceId__c).vlocity_cmt__RecurringCharge__c;*/
                
                varGroup.name = varPlugin.PlanGroup__c;
                varGroup.areaCode = varPlugin.SubGroup__c;
                varGroup.requestType = varPlugin.TypeOfRequest__c;             
                
                varGroup.paymentMethod = this.paymentMethod;
                varGroup.additionalServices = new List<CEC_PME_SalesDocumentsRequest.AdditionalServices>();
                varGroup.includedServices = new List<CEC_PME_SalesDocumentsRequest.IncludedServices>();
                varGroup.lineDetails = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
                
                if(mapIdPlanGroup.containsKey(varPlugin.ReliesOnReferenceId__c))
                {
                    mapIdPlanGroup.get(mapFranquia.get(varPlugin.ReliesOnReferenceId__c).ReliesOnReferenceId__c).add(varGroup);
                } else
                {
                    lstGroupAux.add(varGroup);
                    mapIdPlanGroup.put(mapFranquia.get(varPlugin.ReliesOnReferenceId__c).ReliesOnReferenceId__c, lstGroupAux);              
                }
                
                lstGroups.add(varPlugin);
                mapIdGroup.put(varPlugin.vlocity_cmt__AssetReferenceId__c, varGroup);         
                this.totalValueOfServices += varPlugin.vlocity_cmt__RecurringTotal__c;            
                
                // Nó Plugin
                CEC_PME_SalesDocumentsRequest.Plugin varPluginNode = new CEC_PME_SalesDocumentsRequest.Plugin();
                varPluginNode.id = varPlugin.Product2.ProductCode;
                varPluginNode.value = varPlugin.vlocity_cmt__RecurringCharge__c;
                varPluginNode.areaCode = varPlugin.SubGroup__c;
                varPluginNode.type = varPlugin.Product2.Name.replace(PROD_TABLET1,PROD_TABLET2); 
                
                if(mapIdGroupPlugin.containsKey(varPlugin.ReliesOnReferenceId__c))
                {
                    mapIdGroupPlugin.get(varPlugin.vlocity_cmt__AssetReferenceId__c).add(varPluginNode);
                } else
                {
                    List<CEC_PME_SalesDocumentsRequest.Plugin> lstPluginAux = new List<CEC_PME_SalesDocumentsRequest.Plugin>();
                    lstPluginAux.add(varPluginNode);
                    mapIdGroupPlugin.put(varPlugin.vlocity_cmt__AssetReferenceId__c, lstPluginAux);
                }
                
                mapIdPluginIdGroup.put(varPlugin.vlocity_cmt__AssetReferenceId__c, varPlugin.ReliesOnReferenceId__c);
            }
            
            for(OrderItem varOrderGroup : lstOrderItensPlugin)
            {            
                if(mapIdGroupPlugin.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).plugins = mapIdGroupPlugin.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                }
                
                if(mapIdGroupAddServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).additionalServices = mapIdGroupAddServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                } else if(mapIdGroupAddServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdPluginIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).additionalServices.addAll(mapIdGroupAddServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c));
                } 
                
                // Gestor/backup ligados a franquia
                if(mapIdGroupAddServices.containsKey(mapPluginFranquia.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).additionalServices.addAll(mapIdGroupAddServices.get(mapPluginFranquia.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)));
                }
                
                if(mapIdGroupIncServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).includedServices = mapIdGroupIncServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                } else if(mapIdGroupIncServices.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdPluginIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).includedServices.addAll(mapIdGroupIncServices.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c));
                }
                
                // Gestor/backup ligados a franquia
                if(mapIdGroupIncServices.containsKey(mapPluginFranquia.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).includedServices.addAll(mapIdGroupIncServices.get(mapPluginFranquia.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)));
                }            
                
                // mapIdGroupLineDetails = Aparelho
                // mapIdGroup = Franquias
                // mapIdPluginIdGroup = Plugin            
                // Se for plugin mapIdGroupLineDetails tem id/assetid do plug in
                
                if(mapIdGroupLineDetails.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {    		
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).lineDetails = mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c);
                    mapIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).lineAmount = String.valueOf(mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).size());
                } else if(mapIdGroupLineDetails.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c) && mapIdPluginIdGroup.containsKey(varOrderGroup.vlocity_cmt__AssetReferenceId__c))
                {	
                    /* Else provavelmente não utilizado */
                    if(setIdsPlans.contains(varOrderGroup.ReliesOnReferenceId__c)) {
                        mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).lineDetails.addAll(mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c));                    
                        mapIdGroup.get(mapIdPluginIdGroup.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c)).lineAmount = String.valueOf(mapIdGroupLineDetails.get(varOrderGroup.vlocity_cmt__AssetReferenceId__c).size());
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento dos serviços
    */       
    public void getServices(List<OrderItem> lstOrderItens, Map<String, String> mapRange)
    {      
        try {
            for(OrderItem varOrder : lstOrderItens)
            {
                if(varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_PASSAPORTE) || varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_SERVICO) || varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_BACKUP) || varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_GESTOR))
                {               
                    if(varOrder.vlocity_cmt__RecurringCharge__c == 0) {
                        CEC_PME_SalesDocumentsRequest.IncludedServices varIncService = new CEC_PME_SalesDocumentsRequest.IncludedServices();
                        varIncService.name = varOrder.Product2.Name;
                        
                        if(mapIdGroupIncServices.containsKey(varOrder.ReliesOnReferenceId__c))
                        {
                            mapIdGroupIncServices.get(varOrder.ReliesOnReferenceId__c).add(varIncService);
                        } else
                        {
                            List<CEC_PME_SalesDocumentsRequest.IncludedServices> lstIncServiceAux = new List<CEC_PME_SalesDocumentsRequest.IncludedServices>();
                            lstIncServiceAux.add(varIncService);
                            mapIdGroupIncServices.put(varOrder.ReliesOnReferenceId__c, lstIncServiceAux);
                        }                    
                    } else {
                        CEC_PME_SalesDocumentsRequest.AdditionalServices varAddService = new CEC_PME_SalesDocumentsRequest.AdditionalServices();
                        varAddService.name = varOrder.Product2.Name;
                        varAddService.value = varOrder.vlocity_cmt__RecurringCharge__c;
                        
                        if(mapIdGroupAddServices.containsKey(varOrder.ReliesOnReferenceId__c))
                        {
                            mapIdGroupAddServices.get(varOrder.ReliesOnReferenceId__c).add(varAddService);
                        } else
                        {
                            List<CEC_PME_SalesDocumentsRequest.AdditionalServices> lstAddServiceAux = new List<CEC_PME_SalesDocumentsRequest.AdditionalServices>();
                            lstAddServiceAux.add(varAddService);
                            mapIdGroupAddServices.put(varOrder.ReliesOnReferenceId__c, lstAddServiceAux);
                        }
                    } 
                } else if(varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_APARELHOS))
                {
                    CEC_PME_SalesDocumentsRequest.LineDetails varLineDetail = new CEC_PME_SalesDocumentsRequest.LineDetails();
                    varLineDetail.telephoneNumber = varOrder.PortabilityNumber__c;
                    varLineDetail.operator = varOrder.Operator__c;
                    varLineDetail.simcard = getSimcardAparelhos(varOrder);
                    varLineDetail.device = getDevice(varOrder, mapRange);
                    varLineDetail.donor = getDonor(varOrder); 
                    
                    if(mapIdGroupLineDetails.containsKey(varOrder.ReliesOnReferenceId__c))
                    {
                        mapIdGroupLineDetails.get(varOrder.ReliesOnReferenceId__c).add(varLineDetail);
                    } else
                    {
                        List<CEC_PME_SalesDocumentsRequest.LineDetails> lstLineDetailsAux = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
                        lstLineDetailsAux.add(varLineDetail);
                        mapIdGroupLineDetails.put(varOrder.ReliesOnReferenceId__c, lstLineDetailsAux);                   
                    }
                    
                    this.deviceQuantity++;
                    this.totalValueOfEquipments += varOrder.vlocity_cmt__EffectiveRecurringTotal__c; 
                } else if(varOrder.Product2.vlocity_cmt__Type__c.equalsIgnoreCase(TIPO_PROD_APARELHO))
                {
                    CEC_PME_SalesDocumentsRequest.LineDetails varLineDetail = new CEC_PME_SalesDocumentsRequest.LineDetails();
                    varLineDetail.telephoneNumber = varOrder.PortabilityNumber__c;
                    varLineDetail.operator = varOrder.Operator__c;
                    varLineDetail.simcard = getSimcard(varOrder);
                    varLineDetail.donor = getDonor(varOrder); 
                    
                    if(mapIdGroupLineDetails.containsKey(varOrder.ReliesOnReferenceId__c))
                    {
                        mapIdGroupLineDetails.get(varOrder.ReliesOnReferenceId__c).add(varLineDetail);
                    } else
                    {
                        List<CEC_PME_SalesDocumentsRequest.LineDetails> lstLineDetailsAux = new List<CEC_PME_SalesDocumentsRequest.LineDetails>();
                        lstLineDetailsAux.add(varLineDetail);
                        mapIdGroupLineDetails.put(varOrder.ReliesOnReferenceId__c, lstLineDetailsAux);
                    }
                    
                    this.lineQuantity++;
                    this.totalValueOfEquipments += varOrder.vlocity_cmt__EffectiveRecurringTotal__c;
                }
                
                this.totalValueOfServices += varOrder.vlocity_cmt__RecurringTotal__c;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
    }

    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó doadores
    */       
    public CEC_PME_SalesDocumentsRequest.Donor getDonor(OrderItem ordItem)
    {
        CEC_PME_SalesDocumentsRequest.Donor varDonor = new CEC_PME_SalesDocumentsRequest.Donor();
        
        try {
            if(String.isNotEmpty(ordItem.DonatorName__c))
            {
                varDonor.name = ordItem.DonatorName__c;
                varDonor.cpf = ordItem.DonatorDocumentNumber__c;
                varDonor.phones = getPhones('', ordItem.DonatorPhone__c);
                varDonor.emailAddress = ordItem.DonatorEmail__c;
                varDonor.address = getAddress();
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varDonor;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento dos endereços de doadores
    */       
    public static CEC_PME_SalesDocumentsRequest.Address getAddress()
    {
        CEC_PME_SalesDocumentsRequest.Address varAddress = new CEC_PME_SalesDocumentsRequest.Address();
        
        try {
            varAddress.addressType = '';
            varAddress.postcode = '';
            varAddress.streetType = '';
            varAddress.streetName= '';
            varAddress.streetNr = '';
            varAddress.complement = '';
            varAddress.neighborhood = '';
            varAddress.cityName = '';
            varAddress.stateAbbreviation = '';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return varAddress;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó sim card
    */       
    public CEC_PME_SalesDocumentsRequest.Simcard getSimcard(OrderItem varOrdemItem)
    {
        CEC_PME_SalesDocumentsRequest.Simcard varSimCard = new CEC_PME_SalesDocumentsRequest.Simcard();
        
        try {
            varSimCard.iccid = varOrdemItem.ICCID__c;
            
            if (varOrdemItem.TypeOfRequest__c != TIPO_REQ_TRANSF) {		
                varSimCard.type = Label.CEC_PME_GGD_Triple_Avulso; 
                varSimCard.value = varOrdemItem.vlocity_cmt__RecurringCharge__c;
                varSimCard.baseValue = varOrdemItem.vlocity_cmt__OverageTotal__c;
                
                if (varOrdemItem.Product2.Name == PROD_SIMCARD_AVULSO) {
                    this.simcardAvulsoQuantity++;            
                }            
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varSimCard;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do de sim card para Aparelhos
    */       
    public CEC_PME_SalesDocumentsRequest.Simcard getSimcardAparelhos(OrderItem varOrdemItem)
    {
        CEC_PME_SalesDocumentsRequest.Simcard varSimCard = new CEC_PME_SalesDocumentsRequest.Simcard();     
        
        try {
            if (mapOrderRelies.containsKey(varOrdemItem.Id)) {
                varSimCard.iccid = varOrdemItem.ICCID__c;
                
                if (varOrdemItem.TypeOfRequest__c != TIPO_REQ_TRANSF) {					
                    varSimCard.type = Label.CEC_PME_GGD_Triple; 
                    varSimCard.value = mapOrderRelies.get(varOrdemItem.Id).vlocity_cmt__RecurringCharge__c;
                    varSimCard.baseValue = mapOrderRelies.get(varOrdemItem.Id).vlocity_cmt__OverageTotal__c;                
                    
                    this.simcardTripleQuantity++;                 
                } 
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return varSimCard;
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó dispositivos
    */   
    public CEC_PME_SalesDocumentsRequest.Device getDevice(OrderItem varOrderItem, Map<String, String> mapRange)
    {
        CEC_PME_SalesDocumentsRequest.Device varDevice = new CEC_PME_SalesDocumentsRequest.Device();
        
        try {
            varDevice.manufacturerName = varOrderItem.Product2.Manufacturer__c;
            varDevice.value = varOrderItem.vlocity_cmt__RecurringCharge__c;
            varDevice.baseValue = varOrderItem.vlocity_cmt__OverageTotal__c; 
            
            if (String.isNotBlank(varOrderItem.Product2.Model__c)) {
                varDevice.modelName = varOrderItem.Product2.Name;
            } else {
                varDevice.modelName = null;
            }
            
            
            if(String.isNotBlank(varOrderItem.DeviceSecondOptionColor__c))
            {
                if(varOrderItem.DeviceSecondOptionColor__c.equalsIgnoreCase(CONST_SIM))
                {
                    varDevice.flagAcceptAnotherColor = true;
                } else
                {
                    varDevice.flagAcceptAnotherColor = false;            
                }
            } else
            {
                varDevice.flagAcceptAnotherColor = false;
            }
            
            if(String.isNotBlank(varOrderItem.AnotherDeviceColor__c))
            {
                if(varOrderItem.AnotherDeviceColor__c.equalsIgnoreCase(CONST_NAO))
                {
                    varDevice.color = CONST_NAO;   
                } else
                {
                    varDevice.color = varOrderItem.AnotherDeviceColor__c;
                }
            } else
            {
                varDevice.color = '';
            }
            
            if (varOrderItem.Payment_Term__c == MET_PAG_VISTA || String.isBlank(varOrderItem.Payment_Term__c)) {
                varDevice.score = 0;
                varDevice.range = '';
            } else {
                if (varOrderItem.Discount_Type__c == TIPO_DESCONTO) {
                    varDevice.score = varOrderItem.Discount_Values__c != null ? Integer.valueOf(varOrderItem.Discount_Values__c.replace(RANGE_PTS, '')) : 0;                                
                } else {
                    if (varOrderItem.Discount_Values__c != null) {
                        varDevice.range = mapRange.get(varOrderItem.Discount_Values__c.replace(RANGE_FAIXA, ''));                                                  
                    }
                }
            } 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varDevice;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do resumo do pedido
    */       
    public CEC_PME_SalesDocumentsRequest.Summary getSummary(String paymentMethod)
    {
		List<CEC_PME_SalesDocumentsRequest.SimcardDetails> lstSimcardQuantity = new List<CEC_PME_SalesDocumentsRequest.SimcardDetails>();
        CEC_PME_SalesDocumentsRequest.SimcardDetails detailsTriple = new CEC_PME_SalesDocumentsRequest.SimcardDetails();
        CEC_PME_SalesDocumentsRequest.Summary varSummary = new  CEC_PME_SalesDocumentsRequest.Summary();        
        
        try {
            if (simcardTripleQuantity > 0) {        
                detailsTriple.type = Label.CEC_PME_GGD_Triple;
                detailsTriple.quantity = simcardTripleQuantity;
            }
            
            lstSimcardQuantity.add(detailsTriple);
            
            CEC_PME_SalesDocumentsRequest.SimcardDetails detailsTripleAvulso = new CEC_PME_SalesDocumentsRequest.SimcardDetails();
            
            if (simcardAvulsoQuantity > 0) {
                detailsTripleAvulso.type = Label.CEC_PME_GGD_Triple_Avulso;
                detailsTripleAvulso.quantity = simcardAvulsoQuantity;
            }
            
            lstSimcardQuantity.add(detailsTripleAvulso);                   
            
            varSummary.lineQuantity = String.valueOf(this.lineQuantity);
            varSummary.deviceQuantity = String.valueOf(this.deviceQuantity);
            varSummary.totalValueOfEquipments = this.totalValueOfEquipments;
            varSummary.totalValueOfServices = String.valueOf(this.totalValueOfServices - this.totalValueOfEquipments);
            varSummary.paymentMethod = paymentMethod;  
            varSummary.simcards = lstSimcardQuantity; 
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return varSummary;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó acceptances
    */       
    public CEC_PME_SalesDocumentsRequest.SubscriberAcceptances getSubAcceptances(Order varOrder)
    {
        CEC_PME_SalesDocumentsRequest.SubscriberAcceptances subAcceptance = new CEC_PME_SalesDocumentsRequest.SubscriberAcceptances();
        
        try {
            subAcceptance.flagAcceptSmsPublicity = false;
            subAcceptance.flagAcceptLD21Manager = CONST_SIM.equalsIgnoreCase(varOrder.LD21__c);
            subAcceptance.flagAuthorizesDataSharing = false;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return subAcceptance;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó referências comerciais
    */       
    public List<CEC_PME_SalesDocumentsRequest.CommercialReferences> getCommercialReferences()
    {
        List<CEC_PME_SalesDocumentsRequest.CommercialReferences> lstCommercialReference = new List<CEC_PME_SalesDocumentsRequest.CommercialReferences>();
        CEC_PME_SalesDocumentsRequest.CommercialReferences varCommercialReference = new CEC_PME_SalesDocumentsRequest.CommercialReferences();
        
        try {
            varCommercialReference.cnpj = '';
            varCommercialReference.companyName = '';
            varCommercialReference.contactName = '';
            varCommercialReference.contactPhone = getContactPhone();
            lstCommercialReference.add(varCommercialReference);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
        
        return lstCommercialReference;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do telefone das referências
    */       
    public CEC_PME_SalesDocumentsRequest.ContactPhone getContactPhone()
    {
        CEC_PME_SalesDocumentsRequest.ContactPhone varContactPhone = new CEC_PME_SalesDocumentsRequest.ContactPhone();
        
        try {
            varContactPhone.areaCode = '';
            varContactPhone.contactMediumRole = CONST_MOBILE_PHONE;
            varContactPhone.internationalCode = '';
            varContactPhone.telephoneNumber = '';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varContactPhone;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do endereço da conta
    */       
    public CEC_PME_SalesDocumentsRequest.BillingSpec getBillingSpec(Account customerAccount)
    {
        CEC_PME_SalesDocumentsRequest.BillingSpec varBillingSpec = new CEC_PME_SalesDocumentsRequest.BillingSpec();
        
        try {
            varBillingSpec.bankingDetails = getBankingDetails();
            varBillingSpec.paymentDayDue = customerAccount.DueDay__c;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varBillingSpec;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó de dados bancários
    */       
    public CEC_PME_SalesDocumentsRequest.BankingDetails getBankingDetails()
    {
        CEC_PME_SalesDocumentsRequest.BankingDetails varBankDetail = new CEC_PME_SalesDocumentsRequest.BankingDetails();
        
        try {
            varBankDetail.accountNumber = '';
            varBankDetail.agency = '';
            varBankDetail.bankId = '';
            varBankDetail.bankName = '';
            varBankDetail.contactName = '';
            varBankDetail.contactPhone = getContactPhone();
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return varBankDetail;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Metodo que recebe uma string com os ids de AccountContactRelation, concatenados e separados por ponto-e-virgula,
    e os coloca em um Set de Ids para retorno 
    */
    public static Set<Id> getRelatedContactIdList(String ids) {
        if (ids == null || String.isBlank(ids)) {
            return new Set<Id>();
        }
        // Filtrando o ultimo ponto-e-virgula caso haja:
        ids = ids.endsWith(';') ? ids.substring(0, ids.length()-1) : ids;
        List<String> idList = ids.split(';');
        Set<Id> idSet = new Set<Id>();
        try {
            for (String rcId : idList) {
                // Validação de ID Salesforce:
                Boolean isValid = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(rcId).matches();
                if (isValid) idSet.add(Id.valueOf(rcId));
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return idSet;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do campo faixa
    */       
	public static Set<String> getRange(List<OrderItem> orderItens)
    {
        Set<String> setRange = new Set<String>();
        
        try {
            for (OrderItem item : orderItens) {
                if (item.Discount_Values__c != null)
                    setRange.add(item.Discount_Values__c.replace(RANGE_FAIXA, ''));    
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }

		return setRange;        
    }  
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do campo faixa
    */       
    public static Map<String, String> getMapRange(List<Product2> products) {
        Map<String, String> mapRange = new Map<String, String>();
        
        try {
            for (Product2 product : products) {
                mapRange.put(product.ProductCode, product.Name);
            }  
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return mapRange;         
    }    
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Adicionar gestor online US 24075
    */
    public void addGestorOnline(CEC_PME_SalesDocumentsRequest.Plans plan) {
        try {
            if(!plan.flagSharedPlan) {
                Boolean hasGroups = plan.groups != null && !plan.groups.isEmpty();
                if(hasGroups) {
                    for(CEC_PME_SalesDocumentsRequest.Groups varGroup : plan.groups) {
                        
                        Boolean isInstantiatedList = varGroup.includedServices != null;
                        if(!isInstantiatedList) {
                            varGroup.includedServices = new List<CEC_PME_SalesDocumentsRequest.IncludedServices>();
                        }
                        varGroup.includedServices.add(buildGertorOnline());
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Build gestor online US 24075
    */    
    private CEC_PME_SalesDocumentsRequest.IncludedServices buildGertorOnline() {
        CEC_PME_SalesDocumentsRequest.IncludedServices includedServiceGO = new CEC_PME_SalesDocumentsRequest.IncludedServices();
        
        try {
            includedServiceGO.name = Label.CEC_PME_GestorOnline; //'Gestor Online';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return includedServiceGO;
    }
}