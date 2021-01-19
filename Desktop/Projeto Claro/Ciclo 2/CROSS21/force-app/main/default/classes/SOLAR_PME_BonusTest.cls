@isTest private class SOLAR_PME_BonusTest {
    @TestSetup
    static void setup(){
        Account acctTest = new Account(Name = 'Test Account 1',BillingCountry='USA',BillingCity='Forest Hills',BillingPostalCode='11375',BillingStreet='110-35 72nd Rd',BillingState='NY',Fax = '1',Industry = 'Agriculture');
        insert acctTest;

        Product2 product2 = new Product2(vlocity_cmt__Type__c  = 'Individual', 
        Name = 'Individual',
        ProductCode = 'Individual',
        Description='Individual',isActive = true);
        insert product2;        
        
        Product2 product3 = new Product2(vlocity_cmt__Type__c  = 'Franquia', 
                                            Name = 'Franquia001',
                                            ProductCode = 'Franquia001',IsActive = true);
        insert product3;

        Product2 product4 = new Product2(vlocity_cmt__Type__c  = 'Bonus', 
                                            Name = 'Bonus001',
                                            ProductCode = 'PME_Bonus_5GB',IsActive = true,
                                            vlocity_cmt__JSONAttribute__c = '{ "ATT_CAT_FRANQ":[ { "attributeRunTimeInfo":{ "uiDisplayType":"Text", "dataType":"Text" }, "attributedisplayname__c":"Validade Bonus", "attributeuniquecode__c":"ATT_PME_BonusValidity" } ] }');
        insert product4; 
        
        Product2 product5 = new Product2(vlocity_cmt__Type__c  = 'Bonus', 
                                            Name = 'Bonus002',
                                            ProductCode = 'PME_BONUS_EXTRA_5GB',IsActive = true,
                                            vlocity_cmt__JSONAttribute__c = '{ "ATT_CAT_FRANQ":[ { "attributeRunTimeInfo":{ "uiDisplayType":"Text", "dataType":"Text" }, "attributedisplayname__c":"Validade Bonus", "attributeuniquecode__c":"ATT_PME_BonusValidity" } ] }');
        insert product5;         
        
        /**/
        Id priceBookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = priceBookId, Product2Id = product2.Id,
        UnitPrice = 0, IsActive = true);
        insert standardPrice;

        PricebookEntry standardPrice3 = new PricebookEntry(
        Pricebook2Id = priceBookId, Product2Id = product3.Id,
        UnitPrice = 0, IsActive = true);
        insert standardPrice3;   
        
        PricebookEntry standardPrice4 = new PricebookEntry(
        Pricebook2Id = priceBookId, Product2Id = product4.Id,
        UnitPrice = 0, IsActive = true);
        insert standardPrice4;  
        
        PricebookEntry standardPrice5 = new PricebookEntry(
        Pricebook2Id = priceBookId, Product2Id = product5.Id,
        UnitPrice = 0, IsActive = true);
        insert standardPrice5;   
        
        /**/
        Order order = new Order(Name='Test Order',AccountId=acctTest.id,EffectiveDate=SYSTEM.TODAY(), Status='Em Andamento', Pricebook2Id=Test.getStandardPricebookId());
        insert order;

		OrderItem plano = new OrderItem();
        plano.product2Id=product2.id;
        plano.vlocity_cmt__product2id__c=product2.id;
        plano.orderId=order.id;
        plano.unitPrice=10;
        plano.PricebookEntryId = standardPrice.id;
        plano.quantity=1;
        plano.vlocity_cmt__LineNumber__c  = '0001';
        plano.vlocity_cmt__ItemName__c='Plano';
        plano.vlocity_cmt__EffectiveQuantity__c=1;
        insert plano;
        plano.vlocity_cmt__AssetReferenceId__c=plano.id;
        plano.ReliesOnReferenceId__c=plano.id;
        update plano;

        OrderItem franquia = new OrderItem();
        franquia.orderid=order.id;
        franquia.ReliesOnReferenceId__c=plano.id;
        franquia.product2id=product3.id;
        franquia.vlocity_cmt__product2id__c=product3.id;
        franquia.unitPrice=10;
        franquia.PricebookEntryId = standardPrice.id;
        franquia.quantity=1;
        franquia.vlocity_cmt__EffectiveQuantity__c=1;
        franquia.vlocity_cmt__LineNumber__c  = '0002';

        insert franquia;
        franquia.vlocity_cmt__AssetReferenceId__c=franquia.id;
        franquia.ReliesOnReferenceId__c=plano.id;
        update franquia; 
        
		/**/
        Opportunity oppt = new Opportunity(Name='Test Oppt',AccountId=acctTest.id, StageName='Em andamento', CloseDate=SYSTEM.TODAY()+30, Pricebook2Id=Test.getStandardPricebookId());
        insert oppt;

		OpportunityLineItem planoOppt = new OpportunityLineItem();
        planoOppt.product2Id=product2.id;
        planoOppt.vlocity_cmt__product2id__c=product2.id;
        planoOppt.OpportunityId=oppt.id;
        planoOppt.unitPrice=10;
        planoOppt.PricebookEntryId = standardPrice.id;
        planoOppt.quantity=1;
        planoOppt.vlocity_cmt__LineNumber__c  = '0001';
        planoOppt.vlocity_cmt__ItemName__c='Plano';
        planoOppt.vlocity_cmt__EffectiveQuantity__c=1;
        insert planoOppt;
        planoOppt.vlocity_cmt__AssetReferenceId__c=planoOppt.id;
        planoOppt.ReliesOnReferenceId__c=planoOppt.id;
        update planoOppt;

        OpportunityLineItem franquiaOppt = new OpportunityLineItem();
        franquiaOppt.OpportunityId=oppt.id;
        franquiaOppt.ReliesOnReferenceId__c=planoOppt.id;
        franquiaOppt.product2id=product3.id;
        franquiaOppt.vlocity_cmt__product2id__c=product3.id;
        franquiaOppt.unitPrice=10;
        franquiaOppt.PricebookEntryId = standardPrice.id;
        franquiaOppt.quantity=1;
        franquiaOppt.vlocity_cmt__EffectiveQuantity__c=1;
        franquiaOppt.vlocity_cmt__LineNumber__c  = '0002';

        insert franquiaOppt;
        franquiaOppt.vlocity_cmt__AssetReferenceId__c=franquiaOppt.id;
        franquiaOppt.ReliesOnReferenceId__c=planoOppt.id;
        update franquiaOppt;        
        
        /**/
        vlocity_cmt__CalculationMatrix__c calcMatrix = new vlocity_cmt__CalculationMatrix__c();
        calcMatrix.Name = 'PME_Bonus_Validity';
        insert calcMatrix; 
        
        vlocity_cmt__CalculationMatrixVersion__c calcVersion = new vlocity_cmt__CalculationMatrixVersion__c();
        calcVersion.vlocity_cmt__CalculationMatrixId__c = calcMatrix.Id;
        calcVersion.vlocity_cmt__IsEnabled__c = true;
        calcVersion.vlocity_cmt__Priority__c = 1;
        insert calcVersion;
    }
    
    @isTest static void addBonusOrderTest(){
        Boolean retorno;
        SOLAR_PME_Bonus bonus = new SOLAR_PME_Bonus();
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        //Map<String,Object> inputMapOppt = new Map<String,Object>();
       
        Product2 bonus1 = [SELECT Id FROM Product2 WHERE Name = 'Bonus001'];
        Product2 bonus2 = [SELECT Id FROM Product2 WHERE Name = 'Bonus002'];
        
        Id cartId = [SELECT Id FROM Order WHERE Name = 'Test Order'].Id;
        //Id cartIdOppt = [SELECT Id FROM Opportunity WHERE Name = 'Test Oppt'].Id;        
        
        OrderItem franquia = [SELECT Id FROM OrderItem WHERE vlocity_cmt__LineNumber__c  = '0002'];
        //OpportunityLineItem franquiaOppt = [SELECT Id FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c  = '0002'];        
        
        inputMap = (Map<String,Object>) JSON.deserializeUntyped('{ "SelItem":{ "Product2":{ "ProductCode":"PME_Franquia5GBIndividual_0001" } }, "PesquisadeCliente":{ "PME_FirstStep_Choise":"CreateOrder" }, "fieldsToUpdate":{ "TypeOfRequest__c":"Novo" }, "ContextCartId":"'+cartId+'", "Bonus":[ { "ProductSubType":"None", "ProductId":"'+bonus1.Id+'", "ProductCode":"PME_Bonus_5GB", "Name":"Bonus 5 GB", "Bonus":"5GB" }, {  "ProductSubType":"Extra", "ProductId":"'+bonus2.Id+'", "ProductCode":"PME_BONUS_EXTRA_5GB", "Name":"Bonus Extra 5GB", "Bonus":"5GB" } ],   "TemplateActions_CloneFromTemplate" : {"FranquiaAssetReferenceId__c" : "'+franquia.Id+'"} }');        
        //inputMapOppt = (Map<String,Object>) JSON.deserializeUntyped('{ "SelItem":{ "Product2":{ "ProductCode":"PME_Franquia5GBIndividual_0001" } }, "PesquisadeCliente":{ "PME_FirstStep_Choise":"CreateOpportunity" }, "fieldsToUpdate":{ "TypeOfRequest__c":"Novo" }, "ContextCartId":"'+cartIdOppt+'", "Bonus":[ { "ProductSubType":"None", "ProductId":"'+bonus1.Id+'", "ProductCode":"PME_Bonus_5GB", "Name":"Bonus 5 GB", "Bonus":"5GB" }, {  "ProductSubType":"Extra", "ProductId":"'+bonus2.Id+'", "ProductCode":"PME_BONUS_EXTRA_5GB", "Name":"Bonus Extra 5GB", "Bonus":"5GB" } ],   "TemplateActions_CloneFromTemplate" : {"FranquiaAssetReferenceId__c" : "'+franquiaOppt.Id+'"} }');        
                                                                
        Test.startTest();
        retorno = bonus.invokeMethod('addBonus', inputMap, outMap, options);
        //retorno = bonus.invokeMethod('addBonus', inputMapOppt, outMap, options);
        Test.stopTest();
    }
    
 @isTest static void addBonusOpptTest(){
        Boolean retorno;
     
        SOLAR_PME_Bonus bonus = new SOLAR_PME_Bonus();
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        //Map<String,Object> inputMapOppt = new Map<String,Object>();
       
        Product2 bonus1 = [SELECT Id FROM Product2 WHERE Name = 'Bonus001'];
        Product2 bonus2 = [SELECT Id FROM Product2 WHERE Name = 'Bonus002'];
        
        //Id cartId = [SELECT Id FROM Order WHERE Name = 'Test Order'].Id;
        Id cartIdOppt = [SELECT Id FROM Opportunity WHERE Name = 'Test Oppt'].Id;        
        
        //OrderItem franquia = [SELECT Id FROM OrderItem WHERE vlocity_cmt__LineNumber__c  = '0002'];
        OpportunityLineItem franquiaOppt = [SELECT Id FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c  = '0002'];        
        
        //inputMap = (Map<String,Object>) JSON.deserializeUntyped('{ "SelItem":{ "Product2":{ "ProductCode":"PME_Franquia5GBIndividual_0001" } }, "PesquisadeCliente":{ "PME_FirstStep_Choise":"CreateOrder" }, "fieldsToUpdate":{ "TypeOfRequest__c":"Novo" }, "ContextCartId":"'+cartId+'", "Bonus":[ { "ProductSubType":"None", "ProductId":"'+bonus1.Id+'", "ProductCode":"PME_Bonus_5GB", "Name":"Bonus 5 GB", "Bonus":"5GB" }, {  "ProductSubType":"Extra", "ProductId":"'+bonus2.Id+'", "ProductCode":"PME_BONUS_EXTRA_5GB", "Name":"Bonus Extra 5GB", "Bonus":"5GB" } ],   "TemplateActions_CloneFromTemplate" : {"FranquiaAssetReferenceId__c" : "'+franquia.Id+'"} }');        
        inputMap = (Map<String,Object>) JSON.deserializeUntyped('{ "SelItem":{ "Product2":{ "ProductCode":"PME_Franquia5GBIndividual_0001" } }, "PesquisadeCliente":{ "PME_FirstStep_Choise":"CreateOpportunity" }, "fieldsToUpdate":{ "TypeOfRequest__c":"Novo" }, "ContextCartId":"'+cartIdOppt+'", "Bonus":[ { "ProductSubType":"None", "ProductId":"'+bonus1.Id+'", "ProductCode":"PME_Bonus_5GB", "Name":"Bonus 5 GB", "Bonus":"5GB" }, {  "ProductSubType":"Extra", "ProductId":"'+bonus2.Id+'", "ProductCode":"PME_BONUS_EXTRA_5GB", "Name":"Bonus Extra 5GB", "Bonus":"5GB" } ],   "TemplateActions_CloneFromTemplate" : {"FranquiaAssetReferenceId__c" : "'+franquiaOppt.Id+'"} }');        
                                                                
        Test.startTest();
        retorno = bonus.invokeMethod('addBonus', inputMap, outMap, options);
        Test.stopTest();
    }    
}