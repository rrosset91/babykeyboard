/**
* @author: Caio Cesar Leite de Oliveira
* @company: IBM - Bluewolf
* @description: Teste para a classe CEC_DisputeInvoice
*/
@isTest
public class CEC_DisputeInvoiceTest {

	@TestSetup
	static void makeData(){




		//------
		List<String> lstPermission = new List<String>();
		lstPermission.add('AttendanceN1');
		Map<String, List<sObject>> returnProfileMap = UserDataFactory.getMockUserRoleProfiles('System Administrator', 'SupervisorCRC', lstPermission);
		List<sObject> ps = returnProfileMap.get('permissions');
		List<sObject> role1 = returnProfileMap.get('role');
		List<sObject> profile1 = returnProfileMap.get('profile');

		//current user
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//force to avoid mixed dml error
		System.runAs(currentUser) {
			User usuario = UserDataFactory.getSingleUser(role1[0].Id, profile1[0].Id, 'dabliudabliudabliu@gmail.com');
			insert usuario;
			insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps[0].Id);
		}

		Account contrato = AccountDataFactory.getSingleAccount('Billing');
			contrato.ContractReferenceNumber__c = ('41579112');
			// contrato.StatusLegado__c = 'Conectado';
			contrato.CityCode__c = '040';
			contrato.ExternalId__c = '010796139';
			contrato.BusinessUnit__c = 'Net';
		insert contrato;
		system.debug('@@@@ contrato: ' + contrato);

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
		Account consumer = new Account(
			DocumentNumber__c = '64204294987',
			DocumentType__c = 'CPF',
			Name = 'MassaInadimplencia Residencial - Consumidor',
			RecordTypeId = consumerRecordType
		);
		insert consumer;

		Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		Case casoAtual = new Case(
			AccountId = consumer.id,
			ContractBillingAccount__c = contrato.id,
			RecordTypeId = caseRecordType,
			Subject = 'Caso Atual'
		);
		insert casoAtual;

		List<String> lstParameters = new List<String>();
		lstParameters.add('InvoiceAuthority');

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(
			name = 'Teste Param',
			RecordTypeId = recordTypeIdParameter,
			Active__c = true,
			// ContractStatus__c = 'Conectado',
			Channel__c = 'Atendimento',
			ItemType__c = 'MENSALIDADE TV PRINCIPAL',
			ItemQtt__c = 1.0,
			Profile__c = 'CEC_Backoffice',
			Segment__c = 'BLACK',
			Amount__c = 100,
			Business_Division__c = 'Residencial',
			AnatelProconProneTargeting__c = '1;2;3;4;5;6;7;8;9;10',
			DefaultTargeting__c = 'MÉDIO'
		);
		insert parametro;

		parametro = new Parameters__c(
				name = 'Teste Param',
				Channel__c = 'Atendimento',
				RecordTypeId = recordTypeIdParameter,
				Active__c = true,
				Amount__c = 1000,
				Business_Division__c = 'Residencial'
		);
		insert parametro;
		system.debug('@@@@ parametro: ' + parametro);

        List<ServiceParameter__c> params = new List<ServiceParameter__c>();

		ServiceParameter__c customSetting = new ServiceParameter__c(
			Name = 'InvoiceAuthority',
			EndPoint__c = 'InvoiceAuthority',
			Method__c = 'GET',
			Timeout__c = 120
		);
		params.add(customSetting);

		customSetting = new ServiceParameter__c(
			name = 'CustomerProconPropensity',
			EndPoint__c = 'CustomerProconPropensity',
			Method__c = 'GET',
			Timeout__c = 120
		);
		params.add(customSetting);

		customSetting = new ServiceParameter__c(
			name = 'CustomerDefaultSegmetation',
			EndPoint__c = 'CustomerDefaultSegmetation',
			Method__c = 'GET',
			Timeout__c = 120
		);
		params.add(customSetting);

		customSetting = new ServiceParameter__c(
			name = 'ContestItem',
			EndPoint__c = 'ContestItem',
			Method__c = 'POST',
			Timeout__c = 120
		);
		params.add(customSetting);

		customSetting = new ServiceParameter__c(
			name = 'CEC_OAG_Claro_ProtocolNETSMS',
			EndPoint__c = '/CEC_OAG_Claro_ProtocolNETSMS',
			Method__c = 'POST',
			Timeout__c = 120,
			User__c = 'MCIDAS',
			NamedCredential__c = 'OAGNet'
		);
		params.add(customSetting);

