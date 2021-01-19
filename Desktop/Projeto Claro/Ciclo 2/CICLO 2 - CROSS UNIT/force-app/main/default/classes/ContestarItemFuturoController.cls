public without sharing class ContestarItemFuturoController {
	@AuraEnabled
	public static List<InvoiceDetailsController.ReasonOption> getContestationOptions() {
		List<InvoiceDetailsController.ReasonOption> options = new List<InvoiceDetailsController.ReasonOption>();
		for (Motivos_de_Contestacao__mdt mtConst : [SELECT ID_MOTIVO_CONTESTACAO__c, Motivo_Salesforce__c, PartnerId__c FROM Motivos_de_Contestacao__mdt])
			options.add(new InvoiceDetailsController.ReasonOption(mtConst.Motivo_Salesforce__c, String.valueOf(mtConst.ID_MOTIVO_CONTESTACAO__c), mtConst.PartnerId__c));
		return options;
	}

	@AuraEnabled
	public static ContestationResponse performContestation(String contestationString, Boolean isCaseApprovation) {
		ContestationObject contestationObj = (ContestationObject) JSON.deserialize(contestationString, ContestationObject.class);

		System.debug('performContestation -> ' + JSON.serializePretty(contestationObj));

		Map<Integer, Decimal> partnerAndDeparture = createDepartureMap(contestationObj.dpGroup);
		Map<Integer, Decimal> partnerAndValue = getValuesGrouped(contestationObj.items);
		Map<Integer, List<ContestationItem>> groupedItemsByPartner = groupItemsByPartner(contestationObj.items);
		Map<Integer, String> partnerHashMap = new Map<Integer, String>();
		Boolean hasAuth = true;

		for (Integer partnerId : partnerAndValue.keySet()) {
			Decimal departureValue = partnerAndDeparture.get(partnerId);
			Decimal contestationGroupValue = partnerAndValue.get(partnerId);
			Decimal totalValue = departureValue + contestationGroupValue;
			String joinItemsDescription = getItemsDescription(groupedItemsByPartner.get(partnerId));
			Integer contestedItemsQuantity = groupedItemsByPartner.get(partnerId).size();

			String partnerHash = getPartnerHash(
				contestedItemsQuantity,
				joinItemsDescription,
				contestationObj.operatorCode,
				contestationObj.contractNumber,
				totalValue,
				contestationGroupValue,
				partnerId
			);

			if (partnerHash == null || partnerHash == '')
				hasAuth = false;

			partnerHashMap.put(partnerId, partnerHash);
		}

		if (hasAuth) {
			Map<String, String> contestationHeaders = setHeaders('ContestItemFuture');
			List<ContestationItem> items = new List<ContestationItem>();

			for (List<ContestationItem> itemsList : groupedItemsByPartner.values())
				items.addAll(itemslist);

			String body = getBodyDispute(
				partnerAndValue,
				partnerAndDeparture,
				partnerHashMap,
				items,
				contestationObj.operatorCode,
				contestationObj.contractNumber,
				InvoicesUtils.getCalloutUser('InvoiceAuthority')
			);

			System.debug('@@@@@ body dispute -> ' + body);

			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(body, new Map<String, String>(), contestationHeaders, 'ContestItemFuture');

			System.debug('@@@@ response dispute -> ' + JSON.serializePretty(calloutResponse));

			if (Integer.valueOf(calloutResponse.get('statusCode')) >= 400)
				throw new ContestationException('Claro API Erro: ' + getErrorMessage(calloutResponse.get('response')));
		}

		if (isCaseApprovation) {
			Boolean partiallyApproved = updatePaymentItems(contestationObj, hasAuth);
			updateCaseN2(contestationObj.caseId, contestationObj.comment, hasAuth, partiallyApproved);
		} else {
			updateCaseN1(contestationObj.caseId, contestationObj.comment, hasAuth);
			createPaymentItems(contestationObj, hasAuth);
		}

		return new ContestationResponse(hasAuth);
	}

	@AuraEnabled
	public static void denyCase(String caseId, String caseComment) {
		if (caseId == null)
			throw new ContestationException('Caso não enviado');

		update new Case(Id = caseId, Status = 'Closed', LeavingReason__c = 'Contestação Negada', EntryReason__c = 'Validação de Contestação de Valores', Description = caseComment);

		List<vlocity_cmt__PaymentAdjustment__c> items = [SELECT Id FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__DisputeId__c = :caseId];
		for (vlocity_cmt__PaymentAdjustment__c item : items)
			item.vlocity_cmt__Status__c = 'Denied';

		update items;
	}

	@AuraEnabled
	public static void setReturnMethod(String caseId, String returnMethod) {
		List<Case> cases = [SELECT Id FROM Case WHERE Id = :caseId];
		if (cases.isEmpty())
			throw new ContestationException('Caso não encontrado');

		update new Case(Id = cases[0].Id, PreferencialContact__c = returnMethod);
	}

	private static boolean updatePaymentItems(ContestationObject constObj, Boolean hasAuth) {
		List<vlocity_cmt__PaymentAdjustment__c> payAdjust = [
			SELECT Id, vlocity_cmt__Status__c, vlocity_cmt__Notes__c, vlocity_cmt__Amount__c, idExtractItem__c, ContestedAmount__c, Reason__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE vlocity_cmt__DisputeId__c = :constObj.caseId
		];

		List<Account> contractList = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = :constObj.contractNumber AND ContractReferenceNumber__c != NULL];

		Id recordTypeId = Schema.getGlobalDescribe()
			.get('vlocity_cmt__PaymentAdjustment__c')
			.getDescribe()
			.getRecordTypeInfosByDeveloperName()
			.get('Itens_Contestados')
			.getRecordTypeId();

		Map<String, vlocity_cmt__PaymentAdjustment__c> adjustMap = new Map<String, vlocity_cmt__PaymentAdjustment__c>();
		for (vlocity_cmt__PaymentAdjustment__c item : payAdjust)
			adjustMap.put(item.idExtractItem__c, item);

		Boolean parcialApproved = false;

		List<vlocity_cmt__PaymentAdjustment__c> payAdjusts = new List<vlocity_cmt__PaymentAdjustment__c>();
		for (ContestationItem item : constObj.items) {
			vlocity_cmt__PaymentAdjustment__c adjustItem = adjustMap.get(String.valueOf(item.itemId));

			if (adjustItem == null) {
				adjustItem = new vlocity_cmt__PaymentAdjustment__c();
				adjustItem.idExtractItem__c = String.valueOf(item.itemId);
				adjustItem.recordTypeId = recordTypeId;
				adjustItem.vlocity_cmt__AccountId__c = contractList[0].Id;
				adjustItem.vlocity_cmt__Amount__c = item.originalValue;
				adjustItem.vlocity_cmt__Date__c = Date.today();
				adjustItem.vlocity_cmt__DisputeId__c = constObj.caseId;
			}

			adjustItem.vlocity_cmt__Status__c = 'Approved';
			adjustItem.Reason__c = String.valueOf(item.contestationReason);
			adjustItem.vlocity_cmt__Notes__c = item.note;
			adjustItem.ContestedAmount__c = item.originalValue - item.valorContestar;
			adjustItem.ItemType__c = 'Lançamentos Futuros';
			payAdjusts.add(adjustItem);
		}

		for (vlocity_cmt__PaymentAdjustment__c payItem : adjustMap.values())
			if (payItem.vlocity_cmt__Status__c == 'Pending') {
				payItem.vlocity_cmt__Status__c = 'Denied';
				parcialApproved = true;
				payAdjusts.add(payItem);
			}

		upsert payAdjusts;
		return parcialApproved;
	}

	private static Map<Integer, List<ContestationItem>> groupItemsByPartner(List<ContestationItem> items) {
		Map<Integer, List<ContestationItem>> itemsGrouped = new Map<Integer, List<ContestationItem>>();

		for (ContestationItem itemInst : items) {
			Integer key = itemInst.partnerId;

			if (itemsGrouped.containsKey(key)) {
				List<ContestationItem> itemsList = itemsGrouped.get(key);
				itemsList.add(itemInst);
				itemsGrouped.put(key, itemsList);
			} else
				itemsGrouped.put(key, new List<ContestationItem>{ itemInst });
		}

		return itemsGrouped;
	}

	private static Map<Integer, Decimal> createDepartureMap(List<ContestarItemFuturoController.DepartureGroup> depGroup) {
		Map<Integer, Decimal> retMap = new Map<Integer, Decimal>();

		for (ContestarItemFuturoController.DepartureGroup dpGrp : depGroup)
			retMap.put(dpGrp.partnerId, dpGrp.value);

		return retMap;
	}

	private static Map<Integer, Decimal> getValuesGrouped(List<ContestationItem> items) {
		Map<Integer, Decimal> groupValues = new Map<Integer, Decimal>();

		for (ContestationItem item : items) {
			Integer key = item.partnerId;
			Decimal valorContestar = item.valorContestar;

			if (groupValues.containskey(key)) {
				Decimal val = groupValues.get(key);
				val += valorContestar;
				groupValues.put(key, val);
			} else {
				groupValues.put(key, valorContestar);
			}
		}

		return groupValues;
	}

	private static String getPartnerHash(
		Integer itemsQuantity,
		String itemsDescription,
		String operatorCode,
		String contractNumber,
		Decimal totalAmount,
		Decimal partnerItemsAmount,
		Integer partnerId
	) {
		Boolean hasSfAuth = FinancialHierarchy.hasSalesforceAuthority(itemsDescription, itemsQuantity, contractNumber, totalAmount);

		if (!hasSfAuth)
			return null;

		Map<String, String> params = setParamsAuthority(operatorCode, contractNumber, InvoicesUtils.getCalloutUser('InvoiceAuthority'), totalAmount, partnerItemsAmount, partnerId);
		System.debug('@@@ params auth -> ' + JSON.serializePretty(params));
		Map<String, Object> hashMap = FinancialHierarchy.performLegacyAuthCall(params);

		if (!Boolean.valueOf(hashMap.get('success')))
			throw new ContestationException('Falha ao receber autorização do legado.');

		HierarchyLimitWrapper resp = (HierarchyLimitWrapper) hashMap.get('authority');

		return resp.hashAutoridade;
	}

	private static String getItemsDescription(List<ContestationItem> items) {
		Set<String> itemsSet = new Set<String>();

		for (ContestationItem itemInst : items)
			itemsSet.add(itemInst.description);

		return String.join(new List<String>(itemsSet), ' ').trim();
	}

	private static Map<String, String> setParamsAuthority(String operator, String contract, String username, Decimal amount, Decimal groupAmount, Integer partnerId) {
		Map<String, String> params = new Map<String, String>();

		params.put('operatorCode', operator);
		params.put('contractNumber', contract);
		params.put('userName', username);
		params.put('amount', String.valueOf(amount));
		params.put('partnerId', String.valueOf(partnerId));
		params.put('amountTela', String.valueOf(groupAmount));
		params.put('functionalityRuleId', '2');

		return params;
	}

	private static Map<String, String> setheaders(String settingName) {
		ServiceParameter__c params = ServiceParameter__c.getInstance(settingName);

		Map<String, String> retMap = new Map<String, String>();
		retMap.put('Content-Type', 'application/json');
		retMap.put('X-Client-Auth', params.Token__c);
		return retMap;
	}

	private static String getBodyDispute(
		Map<Integer, Decimal> partnerAndValue,
		Map<Integer, Decimal> groupDeparture,
		Map<Integer, String> hashAuth,
		List<ContestationItem> items,
		String operatorId,
		String contractnumber,
		String username
	) {
		List<Account> acc = [
			SELECT ParentId, Parent.Name, Parent.CellPhone__c, Parent.vlocity_cmt__BillingEmailAddress__c
			FROM Account
			WHERE ContractReferenceNumber__c = :contractnumber AND Parent.RecordType.Name = 'Consumer'
		];

		String phone = '11999999999';
		String name = 'Nao tem';

		if (!acc.isEmpty() && acc[0].ParentId != null) {
			if (acc[0].Parent.CellPhone__c != null)
				phone = acc[0].Parent.CellPhone__c.right(9).trim();
			name = acc[0].Parent.Name;
		}

		List<JSONDisputeFutureInvoice.ContestationFutureItem> contestationItems = new List<JSONDisputeFutureInvoice.ContestationFutureItem>();
		JSONDisputeFutureInvoice body = new JSONDisputeFutureInvoice();
		JSONDisputeFutureInvoice.Data data = new JSONDisputeFutureInvoice.Data();

		data.operatorCode = operatorId;
		data.contractNumber = contractnumber.replaceFirst('^0+(?!$)', '');
		data.userName = username;
		data.name = name;
		data.phoneNumber = phone;
		data.contestationOrigin = 1;

		for (ContestationItem itemInst : items) {
			JSONDisputeFutureInvoice.ContestationFutureItem constItem = new JSONDisputeFutureInvoice.ContestationFutureItem();

			if (itemInst.partnerId == 1)
				constItem.idExtractItem = itemInst.itemId;

			Decimal totalDeparture = groupDeparture.get(itemInst.partnerId) + partnerAndValue.get(itemInst.partnerId);

			constItem.value = itemInst.valorContestar;
			constItem.contestationReasonId = itemInst.contestationReason;
			constItem.note = itemInst.note;
			constItem.hashAuthority = hashAuth.get(itemInst.partnerId);

			contestationItems.add(constItem);
		}

		data.installments = contestationItems;

		body.data = data;

		return JSON.serialize(body);
	}

	private static String getErrorMessage(Object responseData) {
		if (responseData == null)
			return 'erro de integracao. A mensagem retornada é nula.';

		String errorKey = 'error';

		Map<String, Object> untypedResponse = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(responseData));
		Map<String, Object> untypedError = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedResponse.get(errorKey)));

		return String.valueOf(untypedError.get('message'));
	}

	private static void updateCaseN1(String caseId, String comment, Boolean hasAuth) {
		Case cs = new Case(Id = caseId);
		cs.RequestSupport__c = comment;
		cs.EntryReason__c = 'Validação de Contestação de Valores';
		cs.LeavingReason__c = hasAuth ? 'Contestação Realizada' : null;
		cs.Solar_Cross_forwardingReason__c = !hasAuth ? 'Fora da alçada' : null;
		if (hasAuth)
			cs.Status = 'Closed';

		update cs;
	}

	private static void updateCaseN2(String caseId, String comment, Boolean hasAuth, Boolean partiallyApproved) {
		Case cs = new Case(Id = caseId);
		cs.LeavingReason__c = partiallyApproved ? 'Contestação Parcialmente Aprovada' : 'Contestação aprovada';
		cs.EntryReason__c = 'Validação de Contestação de Valores';
		cs.Description = comment;
		cs.Status = 'Closed';
		update cs;
	}

	private static void createPaymentItems(ContestationObject constObj, Boolean hasAuth) {
		List<vlocity_cmt__PaymentAdjustment__c> retList = new List<vlocity_cmt__PaymentAdjustment__c>();
		List<Account> acc = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = :constObj.contractNumber AND RecordType.Name = 'Billing'];

		if (acc.isEmpty())
			throw new ContestationException('Conta não encontrada.');

		Id recordTypeId = Schema.getGlobalDescribe()
			.get('vlocity_cmt__PaymentAdjustment__c')
			.getDescribe()
			.getRecordTypeInfosByDeveloperName()
			.get('Itens_Contestados')
			.getRecordTypeId();

		if (constObj.items == null || constObj.items.isEmpty())
			return;

		for (ContestationItem item : constObj.items) {
			vlocity_cmt__PaymentAdjustment__c adjustment = new vlocity_cmt__PaymentAdjustment__c();

			adjustment.RecordTypeId = recordTypeId;
			adjustment.vlocity_cmt__AccountId__c = acc[0].Id;
			adjustment.idExtractItem__c = String.valueOf(item.itemId);
			adjustment.vlocity_cmt__Amount__c = item.originalValue;
			adjustment.vlocity_cmt__Date__c = Date.today();
			adjustment.vlocity_cmt__DisputeId__c = constObj.caseId;
			adjustment.ContestedAmount__c = item.originalValue - item.valorContestar;
			adjustment.vlocity_cmt__Status__c = hasAuth ? 'Approved' : 'Pending';
			adjustment.Reason__c = String.valueOf(item.contestationReason);
			adjustment.vlocity_cmt__Notes__c = item.note;
			adjustment.ItemType__c = 'Lançamentos Futuros';

			retList.add(adjustment);
		}

		insert retList;
	}

	public class ContestationObject {
		@AuraEnabled
		public String caseId;

		@AuraEnabled
		public String operatorCode;

		@AuraEnabled
		public String contractNumber;

		@AuraEnabled
		public String comment;

		@AuraEnabled
		public List<ContestationItem> items;

		@AuraEnabled
		public List<DepartureGroup> dpGroup;
	}

	public class ContestationItem {
		@AuraEnabled
		public Long itemId;

		@AuraEnabled
		public Decimal originalValue;

		@AuraEnabled
		public Decimal valorContestar;

		@AuraEnabled
		public Decimal valorCorrigido;

		@AuraEnabled
		public Integer contestationReason;

		@AuraEnabled
		public Integer partnerId;

		@AuraEnabled
		public String description;

		@AuraEnabled
		public String note;
	}

	public class DepartureGroup {
		@AuraEnabled
		public Integer partnerId;
		@AuraEnabled
		public Decimal value;
	}

	public class ContestationResponse {
		@AuraEnabled
		public Boolean hasAuthority = false;

		public ContestationResponse(Boolean hasAuth) {
			this.hasAuthority = hasAuth;
		}
	}

	public class ContestationException extends Exception {
	}
}