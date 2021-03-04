/**
 * @description       : Classe utilizada pelo LWC SolarAutomaticEventAnalysis, responsável por processar os dados das chamadas das APIs de eventos
 * @author            : Felipe Ducheiko
 * @group             : 
 * @last modified on  : 24-02-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-02-2021   Felipe Ducheiko   Initial Version
**/
public class FinancialEventAnalysisController {

	@AuraEnabled
	public static Map<String, Object> getAllEvents(String parameters) {
		Map<String, Object> result = new Map<String, Object>();
		List<EventWrapper> allEvents = new List<EventWrapper>();

		DiagnosticComparison diagnosticComparison = (DiagnosticComparison) JSON.deserialize(parameters, DiagnosticComparison.class);
		
		validateDiagnosticComparison(diagnosticComparison);
		
		Date startDate = InvoicesUtils.convertFormattedDateToSFDate(diagnosticComparison.invoicesDataToCompare.get(1).invoice.dataVencimento);
		Date endDate = InvoicesUtils.convertFormattedDateToSFDate(diagnosticComparison.invoicesDataToCompare.get(0).invoice.dataVencimento);
		
		Parameters__c numberDaysParameter = getNumberDaysParameter();
		Integer numberDaysStart = - Integer.valueOf(numberDaysParameter.NumberDaysStart__c);
		Integer numberDaysEnd = - Integer.valueOf(numberDaysParameter.NumberDaysEnd__c);

		allEvents.addAll(getRequests(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		allEvents.addAll(getManualPostings(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		allEvents.addAll(getContractedOffers(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		allEvents.addAll(getPPVs(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		allEvents.addAll(getReadjustments(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		allEvents.addAll(getFees(diagnosticComparison.contractNumber, diagnosticComparison.operatorCode, startDate.addDays(numberDaysStart), endDate.addDays(numberDaysEnd)));

		result.put('data', allEvents);

		return result;
	}

	private static void validateDiagnosticComparison(DiagnosticComparison diagnosticComparison) {

		if (diagnosticComparison == null || String.isBlank(diagnosticComparison.contractNumber) || String.isBlank(diagnosticComparison.operatorCode))
			throw new AuraHandledException('Númeto de Contrato/Código Operadora incorreto');

		if (diagnosticComparison.invoicesDataToCompare == null)
			throw new AuraHandledException('Data faturas incorreta');

		if (diagnosticComparison.invoicesDataToCompare.get(0) == null || diagnosticComparison.invoicesDataToCompare.get(0).invoice == null || diagnosticComparison.invoicesDataToCompare.get(0).invoice.dataVencimento == null)
			throw new AuraHandledException('Data fatura 1 incorreta');

		if (diagnosticComparison.invoicesDataToCompare.get(1) == null || diagnosticComparison.invoicesDataToCompare.get(1).invoice == null || diagnosticComparison.invoicesDataToCompare.get(1).invoice.dataVencimento == null)
			throw new AuraHandledException('Data fatura 2 incorreta');
	}

	private static Parameters__c getNumberDaysParameter(){

		Id recordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AutomaticDiagnostics').getRecordTypeId();

		List<Parameters__c> numberDaysParameters = [SELECT Id, NumberDaysEnd__c, NumberDaysStart__c
			FROM Parameters__c
			WHERE Active__c = true AND RecordTypeId = :recordTypeId AND Channel__c = 'Atendimento' AND
			Process__c = 'Contestação' AND Business_Division__c = 'Residencial' AND Parametertype__c =
			'Quantidade de dias para Histórico Eventos' LIMIT 1];

		if (numberDaysParameters == null || numberDaysParameters.isEmpty() || numberDaysParameters.get(0).NumberDaysStart__c == null || numberDaysParameters.get(0).NumberDaysEnd__c == null)
			throw new AuraHandledException('Parâmetro de Quantidade de dias para Histórico Eventos configurado incorretamente');

		return numberDaysParameters.get(0);
	}

	private static Parameters__c getKBParameter(String eventType){

		Id recordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AutomaticDiagnostics').getRecordTypeId();
		
		eventType = '%' + eventType + '%'; 

		List<Parameters__c> parameters = [SELECT Id, name, ContentArticleLink__c
			FROM Parameters__c
			WHERE Active__c = true AND RecordTypeId = :recordTypeId AND Channel__c = 'Atendimento' AND
			Process__c = 'Contestação' AND Business_Division__c = 'Residencial' AND Parametertype__c =
			'Tipos de Eventos' AND ConcatenatedEvent__c LIKE :eventType LIMIT 1];
	
		if (parameters == null || parameters.isEmpty() || parameters.get(0).ContentArticleLink__c == null)
			return null;

		return parameters.get(0);
	}

	private static List<EventWrapper> getRequests(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getEventsByDate(contractId, operatorId, startDate, endDate);
		Map<String, Parameters__c> parametersKB = getParametersRequestKB();

		if (! (Boolean) data.get('success')) {
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<EventsWrapper> eventsAPI = (List<EventsWrapper>) data.get('events');
		
		if (eventsAPI == null) return events;

		for (EventsWrapper eventAPI : eventsAPI) {
			EventWrapper event = transformeRequest(eventAPI);
			
			if (String.isBlank(event.eventType)) break;

			Parameters__c parameterKB = parametersKB.get(event.eventType);
			if (parameterKB != null) {
				event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
				event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
			}

			events.add(event);
		}

		return events;
	}
 
	public static EventWrapper transformeRequest (EventsWrapper eventAPI) {
		EventRequestWrapper event = new EventRequestWrapper();

		event.eventType = EventsController.groupTypes.get(eventAPI.requestTypeID);
		event.eventDate = String.isNotBlank(eventAPI.closeDate) ? InvoicesUtils.formatIntegrationDateToSFDate(eventAPI.closeDate) : '--';
		event.eventDescription = eventAPI.requestTypeDescription;

		event.requestID = String.valueOf(eventAPI.requestID);

		event.user = eventAPI.openUser;
		event.closeType = eventAPI.statusDescription;

		return event;
	}

	private static Map<String, Parameters__c> getParametersRequestKB(){
		Map<String, Parameters__c> parametersKB = new Map<String, Parameters__c>();

		parametersKB.put('Compras/ Movimentações de Produtos e Serviços', getKBParameter('Compras/Movimentações de Produtos e Serviços'));
		parametersKB.put('Eventos Técnicos / Serviços', getKBParameter('Eventos Técnicos / Serviços'));
		parametersKB.put('Cancelamentos em andamento ou executados', getKBParameter('Cancelamentos em andamento ou executados'));

		return parametersKB;
	}

	public static List<EventWrapper> getManualPostings(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getHistoryEvents(contractId, operatorId, 'ISSUED', startDate, endDate);
		Parameters__c parameter = getKBParameter('Lançamentos Manuais');

		if (! (Boolean) data.get('success')){
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<EventsHistoryWrapper.BillDocumentList> eventsAPI = (List<EventsHistoryWrapper.BillDocumentList>) data.get('events');
		
		if (eventsAPI == null) return events;

		for (EventsHistoryWrapper.BillDocumentList eventAPI : eventsAPI) {
			events.add(transformeManualPosting(eventAPI, parameter));
		}

		return events; 
	}

	public static EventWrapper transformeManualPosting (EventsHistoryWrapper.BillDocumentList eventAPI, Parameters__c parameterKB) {
		EventManualPosting event = new EventManualPosting();

		event.eventType = 'Lançamentos Manuais';
		event.eventDate = String.isNotBlank(eventAPI.billDate) ? FinancialMobileUtils.formatResponseDate(eventAPI.billDate, false) : '--';
		event.eventDescription = eventAPI.extractItemTypeDescription;
		
		if (parameterKB != null) {
			event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
			event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
		}

		event.installment = eventAPI.installments;
		event.value = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.amountDue));
		
		if (eventAPI.extractItensDetails != null && eventAPI.extractItensDetails.get(0) != null) {
			event.user = eventAPI.extractItensDetails.get(0).registrationUser;
			event.product = eventAPI.extractItensDetails.get(0).productDescription;
			event.item = eventAPI.extractItensDetails.get(0).detTypeExtractItemNote;
			event.partner = eventAPI.extractItensDetails.get(0).partnerName;
		}

		return event;
	}

	public static List<EventWrapper> getContractedOffers(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getNewProducts(contractId, operatorId, startDate, endDate);
		Parameters__c parameter = getKBParameter('Oferta Contratada'); 

		if (! (Boolean) data.get('success')){
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<JSONResidentialCustomersNewProducts.NewProduct> eventsAPI = (List<JSONResidentialCustomersNewProducts.NewProduct>) data.get('newProducts');
		
		if (eventsAPI == null) return events;

		for (JSONResidentialCustomersNewProducts.NewProduct eventAPI : eventsAPI) {
			events.add(transformeContractedOffer(eventAPI, parameter));
		}

		return events; 
	}

	public static EventWrapper transformeContractedOffer (JSONResidentialCustomersNewProducts.NewProduct eventAPI, Parameters__c parameterKB) {
		EventContractedOffer event = new EventContractedOffer();

		event.eventType = 'Oferta Contratada';
		event.eventDate = String.isNotBlank(eventAPI.effectiveDate) ? FinancialMobileUtils.formatResponseDate(eventAPI.effectiveDate, false) : '--';
		event.eventDescription = eventAPI.productDescription;
		
		if (parameterKB != null) {
			event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
			event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
		}

		event.value = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.amount));

		return event;
	}

	public static List<EventWrapper> getPPVs(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getCustomerPpv(contractId, operatorId, startDate, endDate);
		Parameters__c parameter = getKBParameter('PPV'); 

		if (! (Boolean) data.get('success')){
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<JSONResidentialCustomerPpv.Consumptions> eventsAPI = (List<JSONResidentialCustomerPpv.Consumptions>) data.get('ppvs');
		
		if (eventsAPI == null) return events;

		for (JSONResidentialCustomerPpv.Consumptions eventAPI : eventsAPI) {
			events.add(transformePPV(eventAPI, parameter));
		}

		return events; 
	}

	public static EventWrapper transformePPV (JSONResidentialCustomerPpv.Consumptions eventAPI, Parameters__c parameterKB) {
		EventPPV event = new EventPPV();

		event.eventType = 'PPV';
		event.eventDate = String.isNotBlank(eventAPI.saleDate) ? FinancialMobileUtils.formatResponseDate(eventAPI.saleDate, false) : '--';
		event.eventDescription = eventAPI.typeSaleDescription;
		
		if (parameterKB != null) {
			event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
			event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
		}

		event.product = eventAPI.eventName;
		event.value = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.price));

		return event;
	}

	public static List<EventWrapper> getReadjustments(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getReadjustments(contractId, operatorId);
		Parameters__c parameter = getKBParameter('Reajuste Anual'); 

		if (! (Boolean) data.get('success')){
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<JSONResidentialCustomersLastReadjustment.LastReadjustment> eventsAPI = (List<JSONResidentialCustomersLastReadjustment.LastReadjustment>) data.get('readjustments');
		
		if (eventsAPI == null) return events;

		for (JSONResidentialCustomersLastReadjustment.LastReadjustment eventAPI : eventsAPI) {
			EventWrapper event = transformeReadjustment(eventAPI, parameter);

			Date eventDate = InvoicesUtils.convertFormattedDateToSFDate(event.eventDate);

			if (eventDate != null && eventDate >= startDate && eventDate <= endDate)
				events.add(event);
		}

		return events; 
	}

	public static EventWrapper transformeReadjustment (JSONResidentialCustomersLastReadjustment.LastReadjustment eventAPI, Parameters__c parameterKB) {
		EventReadjustment event = new EventReadjustment();

		event.eventType = 'Reajuste Anual';
		event.eventDate = String.isNotBlank(eventAPI.readjustmentDate) ? FinancialMobileUtils.formatResponseDate(eventAPI.readjustmentDate, false) : '--';
		event.eventDescription = eventAPI.readjustmentType;
		
		if (parameterKB != null) {
			event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
			event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
		}

		event.product = eventAPI.productDescription;
		event.readjustmentPercentage = eventAPI.percentAdjusted;
		event.previousPrice = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.previousPrice));
		event.readjustmentPrice = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.readjustmentPrice));
		event.readjustmentValue = eventAPI.formattedAmount;

		return event;
	}

	public static List<EventWrapper> getFees(String contractId, String operatorId, Date startDate, Date endDate){
		List<EventWrapper> events = new List<EventWrapper>();
		Map<String, Object> data = EventsController.getRequestFees(contractId, operatorId, startDate, endDate);
		Parameters__c parameter = getKBParameter('Taxas Técnicas'); 

		if (! (Boolean) data.get('success')){
			System.debug('API Error: ' + (String) data.get('message'));
			throw new AuraHandledException('Ops! Parece que algo errado deu errado, por favor tente novamente mais tarde.');
		}

		List<JSONResidentialRequestFees.RequestFee> eventsAPI = (List<JSONResidentialRequestFees.RequestFee>) data.get('requestFees');
		
		if (eventsAPI == null) return events;

		for (JSONResidentialRequestFees.RequestFee eventAPI : eventsAPI) {
			events.add(transformeFee(eventAPI, parameter));
		}

		return events; 
	}

	public static EventWrapper transformeFee (JSONResidentialRequestFees.RequestFee eventAPI, Parameters__c parameterKB) {
		EventFee event = new EventFee();

		event.eventType = 'Taxas Técnicas';
		event.eventDate = String.isNotBlank(eventAPI.releaseDate) ? FinancialMobileUtils.formatResponseDate(eventAPI.releaseDate, false) : '--';
		event.eventDescription = eventAPI.requestTypeDescription;
		
		if (parameterKB != null) {
			event.eventKB = String.isNotBlank(parameterKB.ContentArticleLink__c) ? parameterKB.ContentArticleLink__c : '';
			event.NameKB = String.isNotBlank(parameterKB.Name) ? parameterKB.Name : '';
		}

		event.itemName = eventAPI.extractItemTypeDescription;
		event.value = FinancialMobileUtils.formatBRL(String.valueOf(eventAPI.amount));
		event.installment = eventAPI.paymentPlanName;
		event.installmentNumber = eventAPI.installmentNumber;
		event.product = eventAPI.productDescription;
		event.requestUser = eventAPI.requestRegistrationUser;
		event.feeUser = eventAPI.itemExtractRegistrationUser;

		return event;
	}

	public virtual class EventWrapper {
		@auraEnabled
		public String eventType {get;set;}
		@auraEnabled
		public String eventDescription {get;set;}
		@auraEnabled
		public String eventDate {get;set;}
		@auraEnabled
		public String eventKB {get;set;}
		@auraEnabled
		public String nameKB {get;set;}
		@auraEnabled
		public String requestID {get;set;}
	}

	public virtual class EventRequestWrapper extends EventWrapper {
		@auraEnabled
		public String user {get;set;}
		@auraEnabled
		public String closeType {get;set;}
	} 

	public virtual class EventManualPosting extends EventWrapper {
		@auraEnabled
		public String installment {get;set;}
		@auraEnabled
		public String value {get;set;}
		@auraEnabled
		public String user {get;set;}
		@auraEnabled
		public String product {get;set;}
		@auraEnabled
		public String item {get;set;}
		@auraEnabled
		public String partner {get;set;}
	}

	public virtual class EventContractedOffer extends EventWrapper {
		@auraEnabled
		public String value {get;set;}
	}

	public virtual class EventPPV extends EventWrapper {
		@auraEnabled
		public String product {get;set;}
		@auraEnabled
		public String value {get;set;}
	}

	public virtual class EventReadjustment extends EventWrapper {
		@auraEnabled
		public String previousPrice {get;set;}
		@auraEnabled
		public String product {get;set;}
		@auraEnabled
		public String readjustmentPercentage {get;set;}
		@auraEnabled
		public String readjustmentPrice {get;set;}
		@auraEnabled
		public String readjustmentValue {get;set;}
	}

	public virtual class EventFee extends EventWrapper {
		@auraEnabled
		public String itemName {get;set;}
		@auraEnabled
		public String value {get;set;}
		@auraEnabled
		public String installment {get;set;}
		@auraEnabled
		public String installmentNumber {get;set;}
		@auraEnabled
		public String product {get;set;}
		@auraEnabled
		public String requestUser {get;set;}
		@auraEnabled
		public String feeUser {get;set;}
	}

	//Wrapper for data received in LWC SolarAutomaticEventAnalysis
	public class DiagnosticComparison {
		public string operatorCode;
		public string contractNumber;
		public List<ComparisonInvoice> invoicesDataToCompare;
	}

	public class ComparisonInvoice {
		public string invoiceName;
		public ComparisonInvoiceFull invoice;
	}

	public class ComparisonInvoiceFull {
		public string dataVencimento;
	}
}