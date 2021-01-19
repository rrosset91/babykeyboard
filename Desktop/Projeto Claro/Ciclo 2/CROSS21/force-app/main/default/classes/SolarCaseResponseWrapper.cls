public with sharing class SolarCaseResponseWrapper 
{
	public Integer codigo   {get; set;} 
	public String mensagem  {get; set;} 
	public String status    {get; set;} 
	public String fluxo     {get; set;} 
	public String casoId    {get; set;} 
    public String idCliente {get; set;} 
	public String protocolo {get; set;} 
    
    public static SolarCaseResponseWrapper SolarCaseResponse(Case requestCase){
		SolarCaseResponseWrapper resultResponse = new SolarCaseResponseWrapper();
		
        resultResponse.casoId 	 = requestCase.Id;
        resultResponse.idCliente = requestCase.ContractBillingAccount__c;
        // resultResponse.idCliente = requestCase.AccountId;
        resultResponse.protocolo = requestCase.ProtocolNumber__c;
        resultResponse.codigo    = 1; 									//Dados mock - sem essa informação
        resultResponse.mensagem  = 'Mensagem retornada'; 				//Dados mock - sem essa informação
        resultResponse.status    = 'Status retornado'; 					//Dados mock - sem essa informação
		resultResponse.fluxo     = 'Fluxo Retornado'; 					//Dados mock - sem essa informação
		
		System.debug('Campos com mock ainda falta definir');

        return resultResponse;   
    }
    
}