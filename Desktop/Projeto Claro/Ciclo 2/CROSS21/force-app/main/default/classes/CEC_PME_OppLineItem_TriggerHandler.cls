public with sharing class CEC_PME_OppLineItem_TriggerHandler {
	public CEC_PME_OppLineItem_TriggerHandler() {}

	public void verifyVlcPricing(List<OpportunityLineItem> newItems, Map<Id, OpportunityLineItem> oldItemsMap ){
		/*
		Map<Id, OpportunityLineItem> oldItemsMap = new Map<Id, OpportunityLineItem>();

		//building the OldItems map to quick acces later
		for (OpportunityLineItem item : oldItems){
			oldItemsMap.put(item.Id, item);
		}*/

		//Iterating the new items
		System.debug('BEFORE THE FOR'); //Dan Mas 16052019

		for (OpportunityLineItem item : newItems){
			if (item.Avoid_vlc_pricing__c){
				//system.debug('avoiding pricing for item:'+item.Id);
				OpportunityLineItem oldItem = oldItemsMap.get(item.Id);
				System.debug('INSIDE THE IF - ITEM:'+ item); //Dan Mas 16052019
				System.debug('INSIDE THE IF - OLDITEM:'+ oldItem); //Dan Mas 16052019
				Decimal qtty = item.vlocity_cmt__EffectiveQuantity__c;
				item.vlocity_cmt__RecurringCalculatedPrice__c = oldItem.vlocity_cmt__RecurringCalculatedPrice__c;
				item.vlocity_cmt__RecurringCharge__c = oldItem.vlocity_cmt__RecurringCharge__c;
				Decimal totalPrice = qtty * item.vlocity_cmt__RecurringCalculatedPrice__c;
				item.TotalPrice = totalPrice;
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
	// Description: Method for applying discounts when the vlocity_cmt__RecurringDiscountPrice__c is modified
	public void applyOpportunityDiscountItem(List<OpportunityLineItem> newItems, Map<Id, OpportunityLineItem> oldItemsMap){
		Decimal tempValue = 0;
		Id myPMERecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Opportunity_PME' AND SobjectType = 'Opportunity' LIMIT 1].Id;
		
		OpportunityLineItem firstElement = newItems[0];
		Id myOppId = firstElement.OpportunityId;        
		
		Id oppRecordType = [SELECT RecordTypeId from Opportunity Where Id = :myOppId LIMIT 1].RecordTypeId;
				
		System.debug('PMERecordType => ' + myPMERecordType );
		System.debug('OppRecordType => ' + oppRecordType ); 
			
		If (myPMERecordType != oppRecordType){
			return;
		}  
		for(OpportunityLineItem item: newItems){
			
			// Id myOppId = item.OpportunityId;        
		
			// Id oppRecordType = [SELECT RecordTypeId from Opportunity Where Id = :myOppId LIMIT 1].RecordTypeId;
			
			tempValue = 0;  
					System.debug('UNIT PRICE:'+item.UnitPrice+',RECURRING DISCOUNT:'+item.vlocity_cmt__RecurringDiscountPrice__c+',RECURRING CHARGE:'+item.vlocity_cmt__RecurringCharge__c);			
				if((item.vlocity_cmt__RecurringDiscountPrice__c > 0 && (item.UnitPrice == 0 || item.UnitPrice==null)) || (item.vlocity_cmt__RecurringDiscountPrice__c > 0 && item.vlocity_cmt__RecurringCharge__c == item.UnitPrice)){

					if(item.vlocity_cmt__EffectiveRecurringTotal__c/item.Quantity != item.vlocity_cmt__RecurringCharge__c)
						return;

					System.debug('OPP ADD DESCONTO');
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
					System.debug('OPP REMOVE DESCONTO');
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
            
                if(item.ProductCode == 'PME_SimCardAvulso_0001')
                {
                    item.vlocity_cmt__RecurringTotal__c = item.Quantity *  item.vlocity_cmt__RecurringCharge__c; 
                }
			
		}
	}
}