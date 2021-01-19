Public class CEC_CatalogBatch implements Database.Batchable<sObject>{
    
    public final String Query;
    public final String Entity;
    public final String Field;
    public final String Value;
    public final String Action;
    public final String Replace;
    
    public CEC_CatalogBatch(String q, String e, String f, String v, String r, String a){
        Query=q;Entity=e;Field=f;Value=v;Replace=r;Action=a;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if(Action.toLowerCase() == 'delete'){
            delete scope;
            
        }else if (Action.toLowerCase() == 'update'){
            for(sobject s : scope){
                s.put(Field,Value); 
            }
            update scope;		
        }else if (Action.toLowerCase() == 'updatecreatekey'){
            String currentDate = CEC_CatalogUtilities.getCurrentDate();
	        String sandboxName = CEC_CatalogUtilities.getSandboxName();
            String key		   = '';
            
            for(sobject s : scope){
                key = CEC_CatalogUtilities.generateKey(currentDate, SandboxName);
                s.put(Field,key); 
            }
            update scope;		
        }else if (Action.toLowerCase() == 'updateReplace'){
            String newField = '';
            Map<String, Object> fieldValue = new Map<String, Object>(); 
            
            for(sobject s : scope){
                fieldValue = s.getPopulatedFieldsAsMap();
                newField = (string) fieldValue.get(Field);                
                System.debug(newField);
                s.put(Field, newField.replace(Value, Replace));
            }
            update scope;		
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}