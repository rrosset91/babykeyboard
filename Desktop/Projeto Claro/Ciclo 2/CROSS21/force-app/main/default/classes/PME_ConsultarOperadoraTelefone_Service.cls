/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
Classe de serviço responsável por montar a chamada do serviço de consulta de operadora.
* Controle de Versão
* ---------------------------------------------------------------
* Data: 27/02/2019    
* Autor: Marcos Aurélio
* Alterações: Inclusão do método getMobileCorporateCustomer.
* ---------------------------------------------------------------
*/

public with sharing class PME_ConsultarOperadoraTelefone_Service {
	
    /*
    * Autor: Marcos Aurelio - Deloitte
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
        obj: Recebe a informação do número do telefone a ser verificado.
        Método contrói a URL com base no parametro recebido e faz a chamada da API.
        Recebe um JSON como retorno e o tranforma em objeto, devolvendo assim a informação para a classe que a invocou.
    */    
	public static PME_ConsultarOperadoraTelefone_Response getInfo(Object obj){
		String endPointMethod = '?phoneLineNumber=' + (String)obj;
		String serviceName = 'PME_ConsultarOperadoraTelefone'; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
		   	
		try{   
            endPointMethod = param.EndPoint__c + endPointMethod;        
		
			if(Test.isRunningTest()){
				Test.setMock(HttpCalloutMock.class, new PME_ConsultarOperadoraTelefone_Mock());
			}
			HttpResponse res = CEC_PME_HttpReq.sendReq(serviceName, endPointMethod);
						
			System.Debug('Response JSON: ' + res.getBody());
			if(res.getStatus() == 'OK'){
				PME_ConsultarOperadoraTelefone_Response response = (PME_ConsultarOperadoraTelefone_Response)JSON.deserialize(res.getBody(), PME_ConsultarOperadoraTelefone_Response.class);
				System.Debug('Response: ' + response);
				return response;
			}
			
			return null;	
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