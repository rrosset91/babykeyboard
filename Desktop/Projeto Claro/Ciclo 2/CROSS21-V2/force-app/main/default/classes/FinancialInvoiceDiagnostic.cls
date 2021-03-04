/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 22-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   05-02-2021   Joao Neves   Initial Version
 **/
public without sharing class FinancialInvoiceDiagnostic {
	private static String MISSING_ITEM_TEXT_OLDER = '';
	private static String MISSING_ITEM_TEXT_NEWER = '';
	private static String DIFF_PRICE_ITEM_TEXT_POSITIVE = '';
	private static String DIFF_PRICE_ITEM_TEXT_NEGATIVE = '';
	private static String DIFF_PRICE_ITEM_PROPORCIONALITY = '';

	@AuraEnabled
	public static List<DiagnosticResponseInfos> compareInvoices(String operatorCode, String contractNumber, String oldestInvoiceNumber, String newerInvoiceNumber) {
		if (operatorCode == null || contractNumber == null || oldestInvoiceNumber == null || newerInvoiceNumber == null)
			throw new AuraHandledException('Preencha todas as informações.');

		System.debug('operatorCode' + operatorCode);
		System.debug('contractNumber' + contractNumber);
		System.debug('oldestInvoiceNumber' + oldestInvoiceNumber);
		System.debug('newerInvoiceNumber' + newerInvoiceNumber);

		fillMessageAttributes();

		InvoiceDetail firstInvoice = getInvoiceDetails(operatorCode, contractNumber, oldestInvoiceNumber);
		System.debug('firstInvoice ==>' + JSON.serializePretty(firstInvoice));
		InvoiceDetail secondInvoice = getInvoiceDetails(operatorCode, contractNumber, newerInvoiceNumber);
		System.debug('secondInvoice ==>' + JSON.serializePretty(firstInvoice));

		ComparisonWrapper comparison = new ComparisonWrapper(firstInvoice, secondInvoice);
		System.debug('comparison ==>' + JSON.serializePretty(firstInvoice));


		List<DiagnosticResponseInfos> responseList = new List<DiagnosticResponseInfos>();

		responseList.addAll(getDiffItems(comparison));
		responseList.addAll(getMissingItems(comparison));

		System.debug('comparison -> ' + JSON.serializePretty(comparison));

		return responseList;
	}

	private static void fillMessageAttributes() {
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();

		List<Parameters__c> returnedParams = [
			SELECT DescriptionDiagnostic__c, InvoiceItemCondition__c
			FROM Parameters__c
			WHERE
				InvoiceItemCondition__c IN (
					'Valor não cobrado na fatura mais antiga',
					'Valor não cobrado na fatura mais nova',
					'Variação de valores para mais',
					'Proporcionalidade',
					'Variação de valores para menos'
				)
				AND ParameterType__c = 'Item da Fatura'
				AND Process__c = 'Contestação'
				AND Active__c = TRUE
		];

		for (Parameters__c intParam : returnedParams) {
			switch on intParam.InvoiceItemCondition__c {
				when 'Valor não cobrado na fatura mais antiga' {
					MISSING_ITEM_TEXT_OLDER = intParam.DescriptionDiagnostic__c;
				}
				when 'Valor não cobrado na fatura mais nova' {
					MISSING_ITEM_TEXT_NEWER = intParam.DescriptionDiagnostic__c;
				}
				when 'Variação de valores para mais' {
					DIFF_PRICE_ITEM_TEXT_POSITIVE = intParam.DescriptionDiagnostic__c;
				}
				when 'Proporcionalidade' {
					DIFF_PRICE_ITEM_PROPORCIONALITY = intParam.DescriptionDiagnostic__c;
				}
				when 'Variação de valores para menos' {
					DIFF_PRICE_ITEM_TEXT_NEGATIVE = intParam.DescriptionDiagnostic__c;
				}
			}
		}
	}

	private static List<DiagnosticResponseInfos> getMissingItems(ComparisonWrapper comparisonObject) {
		List<DiagnosticResponseInfos> response = new List<DiagnosticResponseInfos>();

		InvoiceDetail firstInvoice = comparisonObject.firstInvoice;
		InvoiceDetail secondInvoice = comparisonObject.secondInvoice;

		for (String itemKey : comparisonObject.diffItemsFirstInvoice.keySet()) {
			InvoiceDetailItem detailItem = comparisonObject.diffItemsFirstInvoice.get(itemKey);

			DiagnosticResponseInfos dg = new DiagnosticResponseInfos();
			dg.idItem = String.valueOf(detailItem.itemId);
			dg.invoiceMonth = getMonthByDate(detailItem.invoiceContextDate).capitalize();
			dg.item = detailItem.productDescription != null ? detailItem.productDescription : detailItem.itemDescription;
			dg.analysisResult = getMissingItemAnalysis(detailItem, firstInvoice, secondInvoice, true);
			dg.difference = detailItem.value < 0 ? detailItem.value : detailItem.value - detailItem.value - detailItem.value;

			DiagnosticResponseItem dgItem = new DiagnosticResponseItem();
			dgItem.dataLancamento = getFormattedDate(detailItem.entryDate);
			dgItem.dataProporcionalidade = getFormattedDate(detailItem.proRataStartDate);
			dgItem.dataVencimento = getFormattedDate(detailItem.dueDate);
			dgItem.descricao = detailItem.itemDescription;
			dgItem.descricaoProduto = detailItem.productDescription;
			dgItem.numeroParcela = detailItem.installmentNumber;
			dgItem.totalParcela = detailItem.totalInstallments;
			dgItem.parceiro = detailItem.partnerName;

			dg.productDetails = dgItem;

			response.add(dg);
		}

		for (String itemKey : comparisonObject.diffItemsSecondInvoice.keySet()) {
			InvoiceDetailItem detailItem = comparisonObject.diffItemsSecondInvoice.get(itemKey);

			DiagnosticResponseInfos dg = new DiagnosticResponseInfos();
			dg.idItem = String.valueOf(detailItem.itemId);
			dg.invoiceMonth = getMonthByDate(detailItem.invoiceContextDate).capitalize();
			dg.item = detailItem.productDescription != null ? detailItem.productDescription : detailItem.itemDescription;
			dg.analysisResult = getMissingItemAnalysis(detailItem, secondInvoice, firstInvoice, false);
			dg.difference = detailItem.value;

			DiagnosticResponseItem dgItem = new DiagnosticResponseItem();
			dgItem.dataLancamento = getFormattedDate(detailItem.entryDate);
			dgItem.dataProporcionalidade = getFormattedDate(detailItem.proRataStartDate);
			dgItem.dataVencimento = getFormattedDate(detailItem.dueDate);
			dgItem.descricao = detailItem.itemDescription;
			dgItem.descricaoProduto = detailItem.productDescription;
			dgItem.numeroParcela = detailItem.installmentNumber;
			dgItem.totalParcela = detailItem.totalInstallments;
			dgItem.parceiro = detailItem.partnerName;

			dg.productDetails = dgItem;

			response.add(dg);
		}

		return response;
	}

	private static List<DiagnosticResponseInfos> getDiffItems(ComparisonWrapper comparisonObject) {
		List<DiagnosticResponseInfos> response = new List<DiagnosticResponseInfos>();

		for (DiffValueItems diff : comparisonObject.diffValueItems) {
			DiagnosticResponseInfos dg = new DiagnosticResponseInfos();
			dg.idItem = String.valueOf(diff.newerItem.itemId);
			dg.invoiceMonth = getMonthByDate(diff.newerItem.invoiceContextDate).capitalize();
			dg.item = diff.newerItem.productDescription != null ? diff.newerItem.productDescription : diff.newerItem.itemDescription;
			dg.analysisResult = getValueDiffItemAnalysis(diff, diff.newerInvoiceDiffValue < 0);
			dg.olderInvoiceValue = diff.oldestItem.value;
			dg.difference = diff.newerInvoiceDiffValue;

			DiagnosticResponseItem dgItem = new DiagnosticResponseItem();
			dgItem.dataLancamento = getFormattedDate(diff.newerItem.entryDate);
			dgItem.dataProporcionalidade = getFormattedDate(diff.newerItem.proRataStartDate);
			dgItem.dataVencimento = getFormattedDate(diff.newerItem.dueDate);
			dgItem.descricao = diff.newerItem.itemDescription;
			dgItem.descricaoProduto = diff.newerItem.productDescription;
			dgItem.numeroParcela = diff.newerItem.installmentNumber;
			dgItem.totalParcela = diff.newerItem.totalInstallments;
			dgItem.parceiro = diff.newerItem.partnerName;

			dg.productDetails = dgItem;

			response.add(dg);
		}

		return response;
	}

	private static string getMissingItemAnalysis(InvoiceDetailItem dtItem, InvoiceDetail firstInvoice, InvoiceDetail secondInvoice, Boolean isFirstOlder) {
		if (isFirstOlder) {
			return MISSING_ITEM_TEXT_OLDER.replaceAll('MES_INICIAL', getMonthByDate(firstInvoice.dataVencimento))
				.replaceAll('MES_FINAL', getMonthByDate(secondInvoice.dataVencimento))
				.replaceAll('VALOR_INICIAL', getFormattedMoney(dtItem.value));
		} else {
			return MISSING_ITEM_TEXT_NEWER.replaceAll('MES_INICIAL', getMonthByDate(firstInvoice.dataVencimento))
				.replaceAll('MES_FINAL', getMonthByDate(secondInvoice.dataVencimento))
				.replaceAll('VALOR_INICIAL', getFormattedMoney(dtItem.value));
		}
	}

	private static string getValueDiffItemAnalysis(DiffValueItems diff, Boolean isNewerItemCheaper) {
		if (diff.newerItem.itemDescription != null && diff.newerItem.itemDescription.toLowerCase().contains('proporcio')) {
			return DIFF_PRICE_ITEM_PROPORCIONALITY.replaceAll('VALOR_INICIAL', getFormattedMoney(diff.oldestItem.value))
				.replaceAll('MES_INICIAL', getMonthByDate(diff.oldestItem.invoiceContextDate))
				.replaceAll('VALOR_FINAL', getFormattedMoney(diff.newerItem.value))
				.replaceAll('MES_FINAL', getMonthByDate(diff.newerItem.invoiceContextDate));
		} else if (isNewerItemCheaper) {
			return DIFF_PRICE_ITEM_TEXT_NEGATIVE.replaceAll('VALOR_INICIAL', getFormattedMoney(diff.oldestItem.value))
				.replaceAll('MES_INICIAL', getMonthByDate(diff.oldestItem.invoiceContextDate))
				.replaceAll('VALOR_FINAL', getFormattedMoney(diff.newerItem.value))
				.replaceAll('MES_FINAL', getMonthByDate(diff.newerItem.invoiceContextDate));
		} else {
			return DIFF_PRICE_ITEM_TEXT_POSITIVE.replaceAll('VALOR_INICIAL', getFormattedMoney(diff.oldestItem.value))
				.replaceAll('MES_INICIAL', getMonthByDate(diff.oldestItem.invoiceContextDate))
				.replaceAll('VALOR_FINAL', getFormattedMoney(diff.newerItem.value))
				.replaceAll('MES_FINAL', getMonthByDate(diff.newerItem.invoiceContextDate));
		}
	}

	private static string getMonthByDate(Datetime dt) {
		if (dt == null)
			return null;

		Map<String, String> monthMaps = new Map<String, String>{
			'january' => 'janeiro',
			'february' => 'fevereiro',
			'march' => 'março',
			'april' => 'abril',
			'may' => 'maio',
			'june' => 'junho',
			'july' => 'julho',
			'august' => 'agosto',
			'september' => 'setembro',
			'october' => 'outubro',
			'november' => 'novembro',
			'december' => 'dezembro'
		};

		return monthMaps.get(dt.format('MMMM', 'America/Sao_Paulo').toLowerCase());
	}

	private static string getFormattedDate(Datetime dt) {
		if (dt == null)
			return null;

		return dt.format('dd/MM/yyyy', 'America/Sao_Paulo');
	}

	private static string getFormattedMoney(Decimal value) {
		if (value == null)
			return null;

		return String.valueOf(value.setScale(2));
	}

	private static InvoiceDetail getInvoiceDetails(String operatorCode, String contractNumber, String invoiceNumber) {
		Map<String, String> params = setParams(contractNumber, operatorCode, invoiceNumber);
		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoiceDetails');

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			return processDetails(calloutResponse.get('response'));
		} else {
			throw new DiagnosticException(setErrorMessage(calloutResponse.get('response')));
		}
	}

	private static Map<String, String> setParams(String contractNumber, String operatorCode, String invoiceId) {
		Map<String, String> params = new Map<String, String>();

		params.put('contractNumber', contractNumber);
		params.put('operatorCode', operatorCode);
		params.put('invoiceId', invoiceId);
		params.put('infoDetailLevel', 'DETAILS');

		return params;
	}

	private static String setErrorMessage(String jsonString) {
		String errorMessage = '';
		JSONInvoiceDetails errorResponse = (JSONInvoiceDetails) JSON.deserialize(jsonString, JSONInvoiceDetails.class);
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

	private static InvoiceDetail processDetails(String details) {
		InvoiceDetail returnDetail = new InvoiceDetail();
		JSONInvoiceDetails response = (JSONInvoiceDetails) JSON.deserialize(details, JSONInvoiceDetails.class);

		returnDetail.amount = Decimal.valueOf(response.data.amount);
		returnDetail.dataVencimento = getTimeFromStringDate(response.data.dueDate);
		returnDetail.invoiceId = response.data.invoiceId;

		List<InvoiceDetailItem> items = new List<InvoiceDetailItem>();

		for (JSONInvoiceDetails.PartnerDebt partnerItem : response.data.partnerDebts) {
			switch on partnerItem.partnerId {
				when 1 {
					items.addAll(fillProductNet(partnerItem, returnDetail.dataVencimento));
				}
				when 2 {
					items.addAll(fillProductEmbratel(partnerItem, returnDetail.dataVencimento));
				}
				when 16 {
					items.addAll(fillProductClaro(partnerItem, returnDetail.dataVencimento));
				}
				when else {
					throw new DiagnosticException('Partner Id: ' + partnerItem.partnerId + ':' + partnerItem.partnerName + 'não cadastrado no sistema');
				}
			}
		}

		returnDetail.items = items;

		return returnDetail;
	}

	private static List<InvoiceDetailItem> fillProductNet(JSONInvoiceDetails.PartnerDebt netNode, Datetime invoiceDate) {
		List<InvoiceDetailItem> items = new List<InvoiceDetailItem>();

		for (JSONInvoiceDetails.DebtGroup debtGroupInstance : netNode.debtGroup) {
			for (JSONInvoiceDetails.ExtractItem extractItemInstance : debtGroupInstance.extractItems) {
				InvoiceDetailItem item = new InvoiceDetailItem();

				String itemTypeId = extractItemInstance.idExtractItemType == null ? '' : String.valueOf(extractItemInstance.idExtractItemType);
				String pointId = extractItemInstance.pointId == null ? '' : String.valueOf(extractItemInstance.pointId);
				String productId = extractItemInstance.productId == null ? '' : String.valueOf(extractItemInstance.productId);
				String productDescription = extractItemInstance.productDescription == null ? '' : String.valueOf(extractItemInstance.productDescription);
				String itemDescription = extractItemInstance.itemDescription == null ? '' : String.valueOf(extractItemInstance.itemDescription);

				item.partnerId = 1;
				item.partnerName = 'NET';
				item.itemId = extractItemInstance.idExtractItem;
				item.itemUniqueKey = itemTypeId + pointId + productId + productDescription + itemDescription;
				item.itemDescription = extractItemInstance.itemDescription;
				// item.productDescription = extractItemInstance.productDescription;
				item.productDescription = returnItemNameFormated(item.itemDescription, extractItemInstance.productDescription);
				item.installmentNumber = extractItemInstance.installmentNumber;
				item.totalInstallments = extractItemInstance.totalInstallments;
				item.value = extractItemInstance.sourceValue;
				item.dueDate = getTimeFromStringDate(extractItemInstance.dueDate);
				item.entryDate = getTimeFromStringDate(extractItemInstance.entryDate);
				item.invoiceContextDate = invoiceDate;
				item.proRataStartDate = getProRataTrashDateFormat(extractItemInstance.proRataStartDate);

				items.add(item);
			}
		}

		return items;
	}

	private static List<InvoiceDetailItem> fillProductEmbratel(JSONInvoiceDetails.PartnerDebt embratelNode, Datetime invoiceDate) {
		List<InvoiceDetailItem> items = new List<InvoiceDetailItem>();

		for (JSONInvoiceDetails.ServiceGroup serviceGroupInstance : embratelNode.serviceGroup) {
			for (JSONInvoiceDetails.PartnerPhone phoneItemInstance : serviceGroupInstance.partnerPhones) {
				InvoiceDetailItem item = new InvoiceDetailItem();

				String originTerminal = phoneItemInstance.originTerminal == null ? '' : phoneItemInstance.originTerminal;

				item.partnerId = 2;
				item.partnerName = 'EMBRATEL';
				item.itemId = null;
				item.itemUniqueKey = originTerminal;
				item.itemDescription = phoneItemInstance.originTerminal;
				item.productDescription = returnItemNameFormated(item.itemDescription, serviceGroupInstance.groupDescription);
				// item.productDescription = serviceGroupInstance.groupDescription;
				item.installmentNumber = null;
				item.totalInstallments = null;
				item.value = Decimal.valueOf(phoneItemInstance.amount);
				item.dueDate = getTimeFromStringDate(embratelNode.dueDate);
				item.entryDate = getTimeFromStringDate(embratelNode.generationDate);
				item.invoiceContextDate = invoiceDate;

				items.add(item);
			}
		}

		return items;
	}

	private static List<InvoiceDetailItem> fillProductClaro(JSONInvoiceDetails.PartnerDebt claroNode, Datetime invoiceDate) {
		List<InvoiceDetailItem> items = new List<InvoiceDetailItem>();

		for (JSONInvoiceDetails.ServiceGroup serviceGroupInstance : claroNode.serviceGroup) {
			for (JSONInvoiceDetails.PartnerExtract extractItemInstance : serviceGroupInstance.partnerExtracts) {
				InvoiceDetailItem item = new InvoiceDetailItem();

				String itemTypeId = extractItemInstance.idExtractItemType == null ? '' : String.valueOf(extractItemInstance.idExtractItemType);

				item.partnerId = 16;
				item.partnerName = 'CLARO';
				item.itemId = extractItemInstance.idExtractItem;
				item.itemUniqueKey = itemTypeId;
				item.itemDescription = extractItemInstance.partnerItemDescription.toUpperCase();
				item.productDescription = null;
				item.installmentNumber = extractItemInstance.installmentNumber;
				item.totalInstallments = extractItemInstance.totalInstallments;
				item.value = extractItemInstance.amount;
				item.dueDate = getTimeFromStringDate(extractItemInstance.dueDate);
				item.entryDate = getTimeFromStringDate(extractItemInstance.entryDate);
				item.invoiceContextDate = invoiceDate;

				items.add(item);
			}
		}

		return items;
	}

	private static String returnItemNameFormated(String strPre, String strPos){
		// String returnString;
		// strPre = String.isNotEmpty(strPre) ? strPre : '';
		// strPos = String.isNotEmpty(strPos) ? strPos : '';

		// returnString = (String.isNotEmpty(strPre) ? strPre : '') + (String.isNotEmpty(strPre) ? ' - ' : '') + (String.isNotEmpty(strPos) ? strPos : '');

		return (String.isNotEmpty(strPre) ? strPre.toUpperCase() : '') + (String.isNotEmpty(strPre) && String.isNotEmpty(strPos) ? ' - ' : '') + (String.isNotEmpty(strPos) ? strPos.toUpperCase() : '');
	}

	private static DateTime getTimeFromStringDate(String integrationFormatDate) {
		if (integrationFormatDate == null)
			return null;
		String[] dtArray = integrationFormatDate.split('-');

		return Date.newInstance(Integer.valueOf(dtArray[0]), Integer.valueOf(dtArray[1]), Integer.valueOf(dtArray[2].substring(0, 2)));
	}

	private static DateTime getProRataTrashDateFormat(String dtString) {
		if (dtString == null)
			return null;

		String[] dtArray = dtString.split(' ');
		return Date.newInstance(Integer.valueOf(dtArray[5]), Integer.valueOf(InvoicesUtils.getMonthNameInNumber(dtArray[1])), Integer.valueOf(dtArray[2]));
	}

	public class InvoiceDetail {
		public decimal amount;
		public long invoiceId;
		public DateTime dataVencimento;
		public List<InvoiceDetailItem> items;

		public boolean isMostValuableInvoice(InvoiceDetail invoice) {
			return this.amount > invoice.amount;
		}

		public integer getInvoiceMonth() {
			return Integer.valueOf(dataVencimento.format('MM', 'America/Sao_Paulo'));
		}

		public decimal getPriceDiff(InvoiceDetail invoice) {
			return this.amount - invoice.amount;
		}
	}

	public class InvoiceDetailItem {
		public string partnerName;
		public integer partnerId;
		public long itemId;
		public string itemUniqueKey;
		public string itemDescription;
		public string productDescription;
		public integer installmentNumber;
		public integer totalInstallments;
		public decimal value;
		public long productId;
		public DateTime dueDate;
		public DateTime entryDate;
		public DateTime invoiceContextDate;
		public DateTime proRataStartDate;

		public boolean isSameItem(String keyId) {
			return this.itemUniqueKey == keyId;
		}

		public boolean isMostExpensiveItemValue(InvoiceDetailItem d) {
			return this.value > d.value;
		}
	}

	public class ComparisonWrapper {
		public InvoiceDetail firstInvoice;
		public InvoiceDetail secondInvoice;
		public boolean isFirstInvoiceMoreExpensive;
		public boolean isFirstInvoiceOlder;
		public decimal priceDiffFirstInvoice;
		public decimal priceDiffSecondInvoice;
		public integer firstInvoiceItemsCount;
		public integer secondInvoiceItemsCount;
		public Map<String, InvoiceDetailItem> firstInvoiceItems;
		public Map<String, InvoiceDetailItem> secondInvoiceItems;
		//Itens que existem na primeira fatura mas nao na segunda.
		public Map<String, InvoiceDetailItem> diffItemsFirstInvoice;
		//Itens que existem na segunda fatura mas nao na primeira.
		public Map<String, InvoiceDetailItem> diffItemsSecondInvoice;
		//Itens que estão nas duas faturas mas com preços diferentes.
		public List<DiffValueItems> diffValueItems;

		public ComparisonWrapper() {
		}

		public ComparisonWrapper(InvoiceDetail firstInvoice, InvoiceDetail secondInvoice) {
			this.firstInvoice = firstInvoice;
			this.secondInvoice = secondInvoice;
			this.isFirstInvoiceMoreExpensive = this.firstInvoice.isMostValuableInvoice(this.secondInvoice);
			this.isFirstInvoiceOlder = this.firstInvoice.getInvoiceMonth() < this.secondInvoice.getInvoiceMonth();
			this.priceDiffFirstInvoice = this.firstInvoice.getPriceDiff(this.secondInvoice);
			this.priceDiffSecondInvoice = this.secondInvoice.getPriceDiff(this.firstInvoice);
			this.firstInvoiceItemsCount = this.firstInvoice.items.size();
			this.secondInvoiceItemsCount = this.secondInvoice.items.size();
			this.firstInvoiceItems = itemsToMap(this.firstInvoice.items);
			this.secondInvoiceItems = itemsToMap(this.secondInvoice.items);
			this.diffItemsFirstInvoice = getDiffItems(this.firstInvoiceItems, this.secondInvoiceItems);
			this.diffItemsSecondInvoice = getDiffItems(this.secondInvoiceItems, this.firstInvoiceItems);
			this.diffValueItems = getDiffValueItems(this.firstInvoiceItems, this.secondInvoiceItems);
		}

		private Map<String, InvoiceDetailItem> getDiffItems(Map<String, InvoiceDetailItem> firstInvoiceItems, Map<String, InvoiceDetailItem> secondInvoiceItems) {
			Map<String, InvoiceDetailItem> retMap = new Map<String, InvoiceDetailItem>();

			for (String itemId : firstInvoiceItems.keySet())
				if (!secondInvoiceItems.containsKey(itemId))
					retMap.put(itemId, firstInvoiceItems.get(itemId));

			return retMap;
		}
		//Changed how to get value when item key its not unique
		private Map<String, InvoiceDetailItem> itemsToMap(List<InvoiceDetailItem> items) {
			Map<String, InvoiceDetailItem> retMap = new Map<String, InvoiceDetailItem>();

			for (InvoiceDetailItem detailItem : items){
				System.debug('itemsToMap::itemUniqueKey==>' + detailItem.itemUniqueKey);
				System.debug('itemsToMap::containsKey==>' + retMap.containsKey(detailItem.itemUniqueKey));

				if(!retMap.containsKey(detailItem.itemUniqueKey)){
					retMap.put(detailItem.itemUniqueKey, detailItem);
				}else{
					InvoiceDetailItem invoice = retMap.get(detailItem.itemUniqueKey);
					System.debug('itemsToMap::invoice.value ==>' + Integer.valueOf(invoice.value));
					System.debug('itemsToMap::detailItem.value ==>' + Integer.valueOf(detailItem.value));

					retMap.get(detailItem.itemUniqueKey).value = Integer.valueOf(invoice.value) +  Integer.valueOf(detailItem.value);
				}
			}

			return retMap;
		}

		private List<DiffValueItems> getDiffValueItems(Map<String, InvoiceDetailItem> firstInvoiceItems, Map<String, InvoiceDetailItem> secondInvoiceItems) {
			List<DiffValueItems> retList = new List<DiffValueItems>();

			for (String firstInvoiceItemKey : firstInvoiceItems.keySet()) {
				if (!secondInvoiceItems.containsKey(firstInvoiceItemKey))
					continue;

				InvoiceDetailItem firstItem = firstInvoiceItems.get(firstInvoiceItemKey);
				InvoiceDetailItem secondItem = secondInvoiceItems.get(firstInvoiceItemKey);

				if (firstItem.value == secondItem.value)
					continue;

				DiffValueItems diff = new DiffValueItems();
				diff.itemId = firstInvoiceItemKey;
				diff.oldestItem = firstItem;
				diff.newerItem = secondItem;
				diff.partnerId = diff.newerItem.partnerId;
				diff.isOldestItemCheaper = diff.oldestItem.value < diff.newerItem.value;
				diff.oldestInvoiceItemValue = diff.oldestItem.value;
				diff.newerInvoiceItemValue = diff.newerItem.value;
				diff.oldestInvoiceDiffValue = diff.oldestItem.value - diff.newerItem.value;
				diff.newerInvoiceDiffValue = diff.newerItem.value - diff.oldestItem.value;

				retList.add(diff);
			}

			return retList;
		}
	}

	public class DiffValueItems {
		public string itemId;
		public string productId;
		public integer partnerId;
		public boolean isOldestItemCheaper;
		public decimal oldestInvoiceItemValue;
		public decimal newerInvoiceItemValue;
		public decimal oldestInvoiceDiffValue;
		public decimal newerInvoiceDiffValue;
		public InvoiceDetailItem oldestItem;
		public InvoiceDetailItem newerItem;
	}

	public class DiagnosticResponseInfos {
		@AuraEnabled
		public string item;
		@AuraEnabled
		public string analysisResult;
		@AuraEnabled
		public string invoiceMonth;
		@AuraEnabled
		public string idItem;
		@AuraEnabled
		public decimal olderInvoiceValue;
		@AuraEnabled
		public decimal difference;
		@AuraEnabled
		public DiagnosticResponseItem productDetails;
	}

	public class DiagnosticResponseItem {
		@AuraEnabled
		public string dataVencimento;
		@AuraEnabled
		public string dataProporcionalidade;
		@AuraEnabled
		public string dataLancamento;
		@AuraEnabled
		public integer totalParcela;
		@AuraEnabled
		public integer numeroParcela;
		@AuraEnabled
		public string descricao;
		@AuraEnabled
		public string descricaoProduto;
		@AuraEnabled
		public string parceiro;
	}

	public class DiagnosticException extends Exception {
	}
}