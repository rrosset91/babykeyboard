public class CEC_OpportunityMethods 
{ 
    public Static void sharingRecord(List<Opportunity> lstOpportunity)
    {
		List<OpportunityShare> forInsert = new List<OpportunityShare>();
		Map<String, String> mapOpportunity = new Map<String, String>();
		Map<String, String> mapHierarchyIds = new Map<String, String>();
		//Map<String, String> mapHierarchyCode = new Map<String, String>();
		Map<String, String> mapGroupIds = new Map<String, String>();
		
        Set<String> setHierarchyIds = new Set<String>();
        
		for(Opportunity opp : lstOpportunity){
			mapOpportunity.put(opp.Id, opp.OwnerId);
		}
		
		List<Member__c> lstMember = [SELECT Id, Hierarchy__c, User__c FROM Member__c WHERE User__c =: mapOpportunity.values()];
		for(Member__c member : lstMember){
			mapHierarchyIds.put(member.Id, member.Hierarchy__c);
		}
		
		List<Hierarchy__c> lstHierarquia = [SELECT Id, TerritoryCode__c FROM Hierarchy__c WHERE Id =: mapHierarchyIds.values()];
		for(Hierarchy__c hierarquia : lstHierarquia){
			if (String.isNotBlank(hierarquia.TerritoryCode__c) && hierarquia.TerritoryCode__c.contains('_GESTOR')) {
            	//mapHierarchyCode.put(hierarquia.Id, hierarquia.TerritoryCode__c);
            	setHierarchyIds.add(hierarquia.Id);
            }
		}
		
		//List<Group> lstGrupo = [SELECT Id, Name FROM Group WHERE Name =: mapHierarchyCode.values()]; 
		List<Group> lstGrupo = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN: setHierarchyIds]; 
		
		for(Opportunity opp : lstOpportunity){
			for(Member__c member : lstMember){
				if(opp.OwnerId != member.User__c){continue;}
				
				for(Hierarchy__c hierarquia : lstHierarquia){
					if(member.Hierarchy__c != hierarquia.Id){continue;}
					
					for(Group gp : lstGrupo){
						if(hierarquia.Id != gp.DeveloperName){continue;}
						
						OpportunityShare oppShare = new OpportunityShare();
						oppShare.OpportunityId  = opp.Id;
						oppShare.UserOrGroupId = gp.Id;
						oppShare.OpportunityAccessLevel = 'Edit';
						oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
			
						forInsert.add(oppShare);
					}
				}
				
			}
		}
		
		if(forInsert.size() > 0){
			insert forInsert;	
		}
	}

    
}