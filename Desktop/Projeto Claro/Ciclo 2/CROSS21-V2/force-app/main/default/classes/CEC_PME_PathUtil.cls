/*
* Autor: Diogo Braga - Deloitte
* Data: 21/10/19
* Descrição: CEC extesão + SQUAD PME: Classe util para implemantações de path customizadas
*/
public class CEC_PME_PathUtil {
    /*
    * Autor: Diogo Braga - Deloitte
	* Data: 21/10/19
	* Descrição: CEC extesão + SQUAD PME: Inner class para validações feitas dentro dessa classe
	*/
    public class PathUtilException extends Exception{}
    
    private static final String INCOMPLETE = 'incomplete';
    private static final String NORMAL = 'Normal';
    private static final String PERDIDO = 'Perdido';
    private static final String LOST = 'lost';
    private static final String ERRO = 'Erro';
    private static final String ERROR = 'error';
    private static final String GANHO = 'Ganho';
    private static final String COMPLETE = 'complete';
    private static final String CURRENT = 'current';
    
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Data: 21/10/19
	* Descrição: CEC extesão + SQUAD PME: classe modelo de path
	*/
    public class Path {
        /*
    	* Autor: Diogo Braga - Deloitte
		* Descrição: CEC extesão + SQUAD PME: método contrutor
		*/
        public Path() {
            items = new List<PathItem>();
        }
        
        public List<PathItem> items {get;set;}
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Data: 21/10/19
	* Descrição: CEC extesão + SQUAD PME: classe modelo das etapas do path
	*/
    public class PathItem {
        /*
		* Autor: Diogo Braga - Deloitte
		* Descrição: CEC extesão + SQUAD PME: método contrutor
		*/
        public PathItem() {
            this.isShowMedium = false;
            this.type = INCOMPLETE;
        }
        
        public String id {get;set;}
        public String name {get;set;}
        public String type {get;set;}
        public Boolean isShowMedium {get;set;}
    }
    
