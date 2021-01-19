/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto membro
*/
public class CEC_PME_HierarchyMemberBO {

    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: Separa os membros e insere o group member dos que não existem
	*/ 
    public void createListMembersWithoutAssociations(List<Member__c> listMembers) {
        
        List<Id> listUserIds = new List<Id>();
        List<Id> listHierarchyIds = new List<Id>();
        
        for(Member__c iMember : listMembers) {
            listUserIds.add(iMember.User__c);
            listHierarchyIds.add(iMember.Hierarchy__c);
        }
        
        
        List<GroupMember> listGroupMembers = [SELECT Id,
                                              UserOrGroupId,
                                              Group.DeveloperName
                                              FROM GroupMember 
                                              WHERE UserOrGroupId IN :listUserIds
                                              AND Group.DeveloperName IN :listHierarchyIds];
        
        Map<Id, set<String>> mapUserIdSetGroupDeveloperName = new Map<Id, set<String>>();
        for(GroupMember iGroupMember : listGroupMembers) {
            if(mapUserIdSetGroupDeveloperName.containsKey(iGroupMember.UserOrGroupId)) {
                mapUserIdSetGroupDeveloperName.get(iGroupMember.UserOrGroupId).add(iGroupMember.Group.DeveloperName);
            } else {
                mapUserIdSetGroupDeveloperName.put(iGroupMember.UserOrGroupId,new set<String>{iGroupMember.Group.DeveloperName});
            }
        }
        
        List<Member__c> listMembersWithoutAssociations = new List<Member__c>();
        for(Member__c iMember : listMembers) {
            Boolean isMapContainsUserId = mapUserIdSetGroupDeveloperName.containsKey(iMember.User__c);
            Boolean isMatchObject = isMapContainsUserId && mapUserIdSetGroupDeveloperName.get(iMember.User__c).contains(iMember.Hierarchy__c);
            
            if(!isMatchObject) {
                listMembersWithoutAssociations.add(iMember);
            }
        }
        
        if(!listMembersWithoutAssociations.isEmpty()) {
            createGroupMembers(listMembers);    
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: cria e insere os group members dos membros passados
    */ 
    private void createGroupMembers(List<Member__c> listMembers) {
        
        Map<Id, List<Member__c>> mapHierarchyIdListMembers = getMapHierarchyIdListMembers(listMembers);
        
        List<GroupMember> listGroupMembersToInsert = new List<GroupMember>();
        
        for(Group iGroup : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = :mapHierarchyIdListMembers.keySet()]) { 
            for(Member__c iMember : mapHierarchyIdListMembers.get(iGroup.DeveloperName)) { 
            
                GroupMember newGroupMember = new GroupMember();
                newGroupMember.GroupId = iGroup.Id; 
                newGroupMember.UserOrGroupId = iMember.User__c;
                
                listGroupMembersToInsert.add(newGroupMember);
            }
        }
        
        if(!listGroupMembersToInsert.isEmpty()) {
            insert listGroupMembersToInsert;
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Mapeia os membros pela hierarquia
    */ 
    private Map<Id, List<Member__c>> getMapHierarchyIdListMembers(List<Member__c> listMembers) {
        Map<Id, List<Member__c>> mapHierarchyIdListMembers = new Map<Id, List<Member__c>>();
        
        for(Member__c iMember : listMembers) { 
            if(mapHierarchyIdListMembers.containsKey(iMember.Hierarchy__c)) {
                mapHierarchyIdListMembers.get(iMember.Hierarchy__c).add(iMember);
            } else {
                mapHierarchyIdListMembers.put(iMember.Hierarchy__c, new List<Member__c>{iMember});
            }
        }
        
        return mapHierarchyIdListMembers;
    }
}