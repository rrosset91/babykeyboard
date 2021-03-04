/**
 * @description       : Classe wrapper para tratamento do retorno da API
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos-Atendimentos
 * @last modified on  : 31-10-2020
 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public with sharing class JSONInteractionsEventsWrapper{

	public String apiVersion;
	public String transactionId;
	public Data data;

	public class Attendances {
		@AuraEnabled public String occurrenceId;
		@AuraEnabled public String protocolNumber;
		@AuraEnabled public String situation;
		@AuraEnabled public String interactionSequenceId;
		@AuraEnabled public String solicitationDateOpening;
		@AuraEnabled public String protocolNumberInteractions;
		@AuraEnabled public String situationInteractions;
		@AuraEnabled public String slaIndicatorExceeded;
		@AuraEnabled public String reclassificationIndicator;
		@AuraEnabled public String reasonCode1;
		@AuraEnabled public String reasonCode2;
		@AuraEnabled public String reasonCode3;
		@AuraEnabled public String reasonCode4;
		@AuraEnabled public String description;
		@AuraEnabled public String formattedSolicitationDate;
		@AuraEnabled public String formattedSolicitationTime;
		@AuraEnabled public Date realSolicitationDate;
		@AuraEnabled public Time realSolicitationTime;
		@AuraEnabled public String formattedSolicitationDateTimeInteractions;
		@AuraEnabled public Datetime realSolicitationDateTimeInteractions;
		@AuraEnabled public String relatedAccordion;
	}

	public class Data {
		@AuraEnabled public List<Attendances> attendances;

	}
}