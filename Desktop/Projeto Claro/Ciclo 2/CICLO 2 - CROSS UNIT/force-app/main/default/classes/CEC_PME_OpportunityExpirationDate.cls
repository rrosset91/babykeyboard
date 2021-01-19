/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/07/2019
* Descrição: Utilizada para preenchimento do campo Data de Expiração
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public class CEC_PME_OpportunityExpirationDate {
    /*
    * Autor: Otávio Fonseca - Deloitte
    * Descrição: Método para buscar a data de expiração no momento da criação da simulação
    */
	public static void getExpirationDate(Set<Id> setOppt) {
    	try {
            Boolean dataPadrao = true;
            Boolean ultimoDiaPadrao = true;
            Decimal diasCorridosPadrao;              
            
            Boolean ultimoDia = true;            
            Decimal diasCorridos;           
            
            Date ultimoDiaMes = CEC_PME_UtilsLimiteExpiracao.ultimoDiaMes(); 
            List<Limite_Expiracao__mdt> lstExpiration = CEC_PME_UtilsLimiteExpiracao.getLimiteExp();              

            Map<String, Limite_Expiracao__mdt> mapLimitePerf = new Map<String, Limite_Expiracao__mdt>();
            Map<String, Limite_Expiracao__mdt> mapLimiteSeg = new Map<String, Limite_Expiracao__mdt>();    
    
            List<Opportunity> lstOppt = [SELECT StageName, CreatorProfile__c, CommercialSegment2__c, Expiration_Date__c 
                                         FROM Opportunity 
                                         WHERE Id IN :setOppt];
            
            for(Limite_Expiracao__mdt limiteExp : lstExpiration){
                if (String.isNotBlank(limiteExp.Segmento__c)) {
                    mapLimiteSeg.put(limiteExp.Segmento__c, limiteExp);
                } else if (String.isNotBlank(limiteExp.Perfil__c)) {
                    mapLimitePerf.put(limiteExp.Perfil__c, limiteExp);
                } else {
                    // Padrão
                    ultimoDiaPadrao = limiteExp.UltimoDiaDoMes__c;
                    diasCorridosPadrao = limiteExp.Dias_corridos_simulacao__c;
                }
            } 
                  
            for(Opportunity oppt : lstOppt){                
                if (mapLimitePerf.containsKey(String.valueOf(oppt.CreatorProfile__c))) { 
                    dataPadrao = false;
                    ultimoDia = mapLimitePerf.get(oppt.CreatorProfile__c).UltimoDiaDoMes__c;
                    diasCorridos = mapLimitePerf.get(oppt.CreatorProfile__c).Dias_corridos_simulacao__c;
                } else if (mapLimiteSeg.containsKey(String.valueOf(oppt.CommercialSegment2__c ))) {
                    dataPadrao = false;
                    ultimoDia = mapLimiteSeg.get(oppt.CommercialSegment2__c ).UltimoDiaDoMes__c;
                    diasCorridos = mapLimiteSeg.get(oppt.CommercialSegment2__c ).Dias_corridos_simulacao__c;
                }
                             
                if (dataPadrao) {
                    if (ultimoDiaPadrao) {
                    	oppt.Expiration_Date__c = ultimoDiaMes;  
                    } else {
                        oppt.Expiration_Date__c = Date.valueOf(Datetime.now()).addDays(diasCorridosPadrao.intValue());
                    }      
                } else {
                    if (ultimoDia) {
                        oppt.Expiration_Date__c = ultimoDiaMes;  
                    } else {
                        oppt.Expiration_Date__c = Date.valueOf(Datetime.now()).addDays(diasCorridos.intValue());
                    }                    
                }               
            }
      
            update lstOppt;            
        } catch (Exception e)
        {
            System.debug('Exception >> '+e.getMessage());
            System.debug('Exception trace >> '+e.getStackTraceString());
        }
    }
    
    /*
    * Autor: Otávio Fonseca - Deloitte
    * Descrição: Método para buscar a data de expiração no momento da alteração do status da simulação
    */    
    public static void updExpirationDate(List<Opportunity> lstOppt) {
        try { 
            List<Limite_Expiracao__mdt> lstExpSegmento = CEC_PME_UtilsLimiteExpiracao.getLimiteExpSeg(); 
			Date ultimoDiaMes = CEC_PME_UtilsLimiteExpiracao.ultimoDiaMes();   
            
            for (Opportunity oppt : lstOppt) {                    
                //if (oppt.Expiration_Date__c == null) {
                    for (Limite_Expiracao__mdt mdtSegmento : lstExpSegmento) {                       
                        if (oppt.CommercialSegment2__c == mdtSegmento.Segmento__c && oppt.StageName.toUpperCase() == mdtSegmento.Status__c.toUpperCase()) {   
                            if (mdtSegmento.UltimoDiaDoMes__c) {
                                oppt.Expiration_Date__c = ultimoDiaMes;
                            } else if (mdtSegmento.Dias_corridos_simulacao__c != null) {
                                oppt.Expiration_Date__c = Date.valueOf(Datetime.now()).addDays(mdtSegmento.Dias_corridos_simulacao__c.intValue());                                
                            }
                        }
                    }
                //}               
            }
            
            //update lstOppt;
        } catch (Exception e)
        {
            System.debug('Exception >> '+e.getMessage());
            System.debug('Exception trace >> '+e.getStackTraceString());
        }
    } 
}