public class CEC_PME_HierarchyBO { 
     
    public List<Hierarchy__c> getListHierarchiesWithoutGroups(List<Hierarchy__c> listHierarchies) {
        List<Hierarchy__c> listHierarchiesWithoutGroups = new List<Hierarchy__c>();
        
        List<Id> listHierarchyIds = new List<Id>();
        for(Hierarchy__c iHierarchy : listHierarchies) {
            listHierarchyIds.add(iHierarchy.Id);
        }
        
        Map<String, Group> mapGroups = getMapGroups(listHierarchyIds);
        
        for(Hierarchy__c iHierarchy : listHierarchies) {
            if(!mapGroups.containsKey(iHierarchy.Id)) {
                listHierarchiesWithoutGroups.add(iHierarchy);
            }
        }
        
        return listHierarchiesWithoutGroups;
    }
    
    public List<Hierarchy__c> getListHierarchiesWithoutAssociations(List<Hierarchy__c> listHierarchies, Map<String, Group> mapGroups) {
        List<Id> listParentHierarchiesIds = new List<Id>();
        List<Id> listChildrenHierarchiesIds = new List<Id>();
        
        for(Hierarchy__c iHierarchy : listHierarchies) {
            if(mapGroups.containsKey(iHierarchy.ParentHierarchy__c) && mapGroups.containsKey(iHierarchy.Id)) {
                listParentHierarchiesIds.add(mapGroups.get(iHierarchy.ParentHierarchy__c).Id);
                listChildrenHierarchiesIds.add(mapGroups.get(iHierarchy.Id).Id);
            }
        }
        
        List<GroupMember> listGroupMembers = [SELECT Id, 
                                              GroupId, 
                                              UserOrGroupId 
                                              FROM GroupMember
                                              WHERE GroupId IN :listChildrenHierarchiesIds
                                              AND UserOrGroupId IN :listParentHierarchiesIds];
        
        Map<Id, GroupMember> mapGroupMemberByGroupId = new Map<Id, GroupMember>();
        for(GroupMember iGroupMember : listGroupMembers) {
            mapGroupMemberByGroupId.put(iGroupMember.GroupId, iGroupMember);
        }
        
        List<Hierarchy__c> listHierarchiesWithoutAssociations = new List<Hierarchy__c>();
        for(Hierarchy__c iHierarchy : listHierarchies) {
            if(mapGroups.containsKey(iHierarchy.ParentHierarchy__c) && mapGroups.containsKey(iHierarchy.Id)) {
                Group parentGroup = mapGroups.get(iHierarchy.ParentHierarchy__c);
                Group childGroup = mapGroups.get(iHierarchy.Id);
                
                Boolean hasMapChildHierarchy = mapGroupMemberByGroupId.containsKey(childGroup.Id);
                Boolean hasMatchObjects = hasMapChildHierarchy && mapGroupMemberByGroupId.get(childGroup.Id).UserOrGroupId != parentGroup.Id;
                
                if(!hasMatchObjects) {
                    listHierarchiesWithoutAssociations.add(iHierarchy);
                }  
            }
        }
        
        return listHierarchiesWithoutAssociations;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Quando uma hierarquia é associada a outra esse método associa os grupos correspondentes
    */ 
    public void associateHierarchies(List<Hierarchy__c> listHierarchys) {
        
        if(!listHierarchys.isEmpty()) {
            List<Id> listAllHierarchiesIds = new List<Id>();
            
            for(Hierarchy__c iHierarchy : listHierarchys) {
                listAllHierarchiesIds.add(iHierarchy.ParentHierarchy__c);
                listAllHierarchiesIds.add(iHierarchy.Id);
            }
            
            Map<String, Group> mapGroups = getMapGroups(listAllHierarchiesIds);
            
            List<Hierarchy__c> listHierarchiesWithoutAssociations = getListHierarchiesWithoutAssociations(listHierarchys, mapGroups);
            
            List<GroupMember> listNewGroupMembers = createListNewGroupMembers(listHierarchiesWithoutAssociations, mapGroups);
            
            if(!listNewGroupMembers.isEmpty()) {
                insert listNewGroupMembers;
            }
        }
    }
    
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: cria a lista dos group Members
    */ 
    private List<GroupMember> createListNewGroupMembers(List<Hierarchy__c> listHierarchiesWithParents, Map<String, Group> mapGroups) {
        List<GroupMember> listNewGroupMembers = new List<GroupMember>();
        
        for(Hierarchy__c iHierarchy : listHierarchiesWithParents) {
            Group parentGroup = mapGroups.get(iHierarchy.ParentHierarchy__c);
            Group childGroup = mapGroups.get(iHierarchy.Id);
            
            
            GroupMember newGroupMember = new GroupMember();
            newGroupMember.GroupId = childGroup.Id;
            newGroupMember.UserOrGroupId = parentGroup.Id ;
                
            listNewGroupMembers.add(newGroupMember);
        }
        
        return listNewGroupMembers;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: query de group
    */
    private List<Group> getListGroup(List<Id> listIds) {
        return [SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName IN :listIds];
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: mapeia os grupos
    */
    private Map<String, Group> getMapGroups(List<Id> listIdsToSearch) {
        Map<String, Group> mapGroups = new Map<String, Group>();
        
        List<Group> listGroups = getListGroup(listIdsToSearch); 
        
        if(listGroups != null) {
            for(Group iGroup : listGroups) {
                mapGroups.put(iGroup.DeveloperName, iGroup);
            }
        }
        
        return mapGroups;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: cria e insere os grupos
    */
    public List<Group> createGroups(List<Hierarchy__c> listHierarchys) {
        List<Group> listNewGroups = new list<Group>();
        
        for(Hierarchy__c iHierarchy : listHierarchys) {
            Group newGroup = new Group();
            newGroup.Name = iHierarchy.Name;
            newGroup.DeveloperName = iHierarchy.Id;
            
            listNewGroups.add(newGroup);
        }
        
        if(!listNewGroups.isEmpty()) {
            insert listNewGroups;
        }
        
        return listNewGroups;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método para deletar o groupos
    */ 
    public void deleteGroups(Map<Id, Hierarchy__c> triggerOldMap) {
        List<Group> listGroupsToDelete = [SELECT Id
                                          FROM Group
                                          WHERE DeveloperName IN :triggerOldMap.keySet()];
        
        if(!listGroupsToDelete.isEmpty()) {
            List<Id> listIdsToDelete = new List<Id>();
            for(Group groupToDelete : listGroupsToDelete) {
                listIdsToDelete.add(groupToDelete.Id);
            }
            
            Database.executeBatch( new CEC_PME_BatchDelete(listIdsToDelete, 'Group'), 100);
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: quando uma associação de hierarquia é removida esse método remove a associação dos grupos correspondentes
    */ 
    public void removeOldAssociationsOfHierarchies(List<Hierarchy__c> triggerNew, Map<Id, Hierarchy__c> triggerOldMap) {
        List<Hierarchy__c> listHierarchiesRemoveAssoc = new List<Hierarchy__c>();
        
        for(Hierarchy__c hierarchyNew : triggerNew) {
            Hierarchy__c hierarchyOld = triggerOldMap.get(hierarchyNew.Id);
            
            if(String.isNotBlank(hierarchyOld.ParentHierarchy__c) && !hierarchyOld.ParentHierarchy__c.equals(hierarchyNew.ParentHierarchy__c)) {
                listHierarchiesRemoveAssoc.add(hierarchyOld);
            }
        }
        
        if(!listHierarchiesRemoveAssoc.isEmpty()) {
            List<GroupMember> listGroupMembersToDelete = getListGroupMembersToDelete(listHierarchiesRemoveAssoc);
            if(!listGroupMembersToDelete.isEmpty()) {
                List<Id> listIdsToDelete = new List<Id>();
                for(GroupMember groupMemberToDelete : listGroupMembersToDelete) {
                    listIdsToDelete.add(groupMemberToDelete.Id);
                }
                
                Database.executeBatch(new CEC_PME_BatchDelete(listIdsToDelete, 'Group'), 100);
            }
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Lista os group members a serem deletados
    */ 
    private List<GroupMember> getListGroupMembersToDelete(List<Hierarchy__c> listHierarchiesRemoveAssoc) {
        List<Id> listAllHierarchiesIds = new List<Id>();
        
        for(Hierarchy__c iHierarchy : listHierarchiesRemoveAssoc) {
            listAllHierarchiesIds.add(iHierarchy.Id);
            listAllHierarchiesIds.add(iHierarchy.ParentHierarchy__c);
        }
        
        Map<String, Group> mapGroups = getMapGroups(listAllHierarchiesIds);
        
        Map<Id, Id> mapChildIdParentId = new Map<Id, Id>();
        
        for(Hierarchy__c iHierarchy : listHierarchiesRemoveAssoc) {
            Id childGroupId = mapGroups.get(iHierarchy.Id).Id;
            Id parentGroupId = mapGroups.get(iHierarchy.ParentHierarchy__c).Id;
            mapChildIdParentId.put(childGroupId, parentGroupId);
        }
        
        List<GroupMember> listGroupMembers = [SELECT Id 
                                              FROM GroupMember
                                              WHERE Group.developerName IN :mapChildIdParentId.keySet()
                                              AND UserOrGroupId IN :mapChildIdParentId.values()];
        
        List<GroupMember> listGroupMembersToDelete = new List<GroupMember>();
        for(GroupMember iGroupMember : listGroupMembers) {
            Boolean hasOnMap = mapChildIdParentId.containsKey(iGroupMember.GroupId);
            Boolean isToDelete = hasOnMap && mapChildIdParentId.get(iGroupMember.GroupId) == iGroupMember.UserOrGroupId;
            if(isToDelete) {
                listGroupMembersToDelete.add(iGroupMember);
            }
        }
        return listGroupMembers;
    }
}