@isTest
private class CEC_Delete_Promotion_Test 
{
    @isTest static void test_method_one() 
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        varAccount.Name = 'Conta Comercial'; 
        insert varAccount;
        
        Id pricebookId = Test.getStandardPricebookId();
       
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
                     
        Product2 varProduct= CEC_SobjectFactory.getProduct(); 
        varProduct.Family = 'TV';
        varProduct.vlocity_cmt__Type__c = 'Plano';
        insert varProduct;
             
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.Type = 'Movel';
        insert varOrder;
        
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        insert varEntryStd;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        insert varEntry;
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.vlocity_cmt__Product2Id__c = varProduct.Id;
        varItem.DescricaoPromocao__c = 'Test product description'; 
        insert varItem;

        vlocity_cmt__OrderPriceAdjustment__c OrderPriceAdjustment = new vlocity_cmt__OrderPriceAdjustment__c();
        OrderPriceAdjustment.vlocity_cmt__OrderId__c = varOrder.Id; 
        OrderPriceAdjustment.vlocity_cmt__OrderItemId__c = varItem.Id; 
        OrderPriceAdjustment.vlocity_cmt__AdjustmentValue__c = 3; 
        insert OrderPriceAdjustment;


        String methodName = 'deletePromotion'; 
        Map<String, Object> inputMap = new Map<String, Object>{'OrderId' => varOrder.Id};
        Map<String, Object> outMap = new Map<String, Object>();
        CEC_Delete_Promotion cecIp = new CEC_Delete_Promotion(); 
        cecIp.invokeMethod(methodName, inputMap, outMap, null); 
    }
}