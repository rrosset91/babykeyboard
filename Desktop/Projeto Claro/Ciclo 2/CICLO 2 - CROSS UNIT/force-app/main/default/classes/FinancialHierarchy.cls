public without sharing class FinancialHierarchy {
	public static Map<String, Object> getAuthority(
		CEC_DisputeInvoice.DisputeInvoiceRequest req,
		String operator,
		String contract,
		String username,
		Decimal amount,
		Integer partnerId,
		String billId
	) {
		//Diminuir o numero de parametros pegando somente do request;
		Map<String, Object> data = new Map<String, Object>();
		username = InvoicesUtils.getCalloutUser('InvoiceAuthority');

		Map<String, String> params = setParamsAuthority(operator, contract, username, amount, partnerId, billId);

		Boolean hasSfAuth = hasSalesforceAuthority(req, amount);

		//Integer oi = Integer.valueOf('HJO ' + hasSfAuth);
		if (hasSfAuth) {
			data = performLegacyAuthCall(params);
		} else {
			data.put('success', false);
			data.put('message', 'Error authority salesforce');
		}

		return data;
	}

	public static Map<String, Object> performLegacyAuthCall(Map<String, String> params) {
		Map<String, Object> data = new Map<String, Object>();

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(null, params, null, 'InvoiceAuthority');

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			data.put('success', true);
			data.put('authority', processAuthority(calloutResponse.get('response')));
		} else {
			data.put('success', false);
			data.put('message', setErrorMessage(calloutResponse.get('response')));
		}
		return data;
	}

	public static Map<String, String> setParamsAuthority(String operator, String contract, String username, Decimal amount, Integer partnerId, String billId) {
		Map<String, String> params = new Map<String, String>();
		params.put('operatorCode', operator);
		params.put('contractNumber', contract);
		params.put('userName', username);
		params.put('amount', String.valueOf(amount));
		params.put('partnerId', String.valueOf(partnerId));
		params.put('amountTela', String.valueOf(amount));
		params.put('functionalityRuleId', '2');
		params.put('billId', billId);
		return params;
	}

	public static boolean hasSalesforceAuthority(String itemTypeDescription, Integer numberOfItems, String contractNumber, Decimal amount) {
		CEC_DisputeInvoice.DisputeInvoiceRequest req = new CEC_DisputeInvoice.DisputeInvoiceRequest();
		req.contractNumber = contractNumber;

		List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
		for (Integer i = 0; i < numberOfItems; i++) {
			CEC_DisputeInvoice.InvoiceItem item = new CEC_DisputeInvoice.InvoiceItem();
			item.itemDescription = itemTypeDescription;
			lst.add(item);
		}

		req.invoiceItems = lst;

		return hasSalesforceAuthority(req, amount);
	}

	public static boolean hasSalesforceAuthority(CEC_DisputeInvoice.DisputeInvoiceRequest req, Decimal amount) {
		Boolean salesforceHasAuth = true;
		String contract = req.contractNumber;
		Account contrato;
		List<Account> contratoList = new List<Account>();
		List<User> lstUser = new List<User>();
		List<PermissionSetAssignment> lstPermissionSet = new List<PermissionSetAssignment>();
		List<Parameters__c> lstParametro = new List<Parameters__c>();
		List<Case> lstCase = new List<Case>();

		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Id recordTypeIdPayment = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName().get('Itens_Contestados').getRecordTypeId();

		contratoList = [
			SELECT Id, name, StatusLegado__c, vlocity_cmt__CustomerValue__c, ContractNumber__c
			FROM Account
			WHERE ContractReferenceNumber__c = :contract AND RecordTypeId = :recordTypeIdAccount
		];

		System.debug('Contrato query -> ' + contratoList.size());

		if (contratoList.isEmpty())
			return false;

		contrato = contratoList[0];

		lstUser = [SELECT Id, Name, UserRoleId, UserRole.DeveloperName FROM User WHERE UserRoleId != NULL AND Id = :UserInfo.getUserId()];
		lstPermissionSet = [SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()];

		Map<String, PermissionSetAssignment> permissionSets = new Map<String, PermissionSetAssignment>();
		for (PermissionSetAssignment assign : lstPermissionSet)
			permissionSets.put(assign.PermissionSet.Name, assign);

		lstParametro = [
			SELECT
				id,
				name,
				active__c,
				Amount__c,
				Profile__c,
				Segment__c,
				ItemType__c,
				ContractStatus__c,
				ItemQtt__c,
				ContractMonths__c,
				Process__c,
				Channel__c,
				ContestationQtt__c,
				TotalAmount__c,
				PercentageApprovedContestation__c,
				Period__c,
				MinContestationQtt__c
			FROM Parameters__c
			WHERE Active__c = TRUE AND RecordTypeId = :recordTypeIdParameter
		];

		lstCase = [
			SELECT Id, Status, EntryReason__c, LeavingReason__c, ClosedDate, Owner.Name, createdby.UserRoleId
			FROM Case
			WHERE
				recordtype.developername = 'Financial'
				AND Status = 'Closed'
				AND EntryReason__c = 'Validação de Contestação de Valores'
				AND LeavingReason__c IN ('Contestação aprovada', 'Contestação Aprovada com ajustes', 'Contestação realizada')
				AND ClosedDate = TODAY
				AND OwnerId IN :lstUser
		];
		/*
			Melhoria - Alterar motivo de saída:
			De: Contestação Parcialmente Aprovada
			Para: Contestacao aprovada com ajustes 
			Roger Rosset - 23-09-2020
		*/
		List<Case> lstCaseN2Aprovado = [
			SELECT Id, Status, EntryReason__c, LeavingReason__c, ClosedDate, Owner.Name, createdby.UserRoleId, Authorization__c, AttendanceByUser__c
			FROM Case
			WHERE
				recordtype.developername = 'Financial'
				AND Status = 'Closed'
				AND EntryReason__c = 'Validação de Contestação de Valores'
				AND LeavingReason__c = 'Contestação aprovada'
				AND Solar_Cross_forwardingReason__c = 'Fora da alçada'
				AND ClosedDate >= LAST_N_MONTHS:5
				AND AttendanceByUser__c = :UserInfo.getUserId()
		];

		List<Case> lstCaseN2Total = [
			SELECT Id, Status, EntryReason__c, LeavingReason__c, ClosedDate, Owner.Name, createdby.UserRoleId, Authorization__c, AttendanceByUser__c
			FROM Case
			WHERE
				recordtype.developername = 'Financial'
				AND Status = 'Closed'
				AND EntryReason__c = 'Validação de Contestação de Valores'
				AND LeavingReason__c IN ('Contestação aprovada', 'Contestação Aprovada com ajustes', 'Contestação Negada')
				AND Solar_Cross_forwardingReason__c = 'Fora da alçada'
				AND ClosedDate >= LAST_N_MONTHS:5
				AND AttendanceByUser__c = :UserInfo.getUserId()
		];

		Decimal N2Aprovado = lstCaseN2Aprovado.size();
		Decimal N2Total = lstCaseN2Total.size();
		Double porcentagemAprovacao = 0;

		if (N2Aprovado != 0 && N2Total != 0)
			porcentagemAprovacao = (N2Aprovado / N2Total) * 100;

		System.debug('Tamanho lstCaseN2Aprovado -> ' + N2Aprovado);
		System.debug('Tamanho lstCaseN2Total -> ' + N2Total);
		System.debug('lstCase porcentagemAprovacao -> ' + porcentagemAprovacao);

		List<vlocity_cmt__PaymentAdjustment__c> lstPayment = [
			SELECT ContestationAmount__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE RecordTypeId = :recordTypeIdPayment AND vlocity_cmt__DisputeId__c IN :lstCase AND ContestationAmount__c != NULL
		];
		Decimal total = 0;

		for (vlocity_cmt__PaymentAdjustment__c paym : lstPayment) {
			total = total + paym.ContestationAmount__c;
		}

		System.debug('total -> ' + total);

		Integer itemQuantity = req.invoiceItems.size();
		String itemType = getItemType(req.invoiceItems);
		Id profileId = UserInfo.getProfileId();
		String usrProfileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
		Boolean isDigitalProfile = usrProfileName == 'SF_DAC_Digital';

		if (!lstUser.isEmpty() && !lstParametro.isEmpty() && contrato != null) {
			salesforceHasAuth = false;
			Boolean parametrosVerificado = false;
			Set<Parameters__c> availableParameters = new Set<Parameters__c>();

			Boolean contestationQttBool = false;
			for (Parameters__c parametro : lstParametro) {
				if (parametro.ContestationQtt__c != null || parametro.TotalAmount__c != null) {
					if (lstCase.size() <= parametro.ContestationQtt__c || total <= parametro.TotalAmount__c) {
						contestationQttBool = true;
						availableParameters.add(parametro);

						System.debug('@@@Entrou no if do For - 01 -> ' + parametro);
						System.debug('@@lstCase.size -> ' + lstCase.size());
						System.debug('@@@Entrou no if Qtt -> ' + parametro.ContestationQtt__c);
						System.debug('@@total -> ' + total);
						System.debug('@@@Entrou no if Valor -> ' + parametro.TotalAmount__c);
					}
				} else {
					if (parametro.PercentageApprovedContestation__c != null) {
						if (
							parametro.PercentageApprovedContestation__c <= porcentagemAprovacao &&
							parametro.MinContestationQtt__c <= lstCaseN2Aprovado.size() &&
							parametro.Amount__c >= amount
						) {
							availableParameters.add(parametro);
							System.debug('@@Entrou na % -> ' + parametro);
							continue;
						} else {
							continue;
						}
					}
					System.debug('@@@Entrou no else -> ' + parametro);

					if ((isDigitalProfile && parametro.Channel__c != 'Digital') || (!isDigitalProfile && parametro.Channel__c == 'Digital'))
						continue;

					Boolean amountBool = parametro.Amount__c >= amount;

					Boolean contractBool = true;
					if (parametro.ContractStatus__c != null) {
						if (contrato.StatusLegado__c != null) {
							contractBool = false;

							List<String> contractStatusList = parametro.ContractStatus__c.split(';');
							String lowerStatus = contrato.StatusLegado__c.toLowerCase();

							for (String contractStatus : contractStatusList)
								if (contractStatus.toLowerCase() == lowerStatus)
									contractBool = true;
						} else {
							contractBool = false;
						}
					}

					Boolean segmentoBool = true;
					if (parametro.Segment__c != null) {
						if (contrato.vlocity_cmt__CustomerValue__c != null) {
							segmentoBool = false;

							List<String> parmsSegList = parametro.Segment__c.split(';');
							String segAccount = contrato.vlocity_cmt__CustomerValue__c.toLowerCase();

							for (String paramSeg : parmsSegList)
								if (paramSeg.toLowerCase() == segAccount)
									segmentoBool = true;
						} else {
							segmentoBool = false;
						}
					}

					Boolean describeItemBool = true;
					Boolean itemQttBool = true;

					if (parametro.ItemQtt__c != null && parametro.ItemType__c != null) {
						itemQttBool = parametro.ItemQtt__c >= itemQuantity;
						describeItemBool = parametro.ItemType__c == itemType;
					}

					if (amountBool && contractBool && segmentoBool && describeItemBool && itemQttBool) {
						availableParameters.add(parametro);
					}
				}
			}

			System.debug('parametrosVerificado -> ' + availableParameters.size());

			parametrosVerificado = !availableParameters.isEmpty();

			if (parametrosVerificado) {
				System.debug('IF DO PARAMETRO VERIFICADO -> ' + availableParameters.size());
				Set<Parameters__c> validatedParams = new Set<Parameters__c>();
				Set<Case> idDaAlcada = new Set<Case>();

				for (Parameters__c param : availableParameters) {
					if (isDigitalProfile) {
						if (usrProfileName == param.Profile__c) {
							validatedParams.add(param);
						} else {
							continue;
						}
					}

					User usr = lstUser[0];

					System.debug('@@@lstUser: ' + usr);
					if (param.Profile__c == null) {
						validatedParams.add(param);
						continue;
					}

					System.debug('@@@ Param.Profile ' + param.Profile__c);
					System.debug('@@@ permission sets' + String.join(new List<String>(permissionSets.keySet()), ','));

					if (contestationQttBool == true && permissionSets.containsKey(param.Profile__c) && (param.ContestationQtt__c != null || param.TotalAmount__c != null)) {
						validatedParams.clear();
						validatedParams.add(param);
						break;
					}

					if (permissionSets.containsKey(param.Profile__c))
						validatedParams.add(param);
					System.debug('@@@ Role ' + usr.UserRole.DeveloperName);
				}
				salesforceHasAuth = !validatedParams.isEmpty();

				if (salesforceHasAuth) {
					Parameters__c autorithyParam = validatedParams.iterator().next();
					InvoiceDetailsController.authorityParam = autorithyParam.Id;
				}
				System.debug('Alçada ->' + validatedParams);
			}

			return salesforceHasAuth;
		}
		return false;
	}

	private static String getItemType(List<CEC_DisputeInvoice.InvoiceItem> items) {
		Set<String> itemsSet = new Set<String>();

		for (CEC_DisputeInvoice.InvoiceItem item : items)
			itemsSet.add(item.itemDescription);

		String itemTypes = String.join(new List<String>(itemsSet), ' ');
		return itemTypes;
	}

	private static HierarchyLimitWrapper processAuthority(String jsonString) {
		JSONHierarchyLimit response = (JSONHierarchyLimit) JSON.deserialize(jsonString, JSONHierarchyLimit.class);
		HierarchyLimitWrapper hierarchyLimitWrp = new HierarchyLimitWrapper();

		if (response.data.returnCode != null)
			hierarchyLimitWrp.codigoRetorno = response.data.returnCode;

		if (response.data.returnMessage != null)
			hierarchyLimitWrp.mensagemRetorno = response.data.returnMessage;

		if (response.data.authorized != null)
			hierarchyLimitWrp.autorizado = response.data.authorized;

		if (response.data.hashAuthority != null)
			hierarchyLimitWrp.hashAutoridade = response.data.hashAuthority;
		System.debug('Alçada?: ' + JSON.serializePretty(hierarchyLimitWrp));
		return hierarchyLimitWrp;
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
}