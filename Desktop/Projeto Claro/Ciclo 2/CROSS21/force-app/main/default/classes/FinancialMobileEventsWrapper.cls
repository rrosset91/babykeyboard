/**
 * @description       : Classe Wrapper para aba histórico de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro

 * @last modified on  : 08-12-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   10-20-2020   Roger Rosset   Initial Version
**/

public class FinancialMobileEventsWrapper {    
    public class EventGroup{

		@AuraEnabled
		public Boolean requireMsisdn = false;
		@AuraEnabled
		public Boolean requireCrmCustomerId = false;
		@AuraEnabled
		public Boolean active = false;
		@AuraEnabled
		public String accordionId;
		@AuraEnabled
		public String accordionTitle;
		@AuraEnabled
		public EventRequestAttributes attributes;
		@AuraEnabled
		public Object columns;
		@AuraEnabled
		public Object modalFields;
		@AuraEnabled
		public Object responseData;
		@AuraEnabled
		public Boolean hasModal;
		@AuraEnabled
		public Boolean isMsisdnGroup;
	}

	public class EventRequestAttributes {
		@AuraEnabled
		public Boolean implemented;
		@AuraEnabled
		public String groupBy;
		@AuraEnabled
		public Boolean hasMultipleGroups;
		@AuraEnabled
		public Boolean callApiOnRowAction = false;
		@AuraEnabled
		public String apiToCallOnRowAction;
		@AuraEnabled
		public String customSetting;
		@AuraEnabled
		public String namedCredential;
		@AuraEnabled
		public String accordionId;

	}
}