		customSetting = new ServiceParameter__c(
			name = 'CEC_OAG_Claro_Protocol',
			EndPoint__c = '/CEC_OAG_Claro_Protocol',
			Method__c = 'POST',
			Timeout__c = 120,
			User__c = 'MCIDAS',
			NamedCredential__c = 'OAGClaro'
		);
		params.add(customSetting);

		insert params;

	}

	@isTest
	static void disputeInvoice() {

		Test.setMock(HttpCalloutMock.class, new Mock());
		User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u) {
			Test.startTest();

			String requestJson = '{"contractNumber":"41579112","operatorCode":"040","channel":"1","idInvoice":"245683775","username":"MCIDA","source":1,"type":"R","invoiceItems":[{"idInvoiceItem":"1538197858","idGroupItem":"1","partnerId":"1","reason":"7","originalValue":15.0,"wishedValue":14.0,"groupDeparture":13.0,"status":"EM ABERTO","notes":"Observação da contestação"},{"idInvoiceItem":null,"idPartnerStatement":"475467791","idDetExtractItem":"3370192963","idGroupItem":"1","partnerId":"2","reason":"160","originalValue":0.53,"wishedValue":0.50,"status":"EM ABERTO","notes":"Observação da contestação"}]}';
			CEC_DisputeInvoice.DisputeInvoiceRequest request = (CEC_DisputeInvoice.DisputeInvoiceRequest)JSON.deserialize(requestJson, CEC_DisputeInvoice.DisputeInvoiceRequest.class);

			System.debug('request==> '+ request );

			CEC_DisputeInvoice.DisputeInvoiceResponse response = CEC_DisputeInvoice.disputeInvoice(request);
			System.debug('response==> '+ response );
			Test.stopTest();

			System.assertNotEquals(null, response);
			System.assertEquals('success', response.message);
			System.assertEquals('200', response.code);
		}
    }

	@isTest
	static void caso() {

        Test.startTest();
		List<CEC_DisputeInvoice.InvoiceItem> invoiceItems = new List<CEC_DisputeInvoice.InvoiceItem>();
		CEC_DisputeInvoice.InvoiceItem invoiceItem = new CEC_DisputeInvoice.invoiceItem();
		invoiceItem.idInvoiceItem = '1579031159';
		invoiceItem.idGroupItem = '1';
		invoiceItem.reason = '1';
		invoiceItem.originalValue = 308.42;
		invoiceItem.wishedValue  = 15.42;
		invoiceItem.disputePercentage = 5;
		invoiceItem.approvationHash = '';
		invoiceItem.notes = 'Observação da contestação';
		invoiceItem.status = 'EM ABERTO';
		invoiceItems.add(invoiceItem);

		Object fieldInvoceItem = invoiceItem.getField('idInvoiceItem');

		CEC_DisputeInvoice.Caso caso = new CEC_DisputeInvoice.caso('1027935', '003321323154',  'EM ABERTO', '13452', invoiceItems);

		CEC_DisputeInvoice.DisputeInvoiceResponse response = new CEC_DisputeInvoice.DisputeInvoiceResponse('400', 'error', new CEC_DisputeInvoice.Caso());
		Test.stopTest();

		System.assertEquals('1579031159', fieldInvoceItem);
		System.assertNotEquals(null, caso);
		System.assertEquals('1027935', caso.contractNumber);
		System.assertNotEquals(null, response);
		System.assertEquals('400', response.code);
    }

	@isTest
	static void disputeInvoiceNull() {

        Test.startTest();
        CEC_DisputeInvoice.DisputeInvoiceResponse response = CEC_DisputeInvoice.disputeInvoice(null);
		Test.stopTest();

		System.assertEquals('dispute object is null', response.message);
		System.assertEquals('400', response.code);
    }

	@isTest
	static void disputeInvoiceCampoNull() {

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        CEC_DisputeInvoice.DisputeInvoiceRequest request = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        request.contractNumber = null;
        request.operatorCode = '004';
        request.channel = 'L';
        request.idInvoice = '245961436';
        request.userName = 'MCIDA';
        request.source = 1;
        request.type = 'R';

        CEC_DisputeInvoice.DisputeInvoiceResponse response = CEC_DisputeInvoice.disputeInvoice(request);
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals('400', response.code);
		System.assertEquals('missing fields: contractNumber,invoiceItems', response.message);
    }

	@isTest
	static void disputeInvoiceItemsNull() {

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> invoiceItems = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItem = new CEC_DisputeInvoice.invoiceItem();
        invoiceItem.idInvoiceItem = '1579031159';
        invoiceItem.idGroupItem = '1';
        invoiceItem.reason = '1';
        invoiceItem.wishedValue  = 15.42;
        invoiceItem.disputePercentage = 5;
        invoiceItem.approvationHash = null;
        invoiceItem.notes = 'Observação da contestação';
        invoiceItem.status = 'EM ABERTO';
        invoiceItem.getField('approvationHash');
        invoiceItems.add(invoiceItem);

        CEC_DisputeInvoice.DisputeInvoiceRequest request = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        request.contractNumber = '1027935';
        request.operatorCode = '004';
        request.channel = 'L';
        request.idInvoice = '245961436';
        request.userName = 'MCIDA';
        request.source = 1;
        request.type = 'R';
		request.invoiceItems = invoiceItems;

        CEC_DisputeInvoice.DisputeInvoiceResponse response = CEC_DisputeInvoice.disputeInvoice(request);
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals('400', response.code);
		System.assertEquals('dispute items are missing properties: item position: 0 fields: originalValue', response.message);
    }

	@isTest
	static void disputeInvoiceError() {

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        CEC_DisputeInvoice.DisputeInvoiceRequest request = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        request.contractNumber = '1027935';
        request.operatorCode = '004';
        request.channel = 'L';
        request.idInvoice = '245961436';
        request.userName = 'MCIDA';
        request.source = 1;
        request.type = 'ERRO';
		request.invoiceItems = null;

		CEC_DisputeInvoice.DisputeInvoiceResponse response = CEC_DisputeInvoice.disputeInvoice(request);
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals('400', response.code);
		System.assertEquals('missing fields: invoiceItems', response.message);
    }

	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('ContestItem')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2020-03-21","transactionId":"Id-2d0384f0823434","data":{"returnCode":"0","returnMessage":"Mensagens de retorno do processo","contestationBillItems":[{"billId":433442,"amontBill":22.22,"dueDate":"2020-02-20","barCode":"84600000002494102962013061005500000057102314","contestationBillCharges":[{"partnerId":1,"parterName":"NET","amont":"323.43"}]}]}}');
                res.setStatusCode(200);
                return res;
            }
			else if (req.getEndpoint().startsWith('InvoiceAuthority')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2020-04-03","transactionId":"Id-54db215f50aa6c5e4fb1a163","data":{"returnCode":"0","returnMessage":"Valor dentro do limite de alçada","authorized":true,"hashAuthority":"ad7610e03fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c"}}');
                res.setStatusCode(200);
                return res;
            }
			else if (req.getEndpoint().startsWith('CustomerProconPropensity')) {
                HTTPResponse res = new HTTPResponse();
                res.setStatusCode(500);
				res.setBody('{"apiVersion":"1;2020-10-01","transactionId":"da7c4d27-d7d2-4b47-bcb3-eb9092e25cfb","error":{"httpCode":504,"errorCode":"API-CUSTOMERPROCONSCORE-504","message":"Gateway Timeout","detailedMessage":"Gateway Timeout","link":{"rel":"related","href":"https://api.claro.com.br/docs"}}}');
                return res;
            }
			else if (req.getEndpoint().startsWith('CustomerDefaultSegmetation')) {
                HTTPResponse res = new HTTPResponse();
				res.setBody('{"apiVersion":"1;2020-10-01","transactionId":"da7c4d27-d7d2-4b47-bcb3-eb9092e25cfb","error":{"httpCode":504,"errorCode":"API-CUSTOMERPROCONSCORE-504","message":"Gateway Timeout","detailedMessage":"Gateway Timeout","link":{"rel":"related","href":"https://api.claro.com.br/docs"}}}');
                res.setStatusCode(500);
                return res;
            }
			else if (req.getEndpoint().startsWith('callout:OAGNet/CEC_OAG_Claro_ProtocolNETSMS')) {
                HTTPResponse res = new HTTPResponse();
				res.setBody('{"transactionId":null,"data":{"reasonId":"1","protocolNumber":"22222","operatorCode":"004","contractNumber":"010332171"}}');
                res.setStatusCode(200);
                return res;
            }
			else if (req.getEndpoint().startsWith('callout:OAGClaro/CEC_OAG_Claro_Protocol')) {
                HTTPResponse res = new HTTPResponse();
				res.setBody('');
                res.setStatusCode(200);
                return res;
            }
			else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}