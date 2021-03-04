/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 19-11-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   19-11-2020   Joao Neves   Initial Version
 **/
@isTest
public with sharing class SolarVlocityCustomFunctionTest {
	@isTest
	static void testToObject() {
		Test.startTest();
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> valueMap = new Map<String, Object>();

		valueMap.put('Invoices', '37465,47384,37485');
		valueMap.put('ContractNumber', '234234234');
		List<Object> objList = new List<Object>();
		objList.add(valueMap);
		input.put('arguments', objList);

		Map<String, Object> retMap = new Map<String, Object>();

		new SolarVlocityCustomFunction().invokeMethod('toObject', input, retMap, null);
		System.assertEquals(false, retMap.keySet().isEmpty());

		Test.stopTest();
	}

	@isTest
	static void testGetHistory() {
		Test.startTest();

		Account contrato = new Account(Name = 'Account Test');
		contrato.ExternalID__c = 'Contratot123';
		contrato.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		contrato.ContractReferenceNumber__c = '004/12345';
		insert contrato;

		Case caso = new Case();
		caso.ContractBillingAccount__c = contrato.id;
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
		insert caso;
		caso.Status = 'Closed';
		update caso;

		Map<String, Object> valueMap = new Map<String, Object>();

		Map<String, List<Object>> caseList = new Map<String, List<Object>>();
		List<Object> objCase = new List<Object>();

		Map<String, String> caseInstance = new Map<String, String>();
		caseInstance.put('id', caso.Id);
		objCase.add(caseInstance);

		caseList.put('case', objCase);
		valueMap.put('GetCaseInfos', caseList);

		Map<String, Object> retMap = new Map<String, Object>();
		new SolarVlocityCustomFunction().invokeMethod('getHistory', valueMap, retMap, null);
		System.assert(retMap.get('result') != null);

		//Nao e possivel acessar o objeto history pois a transacao nao e comitada.
		SolarVlocityCustomFunction.HistoryCaseJson instCase = new SolarVlocityCustomFunction.HistoryCaseJson();
		SolarVlocityCustomFunction.HistoryCaseJson instCaseParams = new SolarVlocityCustomFunction.HistoryCaseJson('1', '2', '3');

		Test.stopTest();
	}
}