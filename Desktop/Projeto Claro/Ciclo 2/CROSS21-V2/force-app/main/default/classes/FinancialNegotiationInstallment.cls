/**
 * @description       : US101348
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 27-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
**/
public with sharing class FinancialNegotiationInstallment {

	/**
        * @description Retorna as possiveis variacoes de parcelamento
        * @author Diego Almeida | 13-01-2021
        * @param stringBaseAtributes Infos do caso
        * @param StringBaseDetail Infos do componente
        * @return Map<String, Object>
	**/
    @AuraEnabled
	public static Map<String, Object> getInstallmentPlan(String stringBaseAtributes, String stringBaseDetail){
        FinancialMobileGeneralService.EntryPointWrapper baseAtributes = (FinancialMobileGeneralService.EntryPointWrapper)JSON.deserialize(stringBaseAtributes, FinancialMobileGeneralService.EntryPointWrapper.class);
        Map<String, Object> baseDetails = (Map<String, Object>) JSON.deserializeUntyped(stringBaseDetail );
        //System.debug('@@postNegotiationOptions:: baseAtributes => '+ JSON.serializePretty(baseAtributes));
        //System.debug('@@postNegotiationOptions:: baseDetails => '+ JSON.serializePretty(baseDetails));

        Map<String, Object> response = new Map<String, Object>();

        Map<String, Object> casoAtual = new Map<String, Object>();
        casoAtual.put('caseID', baseAtributes.recordId);
        casoAtual.put('status', 'Closed');



        Map<String, Object> authority = hasSalesforceAuthority(baseAtributes, baseDetails);
        if((Boolean) authority.get('hasSalesforceAuthority')){
            response.put('alcada', true);
            response.put('success', true);
            response.put('alcadaAprovada', authority.get('parametrosAprovados'));
            Map<String,Object> opcoesParcelamento = getInstallmentOptions(baseAtributes, baseDetails);
            response.put('matrizOfertas', opcoesParcelamento.get('matrizOfertas'));
            if(opcoesParcelamento.get('sucesso') == false){
                response.put('success', false);
                response.put('errorMessage', opcoesParcelamento.get('ofertaParcelamento'));
                casoAtual.put('authorityParam', authority.get('parametrosAprovados'));
                casoAtual.put('leavingReason', 'Negociação não realizada -Erro ao tentar negociar');
                response.put('casoAtual', closeCaseNegotiation(casoAtual));
            }
            response.put('dadosParcelamento', opcoesParcelamento.get('ofertaParcelamento'));

        }else{
            response.put('success', false);
            response.put('errorMessage', 'Nao foi encontrada alcada referente ao solicitado');
            casoAtual.put('authorityParam', authority.get('parametrosAprovados'));
            casoAtual.put('leavingReason', 'Negociação não realizada - Não disponível');
            response.put('casoAtual', closeCaseNegotiation(casoAtual));
        }

		return response;
    }

    /**
        * @description Valida alcada da US100174
        * @author Diego Almeida | 19-01-2021
        * @param casoAtual
        * @param valorNegociacao
        * @return Boolean
    **/
    private static Map<String, Object> hasSalesforceAuthority(FinancialMobileGeneralService.EntryPointWrapper baseAtributes, Map<String, Object> baseDetails){
        Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
        List<Parameters__c> parametrosAlcada = new List<Parameters__c>();
        List<Parameters__c> parametrosAprovados = new List<Parameters__c>();
        Map<String, Object> response = new Map<String, Object>();

        parametrosAlcada = [
            SELECT
				id,
				name,
				active__c,
				Process__c,
				Channel__c,
				Profile__c,
				Amount__c,
                Business_Division__c
			FROM Parameters__c
			WHERE Active__c = TRUE
				AND RecordTypeId = :recordTypeIdParameter
				AND Process__c = 'Negociação'
        ];
        //System.debug('@@hasSalesforceAuthority:: parametrosAlcada => '+ parametrosAlcada);

        if(parametrosAlcada.size() == 0){
            response.put('hasSalesforceAuthority', false);
            return response;
        }

        List<User> lstUser = new List<User>();
        List<PermissionSetAssignment> lstPermissionSet = new List<PermissionSetAssignment>();

        lstUser = [SELECT Id, Name, UserRoleId, UserRole.DeveloperName FROM User WHERE UserRoleId != NULL AND Id = :UserInfo.getUserId()];
        lstPermissionSet = [SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()];

        //System.debug('@@hasSalesforceAuthority:: lstUser => '+ lstUser);
        //System.debug('@@hasSalesforceAuthority:: lstPermissionSet => '+ lstPermissionSet);


		Map<String, PermissionSetAssignment> permissionSets = new Map<String, PermissionSetAssignment>();
		for (PermissionSetAssignment assign : lstPermissionSet){
            permissionSets.put(assign.PermissionSet.Name, assign);
        }
        //System.debug('@@hasSalesforceAuthority:: permissionSets => '+ permissionSets);


        Id profileId = UserInfo.getProfileId();
		String usrProfileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
        Boolean isDigitalProfile = usrProfileName == 'SF_DAC_Digital';
        //System.debug('@@hasSalesforceAuthority:: usrProfileName => '+ usrProfileName);



        for (Parameters__c parametro : parametrosAlcada) {

            if ((isDigitalProfile && parametro.Channel__c != 'Digital') || (!isDigitalProfile && parametro.Channel__c == 'Digital')){
                //System.debug('@@hasSalesforceAuthority:: isDigitalProfile => '+ isDigitalProfile);
                //System.debug('@@hasSalesforceAuthority:: parametro.Channel__c => '+ parametro.Channel__c);
                continue;
            }

            Boolean profileBool     = parametro.Profile__c != null  ?   permissionSets.get(parametro.Profile__c) != null    :   true;
            //System.debug('@@hasSalesforceAuthority:: profileBool => '+ profileBool);

            Boolean amountBool      = parametro.Amount__c != null   ?   parametro.Amount__c >= (Decimal) baseDetails.get('fullSumSelectedItems')     :   true;
            //System.debug('@@hasSalesforceAuthority:: amountBool => '+ amountBool);

            Boolean divisionBool    = parametro.Business_Division__c != null    ?   getBusinessDivision(baseAtributes.businessUnit) == parametro.Business_Division__c  :    true;
            //System.debug('@@hasSalesforceAuthority:: divisionBool => '+ divisionBool);



            if(profileBool && amountBool && divisionBool){
                parametrosAprovados.add(parametro);
            }
        }


        //System.debug('@@hasSalesforceAuthority:: parametrosAprovados => '+ parametrosAprovados);
        if(!parametrosAprovados.isEmpty()){
            String stringParams = '';
            response.put('hasSalesforceAuthority', true);
            // for (Parameters__c param : parametrosAprovados) {
            //     stringParams += param.Id;
            // }
            // response.put('parametrosAprovados', stringParams);
            response.put('parametrosAprovados', parametrosAprovados[0].Id);
        }else{
            response.put('hasSalesforceAuthority', false);
        }


        return response;
    }

    /**
        * @description Retorna a Businnes Division atrelada nas FinancialMobileGeneralService
        * @author Diego Almeida | 19-01-2021
        * @param contractCaseDivision
        * @return String
    **/
    private static String getBusinessDivision(String contractCaseDivision) {
        if (FinancialMobileGeneralService.RESIDENTIAL_UNIT.contains(contractCaseDivision.toUpperCase())){
            //System.debug('@@hasSalesforceAuthority:: getBusinessDivision => '+ 'Residencial');
            return 'Residencial';
        }

        if (FinancialMobileGeneralService.MOBILE_UNIT.contains(contractCaseDivision.toUpperCase())){
            //System.debug('@@hasSalesforceAuthority:: getBusinessDivision => '+ 'Movel');
            return 'Movel';
        }

        //System.debug('@@hasSalesforceAuthority:: getBusinessDivision => '+ 'Combo Multi');
        return 'Combo Multi';
    }

    /**
        * @description valida parcelamento q sera exibido
        * @author Diego Almeida | 21-01-2021
        * @param baseAtributes
        * @param baseDetails
        * @return Map<String, Object>
    **/
    private static Map<String,Object> getInstallmentOptions(FinancialMobileGeneralService.EntryPointWrapper baseAtributes, Map<String, Object> baseDetails){
        Map<String,Object> installmentOptions = new Map<String,Object>();
        String contractNumber = baseAtributes.contractId;// casoAtual.ContractBillingAccount__r.ContractReferenceNumber__c;
        String operatorCode = baseAtributes.operatorId;// casoAtual.ContractBillingAccount__r.CityCode__c;
        String cpf = baseAtributes.documentNumber;// casoAtual.Account.DocumentNumber__c;
        String segmentoContrato = baseAtributes.customerValue;// casoAtual.ContractBillingAccount__r.vlocity_cmt__CustomerValue__c;
        Double debtValue = (Double) baseDetails.get('fullSumSelectedItems');

        Map<String, List<String>> selectedNegotiation = convertListBillsStatment(baseDetails);

        //System.debug('@@getInstallmentOptions:: lstBills => '+ JSON.serializePretty(selectedNegotiation.get('bills')));
        //System.debug('@@getInstallmentOptions:: lstStatment => '+ JSON.serializePretty(selectedNegotiation.get('statements')));



        //Passo 1 - Chamar a api e retonar os planos de parcelamento do legado
        try {
            JSONInvoicesNegotiationOptions retornoLegado = postNegotiationOptions(contractNumber, operatorCode, '0', '0', selectedNegotiation);
            //System.debug('@@getInstallmentOptions:: retornoLegado => '+ JSON.serializePretty(retornoLegado));

            //Passo 2 - Selecionar a matriz de oferta
            Map<String, Object> propensaoPROCON = getPropensaoPROCON(cpf, contractNumber, operatorCode, '2');
            //System.debug('@@getInstallmentOptions:: propensaoPROCON => '+ propensaoPROCON);

            Map<String, Object> segmentacaoDefault = getSegmentacaoDefault(cpf, contractNumber, operatorCode, '2');
            //System.debug('@@getInstallmentOptions:: SegmentacaoDefault => '+ segmentacaoDefault);

            List<Parameters__c> offerMatrix = getOfferMatrix(String.valueOf(propensaoPROCON.get('parameterPROCON')), String.valueOf(segmentacaoDefault.get('parameterDefault')), segmentoContrato, debtValue);

            //Passo 3 - Tratamento caso nao haja matrix de oferta cadastrada para o perfil
            Map<String, Parameters__c> mapParcelamentoParam = new Map<String, Parameters__c>();
            if (offerMatrix.size() > 0) {
                for (Parameters__c parametro : offerMatrix) {
                    //System.debug('@@getInstallmentOptions:: Installments__c => '+ parametro.Installments__c);
                    if(mapParcelamentoParam.get(parametro.Installments__c) != null){
                        //System.debug('@@getInstallmentOptions:: mapParcelamentoParam => '+ mapParcelamentoParam.get(parametro.Installments__c).InstallmentDiscount__c);
                        //System.debug('@@getInstallmentOptions:: parametro => '+ parametro.InstallmentDiscount__c);
                        //System.debug('@@getInstallmentOptions:: compare => ' + (mapParcelamentoParam.get(parametro.Installments__c).InstallmentDiscount__c < parametro.InstallmentDiscount__c));


                        if(mapParcelamentoParam.get(parametro.Installments__c).InstallmentDiscount__c < parametro.InstallmentDiscount__c){
                            mapParcelamentoParam.put(parametro.Installments__c, parametro);
                        }
                    }else{
                        mapParcelamentoParam.put(parametro.Installments__c, parametro);
                    }
                }
                //System.debug('@@getInstallmentOptions:: mapParcelamentoParam => '+ JSON.serializePretty(mapParcelamentoParam));
            }

            //Passo 4 - limitar o legado de acordo com o retorno da matrix de oferta
            List<DadosParcelamento> parcelamentos = new List<DadosParcelamento>();
            for (JSONInvoicesNegotiationOptions.InstallmentOption installmentOption : retornoLegado.installmentOptions) {
                // DadosParcelamento parcelamento = new DadosParcelamento();
                if(offerMatrix.size() > 0){
                    installmentOptions.put('matrizOfertas', offerMatrix);
                    if(mapParcelamentoParam.get(String.valueOf(installmentOption.installmentNumber)) != null){
                        parcelamentos.add(fillDataInstallment(mapParcelamentoParam.get(String.valueOf(installmentOption.installmentNumber)), installmentOption));
                    }else{
                        //nao deveria cair aqui nunca mas....
                        parcelamentos.add(fillDataInstallment(null, installmentOption));
                    }
                }else{
                    installmentOptions.put('matrizOfertas', 'Nao foi encontrada matriz de oferta referente cadastrada');
                    parcelamentos.add(fillDataInstallment(null, installmentOption));
                }
            }
            //System.debug('@@getInstallmentOptions:: parcelamentos => '+ JSON.serializePretty(parcelamentos));
            installmentOptions.put('ofertaParcelamento', parcelamentos);
            installmentOptions.put('sucesso', true);
        } catch(Exception e) {
            installmentOptions.put('sucesso', false);
            installmentOptions.put('ofertaParcelamento', 'Erro na chamada do legado: ' + e.getMessage());
        }
        return installmentOptions;
    }

    /**
        * @description Transforma a lista de objetos em lista de string em um map
        * !validar com o joao se ta correto
        * @author Diego Almeida | 21-01-2021
        * @param baseDetails
        * @return Map<String, List<String>>
    **/
    private static Map<String, List<String>> convertListBillsStatment(Map<String, Object> baseDetails) {
        Map<String, List<String>> selectedNegotiation = new Map<String, List<String>>();
        selectedNegotiation.put('bills',  new List<string> ());
        selectedNegotiation.put('statements',  new List<string> ());

        List<Object> lstObjectBills = (List<Object>) baseDetails.get('selectedBills');
        for(Object b: lstObjectBills){
            selectedNegotiation.get('bills').add(String.valueOf(b));
        }

        List<Object> lstObjectStatment = (List<Object>) baseDetails.get('statementsIdsString');
        for(Object s: lstObjectStatment){
            selectedNegotiation.get('statements').add(String.valueOf(s));
        }

        return selectedNegotiation;
    }

    /**
        * @description monta as ofertas de parcelamento
        * @author Diego Almeida | 21-01-2021
        * @param mapParameters
        * @param jsonInstallment
        * @return DadosParcelamento
    **/
    private static DadosParcelamento fillDataInstallment(Parameters__c mapParameters, JSONInvoicesNegotiationOptions.InstallmentOption jsonInstallment) {
        //Passo 5 - montar o wrapper de envio
        DadosParcelamento parcelamento = new DadosParcelamento();
            parcelamento.ofertaParcelamento = jsonInstallment.installmentNumber +'x';
            parcelamento.descontoParcelamento = (mapParameters != null && mapParameters.InstallmentDiscount__c > 0) ? 'Desconto de '+mapParameters.InstallmentDiscount__c+'%' : 'Sem desconto';
            parcelamento.quantidadeParcelamento = jsonInstallment.installmentNumber;
            parcelamento.porcentagemDesconto = mapParameters != null ? mapParameters.InstallmentDiscount__c : 0;
            parcelamento.primeiroVencimento = FinancialMobileUtils.formatResponseDate(jsonInstallment.dueDate ,false);

        return parcelamento;
    }

    /**
        * @description monta e retorna query dinamica com as regras de validacao da matriz de ofertas
        * @author Diego Almeida | 21-01-2021
        * @param propensaoPROCON
        * @param segmentacaoDefault
        * @param segmentoContrato
        * @param debtValue
        * @return List<Parameters__c>
    **/
    private static List<Parameters__c> getOfferMatrix(String propensaoPROCON, String segmentacaoDefault, String segmentoContrato, Double debtValue) {
        //System.debug('@@getOfferMatrix:: propensaoPROCON => ' + propensaoPROCON);
        //System.debug('@@getOfferMatrix:: segmentacaoDefault => ' + segmentacaoDefault);
        //System.debug('@@getOfferMatrix:: segmentoContrato => ' + segmentoContrato);


        Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
        String queryParameters = 'SELECT  Id,  AnatelProconProneTargeting__c, Segment__c, DefaultTargeting__c, Name, Installments__c, InstallmentDiscount__c, DebtLimitValue__c';
        queryParameters += ' FROM Parameters__c WHERE Active__c = TRUE AND RecordTypeId = :recordTypeIdParameter';

        if(String.isNotBlank(propensaoPROCON)){ queryParameters += ' AND AnatelProconProneTargeting__c INCLUDES (\''+propensaoPROCON+'\')'; }

        if(String.isNotBlank(segmentacaoDefault)){ queryParameters += ' AND DefaultTargeting__c =: segmentacaoDefault'; }


        if(String.isNotBlank(segmentoContrato)){
            queryParameters += ' AND Segment__c INCLUDES (\''+segmentoContrato+'\')';
        }

        if(String.isNotBlank(segmentoContrato)){
            queryParameters += ' AND DebtLimitValue__c <= '+ debtValue;
        }


        queryParameters += ' ORDER BY Installments__c';
        //System.debug('@@getOfferMatrix:: queryParameters => ' + queryParameters);

        List<Parameters__c> matrixOfertas = Database.Query(queryParameters);
        //System.debug('@@getOfferMatrix:: matrixOfertas => ' + JSON.serializePretty(matrixOfertas));


        return matrixOfertas;
    }

    /**
        * @description Chama api InvoicesNegotiationOptions de parcelamento legado
        * @author Diego Almeida | 21-01-2021
        * @param contractNumber
        * @param operatorCode
        * @param discountValue
        * @param firstInstallmentValue
        * @param selectedNegotiation
        * @return JSONInvoicesNegotiationOptions
    **/
    private static JSONInvoicesNegotiationOptions postNegotiationOptions(String contractNumber,String operatorCode, String discountValue, String firstInstallmentValue, Map<String, List<string>> selectedNegotiation) {
        String stringJSONDATA = setJsonBody(contractNumber,operatorCode, discountValue, '0',  selectedNegotiation);

        Map<String, String> params = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');

        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(stringJSONDATA, params, headers, 'InvoicesNegotiationOptions');
        calloutResponse.put('response', calloutResponse.get('response').replace('"number"', '"installmentNumber"'));
        JSONInvoicesNegotiationOptions resp = new JSONInvoicesNegotiationOptions('JSONInvoicesNegotiationOptions', calloutResponse, true);

        //System.debug('@@postNegotiationOptions:: calloutResponse => '+ JSON.serializePretty(resp));

        return (JSONInvoicesNegotiationOptions) resp.getData();
    }

    /**
        * @description Parse data to JsonBody to post
        * @author Diego Almeida | 19-01-2021
        * @param jsonData
        * @return String
    **/
    private static String setJsonBody(String contractNumber,String operatorCode, String discountValue, String firstInstallmentValue,  Map<String, List<string>> selectedNegotiation){
        PostBody objBody = new PostBody();
        PostData objData = new PostData();
            objData.operatorCode            =   operatorCode;
            objData.contractNumber          =   Integer.valueOf(contractNumber);
            objData.userName                =   InvoicesUtils.getCalloutUser('InvoicesNegotiationOptions');
            objData.discountValue           =   Double.valueOf(discountValue);
            objData.firstInstallmentValue   =   Integer.valueOf(firstInstallmentValue);
            objData.exemptInterestTicket    =   false;
            objData.bills                   =   selectedNegotiation.get('bills');
            objData.statements              =   selectedNegotiation.get('statements');
        objBody.data                    =   objData;
        //System.debug('@@setJsonBody:: stringJSONDATA => '+ JSON.serializePretty(objBody));

        return JSON.serializePretty(objBody);
    }


    private static Map<String, Object> getPropensaoPROCON(String cpf, String contractNumber,String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

        Map<String, String> params = new Map<String, String>();
            params.put('origen', origin);
		// //System.debug('getPropensaoPROCON params: ' + params);

        Map<String, String> headers = new Map<String, String>();
            String authToken = getAuth('CustomerProconPropensity');
			headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf='+cpf+'&contractNumber='+contractNumber+'&operatorCode='+operatorCode;
			headers.put('X-QueryString', queryString);

		// //System.debug('getPropensaoPROCON headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerProconPropensity');
		JSONCustomerProconPropensity responseObject = (JSONCustomerProconPropensity)JSON.deserialize(calloutResponse.get('response'), JSONCustomerProconPropensity.class);

		if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
			response.put('propensaoPROCON', true);
            response.put('parameterPROCON', responseObject.data.codRangePropensity);
		}else{
			response.put('propensaoPROCON', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;

    }

    private static Map<String, Object> getSegmentacaoDefault(String cpf, String contractNumber,String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

        Map<String, String> params = new Map<String, String>();
            params.put('origen', origin);
		// //System.debug('getSegmentacaoDefault params: ' + params);

        Map<String, String> headers = new Map<String, String>();
            String authToken = getAuth('CustomerDefaultSegmetation');
			headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf='+cpf+'&contractNumber='+contractNumber+'&operatorCode='+operatorCode;
			headers.put('X-QueryString', queryString);

		// //System.debug('getSegmentacaoDefault headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerDefaultSegmetation');
		JSONCustomerDefaultSegmetation responseObject = (JSONCustomerDefaultSegmetation)JSON.deserialize(calloutResponse.get('response'), JSONCustomerDefaultSegmetation.class);

		if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
			response.put('propensaoDefault', true);
			response.put('parameterDefault', responseObject.data.descCluster);
		}else{
			response.put('propensaoDefault', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;

	}


    private static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
    }



	/**
        * @description Com base no parcelamento selecionado retorna os dados das parcelas
        * @author Diego Almeida | 13-01-2021
        * @param baseAtributes Infos do caso
        * @param baseDetail Infos do componente '.selectedInstallment'=DadosParcelamento
        * @return Map<String, Object>
	**/
    @AuraEnabled
	public static Map<String, Object> getInstallmentValues(String stringBaseAtributes, String stringBaseDetail){
        FinancialMobileGeneralService.EntryPointWrapper baseAtributes = (FinancialMobileGeneralService.EntryPointWrapper)JSON.deserialize(stringBaseAtributes, FinancialMobileGeneralService.EntryPointWrapper.class);
        Map<String, Object> baseDetails = (Map<String, Object>) JSON.deserializeUntyped(stringBaseDetail);
        Map<String, Object> response = new Map<String, Object>();

        Map<String, Object> casoAtual = new Map<String, Object>();
            casoAtual.put('caseID', baseAtributes.recordId);
            casoAtual.put('status', 'Closed');
            casoAtual.put('leavingReason', 'Negociação não realizada -Erro ao tentar negociar');


        DadosParcelamento dadosParcelamento = (DadosParcelamento) JSON.deserialize(JSON.serialize(baseDetails.get('selectedInstallment')), DadosParcelamento.class) ;
        // System.debug('@@getInstallmentValues:: dadosParcelamento => '+ JSON.serializePretty(dadosParcelamento));


        Map<String,Object> installmentOptions = new Map<String,Object>();
        String contractNumber = baseAtributes.contractId;// casoAtual.ContractBillingAccount__r.ContractReferenceNumber__c;
        String operatorCode = baseAtributes.operatorId;// casoAtual.ContractBillingAccount__r.CityCode__c;
        String cpf = baseAtributes.documentNumber;// casoAtual.Account.DocumentNumber__c;
        String segmentoContrato = baseAtributes.customerValue;// casoAtual.ContractBillingAccount__r.vlocity_cmt__CustomerValue__c;
        Double debtValue = (Double) baseDetails.get('fullSumSelectedItems');

        Map<String, List<String>> selectedNegotiation = convertListBillsStatment(baseDetails);
        // System.debug('@@getInstallmentValues:: dadosParcelamento => '+ JSON.serializePretty(dadosParcelamento));

        String discountValue = String.valueOf(dadosParcelamento.porcentagemDesconto);
        //Passo1 - Chamar o legado com os dados de desconto selecionado

        try {
            JSONInvoicesNegotiationOptions retornoLegado = postNegotiationOptions(contractNumber, operatorCode, discountValue, '0', selectedNegotiation);
            // System.debug('@@getInstallmentValues:: retornoLegado => '+ JSON.serializePretty(retornoLegado));


            //Passo2 - Preencher os dados de parcelamento com os dados atualizados
            dadosParcelamento.valorDesconto = Double.valueOf(retornoLegado.totalDebt);
            System.debug('@@getInstallmentValues:: dadosParcelamento => '+ JSON.serializePretty(dadosParcelamento));


            //Passo3 - Criar map das parcelas
            JSONInvoicesNegotiationOptions.InstallmentOption objParcelamento = new JSONInvoicesNegotiationOptions.InstallmentOption();
            for (JSONInvoicesNegotiationOptions.InstallmentOption installmentOption : retornoLegado.installmentOptions) {
                if(installmentOption.installmentNumber == dadosParcelamento.quantidadeParcelamento){
                    objParcelamento = installmentOption;
                    break;
                }
            }

            System.debug('@@getInstallmentValues:: objParcelamento => '+ JSON.serializePretty(objParcelamento));



            //Tratamento pq o ammout retorna como 0 quando parcela a vista
            Integer qtdParcelas = objParcelamento.installmentNumber == 0 ? 1 : objParcelamento.installmentNumber;

            Date dataPrimeiroVencimento = Date.newInstance(Integer.valueOf(dadosParcelamento.primeiroVencimento.split('/')[2]), Integer.valueOf(dadosParcelamento.primeiroVencimento.split('/')[1]), Integer.valueOf(dadosParcelamento.primeiroVencimento.split('/')[0]));


            //Passo4 - Calcular o valor de cada parcela relacionda
            List<ParcelaItem> lstParcelas = new List<ParcelaItem>();
            Double totalValueParcelas = 0;
            for (Integer i = 1; i <= qtdParcelas; i++) {

                ParcelaItem parcela = new ParcelaItem();
                parcela.numeroParcela = String.valueOf(i);
                if(i==1){
                    parcela.valorJuros = Double.valueOf(objParcelamento.firstInterest);
                    parcela.valorMulta = Double.valueOf(objParcelamento.firstTicket);
                    parcela.valorParcela = Double.valueOf(objParcelamento.firstValue);
                    parcela.valorTotal = Double.valueOf(objParcelamento.firstValue);
                    parcela.vencimento = FinancialMobileUtils.formatResponseDate(String.valueOf(dataPrimeiroVencimento), false);
                }else if(i == qtdParcelas){
                    parcela.valorJuros = Double.valueOf(objParcelamento.lastInterest);
                    parcela.valorMulta = Double.valueOf(objParcelamento.lastTicket);
                    parcela.valorParcela = Double.valueOf(objParcelamento.lastValue);
                    parcela.valorTotal =  Double.valueOf(objParcelamento.lastValue);
                    parcela.vencimento = FinancialMobileUtils.formatResponseDate(String.valueOf(dataPrimeiroVencimento.addMonths(i-1)) ,false);
                }else{
                    parcela.valorJuros = Double.valueOf(objParcelamento.intermediaryInterest);
                    parcela.valorMulta = Double.valueOf(objParcelamento.intermediaryTicket);
                    parcela.valorParcela = Double.valueOf(objParcelamento.intermediaryValue);
                    parcela.valorTotal = Double.valueOf(objParcelamento.intermediaryValue);
                    parcela.vencimento = FinancialMobileUtils.formatResponseDate(String.valueOf(dataPrimeiroVencimento.addMonths(i-1)) ,false);
                }
                totalValueParcelas += parcela.valorTotal;
                lstParcelas.add(parcela);
            }

            //Passo5 - Retornar a lista de parcelas para o front
            dadosParcelamento.parcelas = lstParcelas;
            dadosParcelamento.apiData = fillApiData(objParcelamento, dadosParcelamento, retornoLegado, totalValueParcelas);
            response.put('success', true);
            response.put('installmentValues', dadosParcelamento);
        } catch(Exception e) {
            response.put('success', false);
            response.put('installmentValues', 'Erro na chamada do legado: ' + e.getMessage());
            response.put('casoAtual', closeCaseNegotiation(casoAtual));
        }

        System.debug('@@getInstallmentValues:: response => '+ JSON.serializePretty(response));
		return response;
    }

    private static ApiData fillApiData(JSONInvoicesNegotiationOptions.InstallmentOption objParcelamento, DadosParcelamento dadosParcelamento, JSONInvoicesNegotiationOptions retornoLegado, Double totalValueParcelas) {
        ApiData returnData = new ApiData();
            returnData.totalDebt = String.valueOf(retornoLegado.totalDebt);
            returnData.totalTicket = String.valueOf(retornoLegado.totalTicket);
            returnData.totalInterest = String.valueOf(retornoLegado.totalInterest);
            returnData.total = String.valueOf(retornoLegado.total);
            returnData.amount = Integer.valueOf(objParcelamento.installmentNumber);
            returnData.exemptInterestTicket = false;
            returnData.discountValue = Double.valueOf(dadosParcelamento.porcentagemDesconto);
            returnData.firstInstallmentValue = Double.valueOf(objParcelamento.firstValue);
            returnData.firstInstallmentInterest = Double.valueOf(objParcelamento.firstInterest);
            returnData.firstInstallmentTicket = Double.valueOf(objParcelamento.firstTicket);
            returnData.intermediaryInstallmentValue = Double.valueOf(objParcelamento.intermediaryValue);
            returnData.intermediaryInstallmenInterest = Double.valueOf(objParcelamento.intermediaryInterest);
            returnData.intermediaryInstallmenTicket = Double.valueOf(objParcelamento.intermediaryTicket);
            returnData.lastInstallmentValue = Double.valueOf(objParcelamento.lastValue);
            returnData.lastInstallmentInterest = Double.valueOf(objParcelamento.lastInterest);
            returnData.lastInstallmentTicket = Double.valueOf(objParcelamento.lastTicket);
            returnData.totalValueParcelas = totalValueParcelas;
        return returnData;
    }

    /**
    * @description
    * @author Diego Almeida | 26-01-2021
    * @param case  Map => caseID;leavingReason;authorityParam;status;
    * @return Case
    **/
    public static Case closeCaseNegotiation (Map <String, Object> caseData){
        Case casoAtualizado = new Case();
            casoAtualizado.Id = String.valueOf(caseData.get('caseID'));
            casoAtualizado.EntryReason__c = 'Renegociacao de Valores';
            casoAtualizado.LeavingReason__c = String.valueOf(caseData.get('leavingReason'));
            if(caseData.get('authorityParam') != null){
                casoAtualizado.Authorization__c = String.valueOf(caseData.get('authorityParam'));
            }
            casoAtualizado.Status = String.valueOf(caseData.get('status'));

        Savepoint sp = Database.setSavepoint();
        try {
            Database.upsert(casoAtualizado);
        }catch(Exception ex) {
            Database.rollback(sp);
            System.debug('closeCaseNegotiation:: Erro ao atualizar caso: ' + ex.getMessage());
        }
        return casoAtualizado;
    }


    //Wrapper do body envio
    public class PostBody{
        public PostData data;
    }
    public class PostData{
        public String operatorCode;
        public Integer contractNumber;
        public String userName;
        public Double discountValue;//Enviar Porcentagem
        public Integer firstInstallmentValue;//Somente quando aporte a vista
        public Boolean exemptInterestTicket;//false
        public List<String> bills;
        public List<String> statements;
    }

    //Wrapper de comunicacao LWC


    public class DadosParcelamento{
        @AuraEnabled public String   ofertaParcelamento;
        @AuraEnabled public String   descontoParcelamento;
        @AuraEnabled public Integer  quantidadeParcelamento;  //number
        @AuraEnabled public Double   valorDesconto;
        @AuraEnabled public Double   porcentagemDesconto;
        @AuraEnabled public String   primeiroVencimento;
        @AuraEnabled public List<ParcelaItem> parcelas;
        @AuraEnabled public ApiData apiData;
    }

    public class ParcelaItem{
        @AuraEnabled public String numeroParcela;
        @AuraEnabled public Double valorTotal;
        @AuraEnabled public String vencimento;
        @AuraEnabled public Double valorParcela;//firstValue
        @AuraEnabled public Double valorJuros;//firstInterest
        @AuraEnabled public Double valorMulta;//firstTicket
    }

    public class ApiData{
        @AuraEnabled public String totalDebt;
        @AuraEnabled public String totalTicket;
        @AuraEnabled public String totalInterest;
        @AuraEnabled public String total;
        @AuraEnabled public Integer amount;
        @AuraEnabled public Boolean exemptInterestTicket;
        @AuraEnabled public Double discountValue;
        @AuraEnabled public Double firstInstallmentValue;
        @AuraEnabled public Double firstInstallmentInterest;
        @AuraEnabled public Double firstInstallmentTicket;
        @AuraEnabled public Double intermediaryInstallmentValue;
        @AuraEnabled public Double intermediaryInstallmenInterest;
        @AuraEnabled public Double intermediaryInstallmenTicket;
        @AuraEnabled public Double lastInstallmentValue;
        @AuraEnabled public Double lastInstallmentInterest;
        @AuraEnabled public Double lastInstallmentTicket;
        @AuraEnabled public Double totalValueParcelas;
    }


	public class InstallmentException extends Exception {
	}
}