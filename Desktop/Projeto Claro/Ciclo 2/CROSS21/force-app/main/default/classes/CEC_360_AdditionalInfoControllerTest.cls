@ isTest

public with sharing class CEC_360_AdditionalInfoControllerTest {

	static Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECInternetFixa').getRecordTypeId();

	@IsTest
	static void getAddresTest() { 

 
		Test.startTest();
		Account acc = new Account(Name = 'Account Test');
		insert acc;

		Asset ast = new Asset(Name = 'Asset Test', AccountId = acc.Id, MSISDN__c = '1234567890', RecordTypeId = recordTypeAsset);
		insert ast;

		CEC_360_AdditionalInformationController.getAddress(ast.Id, 'Asset');
        CEC_360_AdditionalInformationController.getAddress(acc.Id, 'Account');
		CEC_360_AdditionalInformationController.getDataRecord(ast.Id, 'Asset');
        CEC_360_AdditionalInformationController.getDataRecord(acc.Id, 'Account');
        //System.assertEquals('Internet Fixa', varAsset.RecordType.Name);
		Test.stopTest();

	}

}