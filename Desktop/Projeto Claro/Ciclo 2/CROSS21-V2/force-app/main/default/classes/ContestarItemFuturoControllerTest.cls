/**
 * @description       :
 * @author
 * @group             :
 * @last modified on  : 10-02-2021
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author            Modification
 **/
@IsTest
public with sharing class ContestarItemFuturoControllerTest {
	@testSetup
	static void makeData() {
		Account acc = AccountDataFactory.getSingleAccount('Billing');
		acc.ContractReferenceNumber__c = '1027935';
		acc.StatusLegado__c = 'Conectado';
		insert acc;

		Case cs = CaseDataFactory.getSingleCase('Billing', acc.Id);
		cs.AttendanceByUser__c = [SELECT Id FROM User LIMIT 1].Id;
		cs.Email__c = acc.Email__c;
		cs.Status = 'New';
		insert cs;

		Vlocity_cmt__PaymentAdjustment__c paymentAdjustment = PaymentAdjustmentDataFactory.getSinglePaymentAdjustment('Itens_Contestados', cs.Id, acc.Id);
		paymentAdjustment.vlocity_cmt__Status__c = 'Pending';
		insert paymentAdjustment;

		List<ServiceParameter__c> services = getTestServiceParameters();
		insert services;

		Parameters__c param = getTestParam();
		insert param;
	}

	@IsTest
	static void getContestationOptionsTest() {
		Test.startTest();
		List<InvoiceDetailsController.ReasonOption> contestationOptions = ContestarItemFuturoController.getContestationOptions();
		Test.stopTest();

		System.assertNotEquals(null, contestationOptions);
	}

	@IsTest
	static void setReturnMethodTest() {
		Test.startTest();
		Case cs = [SELECT Id FROM Case LIMIT 1];
		ContestarItemFuturoController.setReturnMethod(cs.Id, 'E-mail');
		Test.stopTest();

		cs = [SELECT id, PreferencialContact__c FROM Case LIMIT 1];

		System.assertNotEquals(null, cs);
		System.assertEquals('E-mail', cs.PreferencialContact__c);
	}

	@IsTest
	static void denyCaseTest() {
		Test.startTest();
		Case cs = [SELECT Id FROM Case LIMIT 1];
		ContestarItemFuturoController.denyCase(cs.Id, 'caseComment');
		Test.stopTest();

		cs = [SELECT id, status, description FROM Case LIMIT 1];

		System.assertNotEquals(null, cs);
		System.assertEquals('Closed', cs.Status);
		System.assertEquals('caseComment', cs.Description);
	}

	@IsTest
	static void performContestationTestApprovationTrue() {
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
		ContestarItemFuturoController.ContestationResponse response = ContestarItemFuturoController.performContestation(getContestationString(), true);
		Test.stopTest();

		System.assertNotEquals(null, response);
		if(response.hasAuthority){
			System.assertEquals(true, response.hasAuthority);
        }else{
            System.assertEquals(false, response.hasAuthority);
        }
	}

	@IsTest
	static void performContestationTestApprovationFalse() {
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
		ContestarItemFuturoController.ContestationResponse response = ContestarItemFuturoController.performContestation(getContestationString(), false);
		Test.stopTest();

		System.assertNotEquals(null, response);
        if(response.hasAuthority){
			System.assertEquals(true, response.hasAuthority);
        }else{
            System.assertEquals(false, response.hasAuthority);
        }
	}

	private static String getContestationString() {
		String contractNumber = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		String caseId = [SELECT Id FROM Case LIMIT 1].Id;

		String JSONString =
			'{"operatorCode":"052","contractNumber":"' +
			contractNumber +
			'","caseId":"' +
			caseId +
			'","comment":"test","items":[{"contestationReason":136,"partnerId":1,"originalValue":20.75,"valorContestar":1,"valorCorrigido":19.75,"itemId":596211961,"description":"ALUGUEL EQUIP HABILITADO PROP","note":"test"}],"dpGroup":[{"partnerId":1,"value":0}]}';

		return JSONString;
	}

	private static List<ServiceParameter__c> getTestServiceParameters() {
		List<ServiceParameter__c> services = new List<ServiceParameter__c>();

		ServiceParameter__c futureRelease = new ServiceParameter__c();
		futureRelease.name = 'ContestItemFuture';
		futureRelease.EndPoint__c = 'ContestItemFuture';
		futureRelease.Method__c = 'POST';
		futureRelease.Timeout__c = 120000;
		services.add(futureRelease);

		ServiceParameter__c authority = new ServiceParameter__c();
		authority.name = 'InvoiceAuthority';
		authority.EndPoint__c = 'InvoiceAuthority';
		authority.Method__c = 'GET';
		authority.Timeout__c = 120000;
		services.add(authority);

		ServiceParameter__c OAGNetSendEmail = new ServiceParameter__c();
		OAGNetSendEmail.name = 'OAG_NET_SendEmail';
		OAGNetSendEmail.EndPoint__c = 'OAG_NET_SendEmail';
		OAGNetSendEmail.Method__c = 'POST';
		OAGNetSendEmail.Timeout__c = 120000;
		OAGNetSendEmail.IsActive__c = true;
		OAGNetSendEmail.User__c = 'MCIDAS';
		OAGNetSendEmail.NamedCredential__c = 'OAGClaro';
		services.add(OAGNetSendEmail);

		return services;
	}

	private static Parameters__c getTestParam() {
		Id parameterRecordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		return new Parameters__c(TotalAmount__c = 10, Business_Division__c = 'Residencial', Active__c = true, RecordTypeId = parameterRecordTypeId);
	}

	private class Mock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HTTPResponse res = new HTTPResponse();

			System.debug('ENDPOINT NAME: ' + req.getEndpoint());

			if (req.getEndpoint().startsWith('ContestItemFuture')) {
				res.setBody('{"data":{"returnCode":"12323","returnMessage":"Mensagem de retorno do processo","contestationItems":[{"idExtractItem":"2122","idExtractItemType":"65214","itemDescriptionType":"DESCONTO SUPORTE","itemNewValue":"9,99"}]}}');
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('InvoiceAuthority')) {
				res.setBody('{"apiVersion":"1;2020-04-03","transactionId":"Id-54db215f50aa6c5e4fb1a163","data":{"returnCode":"0","returnMessage":"Valor dentro do limite de alçada","authorized":true,"hashAuthority":"ad7610e03fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c"}}');
				res.setStatusCode(200);
				return res;
			} else if (req.getEndpoint().startsWith('OAG_NET_SendEmail')) {
				res.setBody('{"data":{"returnCode":"12323","returnMessage":"Mensagem de retorno do processo","contestationItems":[{"idExtractItem":"2122","idExtractItemType":"65214","itemDescriptionType":"DESCONTO SUPORTE","itemNewValue":"9,99"}]}}');
				res.setStatusCode(200);
				return res;
			} else {
				System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
				return null;
			}
		}
	}
}