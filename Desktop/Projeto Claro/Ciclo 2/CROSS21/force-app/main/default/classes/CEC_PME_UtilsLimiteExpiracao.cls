public class CEC_PME_UtilsLimiteExpiracao {
    public static List<Limite_Expiracao__mdt> getLimiteExp() {
        return [SELECT DeveloperName, UltimoDiaDoMes__c, Dias_corridos_pedido__c, Dias_corridos_simulacao__c, Perfil__c, Segmento__c 
                FROM Limite_Expiracao__mdt 
                WHERE Ativo__c = true AND Status__c = null];
    }     
    
    public static List<Limite_Expiracao__mdt> getLimiteExpSeg() {
        return [SELECT DeveloperName, UltimoDiaDoMes__c, Dias_corridos_pedido__c, Dias_corridos_simulacao__c, Segmento__c, Status__c
                FROM Limite_Expiracao__mdt
                WHERE Ativo__c = true AND Segmento__c != null AND Status__c != null];
    }  

    public static Date ultimoDiaMes() {
        Date dataAtual = Date.Today();
        Date dataAlvo = Date.newInstance(dataAtual.year(), dataAtual.month(), 1);
        dataAlvo = dataAlvo.addMonths(1);
        Date dataFinal = dataAlvo.addDays(-1);
        
        return dataFinal;        
    }   
    
    public static Set<String> getLimiteStatus(String tipo) {
        Set<String> setStatus = new Set<String>();
        
        List<LimiteExpiracaoStatusExcecao__mdt> lstStatus = [SELECT Status__c 
                										FROM LimiteExpiracaoStatusExcecao__mdt 
                										WHERE TipoObjeto__c = :tipo AND Ativo__c = true];
        
        for (LimiteExpiracaoStatusExcecao__mdt mdtStatus : lstStatus) {
        	setStatus.add(mdtStatus.Status__c);
        }
        
        return setStatus;
    }    
    
    //parâmetros para o batch de oportunidades (Limite expiração)
    public static Map<String, Object> getOppParams(String developerName){
        Map<String, Object> params = new Map<String, Object>();
        //metadado customizado
        ConfigLimiteExpiracao__mdt config = getLimiteExpConfig(developerName);
        //retorna os status a serem verificados
        params.put('status', getPickListValues(config, 'StatusOportunidade__c'));
        //perfis
        params.put('profiles', getPickListValues(config, 'PerfisConsiderados__c'));
        //segmentos comerciais
        params.put('commercialSegments', getPickListValues(config, 'SegmentosComerciais__c'));
        //dias corridos
        params.put('days', Integer.valueOf(config.DiasCorridos__c));
        //data de expiração
        params.put('expDate', Date.valueOf(config.DataExpiracao__c));
        //data de expiração para perfis
        params.put('expDateProfile', Date.valueOf(config.DataExpiracaoPerfis__c));
        return params;
    }
    
    //parâmetros para o batch de pedidos (Limite expiração)
    public static Map<String, Object> getOrderParams(String developerName){
        Map<String, Object> params = new Map<String, Object>();
        //metadado customizado
        ConfigLimiteExpiracao__mdt config = getLimiteExpConfig(developerName);
        //retorna os status a serem verificados
        params.put('status', getPickListValues(config, 'StatusPedido__c'));
        //perfis
        params.put('profiles', getPickListValues(config, 'PerfisConsiderados__c'));
        //segmentos comerciais
        params.put('commercialSegments', getPickListValues(config, 'SegmentosComerciais__c'));
        //dias corridos
        params.put('days', Integer.valueOf(config.DiasCorridos__c));
        //data de expiração
        params.put('expDate', Date.valueOf(config.DataExpiracao__c));
        //data de expiração para perfis
        params.put('expDateProfile', Date.valueOf(config.DataExpiracaoPerfis__c));
        return params;
    }
    
    //retorna a lista de valores das picklists
    public static List<String> getPickListValues(sObject currentObject, string fieldValue){
        List<String> values = new List<String>();
        Schema.sObjectType objType = currentObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        for(Schema.PicklistEntry f : fieldMap.get(fieldValue).getDescribe().getPickListValues()){
            values.add(f.getLabel());
        }
        return values;
    }
    
    //Metadata
    public static ConfigLimiteExpiracao__mdt getLimiteExpConfig(String developerName){
        return [SELECT DataExpiracao__c, DataExpiracaoPerfis__c, DiasCorridos__c, 
                StatusOportunidade__c, StatusPedido__c
                FROM ConfigLimiteExpiracao__mdt
                WHERE DeveloperName IN: new List<String>{developerName}];
    }
     
}