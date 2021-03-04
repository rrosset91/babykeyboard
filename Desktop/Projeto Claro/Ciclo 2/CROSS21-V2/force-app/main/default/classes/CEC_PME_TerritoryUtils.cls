public without sharing class CEC_PME_TerritoryUtils {
    public class TerritoryUtilsException extends Exception {}
    public static String getListTerritorysRadios(Id orderId) { 
        system.debug('orderId ' + orderId);
        List<Map<String,String>> listTerritorys = new List<Map<String,String>>();
        
        List<Member__c> listMembers = [SELECT Id, 
                                       Hierarchy__c,
                                       Hierarchy__r.name
                                       FROM Member__c
                                       WHERE User__c IN (SELECT OwnerId FROM Order WHERE Id = :orderId)];
        
        if(listMembers.isEmpty()) {
            throw new TerritoryUtilsException('Não foi possivel encontrar um território');
        }
        
        for(Member__c member : listMembers) {
            Map<String,String> newOption = new Map<String,String>();
            newOption.put('value', member.Hierarchy__c);
            newOption.put('label', member.Hierarchy__r.name);
            listTerritorys.add(newOption);
        }
        system.debug('listMembers ' + listMembers);
        return JSON.serialize(listTerritorys); 
    }
    
    public static void updateAccountTerritory(Id orderId, String territoryId) { 
        Order orderUp = [SELECT Id,
                         AccountId
                         FROM Order 
                         WHERE Id = :orderId];
        
        Account accountUp = new Account();
        accountUp.Id = orderUp.AccountId;
        accountUp.Hierarchy__c = territoryId;
        update accountUp;
    }
}