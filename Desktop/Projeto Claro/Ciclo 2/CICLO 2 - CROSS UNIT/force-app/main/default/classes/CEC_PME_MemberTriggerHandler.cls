/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de regras de negócio do objeto membro
*/
public class CEC_PME_MemberTriggerHandler extends TriggerHandler {

    private List<Member__c> triggerNew;
    private List<Member__c> triggerOld;
    private Map<Id, Member__c> triggerOldMap;

    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Construtor
    */ 
    public CEC_PME_MemberTriggerHandler() {
        triggerNew = (List<Member__c>) getTriggerNew();
        triggerOld = (List<Member__c>) getTriggerOld();
        triggerOldMap = new Map<Id, Member__c>();
        triggerOldMap.putAll(triggerOld);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterInsert() {
        if(!CEC_PME_ResizableHierarchy.isScheduledLessNMinutes(20)) {
            new CEC_PME_ResizableHierarchy(0, 0, 19, false).schedule();
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void afterUpdate() {
        if(!CEC_PME_ResizableHierarchy.isScheduledLessNMinutes(20)) {
            new CEC_PME_ResizableHierarchy(0, 0, 19, false).schedule();
        }
        deleteGroupMembers(triggerOld);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método contextualizado
    */ 
    public override void beforeDelete() {
        deleteGroupMembers(triggerOld);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método para deletar o group member
    */ 
    private void deleteGroupMembers(List<Member__c> listMembers) {
        Map<Id, List<Member__c>> mapUserIdMembers = getMapUserIdMembers(listMembers);
        
        Map<Id, Group> mapGroups = getMapGroups(listMembers);
        
        List<GroupMember> listGroupMembers = [SELECT Id,
                                              GroupId,
                                              UserOrGroupId
                                              FROM GroupMember
                                              WHERE GroupId IN :mapGroups.keySet()
                                              AND UserOrGroupId IN :mapUserIdMembers.keySet()];
        
        List<GroupMember> listGroupMembersToDelete = new List<GroupMember>();
        
        for(GroupMember iGroupMember : listGroupMembers) {
            Boolean isContainsUser = mapUserIdMembers.containsKey(iGroupMember.UserOrGroupId);
            Boolean isContainsGroup = mapGroups.containsKey(iGroupMember.GroupId);
            
            if(isContainsUser && isContainsGroup) {
                List<Member__c> listMembersByUser = mapUserIdMembers.get(iGroupMember.UserOrGroupId);
                Group hierarchyGroup = mapGroups.get(iGroupMember.GroupId);
                
                for(Member__c iMemberByUser : listMembersByUser) {
                    if(hierarchyGroup.DeveloperName.equals(iMemberByUser.Hierarchy__c)) {
                        listGroupMembersToDelete.add(iGroupMember);
                    }
                }
            }
        }
        
        if(!listGroupMembersToDelete.isEmpty()) {
            List<Id> listIdsToDelete = new List<Id>();
            for(GroupMember groupMemberDelete : listGroupMembersToDelete) {
                listIdsToDelete.add(groupMemberDelete.Id);
            }
            
            Database.executeBatch( new CEC_PME_BatchDelete(listIdsToDelete, 'GroupMember'), 100);
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Lista os membros por id do usuário
    */ 
    private Map<Id, List<Member__c>> getMapUserIdMembers(List<Member__c> listMembers) {
        Map<Id, List<Member__c>> mapUserIdMembers = new Map<Id, List<Member__c>>();
        
        for(Member__c iMember : listMembers) {
            if(String.isNotBlank(iMember.User__c) && String.isNotBlank(iMember.Hierarchy__c)) {
                if(mapUserIdMembers.containsKey(iMember.User__c)) {
                    mapUserIdMembers.get(iMember.User__c).add(iMember);
                } else {
                    mapUserIdMembers.put(iMember.User__c, new List<Member__c>{iMember});
                }
            }
        }
        
        return mapUserIdMembers;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: mapeia os grupos
    */ 
    private Map<Id, Group> getMapGroups(List<Member__c> listMembers) {
        List<Id> listHierarchyId = new List<Id>();
        
        for(Member__c iMember : listMembers) {
            if(String.isNotBlank(iMember.Hierarchy__c)) {
                listHierarchyId.add(iMember.Hierarchy__c);
            }
        }
        
        List<Group> listGroups = [SELECT Id, 
                                  DeveloperName 
                                  FROM Group 
                                  WHERE DeveloperName IN :listHierarchyId];
        
        Map<Id, Group> mapGroups = new Map<Id, Group>();
        
        mapGroups.putAll(listGroups);
        
        return mapGroups;
    }
    
}