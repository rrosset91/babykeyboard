global class Solar_SkillsBasedRouting {

    @InvocableMethod
    public static void routUsingSkills(List<Case> lstCase){
        
        List<PendingServiceRouting> lstPendingServiceRouting = new List<PendingServiceRouting>();
        List<SkillRequirement> lstSkillRequirement = new List<SkillRequirement>();
		String varChannelId = getChannelId('CaseCC');
        for(Case objCase: lstCase){
            lstPendingServiceRouting.add(getPendingServiceRouting(objCase,varChannelId));
        }
        insert lstPendingServiceRouting;
        
        Set<String> setSkillsId = new Set<String>{'FinancialDisputeInvoice'};
        Map<String, Id> mapSkillByName = getSkillId(setSkillsId);
        
        
        Map<Id, PendingServiceRouting> mapPendingServiceRoutingByCase = new Map<Id, PendingServiceRouting>();
        for(PendingServiceRouting routing : [SELECT Id, IsReadyForRouting, WorkItemId FROM PendingServiceRouting WHERE Id IN: lstPendingServiceRouting]){
            if(!mapPendingServiceRoutingByCase.containsKey(routing.WorkItemId))
                mapPendingServiceRoutingByCase.put(routing.WorkItemId, routing);
        }
        
        for(Case objCase: lstCase){
            PendingServiceRouting varPendingServiceRouting = mapPendingServiceRoutingByCase.get(objCase.Id);
			lstSkillRequirement.add(getSkillRequirement(objCase, varPendingServiceRouting.id,mapSkillByName.get('FinancialDisputeInvoice')));
            mapPendingServiceRoutingByCase.get(objCase.Id).IsReadyForRouting = TRUE;
        }
        
        insert lstSkillRequirement;
        
        update mapPendingServiceRoutingByCase.values();
    }
    
    
    private static PendingServiceRouting getPendingServiceRouting(Case pCase,String serviceChannelId){
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = false,
            RoutingPriority = 1,
            RoutingModel  = 'MostAvailable',
            RoutingType = 'SkillsBased',
            ServiceChannelId  = serviceChannelId,
            WorkItemId = pCase.Id
        );
        
        return psrObj;
    }
    
    private static SkillRequirement getSkillRequirement(Case pCase, String pPendingServiceRouting,String skillId){
        SkillRequirement srObj = new SkillRequirement(
            RelatedRecordId = pPendingServiceRouting,
            SkillId = skillId
            //SkillLevel = 1
        );    
        return srObj;    
    }

    public static Map<String, Id> getSkillId(Set<String> setSkillsId){
        Map<String, Id> mapSkillByName = new Map<String, Id>();
        
        for(Skill skillItem : [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN: setSkillsId]){
            if(!mapSkillByName.containsKey(skillItem.DeveloperName))
                mapSkillByName.put(skillItem.DeveloperName, skillItem.Id);
        }
        
        return mapSkillByName;
    } 
    
        public static String getChannelId(String channelName) {
        ServiceChannel channel = [SELECT Id 
                                  FROM ServiceChannel 
                                  WHERE DeveloperName = :channelName];
        
        return channel.Id;
    }
}