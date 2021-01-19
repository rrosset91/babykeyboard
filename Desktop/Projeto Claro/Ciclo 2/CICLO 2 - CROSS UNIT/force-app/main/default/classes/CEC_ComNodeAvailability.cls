public class CEC_ComNodeAvailability {

    public Set<Id> getProductsIdWithNodeAvailable(Map<String, Object> inputMap){
        string city = ((String)inputMap.get('city')).toUpperCase();
        string orderID = (String)inputMap.get('OrderId');
        string node = '';
        node  = [SELECT Node__c FROM Order WHERE Id = :orderID LIMIT 1].Node__c;
        List<Group_Set__c> groupSetAll = [ SELECT Name, Node__c, City__c, RecordType.DeveloperName FROM Group_Set__c WHERE Start_Date__c <= TODAY LIMIT 100 ];
        Set<Id> prodAvailability = new Set<Id>();
        for(Group_Set__c groupSetItem : groupSetAll){
            prodAvailability.add(buscaProdutoAvailability(groupSetItem, city, node));
        }
        prodAvailability.remove(null);
        return buscaProdutos(prodAvailability, inputMap);
    }

    private Id buscaProdutoAvailability(Group_Set__c item, String city, String node){
        Id groupSetID;
        if(item.RecordType.DeveloperName == 'City'){
            groupSetID = buscaEmCity(item, city);
        }else if(item.RecordType.DeveloperName == 'Node'){
            groupSetID = buscaemNode(item, city, node);
        }
        return groupSetID;
    }

    private Id buscaEmCity(Group_Set__c item, string city){
        id groupSetID;
        List<String> cityList = new List<String>();
        cityList = item.City__c.toUpperCase().split(';');
        if(cityList.contains(city)){
            groupSetID = item.Id;
        }
        return groupSetID;
    }

    private Id buscaemNode(Group_Set__c item, string city, string node){
        Id groupSetID;
        List<String> cityList = new List<String>();
        List<String> nodeList = new List<String>();
        cityList = item.City__c.toUpperCase().split(';');
        nodeList = item.Node__c.toUpperCase().split(';');
        if(nodeList.contains(node) && cityList.contains(city)){
            groupSetID = item.Id;
        }
        return groupSetID;
    }

    private Set<Id> buscaProdutos(Set<Id> prodAvailability, Map<String, Object> inputMap){
        Set<Id> produtos = new Set<Id>();
        
        boolean restricao = (Boolean)inputMap.get('restricao');
        if(!restricao)
        {
            List<vlocity_cmt__ProductAvailability__c> listProd = [SELECT Id, Name, vlocity_cmt__Product2Id__r.Id 
                                                                  FROM vlocity_cmt__ProductAvailability__c 
                                                                  WHERE Group_Set__r.Id IN : prodAvailability AND Type__c = 'Available' ];
            for(vlocity_cmt__ProductAvailability__c aval : listProd){
                produtos.add(aval.vlocity_cmt__Product2Id__r.Id);
            }
        }
        else
        {
            List<vlocity_cmt__ProductAvailability__c> listProd = [SELECT Id, Name, vlocity_cmt__Product2Id__r.Id 
                                                                  FROM vlocity_cmt__ProductAvailability__c 
                                                                  WHERE Group_Set__r.Id IN : prodAvailability AND Type__c = 'Available'
                                                                  AND vlocity_cmt__Product2Id__r.ProductCode LIKE '%_REST_%'];
            
            for(vlocity_cmt__ProductAvailability__c aval : listProd){
                produtos.add(aval.vlocity_cmt__Product2Id__r.Id);
            }
        }

        return produtos;
    }

}