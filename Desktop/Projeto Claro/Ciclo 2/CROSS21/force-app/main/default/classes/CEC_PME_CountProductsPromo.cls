/*
* Autor: Argenis Cortez - Aconcagua Team
* Data: 25/10/2019
* Descrição: Classe de regras de negócio do objeto Bonus__c
*/
global with sharing class CEC_PME_CountProductsPromo implements vlocity_cmt.VlocityOpenInterface {
    public class CountProductsPromoException extends Exception {}
    
    private Map<String, Object> input;
    private Map<String, Object> output;
    private Map<String, Object> options;
    
    /*
    * Autor: Argenis Cortez - Aconcagua Team
    * Data: 25/10/2019
    * Descrição: Método abstrato da interface de Vlocity
    */
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Boolean result = true;
        try {
            System.debug('methodName: ' + JSON.serialize(methodName));
            System.debug('input: ' + JSON.serialize(input));
            System.debug('options: ' + JSON.serialize(options));
            
            this.input = input;
            this.output = output;
            this.options = options;
            
            switch on methodName {
                when 'getCount' {
                    this.setPromotionFields();
                } when 'updateDiscountField' {
                    this.updateDiscountField();
                } when 'getTradeInDuration' {
                    this.getTradeInDuration();
                }
            }
            
            System.debug('output: ' + JSON.serialize(output));
        } catch (Exception ex) {
            result = false;
        }
        
        return result;
    }
    
    private void setPromotionFields() {
        Map<String, Decimal> mapItemDiscount = new Map<String, Decimal>();
        List<SObject> listItems = getListItems();
        
        List<Pricing_Matrix__c> listPricingMatrices = getListPricingMatrices();
        
        Integer totalLines = getTotalLines(listItems);
        
        Map<String, Integer> mapDDDTotalLines = getMapDDDTotalLines(listItems);
        
        Pricing_Matrix__c pricingMatrixProg = getPricingMatrixProgressive(listPricingMatrices, totalLines);
        
        if(pricingMatrixProg == null) {
            Boolean isPromo = false;
            Integer limitPromo;
            String promotionDescription = '';
            String promotionPrice = '';
            String totalProductsDDD = '';
            
            Map<String, Pricing_Matrix__c> mapDDDPricingMatrix = new Map<String, Pricing_Matrix__c>();
            for(String subgroupDDD : mapDDDTotalLines.keySet()) {
                Pricing_Matrix__c pricingMatrixProgDDD = getPricingMatrixProgressiveDDD(listPricingMatrices, subgroupDDD, mapDDDTotalLines.get(subgroupDDD));
                if(pricingMatrixProgDDD != null) {
                    mapDDDPricingMatrix.put(subgroupDDD, pricingMatrixProgDDD);
                    
                    isPromo |= pricingMatrixProgDDD.From_Quantity__c != null && pricingMatrixProgDDD.From_Quantity__c > 0;
                    totalProductsDDD = subgroupDDD + ';' + totalProductsDDD;
                }
            }
            
            totalProductsDDD = totalProductsDDD.substring(0, totalProductsDDD.length() - 1);
            
            for(sObject item : listItems) {
                Pricing_Matrix__c pricingMatrixProgDDD = mapDDDPricingMatrix.get((String)item.get('Subgroup__c'));
                
                if(pricingMatrixProgDDD != null) {
                    Integer currentLimit = Integer.valueOf(pricingMatrixProgDDD.From_Quantity__c);
                    
                    if(limitPromo == null || limitPromo > currentLimit) {
                        limitPromo = currentLimit;
                    }
                    
                    promotionDescription = String.valueOf(pricingMatrixProgDDD.Promotion__c);
                    promotionPrice = String.valueOf(pricingMatrixProgDDD.price__c);
                    mapItemDiscount.put((String) item.get('Id'), pricingMatrixProgDDD.price__c);
                }
            }
            
            output.put('isPromo', isPromo);
            output.put('totalProducts', totalProductsDDD);
            output.put('limitPromo', limitPromo);
            output.put('PromotionDescription', promotionDescription);
            output.put('PromotionPrice', mapItemDiscount);
        } else {
            for(sObject item : listItems) {
                mapItemDiscount.put((String) item.get('Id'), pricingMatrixProg.price__c);
            }
            
            output.put('isPromo', pricingMatrixProg.From_Quantity__c != null && pricingMatrixProg.From_Quantity__c > 0);
            output.put('limitPromo', Integer.valueOf(pricingMatrixProg.From_Quantity__c));
            output.put('PromotionDescription', pricingMatrixProg.Promotion__c);
            output.put('PromotionPrice', mapItemDiscount);
        }
        
    }
    
    private List<SObject> getListItems() {
        String orderId = String.valueOf(options.get('OrderID'));
        String opportunityId = String.valueOf(options.get ('OpptyId'));
        
        List<SObject> listItems = new List<SObject>();
        
        if(String.isNotBlank(orderId)) {
            listItems.addAll(getListOrderItems(orderId));
        } else if(String.isNotBlank(opportunityId)) {
            listItems.addAll(getListOpportunityLineItems(opportunityId));
        } else {
            throw new CountProductsPromoException('O campo OrderID ou OpptyId deve estar preenchido');
        }
        
        return listItems;
    }
    
    private List<OrderItem> getListOrderItems(Id orderId) {
        return [SELECT Id, 
                Quantity, 
                Subgroup__c, 
                Product2Id
                FROM OrderItem 
                WHERE OrderId = :orderId
                AND vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c = 'Franquia'];
    }
    
    private List<OpportunityLineItem> getListOpportunityLineItems(Id opportunityId) {
        return [SELECT Id, 
                Quantity, 
                Subgroup__c, 
                Product2Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
                AND vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c = 'Franquia'];
    }
    
    private List<Pricing_Matrix__c> getListPricingMatrices() {
        String promotionChannel = String.valueOf(options.get('User'));
        String promotionType = String.valueOf(options.get('PromotionType'));
        
        return [SELECT Id, 
                promotion__c, 
                price__c,
                From_Quantity__c, 
                To_Quantity__c,
                DDD__c
                FROM Pricing_Matrix__c 
                WHERE Active__c = true
                AND Business_Unit__c = 'PME'
                AND End_Date__c >= TODAY 
                AND Start_Date__c <= TODAY
                AND (Promotion_Channel__c = :promotionChannel 
                     OR Promotion_Channel__c = null)
                AND Promotion_Type__c = :promotionType
                AND RecordType.Name = 'Promotion'];
    }
    
    private Integer getTotalLines(List<SObject> listItems) {
        Integer total = 0;
        for(SObject item : listItems) {
            total += Integer.valueOf(item.get('Quantity'));
        }
        
        return total;
    }
    
    private Map<String, Integer> getMapDDDTotalLines(List<SObject> listItems) {
        Map<String, Integer> mapDDDTotalLines = new Map<String, Integer>();
        
        for(SObject item : listItems) {
            Integer quantity = Integer.valueOf(item.get('Quantity'));
            String subgroupDDD = String.valueOf(item.get('Subgroup__c'));
            
            if(String.isNotEmpty(subgroupDDD) && quantity != 0) {
                if(mapDDDTotalLines.containsKey(subgroupDDD)) {
                    Integer totalLineDDD = mapDDDTotalLines.get(subgroupDDD);
                    totalLineDDD += quantity;
                    mapDDDTotalLines.put(subgroupDDD, totalLineDDD);
                } else {
                    mapDDDTotalLines.put(subgroupDDD, quantity);
                }
            }
        }
        
        return mapDDDTotalLines;
    }
    
    private Pricing_Matrix__c getPricingMatrixProgressive(List<Pricing_Matrix__c> listPricingMatrices, Integer totalLines) {
        
        for(Pricing_Matrix__c pricingMatrix : listPricingMatrices) {
            Boolean isMatrixNotDDD = String.isBlank(pricingMatrix.DDD__c);
            Boolean isTotalWithinLimits = pricingMatrix.From_Quantity__c <= totalLines && totalLines <= pricingMatrix.To_Quantity__c;
            
            if(isMatrixNotDDD && isTotalWithinLimits) {
                return pricingMatrix;
            }
        }
        
        return null;
    }
    
    private Pricing_Matrix__c getPricingMatrixProgressiveDDD(List<Pricing_Matrix__c> listPricingMatrices, String subgroupDDD, Integer total) {
        
        for(Pricing_Matrix__c pricingMatrix : listPricingMatrices) {
            Boolean isMatrixDDD = String.isNotBlank(pricingMatrix.DDD__c);
            
            if(isMatrixDDD) {
                Set<String> setDDDs = new Set<String>();
                setDDDs.addAll(pricingMatrix.DDD__c.split(';'));
                
                Boolean isDDDOnMatrix = setDDDs.contains(subgroupDDD);
                Boolean isTotalWithinLimits = pricingMatrix.From_Quantity__c <= total && total <= pricingMatrix.To_Quantity__c;
                
                if(isDDDOnMatrix && isTotalWithinLimits) {
                    return pricingMatrix;
                }
            }
        }
        
        return null;
    }
    
    private void updateDiscountField() {
        try {
            String totalProductsDDD = String.valueOf(options.get('TotalProducts'));
            Integer totalProducts = 0;
            Decimal totalDiscount = 0;
            String orderId = String.valueOf(options.get('OrderId'));
            String oppId = String.valueOf(options.get ('OpptyId'));
            String action = String.valueOf(options.get('Action'));
            Integer modification = 1;

            Map<String, Object> mapItemDiscount = (Map<String, Object>) options.get('PromotionPrice');
            
            if(!action.equalsIgnoreCase('Add')) {
                action = 'Add';
                modification = 0;
                removeDiscount();
            } else {
                action = 'Remove';
                
                Boolean isMapNotEmpty = mapItemDiscount != null && !mapItemDiscount.isEmpty();
                
                if(!String.isEmpty(orderId) && isMapNotEmpty) {
                    List<OrderItem> orderItemsUpdate = new List<OrderItem>();
                    
                    List<OrderItem> orderItems = [SELECT Id,
                                                  vlocity_cmt__RecurringDiscountPrice__c,
                                                  Quantity,
                                                  Subgroup__c
                                                  FROM OrderItem 
                                                  WHERE Id IN :mapItemDiscount.keySet()];
                    
                    for(OrderItem item : orderItems) {
                        Boolean isNotNull = item.Quantity != null && mapItemDiscount.get(item.Id) != null;
                        if(isNotNull) {
                            Decimal discount = (Decimal) mapItemDiscount.get(item.Id);
                            item.vlocity_cmt__RecurringDiscountPrice__c = discount;
                            orderItemsUpdate.add(item);
                            totalDiscount += discount;
                        }
                    }
                    update orderItemsUpdate;
                }
                
                if(!String.isEmpty(oppId) && isMapNotEmpty) {
                    List<OpportunityLineItem> oppyItemsUpdate = new List<OpportunityLineItem>();
                    
                    List<OpportunityLineItem> oppyItems = [SELECT Id,
                                                           vlocity_cmt__RecurringDiscountPrice__c,
                                                           Quantity, 
                                                           Subgroup__c
                                                           FROM OpportunityLineItem 
                                                           WHERE Id IN :mapItemDiscount.keySet()];
                    
                    for(OpportunityLineItem item : oppyItems) {
                        Boolean isNotNull = item.Quantity != null && mapItemDiscount.get(item.Id) != null;
                        if(isNotNull) {
                            Decimal discount = (Decimal) mapItemDiscount.get(item.Id);
                            item.vlocity_cmt__RecurringDiscountPrice__c = discount;
                            oppyItemsUpdate.add(item);
                            totalDiscount += discount * item.Quantity;
                        }
                    }
                    update oppyItemsUpdate;
                }
                
                output.put('TotalDescuento',totalDiscount);
                output.put('Action',action);
            }
        } catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private void removeDiscount() {
        String orderId = (String) options.get('OrderId');
        String opportunityId = (String) options.get('OpptyId');
        
        List<SObject> listItems = new List<SObject>();
        
        if(String.isNotBlank(orderId)) {
            listItems = [SELECT Id,
                         vlocity_cmt__RecurringDiscountPrice__c
                         FROM OrderItem 
                         WHERE OrderId =:orderId
                         AND vlocity_cmt__RecurringDiscountPrice__c != 0
                         AND vlocity_cmt__RecurringDiscountPrice__c != null];
        } else if(String.isNotBlank(opportunityId)) {
            listItems = [SELECT Id,
                         vlocity_cmt__RecurringDiscountPrice__c
                         FROM OpportunityLineItem 
                         WHERE OpportunityId = :opportunityId
                         AND vlocity_cmt__RecurringDiscountPrice__c != 0
                         AND vlocity_cmt__RecurringDiscountPrice__c != null];
        }
        
        for(SObject item : listItems) {
            item.put('vlocity_cmt__RecurringDiscountPrice__c', null);
        }
        
        if(!listItems.isEmpty()) {
            update listItems;
        }
    }
    
    private void getTradeInDuration() {
        try {
            String promotionType = String.valueOf(options.get('PromotionType'));
            if(!promotionType.equalsIgnoreCase('Não')) {
                String value = promotionType.subString(0,1);
                output.put('TradeInDuration',Integer.valueOf(value));
            }
            
        } catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
}