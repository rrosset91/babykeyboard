public class CEC_MemberMethods { 
    
    @future
    public static void createGroupMember(String jsonMember) { 
        
        list<Member__c> lstMemberNew = (list<Member__c>)JSON.deserialize(jsonMember, list<Member__c>.class);
        
        map<Id, list<Member__c>> mapHierarchyWithMembers = new map<Id, list<Member__c>>();
        
        for(Member__c mbr : lstMemberNew) { 
            
            list<Member__c> lstMember = mapHierarchyWithMembers.get(mbr.Hierarchy__c);
            if(lstMember == null) {
                lstMember = new list<Member__c>();
            }
            
            lstMember.add(mbr);
            mapHierarchyWithMembers.put(mbr.Hierarchy__c, lstMember);
        }
        
        if(mapHierarchyWithMembers.isEmpty()) return;
        
        list<GroupMember> lstInsertGroupMember = new list<GroupMember>();
        
        for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = :mapHierarchyWithMembers.keySet()]) { 
            
            list<Member__c> lstMember = mapHierarchyWithMembers.get(grp.DeveloperName);
            if(lstMember == null) continue;
            
            for(Member__c mbr : lstMember) { 
            
                GroupMember grpMemb = new GroupMember();
                grpMemb.GroupId = grp.Id;
                grpMemb.UserOrGroupId = mbr.User__c;
                
                lstInsertGroupMember.add(grpMemb);
            }
        }
        
        if(!lstInsertGroupMember.isEmpty()) insert lstInsertGroupMember;
        
    }
    
    @future
    public static void deleteGroupMember(String jsonMember) { 
        
        list<Member__c> lstMemberOld = (list<Member__c>)JSON.deserialize(jsonMember, list<Member__c>.class);
        
        set<Id> lstUserId = new set<Id>();
        set<String> lstHierarchyId = new set<String>();
        
        for(Member__c mbr : lstMemberOld) { 
            
            lstUserId.add(mbr.User__c);
            lstHierarchyId.add(mbr.Hierarchy__c);
        }
        
        if(lstUserId.isEmpty() || lstHierarchyId.isEmpty()) return;
        
        list<GroupMember> lstDeleteGroupMember = new list<GroupMember>([SELECT Id 
                                                                        FROM GroupMember 
                                                                        WHERE UserOrGroupId = :lstUserId 
                                                                        AND Group.DeveloperName = :lstHierarchyId]);
        
        if(!lstDeleteGroupMember.isEmpty()) delete lstDeleteGroupMember;
    }    

}