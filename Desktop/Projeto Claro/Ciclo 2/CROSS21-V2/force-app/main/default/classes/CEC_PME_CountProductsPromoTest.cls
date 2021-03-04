@isTest
private class CEC_PME_CountProductsPromoTest {
    @testSetup 
    static void setup() {
        Product2 product = new Product2();
        product.Name = 'name1';
        product.Color__c = 'color1';
        product.Model__c = 'model1';
        product.ProductCode = '00099';
        product.Manufacturer__c = 'manufacturer1';
        product.vlocity_cmt__IsOrderable__c = true;
        product.IsActive = true;
        product.vlocity_cmt__Type__c='Aparelhos';
        product.Family='Movel';
        insert product;
        
        RecordType myRecordType = [SELECT Id, 
                                   Name 
                                   FROM RecordType 
                                   WHERE Name = 'Promotion' 
                                   AND SobjectType = 'Pricing_Matrix__c' 
                                   LIMIT 1];
        
        System.debug('Record Type -> '+ myRecordType.Id + ' Name -> ' + myRecordType.Name );
        
        List<Pricing_Matrix__c> listPricingMatrix = new List<Pricing_Matrix__c>(); 
        Pricing_Matrix__c price1 = new Pricing_Matrix__c(Promo_Duration_Unit__c = 'Months', 
                                                         Promotion_Duration__c = 1.0, 
                                                         From_Quantity__c = 50, 
                                                         To_Quantity__c = 9999,
                                                         price__c = 5,
                                                         Promotion_Type__c = 'New_Provide',
                                                         RecordTypeId = myRecordType.Id,
                                                         Type__c = 'Absolute',
                                                         Active__c = true,
                                                         Business_Unit__c = 'PME',
                                                         End_Date__c = System.today().addDays(1),
                                                         Start_Date__c =  System.today().addDays(-1)
                                                        );
        listPricingMatrix.add(price1);
        
        Pricing_Matrix__c priceDDD = new Pricing_Matrix__c(Promo_Duration_Unit__c = 'Months', 
                                                           Promotion_Duration__c = 1.0, 
                                                           From_Quantity__c = 5, 
                                                           To_Quantity__c = 49,
                                                           Promotion_Type__c = 'New_Provide',
                                                           RecordTypeId = myRecordType.Id,
                                                           price__c = 5,
                                                           Type__c = 'Absolute',
                                                           DDD__c = '77',
                                                           Active__c = true,
                                                           Business_Unit__c = 'PME',
                                                           End_Date__c = System.today().addDays(1),
                                                           Start_Date__c =  System.today().addDays(-1)
                                                          );
        listPricingMatrix.add(priceDDD);
            
        insert listPricingMatrix;
        
        Product2 product2 = new Product2(vlocity_cmt__Type__c  = 'Franquia',
                                         Name = 'Franquia001',
                                         Family='Movel',
                                         ProductCode = 'Franquia001');
        insert product2;
        
        Product2 product3 = new Product2(Name = 'Simcard Avulso',
                                         ProductCode = 'PME_SimCardAvulso_0001',
                                         Family='Movel');
        insert product3;
        
        Product2 product4 = new Product2(Name = 'Simcard Aparelho',
                                         ProductCode = 'PME_SimCardAparelho_0001',
                                         Family='Movel');
        insert product4;
        
        Product2 product5 = new Product2(Name = 'Device 01',
                                         ProductCode = '00001', 
                                         vlocity_cmt__Type__c='Aparelhos', 
                                         Family='Movel');
        insert product5;
        
        Product2 product6 = new Product2(Name = 'Device 02',
                                         ProductCode = '00002', 
                                         vlocity_cmt__Type__c='Aparelhos', 
                                         Family='Movel');
        insert product6;
        
        Product2 product7 = new Product2(Name = 'Device 03',
                                         ProductCode = '00003', 
                                         vlocity_cmt__Type__c='Aparelhos', 
                                         Family='Movel');
        insert product7;
        
        Account cuenta = new Account(Name = 'Cuenta');
        insert cuenta;
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), 
            Product2Id = product2.Id,
            UnitPrice = 10, 
            IsActive = true);
        
        insert standardPrice2;
        
        Opportunity opportunity = new Opportunity(Name = 'Opportunity', 
                                                  AccountId = cuenta.Id, 
                                                  StageName = 'Em andamento', 
                                                  CloseDate = Date.today(), 
                                                  Pricebook2ID = Test.getStandardPricebookId());
        insert opportunity;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2Id = product2.Id, 
                                                                  OpportunityId = opportunity.Id, 
                                                                  vlocity_cmt__RecurringDiscountPrice__c = 5.00, 
                                                                  vlocity_cmt__RecurringCharge__c = 100.00, 
                                                                  Quantity = 100, 
                                                                  TotalPrice = 1000, 
                                                                  vlocity_cmt__LineNumber__c  = '0001', 
                                                                  TypeOfRequest__c = 'Novo');
        insert oppLineItem;
        
        Order order = new Order(AccountId = cuenta.Id, 
                                Status = 'Em andamento', 
                                EffectiveDate = Date.today(),
                                Pricebook2ID = Test.getStandardPricebookId());
        insert order;
        
        OrderItem orderItemFranquia = new OrderItem(Product2Id = product2.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__RecurringDiscountPrice__c = 5.00, 
                                                    vlocity_cmt__RecurringCharge__c = 100.00,
                                                    UnitPrice = 55, 
                                                    Quantity = 51,  
                                                    OrderId = order.Id, 
                                                    vlocity_cmt__LineNumber__c  = '0001', 
                                                    PricebookEntryId = standardPrice2.Id, 
                                                    TypeOfRequest__c= 'TT PF/PJ', 
                                                    SAP_ID__c = '23100', 
                                                    ParentGroup__c = 'BA/SE', 
                                                    Group__c = 'AC', 
                                                    Subgroup__c = '11', 
                                                    vlocity_cmt__OverageTotal__c = 0.00 );
        insert orderItemFranquia; 
        orderItemFranquia.Id = null;
        orderItemFranquia.Subgroup__c = '77';
        orderItemFranquia.Quantity = 5; 
        insert orderItemFranquia; 
    }
    
    @isTest 
    static void testGetCountOrderNotDDD() {
        Map<String,Object> options = new Map<String,Object>();     
        
        options.put('PromotionType', 'New_Provide');
        options.put('User', 'TOP PME');
        
        String orderId = [SELECT Id
                          FROM Order
                          LIMIT 1].Id;
        
        options.put('OrderID', orderId);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getCount', new Map<String, Object>(), new Map<String, Object>(), options);
        System.assert(retorno, 'Retorno deveria ser true');
    }
    
    @isTest 
    static void testGetCountOrderDDD() {
        Map<String,Object> options = new Map<String,Object>();
        
        OrderItem orderItemFranquia = [SELECT Id,
                                       Quantity,
                                       Subgroup__c
                                       FROM OrderItem
                                       WHERE Subgroup__c != '77'];
        
        orderItemFranquia.Quantity = 6;
        orderItemFranquia.Subgroup__c = '77';
        update orderItemFranquia;
        
        options.put('PromotionType', 'New_Provide');
        options.put('User', 'TOP PME');
        
        String orderId = [SELECT Id
                          FROM Order
                          LIMIT 1].Id;
        
        options.put('OrderID', orderId);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getCount', new Map<String, Object>(), new Map<String, Object>(), options);  
        System.assert(retorno, 'Retorno deveria ser true');
    }
    
    @isTest 
    static void testGetCountOpportunity() {
        Map<String, Object> options = new Map<String, Object>();     
        
        options.put('PromotionType', 'New_Provide');
        options.put('User', 'TOP PME');
        
        String oportunityId = [SELECT Id
                               FROM Opportunity
                               LIMIT 1].Id;
        
        options.put('OpptyId', oportunityId);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getCount', new Map<String, Object>(), new Map<String, Object>(), options);  
        System.assert(!retorno, 'Retorno deveria ser false');
    }
    
    @isTest 
    static void testGetCountError() {
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getCount', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());  
        System.assert(!retorno, 'Retorno deveria ser false');
    }
    
    @isTest 
    static void testUpdateDiscountFieldAddOrder() {
        Map<String, Object> options  = new Map<String, Object>();
        Map<String, Object> mapPrice = new Map<String, Object>();
        
        OrderItem varItem = [SELECT Id, OrderId FROM OrderItem LIMIT 1];
        mapPrice.put(varItem.Id, 10);
        
        options.put('PromotionPrice', mapPrice);
        options.put('TotalProducts', 1);
        options.put('Action', 'Add');
        options.put('OrderId', varItem.OrderId);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('updateDiscountField', new Map<String, Object>(), new Map<String, Object>(), options); 
        
        OrderItem orderItem = [SELECT vlocity_cmt__RecurringDiscountPrice__c 
                               FROM OrderItem 
                               WHERE Id = :varItem.Id];
        
        System.assert(orderItem.vlocity_cmt__RecurringDiscountPrice__c == 10, 'Desconto deveria ser 10');
    }
    
    @isTest 
    static void testUpdateDiscountFieldAddOpportunity() {
        Map<String, Object> options  = new Map<String, Object>();
        Map<String, Object> mapPrice = new Map<String, Object>();
        
        OpportunityLineItem varItem = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        mapPrice.put(varItem.Id, 10);
        
        options.put('PromotionPrice', mapPrice);
        options.put('TotalProducts', 1);
        options.put('Action', 'Add');
        options.put('OpptyId', varItem.OpportunityId);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('updateDiscountField', new Map<String, Object>(), new Map<String, Object>(), options);  
        
        OpportunityLineItem opportunityLineItem = [SELECT vlocity_cmt__RecurringDiscountPrice__c 
                                                   FROM OpportunityLineItem 
                                                   WHERE Id = :varItem.Id];
        
        System.assert(opportunityLineItem.vlocity_cmt__RecurringDiscountPrice__c == 10, 'Desconto deveria ser 10');
    }
    
    
    @isTest 
    static void testUpdateDiscountFieldRemoveOrder() {
        Map<String, Object> options  = new Map<String, Object>();
        
        options.put('Action', 'Remove');
        options.put('OrderId', [SELECT Id 
                                FROM Order 
                                LIMIT 1].Id);

        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('updateDiscountField', new Map<String, Object>(), new Map<String, Object>(), options); 
        System.assert(retorno, 'Retorno deveria ser true');
    }
    
    @isTest 
    static void testUpdateDiscountFieldRemoveOpportunity() {
        Map<String, Object> options  = new Map<String, Object>();
        
        options.put('Action', 'Remove');
        options.put('OpptyId', [SELECT Id 
                                FROM Opportunity 
                                LIMIT 1].Id);
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('updateDiscountField', new Map<String, Object>(), new Map<String, Object>(), options);  
        System.assert(retorno, 'Retorno deveria ser true');
    }
    
    @isTest 
    static void testGetTradeInDuration() {
        Map<String, Object> options  = new Map<String, Object>();
        
        options.put('PromotionType', 'Desconto Progressivo');
        
       
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getTradeInDuration', new Map<String, Object>(), new Map<String, Object>(), options);  
        System.assert(!retorno, 'Retorno deveria ser false');
    }
    
    @isTest 
    static void testGetTradeInDurationNao() {
        Map<String, Object> options  = new Map<String, Object>();
        
        options.put('PromotionType', 'Não');
        
        
        Boolean retorno = new CEC_PME_CountProductsPromo().invokeMethod('getTradeInDuration', new Map<String, Object>(), new Map<String, Object>(), options);  
        System.assert(retorno, 'Retorno deveria ser true');
    }
}