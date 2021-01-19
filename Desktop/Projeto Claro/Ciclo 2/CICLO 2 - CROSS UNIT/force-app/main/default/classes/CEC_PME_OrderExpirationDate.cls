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

public class CEC_PME_OrderExpirationDate {
    /*
    * Autor: Otávio Fonseca - Deloitte
    * Descrição: Método para buscar a data de expiração no momento da criação do pedido
    */    
	public static void getExpirationDate(Set<Id> setOrder)
    {
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

			List<Order> lstOrder = [SELECT Id, CreatorProfile__c, Segmento_Comercial__c, vlocity_cmt__ExpirationDate__c, Status 
                                    FROM Order 
                                    WHERE Id IN :setOrder];            
    
            for(Limite_Expiracao__mdt limiteExp : lstExpiration){
                if (String.isNotBlank(limiteExp.Segmento__c)) {
                    mapLimiteSeg.put(limiteExp.Segmento__c, limiteExp);
                } else if (String.isNotBlank(limiteExp.Perfil__c)) {
                    mapLimitePerf.put(limiteExp.Perfil__c, limiteExp);
                } else {
                    // Padrão
                    ultimoDiaPadrao = limiteExp.UltimoDiaDoMes__c;
                    diasCorridosPadrao = limiteExp.Dias_corridos_pedido__c;
                }
            } 
           
            for(Order order : lstOrder){   
                if (mapLimitePerf.containsKey(String.valueOf(order.CreatorProfile__c))) {
                    dataPadrao = false;
                    ultimoDia = mapLimitePerf.get(order.CreatorProfile__c).UltimoDiaDoMes__c;
                    diasCorridos = mapLimitePerf.get(order.CreatorProfile__c).Dias_corridos_simulacao__c;
                } else if (mapLimiteSeg.containsKey(String.valueOf(order.Segmento_Comercial__c ))) {
                    dataPadrao = false;
                    ultimoDia = mapLimiteSeg.get(order.Segmento_Comercial__c ).UltimoDiaDoMes__c;
                    diasCorridos = mapLimiteSeg.get(order.Segmento_Comercial__c ).Dias_corridos_simulacao__c;
                }
                           
				if (dataPadrao) {
                    if (ultimoDiaPadrao) {
                    	order.vlocity_cmt__ExpirationDate__c = ultimoDiaMes;  
                    } else {
                        order.vlocity_cmt__ExpirationDate__c = Date.valueOf(Datetime.now()).addDays(diasCorridosPadrao.intValue());
                    }      
                } else {
                    if (ultimoDia) {
                        order.vlocity_cmt__ExpirationDate__c = ultimoDiaMes;  
                    } else {
                        order.vlocity_cmt__ExpirationDate__c = Date.valueOf(Datetime.now()).addDays(diasCorridos.intValue());
                    }                    
                }                   
            }     
            update lstOrder;            
        } catch (Exception e)
        {
            System.debug('Exception >> '+e.getMessage());
            System.debug('Exception trace >> '+e.getStackTraceString());
        }
    }
    
    /*
    * Autor: Otávio Fonseca - Deloitte
    * Descrição: Método para buscar a data de expiração no momento da alteração do status do pedido
    */      
    public static void updExpirationDate(List<Order> lstOrder) {
        try {    
            List<Limite_Expiracao__mdt> lstExpSegmento = CEC_PME_UtilsLimiteExpiracao.getLimiteExpSeg();  
			Date ultimoDiaMes = CEC_PME_UtilsLimiteExpiracao.ultimoDiaMes();  

            for (Order order : lstOrder) {                
                //if (order.vlocity_cmt__ExpirationDate__c == null) {
                    for (Limite_Expiracao__mdt mdtSegmento : lstExpSegmento) {  
                        if (order.Segmento_Comercial__c == mdtSegmento.Segmento__c && order.status.toUpperCase() == mdtSegmento.Status__c.toUpperCase()) { 
                            if (mdtSegmento.UltimoDiaDoMes__c) {
                                order.vlocity_cmt__ExpirationDate__c = ultimoDiaMes;
                            } else if (mdtSegmento.Dias_corridos_pedido__c != null) {
                                order.vlocity_cmt__ExpirationDate__c = Date.valueOf(Datetime.now()).addDays(mdtSegmento.Dias_corridos_pedido__c.intValue());                                
                            }                           
                        }
                    }
                //}
            }
            
            //update lstOrder;
        } catch (Exception e)
        {
            System.debug('Exception >> '+e.getMessage());
            System.debug('Exception trace >> '+e.getStackTraceString());
        }
    }   
}