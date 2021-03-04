/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe de serviço responsável por montar a chamada do serviço de listar endereço.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
public with sharing class CEC_PME_ListarEndereco_Service {
	
	private CEC_PME_ListarEndereco_Service(){}
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
 	obj: Recebe a informação do CEP a ser verificado.
	Método contrói a URL com base no parametro recebido e faz a chamada da API.
	Recebe um JSON como retorno e o tranforma em objeto, devolvendo assim a informação para a classe que a invocou.
*/	
	public static CEC_PME_ListarEndereco_Response getInfo(Object obj){
		String endPointMethod = '&zipCode=' + (String)obj;
		String serviceName = 'CEC_PME_ListarEndereco'; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
		    	
		try{   
            endPointMethod = param.EndPoint__c + endPointMethod;       
		
			if(Test.isRunningTest()){
				Test.setMock(HttpCalloutMock.class, new CEC_PME_ListarEndereco_Mock());
			}
			HttpResponse res = CEC_PME_HttpReq.sendReq(serviceName, endPointMethod);
						
			System.Debug('Response JSON: ' + res.getBody());
			
			CEC_PME_ListarEndereco_Response response = (CEC_PME_ListarEndereco_Response)JSON.deserialize(res.getBody(), CEC_PME_ListarEndereco_Response.class);
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