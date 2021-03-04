@isTest private class CEC_PME_KitUtilsTest  {
    /* This is the class for testing Kit Apex functionalities 
    * @author Albert Cortez
    * @since Feb 12, 2020
    * @group LABSXD
    * 
    */
    
    @TestSetup
    static void setup(){
        Account acctTest = new Account(Name = 'Test Account 1',BillingCountry='USA',BillingCity='Forest Hills',BillingPostalCode='11375',BillingStreet='110-35 72nd Rd',BillingState='NY',Fax = '1',Industry = 'Agriculture');
        insert acctTest;

        Product2 product2 = new Product2(vlocity_cmt__Type__c  = 'Kit', 
        Name = 'Kit',
        ProductCode = 'Kit',
        Description='Kit',isActive = true);
        insert product2;        
        
        Product2 product3 = new Product2(vlocity_cmt__Type__c  = 'Franquia', 
                                            Name = 'Franquia001',
                                            ProductCode = 'Franquia001',IsActive = true);
        insert product3;

        Product2 product4 = new Product2(vlocity_cmt__Type__c  = 'Mobilidade', 
        Name = 'Mobilidade',
        ProductCode = 'Mobilidade',IsActive = true);
        insert product4;

        Product2 product5 = new Product2(vlocity_cmt__Type__c  = 'Aparelho', 
        Name = 'Aparelho',
        ProductCode = 'Aparelho',IsActive = true);
        insert product5;

        Product2 product6 = new Product2(vlocity_cmt__Type__c  = 'Passaporte', 
        Name = 'Passaporte',
        ProductCode = 'Passaporte',IsActive = true);
        insert product6;

        Product2 product7 = new Product2(vlocity_cmt__Type__c  = 'Aparelhos', 
        Name = 'Aparelhos',
        ProductCode = 'Aparelhos',IsActive = true,
        Manufacturer__c = 'LG',
        Model__c = 'K8',
        Color__c = 'PRETO');
        insert product7;    


        Product2 product8 = new Product2(vlocity_cmt__Type__c  = 'Bônus', 
        Name = 'Bônus',
        ProductCode = 'Bônus',IsActive = true);
        insert product8;        


        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product2.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice;

        PricebookEntry standardPrice3 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product3.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice3;

        PricebookEntry standardPrice4 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product4.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice4;

        PricebookEntry standardPrice5 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product5.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice5;

        PricebookEntry standardPrice6 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product6.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice6;

        PricebookEntry standardPrice7 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product7.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice7;        
        

        PricebookEntry standardPrice8 = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product8.Id,
        UnitPrice = 10, IsActive = true);
        insert standardPrice8;         
        

        Opportunity oppTemplate = new Opportunity(AccountId = acctTest.id);
        oppTemplate.name  =  'KITTest';
        oppTemplate.StageName = 'Qualificação';
        oppTemplate.closedate = SYSTEM.TODAY() + 10;
        oppTemplate.Pricebook2Id = Test.getStandardPricebookId();
        insert oppTemplate;

        Opportunity opp = new Opportunity(AccountId = acctTest.id);
        opp.name  =  'TestOpp';
        opp.StageName = 'Qualificação';
        opp.closedate = SYSTEM.TODAY() + 10;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.NewRequestType__c='Novo';
        insert opp;

        OpportunityLineItem oppKit = new OpportunityLineItem(Product2Id = product2.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0001',PricebookEntryId = standardPrice.Id);
        insert oppKit;
        oppKit.vlocity_cmt__AssetReferenceId__c=oppKit.id;
        oppKit.ReliesOnReferenceId__c=oppKit.id;
        oppKit.vlocity_cmt__product2id__c=product2.id;
        oppKit.vlocity_cmt__ItemName__c='Kit';
        oppKit.vlocity_cmt__EffectiveQuantity__c=1;
        update oppKit;

        OpportunityLineItem oppFr = new OpportunityLineItem(Product2Id = product3.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0002', ReliesOnReferenceId__c =oppKit.id,PricebookEntryId = standardPrice3.Id);
        insert oppFr;
        //OpportunityLineItem teste = [SELECT Id, Product2.vlocity_cmt__Type__c FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c  = '0002'];

        oppFr.vlocity_cmt__AssetReferenceId__c=oppFr.id;
        oppFr.ReliesOnReferenceId__c=oppKit.id;
        oppFr.vlocity_cmt__product2id__c=product3.id;
        oppFr.State__c='State';
        oppFr.vlocity_cmt__EffectiveQuantity__c=1;
        update oppFr;

        OpportunityLineItem oppS1 = new OpportunityLineItem(Product2Id = product4.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0003', ReliesOnReferenceId__c =oppFr.id,PricebookEntryId = standardPrice.Id);
        insert oppS1;
        oppS1.vlocity_cmt__AssetReferenceId__c=oppS1.id;
        oppS1.ReliesOnReferenceId__c=oppFr.id;
        oppS1.vlocity_cmt__product2id__c=product4.id;
        oppS1.vlocity_cmt__RecurringCalculatedPrice__c=1;
        oppS1.vlocity_cmt__EffectiveQuantity__c=1;
        update oppS1;

        OpportunityLineItem oppS2 = new OpportunityLineItem(Product2Id = product5.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0004', ReliesOnReferenceId__c =oppFr.id,PricebookEntryId = standardPrice.Id);
        insert oppS2;
        oppS2.vlocity_cmt__AssetReferenceId__c=oppS2.id;
        oppS2.ReliesOnReferenceId__c=oppFr.id;
        oppS2.vlocity_cmt__product2id__c=product5.id;
        oppS2.vlocity_cmt__RecurringCalculatedPrice__c=1;
        oppS2.vlocity_cmt__EffectiveQuantity__c=1;
        update oppS2;

        OpportunityLineItem oppS3 = new OpportunityLineItem(Product2Id = product6.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0005', ReliesOnReferenceId__c =oppFr.id,PricebookEntryId = standardPrice.Id);
        insert oppS3;
        oppS3.vlocity_cmt__AssetReferenceId__c=oppS3.id;
        oppS3.ReliesOnReferenceId__c=oppFr.id;
        oppS3.vlocity_cmt__product2id__c=product6.id;
        oppS3.vlocity_cmt__RecurringCalculatedPrice__c=1;
        oppS3.vlocity_cmt__EffectiveQuantity__c=1;
        update oppS3;

        OpportunityLineItem oppA1 = new OpportunityLineItem(Product2Id = product7.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0006', ReliesOnReferenceId__c =oppFr.id,PricebookEntryId = standardPrice7.Id);
        insert oppA1;
        oppA1.vlocity_cmt__AssetReferenceId__c=oppA1.id;
        oppA1.ReliesOnReferenceId__c=oppFr.id;
        oppA1.vlocity_cmt__product2id__c=product7.id;
        oppA1.vlocity_cmt__RecurringCalculatedPrice__c=1;
        oppA1.vlocity_cmt__EffectiveQuantity__c=1;
        update oppA1;        

        
        OpportunityLineItem oppB1 = new OpportunityLineItem(Product2Id = product8.Id, OpportunityId = oppTemplate.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0007', ReliesOnReferenceId__c =oppFr.id,PricebookEntryId = standardPrice8.Id);
        insert oppB1;
        oppB1.vlocity_cmt__AssetReferenceId__c=oppB1.id;
        oppB1.ReliesOnReferenceId__c=oppFr.id;
        oppB1.vlocity_cmt__product2id__c=product6.id;
        oppB1.vlocity_cmt__RecurringCalculatedPrice__c=1;
        oppB1.vlocity_cmt__EffectiveQuantity__c=1;
        update oppB1;        


        Order orderTemplate = new Order(Name='KITTest', AccountId=acctTest.id, EffectiveDate=SYSTEM.TODAY(), Status='Em Andamento',Pricebook2Id=Test.getStandardPricebookId());
        Order order = new Order(Name='Test Order',AccountId=acctTest.id,EffectiveDate=SYSTEM.TODAY(), Status='Em Andamento', Pricebook2Id=Test.getStandardPricebookId());
        insert orderTemplate;
        insert order;

        OrderItem kit = new OrderItem();
        kit.product2Id=product2.id;
        kit.vlocity_cmt__product2id__c=product2.id;
        kit.orderId=orderTemplate.id;
        kit.unitPrice=10;
        kit.PricebookEntryId = standardPrice.id;
        kit.quantity=1;
        kit.vlocity_cmt__LineNumber__c  = '0001';
        kit.vlocity_cmt__ItemName__c='Kit';
        kit.vlocity_cmt__EffectiveQuantity__c=1;
        insert kit;
        kit.vlocity_cmt__AssetReferenceId__c=kit.id;
        kit.ReliesOnReferenceId__c=kit.id;
        update kit;

        OrderItem franquia = new OrderItem();
        franquia.orderid=orderTemplate.id;
        franquia.ReliesOnReferenceId__c=kit.id;
        franquia.product2id=product3.id;
        franquia.vlocity_cmt__product2id__c=product3.id;
        franquia.unitPrice=10;
        franquia.PricebookEntryId = standardPrice3.id;
        franquia.quantity=1;
        franquia.vlocity_cmt__EffectiveQuantity__c=1;
        franquia.vlocity_cmt__LineNumber__c  = '0002';

        insert franquia;
        franquia.vlocity_cmt__AssetReferenceId__c=franquia.id;
        franquia.ReliesOnReferenceId__c=kit.id;
        update franquia;

        OrderItem S1 = new OrderItem();
        S1.orderid=orderTemplate.id;
        S1.ReliesOnReferenceId__c=franquia.id;
        S1.product2id=product4.id;
        S1.vlocity_cmt__product2id__c=product4.id;
        S1.unitPrice=10;
        S1.PricebookEntryId = standardPrice4.id;
        S1.quantity=1;
        S1.vlocity_cmt__LineNumber__c  = '0003';
        S1.vlocity_cmt__EffectiveQuantity__c=1;
        insert S1;
        S1.vlocity_cmt__AssetReferenceId__c=S1.id;
        S1.ReliesOnReferenceId__c=franquia.id;
        update S1;

        OrderItem S2 = new OrderItem();
        S2.orderid=orderTemplate.id;
        S2.ReliesOnReferenceId__c=franquia.id;
        S2.product2id=product4.id;
        S2.vlocity_cmt__product2id__c=product4.id;
        S2.unitPrice=10;
        S2.PricebookEntryId = standardPrice4.id;
        S2.quantity=1;
        S2.vlocity_cmt__EffectiveQuantity__c=1;
        S2.vlocity_cmt__LineNumber__c  = '0004';

        insert S2;
        S2.vlocity_cmt__AssetReferenceId__c=S2.id;
        S2.ReliesOnReferenceId__c=franquia.id;
        update S2;

        OrderItem S3 = new OrderItem();
        S3.orderid=orderTemplate.id;
        S3.ReliesOnReferenceId__c=franquia.id;
        S3.product2id=product4.id;
        S3.vlocity_cmt__product2id__c=product4.id;
        S3.unitPrice=10;
        S3.PricebookEntryId = standardPrice5.id;
        S3.quantity=1;
        S3.vlocity_cmt__EffectiveQuantity__c=1;
        S3.vlocity_cmt__LineNumber__c  = '0005';

        insert S3;
        S3.vlocity_cmt__AssetReferenceId__c=S3.id;
        S3.ReliesOnReferenceId__c=franquia.id;
        update S3;

        OrderItem A1 = new OrderItem();
        A1.orderid=orderTemplate.id;
        A1.ReliesOnReferenceId__c=franquia.id;
        A1.product2id=product7.id;
        A1.vlocity_cmt__product2id__c=product7.id;
        A1.unitPrice=10;
        A1.PricebookEntryId = standardPrice7.id;
        A1.quantity=1;
        A1.vlocity_cmt__EffectiveQuantity__c=1;
        A1.vlocity_cmt__LineNumber__c  = '0006';
    
        insert A1;
        A1.vlocity_cmt__AssetReferenceId__c=A1.id;
        A1.ReliesOnReferenceId__c=franquia.id;
        update A1;        

        
        OrderItem B1 = new OrderItem();
        B1.orderid=orderTemplate.id;
        B1.ReliesOnReferenceId__c=franquia.id;
        B1.product2id=product8.id;
        B1.vlocity_cmt__product2id__c=product8.id;
        B1.unitPrice=10;
        B1.PricebookEntryId = standardPrice8.id;
        B1.quantity=1;
        B1.vlocity_cmt__EffectiveQuantity__c=1;
        B1.vlocity_cmt__LineNumber__c  = '0007';

        insert B1;
        B1.vlocity_cmt__AssetReferenceId__c=B1.id;
        B1.ReliesOnReferenceId__c=franquia.id;
        update B1;        

    }
    
    //METODO 1a
    @isTest static void testShowKitProductsOrder(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
       
       
        Order  orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        Order order = [Select id,Name from Order where not Name like '%KIT%' limit 1];
                
        OrderItem orderItemKit= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0001' Limit 1];
        OrderItem orderItemfr= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        OrderItem orderS1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0003' Limit 1];
        OrderItem orderS2= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0004' Limit 1];
        OrderItem orderS3= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0005' Limit 1];
        OrderItem orderA1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0006' Limit 1];

        OrderItem orderB1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0007' Limit 1];


        String orderProduct= '{"AssetReference":\"'+orderItemKit.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderItemKit.ReliesOnReferenceId__c+'","ProductCode": "Kit","Name": "Kit","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderItemKit.Product2Id+'\"}';
        String orderProduct2= '{"AssetReference":\"'+orderItemfr.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderItemfr.ReliesOnReferenceId__c+'","ProductCode": "Franquia","Name": "Franquia","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderItemfr.Product2Id+'\"}';
        String orderProduct3= '{"AssetReference":\"'+orderS1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderS1.ReliesOnReferenceId__c+'","ProductCode": "Mobilidade","Name": "Mobilidade","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderS1.Product2Id+'\"}';
        String orderProduct4= '{"AssetReference":\"'+orderS2.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderS2.ReliesOnReferenceId__c+'","ProductCode": "Aparelho","Name": "APARELHO","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderS2.Product2Id+'\"}';
        String orderProduct5= '{"AssetReference":\"'+orderS3.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderS3.ReliesOnReferenceId__c+'","ProductCode": "Passaporte","Name": "Passaporte","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderS3.Product2Id+'\"}';
        String orderProduct6= '{"AssetReference":\"'+orderA1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderA1.ReliesOnReferenceId__c+'","ProductCode": "Aparelhos","Name": "Aparelhos","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderA1.Product2Id+'\"}';

        String orderProduct7= '{"AssetReference":\"'+orderB1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+orderB1.ReliesOnReferenceId__c+'","ProductCode": "Bônus","Name": "Bônus","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+orderB1.Product2Id+'\"}';


        List<Map<String,Object>> orderProducts= new List<Map<String,Object>>();
        Map<String,Object> prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct);
        orderProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct2);
        orderProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct3);
        orderProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct4);
        orderProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct5);
        orderProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct6);
        orderProducts.add(prod);

        prod=(Map<String,Object>)JSON.deserializeUntyped(orderProduct7);
        orderProducts.add(prod);        

       
        options.put('orderTemplateProducts',orderProducts);
        options.put('orderTemplateId',orderTemplate.Id);
        options.put('orderId',order.Id);
       
        Test.startTest();
        Boolean retorno = myKitClass.invokeMethod('showKitProducts',inputMap,outMap,options);
        Test.stopTest();
    }

    //METODO 1b
    @isTest static void testShowKitProductsOpp(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        Opportunity oppty = [Select id,Name from Opportunity where not Name like '%KIT%' limit 1];

        OpportunityLineItem opptyItemKit= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0001' Limit 1];
        OpportunityLineItem opptyItemfr= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        OpportunityLineItem opptyS1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0003' Limit 1];
        OpportunityLineItem opptyS2= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0004' Limit 1];
        OpportunityLineItem opptyS3= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0005' Limit 1];
        OpportunityLineItem opptyA1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0006' Limit 1];

        OpportunityLineItem opptyB1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0007' Limit 1];


        String opptyItemProduct= '{"AssetReference":\"'+opptyItemKit.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyItemKit.ReliesOnReferenceId__c+'","ProductCode": "Kit","Name": "Kit","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyItemKit.Product2Id+'\"}';
        String opptyItemProduct2= '{"AssetReference":\"'+opptyItemfr.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyItemfr.ReliesOnReferenceId__c+'","ProductCode": "Franquia","Name": "Franquia","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyItemfr.Product2Id+'\"}';
        String opptyItemProduct3= '{"AssetReference":\"'+opptyS1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyS1.ReliesOnReferenceId__c+'","ProductCode": "Mobilidade","Name": "Mobilidade","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyS1.Product2Id+'\"}';
        String opptyItemProduct4= '{"AssetReference":\"'+opptyS2.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyS2.ReliesOnReferenceId__c+'","ProductCode": "Aparelho","Name": "APARELHO","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyS2.Product2Id+'\"}';
        String opptyItemProduct5= '{"AssetReference":\"'+opptyS3.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyS3.ReliesOnReferenceId__c+'","ProductCode": "Passaporte","Name": "Passaporte","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyS3.Product2Id+'\"}';
        String opptyItemProduct6= '{"AssetReference":\"'+opptyA1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyA1.ReliesOnReferenceId__c+'","ProductCode": "Aparelhos","Name": "Aparelhos","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyA1.Product2Id+'\"}';

        String opptyItemProduct7= '{"AssetReference":\"'+opptyB1.vlocity_cmt__AssetReferenceId__c+'\","ReliesOnReference":"'+opptyB1.ReliesOnReferenceId__c+'","ProductCode": "Bônus","Name": "Bônus","EffectiveRecurringTotal": "69.99","MinQuantity": 1,"MaxQuantity": 1,"DefaultQuantity": 1,"ProductId":\"'+opptyB1.Product2Id+'\"}';


        List<Map<String,Object>> opptyProducts= new List<Map<String,Object>>();
        Map<String,Object> prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct);
        opptyProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct2);
        opptyProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct3);
        opptyProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct4);
        opptyProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct5);
        opptyProducts.add(prod);
        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct6);
        opptyProducts.add(prod);

        prod=(Map<String,Object>)JSON.deserializeUntyped(opptyItemProduct7);
        opptyProducts.add(prod);


        System.debug('orderProducts:'+opptyProducts);
        System.debug('order:'+oppty);

        options.put('oppTemplateProducts',opptyProducts);
        options.put('oppTemplateId',oppTemplate.Id);
        options.put('opptyId',oppty.Id);
    
        Test.startTest();
        Boolean retorno = myKitClass.invokeMethod('showKitProducts',inputMap,outMap,options);
        Test.stopTest();
    }

    //METODO 2   
    @isTest static void testgetDependentPicklistValues(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        options.put('fieldname','DDD__c');
        options.put('sObjectName','OpportunityLineItem');
        
        Test.startTest();
            Boolean retorno = myKitClass.invokeMethod('getDependentPicklistValues',inputMap,outMap,options);
        Test.stopTest();
        
    }

    //METODO 3
    @isTest static void testgetPickListValues(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        options.put('fieldname','DDD__c');
        options.put('sObjectName','OpportunityLineItem');

        Test.startTest();
            Boolean retorno = myKitClass.invokeMethod('getPickListValues',inputMap,outMap,options);
        Test.stopTest();
        
    }
    
    //METODO 4a
    @isTest static void testaddKitOpportunity(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        Opportunity oppty = [Select id,Name from Opportunity where not Name like '%KIT%' limit 1];

        OpportunityLineItem opptyItemKit= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0001' Limit 1];
        OpportunityLineItem opptyItemfr= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        OpportunityLineItem opptyS1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0003' Limit 1];
        OpportunityLineItem opptyS2= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0004' Limit 1];
        OpportunityLineItem opptyS3= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0005' Limit 1];
        OpportunityLineItem opptyB1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0007' Limit 1];


        Map<String,Object> kitNode = (Map<String,Object>) JSON.deserializeUntyped('{"Name":"Kit","DisabledBonus":false,"isVisibleAdicionar":true,"DisabledBonusClick":true,"OpptyId":"","ProductCode":"PME_KIT2_0001","Description":"KIT:3plano(s)CLAROTOTALINDIVIDUAL5GB(+2GB)e1aparelho(s)MOTOE6PLUS32GB-Total24xR$199,99/mês","ProductId":"01t2C000001mq4qQAA","Franquias":[{"BonusKit":[{"Quantity":"1","Price":"0.00","AssetReference":"'+opptyB1.vlocity_cmt__AssetReferenceId__c+'","Name":"Bônus"}],"Servicios":[{"Quantity":"1","Price":"0.00","AssetReference":"'+opptyS1.vlocity_cmt__AssetReferenceId__c+'","Name":"Mobilidade"}],"Pasaportes":[{"AssetReference":"'+opptyS3.vlocity_cmt__AssetReferenceId__c+'","Name":"Passaporte","Price":"29.99","ProductId":"01t2C000000tDq4QAE","Quantity":"0","chck":true}],"Aparelhos":[{"Quantity":"1","Price":"480.48","AssetReference":"'+opptyS2.vlocity_cmt__AssetReferenceId__c+'","Name":"Aparelho","AparelhoSelected":false}],"AssetReference":"'+opptyItemfr.vlocity_cmt__AssetReferenceId__c+'","Price":"59.99","Quantity":"1","ProductId":"01t2C000001T0CpQAK","Name":"5GB","Convergencia":false,"TotalPasaporte":0,"TotalAux":"59.99","ServiciosText":"MobilidadeRedesSociais","QuantityEquals":3,"SelectRegional":"NO","SelectUF":"AM","SelectDDD":"92","ArrayUF":["AM","AP","MA","PA","RR"],"ArrayDDD":["92","97"],"SelectTSolicitacao":"Novo","Bonus":"2GB"}],"KitReferenceId":"'+opptyItemKit.vlocity_cmt__AssetReferenceId__c+'","PlanoId":"c0a21e10-a944-4223-a069-1b56e34b1d0f","oppTemplateId":"","orderTemplateId":""}');


        kitNode.put('oppTemplateId',oppTemplate.Id);
        kitNode.put('OrderId',null);
        kitNode.put('OpptyId',oppty.id);
        inputMap.put('ConvertedOrderId',null);
        options.put('KitSelected',kitNode);
        options.put('NumberOfGroupsInTheCart','1');
        
        inputMap.put('Group','1');
        inputMap.put('OrderId',null);
        inputMap.put('OpptyId',oppTemplate.Id);

        Test.startTest();
        Boolean retorno = myKitClass.invokeMethod('addKit',inputMap,outMap,options);
        retorno = myKitClass.invokeMethod('deleteKit',inputMap,outMap,options);
        Test.stopTest();
        
    }

    //METODO 4b
    @isTest static void testaddKitOrder(){
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Order orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        Order order = [Select id,Name from Order where not Name like '%KIT%' limit 1];
                
        OrderItem orderItemKit= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0001' Limit 1];
        OrderItem orderItemfr= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        OrderItem orderS1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0003' Limit 1];
        OrderItem orderS2= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0004' Limit 1];
        OrderItem orderS3= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0005' Limit 1];
        OrderItem orderB1= [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0005' Limit 1];


        Map<String,Object> kitNode = (Map<String,Object>) JSON.deserializeUntyped('{"Name":"Kit","DisabledBonus":false,"isVisibleAdicionar":true,"DisabledBonusClick":true,"OpptyId":"","ProductCode":"PME_KIT2_0001","Description":"KIT:3plano(s)CLAROTOTALINDIVIDUAL5GB(+2GB)e1aparelho(s)MOTOE6PLUS32GB-Total24xR$199,99/mês","ProductId":"01t2C000001mq4qQAA","Franquias":[{"BonusKit":[{"Quantity":"1","Price":"0.00","AssetReference":"'+orderB1.vlocity_cmt__AssetReferenceId__c+'","Name":"Bônus"}],"Servicios":[{"Quantity":"1","Price":"0.00","AssetReference":"'+orderS1.vlocity_cmt__AssetReferenceId__c+'","Name":"Mobilidade"}],"Pasaportes":[{"AssetReference":"'+orderS3.vlocity_cmt__AssetReferenceId__c+'","Name":"Passaporte","Price":"29.99","ProductId":"01t2C000000tDq4QAE","Quantity":"0","chck":true}],"Aparelhos":[{"Quantity":"0","Price":"480.48","AssetReference":"'+orderS2.vlocity_cmt__AssetReferenceId__c+'","Name":"Aparelho","AparelhoSelected":false}],"AssetReference":"'+orderItemfr.vlocity_cmt__AssetReferenceId__c+'","Price":"59.99","Quantity":"1","ProductId":"01t2C000001T0CpQAK","Name":"5GB","Convergencia":false,"TotalPasaporte":0,"TotalAux":"59.99","ServiciosText":"MobilidadeRedesSociais","QuantityEquals":3,"SelectRegional":"NO","SelectUF":"AM","SelectDDD":"92","ArrayUF":["AM","AP","MA","PA","RR"],"ArrayDDD":["92","97"],"SelectTSolicitacao":"Novo","Bonus":"2GB"}],"KitReferenceId":"'+orderItemKit.vlocity_cmt__AssetReferenceId__c+'","PlanoId":"c0a21e10-a944-4223-a069-1b56e34b1d0f","oppTemplateId":"","orderTemplateId":""}');

        kitNode.put('OpptyId',null);
        kitNode.put('orderTemplateId',orderTemplate.Id);
        kitNode.put('OrderId',order.id);
        options.put('KitSelected',kitNode);
        options.put('NumberOfGroupsInTheCart','1');
        
        inputMap.put('Group','1');
        inputMap.put('OrderId',order.id);
        inputMap.put('OpptyId',null);

        Test.startTest();
        Boolean retorno = myKitClass.invokeMethod('addKit',inputMap,outMap,options);
        retorno = myKitClass.invokeMethod('deleteKit',inputMap,outMap,options);
        Test.stopTest();  
    }
 
    @isTest static void testManufacturerOppt() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        options.put('opportunityTemplateId', oppTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getManufacturer', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno das marcas');      
        Test.stopTest();        
    } 

    @isTest static void testModelOppt() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        options.put('opportunityTemplateId', oppTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getModel', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno dos modelos');        
        Test.stopTest();        
    }  
    
	@isTest static void testColorOppt() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        options.put('opportunityTemplateId', oppTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getColor', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno das cores');        
        Test.stopTest();        
    }     

    
	@isTest static void testDeviceOppt() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Opportunity oppTemplate = [Select id,Name from Opportunity where Name like '%KIT%' limit 1];
        OpportunityLineItem opptyItemfr = [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OpportunityLineItem where OpportunityId =:oppTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        
        inputMap.put('opportunityTemplateId', oppTemplate.Id); 
        inputMap.put('assetReference', opptyItemfr.Id);
        inputMap.put('brand', 'LG');  
        inputMap.put('model', 'K8');  
        inputMap.put('color', 'PRETO'); 

        Test.startTest();
        myKitClass.invokeMethod('getDevices', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('devices'), 'Falha no retorno dos aparelhos');        
        Test.stopTest();        
    }     

    @isTest static void testManufacturerOrder() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Order orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        options.put('orderTemplateId', orderTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getManufacturer', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno das marcas');       
        Test.stopTest();        
    }

    @isTest static void testModelOrder() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();


        Order orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        options.put('orderTemplateId', orderTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getModel', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno dos modelos');        
        Test.stopTest();        
    }
    
	@isTest static void testColorOrder() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Order orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        options.put('orderTemplateId', orderTemplate.Id);  

        Test.startTest();
        myKitClass.invokeMethod('getColor', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('values'), 'Falha no retorno das cores');        
        Test.stopTest();        
    }    

    @isTest static void testDeviceOrder() {
        CEC_PME_KitUtils myKitClass = new CEC_PME_KitUtils();

        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Order orderTemplate = [Select id,Name from Order where Name like '%KIT%' limit 1];
        OrderItem orderItemfr = [Select vlocity_cmt__AssetReferenceId__c,Product2Id,  ReliesOnReferenceId__c from OrderItem where OrderId =:orderTemplate.id AND vlocity_cmt__LineNumber__c  = '0002' Limit 1];
        
        inputMap.put('orderTemplateId', orderTemplate.Id);  
        inputMap.put('assetReference', orderItemfr.Id);  
        inputMap.put('brand', 'LG');
        inputMap.put('model', 'K8');  
        inputMap.put('color', 'PRETO');  

        Test.startTest();
        myKitClass.invokeMethod('getDevices', inputMap, outMap, options);
        System.assertNotEquals(null, outMap.get('devices'), 'Falha no retorno dos aparelhos');       
        Test.stopTest();        
    }
       
}