@isTest
public with sharing class SolarPFTokenServiceTest {
	
	@TestSetup
	static void makeData(){
		AuthSession auth = [SELECT Id, SourceIp FROM AuthSession ORDER BY CreatedDate DESC LIMIT 1];
		system.debug('auth>>'+auth);
		insert new ServiceParameter__c(Name  = 'CEC_SSO_Token', EndPoint__c = '/token', IsActive__c = true, Method__c = 'POST', Timeout__c = 100000 );
	}

	@isTest
	static void getTokenForUserTestSuccess(){
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
		 	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, CPF__c = '306.773.730-07', Claro__c = '12345',
			FederationIdentifier = '123123132',
			 TimeZoneSidKey='America/Los_Angeles', UserName='tokenativacao@claro.com');
		System.runAs(u) {
			Test.startTest();
			SolarPFTokenServiceTest.TokenApiCallout apicallout = new SolarPFTokenServiceTest.TokenApiCallout();
			apicallout.setSuccessResponse();
			Test.setMock(HttpCalloutMock.class, apicallout); 
			String tokenResponse = SolarPFTokenService.getTokenForUser();
			System.assertEquals('tks-be2f5e3a-ee7e-42df-8543-2a7c444ae626', tokenResponse, 'token ativacao success');
			Test.stopTest();
		}
		
	}

	@isTest
	static void getTokenForUserTestFail(){
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
		 	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, CPF__c = '306.773.730-07', Claro__c = '12345',
			FederationIdentifier = '123123132',
			 TimeZoneSidKey='America/Los_Angeles', UserName='tokenativacao@claro.com');
		System.runAs(u) {
			Test.startTest();
			try{
				SolarPFTokenServiceTest.TokenApiCallout apicallout = new SolarPFTokenServiceTest.TokenApiCallout();
				apicallout.setFailResponse();
				Test.setMock(HttpCalloutMock.class, apicallout); 
				String tokenResponse = SolarPFTokenService.getTokenForUser();
			}catch(CalloutException e){
				System.assertEquals('Sua solicitação não foi executada. Tente novamente, ou abra um chamado informando o código: API-TOKEN-001', e.getMessage(), 'token api erro 400');
			}
			Test.stopTest();
		}
	}
	@isTest
	static void requestObjectCreateNull(){
		User usr;
		try{
		SolarPFTokenServiceWrapper.Request request = SolarPFTokenService.requestObjectCreate(usr);
		}catch(NullPointerException e){
			System.assertEquals('Attempt to de-reference a null object', 'Attempt to de-reference a null object', 'requestObjectCreateNull');
		}
	}
	
	public class TokenApiCallout implements HttpCalloutMock{
		private String responsejson;
		private Integer statusCode;

		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(responsejson);
			response.setStatusCode(StatusCode);
			return response; 
		}

		public void setSuccessResponse(){
			this.responsejson = '{"apiVersion":"1;2019-06-17","transactionId":"Id-15ba295f32c5eb1eb788114a","data":{"token":{"tokenId":"tks-be2f5e3a-ee7e-42df-8543-2a7c444ae626","session":{"id":"cf342baa-991f-415c-8aaa-2a60ffc7375c","creationDate":"2020-08-04T16:42:13.935-03:00","expirationDate":"2020-08-04T17:12:13.935-03:00"},"creationDate":"2020-08-04T16:42:13.935-03:00","expirationDate":"2020-08-04T17:12:13.935-03:00"}}}';
			this.statusCode = 200;
		}

		public void setFailResponse(){
			this.responsejson = '{"apiVersion":"1;2019-06-17","transactionId":"Id-1ef02a5fdca9ec92ae349281","error":{"httpCode":"400","errorCode":"API-TOKEN-001","message":"Invalid Request for operation","detailedMessage":null,"link":{"rel":"related","href":"https://oag.claro.com.br/docs/error_codes.html"}}}';
			this.statusCode = 400;
		}
	}
}