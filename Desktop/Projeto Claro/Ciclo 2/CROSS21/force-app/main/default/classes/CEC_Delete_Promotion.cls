global with sharing class CEC_Delete_Promotion implements vlocity_cmt.VlocityOpenInterface 
{
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) 
    {
        if (methodName == 'deletePromotion') 
        {
            deletePromotion(inputMap, outMap, options);
        }
        if (methodName == 'deleteAdjustments') 
        {
            deleteAdjustments(inputMap, outMap, options);
        }
        return true;
    }
    
    private Map<String, Object> deletePromotion(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) 
    {
        try
        {
            String orderId = (String) inputMap.get('OrderId');
            Sobject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
            if(parent != null)
            {
                orderId = (String)parent.get('Id');
            }
            
            List<vlocity_cmt__OrderPriceAdjustment__c> OrderPriceAdjustmentList = new List<vlocity_cmt__OrderPriceAdjustment__c>(); 
            List<OrderItem> orderItemListUpdate = new List<OrderItem>(); 
            List<OrderItem> orderItemList = [Select 
                                             Id, DescricaoPromocao__c, 
                                             (Select Id from vlocity_cmt__OrderPricingAdjustments__r)
                                             from   OrderItem 
                                             where   OrderId =: orderId ]; 
            
            for(OrderItem orderItem : orderItemList)
            {
                //orderItem.DescricaoPromocao__c = null;
                //orderItem.Promotion_Log__c = null;
                orderItemListUpdate.add(orderItem); 
                for(vlocity_cmt__OrderPriceAdjustment__c OrderPriceAdjustmentId : orderItem.vlocity_cmt__OrderPricingAdjustments__r)
                {
                    vlocity_cmt__OrderPriceAdjustment__c OrderPriceAdjustment = new vlocity_cmt__OrderPriceAdjustment__c(Id=OrderPriceAdjustmentId.Id);
                    OrderPriceAdjustmentList.add(OrderPriceAdjustment);    
                }
            }      
            
            system.debug('delete.orderItemListUpdate: '+orderItemListUpdate);
            system.debug('delete.OrderPriceAdjustmentList: '+OrderPriceAdjustmentList);

            //update orderItemListUpdate; 
            delete OrderPriceAdjustmentList; 
        }
        catch(Exception e)
        {
            System.debug('The following exception has occured : ' + e.getMessage() + ' -- at line : ' + e.getLineNumber()); 
        }
        return outMap;     
    }
    private Map<String, Object> deleteAdjustments(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) 
    {
        try
        {
            system.debug('DELETE_INPUT: '+inputMap);
            List<vlocity_cmt__OrderPriceAdjustment__c> OrderPriceAdjustmentList = new List<vlocity_cmt__OrderPriceAdjustment__c>();
            
            
            List<OrderItem> orderItemList = (List<OrderItem>) inputMap.get('items');
            system.debug('DELETE_orderItemList: '+orderItemList);
            for(OrderItem orderItem : orderItemList)
            {
                for(vlocity_cmt__OrderPriceAdjustment__c OrderPriceAdjustmentId : orderItem.vlocity_cmt__OrderPricingAdjustments__r)
                {
                    vlocity_cmt__OrderPriceAdjustment__c OrderPriceAdjustment = new vlocity_cmt__OrderPriceAdjustment__c(Id=OrderPriceAdjustmentId.Id);
                    OrderPriceAdjustmentList.add(OrderPriceAdjustment);    
                }
            }
            system.debug('OrderPriceAdjustmentList: '+OrderPriceAdjustmentList);
            delete OrderPriceAdjustmentList; 
        }
        catch(Exception e)
        {
            System.debug('The following exception has occured : ' + e.getMessage() + ' -- at line : ' + e.getLineNumber()); 
        }
        return outMap;     
    }
}