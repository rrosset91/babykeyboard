/* 
* Autor: Diogo Braga - Deloitte
* Data: 19/09/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe padronização dos tratamento das triggers
*  ---------------------------------------------------------------
*/
public virtual class TriggerHandler { 

    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    private static Boolean isAllBypassed;
    
    @TestVisible
    private TriggerContext context;
    
    @TestVisible
    private Boolean isTriggerExecuting;
    
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        isAllBypassed = false;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Construtor
	*/      
    public TriggerHandler() {
        this.setTriggerContext();
    }

    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Inicialização da triggerHandler
	*/      
    public void run() {
        
        if(!validateRun()) return;
        
        addToLoopCount();
        
        if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Marca o número máximo de loops permitido
	*/      
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Limpa o número máximo de loops permitido
	*/      
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
      
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Executa o bypass de métodos da trigger
	*/      
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Executa o bypass dos métodos da triggers
	*/      
    public static void allBypass(String handlerName) {
        isAllBypassed = true;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Desmarca método marcado para bypass
	*/      
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Verifica se um método esta marcado para bypass
	*/      
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName) || isAllBypassed;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Limpa todos os métodos marcados para bypass
	*/      
    public static void clearAllBypasses() {
        isAllBypassed = false;
        TriggerHandler.bypassedHandlers.clear();
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Executa a marcação do contexto da trigger
	*/      
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Executa a marcação do contexto da trigger
	*/     
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) || (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) || (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) || (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) || (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) || (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) || (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) || (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Atualiza o contador de loop
	*/     
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Executa a validação da execução da trigger
	*/     
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        
        if(TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Pesquisa o nome do handler da triggers
	*/     
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual beforeInsert
	*/     
    @TestVisible
    protected virtual void beforeInsert() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual beforeUpdate
	*/    
    @TestVisible
    protected virtual void beforeUpdate() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual beforeDelete
	*/    
    @TestVisible
    protected virtual void beforeDelete() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual afterInsert
	*/    
    @TestVisible
    protected virtual void afterInsert() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual afterUpdate
	*/
    @TestVisible
    protected virtual void afterUpdate() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual afterDelete
	*/    
    @TestVisible
    protected virtual void afterDelete() {
        
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Método virtual afterUndelete
	*/    
    @TestVisible
    protected virtual void afterUndelete() {
        
    }

    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Controla o contador do loop
	*/    
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            if(this.max < 0) {
                return false;
            }
            if(this.count > this.max) {
                return true;
            }
            return false;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
            this.max = max;
        }
    }
       
    @TestVisible
    private enum TriggerContext {
       		BEFORE_INSERT, 
            BEFORE_UPDATE, 
            BEFORE_DELETE,
            AFTER_INSERT, 
            AFTER_UPDATE, 
            AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Retorna os dados novos dos registros
	*/     
    protected List<SObject> getTriggerNew() {
        if(Trigger.new == null) {
            return new List<SObject>();
        }
        return Trigger.new;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Retorna os dados antigos dos registros
	*/    
    protected List<SObject> getTriggerOld() {
        if(Trigger.old == null) {
            return new List<SObject>();
        }
        return Trigger.old;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Filtra os valores de registros novos pelo recordType
	*/    
    protected List<SObject> getTriggerNewByRecordTypeDeveloperName(String recordTypeDeveloperName) {
        return getListByRecordTypeDeveloperName(getTriggerNew(), recordTypeDeveloperName);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Filtra os valores de registros antigos pelo recordType
	*/   
    protected List<SObject> getTriggerOldByRecordTypeDeveloperName(String recordTypeDeveloperName) {
        return getListByRecordTypeDeveloperName(getTriggerOld(), recordTypeDeveloperName);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Filtra os registros pelo recordType
	*/       
    private List<SObject> getListByRecordTypeDeveloperName(List<SObject> listObjects, String recordTypeDeveloperName) {
        Id recordTypeId = getRecordTypeIdByDeveloperName(recordTypeDeveloperName);
        
        List<SObject> listSeparetedObjects = new List<SObject>();
        for(SObject varSobject : listObjects) {
            if(recordTypeId.equals((Id) varSobject.get('RecordTypeId'))) {
                listSeparetedObjects.add(varSobject);
            }
        }
        
        return listSeparetedObjects;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Filtra os registros pelo recordType
	*/    
    private Id getRecordTypeIdByDeveloperName(String recordTypeDeveloperName) {
        SObject varSobject;
        if(Trigger.new != null) {
            varSobject = Trigger.new.get(0);
        } else if(Trigger.old != null){
            varSobject = Trigger.old.get(0);
        } else {
            throw new TriggerHandlerException('Trigger.new and Trigger.old is null');
        }
        
        if(!varSobject.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().containsKey(recordTypeDeveloperName)) {
            throw new TriggerHandlerException('record type [' +recordTypeDeveloperName+ '] not found on sobject [' + varSobject.getSObjectType().getDescribe().getName() + ']');
        }
        
        return varSobject.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: Tratamento de erro da trigger
	*/    
    public class TriggerHandlerException extends Exception {
        
    }
    
}