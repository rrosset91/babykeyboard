/* 
* Autor: Diogo Braga - Deloitte
* Data: 01/10/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe contém as regras de compartilhamento de registro por membro de hierarquia
*/
public class CEC_PME_SharerRecord {
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: método para compartilhar pedidos
    */ 
    public void sharingRecordOrder(List<Order> listOrder) {
        List<Id> listOwnersId = getListOwnerId(listOrder);
        
        Map<Id, List<Member__c>> mapUserIdListMembers = getMapUserIdListMembers(listOwnersId);
        
        Map<String, Group> mapDevNameGroup = getMapDevNameGroupByMapMembers(mapUserIdListMembers);
        
        List<OrderShare> listOrderShareToInsert = new List<OrderShare>();
        for(Order iOrder : listOrder) {
            if(mapUserIdListMembers.containsKey(iOrder.OwnerId)) {
                List<Member__c> listMembers = mapUserIdListMembers.get(iOrder.OwnerId);
                
                for(Member__c iMember : listMembers) {
                    Group groupByMember = getGroupByHierarchy(mapDevNameGroup, iMember.Hierarchy__r);
                    
                    if(groupByMember == null) {
                        groupByMember = getGroupByHierarchy(mapDevNameGroup, iMember.Hierarchy__r.ParentHierarchy__r);
                    }
                    
                    if(groupByMember != null) {
                        listOrderShareToInsert.add(builderOrderShare(groupByMember.Id, iOrder.Id));
                    }                    
                } 
            }
        }
        
        if(!listOrderShareToInsert.isEmpty()) {
            database.insert(listOrderShareToInsert, false);
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: método para compartilhar oportunidades
    */ 
    public void sharingRecordOpportunity(List<Opportunity> listOpportunities) {
        List<Id> listOwnersId = getListOwnerId(listOpportunities);
        Map<Id, List<Member__c>> mapUserIdListMembers = getMapUserIdListMembers(listOwnersId);
        Map<String, Group> mapDevNameGroup = getMapDevNameGroupByMapMembers(mapUserIdListMembers);
        
        List<OpportunityShare> listOpportunityShareToInsert = new List<OpportunityShare>();
        for(Opportunity iOpportunity : listOpportunities) {
            if(mapUserIdListMembers.containsKey(iOpportunity.OwnerId)) {
                List<Member__c> listMembers = mapUserIdListMembers.get(iOpportunity.OwnerId);
                
                for(Member__c iMember : listMembers) {
                    Group groupByMember = getGroupByHierarchy(mapDevNameGroup, iMember.Hierarchy__r);
                    
                    if(groupByMember == null && iMember.Hierarchy__r != null) {
                        groupByMember = getGroupByHierarchy(mapDevNameGroup, iMember.Hierarchy__r.ParentHierarchy__r);
                    }
                    
                    if(groupByMember != null) {
                        listOpportunityShareToInsert.add(builderOpportunityShare(groupByMember.Id, iOpportunity.Id));
                    }                    
                } 
            }
        }
        
        if(!listOpportunityShareToInsert.isEmpty()) {
            database.insert(listOpportunityShareToInsert, false);
        }
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Identifica de existe grupo gestor para a hierarquia 
    */ 
    private Group getGroupByHierarchy(Map<String, Group> mapDevNameGroup, Hierarchy__c hierarchy) {
        if(hierarchy == null) {
            return null;
        }
        
        Boolean isContainsGroup = mapDevNameGroup.containsKey(hierarchy.Id);
        Boolean isCodeNotBlank = isContainsGroup && String.isNotBlank(hierarchy.TerritoryCode__c);
        Boolean isGestor = isCodeNotBlank && hierarchy.TerritoryCode__c.contains('GESTOR');
        
        if(isGestor) {
            return mapDevNameGroup.get(hierarchy.Id);
        }
        return null;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Instancia de objeto de compartilhamento de pedido 
    */ 
    @TestVisible 
    private OrderShare builderOrderShare(Id groupId, Id orderId) {
        OrderShare newOrderShare = new OrderShare();
        newOrderShare.OrderId  = orderId;
        newOrderShare.UserOrGroupId = groupId;
        newOrderShare.OrderAccessLevel = 'Edit';
        newOrderShare.RowCause = Schema.OrderShare.RowCause.Manual;
        return newOrderShare;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Instancia de objeto de compartilhamento de oportunidade 
    */ 
    @TestVisible 
    private OpportunityShare builderOpportunityShare(Id groupId, Id OpportunityId) {
        OpportunityShare newOpportunityShare = new OpportunityShare();
        newOpportunityShare.OpportunityId  = OpportunityId;
        newOpportunityShare.UserOrGroupId = groupId;
        newOpportunityShare.OpportunityAccessLevel = 'Edit';
        newOpportunityShare.RowCause = Schema.OrderShare.RowCause.Manual;
        return newOpportunityShare;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método mapeia os grupos pelo id da hierarquia  
    */ 
    private Map<String, Group> getMapDevNameGroupByMapMembers(Map<Id, List<Member__c>> mapMembers) {
        Map<String, Group> mapDevNameGroup = new Map<String, Group>();
        List<Id> listHierarchiesId = new List<Id>();
        
        for(List<Member__c> listMember : mapMembers.values()) {
            for(Member__c iMember : listMember) {
                if(String.isNotBlank(iMember.Hierarchy__c)) {
                    listHierarchiesId.add(iMember.Hierarchy__r.Id);
                    listHierarchiesId.add(iMember.Hierarchy__r.ParentHierarchy__r.Id);
                }
            }
        }
        
        List<Group> listGroups = [SELECT Id, 
                                  DeveloperName
                                  FROM Group
                                  WHERE DeveloperName IN :listHierarchiesId];
        
        for(Group iGroup : listGroups) {
            mapDevNameGroup.put(iGroup.DeveloperName, iGroup);
        }
        
        return mapDevNameGroup;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método mapeia as listas de membros por id do usuário 
    */ 
    private Map<Id, List<Member__c>> getMapUserIdListMembers(List<Id> listOwnersId) {
        Map<Id, List<Member__c>> mapUserIdListMembers = new Map<Id, List<Member__c>>();
        
        List<Member__c> listMembers = [SELECT Id, 
                                       User__c,
                                       Hierarchy__r.Id,
                                       Hierarchy__r.TerritoryCode__c,
                                       Hierarchy__r.ParentHierarchy__r.Id,
                                       Hierarchy__r.ParentHierarchy__r.TerritoryCode__c
                                       FROM Member__c 
                                       WHERE User__c IN :listOwnersId];
        
        for(Member__c iMember : listMembers) {
            if(mapUserIdListMembers.containsKey(iMember.User__c)) {
                mapUserIdListMembers.get(iMember.User__c).add(iMember);
            } else {
                mapUserIdListMembers.put(iMember.User__c, new List<Member__c>{iMember});
            }
        }
        
        return mapUserIdListMembers;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Lista os ids dos proprietários dos objetos  
    */ 
    private List<Id> getListOwnerId(List<SObject> listSObjects) {
        List<Id> listOwnersId = new List<Id>();
        
        for(SObject iSObjects : listSObjects){
            listOwnersId.add((Id) iSObjects.get('OwnerId'));
        }
        
        return listOwnersId;
    }
}