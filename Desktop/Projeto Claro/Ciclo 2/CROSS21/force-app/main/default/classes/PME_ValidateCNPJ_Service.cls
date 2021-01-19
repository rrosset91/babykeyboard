/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe de serviço responsável por montar a chamada do serviço do AOG de validação de CNPJ.
* Controle de Versão
* ---------------------------------------------------------------
* Data: 27/02/2019    
* Autor: Marcos Aurélio
* Alterações: Inclusão do método getMobileCorporateCustomer.
* ---------------------------------------------------------------
* Data: 02/06/2020    
* Autor: João Rodrigues
* Alterações: DDP 128209 - Alteração do método getInfoByClientActive para usar a paginação corretamente.
*/
public with sharing class PME_ValidateCNPJ_Service {
	
	private PME_ValidateCNPJ_Service(){}
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
        obj: Recebe a informação do CNPJ a ser verificado.
        Método contrói a URL com base no parametro recebido e faz a chamada da API.
        Recebe um JSON como retorno e o tranforma em objeto, devolvendo assim a informação para a classe que a invocou.
    */    
    
	public static PME_ValidateCNPJ_Response getInfoByClient(Object obj){
		String endPointMethod = '?cnpj=' + (String)obj;
        String serviceName = 'PME_ValidateCNPJ'; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
		    	
		try{   
            endPointMethod = param.EndPoint__c + endPointMethod;         
            
			if(Test.isRunningTest()){
				Test.setMock(HttpCalloutMock.class, new PME_ValidateCNPJ_MockGenerate());
			}
            
			HttpResponse res = CEC_PME_HttpReq.sendReq(serviceName, endPointMethod);
			
			System.Debug('Response JSON: ' + res.getBody());
			
			PME_ValidateCNPJ_Response response = (PME_ValidateCNPJ_Response)JSON.deserialize(res.getBody(), PME_ValidateCNPJ_Response.class);
			System.Debug('Response: ' + response);
			System.Debug('Response Status: ' + res.getStatus());
			
			return response;	
		}catch(Exception e){
   	 		System.debug('Exception type caught: ' + e.getTypeName());   
    		System.debug('Message: ' + e.getMessage());   
    		System.debug('Cause: ' + e.getCause());
    		System.debug('Line number: ' + e.getLineNumber());   
    		System.debug('Stack trace: ' + e.getStackTraceString());
    		
    		return null;
   		}
	}
	/*
	* Autor: Marcos Aurelio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
	* Método responsável por construir a URL no contexto cliente Ativo.
	*/    
	public static PME_ValidateCNPJ_Response getInfoByClientActive(Object obj, Integer pageNumber, Integer recordsLimit){
		String param = (String)obj + '&status=ATIVO,PRE_ATIVO,SUSPENSO' + '&page=' + pageNumber + '&limit=' + recordsLimit ;
		return PME_ValidateCNPJ_Service.getInfoByClient(param);
	}

	public static PME_ValidateCNPJ_Response getInfoByClientActive(Object obj){
		String param = (String)obj + '&status=ATIVO,PRE_ATIVO,SUSPENSO&page=1&limit=1' ;
		return PME_ValidateCNPJ_Service.getInfoByClient(param);
	}
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
    Método responsável por obter as informações do cliente no mobile.
    */    
    public static CEC_PME_MobileCustomer_Response getClientMobile(Object obj){
		String endPointMethod = '?documentNumberCNPJ=' + (String)obj;
        String serviceName = 'CEC_PME_MobileCustomer'; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName);          
		
		try{
            endPointMethod = param.EndPoint__c + endPointMethod;           
            
			if(Test.isRunningTest()){
				Test.setMock(HttpCalloutMock.class, new CEC_PME_MobileCustomer_Mock());
			}
			HttpResponse res = CEC_PME_HttpReq.sendReq('CEC_PME_MobileCustomer',endPointMethod);
			
			System.Debug('Response JSON: ' + res.getBody());
			
			CEC_PME_MobileCustomer_Response response = (CEC_PME_MobileCustomer_Response)JSON.deserialize(res.getBody(), CEC_PME_MobileCustomer_Response.class);
			System.Debug('Response: ' + response);
			System.Debug('Response Status: ' + res.getStatus());
			
			return response;	
		}catch(Exception e){
   	 		System.debug('Exception type caught: ' + e.getTypeName());   
    		System.debug('Message: ' + e.getMessage());   
    		System.debug('Cause: ' + e.getCause());
    		System.debug('Line number: ' + e.getLineNumber());   
    		System.debug('Stack trace: ' + e.getStackTraceString());
    		
    		return null;
   		}
    }
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 8]
    Método responsável por obter as informações do cliente no CPC.
    */        
    public static CEC_PME_MobileCorporateCustomer_Response getMobileCorporateCustomer(Object obj){
		String endPointMethod = '?documentNumberCNPJ=' + (String)obj;
        String serviceName = 'CEC_PME_MobileCorporateCustomer'; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
			
		try{
            endPointMethod = param.EndPoint__c + endPointMethod;            
            
			if(Test.isRunningTest()){
				Test.setMock(HttpCalloutMock.class, new CEC_PME_MobileCorporateCustomer_Mock());
			}
			HttpResponse res = CEC_PME_HttpReq.sendReq(serviceName, endPointMethod);
			
			System.Debug('Response JSON: ' + res.getBody());
			
			CEC_PME_MobileCorporateCustomer_Response response = (CEC_PME_MobileCorporateCustomer_Response)JSON.deserialize(res.getBody(), CEC_PME_MobileCorporateCustomer_Response.class);
			System.Debug('Response: ' + response);
			System.Debug('Response Status: ' + res.getStatus());
			
			return response;	
		}catch(Exception e){
   	 		System.debug('Exception type caught: ' + e.getTypeName());   
    		System.debug('Message: ' + e.getMessage());   
    		System.debug('Cause: ' + e.getCause());
    		System.debug('Line number: ' + e.getLineNumber());   
    		System.debug('Stack trace: ' + e.getStackTraceString());
    		
    		return null;
   		}
    }
}