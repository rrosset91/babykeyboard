public class LancamentosFuturosController {
	@AuraEnabled
	public static List<vlocity_cmt__PaymentAdjustment__c> getCasedetails(String caseId) {
		return [
			SELECT
				Id,
				vlocity_cmt__AccountId__c,
				idExtractItem__c,
				vlocity_cmt__Amount__c,
				vlocity_cmt__Date__c,
				vlocity_cmt__DisputeId__c,
				ContestedAmount__c,
				vlocity_cmt__Status__c,
				Reason__c,
				vlocity_cmt__Notes__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE vlocity_cmt__DisputeId__c = :caseId AND vlocity_cmt__Status__c = 'Pending'
		];
	}

	@AuraEnabled
	public static Map<String, Object> getHistoryByDatePeriod(
		String contractId,
		String operatorId,
		String extractItemStatus,
		Integer period,
		Date dateStart,
		Date dateEnd,
		String recordId
	) {
		Date startDate = InvoicesUtils.toStartOfMonth(period != null ? Date.today().addMonths(-period) : dateStart);
		Date endDate = InvoicesUtils.toEndOfMonth(period != null ? Date.today() : dateEnd);

		return getHistoryEvents(contractId, operatorId, extractItemStatus, startDate, endDate, recordId);
	}

	private static Map<String, Object> getHistoryEvents(String contractId, String operatorId, String extractItemStatus, Date startDate, Date endDate, String recordId) {
		Map<String, Object> data = new Map<String, Object>();

		String startDateText = InvoicesUtils.formatDateToIntegration(startDate, false);
		String endDateText = InvoicesUtils.formatDateToIntegration(endDate, false);

		Map<String, String> params = setParamsHistory(contractId, operatorId, extractItemStatus, startDateText, endDateText);

		ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('futureReleaseAttributes');

		Map<String, String> headers = new Map<String, String>();
		headers.put('X-QueryString', 'operatorCode=' + operatorId + '&contractNumber=' + contractId + '&userName=' + InvoicesUtils.getCalloutUser('futureReleaseAttributes'));
		headers.put('X-Client-Auth', metaParameter.Token__c);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(null, params, headers, 'futureReleaseAttributes');

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			FutureReleaseJson releaseJson = (FutureReleaseJson) JSON.deserialize(calloutResponse.get('response'), FutureReleaseJson.class);

			List<EventsHistoryWrapper.BillDocumentList> history = processHistory(releaseJson);
			history = fillContestedItems(history, recordId);

			data.put('success', true);
			data.put('events', history);
			data.put('departureGroup', calculateAmountDeparture(history));
		} else {
			data.put('success', false);
			data.put('message', setErrorMessage(calloutResponse.get('response')));
		}
		return data;
	}

	@TestVisible
	private static List<EventsHistoryWrapper.BillDocumentList> fillContestedItems(List<EventsHistoryWrapper.BillDocumentList> items, String caseId) {
		if (!GeneralInvoicesController.isBackofficeN2())
			return items;

		Set<String> itemsIds = new Set<String>();
		for (EventsHistoryWrapper.BillDocumentList itm : items)
			itemsIds.add(String.valueOf(itm.id));

		List<String> dedupItems = new List<String>(itemsIds);

		List<vlocity_cmt__PaymentAdjustment__c> dbItems = [
			SELECT Id, idExtractItem__c, Reason__c, ContestedAmount__c, vlocity_cmt__Notes__c, vlocity_cmt__Amount__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE idExtractItem__c IN :dedupItems AND vlocity_cmt__DisputeId__r.IsClosed = FALSE AND vlocity_cmt__Status__c = 'Pending' AND vlocity_cmt__DisputeId__c = :caseId
		];

		Map<String, vlocity_cmt__PaymentAdjustment__c> dbItemsMap = new Map<String, vlocity_cmt__PaymentAdjustment__c>();
		for (vlocity_cmt__PaymentAdjustment__c itm : dbItems)
			dbItemsMap.put(itm.idExtractItem__c, itm);

		for (EventsHistoryWrapper.BillDocumentList itm : items)
			if (dbItemsMap.containsKey(String.valueOf(itm.id))) {
				itm.isSfPendingItem = true;
				itm.dbAdjustment = dbItemsMap.get(String.valueOf(itm.id));
			}

		return items;
	}

	@TestVisible
	private static Map<String, Decimal> calculateAmountDeparture(List<EventsHistoryWrapper.BillDocumentList> history) {
		Map<String, Decimal> groupValue = new Map<String, Decimal>();

		for (EventsHistoryWrapper.BillDocumentList doc : history)
			if (groupValue.containsKey(doc.partnerId))
				groupValue.put(doc.partnerId, groupValue.get(doc.partnerId) + Math.abs(doc.amountContested));
			else
				groupValue.put(doc.partnerId, Math.abs(doc.amountContested));

		return groupValue;
	}

	@TestVisible
	private static List<EventsHistoryWrapper.BillDocumentList> processHistory(FutureReleaseJson futureRelease) {
		List<EventsHistoryWrapper.BillDocumentList> lstHistory = new List<EventsHistoryWrapper.BillDocumentList>();

		for (FutureReleaseJson.Installments install : futureRelease.data.installments) {
			EventsHistoryWrapper.BillDocumentList billDoc = new EventsHistoryWrapper.BillDocumentList();

			billDoc.id = Integer.valueOf(install.idExtractItem);
			billDoc.billNo = null;
			billDoc.billId = null;
			billDoc.paymentDueDate = install.dueDate;
			billDoc.billDate = install.releaseDate;
			billDoc.description = install.descriptionExtractItem;
			billDoc.name = null;
			billDoc.installments = null;
			billDoc.extractItemTypeId = install.idExtractItemType;
			billDoc.extractItemTypeDescription = install.itemDescriptionType;
			billDoc.amountDue = install.sourceValue;
			billDoc.isContestation = null;
			billDoc.complement = null;
			billDoc.reasonId = null;
			billDoc.partnerId = '1';
			billDoc.partnerName = 'NET';
			billDoc.reasonDescription = null;
			billDoc.formattedAmount = null;
			billDoc.invoiceItemGroupDemoId = install.idInvoiceGroupDemo;
			billDoc.invoiceItemGroupDemoDescription = install.descriptionInvoiceGroupDemo;
			billDoc.extractItensDetails = null;
			billDoc.hasElegibility = install.allowContestation;
			billDoc.contestationOptions = install.contestationReasonTypes;
			billDoc.amountContested = install.value;
			lstHistory.add(billDoc);
		}

		return lstHistory;
	}

	@TestVisible
	private static Map<String, String> setParamsHistory(String contractId, String operatorId, String extractItemStatus, String dateFrom, String dateTo) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(contractId) || String.isEmpty(operatorId)) {
			String emptyFields = (String.isEmpty(contractId)) ? ', contractId' : '';
			emptyFields += (String.isEmpty(operatorId)) ? ', operatorId' : '';

			throw new EventsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			if (extractItemStatus == 'FUTURE_RELEASE')
				dateFrom = '2000-01-01';

			params.put('calldateOf', dateFrom);
			params.put('calldateFor', dateTo);
			params.put('infoDetailLevel', 'DETAILS');
			params.put('extractItemStatus', extractItemStatus);
		}

		return params;
	}

	@TestVisible
	private static String setErrorMessage(String jsonString) {
		String errorMessage = '';

		JSONEvents errorResponse = (JSONEvents) JSON.deserialize(jsonString, JSONEvents.class);
		if (errorResponse != null) {
			if (errorResponse.error != null) {
				errorMessage = errorResponse.error.errorCode + ' - ' + errorResponse.error.detailedMessage;
			} else {
				errorMessage = 'Unknown error';
			}
		} else {
			errorMessage = 'Unknown error';
		}
		return errorMessage;
	}

	public class EventsControllerException extends Exception {
	}
}