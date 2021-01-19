@isTest
public with sharing class SolarPFInvokeMethodTest {

    @TestSetup
	static void makeData(){
		insert new CEC_Role__c( Name= 'Vendedor Televendas',UpdateMethod__c = 'CEC_CheckCustomer.updateDadosVendedor', Profile__c = 'Vendedor Televendas', Role__c = 'Vendedor' );
		List<User> lstusr = new List<User>();
		Profile p = [SELECT Id FROM Profile WHERE Name='Vendedor Televendas']; 
		UserRole role = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Vendedor'];
		System.debug('role>>'+role);
		User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', //UserRoleId= role.Id,
		 	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, CPF__c = '306.773.730-07', Claro__c = '12345',
			FederationIdentifier = '123123132',
             TimeZoneSidKey='America/Los_Angeles', UserName='tokenativacao@claro.com');
        User usr2 = new User(Alias = 'standt', Email='standarduser@testorg.com', //UserRoleId= role.Id,
		 	EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, CPF__c = '573.461.070-47', Claro__c = '12345',
			FederationIdentifier = '123123132',
			 TimeZoneSidKey='America/Los_Angeles', UserName='tokenativacao@claro.com.test');
		
		lstusr.add(usr);
		lstusr.add(usr2);
		insert lstusr;
		
		
	}

	@isTest
	static void callClassByCustomSettingTest(){
		List<User> usrLst = [SELECT ProfileId, UserRoleId FROM User
							 WHERE UserName IN ('tokenativacao@claro.com.test', 'tokenativacao@claro.com') LIMIT 2];
		SolarPFInvokeMethod.callClassByCustomSetting(usrLst);
	}

}