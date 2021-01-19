/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe de teste responsável por testar a funcionalidade implementada na classe CEC_PME_ListarEndereco e suas dependências.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
@isTest
private class CEC_PME_ListarEndereco_Test {
    @testSetup static void setup() {
		ServiceParameter__c param = new ServiceParameter__c();
		param.name = 'CEC_PME_ListarEndereco';
		param.EndPoint__c = 'https://test/salesforce.com';
		param.Method__c = 'GET';
		
		insert param;
		
		Account acc = new Account();
		acc.Name = 'Conta Classe teste';
		
		insert acc;
    }
	
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário de sucesso, onde há o retorno contendo os dados de endereço.
*/    	
	@isTest static void testConsultarendereco() {
     	CEC_PME_ListarEndereco endereco = new CEC_PME_ListarEndereco(); 
     	String cep = '00000-000';
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cep',cep);
     	
     	Test.startTest();
     	Boolean retorno = endereco.invokeMethod('getAddressList',inputMap,outMap,options);
     	
     	CEC_PME_ListarEndereco_Response.address enderecoRetorno = (CEC_PME_ListarEndereco_Response.address)outMap.get('endereco');
     	
     	System.assertEquals(enderecoRetorno.logradouro, 'AUGUSTOFRANCODESOUSA');
     	
     	Test.stopTest();
     	
     }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário onde o nome do método não é enviado na chamada.
*/     
     @isTest static void testNoMethodName() {
     	CEC_PME_ListarEndereco endereco = new CEC_PME_ListarEndereco(); 
     	String cep = '00000-000';
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cep',cep);
     	
     	Boolean retorno = endereco.invokeMethod('',inputMap,outMap,options);
     	System.assertEquals(retorno, false);
     	
     	System.Debug('OutMap' + outMap);
     	
     }
}