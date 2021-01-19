/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
Classe de teste responsável por testar a funcionalidade implementada na classe PME_ConsultarOperadoraTelefone e suas dependências.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

@isTest
private class PME_ConsultarOperadoraTelefone_Test {
	@testSetup static void setup() {
		ServiceParameter__c param = new ServiceParameter__c();
		param.name = 'PME_ConsultarOperadoraTelefone';
		param.EndPoint__c = 'https://test/salesforce.com';
		param.Method__c = 'GET';
		
		insert param;
    }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
Testa o cenário de consulta de portabilidade.
*/    
	@isTest static void testConsultarTelefone() {
     	
     	List<String> listTelephone = new List<String>();
		listTelephone.add('11945867706');
		listTelephone.add('11975278987');
		listTelephone.add('11000000001');
	
		Test.startTest();
		Map<String, String> retorno = PME_ConsultarOperadoraTelefone.getListTelephoneInfo(listTelephone);
		System.assertEquals(retorno.get('11945867706'), 'Telefones não podem ser portados pois já estão na Claro.');
		System.assertEquals(retorno.get('11975278987'), 'VIVO S.A.');
		System.assertEquals(retorno.get('11000000001'), 'Prefixos não cadastrados no SAPN da Anatel.');
     	Test.stopTest();
    }
}