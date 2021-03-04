/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Classe do tipo controller que obtém os detalhes da fatura
 */
public without sharing class InvoiceDetailsController {
	private static final Map<String, String> REASON_MAPS = new Map<String, String>{ '1' => 'tv', '3' => 'internet', '5' => 'outros', '6' => 'telefone' };
	public static string authorityParam = '';
	/*
	 * @description: Método para enviar a segunda via
	 */
	@AuraEnabled
	public static Object postDuplicate(
		string operatorCode,
		string contractNumber,
		string userName,
		string billId,
		string name,
		string phoneNumber,
		string email,
		string sendMethod,
		string billExtend,
		string descriptionReason,
		string caseId
	) {
		system.debug(
			'@@@postDuplicate-Envio invoicesControler: ' +
			' ' +
			operatorCode +
			' ' +
			contractNumber +
			' ' +
			userName +
			' ' +
			billId +
			' ' +
			name +
			' ' +
			phoneNumber +
			' ' +
			email +
			' ' +
			sendMethod +
			' ' +
			billExtend +
			' ' +
			descriptionReason +
			' ' +
			caseId
		);
		return InvoicesSendDuplicate.postDuplicateInvoice(operatorCode, contractNumber, userName, billId, name, phoneNumber, email, sendMethod, billExtend, descriptionReason, caseId);
	}

	/*
	 * @description: Método para retornar para o componente os detalhes da fatura
	 */
	@AuraEnabled
	public static Map<String, Object> getInvoiceDetails(String contractNumber, String invoiceId, String operatorCode, String infoDetailLevel, String recordId, String contestId) {
		Map<String, Object> data = new Map<String, Object>();

		try {
			//parâmetros para a URL
			Map<String, String> params = setParams(contractNumber, operatorCode, invoiceId, infoDetailLevel);
			//header
			Map<String, String> headers = setHeaders();
			//instância e realização do callout
			Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, 'InvoiceDetails');
			//success

			if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
				data.put('success', true);
				InvoiceDetailsWrapper wrp = processInvoiceDetails(calloutResponse.get('response'), contractNumber);
				wrp.canDispute = GeneralInvoicesController.canDispute(recordId, contestId);
				data.put('invoiceDetails', wrp);
				// data.put('invoiceGrouped', processGroupedInvoiceDetails(calloutResponse.get('response')));
			} else {
				data.put('success', false);
				data.put('message', setErrorMessage(calloutResponse.get('response')));
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}

		return data;
	}

	/*
	 * @description: Método para retornar para o componente os detalhes da fatura
	 */
	@AuraEnabled
	public static void denyCase(String caseId, String caseComment) {
		if (caseId == null)
			throw new InvoiceDetailsControllerException('Caso não enviado');

		update new Case(Id = caseId, Status = 'Closed', LeavingReason__c = 'Contestação Negada', EntryReason__c = 'Validação de Contestação de Valores', Description = caseComment);
		List<vlocity_cmt__PaymentAdjustment__c> items = [SELECT Id FROM vlocity_cmt__PaymentAdjustment__c WHERE vlocity_cmt__DisputeId__c = :caseId];
		for (vlocity_cmt__PaymentAdjustment__c item : items)
			item.vlocity_cmt__Status__c = 'Denied';

		update items;
	}

	/*
	 * @description: Método para criar uma contestacao
	 */
	@AuraEnabled
	public static Map<String, Object> disputeInvoice(String invoiceStg, String returnMethod, String recalculationReturn, String contestationObservation, String caseId, Boolean isN2Update) {
		Map<String, Object> retMap = new Map<String, Object>();
		Set<String> groupsSelected = new Set<String>();

		ContestationAuraWrapper invoiceObj = (ContestationAuraWrapper) JSON.deserialize(invoiceStg, ContestationAuraWrapper.class);
		CEC_DisputeInvoice.DisputeInvoiceRequest req = createRequest(invoiceObj, null, contestationObservation, returnMethod);
		req.caseId = caseId;

		for (ContestationItem item : invoiceObj.items)
			groupsSelected.add(item.idParceiro);

		Decimal totalValue = 0;

		for (CEC_DisputeInvoice.InvoiceItem invItem : req.invoiceItems) {
			Decimal diffVal = invItem.originalValue - invItem.wishedValue;
			totalValue = totalValue + diffVal;
		}

		Boolean hasAuthority = FinancialHierarchy.hasSalesforceAuthority(req, totalValue);
		Map<String, String> hashMap = new Map<String, String>();

		if (hasAuthority) {
			for (DepartureGroup depItem : invoiceObj.bill.amountAgainstDeparture) {
				if (depItem.groupId == '16' || !groupsSelected.contains(depItem.groupId)) {
					hashMap.put(depItem.groupId, null);
					continue;
				}

				String hash = getHashAuthority(req, invoiceObj, depItem);

				if (hash == null || hash == '')
					hasAuthority = false;

				hashMap.put(depItem.groupId, hash);
			}
		}

		for (CEC_DisputeInvoice.InvoiceItem constItem : req.invoiceItems)
			constItem.approvationHash = hashMap.get(constItem.partnerId);

		Boolean createCase = caseId == null;
		Boolean createItens = createCase;
		req.caseId = caseId;

		CEC_DisputeInvoice.DisputeInvoiceResponse resp = FinancialService.createDispute(req, 'ALTERAR PROXIMA SPRINT', createCase, hasAuthority, createItens);
		if (Integer.valueOf(resp.code) >= 400 && Integer.valueOf(resp.code) < 500)
			throw new InvoiceDetailsControllerException(resp.errorMessage);

		System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
		System.debug('caseId -> ' + caseId);
		System.debug('isN2Update -> ' + isN2Update);
		System.debug('returnMethod -> ' + returnMethod);
		System.debug('recalculationReturn -> ' + recalculationReturn);
		System.debug('invoiceObj serializePretty -> ' + JSON.serializePretty(invoiceObj));
		System.debug('req serializePretty -> ' + JSON.serializePretty(req));
		System.debug('createCase -> ' + createCase);
		System.debug('createItens -> ' + createItens);
		System.debug('hasAuthority -> ' + hasAuthority);
		System.debug('resp serializePretty -> ' + JSON.serializePretty(resp));
		System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

		//if(createCase)
		//	update new Case(Id = resp.caseData.caseId, ContactPreference__c = recalculationReturn, ReturnStrategy__c = returnMethod);

		retMap.put('caseId', createCase ? resp.caseData.caseId : caseId);
		retMap.put('needApproval', !hasAuthority);
		retMap.put('newBillId', resp.newBillId);
		retMap.put('code', resp.code);
		if (Integer.valueOf(resp.code) >= 400) {
			retMap.put('errorMessage', resp.errorMessage);
		}
		System.debug('authorityParam -> ' + authorityParam);

		if (!createCase) {
			if (isN2Update) {
				processCaseContestation(req, caseId);
			} else {
				Account acc = InvoicesUtils.getAccountFromCaseId(caseId);
				FinancialCaseManagement.createPaymentItems(hasAuthority, req, caseId, acc.Id, 'Itens_Contestados');
				FinancialCaseManagement.updateCaseContestation(req, caseId, acc.Id, recalculationReturn, hasAuthority);
			}
		}

		return retMap;
	}

	/*
	 * @description: Método para retornar as opcoes de contestacao
	 */
	@AuraEnabled
	public static List<ReasonOption> getContestationOptions() {
		List<ReasonOption> options = new List<ReasonOption>();
		for (Motivos_de_Contestacao__mdt mtConst : [SELECT ID_MOTIVO_CONTESTACAO__c, Motivo_Salesforce__c, PartnerId__c FROM Motivos_de_Contestacao__mdt]) {
			options.add(new ReasonOption(mtConst.Motivo_Salesforce__c, String.valueOf(mtConst.ID_MOTIVO_CONTESTACAO__c), mtConst.PartnerId__c));
		}
		return options;
	}

	/*
	 * @description: Método para chamar a elegibilidade
	 */
	@AuraEnabled
	public static Map<String, Object> getContestation(String contract, String operatorCode, String billId, String userName) {
		return FinancialService.getElegibility(contract, operatorCode, billId, userName);
	}

	/*
	 * @description: Método para atualizar o caso com a forma de retorno desejada
	 */
	@AuraEnabled
	public static void setReturnMethod(String caseId, String returnMethod) {
		List<Case> cases = [SELECT Id FROM Case WHERE Id = :caseId];
		if (cases.isEmpty())
			throw new InvoiceDetailsControllerException('Caso não encontrado');

		update new Case(Id = cases[0].Id, PreferencialContact__c = returnMethod);
	}

	private static CEC_DisputeInvoice.DisputeInvoiceRequest createRequest(ContestationAuraWrapper invoiceObj, String authHash, String contestationObservation, String returnMethod) {
		CEC_DisputeInvoice.DisputeInvoiceRequest req = new CEC_DisputeInvoice.DisputeInvoiceRequest();
		req.channel = 'E';
		req.contractNumber = invoiceObj.bill.contractId;
		req.idInvoice = invoiceObj.bill.idFatura;
		req.operatorCode = invoiceObj.bill.operatorId;
		req.source = 1;
		req.type = returnMethod == 'recalculation' ? 'R' : 'F';
		req.descricaoSolicitacao = contestationObservation;

		List<CEC_DisputeInvoice.InvoiceItem> items = new List<CEC_DisputeInvoice.InvoiceItem>();

		for (ContestationItem constItem : invoiceObj.items) {
			CEC_DisputeInvoice.InvoiceItem invItem = new CEC_DisputeInvoice.InvoiceItem();
			invItem.wishedValue = constItem.realValue - constItem.valorContestar;
			invItem.notes = contestationObservation;
			invItem.reason = constItem.contestationReason;
			invItem.originalValue = constItem.realValue;
			invItem.approvationHash = authHash;
			invItem.idInvoiceItem = constItem.idItem;
			invItem.itemDescription = constItem.descricao;
			invItem.idDetExtractItem = constItem.idDetExtractItem;
			invItem.idPartnerStatement = String.valueOf(constItem.idPartnerStatement);
			invItem.partnerId = constItem.idParceiro;
			items.add(invItem);
		}
		req.invoiceItems = items;

		return req;
	}

	private static void processCaseContestation(CEC_DisputeInvoice.DisputeInvoiceRequest req, String caseId) {
		List<vlocity_cmt__PaymentAdjustment__c> payAdjust = [
			SELECT Id, vlocity_cmt__Status__c, vlocity_cmt__Notes__c, vlocity_cmt__Amount__c, idExtractItem__c, ContestedAmount__c, Reason__c
			FROM vlocity_cmt__PaymentAdjustment__c
			WHERE vlocity_cmt__DisputeId__c = :caseId
		];

		List<Account> contractList = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = :req.contractNumber AND ContractReferenceNumber__c != NULL];

		Id recordTypeId = Schema.getGlobalDescribe().get('vlocity_cmt__PaymentAdjustment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Itens_Contestados').getRecordTypeId();

		Map<String, vlocity_cmt__PaymentAdjustment__c> adjustMap = new Map<String, vlocity_cmt__PaymentAdjustment__c>();
		for (vlocity_cmt__PaymentAdjustment__c item : payAdjust)
			adjustMap.put(item.idExtractItem__c, item);

		Boolean parcialApproved = false;

		List<vlocity_cmt__PaymentAdjustment__c> payAdjusts = new List<vlocity_cmt__PaymentAdjustment__c>();
		for (CEC_DisputeInvoice.InvoiceItem item : req.invoiceItems) {
			vlocity_cmt__PaymentAdjustment__c adjustItem = adjustMap.get(item.idInvoiceItem);

			if (adjustItem == null) {
				adjustItem = new vlocity_cmt__PaymentAdjustment__c();
				adjustItem.idExtractItem__c = item.idInvoiceItem;
				adjustItem.recordTypeId = recordTypeId;
				adjustItem.vlocity_cmt__AccountId__c = contractList[0].Id;
				adjustItem.vlocity_cmt__Amount__c = item.originalValue;
				adjustItem.vlocity_cmt__Date__c = Date.today();
				adjustItem.vlocity_cmt__DisputeId__c = caseId;
			}

			adjustItem.vlocity_cmt__Status__c = 'Approved';
			adjustItem.Reason__c = item.reason;
			adjustItem.vlocity_cmt__Notes__c = item.notes;
			adjustItem.ContestedAmount__c = item.wishedValue;
			payAdjusts.add(adjustItem);
		}

		for (vlocity_cmt__PaymentAdjustment__c payItem : adjustMap.values())
			if (payItem.vlocity_cmt__Status__c == 'Pending') {
				payItem.vlocity_cmt__Status__c = 'Denied';
				parcialApproved = true;
				payAdjusts.add(payItem);
			}

		upsert payAdjusts;
		/*
			Melhoria - Alterar motivo de saída:
			De: Contestação Parcialmente Aprovada
			Para: Contestacao aprovada com ajustes 
			Roger Rosset - 23-09-2020
		*/

		Case cs = new Case(Id = caseId);
		cs.LeavingReason__c = parcialApproved ? 'Contestação Aprovada com ajustes' : 'Contestação aprovada';
		cs.EntryReason__c = 'Validação de Contestação de Valores';
		cs.Description = req.descricaoSolicitacao;
		cs.Status = 'Closed';

		update cs;
	}

	private static InvoiceDetailsWrapper processInvoiceDetails(String jsonString, String contractNumber) {
		System.debug('Valor do JSON -> ' + jsonString);
		JSONInvoiceDetails response = (JSONInvoiceDetails) JSON.deserialize(jsonString, JSONInvoiceDetails.class);

		List<Account> accList = [
			SELECT Id, Parent.EnderecoFormula__c, Parent.vlocity_cmt__BillingEmailAddress__c
			FROM Account
			WHERE RecordType.DeveloperName = 'Billing' AND ContractReferenceNumber__c = :contractNumber AND ParentId != NULL
		];

		Account acc;
		if (!accList.isEmpty())
			acc = accList[0];

		InvoiceDetailsWrapper invoiceDetailsWrp = new InvoiceDetailsWrapper();
		invoiceDetailsWrp.tipoFatura = 'Fatura';
		invoiceDetailsWrp.formaPagamento = response.data.paymentMethod != null ? response.data.paymentMethod.toLowerCase().capitalize() : '';
		invoiceDetailsWrp.modoRecebimento = acc != null && acc.parent.vlocity_cmt__BillingEmailAddress__c != null ? acc.parent.vlocity_cmt__BillingEmailAddress__c : '';
		invoiceDetailsWrp.tipoFatura = 'Fatura';
		invoiceDetailsWrp.idFatura = String.valueOf(response.data.invoiceId);
		invoiceDetailsWrp.produto = 'TV + Virtua + Telefone'; //Claro está levantando quais nome de itens da fatura eles irão mostrar para nós processarmos
		invoiceDetailsWrp.status = response.data.status;
		invoiceDetailsWrp.valor = (response.data.amount != null) ? 'R$' + response.data.amount : 'R$0,00';
		System.debug('valor detalhe pretty -> ' + jsonString);
		if (response.data.dueDate != null)
			invoiceDetailsWrp.dataVencimento = InvoicesUtils.setFormattedDate(response.data.dueDate);
		if (response.data.paymentDate != null)
			invoiceDetailsWrp.dataPagamento = InvoicesUtils.setFormattedDate(response.data.paymentDate);
		if (response.data.executeDate != null)
			invoiceDetailsWrp.dataBaixa = InvoicesUtils.setFormattedDate(response.data.executeDate);
		List<InvoiceDetailsWrapper.InvoiceProducts> products = new List<InvoiceDetailsWrapper.InvoiceProducts>();
		if (response.data.partnerDebts == null)
			return invoiceDetailsWrp;

		Map<Integer, Integer> mapGrpoupIdtoParent = new Map<Integer, Integer>();
		for (JSONInvoiceDetails.ItemGroup itemGroup : response.data.itemGroups) {
			if (!mapGrpoupIdtoParent.containsKey(itemGroup.groupId))
				mapGrpoupIdtoParent.put(itemGroup.groupId, itemGroup.groupIdParent);
		}
		System.debug('mapGrpoupIdtoParent : ' + mapGrpoupIdtoParent);

		for (JSONInvoiceDetails.PartnerDebt partnerItem : response.data.partnerDebts) {
			// System.debug('partnerItem'+partnerItem);
			switch on partnerItem.partnerId {
				when 1 {
					products = fillProductNet(products, partnerItem, mapGrpoupIdtoParent);
				}
				when 2 {
					products = fillProductEmbratel(products, partnerItem, mapGrpoupIdtoParent);
				}
				when 16 {
					products = fillProductClaro(products, partnerItem, mapGrpoupIdtoParent);
				}
				when else {
					System.debug('Partner Id: ' + partnerItem.partnerId + ':' + partnerItem.partnerName + 'nao cadastrado no sistema');
				}
			}
		}
		System.debug('products.size: ' + products.size() + ': ' + products);
		invoiceDetailsWrp.detalheProdutos = products;
		return invoiceDetailsWrp;
	}

	private static List<InvoiceDetailsWrapper.InvoiceProducts> fillProductNet(
		List<InvoiceDetailsWrapper.InvoiceProducts> products,
		JSONInvoiceDetails.PartnerDebt partnerItem,
		Map<Integer, Integer> mapGrpoupIdtoParent
	) {
		if (partnerItem.debtGroup != null) {
			for (JSONInvoiceDetails.DebtGroup debtItem : partnerItem.debtGroup) {
				if (debtItem.extractItems == null)
					continue;
				for (JSONInvoiceDetails.ExtractItem item : debtItem.extractItems) {
					//if (item.itemGrouper != null)
					//	continue;

					InvoiceDetailsWrapper.InvoiceProducts itm = new InvoiceDetailsWrapper.InvoiceProducts();
					itm.dataLancamento = item.entryDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.entryDate) : item.entryDate;
					itm.descricao = item.itemDescription;
					itm.valor = (item.sourceValue != null) ? 'R$' + item.sourceValue : 'R$0,00';
					itm.idItem = String.valueOf(item.idExtractItem);
					itm.dataVencimento = item.entryDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.dueDate) : item.dueDate;
					itm.descricaoProduto = item.productDescription;
					itm.totalParcela = String.valueOf(item.totalInstallments);
					itm.numeroParcela = String.valueOf(item.installmentNumber);
					itm.parceiro = partnerItem.partnerName;
					itm.idParceiro = String.valueOf(partnerItem.partnerId);
					itm.dataProporcionalidade = item.proRataStartDate;
					itm.groupIdParent = mapGrpoupIdtoParent.get(debtItem.groupId);
					itm.sortentryDate = item.entryDate.indexOf('-') > 0 ? item.entryDate.Split('T')[0] : '';
					// itm.groupString = REASON_MAPS.get(String.valueOf(debtItem.groupId));
					products.add(itm);
				}
			}
		}
		return products;
	}

	private static List<InvoiceDetailsWrapper.InvoiceProducts> fillProductEmbratel(
		List<InvoiceDetailsWrapper.InvoiceProducts> products,
		JSONInvoiceDetails.PartnerDebt partnerItem,
		Map<Integer, Integer> mapGrpoupIdtoParent
	) {
		if (partnerItem.serviceGroup != null) {
			for (JSONInvoiceDetails.ServiceGroup serviceItem : partnerItem.serviceGroup) {
				if (serviceItem.partnerPhones != null) {
					for (JSONInvoiceDetails.PartnerPhone phones : serviceItem.partnerPhones) {
						if (phones.partnerExtracts != null) {
							for (JSONInvoiceDetails.PartnerExtract2 item : phones.partnerExtracts) {
								System.debug('100089 :: fillProductEmbratel: item ==>' + item.details);
								// InvoiceDetailsWrapper.InvoiceProducts itm = new InvoiceDetailsWrapper.InvoiceProducts();
								// itm.idItem = String.valueOf(item.idExtractItem);
								// itm.totalParcela = String.valueOf(item.totalInstallments);
								// itm.numeroParcela = String.valueOf(item.installmentNumber);
								// itm.dataVencimento = item.dueDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.dueDate) : item.dueDate;
								// itm.dataLancamento = item.entryDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.entryDate) : item.entryDate;
								// itm.descricao = item.itemDescription;
								// itm.valor = (item.amount != null) ? 'R$' + item.amount : 'R$0,00';
								// itm.descricaoProduto = String.valueOf(item.idExtractItemType);
								// itm.idParceiro = String.valueOf(partnerItem.partnerId);
								// itm.parceiro = partnerItem.partnerName;
								// itm.groupIdParent = mapGrpoupIdtoParent.get(serviceItem.groupId);
								// itm.sortentryDate = item.entryDate.indexOf('-') > 0 ? item.entryDate.Split('T')[0] : '';

								// @note : 100089 - Visualizar na fatura detalhes do produto Embratel
								System.debug('100089 :: fillProductEmbratel: item!=null ==>' + item.details != null);
								System.debug('100089 :: fillProductEmbratel: item.details.size ==>' + item.details.size());

								if (item.details != null && item.details.size() > 0) {
									// itm.itensDetalhe = new List<InvoiceDetailsWrapper.InvoiceProductsDetails>();
									for (JSONInvoiceDetails.Detail2 details : item.details) {
										System.debug('100089 :: fillProductEmbratel: item ==>' + details);
										InvoiceDetailsWrapper.InvoiceProducts itemDetails = new InvoiceDetailsWrapper.InvoiceProducts();
										itemDetails.idItem = String.valueOf(details.idDetExtractItem);
										itemDetails.duracao = Double.valueOf(details.callDuration);
										itemDetails.horarioInicio = details.startTime;
										itemDetails.periodo = details.startDate != null ? InvoicesUtils.setFormattedDate(details.startDate.split('T')[0]) : details.startDate;
										itemDetails.telefoneDestino = details.targetTerminal;
										itemDetails.localDestino = details.destination;
										itemDetails.pais = details.destinationCountry;
										itemDetails.valor = (details.callDetailValue != null) ? 'R$' + details.callDetailValue : 'R$0,00';

										// dados de controle da pagina
										itemDetails.groupIdParent = mapGrpoupIdtoParent.get(serviceItem.groupId);
										itemDetails.descricao = item.itemDescription;
										itemDetails.idParceiro = String.valueOf(partnerItem.partnerId);
										itemDetails.parceiro = partnerItem.partnerName;
										itemDetails.sortentryDate = details.startDate != null ? details.startDate.split('T')[0] : details.startDate;

										products.add(itemDetails);
									}
								}
								// products.add(itemDetails);
								// System.debug('fillProductEmbratel: ' + itm);
							}
						}
					}
				}
			}
		}
		return products;
	}

	private static List<InvoiceDetailsWrapper.InvoiceProducts> fillProductClaro(
		List<InvoiceDetailsWrapper.InvoiceProducts> products,
		JSONInvoiceDetails.PartnerDebt partnerItem,
		Map<Integer, Integer> mapGrpoupIdtoParent
	) {
		if (partnerItem.serviceGroup != null) {
			for (JSONInvoiceDetails.ServiceGroup serviceItem : partnerItem.serviceGroup) {
				if (serviceItem.partnerExtracts != null) {
					for (JSONInvoiceDetails.PartnerExtract item : serviceItem.partnerExtracts) {
						System.debug('100089 :: fillProductClaro: item ==>' + item.details);
						// InvoiceDetailsWrapper.InvoiceProducts itm = new InvoiceDetailsWrapper.InvoiceProducts();
						// itm.idItem = String.valueOf(item.idExtractItem);
						// itm.totalParcela = String.valueOf(item.totalInstallments);
						// itm.numeroParcela = String.valueOf(item.installmentNumber);
						// itm.dataVencimento = item.dueDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.dueDate) : item.dueDate;
						// itm.dataLancamento = item.entryDate.indexOf('-') > 0 ? InvoicesUtils.setFormattedDate(item.entryDate) : item.entryDate;
						// itm.descricao = item.itemDescription;
						// itm.valor = (item.amount != null) ? 'R$' + item.amount : 'R$0,00';
						// itm.descricaoProduto = String.valueOf(item.idExtractItemType);
						// itm.idParceiro = String.valueOf(partnerItem.partnerId);
						// itm.parceiro = partnerItem.partnerName;
						// itm.groupIdParent = mapGrpoupIdtoParent.get(serviceItem.groupId);
						// itm.sortentryDate = item.entryDate.indexOf('-') > 0 ? item.entryDate.Split('T')[0] : '';

						// @note : 100089 - Visualizar na fatura detalhes do produto Embratel
						if (item.details != null && item.details.size() > 0) {
							// itm.itensDetalhe = new List<InvoiceDetailsWrapper.InvoiceProductsDetails>();
							for (JSONInvoiceDetails.Detail details : item.details) {
								System.debug('100089 :: fillProductEmbratel: item ==>' + details);
								InvoiceDetailsWrapper.InvoiceProducts itemDetails = new InvoiceDetailsWrapper.InvoiceProducts();
								itemDetails.idItem = String.valueOf(details.idDetExtractItem);
								itemDetails.duracao = Double.valueOf(details.callDuration);
								itemDetails.horarioInicio = details.startTime;
								itemDetails.periodo = details.startDate != null ? InvoicesUtils.setFormattedDate(details.startDate.split('T')[0]) : details.startDate;
								itemDetails.telefoneDestino = details.targetTerminal;
								itemDetails.localDestino = details.destination;
								itemDetails.pais = details.destinationCountry;
								itemDetails.valor = (details.callDetailValue != null) ? 'R$' + details.callDetailValue : 'R$0,00';

								// dados de controle da pagina
								itemDetails.groupIdParent = mapGrpoupIdtoParent.get(serviceItem.groupId);
								itemDetails.descricao = item.itemDescription;
								itemDetails.idParceiro = String.valueOf(partnerItem.partnerId);
								itemDetails.parceiro = partnerItem.partnerName;
								itemDetails.sortentryDate = details.startDate != null ? details.startDate.split('T')[0] : details.startDate;

								products.add(itemDetails);
							}
						}
						// products.add(itm);
						System.debug('fillProductClaro: ' + products);
					}
				}
			}
		}
		return products;
	}

	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (InvoiceDetalis)
	 */
	@TestVisible
	private static Map<String, String> setParams(String contractNumber, String operatorCode, String invoiceId, String infoDetailLevel) {
		Map<String, String> params = new Map<String, String>();
		if (String.isEmpty(contractNumber) || String.isEmpty(operatorCode) || String.isEmpty(invoiceId) || String.isEmpty(infoDetailLevel)) {
			String emptyFields = (String.isEmpty(contractNumber)) ? 'contractNumber' : '';
			emptyFields += (String.isEmpty(operatorCode)) ? ', operatorCode' : '';
			emptyFields += (String.isEmpty(invoiceId)) ? ', invoiceId' : '';
			emptyFields += (String.isEmpty(infoDetailLevel)) ? ', infoDetailLevel' : '';
			throw new InvoiceDetailsControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
		} else {
			params.put('contractNumber', contractNumber);
			params.put('operatorCode', operatorCode);
			params.put('invoiceId', invoiceId);
			params.put('infoDetailLevel', infoDetailLevel);
		}
		return params;
	}

	/*
	 * @description: Método para gerar o hash
	 */
	@TestVisible
	private static String getHashAuthority(CEC_DisputeInvoice.DisputeInvoiceRequest req, ContestationAuraWrapper invoiceObj, DepartureGroup dpGroup) {
		Decimal totalDisputeValue = 0;

		for (ContestationItem constItem : invoiceObj.items)
			if (constItem.idParceiro == dpGroup.groupId)
				totalDisputeValue = totalDisputeValue + constItem.valorContestar;
		/*
		for(CEC_DisputeInvoice.InvoiceItem itm : req.invoiceItems)
			if(itm.partnerId == dpGroup.groupId)
				itm.groupDeparture = dpGroup.value;
		*/
		totalDisputeValue = totalDisputeValue + dpGroup.value;

		String authHash = null;

		Map<String, Object> authorityMap = FinancialService.getAuthority(
			req,
			invoiceObj.bill.operatorId,
			invoiceObj.bill.contractId,
			'ALTERAR PROXIMA SPRINT',
			totalDisputeValue,
			Integer.valueOf(dpGroup.groupId),
			invoiceObj.bill.idFatura
		);

		if (Boolean.valueOf(authorityMap.get('success'))) {
			HierarchyLimitWrapper response = (HierarchyLimitWrapper) JSON.deserialize(JSON.serialize(authorityMap.get('authority')), HierarchyLimitWrapper.class);

			if (response.autorizado != null && response.autorizado)
				authHash = response.hashAutoridade;
		}

		return authHash;
	}

	/*
	 * @description: Método para gerar a URL com os parâmetros para chamada no OAG (Invoices)
	 */
	@TestVisible
	private static Map<String, String> setHeaders() {
		Map<String, String> params = new Map<String, String>();
		//params.put('', '');
		return params;
	}

	/*
	 * @description: Método para gerar a a mensagem de erro quando necessário
	 */
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

	public class ReasonOption {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String partnerId;

		public ReasonOption(String l, String v, String partner) {
			this.label = l;
			this.value = v;
			this.partnerId = partner;
		}
	}

	public class ContestationAuraWrapper {
		@AuraEnabled
		public List<ContestationItem> items;
		@AuraEnabled
		public Bill bill;
	}

	public class ContestationItem {
		@AuraEnabled
		public String idItem;
		@AuraEnabled
		public String idParceiro;
		@AuraEnabled
		public Long idPartnerStatement;
		@AuraEnabled
		public String idDetExtractItem;
		@AuraEnabled
		public Decimal realValue;
		@AuraEnabled
		public Decimal valorContestar;
		@AuraEnabled
		public Decimal valorCorrigido;
		@AuraEnabled
		public String descricao;
		@AuraEnabled
		public String contestationReason;
	}

	public class Bill {
		@AuraEnabled
		public String idFatura;
		@AuraEnabled
		public String contractId;
		@AuraEnabled
		public String operatorId;
		@AuraEnabled
		public List<DepartureGroup> amountAgainstDeparture;
	}

	public class DepartureGroup {
		@AuraEnabled
		public String groupId;
		@AuraEnabled
		public Decimal value;
	}

	/*
    @AuraEnabled
    public static String getUrlPdfBillingAccRes(String contractNumber, String invoiceId) {
        String url;
        string ContractReferenceNumber = contractNumber;
        if(!Test.isRunningTest()){
            url = CEC_360_IntegrationInvoices.getInvoicesURLRes('RESIDENCIAL',invoiceId,ContractReferenceNumber);
        }else{
            url = 'teste';
        }
        system.debug('URL'+url);
        return url;
    }
	*/

	@AuraEnabled
	public static Object getPdf(String contract, String invoiceId) {
		// @note Bug 100632 : formatacao de variaveis para envio
		System.debug('@@@@ DIOGOTESTE >>>> ' + 'contract: ' + contract + ' invoiceId: ' + invoiceId);
		return CEC_360_AccBillingDetailsController.getUrlPdfBillingAccRes(contract, invoiceId);
		//return null;
	}

	public class InvoiceDetailsControllerException extends Exception {
	}
}