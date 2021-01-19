public class CEC_PME_BatchDelete implements Database.Batchable<sObject> {  
    public List<Id> listObjectIds = new List<Id>();
    public String sObjectName;
    
    public CEC_PME_BatchDelete(List<Id> listObjectIds, String sObjectName) {
        this.listObjectIds = listObjectIds;
        this.sObjectName = sObjectName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM ' + sObjectName + ' WHERE Id IN :listObjectIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Database.delete(scope, false);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}