public class CEC_PME_FromToUtil {
    public class CEC_PME_FromToException extends Exception {}

    private String fromToGroup;
    private Map<String, String> mapFromTo;
    
    public CEC_PME_FromToUtil(String fromToGroup) {
        this.fromToGroup = fromToGroup;
        mapFromTo = new Map<String, String>();
        
        List<CEC_PME_FromTo__mdt> listFromTo = [SELECT Id, From__c, To__c
                                                FROM CEC_PME_FromTo__mdt
                                                WHERE Group__c = :fromToGroup];
        
        if(String.isBlank(fromToGroup)) {
            throw new CEC_PME_FromToException('fromToGroup não pode ser nulo ou vazio');
        }
        
        if(listFromTo.isEmpty()) {
            throw new CEC_PME_FromToException('CEC_PME_FromTo__mdt não encontrado com fromToGroup informado');
        }
        
        for(CEC_PME_FromTo__mdt fromTo : listFromTo) {
            mapFromTo.put(fromTo.From__c, fromTo.To__c);
        }
    }
    
    public Boolean hasTo(String keyFrom) {
        return mapFromTo.containsKey(keyFrom);
    }
    
    public String getTo(String keyFrom) {
        if(mapFromTo.containsKey(keyFrom)) {
            return mapFromTo.get(keyFrom);
        } else {
            throw new CEC_PME_FromToException('De para não encontrado');
        }
    }
}