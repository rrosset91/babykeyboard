/**
 * @description       : Classe de testes para cobertura da classe FinancialMobileContestationReasons
 * @author            : Roger Rosset
 * @group             :
 * @last modified on  : 29-12-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   29-12-2020   Roger Rosset   Initial Version
 **/
@isTest
public class FinancialMobileContestationReasonsTest {
	@TestSetup
	public static void makeData() {
		Id recordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('ReasonsContestation').getRecordTypeId();
		Parameters__c param = new Parameters__c();

		param.RecordTypeId = recordTypeId;
		param.Active__c = true;
		param.ExternalID__c = '1234567';
		param.ProcedureGroupN1__c = 'AJCLVD;AJICMS';
		param.ProcedureGroupN2__c = 'DJUPAR;DJUCNE';
		param.SystemGroupN1__c = 'AJICMS;AJGOV';
		param.SystemGroupN2__c = 'AJULDN;AJUCLO';

		insert param;
	}

	@isTest
	public static void getContestationReasons() {
		Parameters__c param = [SELECT Id, ExternalID__c, ProcedureGroupN1__c, ProcedureGroupN2__c, SystemGroupN1__c, SystemGroupN2__c FROM Parameters__c LIMIT 1];
		test.startTest();
		FinancialMobileContestationReasons.ParametersWrapper result = FinancialMobileContestationReasons.getContestationReasons(param.ExternalID__c);
		test.stopTest();
		system.assertEquals(true, result != null);
	}
}