    private List<CEC_PME_PathConfig__mdt> listPathConfigs;
    private Map<String, CEC_PME_PathConfig__mdt> mapPathConfigs;
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: método contrutor, busca configurações por implementação e mapeia os microstatus
	*/
    public CEC_PME_PathUtil(String component) {
        if(String.isBlank(component)) {
            throw new PathUtilException(Label.CEC_PME_PathUtil_1);
        }
        
        List<CEC_PME_PathConfig__mdt> listPathConfigs = [SELECT Id,
                                                         MacroStatus__c,
                                                         MicroStatus__c,
                                                         Order__c,
                                                         Type__c
                                                         FROM CEC_PME_PathConfig__mdt
                                                         WHERE Component__c = :component
                                                         ORDER BY Order__c];
        
        if(listPathConfigs.isEmpty()) {
            throw new PathUtilException(Label.CEC_PME_PathUtil_2);
        }
        
        this.listPathConfigs = listPathConfigs;
        this.mapPathConfigs = assenbleMapPathConfigs();
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: monta o map de microstatus
	*/
    private Map<String, CEC_PME_PathConfig__mdt> assenbleMapPathConfigs() {
        Map<String, CEC_PME_PathConfig__mdt> mapPathConfigs = new Map<String, CEC_PME_PathConfig__mdt>();
        
        for(CEC_PME_PathConfig__mdt pathConfig : listPathConfigs) {
            mapPathConfigs.put(pathConfig.MicroStatus__c, pathConfig);
        }
        
        return mapPathConfigs;
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: pega a configuração pelo microstatus
	*/
    private CEC_PME_PathConfig__mdt getPathConfig(String microStatus) {
        CEC_PME_PathConfig__mdt currentPathConfig = mapPathConfigs.get(microStatus);
        
        if(currentPathConfig == null) {
            currentPathConfig = new CEC_PME_PathConfig__mdt();
            currentPathConfig.MacroStatus__c = microStatus;
            currentPathConfig.MicroStatus__c = microStatus;
            currentPathConfig.Order__c = 0;
            currentPathConfig.Type__c = NORMAL;
        }
        
        return currentPathConfig;
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: monta e retorna o path seguindo a implementação, configuração e microstatus
	*/
    public Path getPathByMicroStatus(String microStatus) {
        Path newPath = new Path();
        set<String> setString = new set<String>();
        CEC_PME_PathConfig__mdt currentPathConfig = getPathConfig(microStatus);
        
        if(currentPathConfig.type__c.equals(PERDIDO)) {
            PathItem newPathItem = new PathItem();
            newPathItem.id = String.valueOf(currentPathConfig.Order__c);
            newPathItem.name = currentPathConfig.MacroStatus__c;
            newPathItem.type = LOST;
            newPath.items.add(newPathItem);
            return newPath;
        }
                
        Integer currentPosition = Integer.valueOf(currentPathConfig.Order__c);
        
        for(CEC_PME_PathConfig__mdt iPathConfig : listPathConfigs) {
            
            if(currentPathConfig.MacroStatus__c.equals(iPathConfig.MacroStatus__c)) {
                if(currentPathConfig.MicroStatus__c.equals(iPathConfig.MicroStatus__c)) {
                    PathItem newPathItem = new PathItem();
                    newPathItem.id = String.valueOf(iPathConfig.Order__c);
                    newPathItem.name = iPathConfig.MicroStatus__c;
                    if(currentPathConfig.Type__c == ERRO) {
                        newPathItem.type = ERROR;
                    } else if(currentPathConfig.Type__c == GANHO) {
                        newPathItem.type = COMPLETE;
                    } else {
                        newPathItem.type = CURRENT;
                    }
                    
                    newPath.items.add(newPathItem);
                }
            } else if(!setString.contains(iPathConfig.MacroStatus__c) && !iPathConfig.type__c.equals(PERDIDO)) {
                PathItem newPathItem = new PathItem();
                newPathItem.id = String.valueOf(iPathConfig.Order__c);
                newPathItem.name = iPathConfig.MacroStatus__c;
                
                if(iPathConfig.Order__c < currentPosition) {
                    newPathItem.type = COMPLETE;
                } else if(iPathConfig.Order__c > currentPosition) {
                    newPathItem.type = INCOMPLETE;
                }
                
                newPath.items.add(newPathItem);
            }
            setString.add(iPathConfig.MacroStatus__c);
        }
        
        Integer currentPositionOnItems = newPath.items.size();
        for(Integer i = 0; i < newPath.items.size(); i++) {
            pathItem pathItem = newPath.items.get(i);
            if(pathItem.type == ERROR || pathItem.type == CURRENT) {
                currentPositionOnItems = i;
            }
        }
        
        if(currentPositionOnItems == 0) {
            for(Integer i = 3; i < newPath.items.size(); i++) {
                newPath.items.get(i).isShowMedium = true;
            }
        } else if(currentPositionOnItems == newPath.items.size()-1) {
            for(Integer i = 0; i < (newPath.items.size() -3); i++) {
                newPath.items.get(i).isShowMedium = true;
            }
        } else {
            Set<Integer> byPass = new Set<Integer> {currentPositionOnItems-1, currentPositionOnItems, currentPositionOnItems+1};
                for(Integer i = 0; i < newPath.items.size(); i++) {
                    if(!byPass.contains(i)) {
                        newPath.items.get(i).isShowMedium = true;
                    }
                }
        }
        
        return newPath;
    }
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: builder para exiber erros
	*/
    public static Path builderErrorPath(String name) {
        Path newPath = new Path();
        
        PathItem pathItem = new PathItem();
        pathItem.id = ERROR;
        pathItem.name = name;
        pathItem.type = ERROR;
        
        newPath.items.add(pathItem);
        return newPath;
    }
    
}