/*
 * @author:      Roger Rosset
 * @company:     IBM - Bluewolf
 * @description: Teste para a classe InvoiceRefundController
 */
@isTest
public class InvoiceRefundControllerTest { //PARAMETRIZAÇAO DO TESTE
	@TestSetup
	static void charge() {
		List<ServiceParameter__c> service = new List<ServiceParameter__c>();
		ServiceParameter__c refundSettings = new ServiceParameter__c();
		refundSettings.name = 'InvoiceRefund';
		refundSettings.EndPoint__c = 'callout:OAGClaro/contactrecords';
		refundSettings.Method__c = 'GET';
		refundSettings.Timeout__c = 120000;
		refundSettings.ReturnMock__c = false;
		service.add(refundSettings);
		insert service;

		Id recordTypeIdAccount   = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); 
        
        Account contrato =  new Account(
            RecordTypeId = recordTypeIdAccount,
            name = 'Teste',
            ContractReferenceNumber__c = '229531991',
            StatusLegado__c  =  'Conectado' ,
            vlocity_cmt__CustomerValue__c = 'Black'
        );
        Insert contrato;

		// Contract contrato = new Contract();
		// contrato.AccountId = acc.Id;
		// insert contrato;

		Case cs = new Case();
		cs.ContractBillingAccount__c = contrato.Id;
		// cs.Contract__c = contrato.Id;
		cs.OpenDateRobot__c = System.now();
		insert cs;

		// Asset asset = new Asset();
	}

	//TESTE PARA OS MÉTODOS QUE RETORNAM LISTAS DE OPÇOES
	@isTest
	static void getPickListTipoPessoaTest() {
		test.startTest();
		List<String> result = InvoiceRefundController.getPickListTipoPessoa();
		test.stopTest();
		system.assertEquals(false, result.isEmpty());
	}

	@isTest
	static void getPickListContaTest() {
		test.startTest();
		List<String> result = InvoiceRefundController.getPickListConta();
		test.stopTest();
		system.assertEquals(false, result.isEmpty());
	}

	@isTest
	static void getPickListBancoTest() {
		test.startTest();
		List<String> result = InvoiceRefundController.getPickListBanco();
		test.stopTest();
		system.assertEquals(false, result.isEmpty());
	}

	@isTest
	static void getPickListMotivoTest() {
		test.startTest();
		List<String> result = InvoiceRefundController.getPickListMotivo();
		test.stopTest();
		system.assertEquals(false, result.isEmpty());
	}
	//TESTE DA CLASSE PRINCIPAL PARA CHAMADA POST NA API DE REEMBOLSO
	@isTest
	static void postInvoiceRefundTest() {
		String contractNumber = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		InvoiceRefundWrapper wrp = new InvoiceRefundWrapper();
		wrp.agencia = 123;
		wrp.banco = '';
		wrp.pessoa = 'Pessoa Física';
		wrp.descricao = 'MockDescription';
		wrp.email = 'mock@email.com';
		wrp.nomeTitular = 'MockName';
		wrp.titular = 'Terceiro';
		wrp.cnpj = '11111111111111';
		wrp.cpf = '33333333333';
		wrp.conta = 111111;
		wrp.digito = 0;
		wrp.refundType = 'CC';
		InvoiceRefundMock mock = new InvoiceRefundMock(
			'{"apiVersion":"1;2018-06-21","transactionId":"Id-e1af325f7a0ab9094229912e","data":{"user":{"login":"MCIDA","userName":null,"partyId":{"number":null,"type":"CPF"},"emailcontact":{"emailAddress":null},"telephoneNumber":{"areaCode":null,"number":null,"extensionNumber":null}},"eventDate":null,"note":"#infoMaker#","sourceEvent":"CLARO","eventType":{"identifier":"861481999","description":null},"type":{"identifier":"1129","description":"FI2 - RS2 - ANALISE DE REEMBOLSO"},"contact":{"user":{"login":null,"userName":null,"partyId":{"number":null,"type":"CPF"},"emailContact":{"emailAddress":null},"telephoneNumber":{"areaCode":null,"number":null,"extensionNumber":null}},"contactType":{"identifier":null,"description":null},"name":"MockTest","interactionNumber":null,"protocol":null,"contactMedium":{"telephoneNumber":{"areaCode":null,"number":null,"extensionNumber":null,"type":null},"contactMedium":{"emailContact":{"emailAddress":null},"urbanPropertyAddress":{"addressId":null,"country":null,"placeId":null,"cityId":null,"cityName":null,"postCode":null,"neighborhood":null,"streetType":null,"streetTypeId":null,"streetName":null,"streetNrFirst":null,"urbanPropertySubAddress":null,"complementarySubAddress":null,"boxNr":null}}}},"message":"Sucess"}}',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);
		test.startTest();
		Map<String, Object> result = InvoiceRefundController.postInvoiceRefund('', contractNumber, 'MockTest', '#infoMaker', '004', '', accId, wrp);
		test.stopTest();
		system.assertEquals(true, result.get('success'));
	}
}