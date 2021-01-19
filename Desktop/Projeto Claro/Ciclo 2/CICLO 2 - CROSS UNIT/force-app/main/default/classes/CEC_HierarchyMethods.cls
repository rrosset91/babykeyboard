public class CEC_HierarchyMethods { 

    public static void createGroup(list<Hierarchy__c> lstHierarchyNew) {   
        
        list<Group> lstInsertGroup = new list<Group>();
        
        for(Hierarchy__c hrcy : lstHierarchyNew) { 
            
			Group grp = new Group();
            grp.Name = hrcy.Name;
            grp.DeveloperName = hrcy.Id;

            lstInsertGroup.add(grp);
        }
        
        if(!lstInsertGroup.isEmpty()) insert lstInsertGroup;
        
        list<Hierarchy__Share> lstInsertHierarchyShare = new list<Hierarchy__Share>();
        
        for(Group grp : lstInsertGroup) { 
            
            Hierarchy__Share hrcyShare = new Hierarchy__Share();
            hrcyShare.UserOrGroupId = grp.Id;
            hrcyShare.ParentId = grp.DeveloperName;
            hrcyShare.AccessLevel = 'Edit';
            
            lstInsertHierarchyShare.add(hrcyShare);
        }
        
        if(!lstInsertHierarchyShare.isEmpty()) insert lstInsertHierarchyShare;
        
    }
    
    public static void assignMembers(list<Hierarchy__c> lstHierarchyNew) { 
        
        set<String> lstParentHierarchyId = new set<String>();
        set<String> lstHierarchyId = new set<String>();
        list<Hierarchy__c> lstHierarchy = new list<Hierarchy__c>();
        
        for(Hierarchy__c hrcy : lstHierarchyNew) {
            
            if(hrcy.ParentHierarchy__c != null) { 
                
                lstParentHierarchyId.add(hrcy.ParentHierarchy__c);
                lstHierarchyId.add(hrcy.Id);
                lstHierarchy.add(hrcy);
            }
        }
        
        if(lstParentHierarchyId.isEmpty()) return;
        
		map<Id, Group> mapHierarchyWithGroup = getHierarchyWithGroup(lstHierarchyId);
        System.debug('lstParentHierarchyId '+lstParentHierarchyId);
        map<Id, list<Member__c>> mapHierarchyWithParentMembers = getHierarchyWithMembers(lstParentHierarchyId);
                
        list<Member__c> lstInsertMember = new list<Member__c>();
        
        for(Hierarchy__c hrcy : lstHierarchy) { 
    
        	Group grp = mapHierarchyWithGroup.get(hrcy.Id);
            if(grp == null) continue;
			System.debug('mapHierarchyWithParentMembers.get(hrcy.ParentHierarchy__c) >>>> '+mapHierarchyWithParentMembers.get(hrcy.ParentHierarchy__c));
            list<Member__c> lstMember = mapHierarchyWithParentMembers.get(hrcy.ParentHierarchy__c);
			System.debug('lstMember >>> '+lstMember);
            if(lstMember == null) continue;
            
            for(Member__c mbr : lstMember) { 
                
                Member__c mbrNew = new Member__c();
                mbrNew.Hierarchy__c = hrcy.Id;
                mbrNew.User__c = mbr.User__c;
                mbrNew.HierarchySource__c = hrcy.ParentHierarchy__c;
                mbrNew.IdExterno__c = mbr.Id;
                
                lstInsertMember.add(mbrNew);
            }
        }
        system.debug('lstInsertMember'+lstInsertMember);
        if(!lstInsertMember.isEmpty()) insert lstInsertMember;
        
    }
    
    public static void deleteMembersOnChangeCompany(list<Hierarchy__c> lstHierarchyNew, map<Id, Hierarchy__c> mapHierarchyOld) {
       
        set<String> lstHierarchyId = new set<String>();
        
        for(Hierarchy__c hrcy : lstHierarchyNew) { 
            
            if(mapHierarchyOld.get(hrcy.Id).Company__c != null && mapHierarchyOld.get(hrcy.Id).Company__c != hrcy.Company__c) { 
                
                lstHierarchyId.add(hrcy.Id);
            }
        }
        
        if(lstHierarchyId.isEmpty()) return;
        
        list<Member__c> lstDeleteMembers = [SELECT Id 
                                            FROM Member__c 
                                            WHERE Hierarchy__c = :lstHierarchyId];

		if(!lstDeleteMembers.isEmpty()) delete lstDeleteMembers;        
        
    }
    
    public static void deleteMembersOnChangeParent(list<Hierarchy__c> lstHierarchyNew, map<Id, Hierarchy__c> mapHierarchyOld) { 
        
        set<String> lstParentHierarchyId = new set<String>();
        set<String> lstHierarchyId = new set<String>();
        list<Hierarchy__c> lstHierarchy = new list<Hierarchy__c>();
        
        for(Hierarchy__c hrcy : lstHierarchyNew) { 
            
            if((hrcy.ParentHierarchy__c != null) && mapHierarchyOld.get(hrcy.Id).ParentHierarchy__c != hrcy.ParentHierarchy__c) {
                
                lstParentHierarchyId.add(hrcy.ParentHierarchy__c);
                lstHierarchyId.add(hrcy.Id);
                lstHierarchy.add(hrcy);
            }
        }
        
        if(lstHierarchyId.isEmpty()) return;
        
        list<Member__c> lstDeleteMembers = [SELECT Id 
                                            FROM Member__c 
                                            WHERE Hierarchy__c = :lstHierarchyId  
                                            AND HierarchySource__c != null];

        if(!lstDeleteMembers.isEmpty()) delete lstDeleteMembers;

		map<Id, Group> mapHierarchyWithGroup = getHierarchyWithGroup(lstHierarchyId);

        map<Id, list<Member__c>> mapHierarchyWithParentMembers = getHierarchyWithMembers(lstParentHierarchyId);
     	
       list<Member__c> lstInsertMember = new list<Member__c>();
        
        for(Hierarchy__c hrcy : lstHierarchy) { 
            
        	Group grp = mapHierarchyWithGroup.get(hrcy.Id);
            if(grp == null) continue;
            
            list<Member__c> lstMember = mapHierarchyWithParentMembers.get(hrcy.ParentHierarchy__c);
            system.debug('mapHierarchyWithParentMembers '+mapHierarchyWithParentMembers);
            system.debug('lstMember '+lstMember);
            if(lstMember == null) continue;
            
            for(Member__c mbr : lstMember) { 
                
                Member__c mbrNew = new Member__c();
                mbrNew.Hierarchy__c = hrcy.Id;
                mbrNew.User__c = mbr.User__c;
                mbrNew.HierarchySource__c = hrcy.ParentHierarchy__c;
                mbrNew.IdExterno__c = mbr.Id;                
                
                lstInsertMember.add(mbrNew);
            }
        }
        
        if(!lstInsertMember.isEmpty()) insert lstInsertMember;      
        
    }
    
    private static map<Id, Group> getHierarchyWithGroup(set<String> lstGroupDeveloperName) {
        
        map<Id, Group> mapHierarchyWithGroup = new map<Id, Group>();
        
        for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = :lstGroupDeveloperName]) {
            
            mapHierarchyWithGroup.put(grp.DeveloperName, grp);
        }
        
        return mapHierarchyWithGroup;
        
    }
    
    private static map<Id, list<Member__c>> getHierarchyWithMembers(set<String> lstHierarchyId) { 
        
        map<Id, list<Member__c>> mapHierarchyWithMembers = new map<Id, list<Member__c>>();
        
        for(Member__c mbr : [SELECT Id, User__c, Hierarchy__c, HierarchySource__c FROM Member__c WHERE Hierarchy__c = :lstHierarchyId]) {  
           
            list<Member__c> lstMember = mapHierarchyWithMembers.get(mbr.Hierarchy__c);
            if(lstMember == null) {
                lstMember = new list<Member__c>();
            }
          
            lstMember.add(mbr);
            mapHierarchyWithMembers.put(mbr.Hierarchy__c, lstMember);
        }
        System.debug('mapHierarchyWithMembers '+mapHierarchyWithMembers);
        return mapHierarchyWithMembers;
        
    }
    
}