public with sharing class CEC_OrderMethods 
{
    public Static void sharingRecord(List<Order> lstOrder)
    {
        List<OrderShare> forInsert = new List<OrderShare>();
        Map<String, String> mapOrder = new Map<String, String>();
        Map<String, String> mapHierarchyIds = new Map<String, String>();
        //Map<String, String> mapHierarchyCode = new Map<String, String>();
        Map<String, String> mapGroupIds = new Map<String, String>();
        
        Set<String> setHierarchyIds = new Set<String>();
        
        for(Order ord : lstOrder){
            mapOrder.put(ord.Id, ord.OwnerId);
        }
        
        List<Member__c> lstMember = [SELECT Id, Hierarchy__c, User__c FROM Member__c WHERE User__c =: mapOrder.values()];
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
        
        for(Order ord : lstOrder){
            for(Member__c member : lstMember){
                if(ord.OwnerId != member.User__c){continue;}
                
                for(Hierarchy__c hierarquia : lstHierarquia){
                    if(member.Hierarchy__c != hierarquia.Id){continue;}
                    
                    for(Group gp : lstGrupo){
                        if(hierarquia.Id != gp.DeveloperName){continue;}
                        
                        OrderShare os = new OrderShare();
                        os.OrderId  = ord.Id;
                        os.UserOrGroupId = gp.Id;
                        os.OrderAccessLevel = 'Edit';
                        os.RowCause = Schema.OrderShare.RowCause.Manual;
            
                        forInsert.add(os);
                    }
                }
                
            }
        }
        
        if(forInsert.size() > 0){
            insert forInsert;   
        }
    }
    
    /*public static void selectTypeHierachyToAccount(List<Order> lstOrder)
    {
        Set<String> setSegments = new Set<String>{'AACE', 'AA Claro Movel', 'AA Net Fixo', 'Loja Própria'};
        Set<String> setSegmentsDigital = new Set<String>{'Televendas', 'Televendas AACE', 'Digital'};    
        Set<Id> setOwnerAprovedOrderId = new Set<Id>(); 
        
        for(Order order : lstOrder){
            if(order.Status == 'Documentação Aprovada')
                setOwnerAprovedOrderId.add(order.OwnerId);
        }
        
        if(setOwnerAprovedOrderId.size() > 0)
        {
            Map<Id, Member__c> mapUserByAprovedOrder = new Map<Id, Member__c>();
            List<Member__c> lstMember = [SELECT Id, Hierarchy__c, User__c, User__r.Account.CommercialSegment__c 
                                         FROM Member__c WHERE User__c =: setOwnerAprovedOrderId];
            
            for(Member__c member : lstMember){
                mapUserByAprovedOrder.put(member.User__c, member);
            }
            
            List<Account> lstAccToUpdate = new List<Account>();
            for(Order order : lstOrder)
            {
                Member__c member = mapUserByAprovedOrder.get(order.OwnerId);
                if(member != Null){
                    if(setSegments.contains(member.User__r.Account.CommercialSegment__c)) {
                        Account objAcc = new Account(Id = order.AccountId, Hierarchy__c = member.Hierarchy__c);
                        lstAccToUpdate.add(objAcc);
                    }
                    else if(setSegmentsDigital.contains(member.User__r.Account.CommercialSegment__c) && 
                            String.isBlank(order.HierarchyAccount__c))
                        order.HierarchyAccount__c.addError('Um território deve ser atribuído ao pedido para ser compartilhado com a conta atrelada.');
                    else
                        system.debug('selectTypeHierachyToAccount >> Nenhum território deve ser atribuído');
                }
            }
            
            try{ 
                update lstAccToUpdate;
            }
            catch(Exception ex){
                system.debug('selectTypeHierachyToAccount >> Exception: ' + ex.getMessage());   
                lstOrder[0].addError('Erro ao atribuir território para a conta atrelada ao pedido.');
            }
        }
        else
            system.debug('selectTypeHierachyToAccount >> Qtd Owner c/ Documentação Aprovada: ' + setOwnerAprovedOrderId.size());   
    } */   
}