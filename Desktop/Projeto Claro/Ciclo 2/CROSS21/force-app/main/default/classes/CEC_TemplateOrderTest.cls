/*
* Autor: Henrique Almeida
* Data: 29-mar-2018
* Descrição: Classe responsável por testar a CEC_TemplateOrderTest
*/
@isTest
public class CEC_TemplateOrderTest {

    @testSetup
    public static void testSetup() {
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        
        insert new MetodoPagamento__c(Name = 'Boleto', Preco__c = 10, Sub_Type__c = 'Pós-Plano', Forma_de_Pagamento__c = 'Boleto');
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
        
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        varProduct.vlocity_cmt__SubType__c = 'Pós-Plano';
        varProduct.vlocity_cmt__Type__c = 'Plano';
        varProduct.Family = 'Internet';
        insert varProduct;
        
        
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.Internet_Grupo__c = 'G1';
        varOrder.Cart_State__c = 'INDIVIDUAL';
        varOrder.Forma_de_Pagamento__c = 'Boleto';
        insert varOrder;
              
      
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        insert varEntryStd;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        insert varEntry;
        
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.vlocity_cmt__Product2Id__c = varItem.Product2Id;
        varItem.vlocity_cmt__AssetReferenceId__c = varItem.Product2Id;
        varItem.vlocity_cmt__LineNumber__c = '0001';
        varItem.TemplateDefaultQty__c  = '1';
        insert varItem;
         
        varItem.ReliesOnReferenceId__c = varItem.Id;
        update varItem;
        
        
        Pricing_Matrix__c promotion = new Pricing_Matrix__c();
        promotion.Cart_State__c = varOrder.Cart_State__c;
        promotion.Target_Product__c = varProduct.Id;
        promotion.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        promotion.Group__c = 'G1';
        promotion.Single__c = 35.99;
        promotion.Promotion__c = '30 R$';
        promotion.Double__c = 30.99;
        promotion.Triple__c = 25.90;
        promotion.Combo_Multi__c = 0;
        promotion.Description__c = 'Durante 3 meses';
        promotion.Internet__c = varProduct.Id;
        insert promotion;
        
        
        Pricing_Matrix__c matrix = new Pricing_Matrix__c();
        matrix.DDD__c = '-';
        matrix.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Pricing').getRecordTypeId();
        matrix.Duration__c = 0;
        matrix.Group__c = 'G1';
        matrix.Source_Product__c = varProduct.Id;
        matrix.Single__c = 35.99;
        matrix.Promotion__c = '30 R$';
        matrix.Double__c = 30.99;
        matrix.Triple__c = 25.90;
        matrix.Combo_Multi__c = 0;
        
        insert matrix;
    }

 
    @isTest 
    static void testSetOptProducts() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem> orderItemList = [SELECT Id, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c FROM OrderItem WHERE OrderId = :lstOrder[0].Id];
        
        lInputMap.put('TemplateId', lstOrder[0].Id);
        lInputMap.put('planName', 'TESTECLASS');
        lInputMap.put('ReliesOnReferenceId', orderItemList[0].ReliesOnReferenceId__c);
        lInputMap.put('ExistingId', lstOrder[0].Id);
        
        Test.startTest();
        CEC_TemplateOrder controller = new CEC_TemplateOrder();
        
        controller.invokeMethod('CloneFromTemplate', lInputMap, lOutMap, lOptions); 
        system.assertEquals(2, [SELECT count() FROM OrderItem WHERE OrderId = :lstOrder[0].Id]);
        Test.stopTest();            
    }
    @isTest 
    static void testSetOptProducts2() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem> orderItemList = [SELECT Id, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c FROM OrderItem WHERE OrderId = :lstOrder[0].Id];
        
        lInputMap.put('TemplateName', 'Order');
        lInputMap.put('planName', 'TESTECLASS');
        lInputMap.put('ReliesOnReferenceId', orderItemList[0].ReliesOnReferenceId__c);
        lInputMap.put('ExistingId', lstOrder[0].Id);
        
        Test.startTest();
        CEC_TemplateOrder controller = new CEC_TemplateOrder();
        
        controller.invokeMethod('CloneFromTemplate', lInputMap, lOutMap, lOptions); 
        system.assertEquals(1, [SELECT count() FROM OrderItem WHERE OrderId = :lstOrder[0].Id]);
        Test.stopTest();            
    }

    
}