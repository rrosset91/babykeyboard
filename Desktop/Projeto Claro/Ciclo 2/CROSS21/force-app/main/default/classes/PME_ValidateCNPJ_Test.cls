/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
* Classe de teste responsável por testar a funcionalidade implementada na classe PME_ValidateCNPJ e suas dependências.
* IMPORTANTE: para o Mock da mobilesubscribershistory funcionar corretamente, é necessário usar os CNPJs do mock
* Controle de Versão
* ---------------------------------------------------------------
* Autor: João Rodrigues
* Data: 02/06/2020
* Descrição: DDP 128209 - Aumentando a quantidade de testes, antes estava em 56% apenas
*/

@isTest
private class PME_ValidateCNPJ_Test {
      @testSetup static void setup() {
		ServiceParameter__c param = new ServiceParameter__c();
		param.name = 'PME_ValidateCNPJ';
		param.EndPoint__c = 'https://test/salesforce.com';
		param.Method__c = 'GET';
		
		insert param;
          
        ServiceParameter__c param2 = new ServiceParameter__c();
		param2.name = 'CEC_PME_MobileCustomer';
		param2.EndPoint__c = 'https://test/salesforce.com';
		param2.Method__c = 'GET';
		
		insert param2;
        
        ServiceParameter__c param3 = new ServiceParameter__c();
		param3.name = 'CEC_PME_MobileCorporateCustomer';
		param3.EndPoint__c = 'https://test/salesforce.com';
		param3.Method__c = 'GET';
		
		insert param3;
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário de validação de CNPJ, onde o CNPJ enviado é um CNPJ válido.
*/      
     @isTest static void testValidateCNPJSuccess(){
     	PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
     	String cnpj = '64520981000180';
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cnpj',cnpj);
     	
     	Test.startTest();
     	Boolean retorno = validate.invokeMethod('validateCNPJ',inputMap,outMap,options);
     	System.assertEquals(outMap.get('cnpjValidado'), true);
     	Test.stopTest();
     	
	 }
	 
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário de validação de CNPJ, onde o CNPJ enviado é um CNPJ inválido.
*/           
     @isTest static void testValidateCNPJFail(){
     	PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
     	String cnpj = '64520981000189';
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cnpj',cnpj);
     	
     	Test.startTest();
     	Boolean retorno = validate.invokeMethod('validateCNPJ',inputMap,outMap,options);
     	System.assertEquals(outMap.get('cnpjValidado'), false);
     	Test.stopTest();
     	
     }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário de exception.
*/           
     @isTest static void testValidateCNPJException(){
     	PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
     	String cnpj;
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cnpj',cnpj);
     	
     	Test.startTest();
     	Boolean retorno = validate.invokeMethod('validateCNPJ',inputMap,outMap,options);
     	System.assertEquals(retorno, false);
     	Test.stopTest();
     	
     }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário onde o nome do método não é enviado na chamada.
*/           
     @isTest static void testValidateCNPJNoMethodName(){
     	PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
     	String cnpj;
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
		options.put('cnpj',cnpj);
     	
     	Boolean retorno = validate.invokeMethod('',inputMap,outMap,options);
     	
     	System.assertEquals(retorno, false);
     }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Testa o cenário de conversão de lead.
*/           
     @isTest static void convertLead(){
     	PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
     	Map<String,Object> inputMap = new Map<String,Object>();
		Map<String,Object> outMap  = new Map<String,Object>();
		Map<String,Object> options  = new Map<String,Object>();
		
     	Lead ld = new Lead(lastName = 'Teste', Company = 'Teste');
     	   
        insert ld;
        
	    inputMap.put('DRId_Lead',ld.Id);
        
        Test.startTest();
        Boolean retorno = validate.invokeMethod('convertLeadInAccountContact',inputMap,outMap,options);
        System.assertEquals(retorno, true);
        Test.stopTest();
     }

/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário de validação de CPF, onde o CPF enviado é um CPF válido.
*/      
	@isTest static void testValidateCPFSuccess(){
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cpf = '20460984047';
		Map<String,Object> inputMap = new Map<String,Object>();
	   	Map<String,Object> outMap  = new Map<String,Object>();
	   	Map<String,Object> options  = new Map<String,Object>();
	
	   	options.put('CPF',cpf);

		Test.startTest();
		Boolean retorno = validate.invokeMethod('validateCPF',inputMap,outMap,options);
		System.assertEquals(outMap.get('cpfValidado'), true);
		Test.stopTest();

	}
/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário de validação de CPF, onde o CPF enviado é um CPF inválido.
*/      
	@isTest static void testValidateCPFFail(){
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cpf = '000';
		Map<String,Object> inputMap = new Map<String,Object>();
		   Map<String,Object> outMap  = new Map<String,Object>();
		   Map<String,Object> options  = new Map<String,Object>();
	
		   options.put('CPF',cpf);
		
		Test.startTest();
		Boolean retorno = validate.invokeMethod('validateCPF',inputMap,outMap,options);
		System.assertEquals(outMap.get('cpfValidado'), false);
		Test.stopTest();
		
	}

/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário onde um cliente tem linhas ativas na primeira página
*/    
	@isTest static void testConsultarDadosConsolidadosClienteFirstPageActive() {
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cnpj = '00796754000108';
		Map<String,Object> inputMap = new Map<String,Object>();
	   	Map<String,Object> outMap  = new Map<String,Object>();
	   	Map<String,Object> options  = new Map<String,Object>();
	
	   	options.put('cnpj',cnpj);

		Test.startTest();
		Boolean retorno = validate.invokeMethod('consultarDadosConsolidadosCliente',inputMap,outMap,options);
		System.assertEquals(outMap.get('segment'), 'PME');
		System.assertEquals(outMap.get('activeLines'), true);

		Test.stopTest();

	}
/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário onde um cliente não tem linhas ativas na primeira página
*/    
	@isTest static void testConsultarDadosConsolidadosClienteAllPagesInactive() {
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cnpj = '53188322000172';
		Map<String,Object> inputMap = new Map<String,Object>();
		   Map<String,Object> outMap  = new Map<String,Object>();
		   Map<String,Object> options  = new Map<String,Object>();

		   options.put('cnpj',cnpj);

		Test.startTest();
		Boolean retorno = validate.invokeMethod('consultarDadosConsolidadosCliente',inputMap,outMap,options);
		System.assertEquals(outMap.get('segment'), 'PME');
		System.assertEquals(outMap.get('activeLines'), false);

		Test.stopTest();

	}

/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário onde um cliente não possui subscribers
*/  
	@isTest static void testConsultarDadosConsolidadosClienteNoSubs() {
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cnpj = '69970002000100';
		Map<String,Object> inputMap = new Map<String,Object>();
	   Map<String,Object> outMap  = new Map<String,Object>();
	   Map<String,Object> options  = new Map<String,Object>();
	
	   options.put('cnpj',cnpj);

		Test.startTest();
		Boolean retorno = validate.invokeMethod('consultarDadosConsolidadosCliente',inputMap,outMap,options);
		System.assertEquals(outMap.get('isClient'), true);
		System.assertEquals(outMap.get('activeLines'), false);

		Test.stopTest();

	}

/*
* Autor: João Rodrigues
* Descrição: DDP 128209 - Aumentando a quantidade de testes...
* Testa o cenário onde um cliente não possui cadastro no mobile, só no CPC
*/  
	@isTest static void testConsultarDadosConsolidadosClienteCPC() {
		PME_ValidateCNPJ validate = new PME_ValidateCNPJ(); 
		String cnpj = '05438120000199';
		Map<String,Object> inputMap = new Map<String,Object>();
	   	Map<String,Object> outMap  = new Map<String,Object>();
	   	Map<String,Object> options  = new Map<String,Object>();

	   	options.put('cnpj',cnpj);

		Test.startTest();
		Boolean retorno = validate.invokeMethod('consultarDadosConsolidadosCliente',inputMap,outMap,options);
		System.assertEquals(outMap.get('isClient'), true);
		System.assertEquals(outMap.get('activeLines'), false);

		Test.stopTest();

	}

}