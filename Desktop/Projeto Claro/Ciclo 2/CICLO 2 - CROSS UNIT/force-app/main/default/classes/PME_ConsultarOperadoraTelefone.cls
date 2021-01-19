/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
Classe que implementa a lógica reponsável pela consulta de operadora.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
public class PME_ConsultarOperadoraTelefone {
	private PME_ConsultarOperadoraTelefone() {}
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
   Obtém a operadora do número informado invocando o serviço.
*/    
	
   	@AuraEnabled
   	public static Map<String, String> getListTelephoneInfo(List<String> lstTelephone){
   		Map<String, String> retorno = new Map<String, String>();
   		
   		String listNumber = '';
   		String returnMessage;
   		
   		for(String telephone : lstTelephone){
            if(telephone.length() > 0){
            	listNumber+= telephone + ',';    
            }
   		}
   		
   		if(listNumber.length() > 0){
   			listNumber = listNumber.mid(0,listNumber.length()-1);
   		}
        
        try{
        	PME_ConsultarOperadoraTelefone_Response res = PME_ConsultarOperadoraTelefone_Service.getInfo(listNumber);    
        
            if(res.data != Null){
                if(res.data.validRequests != Null){
                    for(PME_ConsultarOperadoraTelefone_Response.ValidRequests validTelephone : res.data.validRequests){
                        if(validTelephone.requestedTickets != Null){
                            for(PME_ConsultarOperadoraTelefone_Response.requestedTickets requestedTickets : validTelephone.requestedTickets){
                                String telephone = requestedTickets.phoneLineNumberType.phoneLineNumber;
                                String operatorName = validTelephone.donorOperator.name;
                                retorno.put(telephone,operatorName);        
                            }
                        }
                        
                    }
                }
                
                
                if(res.data.rejectedRequests != Null){
                    for(PME_ConsultarOperadoraTelefone_Response.RejectedRequests rejectedTelephone : res.data.rejectedRequests){
                        for(PME_ConsultarOperadoraTelefone_Response.RequestedTickets requestedTickets : rejectedTelephone.requestedTickets){
                            String telephone = requestedTickets.phoneLineNumberType.phoneLineNumber;
                            String detail = '';
                            if(rejectedTelephone.rejectionReason.reasonId.equals('NUMERO_NA_CLARO')){
                                detail = 'CLARO';
                            } else {
                            	detail = rejectedTelephone.detail;    
                            }
                            
                            retorno.put(telephone,detail);    
                        }
                    }    
                }
                
            }
        }catch(Exception e){  
      		System.debug('Exception type caught: ' + e.getTypeName());   
        	System.debug('Message: ' + e.getMessage());   
        	System.debug('Cause: ' + e.getCause());
        	System.debug('Line number: ' + e.getLineNumber());   
        	System.debug('Stack trace: ' + e.getStackTraceString());
       }
		
		return retorno;
   	}
}