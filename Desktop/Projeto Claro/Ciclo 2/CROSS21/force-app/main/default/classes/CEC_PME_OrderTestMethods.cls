public class CEC_PME_OrderTestMethods {
    public static ServiceParameter__c createParameter(String paramName){
        ServiceParameter__c param = new ServiceParameter__c();
		param.name = paramName;
		param.EndPoint__c = 'https://test/salesforce.com';
		param.Method__c = 'GET';
        param.User__c = 'user';
        param.Password__c = 'password';
        
        return param;
    }
    
    public static void generateAllData(){
        insert createParameter('PME_ConsultarOperadoraTelefone');
        
        Account acc = getAccount();
        insert acc;
        
        Contact con = getContact();
        insert con;
        
        AccountContactRelation accCtt = getAccountContactRelation(acc, con);
        update accCtt;
        
        Order ord = getOrder(acc, Test.getStandardPricebookId());
        insert ord;
        
        /*apenas para preencher a lista de cor do produto*/    
        Product2 prdOutraCor = getProduct('Produto_Cor_Diferente');
        prdOutraCor.Manufacturer__c = 'teste fabricante';
        prdOutraCor.Model__c = 'teste modelo';
        prdOutraCor.Color__c = 'teste cor 2';
        insert prdOutraCor;
        
        /*Plano Individual*/
        Product2 prd = getProduct('PME_PlanoClaroTotalIndividual_0001');
        insert prd;
        
        PricebookEntry pbe = getPbe(Test.getStandardPricebookId(), prd);
        insert pbe;
        
        OrderItem ordItem = getOrderItem(ord, prd, pbe, 'Plano_Individual', '');
        insert ordItem;
        
        /*Franquia Individual Novo*/
        Product2 prd2 = getProduct('Franquia_Individual_Novo');
        insert prd2;
        
        PricebookEntry pbe2 = getPbe(Test.getStandardPricebookId(), prd2);
        insert pbe2;
        
        OrderItem ordItem2 = getOrderItem(ord, prd2, pbe2, 'Franquia_Individual_Novo', 'Plano_Individual');
        ordItem2.TypeOfRequest__c = 'Novo';
        insert ordItem2;
        
        /*Aparelho Individual Novo*/
        Product2 prd3 = getProduct('Aparelho_Individual_Novo');
        prd3.vlocity_cmt__Type__c = 'Aparelhos';
        insert prd3;
        
        PricebookEntry pbe3 = getPbe(Test.getStandardPricebookId(), prd3);
        insert pbe3;
        
        OrderItem ordItem3 = getOrderItem(ord, prd3, pbe3, 'Aparelho_Individual_Novo', 'Franquia_Individual_Novo');
        insert ordItem3;
        
        /*Simcard Avulso Individual Novo*/
        Product2 prd4 = getProduct('SimcardAvulso_Individual_Novo');
        prd4.vlocity_cmt__Type__c = 'Aparelho';
        prd4.vlocity_cmt__subType__c = 'SimCard Avulso';
        insert prd4;
        
        PricebookEntry pbe4 = getPbe(Test.getStandardPricebookId(), prd4);
        insert pbe4;
        
        OrderItem ordItem4 = getOrderItem(ord, prd4, pbe4, 'SimcardAvulso_Individual_Novo', 'Franquia_Individual_Novo');
        insert ordItem4;
        
        /*Servico Individual Novo*/
        Product2 prd5 = getProduct('Servico_Individual_Novo');
        prd5.vlocity_cmt__Type__c = 'Serviço';
        insert prd5;
        
        PricebookEntry pbe5 = getPbe(Test.getStandardPricebookId(), prd5);
        insert pbe5;
        
        OrderItem ordItem5 = getOrderItem(ord, prd5, pbe5, 'Servico_Individual_Novo', 'Franquia_Individual_Novo');
        insert ordItem5;
        
        /*Passaporte*/
        Product2 prd6 = getProduct('Passaporte');
        prd6.vlocity_cmt__Type__c = 'Passaporte';
        //prd6.vlocity_cmt__subType__c = 'SimCard Avulso';
        insert prd6;
        
        PricebookEntry pbe6 = getPbe(Test.getStandardPricebookId(), prd6);
        insert pbe6;
        
        OrderItem ordItem6 = getOrderItem(ord, prd6, pbe6, 'Passaporte', 'Franquia_Individual_Novo');
        insert ordItem6;        
        
        /*Plano Compartilhado*/
        Product2 prdc = getProduct('PME_PlanoClaroTotalCompartilhado_0001');
        insert prdc;
        
        PricebookEntry pbec = getPbe(Test.getStandardPricebookId(), prdc);
        insert pbec;
        
        OrderItem ordItemc = getOrderItem(ord, prdc, pbec, 'Plano_Compartilhado', '');
        insert ordItemc;
        
        /*Franquia Compartilhado Novo*/
        Product2 prdc2 = getProduct('Franquia_Comp_Novo');
        insert prdc2;
        
        PricebookEntry pbec2 = getPbe(Test.getStandardPricebookId(), prdc2);
        insert pbec2;
        
        OrderItem ordItemc2 = getOrderItem(ord, prdc2, pbec2, 'Franquia_Comp_Novo', 'Plano_Compartilhado');
        insert ordItemc2;
        
        /*Plugin Compartilhado Novo*/
        Product2 prdc3 = getProduct('Plugin_Comp_Novo');
        prdc3.vlocity_cmt__Type__c = 'Plug-In';
        insert prdc3;
        
        PricebookEntry pbec3 = getPbe(Test.getStandardPricebookId(), prdc3);
        insert pbec3;
        
        OrderItem ordItemc3 = getOrderItem(ord, prdc3, pbec3, 'Plugin_Comp_Novo', 'Franquia_Comp_Novo');
        ordItemc3.TypeOfRequest__c = 'Novo';
        insert ordItemc3;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa;       
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('Test Hierarquia Pai', empresa.id);
        insert hierarquiaPai;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('Test Hierarquia', empresa.id);
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        
        Member__c mbr = CEC_ObjectFactory.getMember(UserInfo.getUserId(), empresa.id, hierarquiaPai.id); 
        insert mbr;
        
        insert hierarquia;
        
    }
    
    private static Account getAccount(){
        Account acc = new Account();
        acc.Name = 'Nome Account';
        acc.CommercialSegment__c = 'AA Claro Movel'; 
        acc.NETContractNumber__c = '12345';
        acc.ShippingPostalCode = '13033-220';
        acc.BillingPostalCode = '13033-220';
        acc.CEC_ShippingNumber__c = '1234';
        acc.CEC_ShippingComplement__c = 'teste comp';
        acc.CEC_ShippingNeighborhood__c = 'teste bairro';
        acc.ShippingCity = 'teste cidade';
        acc.ShippingState = 'teste estado';
        acc.CEC_BillingNumber__c = '4321';
        acc.CNAE__c = '012345678';
        acc.CNAE2__c = '012345678';
        
        return acc;
    }
    
    private static Contact getContact(){
        Account accnt = [SELECT Id FROM Account LIMIT 1];
        
        Contact con = new Contact();
        con.AccountId = accnt.Id;
        con.FirstName = 'Nome';
        con.LastName = 'Sobrenome';
        con.DocumentNumber__c = '00000000000';
        
        return con;
    }    
    
    private static AccountContactRelation getAccountContactRelation(Account acc, Contact ctt){
        AccountContactRelation accCtt = [SELECT Id FROM AccountContactRelation WHERE AccountId =: acc.Id and ContactId =: ctt.Id];
        
        //accCtt.AccountId = acc.Id;
        //accCtt.ContactId = ctt.Id; 
        accCtt.Email__c = 'test@teste.com';
        accCtt.MobilePhone__c = '11999999999';
        accCtt.Phone__c = '1133333333';
        accCtt.ResponsibleForTheSignature__c = true; 
        accCtt.Roles = 'Gerente de TI';
            
        return accCtt;
    }
    
    private static Product2 getProduct(String name){
        Product2 prd = new Product2();
        prd.Name = name;
        prd.ProductCode = name;
        prd.vlocity_cmt__Type__c = '';
        prd.Manufacturer__c = 'teste fabricante';
        prd.Model__c = 'teste modelo';
        prd.Color__c = 'teste cor 2';
        
        return prd;
    }
    
    private static PricebookEntry getPbe(String pbId, Product2 prd){
        PricebookEntry pbe = new PricebookEntry(pricebook2id=pbId, product2id=prd.id,unitprice=0.0, isActive=true);
        return pbe;
    }
    
    private static Order getOrder(Account acc, String pbId){
        Order ord = new Order();
        ord.AccountId = acc.Id;
        ord.Pricebook2Id = pbId;
        ord.Status = 'Em andamento';
        ord.EffectiveDate = Date.today();
        ord.ReceiverFullName1__c = 'Teste';
        ord.ReceiverFullName2__c = 'Teste';
        ord.ReceiverFullName3__c = 'Teste';
        ord.ReceiverMobile1__c = '11999999999';
        ord.ReceiverMobile2__c = '11999999999';
        ord.ReceiverMobile3__c = '11999999999';
        
        return ord;
        
    }
    
    private static OrderItem getOrderItem(Order ord, Product2 prd, PricebookEntry pbe, String assetId, String relienOnId){
        OrderItem ordItem = new OrderItem();
        ordItem.OrderId = ord.Id;
       	ordItem.Product2Id = prd.Id;
        ordItem.PricebookEntryId = pbe.Id;
        ordItem.vlocity_cmt__AssetReferenceId__c = assetId;
        ordItem.ReliesOnReferenceId__c = relienOnId;
        ordItem.Quantity = 1;
        ordItem.UnitPrice = 0.0;
        ordItem.vlocity_cmt__EffectiveRecurringTotal__c = 1;
        ordItem.DonatorName__c = 'Teste';
        ordItem.vlocity_cmt__RecurringTotal__c = 0.00;
        ordItem.AnotherDeviceColor__c = 'teste outra cor';
        return ordItem;
    }
}