global class SOLAR_PME_Bonus implements vlocity_cmt.VlocityOpenInterface {
    private Map<String, Object> input;
    private Map<String, Object> output;
    private Map<String, Object> options;
    
    private map<Id, String> mapJSONAttr;
    private map<String, Id> mapPrice;
    private List<vlocity_cmt__CalculationMatrixRow__c> lstMatrixRow;
    
	global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
    	try {
            System.debug('input: ' + JSON.serialize(input));
            System.debug('output: ' + JSON.serialize(output));
            System.debug('options: ' + JSON.serialize(options));
            
            this.input = input;
            this.output = output;
            this.options = options;
            
            switch on methodName {
                when 'addBonus' {
                    this.addBonus(input, output,options);
                }
            }
        } catch (Exception ex) {
        	throw ex;
        }
        
        return true;
    }    
    
	private void addBonus(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
		List<Object> listBonus;
        Map<String, Object> mapBonus;        
        
        try { 
			System.debug('########## START SOLAR_PME_Bonus.addBonus');            
            
            Map<String, Object> mapPesquisadeCliente = (Map<String, Object>) input.get('PesquisadeCliente');
            String firstStep = (String) mapPesquisadeCliente.get('PME_FirstStep_Choise');            
                        
            try {
				listBonus = (List<Object>) input.get('Bonus');                
            } catch(Exception ex) {
            	mapBonus = (Map<String, Object>) input.get('Bonus');  
                listBonus = new List<Object>();
                listBonus.add(mapBonus);
            }
            
            builderMaps(listBonus);
            
            if (firstStep == 'CreateOrder') {
            	builderBonusOrder(listBonus);  
            } else {
            	builderBonusOppt(listBonus);    
            }
            
			System.debug('########## END SOLAR_PME_Bonus.addBonus');                        
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    }          

	private void builderBonusOrder(List<Object> listBonus) {
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        OrderItem item;
        
        try { 
			System.debug('########## START SOLAR_PME_Bonus.builderBonusOrder');                                    
            
            String cartId = (String) this.input.get('ContextCartId');  

            Map<String, Object> mapRelies = (Map<String, Object>) this.input.get('TemplateActions_CloneFromTemplate');
            String franquiaId = (String) mapRelies.get('FranquiaAssetReferenceId__c'); 
            
            Map<String, Object> mapFieldsToUpdate = (Map<String, Object>) this.input.get('fieldsToUpdate');
            String typeOfRequest = (String) mapFieldsToUpdate.get('TypeOfRequest__c'); 
            
            Map<String, Object> mapSelItem = (Map<String, Object>) this.input.get('SelItem');
            Map<String, Object> mapSelProd = (Map<String, Object>) mapSelItem.get('Product2');
            String franquiaCode = (String) mapSelProd.get('ProductCode'); 
            
            for (Object obj : listBonus) {
                Map<String, Object> mapBonus = (Map<String, Object>) obj;
                Id productId = (Id) mapBonus.get('ProductId');
                String productCode = (String) mapBonus.get('ProductCode');
                String productSubType = (String) mapBonus.get('ProductSubType');

            	item = new OrderItem();
                item.Product2Id = productId;
                item.vlocity_cmt__Product2Id__c = productId;
                item.OrderId = cartId;
                item.TypeOfRequest__c = typeOfRequest;
                item.vlocity_cmt__LineNumber__c = '0100';
                //item.Discount = 0;
                item.vlocity_cmt__RecurringTotal__c = 0;
                item.vlocity_cmt__RecurringCharge__c = 0;
                item.vlocity_cmt__RecurringCalculatedPrice__c = 0;
                item.vlocity_cmt__EffectiveRecurringTotal__c = 0;
				item.vlocity_cmt__OneTimeLoyaltyPrice__c = 0;
                item.ListPrice = 0;
                item.UnitPrice = 0;
                //item.Subtotal = 0;
                item.PricebookEntryId = mapPrice.get(productCode);
                item.Quantity = 1;
                item.vlocity_cmt__EffectiveQuantity__c = 1;
                item.ReliesOnReferenceId__c = franquiaId;

                if (productSubType == 'Extra') {
                	String jsonAttr = mapJSONAttr.get(productId);
                	String validity = getValidity(productCode, franquiaCode);
                	Map<String, Object> mapJSON = setOnJSON(jsonAttr, validity);  
                    
                	item.vlocity_cmt__JSONAttribute__c = JSON.serialize(mapJSON);                    
                }
                
				lstOrderItem.add(item);
            }
            
            insert lstOrderItem;
            
			System.debug('########## END SOLAR_PME_Bonus.builderBonusOrder');
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    } 
       
	private void builderBonusOppt(List<Object> listBonus) {
        List<OpportunityLineItem> lstOpptItem = new List<OpportunityLineItem>();
        OpportunityLineItem item;
        
		System.debug('########## START SOLAR_PME_Bonus.builderBonusOppt');                                                        
        
        try { 
            String cartId = (String) this.input.get('ContextCartId');  
           
            Map<String, Object> mapRelies = (Map<String, Object>) this.input.get('TemplateActions_CloneFromTemplate');
            String franquiaId = (String) mapRelies.get('FranquiaAssetReferenceId__c'); 
            
            Map<String, Object> mapFieldsToUpdate = (Map<String, Object>) this.input.get('fieldsToUpdate');
            String typeOfRequest = (String) mapFieldsToUpdate.get('TypeOfRequest__c'); 
            
            Map<String, Object> mapSelItem = (Map<String, Object>) this.input.get('SelItem');
            Map<String, Object> mapSelProd = (Map<String, Object>) mapSelItem.get('Product2');
            String franquiaCode = (String) mapSelProd.get('ProductCode'); 
            
            for (Object obj : listBonus) {
                Map<String, Object> mapBonus = (Map<String, Object>) obj;
                Id productId = (Id) mapBonus.get('ProductId');
                String productCode = (String) mapBonus.get('ProductCode');
                String productSubType = (String) mapBonus.get('ProductSubType');

            	item = new OpportunityLineItem();
                item.Product2Id = productId;
                item.vlocity_cmt__Product2Id__c = productId;
                item.OpportunityId = cartId;
                item.TypeOfRequest__c = typeOfRequest;
                item.vlocity_cmt__LineNumber__c = '0100';
                //item.Discount = 0;
                item.vlocity_cmt__RecurringTotal__c = 0;
                item.vlocity_cmt__RecurringCharge__c = 0;
                item.vlocity_cmt__RecurringCalculatedPrice__c = 0;
                item.vlocity_cmt__EffectiveRecurringTotal__c = 0;
				item.vlocity_cmt__OneTimeLoyaltyPrice__c = 0;
                //item.ListPrice = 0;
                item.UnitPrice = 0;
                //item.Subtotal = 0;
                item.PricebookEntryId = mapPrice.get(productCode);
                item.Quantity = 1;
                item.vlocity_cmt__EffectiveQuantity__c = 1;
                item.ReliesOnReferenceId__c = franquiaId;

                if (productSubType == 'Extra') {
                	String jsonAttr = mapJSONAttr.get(productId);
                	String validity = getValidity(productCode, franquiaCode);
                	Map<String, Object> mapJSON = setOnJSON(jsonAttr, validity);  
                    
                	item.vlocity_cmt__JSONAttribute__c = JSON.serialize(mapJSON);                    
                }
                
				lstOpptItem.add(item);
            }
            
            insert lstOpptItem;
            
			System.debug('########## END SOLAR_PME_Bonus.builderBonusOppt');            
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    }    
    
	private void builderMaps(List<Object> listBonus) {
        List<Id> lstProductId = new List<Id>();
        List<String> lstPrice = new List<String>();

		System.debug('########## START SOLAR_PME_Bonus.builderMaps');                                                
        
        try { 
            for (Object obj : listBonus) {
                Map<String, Object> mapBonus = (Map<String, Object>) obj;
                Id productId = (Id) mapBonus.get('ProductId');
                String productCode = (String) mapBonus.get('ProductCode');
                String productSubType = (String) mapBonus.get('ProductSubType');
                
				lstProductId.add(productId);
                lstPrice.add(productCode);
            }
            
            builderJSONAttribute(lstProductId);
            builderPrice(lstPrice);
            builderMatrix();
            
			System.debug('########## END SOLAR_PME_Bonus.builderMaps');                        
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    }     
    
	private void builderJSONAttribute(List<Id> lstProductId) {
        mapJSONAttr = new map<Id, String>();
        
		System.debug('########## START SOLAR_PME_Bonus.builderJSONAttribute');                                        
        
        try { 
            List<Product2> lstProduct = [SELECT Id, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE Id =:lstProductId];
            
            for (Product2 prod : lstProduct) {
            	mapJSONAttr.put(prod.Id, prod.vlocity_cmt__JSONAttribute__c);    
            }
            
			System.debug('########## END SOLAR_PME_Bonus.builderJSONAttr');                         
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    }     
    
	private void builderPrice(List<String> lstProductCode) {
        mapPrice = new map<String, Id>();
        
		System.debug('########## START SOLAR_PME_Bonus.builderPrice');                                
        
        try { 
            List<PriceBookEntry> lstPrice = [SELECT Id, ProductCode FROM PriceBookEntry WHERE ProductCode =:lstProductCode];
            
            for (PriceBookEntry price : lstPrice) {
            	mapPrice.put(price.ProductCode, price.Id);    
            }            
            
			System.debug('########## END SOLAR_PME_Bonus.builderPrice');                         
            
        } catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            
            throw e;
        }
    }    
    
    private void builderMatrix(){
		System.debug('########## START SOLAR_PME_Bonus.builderMatrix');                        
        
        vlocity_cmt__CalculationMatrixVersion__c activeControlMatrix = [SELECT Id FROM vlocity_cmt__CalculationMatrixVersion__c WHERE vlocity_cmt__CalculationMatrixId__c in (SELECT Id FROM vlocity_cmt__CalculationMatrix__c WHERE Name LIKE 'PME_Bonus_Validity') AND vlocity_cmt__IsEnabled__c=true ORDER BY vlocity_cmt__Priority__c DESC LIMIT 1];
        
        Map<String, String> rowInput;
        Map<String, String> rowOutput;
            
        lstMatrixRow = [SELECT vlocity_cmt__InputData__c,vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE vlocity_cmt__CalculationMatrixVersionId__c = :activeControlMatrix.Id and IsDeleted = false and vlocity_cmt__OutputData__c  != null];
        
		System.debug('########## END SOLAR_PME_Bonus.builderMatrix');                                 
  	}
    
	private String getValidity(String productCode, String franquiaCode){
        String validity;
        
        Map<String, String> rowInput;
        Map<String, String> rowOutput;        
        
		System.debug('########## START SOLAR_PME_Bonus.getValidity');                
        
        for (vlocity_cmt__CalculationMatrixRow__c matrixRow : lstMatrixRow){
          rowInput = (Map<String, String>)  JSON.deserialize(matrixRow.vlocity_cmt__InputData__c, Map<String, String>.class);
          rowOutput = (Map<String, String>) JSON.deserialize(matrixRow.vlocity_cmt__OutputData__c, Map<String, String>.class);
    
            if (rowInput.get('BonusCode') == productCode && rowInput.get('FranquiaCode') == franquiaCode) {
            	validity = rowOutput.get('BonusValidity');
                break;
            }
       }

	   System.debug('########## END SOLAR_PME_Bonus.getValidity');                                         
        
       return validity;
  	}    
    
	   
	private Map<String, Object> setOnJSON(String jsonString, String validity) {
		System.debug('########## START SOLAR_PME_Bonus.setOnJSON');        
        
        if (jsonString != null) {
			Map<String, Object> mapObject = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
            if(mapObject.containsKey('ATT_CAT_FRANQ')) {
                List<Object> listAttCatFranq = (List<Object>) mapObject.get('ATT_CAT_FRANQ');
                for(Object objAttCatFranq : listAttCatFranq) {
                    Map<String, Object> mapAttCatFranq = (Map<String, Object>) objAttCatFranq;
                    Boolean isContains = mapAttCatFranq.containsKey('attributeuniquecode__c');
                    //isContains &= mapAttCatFranq.containsKey(attribute);
                    String attributeUniqueCode = (String) mapAttCatFranq.get('attributeuniquecode__c');               
                    if(isContains && attributeUniqueCode.equalsIgnoreCase('ATT_PME_BonusValidity')) {
                        Map<String, Object> mapAttrRun = (Map<String, Object>) mapAttCatFranq.get('attributeRunTimeInfo');                                          
                        mapAttrRun.put('value', validity);
                        
                        System.debug('########## END SOLAR_PME_Bonus.setOnJSON');                                                             
                        
                        return mapObject;
                    }
                }
            }            
        }

        return null;
    }    
}