/**
 * @description       : Classe responsável por retornar os registros de Parameters__c para inserir no motivo de contestação
 * @author            : Roger Rosset
 * @group             : FINANCEIRO - MOBILE
 * @last modified on  : 05-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   24-12-2020   Roger Rosset   Initial Version
 **/
public with sharing class FinancialMobileContestationReasons {
	/**
	 * @description MÉTODO RECEBE CHARGE CODE E RETORNA WRAPPER COM OS PARAMETROS CORRESPONDENTES
	 * @author Roger Rosset | 24-12-2020
	 * @param String chargeCode
	 * @return ParametersWrapper
	 **/
	@AuraEnabled
	public static ParametersWrapper getContestationReasons(String chargeCode) {
		Parameters__c contestationParameters = new Parameters__c();
		ParametersWrapper parametersWrapper = new ParametersWrapper();
		Id recordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('ReasonsContestation').getRecordTypeId();
		contestationParameters = [
			SELECT Id, ExternalId__c, ProcedureGroupN1__c, ProcedureGroupN2__c, SystemGroupN1__c, SystemGroupN2__c, Dispute__c
			FROM Parameters__c
			WHERE recordTypeId = :recordTypeId AND ExternalId__c = :chargeCode
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
		parametersWrapper = setWrapper(contestationParameters);
		return ParametersWrapper;
	}

	/**
	 * @description MÉTODO RESPONSÁVEL POR INSTANCIAR O WRAPPER, MELHORANDO E LEGIBILIDADE DO CÓDIGO
	 * @author Roger Rosset | 24-12-2020
	 * @param Parameters__c params
	 * @return ParametersWrapper
	 **/
	private static ParametersWrapper setWrapper(Parameters__c params) {
		ParametersWrapper parametersWrapper = new ParametersWrapper();
		parametersWrapper.dispute = params.Dispute__c;
		parametersWrapper.externalId = params.ExternalID__c;
		parametersWrapper.id = params.Id;
		parametersWrapper.procedureGroupN1 = getOptions(params.ProcedureGroupN1__c.split(';'), 'procedureN1');
		parametersWrapper.procedureGroupN2 = getOptions(params.ProcedureGroupN2__c.split(';'), 'procedureN2');
		parametersWrapper.systemGroupN1 = getOptions(params.SystemGroupN1__c.split(';'), 'systemN1');
		parametersWrapper.systemGroupN2 = getOptions(params.SystemGroupN2__c.split(';'), 'systemN2');
		return parametersWrapper;
	}

	/**
	 * @description MÉTODO RESPONSÁVEL POR PEGAR OS LABELS E API FIELDS DE CADA OPÇÃO CADASTRADA NO MULTIPICKLIST
	 * @author Roger Rosset | 24-12-2020
	 * @param List<String> values
	 * @param String fieldToSearch
	 * @return Map<String, String>
	 **/
	private static Map<String, String> getOptions(List<String> values, String fieldToSearch) {
		Map<String, String> picklistValues = new Map<String, String>();
		Map<String, String> options = new Map<String, String>();
		switch on fieldToSearch {
			when 'procedureN1' {
				Schema.DescribeFieldResult F = Parameters__c.ProcedureGroupN1__c.getDescribe();
				List<Schema.PicklistEntry> P = F.getPicklistValues();
				for (Schema.PicklistEntry picklistOption : P) {
					picklistValues.put(picklistOption.getValue(), picklistOption.getLabel());
				}
			}
			when 'procedureN2' {
				Schema.DescribeFieldResult F = Parameters__c.ProcedureGroupN2__c.getDescribe();
				List<Schema.PicklistEntry> P = F.getPicklistValues();
				for (Schema.PicklistEntry picklistOption : P) {
					picklistValues.put(picklistOption.getValue(), picklistOption.getLabel());
				}
			}
			when 'systemN1' {
				Schema.DescribeFieldResult F = Parameters__c.SystemGroupN1__c.getDescribe();
				List<Schema.PicklistEntry> P = F.getPicklistValues();
				for (Schema.PicklistEntry picklistOption : P) {
					picklistValues.put(picklistOption.getValue(), picklistOption.getLabel());
				}
			}
			when 'systemN2' {
				Schema.DescribeFieldResult F = Parameters__c.SystemGroupN2__c.getDescribe();
				List<Schema.PicklistEntry> P = F.getPicklistValues();
				for (Schema.PicklistEntry picklistOption : P) {
					picklistValues.put(picklistOption.getValue(), picklistOption.getLabel());
				}
			}
			when else {
				return null;
			}
		}
		for (String value : values) {
			options.put(picklistValues.get(value), value);
		}
		system.debug(options);
		return options;
	}

	public class ParametersWrapper {
		@AuraEnabled
		public String externalId;
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String dispute;
		@AuraEnabled
		public Map<String, String> procedureGroupN1;
		@AuraEnabled
		public Map<String, String> procedureGroupN2;
		@AuraEnabled
		public Map<String, String> systemGroupN1;
		@AuraEnabled
		public Map<String, String> systemGroupN2;
	}
}