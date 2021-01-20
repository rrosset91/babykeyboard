/**
 * @description       : US101348
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 20-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
 **/
public with sharing class FinancialNegotiationInstallment {
	/**
	 * @description Retorna as possiveis variacoes de parcelamento
	 * @author Diego Almeida | 13-01-2021
	 * @param caseId Id do caso CRM
	 * @param bills Lista de bills selecionadas
	 * @param statements Lista de statements selecionadas
	 * @return Map<String, Object>
	 **/
	@AuraEnabled
	public static Map<String, Object> getInstallmentPlan(String caseId, List<String> bills, List<String> statements, String valorNegociacao) {
		Map<String, Object> response = new Map<String, Object>();

		Case casoAtual = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c, ContractBillingAccount__r.ContractReferenceNumber__c, ContractBillingAccount__r.CityCode__c FROM Case WHERE Id = :caseId LIMIT 1];
		System.debug('@@getInstallmentPlan:: Case => ' + casoAtual);

		Map<String, List<String>> selectedNegotiation = new Map<String, List<String>>();
		if (bills.size() > 0) {
			System.debug('@@getInstallmentPlan:: bills => ' + bills);

			selectedNegotiation.put('bills', new List<String>());
			for (String bill : bills) {
				selectedNegotiation.get('bills').add(bill);
			}
		}
		if (statements.size() > 0) {
			System.debug('@@getInstallmentPlan:: statements => ' + statements);

			selectedNegotiation.put('statements', new List<String>());
			for (String statement : statements) {
				selectedNegotiation.get('statements').add(statement);
			}
		}
		System.debug('@@getInstallmentPlan:: selectedNegotiation => ' + response);

		if (hasSalesforceAuthority(casoAtual, valorNegociacao)) {
			response.put('alcada', true);
			Map<String, Object> opcoesParcelamento = getInstallmentOptions(casoAtual, selectedNegotiation);
		} else {
			response.put('success', false);
			response.put('errorMessage', 'Nao encontrada alcada referente ao solicitado');
		}

		//MOCK
		response.put('success', true);
		response.put('dadosParcelamento', returnMock());
		//response.put('nameAuthority', parameterHierarchy);

		// System.debug('@@getInstallmentPlan:: response => '+ response);

		return response;
	}
	public static List<DadosParcelamento> returnMock() {
		List<DadosParcelamento> lstDadosParcelamento = new List<DadosParcelamento>();
		DadosParcelamento parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = 'A vista';
		parcelamento.descontoParcelamento = 'Desconto de 20%';
		parcelamento.quantidadeParcelamento = 0; //number
		parcelamento.valorDesconto = 20;
		parcelamento.porcentagemDesconto = 20;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = '1x';
		parcelamento.descontoParcelamento = 'Desconto de 15%';
		parcelamento.quantidadeParcelamento = 1; //number
		parcelamento.valorDesconto = 15;
		parcelamento.porcentagemDesconto = 15;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = '2x';
		parcelamento.descontoParcelamento = 'Desconto de 10%';
		parcelamento.quantidadeParcelamento = 2; //number
		parcelamento.valorDesconto = 10;
		parcelamento.porcentagemDesconto = 10;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = '3x';
		parcelamento.descontoParcelamento = 'sem desconto';
		parcelamento.quantidadeParcelamento = 3; //number
		parcelamento.valorDesconto = 0;
		parcelamento.porcentagemDesconto = 0;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = '4x';
		parcelamento.descontoParcelamento = 'sem desconto';
		parcelamento.quantidadeParcelamento = 4; //number
		parcelamento.valorDesconto = 0;
		parcelamento.porcentagemDesconto = 0;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = '5x';
		parcelamento.descontoParcelamento = 'sem desconto';
		parcelamento.quantidadeParcelamento = 5; //number
		parcelamento.valorDesconto = 0;
		parcelamento.porcentagemDesconto = 0;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		lstDadosParcelamento.add(parcelamento);

		return lstDadosParcelamento;
	}

	/**
	 * @description Valida alcada da US100174
	 * @author Diego Almeida | 19-01-2021
	 * @param casoAtual
	 * @param valorNegociacao
	 * @return Boolean
	 **/
	private static Boolean hasSalesforceAuthority(Case casoAtual, String valorNegociacao) {
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		List<Parameters__c> parametrosAlcada = new List<Parameters__c>();
		List<Parameters__c> parametrosAprovados = new List<Parameters__c>();

		parametrosAlcada = [SELECT id, name, active__c, Process__c, Channel__c, Profile__c, Amount__c, Business_Division__c FROM Parameters__c WHERE Active__c = TRUE AND RecordTypeId = :recordTypeIdParameter AND Process__c = 'Negociação'];
		System.debug('@@hasSalesforceAuthority:: parametrosAlcada => ' + parametrosAlcada);

		if (parametrosAlcada.size() == 0)
			return false;

		List<User> lstUser = new List<User>();
		List<PermissionSetAssignment> lstPermissionSet = new List<PermissionSetAssignment>();

		lstUser = [SELECT Id, Name, UserRoleId, UserRole.DeveloperName FROM User WHERE UserRoleId != NULL AND Id = :UserInfo.getUserId()];
		lstPermissionSet = [SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()];

		System.debug('@@hasSalesforceAuthority:: lstUser => ' + lstUser);
		System.debug('@@hasSalesforceAuthority:: lstPermissionSet => ' + lstPermissionSet);

		Map<String, PermissionSetAssignment> permissionSets = new Map<String, PermissionSetAssignment>();
		for (PermissionSetAssignment assign : lstPermissionSet) {
			permissionSets.put(assign.PermissionSet.Name, assign);
		}
		System.debug('@@hasSalesforceAuthority:: permissionSets => ' + permissionSets);

		Id profileId = UserInfo.getProfileId();
		String usrProfileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
		Boolean isDigitalProfile = usrProfileName == 'SF_DAC_Digital';
		System.debug('@@hasSalesforceAuthority:: usrProfileName => ' + usrProfileName);

		for (Parameters__c parametro : parametrosAlcada) {
			if ((isDigitalProfile && parametro.Channel__c != 'Digital') || (!isDigitalProfile && parametro.Channel__c == 'Digital')) {
				System.debug('@@hasSalesforceAuthority:: isDigitalProfile => ' + isDigitalProfile);
				System.debug('@@hasSalesforceAuthority:: parametro.Channel__c => ' + parametro.Channel__c);
				continue;
			}

			Boolean profileBool = parametro.Profile__c != null ? permissionSets.get(parametro.Profile__c) != null : true;
			System.debug('@@hasSalesforceAuthority:: profileBool => ' + profileBool);

			Boolean amountBool = parametro.Amount__c != null ? parametro.Amount__c >= Decimal.valueOf(valorNegociacao) : true;
			System.debug('@@hasSalesforceAuthority:: amountBool => ' + amountBool);

			Boolean divisionBool = parametro.Business_Division__c != null ? getBusinessDivision(casoAtual.ContractBillingAccount__r.BusinessUnit__c) == parametro.Business_Division__c : true;
			System.debug('@@hasSalesforceAuthority:: divisionBool => ' + divisionBool);

			if (profileBool && amountBool && divisionBool) {
				parametrosAprovados.add(parametro);
			}
		}

		System.debug('@@hasSalesforceAuthority:: parametrosAprovados => ' + parametrosAprovados);
		return !parametrosAprovados.isEmpty();
	}

	/**
	 * @description Retorna a Businnes Division atrelada nas FinancialMobileGeneralService
	 * @author Diego Almeida | 19-01-2021
	 * @param contractCaseDivision
	 * @return String
	 **/
	private static String getBusinessDivision(String contractCaseDivision) {
		if (FinancialMobileGeneralService.RESIDENTIAL_UNIT.contains(contractCaseDivision.toUpperCase())) {
			System.debug('@@hasSalesforceAuthority:: getBusinessDivision => ' + 'Residencial');
			return 'Residencial';
		}

		if (FinancialMobileGeneralService.MOBILE_UNIT.contains(contractCaseDivision.toUpperCase())) {
			System.debug('@@hasSalesforceAuthority:: getBusinessDivision => ' + 'Movel');
			return 'Movel';
		}

		System.debug('@@hasSalesforceAuthority:: getBusinessDivision => ' + 'Combo Multi');
		return 'Combo Multi';
	}

	private static Map<String, Object> getInstallmentOptions(Case casoAtual, Map<String, List<String>> selectedNegotiation) {
		Map<String, Object> installmentOptions = new Map<String, Object>();

		//Passo 1 - Chamar a api e retonar os planos de parcelamento ddo legado
		JSONInvoicesNegotiationOptions retornoLegado = postNegotiationOptions(casoAtual.ContractBillingAccount__r.ContractReferenceNumber__c, casoAtual.ContractBillingAccount__r.CityCode__c, '0', '0', selectedNegotiation);

		//Passo 2 - Selecionar a matriz de oferta

		//Passo 3 - Tratamento caso nao haja matrix de oferta cadastrada para o perfil
		//Passo 4 - limitar o legado de acordo com o retorno da matrix de oferta
		//Passo 5 - montar o wrapper de envio
		return installmentOptions;
	}

	private static JSONInvoicesNegotiationOptions postNegotiationOptions(String contractNumber, String operatorCode, String discountValue, String firstInstallmentValue, Map<String, List<string>> selectedNegotiation) {
		System.debug('@@postNegotiationOptions:: contractNumber => ' + contractNumber);
		System.debug('@@postNegotiationOptions:: operatorCode => ' + operatorCode);
		System.debug('@@postNegotiationOptions:: discountValue => ' + discountValue);
		System.debug('@@postNegotiationOptions:: selectedNegotiation => ' + selectedNegotiation);

		JSONInvoicesNegotiationOptions response = new JSONInvoicesNegotiationOptions();
		String stringJSONDATA = setJsonBody(contractNumber, operatorCode, discountValue, '0', selectedNegotiation);

		Map<String, String> params = new Map<String, String>();
		Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'application/json');

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(stringJSONDATA, params, headers, 'InvoicesNegotiationOptions');
		calloutResponse.put('response', calloutResponse.get('response').replace('"number"', '"installmentNumber"'));
		JSONInvoicesNegotiationOptions resp = new JSONInvoicesNegotiationOptions('JSONInvoicesNegotiationOptions', calloutResponse);
		System.debug('@@postNegotiationOptions:: calloutResponse => ' + JSON.serializePretty(resp));

		// if (resp.isSuccessfull) {
		response = (JSONInvoicesNegotiationOptions) resp.getData();
		// } else {
		//throw new InstallmentException(resp.getErrorMessage());
		// }
		// //JSONInvoicesNegotiationOptions responseObject = (JSONInvoicesNegotiationOptions)JSON.deserialize(calloutResponse.get('response').replace('"number"', '"installmentNumber"'), JSONInvoicesNegotiationOptions.class);

		return response;
	}

	/**
	 * @description Parse data to JsonBody to post
	 * @author Diego Almeida | 19-01-2021
	 * @param jsonData
	 * @return String
	 **/
	private static String setJsonBody(String contractNumber, String operatorCode, String discountValue, String firstInstallmentValue, Map<String, List<string>> selectedNegotiation) {
		PostBody objBody = new PostBody();
		PostData objData = new PostData();
		objData.operatorCode = operatorCode;
		objData.contractNumber = Integer.valueOf(contractNumber);
		objData.userName = InvoicesUtils.getCalloutUser('InvoicesNegotiationOptions');
		objData.discountValue = Double.valueOf(discountValue);
		objData.firstInstallmentValue = Integer.valueOf(firstInstallmentValue);
		objData.exemptInterestTicket = false;
		objData.bills = selectedNegotiation.get('bills');
		objData.statements = selectedNegotiation.get('statements');
		objBody.data = objData;
		System.debug('@@setJsonBody:: stringJSONDATA => ' + JSON.serializePretty(objBody));

		return JSON.serializePretty(objBody);
	}

	private static Map<String, Object> getPropensaoPROCON(String cpf, String contractNumber, String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

		Map<String, String> params = new Map<String, String>();
		params.put('origen', origin);
		// System.debug('getPropensaoPROCON params: ' + params);

		Map<String, String> headers = new Map<String, String>();
		String authToken = getAuth('CustomerProconPropensity');
		headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf=' + cpf + '&contractNumber=' + contractNumber + '&operatorCode=' + operatorCode;
		headers.put('X-QueryString', queryString);

		// System.debug('getPropensaoPROCON headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerProconPropensity');
		JSONCustomerProconPropensity responseObject = (JSONCustomerProconPropensity) JSON.deserialize(calloutResponse.get('response'), JSONCustomerProconPropensity.class);

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			response.put('propensaoPROCON', true);
			if (origin == '2') {
				response.put('parameterPROCON', responseObject.data.codRangePropensity);
			}
		} else {
			response.put('propensaoPROCON', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;
	}

	private static Map<String, Object> getSegmentacaoDefault(String cpf, String contractNumber, String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

		Map<String, String> params = new Map<String, String>();
		params.put('origen', origin);
		// System.debug('getSegmentacaoDefault params: ' + params);

		Map<String, String> headers = new Map<String, String>();
		String authToken = getAuth('CustomerDefaultSegmetation');
		headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf=' + cpf + '&contractNumber=' + contractNumber + '&operatorCode=' + operatorCode;
		headers.put('X-QueryString', queryString);

		// System.debug('getSegmentacaoDefault headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerDefaultSegmetation');
		JSONCustomerDefaultSegmetation responseObject = (JSONCustomerDefaultSegmetation) JSON.deserialize(calloutResponse.get('response'), JSONCustomerDefaultSegmetation.class);

		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
			response.put('propensaoDefault', true);
			if (origin == '2') {
				response.put('parameterDefault', responseObject.data.descCluster);
			}
		} else {
			response.put('propensaoDefault', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;
	}

	private static String getAuth(String customSetting) {
		ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
		String token = setting.Token__c;
		return token;
	}

	/**
	 * @description Com base no parcelamento selecionado retorna os dados das parcelas
	 * @author Diego Almeida | 13-01-2021
	 * @param request item da lista dadosParcelamento retornado em getInstallmentPlan
	 * @return Map<String, Object>
	 **/
	@AuraEnabled
	public static Map<String, Object> getInstallmentValues(String request) {
		System.debug('@@getInstallmentValues:: request => ' + request);

		Map<String, Object> response = new Map<String, Object>();
		response.put('success', true);
		response.put('errorMessage', 'XPTO');
		response.put('dadosParcelamento', returnMockParcelas());
		//response.put('nameAuthority', parameterHierarchy);
		System.debug('@@getInstallmentValues:: response => ' + response);

		return response;
	}

	public static DadosParcelamento returnMockParcelas() {
		DadosParcelamento parcelamento = new DadosParcelamento();
		parcelamento.ofertaParcelamento = 'A vista';
		parcelamento.descontoParcelamento = 'Desconto de 20%';
		parcelamento.quantidadeParcelamento = 0; //number
		parcelamento.valorDesconto = 20;
		parcelamento.porcentagemDesconto = 20;
		parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas = new List<ParcelaItem>();
		ParcelaItem parcela = new ParcelaItem();
		parcela.numeroParcela = '0';
		parcela.valorJuros = 15.36;
		parcela.valorMulta = 6.02;
		parcela.valorParcela = 263.38;
		parcela.valorTotal = 263.38;
		parcela.vencimento = FinancialMobileUtils.formatResponseDate('2021-01-30T00:00:00', false);
		parcelamento.parcelas.add(parcela);
		return parcelamento;
	}

	//Wrapper do body envio
	public class PostBody {
		public PostData data;
	}
	public class PostData {
		public String operatorCode;
		public Integer contractNumber;
		public String userName;
		public Double discountValue; //Enviar Porcentagem
		public Integer firstInstallmentValue; //Somente quando aporte a vista
		public Boolean exemptInterestTicket; //false
		public List<String> bills;
		public List<String> statements;
	}

	//Wrapper de comunicacao LWC
	public class DadosParcelamento {
		public String ofertaParcelamento;
		public String descontoParcelamento;
		public Integer quantidadeParcelamento; //number
		public Double valorDesconto;
		public Double porcentagemDesconto;
		public String primeiroVencimento;
		public List<ParcelaItem> parcelas;
	}
	public class ParcelaItem {
		public String numeroParcela;
		public Double valorTotal;
		public String vencimento;
		public Double valorParcela; //firstValue
		public Double valorJuros; //firstInterest
		public Double valorMulta; //firstTicket
	}

	public class InstallmentException extends Exception {
	}
}
