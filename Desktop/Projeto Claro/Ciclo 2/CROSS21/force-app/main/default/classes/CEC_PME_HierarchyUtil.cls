public class CEC_PME_HierarchyUtil {
    public static Map<Id, List<Id>> getMapOwnerIdLstHierId(List<Order> listOrder) {
        Map<Id, List<Id>> mapOwnerIdLstHierId = new Map<Id, List<Id>>();
        List<Id> listOwnersId = new List<Id>();
        for(Order varOrder : listOrder) {
            listOwnersId.add(varOrder.OwnerId);
        }
        
        List<Hierarchy__c> listHierarchy = [SELECT Id,
                                            (SELECT Id, User__c 
                                             FROM Membro_da_Revenda__r 
                                             WHERE User__c IN :listOwnersId) 
                                            FROM Hierarchy__c 
                                            WHERE Id IN (SELECT Hierarchy__c 
                                                         FROM Member__c 
                                                         WHERE User__c IN :listOwnersId)];
        
        for(Hierarchy__c varHierarchy : listHierarchy) {
            if(varHierarchy.Membro_da_Revenda__r != null) {
                for(Member__c varMember : varHierarchy.Membro_da_Revenda__r) {
                    if(mapOwnerIdLstHierId.containsKey(varMember.User__c)) {
                        mapOwnerIdLstHierId.get(varMember.User__c).add(varHierarchy.Id);
                    } else {
                        mapOwnerIdLstHierId.put(varMember.User__c, new List<Id>{varHierarchy.Id});
                    }
                }
            }
        }
        return mapOwnerIdLstHierId;
    }
}