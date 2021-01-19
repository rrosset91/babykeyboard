public with sharing class CEC_PME_OrderItem_TriggerHandler {
    public CEC_PME_OrderItem_TriggerHandler() {
        
    }

    public void verifyVlcPricing(List<OrderItem> newItems, Map<Id, OrderItem> oldItemsMap ){

        /*Map<Id, OrderItem> oldItemsMap = new Map<Id, OrderItem>();

        //building the OldItems map to quick acces later
        for (OrderItem item : oldItems){
            oldItemsMap.put(item.Id, item);
        }*/

        //Iterating the new items
        for (OrderItem item : newItems){
            if (item.Avoid_vlc_pricing__c){
				//
                OrderItem oldItem = oldItemsMap.get(item.Id);
                Decimal qtty = item.vlocity_cmt__EffectiveQuantity__c;
                item.vlocity_cmt__RecurringCalculatedPrice__c = oldItem.vlocity_cmt__RecurringCalculatedPrice__c;
                item.vlocity_cmt__RecurringCharge__c = oldItem.vlocity_cmt__RecurringCharge__c;
                Decimal totalPrice = qtty * item.vlocity_cmt__RecurringCalculatedPrice__c;
                item.vlocity_cmt__EffectiveRecurringTotal__c =totalPrice;
                item.vlocity_cmt__RecurringTotal__c = totalPrice;
                item.vlocity_cmt__OneTimeLoyaltyPrice__c = oldItem.vlocity_cmt__OneTimeLoyaltyPrice__c;
                item.vlocity_cmt__OneTimeLoyaltyTotal__c = qtty * item.vlocity_cmt__OneTimeLoyaltyPrice__c;
                item.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c = item.vlocity_cmt__OneTimeLoyaltyTotal__c;
                //system.debug('final values for item:'+item);
            }
        }
    }

	// Date: Dec 2, 2019
	// Modified by: Miguel A. Muñoz (LabsXD)
	// Description:  Method for applying discounts when the vlocity_cmt__RecurringDiscountPrice__c is set
	public void applyOrderDiscountItem(List<OrderItem> newItems, Map<Id, OrderItem> oldItemsMap ){
		Decimal tempValue = 0;
    	Id pmeRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PME_Order' AND SobjectType = 'Order' LIMIT 1].Id;
    
		OrderItem firstElement = newItems[0];
		Id myOrdId = firstElement.OrderId;        
		
		Id ordRecordType = [SELECT RecordTypeId from Order Where Id = :myOrdId LIMIT 1].RecordTypeId;

		System.debug('PMERecordType => ' + pmeRecordType );
		System.debug('OrdRecordType => ' + ordRecordType );
			
		If (pmeRecordType != ordRecordType){
			return;
		} 

		for(OrderItem item : newItems){
			OrderItem oldItem = oldItemsMap.get(item.Id);
			//Id myOrdId = item.OrderId;			
		
			//Id ordRecordType = [SELECT RecordTypeId from Order Where Id = :myOrdId LIMIT 1].RecordTypeId;		
			tempValue = 0;  
					System.debug('UNIT PRICE:'+item.UnitPrice+',RECURRING DISCOUNT:'+item.vlocity_cmt__RecurringDiscountPrice__c+',RECURRING CHARGE:'+item.vlocity_cmt__RecurringCharge__c);


				if((item.vlocity_cmt__RecurringDiscountPrice__c > 0 && (item.UnitPrice == 0 || item.UnitPrice==null)) || (item.vlocity_cmt__RecurringDiscountPrice__c > 0 && item.vlocity_cmt__RecurringCharge__c == item.UnitPrice)){
					if(item.vlocity_cmt__EffectiveRecurringTotal__c/item.Quantity != item.vlocity_cmt__RecurringCharge__c)
						return;
					System.debug('ORDER ADD DESCONTO');
					tempValue = item.vlocity_cmt__RecurringCharge__c;				
					item.UnitPrice = item.vlocity_cmt__RecurringCharge__c;
					item.vlocity_cmt__RecurringCharge__c = tempValue - item.vlocity_cmt__RecurringDiscountPrice__c;
					item.vlocity_cmt__RecurringTotal__c = item.Quantity * (tempValue - item.vlocity_cmt__RecurringDiscountPrice__c); 
					if(item.vlocity_cmt__OneTimeLoyaltyPrice__c!=null && item.vlocity_cmt__OneTimeLoyaltyPrice__c!=0){
					item.vlocity_cmt__OneTimeLoyaltyPrice__c = (tempValue - item.vlocity_cmt__RecurringDiscountPrice__c) *100;					
					item.vlocity_cmt__OneTimeLoyaltyTotal__c = item.Quantity * item.vlocity_cmt__OneTimeLoyaltyPrice__c;
					item.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c=item.vlocity_cmt__OneTimeLoyaltyTotal__c;
					}
					System.debug('AFTER DESCONTO --- UNIT PRICE:'+item.UnitPrice+',RECURRING DISCOUNT:'+item.vlocity_cmt__RecurringDiscountPrice__c+',RECURRING CHARGE:'+item.vlocity_cmt__RecurringCharge__c);

				}
				if(item.vlocity_cmt__RecurringDiscountPrice__c == 0 && item.vlocity_cmt__EffectiveRecurringTotal__c/item.Quantity != item.vlocity_cmt__RecurringCharge__c){
					System.debug('ORDER REMOVE DESCONTO');
					if(item.vlocity_cmt__OneTimeLoyaltyPrice__c!=null &&  item.vlocity_cmt__OneTimeLoyaltyPrice__c!=0){
					item.vlocity_cmt__OneTimeLoyaltyPrice__c = (item.vlocity_cmt__EffectiveRecurringTotal__c/item.Quantity) *100;
					item.vlocity_cmt__OneTimeLoyaltyTotal__c = item.Quantity * item.vlocity_cmt__OneTimeLoyaltyPrice__c;
					}
					item.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c=item.vlocity_cmt__OneTimeLoyaltyTotal__c;
					item.vlocity_cmt__RecurringCharge__c = item.vlocity_cmt__EffectiveRecurringTotal__c/item.Quantity;
					item.vlocity_cmt__RecurringTotal__c =item.vlocity_cmt__EffectiveRecurringTotal__c;  
					System.debug('AFTER REMOVE DESCONTO --- RECURRING DISCOUNT:'+item.vlocity_cmt__RecurringDiscountPrice__c+',RECURRING CHARGE:'+item.vlocity_cmt__RecurringCharge__c);
        
				}

				if(item.vlocity_cmt__RecurringDiscountPrice__c > 0 && item.vlocity_cmt__RecurringTotal__c==(item.Quantity * item.UnitPrice))
				{
					item.vlocity_cmt__RecurringTotal__c = item.Quantity *  item.vlocity_cmt__RecurringCharge__c; 
				}
			
		}
	}


}