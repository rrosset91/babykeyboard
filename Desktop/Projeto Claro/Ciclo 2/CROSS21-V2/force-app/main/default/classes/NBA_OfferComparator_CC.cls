/*--------------------------------------------------------------------------------------------
  --- Company: Accenture Brasil
  --- Creation Date: 20/01/2018
  --- Author: Vladson Araujo
  --- Description: Classe que representa o controlador do componente de Ofertas
  ---------------------------------------------------------------------------------------------
  --- Company: Claro Brasil
  --- Modify Date: 13/03/2020 
  --- Author: André Salgado
  --- Description: Inclusão do nó mobileDiscounts no retorno da API de extras
  ----------------------------------------------------------------------------------------------*/
  public with sharing class NBA_OfferComparator_CC {
    private static Boolean hasDiscountAutomaticDebit = false;
    private static final Id recordTypeIdNBAOffer = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
    
    @AuraEnabled
    public static String portabilityPerformPreAnalysis(List<String> phoneNumbers){
        List<Map<String, Object>> telephoneNumbers = new List<Map<String, Object>>();
		for(String phoneNumber: phoneNumbers)
			telephoneNumbers.add(new Map<String, Object>{'number' => phoneNumber});
		Map<String, Object> data = new Map<String, Object>{'telephoneNumbers' => telephoneNumbers};
        Map<String, Object> payload = new Map<String, Object>{'data' => data, 'apiVersion' => null};
        
        return JSON.serialize(NBA_IntegrationServices.portabilityPerformPreAnalysis(payload));
    }
    
    @AuraEnabled
    public static String portabilityValidateMatchingDDD(String caseId){
        String zipCode;
        List<Case> caseContractId = [SELECT Id,ContractNumber__c,ContractNumber__r.BillingPostalCode FROM Case WHERE Id =: caseId];
        List<Asset> premisesPostalCode = [SELECT Id, vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c FROM Asset WHERE vlocity_cmt__ContractId__c =:caseContractId[0].ContractNumber__c AND vlocity_cmt__PremisesId__c != null];        
        if(!premisesPostalCode.isEmpty()){
        zipCode = premisesPostalCode[0].vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c;
        }else{
            zipCode = caseContractId[0].ContractNumber__r.BillingPostalCode;
        }
        Map<String, Object> payload = new Map<String, Object>{
            'zipCode' => zipCode
        };        
        
        return JSON.serialize(NBA_IntegrationServices.portabilityValidateMatchingDDD(payload));
    }

    @AuraEnabled
    public static String portabilityValidateOwnership(String cityId, String phoneNumber, String caseId){
        Case caso = [SELECT ContractNumber__r.Account.DocumentType__c, ContractNumber__r.Account.DocumentNumber__c FROM Case WHERE Id=:caseId];
        Map<String, Object> payload = new Map<String, Object>{
            'cityId'=>cityId, 'telephoneNumber'=>phoneNumber, 
            'partyIdentificationType'=>caso.ContractNumber__r.Account.DocumentType__c=='CPF' ? '1' : '2', 
            'partyIdentificationNumber'=>caso.ContractNumber__r.Account.DocumentNumber__c
        };
        
        return JSON.serialize(NBA_IntegrationServices.portabilityValidateOwnership(payload));
    }

    @AuraEnabled
    public static void saveClickSelectOffer(String recordId){
        Case caso = [SELECT CallParameterIndt__c FROM Case Where id = :recordId];        

        if(caso.CallParameterIndt__c==null || caso.CallParameterIndt__c=='' || (String.isNotBlank(caso.CallParameterIndt__c) && !caso.CallParameterIndt__c.contains('Clique:'))){

          caso.CallParameterIndt__c = caso.CallParameterIndt__c + 'Clique:TodasAsOfertas;';
        }
        update caso;
    }
    
    //Adicionada validação para casos do tipo financeiro, pois CRM Cross utiliza estrutura diferente para o contrato
    @AuraEnabled
    public static NBA_OfferComparator_CC.Result consultarOfertas(Id recordId, Boolean tvAvailable, Boolean BroadbandAvailable, Boolean digAvailable, Boolean phoneAvailable, NBA_IntegrationModels.CurrentProductResponse retornoPosse) {
        System.debug('nessa ordem ' + recordId + '' + tvAvailable + '' + BroadbandAvailable + '' + digAvailable + '' + phoneAvailable);
        NBA_OfferComparator_CC.Result result = new NBA_OfferComparator_CC.Result();
        result.OffersApiCalled = true;
        Try {
            List<Case> lstCase = [
                    SELECT Id,
                            Contract__c,
                            CallReason__c,
                            Subreason__c,
                            ProductTV__c,
                            broadband__c,
                            Fixo__c,
                            Movel__c,
                			Account.DocumentNumber__c,
                            RecordType.DeveloperName,
                            ContractNumber__r.CityCode__c,
                            ContractNumber__r.ContractNumber__c,
                            ContractNumber__r.Account.DocumentNumber__c,
                            ContractNumber__r.PaymentMethod__c,
                            ContractNumber__r.BillDeliveryMethod__c,
                			ContractBillingAccount__r.ContractReferenceNumber__c,
                			ContractBillingAccount__r.CityCode__c
                    FROM Case
                    WHERE Id = :recordId
            ];
            List<User> lstUser = [SELECT NetServicos__c, FederationIdentifier, CompanyName, Claro__c FROM User WHERE Id = :UserInfo.getUserId()];
            if (lstUser != null && !lstUser.isEmpty()) {
                String netServicos;
                if (lstUser[0].NetServicos__c != null) {
                    netServicos = lstUser[0].NetServicos__c;
                } else {
                    netServicos = lstUser[0].FederationIdentifier;
                }
                String perfilAtendente;
                if (lstUser[0].Claro__c != null) {
                    perfilAtendente = lstUser[0].Claro__c;
                } else {
                    perfilAtendente = '';
                }
                if (lstCase != null && !lstCase.isEmpty()) {
                    Case caso = lstCase[0];
                    if (String.isNotBlank(caso.ContractNumber__r.PaymentMethod__c) && String.isNotBlank(caso.ContractNumber__r.BillDeliveryMethod__c)) {
                        hasDiscountAutomaticDebit = NBA_Constants.PAYMENTMETHOD.containsIgnoreCase(caso.ContractNumber__r.PaymentMethod__c) && NBA_Constants.BILLDELIVERYMETHOD.containsIgnoreCase(caso.ContractNumber__r.BillDeliveryMethod__c);
                    } else {
                        hasDiscountAutomaticDebit = false;
                    }
                    if ((caso.recordType.DeveloperName != 'Financial' && String.isNotBlank(caso.ContractNumber__r.ContractNumber__c) && String.isNotBlank(caso.ContractNumber__r.Account.DocumentNumber__c)) ||
                        (caso.recordType.DeveloperName == 'Financial' && String.isNotBlank(caso.ContractBillingAccount__r.ContractReferenceNumber__c) && String.isNotBlank(caso.Account.DocumentNumber__c))) {
                        NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_List_Offers');
                        Map<String, Object> request = new Map<String, Object> ();
                        if(caso.recordType.DeveloperName == 'Financial'){
                            request.put('operatorId', (caso.ContractBillingAccount__r.CityCode__c != null ? caso.ContractBillingAccount__r.CityCode__c : ''));
                            request.put('contractNumber', (caso.ContractBillingAccount__r.ContractReferenceNumber__c != null ? caso.ContractBillingAccount__r.ContractReferenceNumber__c : ''));
                            request.put('documentNumber', (caso.Account.DocumentNumber__c != null ? caso.Account.DocumentNumber__c : ''));       
                        }else{
                            request.put('operatorId', (caso.ContractNumber__r.CityCode__c != null ? caso.ContractNumber__r.CityCode__c : ''));
                            request.put('contractNumber', (caso.ContractNumber__r.ContractNumber__c != null ? caso.ContractNumber__r.ContractNumber__c : ''));
                            request.put('documentNumber', (caso.ContractNumber__r.Account.DocumentNumber__c != null ? caso.ContractNumber__r.Account.DocumentNumber__c : ''));
                        }
                        request.put('attendantProfile', (netServicos != null ? netServicos : ''));
                        request.put('eventType', (caso.RecordType.DeveloperName != null ? caso.RecordType.DeveloperName : ''));
                        request.put('subreason', (caso.Subreason__c != null ? caso.Subreason__c : ''));
                        request.put('offerId', '');
                        request.put('caseId', (caso.Id != null ? caso.Id : ''));
                        request.put('serviceProvider', (lstUser[0].CompanyName != null ? lstUser[0].CompanyName : ''));
                        request.put('channel', 'Salesforce');
                        request.put('quantity', removeDecimalPlace(String.valueOf(configuracao.NBA_NumeroOfertas__c)));
                        request.put('flagTvAction', (caso.ProductTV__c ? '1' : '0'));
                        request.put('flagBroadbandAction', (caso.broadband__c ? '1' : '0'));
                        request.put('flagPhoneAction', (caso.Fixo__c ? '1' : '0'));
                        request.put('flagMobileAction', (caso.Movel__c ? '1' : '0'));
                        //request.put('mobileAttendantProfile', '93209756');
                        request.put('mobileAttendantProfile', perfilAtendente);
                        request.put('flagTvAvailable', '1');
                        if (tvAvailable != null && !tvAvailable) {
                            request.put('flagTvAvailable', '0');
                        }
                        request.put('flagDigAvailable', '1');
                        if (digAvailable != null && !digAvailable) {
                            request.put('flagDigAvailable', '0');
                        }
                        request.put('flagBroadbandAvailable', '1');
                        if (BroadbandAvailable != null && !BroadbandAvailable) {
                            request.put('flagBroadbandAvailable', '0');
                        }
                        request.put('flagPhoneAvailable', '1');
                        if (phoneAvailable != null && !phoneAvailable) {
                            request.put('flagPhoneAvailable', '0');
                        }
                        // posse
                        if (retornoPosse.data == null) {
                            retornoPosse.data = new NBA_IntegrationModels.CurrentProductData();
                        }

                        // ofertas
                        NBA_IntegrationModels.SearchOffersResponse response = NBA_IntegrationServices.getOffers(request);

                        if (response.data == null) {
                            response.data = new NBA_IntegrationModels.SearchOffersData();
                        }
                        if (response.data.recommendations == null || response.data.recommendations.size() == 0) {
                            result.mensagemSemOfertas = response.data.salesmanId;
                        } else {
                            
                            
                            response.data.currentProduct = retornoPosse.data;
                            result = calculateOffers(response, caso.Id);
                            result.cityCode = response.data.subscriberCityCode;
                            result.subscriberIbgeCode = response.data.subscriberIbgeCode;
                            result.channelDetail = response.data.channelDetail;
                            result.attendantProfile = response.data.attendantProfile;
                            result.mobileAttendantProfile = response.data.mobileAttendantProfile;
                            result.mobileChannelDetail = response.data.mobileChannelDetail;
                            result.callReason = lstCase[0].CallReason__c; //10/09/19 - Kleverton Fortunato - CLAR179
                            result.resultadoBrudoAPI = response;
                            //Chirleny 12/12/2019
                            List<NBA_Pointing__mdt> lstPontuacao = [SELECT Id, MaxPercentage__c, MinPercentage__c, Pointing__c FROM NBA_Pointing__mdt];
                            if (lstPontuacao != null && !lstPontuacao.isEmpty()) {
                                result.pontuacao = lstPontuacao;
                            }
                        }
                    } else {
                        throw new DadosInvalidosException('Valores de Número do Contrato ou Número CPF estão vazios!');
                    }
                }
            }
        } catch (Exception e) {
            System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    @AuraEnabled
    public static NBA_IntegrationModels.SearchOffersResponse consultarListaOfertas(Id recordId, Boolean tvAvailable, Boolean BroadbandAvailable, Boolean digAvailable, Boolean phoneAvailable) {
        return consultarListaTodasOfertas(recordId, false, tvAvailable, BroadbandAvailable, digAvailable, phoneAvailable);
    }
    @AuraEnabled
    public static NBA_IntegrationModels.SearchOffersResponse consultarListaOfertasCancelamento(Id recordId, Boolean tvAvailable, Boolean BroadbandAvailable, Boolean digAvailable, Boolean phoneAvailable) {
        return consultarListaTodasOfertas(recordId, true, tvAvailable, BroadbandAvailable, digAvailable, phoneAvailable);
    }

    //Adicionado por time CRM Cross validação para casos do tipo de registro financeiro, pois o mesmo utiliza uma estrutura diferente para chegar ao contrato
    @AuraEnabled
    public static NBA_IntegrationModels.SearchOffersResponse consultarListaTodasOfertas(Id recordId, Boolean isCancel, Boolean tvAvailable, Boolean BroadbandAvailable, Boolean digAvailable, Boolean phoneAvailable) {
        NBA_IntegrationModels.SearchOffersResponse result = new NBA_IntegrationModels.SearchOffersResponse();
        List<Case> lstCase = [
                    SELECT Id,
                            Contract__c,
                            CallReason__c,
                            Subreason__c,
                            ProductTV__c,
                            broadband__c,
                            Fixo__c,
                            Movel__c,
                			Account.DocumentNumber__c,
                            RecordType.DeveloperName,
                            ContractNumber__r.CityCode__c,
                            ContractNumber__r.ContractNumber__c,
                            ContractNumber__r.Account.DocumentNumber__c,
                            ContractNumber__r.PaymentMethod__c,
                            ContractNumber__r.BillDeliveryMethod__c,
                			ContractBillingAccount__r.ContractReferenceNumber__c,
                			ContractBillingAccount__r.CityCode__c
                    FROM Case
                    WHERE Id = :recordId
            ];
        List<User> lstUser = [SELECT NetServicos__c, FederationIdentifier, Claro__c, CompanyName FROM User WHERE Id = :UserInfo.getUserId()];
        String perfilAtendente;
        if (lstUser[0].Claro__c != null) {
            perfilAtendente = lstUser[0].Claro__c;
        } else {
            perfilAtendente = '';
        }
        if (!lstUser.isEmpty()) {
            String netServicos = lstUser[0].NetServicos__c != null ? lstUser[0].NetServicos__c : lstUser[0].FederationIdentifier;
            if (!lstCase.isEmpty()) {
                Case caso = lstCase[0];
                if (String.isNotBlank(caso.ContractNumber__r.PaymentMethod__c) && String.isNotBlank(caso.ContractNumber__r.BillDeliveryMethod__c)) {
                    hasDiscountAutomaticDebit = NBA_Constants.PAYMENTMETHOD.containsIgnoreCase(caso.ContractNumber__r.PaymentMethod__c) && NBA_Constants.BILLDELIVERYMETHOD.containsIgnoreCase(caso.ContractNumber__r.BillDeliveryMethod__c);
                } else {
                    hasDiscountAutomaticDebit = false;
                }
                if ((caso.recordType.DeveloperName != 'Financial' && String.isNotBlank(caso.ContractNumber__r.ContractNumber__c) && String.isNotBlank(caso.ContractNumber__r.Account.DocumentNumber__c)) ||
                    (caso.recordType.DeveloperName == 'Financial' && String.isNotBlank(caso.ContractBillingAccount__r.ContractReferenceNumber__c) && String.isNotBlank(caso.Account.DocumentNumber__c))) {
                    NBA_Integration_Definitions__mdt configuracao = NBA_IntegrationUtils.getConfiguracaoDeIntegracao('NBA_List_Offers');
                    Map<String, Object> request = new Map<String, Object> ();
                    if(caso.recordType.DeveloperName == 'Financial'){
                        request.put('operatorId', (caso.ContractBillingAccount__r.CityCode__c != null ? caso.ContractBillingAccount__r.CityCode__c : ''));
                        request.put('contractNumber', (caso.ContractBillingAccount__r.ContractReferenceNumber__c != null ? caso.ContractBillingAccount__r.ContractReferenceNumber__c : ''));
                        request.put('documentNumber', (caso.Account.DocumentNumber__c != null ? caso.Account.DocumentNumber__c : ''));       
                    }else{
                        request.put('operatorId', (caso.ContractNumber__r.CityCode__c != null ? caso.ContractNumber__r.CityCode__c : ''));
                        request.put('contractNumber', (caso.ContractNumber__r.ContractNumber__c != null ? caso.ContractNumber__r.ContractNumber__c : ''));
                        request.put('documentNumber', (caso.ContractNumber__r.Account.DocumentNumber__c != null ? caso.ContractNumber__r.Account.DocumentNumber__c : ''));
                    }
                    request.put('attendantProfile', (netServicos != null ? netServicos : ''));
                    request.put('eventType', (caso.RecordType.DeveloperName != null ? caso.RecordType.DeveloperName : ''));
                    if (isCancel) {
                        request.put('reason', 'Cancelamento');
                        request.put('subreason', '');
                    } else {
                        request.put('reason', (caso.CallReason__c != null ? caso.CallReason__c : ''));
                        request.put('subreason', (caso.Subreason__c != null ? caso.Subreason__c : ''));
                    }
                    request.put('offerId', '');
                    request.put('caseId', (caso.Id != null ? caso.Id : ''));
                    request.put('serviceProvider', (lstUser[0].CompanyName != null ? lstUser[0].CompanyName : ''));
                    request.put('channel', 'Salesforce');
                    request.put('quantity', removeDecimalPlace(String.valueOf(configuracao.NBA_NumeroOfertas__c)));
                    request.put('flagTvAction', (caso.ProductTV__c ? '1' : '0'));
                    request.put('flagBroadbandAction', (caso.broadband__c ? '1' : '0'));
                    request.put('flagPhoneAction', (caso.Fixo__c ? '1' : '0'));
                    request.put('flagMobileAction', (caso.Movel__c ? '1' : '0'));
                    request.put('mobileAttendantProfile', perfilAtendente);   // Alexandre Amaro 16-08-19
                    request.put('flagTvAvailable', '1');
                    if (tvAvailable != null && !tvAvailable) {
                        request.put('flagTvAvailable', '0');
                    }
                    request.put('flagDigAvailable', '1');
                    if (digAvailable != null && !digAvailable) {
                        request.put('flagDigAvailable', '0');
                    }
                    request.put('flagBroadbandAvailable', '1');
                    if (BroadbandAvailable != null && !BroadbandAvailable) {
                        request.put('flagBroadbandAvailable', '0');
                    }
                    request.put('flagPhoneAvailable', '1');
                    if (phoneAvailable != null && !phoneAvailable) {
                        request.put('flagPhoneAvailable', '0');
                    }
                    //request.put('operatorId', '013');
                    //request.put('contractNumber', '21090063');
                    //request.put('documentNumber', '01448510678');
                    //request.put('attendantProfile', 'T6319063');
                    //request.put('eventType', 'RETENCAO/REVERSAO');
                    //request.put('reason', 'ERRADO');
                    //request.put('subreason', 'ERRADO');
                    //request.put('offerId', '123456');
                    //request.put('caseId', '123456');
                    //request.put('serviceProvider', 'URA');
                    //request.put('channel', 'Salesforce');
                    //request.put('quantity', String.valueOf(configuracao.NBA_NumeroOfertas__c));
                    //request.put('flagTvAction', (caso.ProductTV__c ? '1' : '0'));
                    //request.put('flagBroadbandAction', (caso.broadband__c ? '1' : '0'));
                    //request.put('flagPhoneAction', (caso.Fixo__c ? '1' : '0'));
                    //request.put('flagMobileAction', (caso.Movel__c ? '1' : '0'));
                    result = NBA_IntegrationServices.getOffers(request);

                    if (result.data == null) {
                        result.data = new NBA_IntegrationModels.SearchOffersData();
                    }


                    NBA_IntegrationModels.CurrentProductResponse responseCurrentProduct = consultarProdutoAtual(recordId);
                    if (responseCurrentProduct.data == null) {
                        responseCurrentProduct.data = new NBA_IntegrationModels.CurrentProductData();
                    }
                    result.data.currentProduct = responseCurrentProduct.data;
                } else {
                    throw new DadosInvalidosException('Valores de Número do Contrato ou Número CPF estão vazios!');
                }
            }
        }
        return result;
    }
    /////////////////////////////////////////////////////////////////////////////////////////      ADICIONAIS POSSE ATUAL   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static NBA_OfferComparator_CC.Result recalculateCurrentProduct(String ofertaToCalculateJSON, String recordId) {
        NBA_IntegrationModels.SearchOffersResponse ofertaToCalculate = (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(ofertaToCalculateJSON, NBA_IntegrationModels.SearchOffersResponse.class);
        Case caso;
        Try {
            List<Case> lstCase = [
                    SELECT id, RecordTypeName__c, ContractNumber__r.ContractNumber__c, ContractNumber__r.CityCode__c, ContractNumber__r.PaymentMethod__c,
                            ContractNumber__r.BillDeliveryMethod__c
                    FROM Case
                    WHERE id = :recordId
            ];
            List<User> lstUser = [SELECT NetServicos__c, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];
            if (!lstUser.isEmpty()) {
                String netServicos = lstUser[0].NetServicos__c != null ? lstUser[0].NetServicos__c : lstUser[0].FederationIdentifier;
                if (!lstCase.isEmpty()) {
                    caso = lstCase[0];
                    hasDiscountAutomaticDebit = String.isNotBlank(caso.ContractNumber__r.PaymentMethod__c) && String.isNotBlank(caso.ContractNumber__r.BillDeliveryMethod__c) ? NBA_Constants.PAYMENTMETHOD.containsIgnoreCase(caso.ContractNumber__r.PaymentMethod__c) && NBA_Constants.BILLDELIVERYMETHOD.containsIgnoreCase(caso.ContractNumber__r.BillDeliveryMethod__c) : false;
                    String currentTvId = '';
                    String offerTVId = '';
                    String offerBLId = '';
                    String offerFNId = '';
                    String offerMVId = '';
                    String offerReferenceId = '';
                    String cityId = ofertaToCalculate.data.subscriberCityCode;
                    String ibgeCode = ofertaToCalculate.data.subscriberIbgeCode;
                    String baseId = '';
                    String channelDetail = ofertaToCalculate.data.channelDetail == null ? '' : ofertaToCalculate.data.channelDetail;
                    String attendantProfile = ofertaToCalculate.data.attendantProfile == null ? '' : ofertaToCalculate.data.attendantProfile;
                    String mobileAttendantProfile = ofertaToCalculate.data.mobileAttendantProfile == null ? '' : ofertaToCalculate.data.mobileAttendantProfile;
                    String mobileServiceChannel = ofertaToCalculate.data.mobileChannelDetail == null ? '' : ofertaToCalculate.data.mobileChannelDetail;
                    //	String callReason = lstCase[0].CallReason__c; //10/09/19 - Kleverton Fortunato - CLAR179
                    /*
                    if(ofertaToCalculate.currentProduct.tv != null && !ofertaToCalculate.currentProduct.tv.isEmpty()){
						currentTvId = ofertaToCalculate.currentProduct.tv[0].planTv.key != null ? ofertaToCalculate.currentProduct.tv[0].planTv.key : '';
						offerTVId   = ofertaToCalculate.currentProduct.tv[0].planTv.key != null ? ofertaToCalculate.currentProduct.tv[0].planTv.key : '';
					}
					offerBLId = ofertaToCalculate.currentProduct.broadband.planBroadband.key != null ? ofertaToCalculate.currentProduct.broadband.planBroadband.key : '';
					offerFNId = ofertaToCalculate.currentProduct.phone.planPhone.key != null ? ofertaToCalculate.currentProduct.phone.planPhone.key : '';
					offerMVId = ofertaToCalculate.currentProduct.mobile.planMobile.key != null ? ofertaToCalculate.currentProduct.mobile.planMobile.key : '';
					baseId    = ofertaToCalculate.currentProduct.baseId != null ? ofertaToCalculate.currentProduct.baseId : '';
					offerReferenceId = ofertaToCalculate.currentProduct.offerReferenceId != null ? ofertaToCalculate.currentProduct.offerReferenceId : '';
                    */
                    if (ofertaToCalculate.data.currentProduct != null) {
                        if (ofertaToCalculate.data.currentProduct.contractProducts != null && !ofertaToCalculate.data.currentProduct.contractProducts.isEmpty()) {
                            for (NBA_IntegrationModels.ContractProduct product : ofertaToCalculate.data.currentProduct.contractProducts) {
                                if (product.productType == NBA_Constants.TV_PACOTE) {
                                    currentTvId = product.productId != null ? product.productId : '';
                                    offerTVId = product.productId != null ? product.productId : '';
                                    baseId = product.isComboMulti != null ? product.isComboMulti : '';
                                    offerReferenceId = product.mobileOfferName != null ? product.mobileOfferName : '';
                                } else if (product.productType == NBA_Constants.BL_ASSINATURA) {
                                    offerBLId = product.productId != null ? product.productId : '';
                                } else if (product.productType == NBA_Constants.NET_FONE) {
                                    offerFNId = product.productId != null ? product.productId : '';
                                } else if (product.productType == NBA_Constants.MOVEL_ASSINATURA) {
                                    offerMVId = product.productId != null ? product.productId : '';
                                }
                            }
                        }
                    }
                    Map<String, Object> request = new Map<String, Object> ();
                    request.put('operatorId', (caso.ContractNumber__r.CityCode__c == null ? '' : caso.ContractNumber__r.CityCode__c));
                    request.put('contractNumber', (caso.ContractNumber__r.ContractNumber__c == null ? '' : caso.ContractNumber__r.ContractNumber__c));
                    request.put('cityId', cityId);
                    request.put('ibgeCode', ibgeCode);
                    request.put('baseId', baseId);
                    request.put('attendantProfile', attendantProfile);
                    request.put('serviceChannel', channelDetail);
                    request.put('mobileAttendantProfile', mobileAttendantProfile);
                    request.put('mobileServiceChannel', mobileServiceChannel);
                    request.put('caseId', recordId);
                    request.put('source', 'Salesforce');
                    request.put('offerReferenceId', offerReferenceId);
                    request.put('currentTvProduct', currentTvId);
                    request.put('tvOfferId', offerTVId);
                    request.put('broadbandOfferId', offerBLId);
                    request.put('phoneOfferId', offerFNId);
                    request.put('mobileOfferId', offerMVId);
                    NBA_IntegrationModels.NewExtrasResponse response = NBA_IntegrationServices.getAdicionais(request);

                    if (response.data == null) {
                        response.data = new NBA_IntegrationModels.Data();
                    }
                    if (response.data.extras == null) {
                        response.data.extras = new NBA_IntegrationModels.NewExtra();
                    }
                    if (response.data.extras.all != null && !response.data.extras.all.isEmpty()) {
                        List<NBA_IntegrationModels.ContractProduct> lstExtras = new List<NBA_IntegrationModels.ContractProduct>();
                        for (NBA_IntegrationModels.Extras all : response.data.extras.all) {
                            if (all.isAlreadyIncluded != null && all.isAlreadyIncluded != '1') {
                                NBA_IntegrationModels.ContractProduct a = new NBA_IntegrationModels.ContractProduct();
                                a.discount = new NBA_IntegrationModels.ContractProductDiscount();
                                a.productId = all.id;
                                a.productName = all.familyName;
                                a.catalogName = all.name;
                                a.productType = all.type;
                                a.productDetail = all.detail;
                                a.pricing = all.price != null ? Decimal.valueOf(all.price) : 0;
                                a.solicitationType = all.solicitationType;
                                a.detail = all.detail;
                                if (all.promotion != null) {
                                    a.promotionCode = all.promotion.id != null ? all.promotion.id : '';
                                    a.promotionName = all.promotion.name != null ? all.promotion.name : '';
                                    if (all.promotion.discount != null) {
                                        a.deducedPrice = all.promotion.discount.value != null ? all.promotion.discount.value : 0;
                                        a.discount.duration = all.promotion.discount.validFor != null ? Integer.valueOf(all.promotion.discount.validFor) : 0;
                                        a.discount.startDate = all.promotion.discount.startDate != null ? all.promotion.discount.startDate : String.valueOf(Datetime.now());
                                    }
                                }
                                //a.directDebitDiscount
                                //a.digitalBillDiscount
                                //	a.pointId
                                //	a.pointTypeId
                                //	a.hasFidelity
                                //	a.dependentAmount
                                //	a.msisdn
                                //	a.isComboMulti
                                //	a.mobileOfferName
                                //a.newExtra = all.isAlreadyIncluded != null && all.isAlreadyIncluded == '1' ? true : false;
                                a.newExtra = false;

                                // essas variáveis de desconto aparentemente não são usadas, por que popular elas? 
                                // Map<String, Decimal> result = getHoverMovel(ofertaToCalculate.data.currentProduct.contractProducts);
                                // a.descontoPG = result.get('Dependente Desconto PG');
                                // a.descontoBL = result.get('Dependente Desconto BL');
                                
                                ofertaToCalculate.data.currentProduct.contractProducts.add(a);
                            }
                        }
                        //ofertaToCalculate.data.currentProduct.contractProducts = lstExtras;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return calculateOffers(ofertaToCalculate, caso.Id);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static NBA_OfferComparator_CC.Result recalculateOffers_CC(String ofertaToCalculateJSON, String recordId) {
        NBA_IntegrationModels.SearchOffersResponse ofertaToCalculate = (NBA_IntegrationModels.SearchOffersResponse) JSON.deserialize(ofertaToCalculateJSON, NBA_IntegrationModels.SearchOffersResponse.class);
        Case caso;
        //chamar o serviço de adicionais ID OFFER
        //retorno ADICIONAIS
        //metodo de conversão para estrutural atual NEWEXTRAS TO EXTRAS
        System.debug('## Entrou no recalculateOffers_CC ## ');
        Try {
            List<Case> lstCase = [
                    SELECT id, RecordTypeName__c, ContractNumber__r.ContractNumber__c, ContractNumber__r.CityCode__c, ContractNumber__r.PaymentMethod__c,
                            ContractNumber__r.BillDeliveryMethod__c, CallReason__c
                    FROM Case
                    WHERE id = :recordId
            ];
            List<User> lstUser = [SELECT NetServicos__c, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];
            if (!lstUser.isEmpty()) {
                String netServicos = lstUser[0].NetServicos__c != null ? lstUser[0].NetServicos__c : lstUser[0].FederationIdentifier;
                if (!lstCase.isEmpty()) {
                    caso = lstCase[0];
                    hasDiscountAutomaticDebit = String.isNotBlank(caso.ContractNumber__r.PaymentMethod__c) && String.isNotBlank(caso.ContractNumber__r.BillDeliveryMethod__c) ? NBA_Constants.PAYMENTMETHOD.containsIgnoreCase(caso.ContractNumber__r.PaymentMethod__c) && NBA_Constants.BILLDELIVERYMETHOD.containsIgnoreCase(caso.ContractNumber__r.BillDeliveryMethod__c) : false;
                    String currentTvId = '';
                    String offerTVId = '';
                    String offerBLId = '';
                    String offerFNId = '';
                    String offerMVId = '';
                    String offerReferenceId = '';
                    String cityId = ofertaToCalculate.data.subscriberCityCode;
                    String ibgeCode = ofertaToCalculate.data.subscriberIbgeCode;
                    String baseId = '';
                    String channelDetail = ofertaToCalculate.data.channelDetail == null ? '' : ofertaToCalculate.data.channelDetail;
                    String attendantProfile = ofertaToCalculate.data.attendantProfile == null ? '' : ofertaToCalculate.data.attendantProfile;
                    String mobileAttendantProfile = ofertaToCalculate.data.mobileAttendantProfile == null ? '' : ofertaToCalculate.data.mobileAttendantProfile;
                    String mobileServiceChannel = ofertaToCalculate.data.mobileChannelDetail == null ? '' : ofertaToCalculate.data.mobileChannelDetail;
                    String callReason = lstCase[0].CallReason__c == null ? '' : lstCase[0].CallReason__c; //10/09/19 - Kleverton Fortunato - CLAR179
                    if (ofertaToCalculate.data.currentProduct != null) {
                        if (ofertaToCalculate.data.currentProduct.contractProducts != null && !ofertaToCalculate.data.currentProduct.contractProducts.isEmpty()) {
                            for (NBA_IntegrationModels.ContractProduct product : ofertaToCalculate.data.currentProduct.contractProducts) {
                                if (product.productType == NBA_Constants.TV_PACOTE) {
                                    currentTvId = product.productId;
                                }
                            }
                        }
                    }
                    NBA_IntegrationModels.Recommendation oferta = ofertaToCalculate.data.recommendations[2];
                    //for (NBA_IntegrationModels.Recommendation oferta : ofertaToCalculate.data.recommendations) {
                    offerBLId = oferta.nboBroadband.id == null ? '' : oferta.nboBroadband.id;
                    offerFNId = oferta.nboPhone.id == null ? '' : oferta.nboPhone.id;
                    if (!oferta.nboMobile.isEmpty()) {
                        //for (Integer y = 0; y<oferta.nboMobile.size(); y++) {
                        offerMVId = oferta.nboMobile[0].id == null ? '' : oferta.nboMobile[0].id;
                        //}
                    }
                    baseId = oferta.baseId == null ? '' : oferta.baseId;
                    //for (NBA_IntegrationModels.NboTv tv : oferta.nboTv) {
                    offerTVId = oferta.nboTv[0].id == null ? '' : oferta.nboTv[0].id;
                    offerReferenceId = oferta.nboTv[0].offerReferenceId == null ? '' : oferta.nboTv[0].offerReferenceId;
                    //}
                    //}
                    Map<String, Object> request = new Map<String, Object> ();
                    request.put('operatorId', (caso.ContractNumber__r.CityCode__c == null ? '' : caso.ContractNumber__r.CityCode__c));
                    request.put('contractNumber', (caso.ContractNumber__r.ContractNumber__c == null ? '' : caso.ContractNumber__r.ContractNumber__c));
                    request.put('cityId', cityId);
                    request.put('ibgeCode', ibgeCode);
                    request.put('baseId', baseId);
                    request.put('attendantProfile', attendantProfile);
                    request.put('serviceChannel', channelDetail);
                    request.put('mobileAttendantProfile', mobileAttendantProfile);
                    request.put('mobileServiceChannel', mobileServiceChannel);
                    request.put('caseId', recordId);
                    request.put('source', 'Salesforce');
                    request.put('offerReferenceId', offerReferenceId);
                    request.put('currentTvProduct', currentTvId);
                    request.put('tvOfferId', offerTVId);
                    request.put('broadbandOfferId', offerBLId);
                    request.put('phoneOfferId', offerFNId);
                    request.put('mobileOfferId', offerMVId);
                    NBA_IntegrationModels.NewExtrasResponse response = NBA_IntegrationServices.getAdicionais(request);

                    if (response.data == null) {
                        response.data = new NBA_IntegrationModels.Data();
                    }
                    if (response.data.extras == null) {
                        response.data.extras = new NBA_IntegrationModels.NewExtra();
                    }
                    List<NBA_IntegrationModels.NboTv> lstNboTV = new List<NBA_IntegrationModels.NboTv> ();
                    lstNboTV.add(ofertaToCalculate.data.recommendations[2].nboTv[0]);
                    if (ofertaToCalculate.data.recommendations != null && !ofertaToCalculate.data.recommendations.isEmpty()) {
                        if (response.data.extras.TvTechnologies != null && !response.data.extras.TvTechnologies.isEmpty()) {
                            for (NBA_IntegrationModels.TvTechnologies tvTec : response.data.extras.TvTechnologies) {
                                NBA_IntegrationModels.NboTv tv = new NBA_IntegrationModels.NboTv();
                                tv.id = tvTec.id;
                                tv.baseId = '';
                                tv.name = tvTec.name;
                                tv.price = tvTec.price;
                                tv.offerType = '';
                                tv.familyName = tvTec.familyName;
                                tv.solicitationType = tvTec.solicitationType;
                                tv.catalogName = tvTec.catalog;
                                tv.comboProfile = tvTec.comboProfile;
                                tv.technologyId = tvTec.technologyId;
                                tv.promotion = new NBA_IntegrationModels.ProductPromotion();
                                tv.promotion.id = tvTec.promotion.id;
                                tv.promotion.name = tvTec.promotion.name;
                                tv.promotion.description = tvTec.promotion.description;
                                tv.promotion.validFor = tvTec.promotion.validFor;
                                tv.promotion.experimentalFor = tvTec.promotion.experimentalFor;
                                tv.promotion.discount = new NBA_IntegrationModels.Discount();
                                tv.promotion.discount.value = tvTec.promotion.discount.value;
                                tv.promotion.discount.validFor = tvTec.promotion.discount.validFor;
                                tv.validFor = tvTec.validFor != null ? Integer.valueOf(tvTec.validFor) : null;
                                tv.experimentalFor = tvTec.experimentalFor != null ? Integer.valueOf(tvTec.experimentalFor) : null;
                                tv.fee = new NBA_IntegrationModels.Fee();
                                tv.fee.paymentMethod = tvTec.fee.paymentMethod;
                                tv.fee.price = tvTec.fee.price;
                                tv.hasFidelity = String.isNotBlank(tvTec.hasFidelity) ? tvTec.hasFidelity : null;
                                tv.technologyName = tvTec.technologyName;
                                tv.technologyTypeName = tvTec.technologyTypeName;
                                lstNboTV.add(tv);
                            }
                        }
                        List<NBA_IntegrationModels.NboMobile> lstNboMobile = new List<NBA_IntegrationModels.NboMobile> ();
                        lstNboMobile.add(ofertaToCalculate.data.recommendations[2].nboMobile[0]);
                        if (response.data.extras.mobileOffers != null && !response.data.extras.mobileOffers.isEmpty()) {
                            System.debug('## response.data.extras.mobileOffers ' + response.data.extras.mobileOffers);
                            for (NBA_IntegrationModels.MobileOffers mobileAdd : response.data.extras.mobileOffers) {
                                NBA_IntegrationModels.NboMobile mv = new NBA_IntegrationModels.NboMobile();
                                mv.id = mobileAdd.id;
                                //mv.baseId = '';
                                mv.name = mobileAdd.name;
                                mv.price = mobileAdd.price;
                                //mv.offerType = '';
                                mv.familyName = mobileAdd.familyName;
                                mv.solicitationType = mobileAdd.solicitationType;
                                mv.catalogName = mobileAdd.catalog;
                                mv.comboProfile = mobileAdd.comboProfile;
                                mv.technologyId = mobileAdd.technologyId;
                                if (mobileAdd.promotion != null) {
                                    mv.promotion = new NBA_IntegrationModels.ProductPromotion();
                                    mv.promotion.discount = new NBA_IntegrationModels.Discount();
                                    mv.promotion.description = mobileAdd.promotion.description;
                                    if (mobileAdd.promotion.discount != null) {
                                        mv.promotion.discount.value = mobileAdd.promotion.discount.value != null ? mobileAdd.promotion.discount.value : 0;
                                    }
                                    //mv.promotion.experimentalFor = '';
                                    mv.promotion.id = mobileAdd.promotion.id;
                                    mv.promotion.name = mobileAdd.promotion.name;
                                    mv.promotion.RelatedOffer = mobileAdd.promotion.relatedOffer;
                                }
                                //mv.promotion.validFor = '';
                                mv.validFor = mobileAdd.validFor != null ? Integer.valueOf(mobileAdd.validFor) : null;
                                mv.experimentalFor = mobileAdd.experimentalFor != null ? Integer.valueOf(mobileAdd.experimentalFor) : null;
                                if (mobileAdd.membershipFee != null) {
                                    mv.fee.paymentMethod = mobileAdd.membershipFee.paymentMethod != null ? mobileAdd.membershipFee.paymentMethod : '' ;
                                    mv.fee.price = mobileAdd.membershipFee.price != null ? mobileAdd.membershipFee.price : '';
                                }
                                mv.hasFidelity = String.isNotBlank(mobileAdd.hasFidelity) ? mobileAdd.hasFidelity : null;
                                
                                if(mobileAdd?.fidelity?.feeValue != null){
                                    mv.fidelity.feeValue = mobileAdd.fidelity.feeValue;    
                                }
                                if(mobileAdd?.fidelity?.loyaltyMonths != null){                        
                                    mv.fidelity.loyaltyMonths = mobileAdd.fidelity.loyaltyMonths;                        
                                }
                                //mv.earlyTerminationFee = ; // complementar
                                mv.speed = mobileAdd.speed;
                                //mv.svas = mobileAdd;
                                //mv.netsmsProductName = '';
                                //mv.offerName = '';
                                mv.portabilityRequestType = mobileAdd.portabilityRequestType;
                                mv.benefitType = mobileAdd.benefitType;
                                mv.subscriberType = mobileAdd.subscriberType;
                                mv.dependentType = mobileAdd.dependentType;
                                mv.netsalesProductName = ofertaToCalculate.data.recommendations[2].nboMobile[0].netsalesProductName;
                                lstNboMobile.add(mv);
                            }
                        }
                        //## Inclui na lista de oferta os descontos e bonus quando retornados da API de extras
                        if(response.data.extras.mobileDiscounts != null && !response.data.extras.mobileDiscounts.isEmpty()) {
                            ofertaToCalculate.data.recommendations[2].mobileDiscounts2 = response.data.extras.mobileDiscounts;
                        }
                        if (lstNboMobile != null && !lstNboMobile.isEmpty()) {
                            ofertaToCalculate.data.recommendations[2].nboMobile = lstNboMobile;
                        }
                        if (lstNboTV != null && !lstNboTV.isEmpty()) {
                            ofertaToCalculate.data.recommendations[2].nboTv = lstNboTV;
                        }
                        if (ofertaToCalculate.data.recommendations[2].nboTv[0].catalogName != NBA_Constants.SEMPLANO) {
                            ofertaToCalculate.data.recommendations[2].extras = response.data.extras.all;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return calculateOffers(ofertaToCalculate, caso.Id);
    }

    private static NBA_OfferComparator_CC.Result calculateOffers(NBA_IntegrationModels.SearchOffersResponse response, String caseId) {
        NBA_OfferComparator_CC.Result result = new NBA_OfferComparator_CC.Result();
        if (response != null && response.data != null) {
            List<NBA_IntegrationModels.Extras> lstExtras = new List<NBA_IntegrationModels.Extras> ();
            result.currentProduct = getCurrentProduct2(response.data.currentProduct, lstExtras);
            result.status = response.status;
            result.currentProduct = setPenalties(result.currentProduct, caseId);
            //  result.lstOffers = getListOffers(response.data.recommendations, result.currentProduct);
            result.currentProduct.tv[0].addOptions = getAdicionaisTV(result.currentProduct, null, lstExtras, true);
            result.currentProduct.broadband.addOptions = getAdicionaisBandaLarga(result.currentProduct, result.currentProduct, lstExtras, true);
            result.currentProduct.phone.addOptions = getAdicionaisPhone(result.currentProduct);
            result.currentProduct.mobile.addOptions = getAdicionaisMovel(result.currentProduct, result.currentProduct, lstExtras, true);
            result.currentProduct.lstSteps = getTotalDegrades(result.currentProduct, true);
            result.lstOffers = getListOffers(response.data.recommendations, result.currentProduct);
            System.debug('>>>>>>>>>>>' + result.currentProduct);
            System.debug('>>>>>>>>>>>' + response);
            System.debug('>>>>> LST OFFERS ' + result.lstOffers);
        }
        return result;
    }

    // converte de recomendações (api) para ofertas (tela) 
    private static List<NBA_OfferComparator_CC.Offer> getListOffers(List<NBA_IntegrationModels.Recommendation> recommendations, NBA_OfferComparator_CC.Offer current) {
        Integer countTop3 = 0;
        List<NBA_OfferComparator_CC.Offer> lstOffers = new List<NBA_OfferComparator_CC.Offer> ();
        if (recommendations != null && !recommendations.isEmpty()) {
            for (NBA_IntegrationModels.Recommendation recommendation : recommendations) {
                // informações gerais da oferta
                NBA_IntegrationModels.NboMobile titularMobile = getTitularMobile(recommendation.nboMobile);
                recommendation = setActionsMoviment(recommendation);
                NBA_OfferComparator_CC.Offer offer = new NBA_OfferComparator_CC.Offer(recommendation);
                offer.oldPriority = String.isNotBlank(recommendation.oldPriority) ? recommendation.oldPriority : recommendation.priority;
                offer.blindagem = recommendation.nboTv[0].offerType.containsIgnoreCase(NBA_Constants.BLINDAGEM) ||
                        recommendation.nboBroadband.offerType.containsIgnoreCase(NBA_Constants.BLINDAGEM) ||
                        recommendation.nboPhone.offerType.containsIgnoreCase(NBA_Constants.BLINDAGEM) ||
                        titularMobile.offerType.containsIgnoreCase(NBA_Constants.BLINDAGEM);
                offer.combate = recommendation.nboTv[0].offerType.containsIgnoreCase(NBA_Constants.COMBATE) ||
                        recommendation.nboBroadband.offerType.containsIgnoreCase(NBA_Constants.COMBATE) ||
                        recommendation.nboPhone.offerType.containsIgnoreCase(NBA_Constants.COMBATE) ||
                        titularMobile.offerType.containsIgnoreCase(NBA_Constants.COMBATE);
                offer.exclusivo = recommendation.nboTv[0].offerType.containsIgnoreCase(NBA_Constants.EXCLUSIVO) ||
                        recommendation.nboBroadband.offerType.containsIgnoreCase(NBA_Constants.EXCLUSIVO) ||
                        recommendation.nboPhone.offerType.containsIgnoreCase(NBA_Constants.EXCLUSIVO) ||
                        titularMobile.offerType.containsIgnoreCase(NBA_Constants.EXCLUSIVO);
                
                // produto tv
                if (!recommendation.nboTv.isEmpty()) {
                    Boolean first = true;
                    //for (NBA_IntegrationModels.NboTv nboTv : recommendation.nboTv) {
                    for (integer x = 0; x < recommendation.nboTv.size(); x++) {
                        NBA_IntegrationModels.NboTv nboTv = recommendation.nboTv[x];
                        if (nboTv != null) {
                            offer.tv.add(new NBA_OfferComparator_CC.PlanTv());
                            if (nboTv.catalogName == '' || nboTv.catalogName == NBA_Constants.SEMPLANO || nboTv.catalogName == '0') {
                                offer.tv[x].planTv.label = NBA_Constants.NAO_POSSUI;
                                offer.tv[x].comboProfile = nboTv.comboProfile;
                            } else {
                                offer.tv[x].planTv.key = nboTv.id;
                                offer.tv[x].planTv.label = nboTv.catalogName;
                                offer.tv[x].planTv.nameLegacy = nboTv.name;
                                offer.tv[x].technology = recommendation.nboTv[x].technologyTypeName;
                                offer.tv[x].technologyName = recommendation.nboTv[x].technologyName;
                                if (hasDiscountAutomaticDebit) {
                                    offer.tv[x].automaticDebitDiscount = 5;
                                    if (first) {
                                        offer.automaticDebitDiscount += offer.tv[x].automaticDebitDiscount;
                                        first = false;
                                    }
                                }
                                offer.tv[x].familyName = nboTv.familyName;
                                offer.tv[x].comboProfile = nboTv.comboProfile;
                                offer.tv[x].solicitationType = nboTv.solicitationType;
                            }
                            if (nboTv.hasFidelity == NBA_Constants.TEM_FIDELIDADE) {
                                offer.tv[x].planTv.fidelity.hasFidelity = true;
                                if(recommendation.nboTv[x]?.fidelity?.feeValue != null){
                                offer.tv[x].planTv.fidelity.totalPenaltyValue = Decimal.valueOf(recommendation.nboTv[x].fidelity.feeValue);
                                }
                                
                                if(recommendation.nboTv[x]?.fidelity?.loyaltyMonths != null){
                                offer.tv[x].planTv.fidelity.loyaltMonths = Integer.valueOf(recommendation.nboTv[x]?.fidelity?.loyaltyMonths);
                                }
                              
                            }
                            offer.tv[x].planTv.value = nboTv.price;
                            offer.tv[x].totalValue = nboTv.price;
                            offer.tv[x].offerType = nboTv.offerType != null ? nboTv.offerType.trim() : '';
                            if (nboTv.promotion.discount.value != null) {
                                NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                                promo.key = nboTv.promotion.id;
                                promo.discount = nboTv.promotion.discount.value;
                                promo.value = nboTv.price - promo.discount;
                                promo.valid = nboTv.validFor != null && nboTv.validFor > 0 ? nboTv.validFor : null;
                                promo.description = nboTv.promotion.name;
                                promo.label = promo.valid > 0 ? offer.tv[x].planTv.label + ' por ' + promo.valid + ' meses ' : offer.tv[x].planTv.label;
                                offer.tv[x].planTv.value = promo.value;
                                offer.tv[x].planTv.lstPromotions.add(promo);
                            }
                            offer.tv[x].planTv.originalValue = offer.tv[x].planTv.value;
                            offer.tv[x].addOptions = getAdicionaisTV(offer, recommendation, recommendation.extras, false);
                            offer.tv[x].difProductsStep = getProductCostVariation(current.tv[0].planTv.lstPromotions, current.tv[0].planTv.originalValue, offer.tv[x].planTv.lstPromotions, offer.tv[x].totalValue);
                            offer.tv[x].difAdditionalsStep = getAdditionalCostVariation(current.tv[0].additionalTv, offer.tv[x].addOptions.lstAdditionals, current.tv[0].optionalPointsTv, offer.tv[x].optionalPointsTv);
                            //  offer.tv[x].difAdditionals = getDifAdditionals(current.tv[0].additionalTv, offer.tv[x].addOptions.lstAdditionals, current.tv[0].optionalPointsTv, offer.tv[x].optionalPointsTv);
                            offer.tv[x].difAdditionals = getDifAdditionals(current.tv[0].addOptions.lstAdditionals, offer.tv[x].addOptions.lstAdditionals, current.tv[0].optionalPointsTv, offer.tv[x].optionalPointsTv);
                        }
                    }
                } else {
                    offer.tv[0].planTv.label = NBA_Constants.NAO_POSSUI;
                }
                
                // produto bl
                if (recommendation.nboBroadband != null) {
                    offer.broadband = new NBA_OfferComparator_CC.PlanBroadband();
                    if (recommendation.nboBroadband.catalogName == '' || recommendation.nboBroadband.catalogName == NBA_Constants.SEMPLANO || recommendation.nboBroadband.catalogName == '0') {
                        offer.broadband.planBroadband.label = NBA_Constants.NAO_POSSUI;
                    } else {
                        offer.broadband.planBroadband.key = recommendation.nboBroadband.id;
                        offer.broadband.planBroadband.label = recommendation.nboBroadband.catalogName;
                        offer.broadband.planBroadband.nameLegacy = recommendation.nboBroadband.name;
                        if (hasDiscountAutomaticDebit) {
                            offer.broadband.automaticDebitDiscount = 5;
                            offer.automaticDebitDiscount += offer.broadband.automaticDebitDiscount;
                        }
                    }
                    offer.broadband.familyName = recommendation.nboBroadband.familyName;
                    offer.broadband.solicitationType = recommendation.nboBroadband.solicitationType;
                    offer.broadband.comboProfile = recommendation.nboBroadband.comboProfile;
                    if (recommendation.nboBroadband.hasFidelity == NBA_Constants.TEM_FIDELIDADE) {
                        offer.broadband.planBroadband.fidelity.hasFidelity = true;
						if(recommendation.nboBroadband?.fidelity?.feeValue != null){                        
                        offer.broadband.planBroadband.fidelity.totalPenaltyValue = Decimal.valueOf(recommendation.nboBroadband.fidelity.feeValue);
                        }
                        if(recommendation.nboBroadband?.fidelity?.loyaltyMonths != null){                        
                        offer.broadband.planBroadband.fidelity.loyaltMonths = Integer.valueOf(recommendation.nboBroadband.fidelity.loyaltyMonths);                       
                    }
                    }
                    offer.broadband.planBroadband.value = recommendation.nboBroadband.price;
                    offer.broadband.totalValue = recommendation.nboBroadband.price;
                    offer.broadband.offerType = recommendation.nboBroadband.offerType != null ? recommendation.nboBroadband.offerType.trim() : '' ;
                    if (recommendation.nboBroadband.promotion.discount.value != null) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.discount = recommendation.nboBroadband.promotion.discount.value;
                        promo.value = recommendation.nboBroadband.price - promo.discount;
                        promo.valid = recommendation.nboBroadband.validFor != null && recommendation.nboBroadband.validFor > 0 ? recommendation.nboBroadband.validFor : null;
                        promo.description = recommendation.nboBroadband.promotion.name;
                        promo.label = promo.valid > 0 ? offer.broadband.planBroadband.label + ' por ' + promo.valid + ' meses ' : offer.broadband.planBroadband.label;
                        offer.broadband.planBroadband.value = promo.value;
                        offer.broadband.planBroadband.lstPromotions.add(promo);
                    }
                    offer.broadband.planBroadband.originalValue = offer.broadband.planBroadband.value;
                    offer.broadband.additionalBroadband = current.broadband.additionalBroadband;
                    offer.broadband.addOptions = getAdicionaisBandaLarga(current, offer, recommendation.extras, false);
                    offer.broadband.difProductsStep = getProductCostVariation(current.broadband.planBroadband.lstPromotions, current.broadband.planBroadband.originalValue , offer.broadband.planBroadband.lstPromotions, offer.broadband.totalValue);
                    offer.broadband.difAdditionalsStep = getAdditionalCostVariation(current.broadband.additionalBroadband, offer.broadband.addOptions.lstAdditionals, null, null);
                    //  offer.broadband.difAdditionals = getDifAdditionals(current.broadband.additionalBroadband, offer.broadband.addOptions.lstAdditionals, null, null);
                    offer.broadband.difAdditionals = getDifAdditionals(current.broadband.addOptions.lstAdditionals, offer.broadband.addOptions.lstAdditionals, null, null);
                } else {
                    offer.broadband.planBroadband.label = NBA_Constants.NAO_POSSUI;
                }
                
                // produto fone
                if (recommendation.nboPhone != null) {
                    offer.phone = new NBA_OfferComparator_CC.PlanPhone();
                    if (recommendation.nboPhone.catalogName == '' || recommendation.nboPhone.catalogName == NBA_Constants.SEMPLANO || recommendation.nboPhone.catalogName == '0') {
                        offer.phone.planPhone.label = NBA_Constants.NAO_POSSUI;
                    } else {
                        offer.phone.planPhone.key = recommendation.nboPhone.id;
                        offer.phone.planPhone.label = recommendation.nboPhone.catalogName;
                        offer.phone.planPhone.nameLegacy = recommendation.nboPhone.name;
                    }
                    offer.phone.familyName = recommendation.nboPhone.familyName;
                    offer.phone.solicitationType = recommendation.nboPhone.solicitationType;
                    offer.phone.comboProfile = recommendation.nboPhone.comboProfile;
                    if (recommendation.nboPhone.hasFidelity == NBA_Constants.TEM_FIDELIDADE) {
                        offer.phone.planPhone.fidelity.hasFidelity = true;
                        if(recommendation.nboPhone?.fidelity?.feeValue != null){
                        offer.phone.planPhone.fidelity.totalPenaltyValue = Decimal.valueOf(recommendation.nboPhone.fidelity.feeValue);    
                        }
                        if(recommendation.nboPhone?.fidelity?.loyaltyMonths != null){                        
                        offer.phone.planPhone.fidelity.loyaltMonths = Integer.valueOf(recommendation.nboPhone.fidelity.loyaltyMonths);                        
                        }
                    }
                    offer.phone.planPhone.value = recommendation.nboPhone.price;
                    offer.phone.totalValue = recommendation.nboPhone.price;
                    offer.phone.offerType = recommendation.nboPhone.offerType != null ? recommendation.nboPhone.offerType.trim() : '';
                    if (recommendation.nboPhone.promotion.discount.value != null) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.discount = recommendation.nboPhone.promotion.discount.value;
                        promo.value = recommendation.nboPhone.price - promo.discount;
                        promo.valid = recommendation.nboPhone.validFor != null && recommendation.nboPhone.validFor > 0 ? recommendation.nboPhone.validFor : null;
                        //promo.label = recommendation.nboPhone.promotion.name;
                        promo.description = recommendation.nboPhone.promotion.name;
                        if (promo.valid > 0) {
                            promo.label = offer.phone.planPhone.label + ' por ' + promo.valid + ' meses ';
                        } else {
                            promo.label = offer.phone.planPhone.label;
                        }
                        offer.phone.planPhone.value = promo.value;
                        offer.phone.planPhone.lstPromotions.add(promo);
                    }
                    offer.phone.planPhone.originalValue = offer.phone.planPhone.value;
                    offer.phone.additionalPhone = current.phone.additionalPhone;
                    offer.phone.addOptions = getAdicionaisPhone(current);
                    offer.phone.difProductsStep = getProductCostVariation(current.phone.planPhone.lstPromotions, current.phone.planPhone.originalValue, offer.phone.planPhone.lstPromotions, offer.phone.totalValue);
                } else {
                    offer.phone.planPhone.label = NBA_Constants.NAO_POSSUI;
                }
                
                // produto móvel
                List<Dependentes> lstDependentes = new List<Dependentes> ();
                List<Dependentes> lstTitularesOfferta = new List<Dependentes>();
                integer numberDadosVoz = 0;
                Integer numberDados = 0;
                Integer numberControle = 0;
                Decimal totalDadosVoz = 0.0;
                Decimal totalDados = 0.0;
                Decimal totalControle = 0.0;
                Integer newId = 0;
                if (!recommendation.nboMobile.isEmpty()) {
                    offer.mobile = new NBA_OfferComparator_CC.PlanMobile();
                    for (integer x = 0; x < recommendation.nboMobile.size(); x++) {
                        NBA_IntegrationModels.NboMobile nboMobile = recommendation.nboMobile[x];

                        if(nboMobile.name=='MANTER')
                            nboMobile.price = current.mobile.planMobile.value;
                        
                        if (x == 0) {
                            offer.mobile.numeroMaxDep = nboMobile.dependentAmount != null ? Integer.valueOf(nboMobile.dependentAmount) : 0 ;  //Alexandre Amaro - numero max de Dependentes
                            if (nboMobile.svas != null) {
                                offer.mobile.svas = nboMobile.svas.split('\\|');
                            }
                            // SE FOR TITULAR
                            //if (nboMobile.subscriberType != null && (nboMobile.subscriberType == '2' || nboMobile.subscriberType == '0')  && nboMobile.offerType != null) {
                            if (nboMobile.catalogName == '' || nboMobile.catalogName == NBA_Constants.SEMPLANO || nboMobile.catalogName == '0') {
                                offer.mobile.planMobile.label = NBA_Constants.NAO_POSSUI;
                            } else {
                                offer.mobile.listaDependentesMobilePosse.addAll(current.mobile.listaDependentesMobilePosse);

                                offer.mobile.numeroDependentesVozDados = offer.mobile.numeroDependentesVozDadosOriginal = current.mobile.numeroDependentesVozDados;
                                offer.mobile.totalVozDados = offer.mobile.totalVozDadosOriginal = current.mobile.totalVozDados;
        
                                offer.mobile.numeroDependentesDados = offer.mobile.numeroDependentesDadosOriginal = current.mobile.numeroDependentesDados;
                                offer.mobile.totalDados = offer.mobile.totalDadosOriginal = current.mobile.totalDados;

                                offer.mobile.numeroDependentesControle = offer.mobile.numeroDependentesControleOriginal = current.mobile.numeroDependentesControle;
                                offer.mobile.totalControle = offer.mobile.totalControleOriginal = current.mobile.totalControle;

                                offer.mobile.planMobile.key = nboMobile.id;
                                offer.mobile.planMobile.label = nboMobile.name;
                                offer.mobile.planMobile.nameLegacy = nboMobile.catalogName;
                                if (hasDiscountAutomaticDebit) { 
                                    if(nboMobile.name == NBA_Constants.MOVIMENTO_MANTER)
                                        offer.mobile.automaticDebitDiscount = current.mobile.automaticDebitDiscount;
                                    else
                                        offer.mobile.automaticDebitDiscount = (nboMobile.technologyId=='POS_PAGO' ? 10 : (nboMobile.technologyId=='CONTROLE' ? 5 : 0));
                                    offer.automaticDebitDiscount += offer.mobile.automaticDebitDiscount;
                                }
                                offer.mobile.dependentslMobile = current.mobile.dependentslMobile;
                            }
                            offer.mobile.familyName = nboMobile.familyName;
                            offer.mobile.solicitationType = nboMobile.solicitationType;
                            offer.mobile.comboProfile = nboMobile.comboProfile;
                            offer.mobile.planMobile.value = nboMobile.price;
                            offer.mobile.totalValue = nboMobile.price;
                            offer.mobile.netsalesProductName = nboMobile.netsalesProductName;
                            offer.mobile.offerType = nboMobile.offerType != null ? nboMobile.offerType.trim() : '';
                            offer.mobile.titularMobile.nomePlano = nboMobile.catalogName; // Alexandre Amaro 22-08-19
                            offer.mobile.name = nboMobile.name;
                            offer.mobile.speed = nboMobile.speed;
                            offer.mobile.titularMobile.valorProduto = nboMobile.price;
                            offer.mobile.technology = nboMobile.technologyId;
                            if (nboMobile.hasFidelity == NBA_Constants.TEM_FIDELIDADE) {
                                offer.mobile.planMobile.fidelity.hasFidelity = true;
                            if(nboMobile?.fidelity?.feeValue != null){
                                offer.mobile.planMobile.fidelity.totalPenaltyValue = Decimal.valueOf(nboMobile.fidelity.feeValue);    
                            }
                            if(nboMobile?.fidelity?.loyaltyMonths != null){                        
                                offer.mobile.planMobile.fidelity.loyaltMonths = Integer.valueOf(nboMobile.fidelity.loyaltyMonths);                        
                            }
                            }
                            if (nboMobile.promotion.discount.value != null && nboMobile.promotion.name != null && nboMobile.promotion.discount.value > 0) {
                                NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                                promo.discount = nboMobile.promotion.discount.value;
                                promo.value = nboMobile.price - promo.discount;
                                promo.valid = 12;
                                //promo.label = nboMobile.promotion.name;
                                promo.description = nboMobile.promotion.name;
                                promo.label = nboMobile.promotion.name;  //promo.valid > 0 ? offer.mobile.planMobile.label + ' por ' + promo.valid + ' meses ' : offer.mobile.planMobile.label;
                                offer.mobile.validFor = '12';
                                offer.mobile.titularMobile.validFor = 12;
                                offer.mobile.planMobile.value = promo.value;
                                offer.mobile.titularMobile.promoSelected = nboMobile.promotion != null && nboMobile.promotion.name != null ? nboMobile.promotion.name : '' ;
                                offer.mobile.titularMobile.discountPromo = nboMobile.promotion != null && nboMobile.promotion.discount != null && nboMobile.promotion.discount.value != null ? nboMobile.promotion.discount.value : 0;
                                offer.mobile.planMobile.lstPromotions.add(promo);
                            }
                            if (String.isNotBlank(nboMobile.svas)) {
                                offer.mobile.titularMobile.listBeneficiosDoPlano = nboMobile.svas.split('\\|');
                            }
                            offer.mobile.planMobile.originalValue = offer.mobile.planMobile.value;
                            offer.mobile.additionalMobile = current.mobile.additionalMobile;
                            offer.mobile.addOptions = getAdicionaisMovel(current, offer, recommendation.extras, false);
                            offer.mobile.difProductsStep = getProductCostVariation(current.mobile.planMobile.lstPromotions, current.mobile.planMobile.originalValue, offer.mobile.planMobile.lstPromotions, offer.mobile.totalValue);
                            offer.mobile.difAdditionalsStep = getAdditionalCostVariation(current.mobile.additionalMobile, offer.mobile.addOptions.lstAdditionals, null, null);
                            //    offer.mobile.difAdditionals				= getDifAdditionals(current.mobile.additionalMobile, offer.mobile.addOptions.lstAdditionals, null, null);
                            offer.mobile.difAdditionals = getDifAdditionals(current.mobile.addOptions.lstAdditionals, offer.mobile.addOptions.lstAdditionals, null, null);
                            //US114 - SP14 - Kleverton Fortunato
                            offer.mobile.difDependentsStep = getDependentsCostVariation(current.mobile.dependentslMobile, offer.mobile.addOptions.lstAdditionals, null, null);
                            offer.mobile.difDependents = getDifDependents(current.mobile.additionalMobile, offer.mobile.addOptions.lstAdditionals, null, null);
                            
                            //Fim da Alteracao - US114 - Kleverton Fortunato
                            Dependentes dep = new Dependentes();
                            dep.netsalesProductName = nboMobile.netsalesProductName;
                            dep.technologyId = nboMobile.technologyId;
                            dep.comboProfile = nboMobile.comboProfile;
                            dep.promoSelected = nboMobile.promotion.name;
                            dep.valorProduto = nboMobile.price;
                            dep.nomePlano = nboMobile.dependentType;
                            dep.portabilityRequestType = nboMobile.portabilityRequestType;
                            dep.key = nboMobile.id;
                            dep.newId = String.valueOf(newId);
                            dep.validFor = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null && nboMobile.promotion.discount.value > 0) ? 12 : 0;
                            dep.discountPromo = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null) ? nboMobile.promotion.discount.value : 0;
                            newId++;
                            if (dep.nomePlano == 'POS_PAGO') {
                                dep.nomePlano = 'DADOS + VOZ';
                            } 
                            else if (dep.nomePlano == 'BANDA_LARGA') {
                                dep.nomePlano = 'DADOS';
                            }
                            else if (dep.nomePlano == 'CONTROLE') {
                                dep.nomePlano = 'CONTROLE';
                            }
                            if (nboMobile.promotion != null && nboMobile.promotion.relatedOffer != null) {
                                dep.listBeneficiosDoPlano = formatMobileServiceValidFor(nboMobile.promotion.relatedOffer.split('\\|'));
                            }
                            //Sprint 03 OA, Bonus e Desconto
                            // if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'BONUS'){
                            //     BonusDesconto bd = new BonusDesconto();
                            //     bd.check = false;
                            //     bd.disabled = false;
                            //     bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('GB', ''));
                            //     offer.mobile.listBonusTitular.add(bd);
                            // }else if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'DESCONTO'){
                            //     BonusDesconto bd = new BonusDesconto();
                            //     bd.check = false;
                            //     bd.disabled = false;
                            //     bd.multa = Decimal.valueOf( nboMobile.mobileDiscount.feeValue.replaceAll(',' , '.'));
                            //     bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('%', ''));
                            //     offer.mobile.listDescontoTitular.add(bd);
                            // }
                            lstTitularesOfferta.add(dep);
                            // SE FOR DEPENDENTES
                        }

                        else if (nboMobile.portabilityRequestType=='1' || nboMobile.portabilityRequestType=='8') { // antigo: subscriberType = 1 ou 2 | antigo: dependentType = -1
                            Dependentes dep = new Dependentes();
                            dep.netsalesProductName = nboMobile.benefitType;
                            dep.technologyId = nboMobile.technologyId;
                            dep.comboProfile = nboMobile.comboProfile;
                            dep.promoSelected = nboMobile.promotion.name;
                            dep.valorProduto = nboMobile.price;
                            dep.nomePlano = nboMobile.dependentType;
                            dep.portabilityRequestType = nboMobile.portabilityRequestType;
                            dep.key = nboMobile.id;
                            dep.newId = String.valueOf(newId);
                            dep.validFor = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null && nboMobile.promotion.discount.value > 0) ? 12 : 0;
                            dep.discountPromo = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null) ? nboMobile.promotion.discount.value : 0;                           
                            newId++;
                            if (dep.nomePlano == 'POS_PAGO') {
                                dep.nomePlano = 'DADOS + VOZ';
                            } 
                            else if (dep.nomePlano == 'BANDA_LARGA') {
                                dep.nomePlano = 'DADOS';
                            }
                            else if (dep.nomePlano == 'CONTROLE') {
                                dep.nomePlano = 'CONTROLE';
                            }
                            if (nboMobile.promotion != null && nboMobile.promotion.relatedOffer != null) {
                                dep.listBeneficiosDoPlano = formatMobileServiceValidFor(nboMobile.promotion.relatedOffer.split('\\|'));
                            }
                            lstTitularesOfferta.add(dep);
                        }

                        else if (nboMobile.portabilityRequestType=='2' || nboMobile.portabilityRequestType=='9'){ // antigo: subscriberType = 3, antigo: dependentType != -1
                            Dependentes dep = new Dependentes();
                            dep.technologyId = nboMobile.technologyId;
                            dep.comboProfile = nboMobile.comboProfile;
                            dep.promoSelected = nboMobile.promotion.name;
                            dep.valorProduto = nboMobile.price;
                            dep.nomePlano = nboMobile.dependentType;
                            dep.portabilityRequestType = nboMobile.portabilityRequestType;
                            dep.key = nboMobile.id;
                            dep.newId = String.valueOf(newId);
                            dep.fidelity = nboMobile.hasFidelity != null && String.isNotBlank(nboMobile.hasFidelity) && !nboMobile.hasFidelity.equalsIgnoreCase('0') ? true : false;
                            dep.dependentType = nboMobile.dependentType;
                            dep.nameLegacy = nboMobile.benefitType;
                            dep.productName = nboMobile.catalogName;
                            dep.promotionName = nboMobile.promotion.name;
                            dep.catalogName = nboMobile.catalogName;
                            dep.validFor = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null && nboMobile.promotion.discount.value > 0) ? 12 : 0;
                            dep.discountPromo = (nboMobile.name!='MANTER' && nboMobile.promotion.discount.value != null) ? nboMobile.promotion.discount.value : 0;                           
                            dep.familyName = nboMobile.familyName;
                            newId++;
                            if (dep.nomePlano == 'POS_PAGO') {
                                dep.nomePlano = 'DADOS + VOZ';
                            } 
                            else if (dep.nomePlano == 'BANDA_LARGA') {
                                dep.nomePlano = 'DADOS';
                            }
                            else if (dep.nomePlano == 'CONTROLE') {
                                dep.nomePlano = 'CONTROLE';
                            }
                            if (nboMobile.promotion != null && nboMobile.promotion.relatedOffer != null) {
                                dep.listBeneficiosDoPlano = formatMobileServiceValidFor(nboMobile.promotion.relatedOffer.split('\\|'));
                            }
                            offer.mobile.listaDependentesMobile.add(dep);
                            
                            //Sprint 03 OA, Bonus e Desconto
                            System.debug('## CHEGOU DESCONTO ' + nboMobile.mobileDiscounts);
                            //  if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'BONUS'){
                            //     BonusDesconto bd = new BonusDesconto();
                            //     bd.check = false;
                            //     bd.disabled = false;
                            //     bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('GB', ''));
                            //     offer.mobile.listBonusDependente.add(bd);
                            // }else if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'DESCONTO'){
                            //     BonusDesconto bd = new BonusDesconto();
                            //     bd.check = false;
                            //     bd.disabled = false;
                            //     bd.multa = Decimal.valueOf( nboMobile.mobileDiscount.feeValue.replaceAll(',' , '.'));
                            //     bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('%' , ''));
                            //     offer.mobile.listDescontoDependente.add(bd);
                            // }
                            lstDependentes.add(dep);
                        }

                        //## Trata a lista de oferta os descontos e bonus quando retornados da API de ofertas (TOP3)
                        System.debug('#### nboMobile : ' + JSON.Serialize(nboMobile.mobileDiscounts));
                        if (nboMobile.mobileDiscounts != null && !nboMobile.mobileDiscounts.isEmpty()) {
                            for (NBA_IntegrationModels.MobileDiscount discounts : nboMobile.mobileDiscounts) {
                                if (discounts.pointType != null && discounts.pointType == 'TITULAR') {
                                    if (discounts.offerType != null && discounts.offerType == 'BONUS') {
                                        BonusDesconto bd = new BonusDesconto();
                                        bd.check = false;
                                        bd.disabled = false;
                                        bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('GB', ''));
                                        bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                        offer.mobile.listBonusTitular.add(bd);
                                        System.debug('BONUS TITULAR >>>>> ' + bd);
                                        System.debug('list BONUS TITULAR >>>>> ' + offer.mobile);
                                    } else if (discounts.offerType != null && discounts.offerType == 'DESCONTO') {
                                        BonusDesconto bd = new BonusDesconto();
                                        bd.check = false;
                                        bd.disabled = false;
                                        bd.multa = Decimal.valueOf(discounts.feeValue.replaceAll(',', '.'));
                                        bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('%', ''));
                                        bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                        offer.mobile.listDescontoTitular.add(bd);
                                        System.debug('DESCONTO TITULAR >>>>> ' + bd);
                                    }
                                } else if (discounts.pointType != null && discounts.pointType == 'DEPENDENTE') {
                                    if (discounts.offerType != null && discounts.offerType == 'BONUS') {
                                        BonusDesconto bd = new BonusDesconto();
                                        bd.check = false;
                                        bd.disabled = false;
                                        bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('GB', ''));
                                        bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                        offer.mobile.listBonusDependente.add(bd);
                                        System.debug('BONUS DEPENDENTE >>>>> ' + bd);
                                    } else if (discounts.offerType != null && discounts.offerType == 'DESCONTO') {
                                        BonusDesconto bd = new BonusDesconto();
                                        bd.check = false;
                                        bd.disabled = false;
                                        bd.multa = Decimal.valueOf(discounts.feeValue.replaceAll(',', '.'));
                                        bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('%', ''));
                                        bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                        offer.mobile.listDescontoDependente.add(bd);
                                        System.debug('DESCONTO DEPENDENTE >>>>> ' + bd);
                                    }
                                }
                            }
                        }

                        offer.mobile.TotalDependentes = offer.mobile.totalVozDados + offer.mobile.totalDados + offer.mobile.totalControle;
                    }
                    offer.mobile.listaDependentesMobile = lstDependentes;
                    offer.mobile.titularesOferta = lstTitularesOfferta;
                }

                else {
                    offer.mobile.planMobile.label = NBA_Constants.NAO_POSSUI;
                }
                // bônus e descontos
                //## Trata a lista de oferta os descontos e bonus quando retornados da API de extras
                if (recommendation.mobileDiscounts2 != null && !recommendation.mobileDiscounts2.isEmpty()) {
                    for (NBA_IntegrationModels.MobileDiscount discounts : recommendation.mobileDiscounts2) {
                        if (discounts.pointType != null && discounts.pointType == 'TITULAR') {
                            if (discounts.offerType != null && discounts.offerType == 'BONUS') {
                                BonusDesconto bd = new BonusDesconto();
                                bd.check = false;
                                bd.disabled = false;
                                bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('GB', ''));
                                bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                offer.mobile.listBonusTitular.add(bd);
                                System.debug('BONUS TITULAR >>>>> ' + bd);
                                System.debug('list BONUS TITULAR >>>>> ' + offer.mobile);
                            } else if (discounts.offerType != null && discounts.offerType == 'DESCONTO') {
                                BonusDesconto bd = new BonusDesconto();
                                bd.check = false;
                                bd.disabled = false;
                                bd.multa = Decimal.valueOf(discounts.feeValue.replaceAll(',', '.'));
                                bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('%', ''));
                                bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                offer.mobile.listDescontoTitular.add(bd);
                                System.debug('DESCONTO TITULAR >>>>> ' + bd);
                            }
                        } else if (discounts.pointType != null && discounts.pointType == 'DEPENDENTE') {
                            if (discounts.offerType != null && discounts.offerType == 'BONUS') {
                                BonusDesconto bd = new BonusDesconto();
                                bd.check = false;
                                bd.disabled = false;
                                bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('GB', ''));
                                bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                offer.mobile.listBonusDependente.add(bd);
                                System.debug('BONUS DEPENDENTE >>>>> ' + bd);
                            } else if (discounts.offerType != null && discounts.offerType == 'DESCONTO') {
                                BonusDesconto bd = new BonusDesconto();
                                bd.check = false;
                                bd.disabled = false;
                                bd.multa = Decimal.valueOf(discounts.feeValue.replaceAll(',', '.'));
                                bd.valor = Decimal.valueOf(discounts.benefitOffer.replaceAll('%', ''));
                                bd.valorRPA = discounts.offerName != null ? discounts.offerName : '';
                                offer.mobile.listDescontoDependente.add(bd);
                                System.debug('DESCONTO DEPENDENTE >>>>> ' + bd);
                            }
                        }
                    }
                }
                offer.totalValue = getTotalValue(current, offer);
                offer.difTotal = offer.totalValue - current.totalValue;
                offer.lstUpgradeFee = getUpgradeFee(recommendation, offer, current);
                offer.lstUpgradeFeeFiltered = filterLstFee(offer, offer.lstUpgradeFee);
                offer.lstMembershipFee = getMembershipFee(recommendation, offer, current);
                offer.lstMembershipFeeFiltered = filterLstFee(offer, offer.lstMembershipFee);
                offer.lstSteps = getTotalDegradesv2(offer, false);
                getTotalCostVariation(current, offer);
                offer.difTotalStep = getDifTotalStep(current, offer);
                lstOffers.add(offer);
                
                if (current != null && offer.mobile != null) {
                    if (offer.mobile.planMobile.label == NBA_Constants.MOVIMENTO_MANTER) {
                        offer.mobile.mouseOverValorSemDesconto                  = current.mobile.mouseOverValorSemDesconto;
                        offer.mobile.mouseOverTitularSemDesconto                = current.mobile.mouseOverTitularSemDesconto;
                        offer.mobile.descontoTitular                            = current.mobile.descontoTitular;
                    }
                        offer.mobile.mouseOverDependenteComDescontoPG           = current.mobile.mouseOverDependenteComDescontoPG;
                        offer.mobile.mouseOverDependenteSemDescontoPG           = current.mobile.mouseOverDependenteSemDescontoPG;
                        offer.mobile.descontoDependentePG                       = current.mobile.descontoDependentePG;
                        offer.mobile.mouseOverDependenteComDescontoBL           = current.mobile.mouseOverDependenteComDescontoBL;
                        offer.mobile.mouseOverDependenteSemDescontoBL           = current.mobile.mouseOverDependenteSemDescontoBL;
                        offer.mobile.descontoDependenteBL                       = current.mobile.descontoDependenteBL;
                        offer.mobile.mouseOverDependenteComDescontoControle     = current.mobile.mouseOverDependenteComDescontoControle;
                        offer.mobile.mouseOverDependenteSemDescontoControle     = current.mobile.mouseOverDependenteSemDescontoControle;
                        offer.mobile.descontoDependenteControle                 = current.mobile.descontoDependenteControle;
                }
                
                System.debug('OFFER ' + offer);
                System.debug('current ' + current);
                // faz os cálculos apenas para as 3 primeiras ofertas
                if (countTop3 > 1) {
                    break;
                } else {
                    countTop3++;
                }
            }
        }
        else {
            throw new SemResultadosRetornadosException('Não foi identificada nenhuma oferta para esse cliente');
        }
        System.debug('LIST OFFERS ' + lstOffers);
        return lstOffers;
    }

    public static List<String> formatMobileServiceValidFor(List<String> services){
       if(services!=null){
           for(Integer index=0; index<services.size(); index++){
                Matcher matcher = Pattern.compile('(.*) ; QTD MESES DESCONTO ([0-9]+)(.*)').matcher(services[index]);
                if(matcher.matches()) services[index] = matcher.group(1) + (Integer.valueOf(matcher.group(2))>0 ? ' por ' + matcher.group(2) + ' mes(es)' : '');
           }
        }
        return services;
    }

    public static NBA_IntegrationModels.NboMobile getTitularMobile(List<NBA_IntegrationModels.NboMobile> lstMobile) {
        NBA_IntegrationModels.NboMobile titular = new NBA_IntegrationModels.NboMobile();
        if (lstMobile != null && !lstMobile.isEmpty()) {
            for (NBA_IntegrationModels.NboMobile mobile : lstMobile) {
                if (mobile.subscriberType != null && mobile.subscriberType == '2' && mobile.offerType != null) {
                    titular = mobile;
                }
            }
        }
        return titular;
    }
    /**
    * @description
    * @param currentProdutoData
    * @param extras
    */
    @TestVisible
    private static NBA_OfferComparator_CC.Offer getCurrentProduct2(NBA_IntegrationModels.CurrentProductData currentProdutoData,
            List<NBA_IntegrationModels.Extras> extras) {
        System.debug('posse atual ' + currentProdutoData);
        NBA_OfferComparator_CC.Offer currentProduct = new NBA_OfferComparator_CC.Offer();
        currentProduct.tv = new List<NBA_OfferComparator_CC.PlanTv>();
        currentProduct.tv.add(new NBA_OfferComparator_CC.PlanTv());
        currentProduct.broadband = new NBA_OfferComparator_CC.PlanBroadband();
        currentProduct.phone = new NBA_OfferComparator_CC.PlanPhone();
        currentProduct.mobile = new NBA_OfferComparator_CC.PlanMobile();
        List<Dependentes> lstDependentes = new List<Dependentes> ();
        if (currentProdutoData != null && currentProdutoData.contractProducts != null && !currentProdutoData.contractProducts.isEmpty()) {
            Integer quantityOptionalPoints = 0;
            Integer quantityFreeOptionalPoints = 0;
            Set<String> msisdnDependentes = new Set<String>();
            getHoverMovel(currentProdutoData.contractProducts, currentProduct);

            for (NBA_IntegrationModels.ContractProduct product : currentProdutoData.contractProducts) {
                if (currentProduct != null) {
                    if (!currentProduct.hasDiscountAutomaticDebit) {
                        currentProduct.hasDiscountAutomaticDebit = String.isNotBlank(product.digitalBillDiscount) && String.isNotBlank(product.directDebitDiscount);
                    }
                }
                //TV
                if (product.productType == NBA_Constants.TV_PACOTE) {
                    if (product.catalogName == '' || product.catalogName == NBA_Constants.SEMPLANO) {
                        currentProduct.tv[0].planTv.label = NBA_Constants.NAO_POSSUI;
                    } else if (product.catalogName != null && product.catalogName.contains(NBA_Constants.ACESSO_VIRTUA)) {
                        currentProduct.tv[0].planTv.label = NBA_Constants.NAO_POSSUI;
                        currentProduct.tv[0].planTv.nameLegacy = NBA_Constants.ACESSO_VIRTUA;
                        currentProduct.tv[0].planTv.typeAcessoVirtua = product.catalogName;
                    } else {
                        currentProduct.tv[0].planTv.label = product.catalogName;
                        currentProduct.tv[0].planTv.nameLegacy = product.productName;
                        if (currentProduct.hasDiscountAutomaticDebit) {
                            currentProduct.tv[0].automaticDebitDiscount = String.isNotBlank(product.digitalBillDiscount) && String.isNotBlank(product.directDebitDiscount) ? Decimal.valueOf(product.digitalBillDiscount) + Decimal.valueOf(product.directDebitDiscount) : 0;
                            currentProduct.automaticDebitDiscount += currentProduct.tv[0].automaticDebitDiscount;
                        }
                    }
                    currentProduct.tv[0].planTv.key = product.productId;
                    currentProduct.baseId = product.isComboMulti;
                    currentProduct.offerReferenceId = product.mobileOfferName;
                    currentProduct.tv[0].planTv.fidelity = new Fidelity();
                    currentProduct.tv[0].planTv.fidelity.startDate = (product.discount != null ? convertDatetimeToDate(product.discount.startDate) : null);
                    currentProduct.tv[0].planTv.fidelity.hasFidelity = product.hasFidelity == NBA_Constants.HAS_FIDELITY_CURRENT;
                    currentProduct.tv[0].planTv.originalValue = product.pricing;
                    currentProduct.tv[0].planTv.value = currentProduct.tv[0].planTv.originalValue;
					currentProduct.tv[0].planTv.pointId = product.pointId;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.key = product.productId;
                        promo.discount = product.deducedPrice;
                        promo.value = currentProduct.tv[0].planTv.originalValue - product.deducedPrice;
                        promo.description = product.promotionName;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration); //Dúvida
                        promo.label = promo.valid > 0 ? currentProduct.tv[0].planTv.label + ' por ' + promo.valid + ' meses ' : currentProduct.tv[0].planTv.label; //Dúvida
                        currentProduct.tv[0].planTv.value = promo.value;
                        currentProduct.tv[0].planTv.lstPromotions.add(promo);
                        if (String.isNotBlank(currentProduct.tv[0].difProductsStep.label) && Integer.valueOf(currentProduct.tv[0].difProductsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.tv[0].difProductsStep.label)) {
                            currentProduct.tv[0].difProductsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.tv[0].difProductsStep.label = String.valueOf(promo.valid);
                        }
                        currentProduct.tv[0].difProductsStep.value = currentProduct.tv[0].planTv.originalValue;
                    }
                    currentProduct.totalValue += currentProduct.tv[0].planTv.value;
                } else if (product.productType == NBA_Constants.TV_A_LA_CARTE) {
                    NBA_IntegrationModels.Extras ex = NBA_OfferComparator_CC.fillAdditional(product);
                    extras.add(ex);
                    NBA_OfferComparator_CC.Additional add = new NBA_OfferComparator_CC.Additional();
                    currentProduct.tv[0].additionalTv.label = NBA_Constants.DEMAIS_A_LA_CARTES; //product.name;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.key = product.productId;
                        promo.label = promo.valid > 0 ? product.productName + ' por ' + promo.valid + ' meses ' : product.productName; //Dúvida
                        promo.value = product.pricing - product.deducedPrice;
                        promo.discount = product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        if (ex.isAlreadyIncluded == '1') {
                            currentProduct.totalValue += promo.value;
                        }
                        if (String.isNotBlank(currentProduct.tv[0].difAdditionalsStep.label) && Integer.valueOf(currentProduct.tv[0].difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.tv[0].difAdditionalsStep.label)) {
                            currentProduct.tv[0].difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.tv[0].difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.tv[0].difAdditionalsStep.value != null) {
                            currentProduct.tv[0].difAdditionalsStep.value += add.value;
                        } else {
                            currentProduct.tv[0].difAdditionalsStep.value = add.value;
                        }
                    } else {
                        if (ex.isAlreadyIncluded == '1') {
                            currentProduct.totalValue += product.pricing;
                        }
                    }
                } else if (product.productType == NBA_Constants.TV_PONTOS_ADICIONAIS) {
                    NBA_IntegrationModels.Extras ex = NBA_OfferComparator_CC.fillAdditional(product);
                    extras.add(ex);
                    currentProduct.tv[0].optionalPointsTv.originalValue = product.pricing;
                    currentProduct.tv[0].optionalPointsTv.nameLegacy = product.productName;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.label = product.catalogName;
                        promo.description = product.promotionName;
                        promo.value = product.pricing - product.deducedPrice;
                        promo.discount = product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        currentProduct.totalValue += promo.value;
                        currentProduct.tv[0].optionalPointsTv.lstPromotions.add(promo);
                        if (String.isNotBlank(currentProduct.tv[0].difAdditionalsStep.label) && Integer.valueOf(currentProduct.tv[0].difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.tv[0].difAdditionalsStep.label)) {
                            currentProduct.tv[0].difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.tv[0].difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.tv[0].difAdditionalsStep.value != null) {
                            currentProduct.tv[0].difAdditionalsStep.value += product.pricing;
                        } else {
                            currentProduct.tv[0].difAdditionalsStep.value = product.pricing;
                        }
                    } else {
                        if (ex.isAlreadyIncluded == '1') {
                            currentProduct.totalValue += product.pricing;
                        }
                    }
                    // BANDA LARGA
                } else if (product.productType == NBA_Constants.BL_ASSINATURA) {
                    if (product.catalogName == '' || product.catalogName == NBA_Constants.SEMPLANO) {
                        currentProduct.broadband.planBroadband.label = NBA_Constants.NAO_POSSUI;
                    } else {
                        currentProduct.broadband.planBroadband.label = product.catalogName;
                        currentProduct.broadband.planBroadband.nameLegacy = product.productName;
                        if (currentProduct.hasDiscountAutomaticDebit) {
                            currentProduct.broadband.automaticDebitDiscount = String.isNotBlank(product.digitalBillDiscount) && String.isNotBlank(product.directDebitDiscount) ? Decimal.valueOf(product.digitalBillDiscount) + Decimal.valueOf(product.directDebitDiscount) : 0;
                            currentProduct.automaticDebitDiscount += currentProduct.broadband.automaticDebitDiscount;
                        }
                    }
                    currentProduct.broadband.planBroadband.key = product.productId;
                    currentProduct.broadband.planBroadband.fidelity = new Fidelity();
                    currentProduct.broadband.planBroadband.fidelity.startDate = (product.discount != null ? convertDatetimeToDate(product.discount.startDate) : null);
                    currentProduct.broadband.planBroadband.fidelity.hasFidelity = product.hasFidelity == NBA_Constants.HAS_FIDELITY_CURRENT;
                    currentProduct.broadband.planBroadband.originalValue = product.pricing;
                    currentProduct.broadband.planBroadband.value = currentProduct.broadband.planBroadband.originalValue;
					currentProduct.broadband.planBroadband.pointId = product.pointId;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.discount = product.deducedPrice;
                        promo.value = product.pricing - product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        promo.label = promo.valid > 0 ? currentProduct.broadband.planBroadband.label + ' por ' + promo.valid + ' meses ' : currentProduct.broadband.planBroadband.label;
                        currentProduct.broadband.planBroadband.value = promo.value;
                        currentProduct.broadband.planBroadband.lstPromotions.add(promo);
                        if (String.isNotBlank(currentProduct.broadband.difProductsStep.label) && Integer.valueOf(currentProduct.broadband.difProductsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.broadband.difProductsStep.label)) {
                            currentProduct.broadband.difProductsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.broadband.difProductsStep.label = String.valueOf(promo.valid);
                        }
                        currentProduct.broadband.difProductsStep.value = currentProduct.broadband.planBroadband.originalValue;
                        currentProduct.totalValue += promo.value;
                    } else {
                        currentProduct.totalValue += product.pricing;
                    }
                } else if (product.productType == NBA_Constants.BL_ADICIONAIS) {
                    NBA_IntegrationModels.Extras ex = NBA_OfferComparator_CC.fillAdditional(product);
                    extras.add(ex);
                    NBA_OfferComparator_CC.Additional add = new NBA_OfferComparator_CC.Additional();
                    add.id = product.productId;
                    add.checked = true;
                    add.label = product.productName;
                    add.value = product.pricing;
                    currentProduct.broadband.addOptions.lstAdditionals.add(add);
                    currentProduct.broadband.addOptions = getAdicionaisBandaLarga(currentProduct, currentProduct, extras, true);
                    currentProduct.broadband.additionalBroadband.label = NBA_Constants.ADICIONAIS;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.label = promo.valid > 0 ? product.productName + ' por ' + promo.valid + ' meses ' : product.productName; //Dúvida
                        promo.value = product.pricing - product.deducedPrice;
                        promo.discount = product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        currentProduct.broadband.additionalBroadband.value += promo.value;
                        if (String.isNotBlank(currentProduct.broadband.difAdditionalsStep.label) && Integer.valueOf(currentProduct.broadband.difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.broadband.difAdditionalsStep.label)) {
                            currentProduct.broadband.difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.broadband.difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.broadband.difAdditionalsStep.value != null) {
                            currentProduct.broadband.difAdditionalsStep.value += product.pricing;
                        } else {
                            currentProduct.broadband.difAdditionalsStep.value = product.pricing;
                        }
                        currentProduct.totalValue += promo.value;
                        currentProduct.broadband.additionalBroadband.lstPromotions.add(promo);
                    } else {
                        if (ex.isAlreadyIncluded == '1') {
                            currentProduct.totalValue += product.pricing;
                            currentProduct.broadband.additionalBroadband.value += product.pricing;
                        }
                    }
                    // NET FONE
                } else if (product.productType == NBA_Constants.NET_FONE) {
                    if (product.catalogName == '' || product.catalogName == NBA_Constants.SEMPLANO) {
                        currentProduct.phone.planPhone.label = NBA_Constants.NAO_POSSUI;
                    } else {
                        currentProduct.phone.planPhone.label = product.catalogName;
                        currentProduct.phone.planPhone.nameLegacy = product.productName;
                    }
                    currentProduct.phone.planPhone.key = product.productId;
                    currentProduct.phone.planPhone.fidelity = new Fidelity();
                    if (product.discount != null) {
                        currentProduct.phone.planPhone.fidelity.startDate = convertDatetimeToDate(product.discount.startDate);
                    } else {
                        currentProduct.phone.planPhone.fidelity.startDate = null;
                    }
                    currentProduct.phone.planPhone.fidelity.hasFidelity = product.hasFidelity == NBA_Constants.HAS_FIDELITY_CURRENT;
                    currentProduct.phone.planPhone.originalValue = product.pricing;
                    currentProduct.phone.planPhone.value = currentProduct.phone.planPhone.originalValue;
					currentProduct.phone.planPhone.pointId = product.pointId;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.discount = product.deducedPrice; //Dúvida product.promotion.discount
                        promo.value = product.pricing - product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        if (promo.valid > 0) {
                            promo.label = currentProduct.phone.planPhone.label + ' por ' + promo.valid + ' meses ';
                        } else {
                            promo.label = currentProduct.phone.planPhone.label;
                        }
                        currentProduct.phone.planPhone.value = promo.value;
                        currentProduct.phone.planPhone.lstPromotions.add(promo);
                        if (String.isNotBlank(currentProduct.phone.difProductsStep.label) && Integer.valueOf(currentProduct.phone.difProductsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.phone.difProductsStep.label)) {
                            currentProduct.phone.difProductsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.phone.difProductsStep.label = String.valueOf(promo.valid);
                        }
                        currentProduct.phone.difProductsStep.value = currentProduct.phone.planPhone.originalValue;
                        currentProduct.totalValue += promo.value;
                    } else {
                        currentProduct.totalValue += product.pricing;
                    }
                } else if (product.productType == NBA_Constants.NET_ADICIONAIS) {
                    currentProduct.phone.additionalPhone.label = NBA_Constants.ADICIONAIS; //product.name;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) { //Dúvida product.promotion != null && product.promotion.discount > 0
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        if (promo.valid > 0) {
                            promo.label = product.productName + ' por ' + promo.valid + ' meses ';
                        } else {
                            promo.label = product.productName;
                        }
                        promo.value = product.pricing - product.deducedPrice;
                        promo.discount = product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        currentProduct.phone.additionalPhone.lstPromotions.add(promo);
                        currentProduct.phone.additionalPhone.value += promo.value;
                        if (String.isNotBlank(currentProduct.phone.difAdditionalsStep.label) && Integer.valueOf(currentProduct.phone.difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.phone.difAdditionalsStep.label)) {
                            currentProduct.phone.difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.phone.difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.phone.difAdditionalsStep.value != null) {
                            currentProduct.phone.difAdditionalsStep.value += product.pricing;
                        } else {
                            currentProduct.phone.difAdditionalsStep.value = product.pricing;
                        }
                        currentProduct.totalValue += promo.value;
                    } else {
                        currentProduct.totalValue += product.pricing;
                        currentProduct.phone.additionalPhone.value += product.pricing;
                    }
                    // MÓVEL
                }
                
                else if (product.productType == NBA_Constants.MOVEL_ASSINATURA && product.pointTypeId == '2') {
                    
                    // cria titular + titular.planMobile
                    if (product.catalogName == '' || product.catalogName == NBA_Constants.SEMPLANO) {
                        currentProduct.mobile.planMobile.label = NBA_Constants.NAO_POSSUI;
                    } else {
                        currentProduct.mobile.planMobile.label = product.catalogName;
                        currentProduct.mobile.planMobile.nameLegacy = product.productName;
                        if (currentProduct.hasDiscountAutomaticDebit) {
                            currentProduct.mobile.automaticDebitDiscount = String.isNotBlank(product.digitalBillDiscount) && String.isNotBlank(product.directDebitDiscount) ? Decimal.valueOf(product.digitalBillDiscount) + Decimal.valueOf(product.directDebitDiscount) : 0;
                            currentProduct.automaticDebitDiscount += currentProduct.mobile.automaticDebitDiscount;
                        }
                    }
                    currentProduct.mobile.planMobile.key = product.productId;
                    currentProduct.mobile.planMobile.fidelity = new Fidelity();
                    currentProduct.mobile.planMobile.fidelity.startDate = (product.discount != null ? convertDatetimeToDate(product.discount.startDate) : null);
                    currentProduct.mobile.planMobile.fidelity.hasFidelity = product.hasFidelity == NBA_Constants.HAS_FIDELITY_CURRENT;
                    currentProduct.mobile.planMobile.originalValue = product.pricing;
                    currentProduct.mobile.planMobile.value = currentProduct.mobile.planMobile.originalValue;
					currentProduct.mobile.planMobile.pointId 				= product.pointId;
                    currentProduct.mobile.isComboMulti = product.isComboMulti != null && product.isComboMulti.equalsIgnoreCase('true') ? true : false;
                    currentProduct.mobile.msisdn = product.msisdn;
                    currentProduct.mobile.promotionName = product.promotionName;
                    currentProduct.mobile.productDetail = product.productDetail;
                    
                    // cria titular.titularMobile(baseado em dependente)
                    Dependentes dep = new Dependentes();
                    dep.origem = 'Base';
                    dep.operadora = 'Claro';
                    dep.numeroTelefone = product.msisdn;
                    dep.nomePlano = product.catalogName;
                    dep.promoSelected = product.productName;
                    dep.valorProduto = product.pricing;
                    dep.productName = product.productName;
                    if (String.isNotBlank(product.mobileOfferName)) {
                        dep.listBeneficiosDoPlano = product.mobileOfferName.split('\\|');
                    }
                    currentProduct.mobile.titularMobile = dep;

                    // não tem efeito em descontos do tipo "DESCONTO_AGREGADO_".. então, terá efeito em algum cenário?
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.discount = product.deducedPrice;
                        promo.value = currentProduct.mobile.planMobile.originalValue - product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        if (promo.valid > 0) {
                            promo.label = currentProduct.mobile.planMobile.label + ' por ' + promo.valid + ' meses ';
                        } else {
                            promo.label = currentProduct.mobile.planMobile.label;
                        }
                        currentProduct.mobile.planMobile.value = promo.value;
                        currentProduct.mobile.planMobile.lstPromotions.add(promo);
                        if (String.isNotBlank(currentProduct.mobile.difProductsStep.label) && Integer.valueOf(currentProduct.mobile.difProductsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.mobile.difProductsStep.label)) {
                            currentProduct.mobile.difProductsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.mobile.difProductsStep.label = String.valueOf(promo.valid);
                        }
                        currentProduct.mobile.difProductsStep.value = currentProduct.mobile.planMobile.originalValue;
                        currentProduct.totalValue += promo.value;
                    } else {
                        currentProduct.totalValue += currentProduct.mobile.planMobile.value;
                    }
                    currentProduct.mobile.posseAtual = false;
                }

                else if (product.productType == NBA_Constants.MOVEL_DEPENDENTES && product.pointTypeId == '3') {
                    
                    // cria obj dep + add obj dep + add valores/unidades do dep nos totais
                    Dependentes dep = new Dependentes();
                    dep.origem = 'Base';
                    dep.operadora = 'Claro';
                    dep.numeroTelefone = product.msisdn;
                    dep.nomePlano = product.productDetail;
                    dep.promoSelected = product.productName;
                    dep.valorProduto = product.pricing;
                    dep.possessionDiscount = product.possessionDiscount;
                    dep.catalogName = product.catalogName;
                    dep.promotionName = product.promotionName;
                    dep.productName = product.productName;
                    dep.fidelity = product.hasFidelity != null && product.hasFidelity.equalsIgnoreCase('true') ? true : false;
                    if (String.isNotBlank(product.mobileOfferName))
                        dep.listBeneficiosDoPlano = product.mobileOfferName.split('\\|');
                    currentProduct.mobile.listaDependentesMobilePosse.add(dep);
                    
                    currentProduct.totalValue += product.pricing;
                    currentProduct.mobile.TotalDependentes += product.pricing;

                    if(product.pricing>0){
                    // dependentes pós pago (voz + dados)
                    if (product.productDetail.toUpperCase() == 'POS PG') {
                        currentProduct.mobile.totalVozDados += product.pricing;
                        if(!msisdnDependentes.contains(product.msisdn))
                            currentProduct.mobile.numeroDependentesVozDados += 1;
                    }
                    // dependentes banda larga (dados)
                    else if (product.productDetail.toUpperCase() == 'POS BL') {
                        currentProduct.mobile.totalDados += product.pricing;
                        if(!msisdnDependentes.contains(product.msisdn))
                            currentProduct.mobile.numeroDependentesDados += 1;
                    }
                    // dependentes controle (controle)
                    else if (product.productDetail.toUpperCase() == 'CONTROLE') {
                        currentProduct.mobile.totalControle += product.pricing;
                        if(!msisdnDependentes.contains(product.msisdn))
                            currentProduct.mobile.numeroDependentesControle += 1;
                    }
                    
                        if(!msisdnDependentes.contains(product.msisdn))
                            currentProduct.mobile.numeroMaxDep++;
                    
                        msisdnDependentes.add(product.msisdn);
                    }
                    // por que sempre sobrescreve essa label?
                    currentProduct.mobile.dependentslMobile.label = product.productName + ' ' + NBA_Constants.DEPENDENTES;
                    
                    // não tem efeito em descontos do tipo "DESCONTO_AGREGADO_".. então, terá efeito em algum cenário?
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.value = product.pricing - product.deducedPrice;
                        promo.valid = product.discount.duration > 0 ? product.discount.duration : null;
                        promo.label = product.promotionName + ' ' + NBA_Constants.DEPENDENTES + ' por ' + promo.valid + ' meses';
                        currentProduct.mobile.dependentslMobile.lstPromotions.add(promo);
                        currentProduct.mobile.dependentslMobile.value += promo.value;
                        if (String.isNotBlank(currentProduct.mobile.difAdditionalsStep.label) && Integer.valueOf(currentProduct.mobile.difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.mobile.difAdditionalsStep.label)) {
                            currentProduct.mobile.difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.mobile.difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.mobile.difAdditionalsStep.value != null) {
                            currentProduct.mobile.difAdditionalsStep.value += product.pricing;
                        } else {
                            currentProduct.mobile.difAdditionalsStep.value = product.pricing;
                        }
                    }
                    else {
                        // redundante com o "currentProduct.mobile.TotalDependentes"?
                        currentProduct.mobile.dependentslMobile.value += product.pricing;
                    }
                    
                }
                
                else if (product.productType == NBA_Constants.MOVEL_ADICIONAIS) {
                    NBA_IntegrationModels.Extras ex = NBA_OfferComparator_CC.fillAdditional(product);
                    extras.add(ex);
                    NBA_OfferComparator_CC.Additional add = new NBA_OfferComparator_CC.Additional();
                    add.id = product.productId;
                    add.checked = true;
                    add.label = product.productName;
                    add.value = product.pricing;
                    currentProduct.mobile.addOptions.lstAdditionals.add(add);
                    currentProduct.mobile.additionalMobile.label = NBA_Constants.ADICIONAIS; //product.name;
                    currentProduct.mobile.additionalMobile.value += product.pricing;
                    if (product.discount != null && product.deducedPrice != null && product.deducedPrice > 0 && product.discount != null && getValid(product.discount.startDate, product.discount.duration) > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        if (promo.valid > 0) {
                            promo.label = product.productName + ' por ' + promo.valid + ' meses '; //Dúvida
                        } else {
                            promo.label = product.productName;
                        }
                        promo.value = product.pricing - product.deducedPrice;
                        promo.discount = product.deducedPrice;
                        promo.valid = getValid(product.discount.startDate, product.discount.duration);
                        promo.description = product.promotionName;
                        currentProduct.totalValue += promo.value;
                        currentProduct.mobile.additionalMobile.lstPromotions.add(promo);
                        currentProduct.mobile.additionalMobile.value += promo.value;
                        if (String.isNotBlank(currentProduct.mobile.difAdditionalsStep.label) && Integer.valueOf(currentProduct.mobile.difAdditionalsStep.label) > 0
                                && promo.valid > Integer.valueOf(currentProduct.mobile.difAdditionalsStep.label)) {
                            currentProduct.mobile.difAdditionalsStep.label = String.valueOf(promo.valid);
                        } else {
                            currentProduct.mobile.difAdditionalsStep.label = String.valueOf(promo.valid);
                        }
                        if (currentProduct.mobile.difAdditionalsStep.value != null) {
                            currentProduct.mobile.difAdditionalsStep.value += product.pricing;
                        } else {
                            currentProduct.mobile.difAdditionalsStep.value = product.pricing;
                        }
                    } else {
                        currentProduct.mobile.additionalMobile.value += product.pricing;
                        currentProduct.totalValue += currentProduct.mobile.additionalMobile.value;
                    }
                }
            }

            currentProduct.totalValue -= currentProduct.automaticDebitDiscount;
            if (String.isBlank(currentProduct.tv[0].planTv.label)) {
                currentProduct.tv[0].planTv.label = NBA_Constants.NAO_POSSUI;
                currentProduct.tv[0].planTv.value = null;
            }
            if (String.isBlank(currentProduct.broadband.planBroadband.label)) {
                currentProduct.broadband.planBroadband.label = NBA_Constants.NAO_POSSUI;
                currentProduct.broadband.planBroadband.value = null;
            }
            if (String.isBlank(currentProduct.phone.planPhone.label)) {
                currentProduct.phone.planPhone.label = NBA_Constants.NAO_POSSUI;
                currentProduct.phone.planPhone.value = null;
            }
            if (String.isBlank(currentProduct.mobile.planMobile.label)) {
                currentProduct.mobile.planMobile.label = NBA_Constants.NAO_POSSUI;
                currentProduct.mobile.planMobile.value = null;
            }
            
            // BONUS E DESCONTOS
            // if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.pointType != null && nboMobile.mobileDiscount.pointType == 'TITULAR'){
            //     if(nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'BONUS'){
            //         BonusDesconto bd = new BonusDesconto();
            //         bd.check = false;
            //         bd.disabled = false;
            //         bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('GB', ''));
            //         currentProduct.mobile.listBonusTitular.add(bd);
            //     }else if(nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'DESCONTO'){
            //         BonusDesconto bd = new BonusDesconto();
            //         bd.check = false;
            //         bd.disabled = false;
            //         bd.multa = Decimal.valueOf( nboMobile.mobileDiscount.feeValue.replaceAll(',' , '.'));
            //         bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('%', ''));
            //         currentProduct.mobile.listDescontoTitular.add(bd);
            //     }
            // }else if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.pointType != null && nboMobile.mobileDiscount.pointType == 'DEPENDENTE'){
            //     if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'BONUS'){
            //         BonusDesconto bd = new BonusDesconto();
            //         bd.check = false;
            //         bd.disabled = false;
            //         bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('GB', ''));
            //         currentProduct.mobile.listBonusDependente.add(bd);
            //     }else if(nboMobile.mobileDiscount != null && nboMobile.mobileDiscount.offerType != null && nboMobile.mobileDiscount.offerType == 'DESCONTO'){
            //         BonusDesconto bd = new BonusDesconto();
            //         bd.check = false;
            //         bd.disabled = false;
            //         bd.multa = Decimal.valueOf( nboMobile.mobileDiscount.feeValue.replaceAll(',' , '.'));
            //         bd.valor = Decimal.valueOf(nboMobile.mobileDiscount.benefitOffer.replaceAll('%' , ''));
            //         currentProduct.mobile.listDescontoDependente.add(bd);
            //     }
            // }

        }
        return currentProduct;
    }

    private static Integer getValid(String startDate, Integer promoValid) {
        if (String.isNotBlank(startDate) && promoValid != null && promoValid > 0) {
            Date start = Date.valueOf(startDate);
            Decimal days = start.daysBetween(Date.today());
            Decimal months = days.divide(30, 2);
            Decimal validMonths = promoValid - months;
            return(Integer) Math.floor(validMonths);
        }
        return 0;
    }
    public static Integer getQtdMonth(String dtStr, Integer qtdMonth) {
        Integer monthDiff;
        if (dtStr != null && String.isNotBlank(dtStr) && String.valueOf(qtdMonth) != null) {
            DateTime dateProduct = DateTime.valueOf(dtStr);
            Date dtResult = Date.newInstance(dateProduct.year(), dateProduct.month(), dateProduct.day());
            monthDiff = System.today().monthsBetween(dtResult.addMonths(qtdMonth));
        } else {
            monthDiff = 0;
        }
        return monthDiff;
    }
    private static Decimal getTotalValue(NBA_OfferComparator_CC.Offer current,
            NBA_OfferComparator_CC.Offer offer) {
        Decimal totalValue = 0;
        totalValue += (offer.tv[0].planTv.value != null ? offer.tv[0].planTv.value : 0);
        totalValue += (offer.tv[0].additionalTv.value != null ? offer.tv[0].additionalTv.value : 0);
        totalValue += (offer.tv[0].optionalPointsTv.value != null ? offer.tv[0].optionalPointsTv.value : 0);
        totalValue += (offer.tv[0].additionalPromoValue != null ? offer.tv[0].additionalPromoValue : 0);
        totalValue += (offer.broadband.planBroadband.value != null ? offer.broadband.planBroadband.value : 0);
        totalValue += (offer.broadband.additionalBroadband.value != null ? offer.broadband.additionalBroadband.value : 0);
        totalValue += (offer.phone.planPhone.value != null ? offer.phone.planPhone.value : 0);
        totalValue += (offer.phone.additionalPhone.value != null ? offer.phone.additionalPhone.value : 0);
        totalValue += (offer.mobile.planMobile.value != null ? offer.mobile.planMobile.value : 0);
        totalValue += (offer.mobile.additionalMobile.value != null ? offer.mobile.additionalMobile.value : 0);
        totalValue += (offer.mobile.dependentslMobile.value != null ? offer.mobile.dependentslMobile.value : 0);
        totalValue -= offer.automaticDebitDiscount;
        return totalValue;
    }
    private static void getTotalCostVariation(NBA_OfferComparator_CC.Offer current,
            NBA_OfferComparator_CC.Offer offer) {
        // Produtos
        Decimal costTV = 0;
        Decimal costBroadband = 0;
        Decimal costFone = 0;
        Decimal costMobile = 0;
        Decimal totalCostVariation = 0;
        Decimal actualCostTV = (current.tv[0].planTv.value != null ? current.tv[0].planTv.value : 0);
        Decimal actualCostBroadband = (current.broadband.planBroadband.value != null ? current.broadband.planBroadband.value : 0);
        Decimal actualCostFone = (current.phone.planPhone.value != null ? current.phone.planPhone.value : 0);
        Decimal actualCostMobile = (current.mobile.planMobile.value != null ? current.mobile.planMobile.value : 0);
        costBroadband = (offer.broadband.planBroadband.value != null ? offer.broadband.planBroadband.value : 0);
        costFone = (offer.phone.planPhone.value != null ? offer.phone.planPhone.value : 0);
        costMobile = (offer.mobile.planMobile.value != null ? offer.mobile.planMobile.value : 0);
        Integer index = 0;
        for (NBA_OfferComparator_CC.PlanTv tv : offer.tv) {
            costTV = tv.planTv.value != null ? tv.planTv.value : 0;
            offer.tv[index].difProducts = costTV - actualCostTV; //- tv.automaticDebitDiscount;
            index++;
        }
        offer.broadband.difProducts = costBroadband - actualCostBroadband; //- offer.broadband.automaticDebitDiscount;
        offer.phone.difProducts = costFone - actualCostFone;
        offer.mobile.difProducts = costMobile - actualCostMobile;
    }
    private static NBA_OfferComparator_CC.Option getDifTotalStep(NBA_OfferComparator_CC.Offer current, NBA_OfferComparator_CC.Offer offer) {
        NBA_OfferComparator_CC.Option opt = new NBA_OfferComparator_CC.Option();
        Decimal difTotalStep = 0;
        List<NBA_OfferComparator_CC.Option> lstStepCurrent = current.lstSteps;
        List<NBA_OfferComparator_CC.Option> lstStepOffer = offer.lstSteps;
        NBA_OfferComparator_CC.Option stepCurrent = !lstStepCurrent.isEmpty() ? lstStepCurrent[lstStepCurrent.size() - 1] : null;
        NBA_OfferComparator_CC.Option stepOffer = !lstStepOffer.isEmpty() ? lstStepOffer[lstStepOffer.size() - 1] : null;
        String maxValid;
        if (stepOffer != null && stepCurrent != null) {
            difTotalStep = (stepOffer.value != null && stepCurrent.value != null) ? (stepOffer.value - stepCurrent.value) : null;
        } else if (stepOffer != null) {
            difTotalStep = stepOffer.value != null ? stepOffer.value - current.totalValue : null;
        } else if (stepCurrent != null) {
            difTotalStep = stepCurrent.value != null ? offer.totalValue - stepCurrent.value : null;
        }
        if (stepCurrent != null && stepOffer != null) {
            maxValid = Integer.valueOf(stepOffer.label) > Integer.valueOf(stepCurrent.label) ? stepOffer.label : stepCurrent.label;
        } else if (stepCurrent != null) {
            maxValid = stepCurrent.label;
        } else if (stepOffer != null) {
            maxValid = stepOffer.label;
        }
        opt.label = maxValid;
        opt.value = difTotalStep;
        return opt;
    }
    private static NBA_OfferComparator_CC.Option getProductCostVariation(
        List<NBA_OfferComparator_CC.ProductPromo> currentLstPromotions, Decimal currentTotalValue, 
        List<NBA_OfferComparator_CC.ProductPromo> offerLstPromotions, Decimal offerTotalValue
    ){
        NBA_OfferComparator_CC.Option opt = new NBA_OfferComparator_CC.Option();
        List<NBA_OfferComparator_CC.ProductPromo> promotionsOffer = offerLstPromotions;
        promotionsOffer = sortLstPromotions(promotionsOffer);
        List<NBA_OfferComparator_CC.ProductPromo> promotionsCurrent = currentLstPromotions;
        promotionsCurrent = sortLstPromotions(promotionsCurrent);
        Integer[] validList = new List<Integer> ();
        NBA_OfferComparator_CC.ProductPromo promoOffer = !promotionsOffer.isEmpty() ? promotionsOffer[promotionsOffer.size() - 1] : null;
        NBA_OfferComparator_CC.ProductPromo promoCurrent = !promotionsCurrent.isEmpty() ? promotionsCurrent[promotionsCurrent.size() - 1] : null;
        if (promoCurrent != null) {
            validList.add(Integer.valueOf(promoCurrent.valid));
        }
        if (promoOffer != null) {
            validList.add(Integer.valueOf(promoOffer.valid));
        }
        validList.sort();
        opt.label = !validList.isEmpty() ? String.valueOf(validList[validList.size() - 1]) : '';
        opt.value = (offerTotalValue!=null ? offerTotalValue : 0) - (currentTotalValue!=null ? currentTotalValue : 0);
        return opt;
    }
    private static NBA_OfferComparator_CC.Option getAdditionalCostVariation(NBA_OfferComparator_CC.Product additionalsCurrent,
            List<NBA_OfferComparator_CC.Additional> additionalsOffer,
            NBA_OfferComparator_CC.Product optionalsCurrent,
            NBA_OfferComparator_CC.Product optionalsOffer) {
        Decimal totalAdditionalsCurrent = 0;
        Decimal totalAdditionalsOffer = 0;
        List<Integer> validAdditionals = new List<Integer> ();
        NBA_OfferComparator_CC.Option opt = new NBA_OfferComparator_CC.Option();
        for (NBA_OfferComparator_CC.ProductPromo promo : additionalsCurrent.lstPromotions) {
            validAdditionals.add(Integer.valueOf(promo.valid));
            totalAdditionalsCurrent += promo.value;
        }
        for (NBA_OfferComparator_CC.Additional add : additionalsOffer) {
            if (add.checked) {
                if (String.isNotBlank(add.promoSelected)) {
                    Integer promoSelected = Integer.valueOf(add.promoSelected);
                    validAdditionals.add(Integer.valueOf(add.lstPromotions[promoSelected].valid));
                    totalAdditionalsOffer += add.value;
                }
            }
        }
        Integer maxValid = 0;
        Decimal difAdditionals = 0;
        for (Integer i : validAdditionals) {
            if (i > maxValid) {
                maxValid = i;
            }
        }
        if (optionalsCurrent != null) {
            difAdditionals -= (optionalsCurrent.value + totalAdditionalsCurrent);
        } else {
            difAdditionals -= totalAdditionalsCurrent;
        }
        if (optionalsOffer != null) {
            difAdditionals += (optionalsOffer.value + totalAdditionalsOffer);
        } else {
            difAdditionals += totalAdditionalsOffer;
        }
        opt.label = maxValid > 0 ? String.valueOf(maxValid) : null;
        opt.value = difAdditionals;
        return opt;
    }
    //US114 - SP14 - Kleverton Fortunato
    private static NBA_OfferComparator_CC.Option getDependentsCostVariation(NBA_OfferComparator_CC.Product additionalsCurrent,
            List<NBA_OfferComparator_CC.Additional> additionalsOffer,
            NBA_OfferComparator_CC.Product optionalsCurrent,
            NBA_OfferComparator_CC.Product optionalsOffer) {
        Decimal totalAdditionalsCurrent = 0;
        Decimal totalAdditionalsOffer = 0;
        List<Integer> validAdditionals = new List<Integer> ();
        NBA_OfferComparator_CC.Option opt = new NBA_OfferComparator_CC.Option();
        for (NBA_OfferComparator_CC.ProductPromo promo : additionalsCurrent.lstPromotions) {
            validAdditionals.add(Integer.valueOf(promo.valid));
            totalAdditionalsCurrent += promo.value;
        }
        for (NBA_OfferComparator_CC.Additional add : additionalsOffer) {
            if (add.checked) {
                if (String.isNotBlank(add.promoSelected)) {
                    Integer promoSelected = Integer.valueOf(add.promoSelected);
                    validAdditionals.add(Integer.valueOf(add.lstPromotions[promoSelected].valid));
                    totalAdditionalsOffer += add.value;
                }
            }
        }
        Integer maxValid = 0;
        Decimal difAdditionals = 0;
        for (Integer i : validAdditionals) {
            if (i > maxValid) {
                maxValid = i;
            }
        }
        if (optionalsCurrent != null) {
            difAdditionals -= (optionalsCurrent.value + totalAdditionalsCurrent);
        } else {
            difAdditionals -= totalAdditionalsCurrent;
        }
        if (optionalsOffer != null) {
            difAdditionals += (optionalsOffer.value + totalAdditionalsOffer);
        } else {
            difAdditionals += totalAdditionalsOffer;
        }
        opt.label = maxValid > 0 ? String.valueOf(maxValid) : null;
        opt.value = difAdditionals;
        return opt;
    }
    private static Decimal getDifDependents(NBA_OfferComparator_CC.Product additionalsCurrent,
            List<NBA_OfferComparator_CC.Additional> additionalsOffer,
            NBA_OfferComparator_CC.Product optionalsCurrent,
            NBA_OfferComparator_CC.Product optionalsOffer) {
        Decimal totalAdditionalsCurrent = 0;
        Decimal totalAdditionalsOffer = 0;
        for (NBA_OfferComparator_CC.ProductPromo promo : additionalsCurrent.lstPromotions) {
            totalAdditionalsCurrent += promo.value;
        }
        for (NBA_OfferComparator_CC.Additional add : additionalsOffer) {
            if (add.checked) {
                if (String.isNotBlank(add.promoSelected)) {
                    Integer promoSelected = Integer.valueOf(add.promoSelected);
                    totalAdditionalsOffer += add.lstPromotions[promoSelected].value;
                }
            }
        }
        Decimal difAdditionals = 0;
        if (optionalsCurrent != null) {
            difAdditionals -= (optionalsCurrent.value + totalAdditionalsCurrent);
        } else {
            difAdditionals -= totalAdditionalsCurrent;
        }
        if (optionalsOffer != null) {
            difAdditionals += (optionalsOffer.value + totalAdditionalsOffer);
        } else {
            difAdditionals += totalAdditionalsOffer;
        }
        return difAdditionals;
    }
    //Fim da Alteracao - US114 - Kleverton Fortunato
    private static Decimal getDifAdditionals(List<NBA_OfferComparator_CC.Additional> additionalsCurrent,
            List<NBA_OfferComparator_CC.Additional> additionalsOffer,
            NBA_OfferComparator_CC.Product optionalsCurrent,
            NBA_OfferComparator_CC.Product optionalsOffer) {
        Decimal totalAdditionalsCurrent = 0;
        Decimal totalAdditionalsOffer = 0;
        //for (NBA_OfferComparator_CC.ProductPromo promo : additionalsCurrent.lstPromotions) {
        //    totalAdditionalsCurrent += promo.value;
        //}
        // Alexandre amaro teste de correção card 052  >>  troca do additionalsCurrente de NBA_OfferComparator_CC.Product para uma lista de adicionais//
        for (NBA_OfferComparator_CC.Additional add : additionalsCurrent) {
            if (add.checked) {
                if (String.isNotBlank(add.promoSelected)) {
                    Integer promoSelected = Integer.valueOf(add.promoSelected);
                    totalAdditionalsCurrent += add.lstPromotions[promoSelected].value;
                } else {
                    totalAdditionalsCurrent += add.value;
                }
            }
        }
        for (NBA_OfferComparator_CC.Additional add : additionalsOffer) {
            if (add.checked) {
                if (String.isNotBlank(add.promoSelected)) {
                    Integer promoSelected = Integer.valueOf(add.promoSelected);
                    totalAdditionalsOffer += add.lstPromotions[promoSelected].value;
                } else {
                    totalAdditionalsOffer += add.value;
                }
            }
        }
        Decimal difAdditionals = 0;
        if (optionalsCurrent != null) {
            difAdditionals -= (optionalsCurrent.value + totalAdditionalsCurrent);
        } else {
            difAdditionals -= totalAdditionalsCurrent;
        }
        if (optionalsOffer != null) {
            difAdditionals += (optionalsOffer.value + totalAdditionalsOffer);
        } else {
            difAdditionals += totalAdditionalsOffer;
        }
        return difAdditionals;
    }

    @TestVisible
    private static List<NBA_OfferComparator_CC.Option> getTotalDegrades(NBA_OfferComparator_CC.Offer offer, Boolean isActualProduct) {
        Map<Integer, NBA_OfferComparator_CC.Option> mapDegrades = new Map<Integer, NBA_OfferComparator_CC.Option> ();
        List<NBA_OfferComparator_CC.ProductPromo> promotions = new List<NBA_OfferComparator_CC.ProductPromo> ();
        promotions.addAll(offer.tv[0].planTv.lstPromotions);
        promotions.addAll(offer.broadband.planBroadband.lstPromotions);
        promotions.addAll(offer.phone.planPhone.lstPromotions);
        promotions.addAll(offer.mobile.planMobile.lstPromotions);
        //promotions.addAll(offer.tv[0].additionalTv.lstPromotions);
        promotions.addAll(offer.tv[0].optionalPointsTv.lstPromotions);
        promotions.addAll(offer.broadband.additionalBroadband.lstPromotions);
        promotions.addAll(offer.mobile.additionalMobile.lstPromotions);
        promotions = sortLstPromotions(promotions);
        if (!promotions.isEmpty()) {
            Decimal valueDegrade = offer.totalValue;
            for (NBA_OfferComparator_CC.ProductPromo promo : promotions) {
                if (promo.valid != null && promo.valid > 0) {
                    if (!mapDegrades.containsKey(promo.valid)) {
                        NBA_OfferComparator_CC.Option option = new NBA_OfferComparator_CC.Option();
                        option.label = String.valueOf(promo.valid);
                        option.value = offer.totalValue;
                        mapDegrades.put(promo.valid, option);
                    }
                    valueDegrade += promo.discount;
                    mapDegrades.get(promo.valid).value = valueDegrade;
                }
            }
        }
        return mapDegrades.values();
    }

    @TestVisible
    private static List<NBA_OfferComparator_CC.Option> getTotalDegradesv2(NBA_OfferComparator_CC.Offer offer, Boolean isActualProduct) {
        Map<Integer, NBA_OfferComparator_CC.Option> mapDegrades = new Map<Integer, NBA_OfferComparator_CC.Option> ();
        List<NBA_OfferComparator_CC.ProductPromo> promotions = new List<NBA_OfferComparator_CC.ProductPromo> ();
        promotions.addAll(offer.tv[0].planTv.lstPromotions);
        promotions.addAll(offer.broadband.planBroadband.lstPromotions);
        promotions.addAll(offer.phone.planPhone.lstPromotions);
        promotions.addAll(offer.mobile.planMobile.lstPromotions);
        promotions.addAll(offer.tv[0].additionalTv.lstPromotions);
        promotions.addAll(offer.tv[0].optionalPointsTv.lstPromotions);
        promotions.addAll(offer.broadband.additionalBroadband.lstPromotions);
        promotions.addAll(offer.mobile.additionalMobile.lstPromotions);
        promotions = sortLstPromotions(promotions);
        if (!promotions.isEmpty()) {
            Decimal valueDegrade = offer.totalValue;
            for (NBA_OfferComparator_CC.ProductPromo promo : promotions) {
                if (promo.valid != null && promo.valid > 0) {
                    if (!mapDegrades.containsKey(promo.valid)) {
                        NBA_OfferComparator_CC.Option option = new NBA_OfferComparator_CC.Option();
                        option.label = String.valueOf(promo.valid);
                        option.value = offer.totalValue;
                        mapDegrades.put(promo.valid, option);
                    }
                    valueDegrade += promo.discount;
                    mapDegrades.get(promo.valid).value = valueDegrade;
                }
            }
        }
        return mapDegrades.values();
    }
    private static List<NBA_OfferComparator_CC.Fee> getMembershipFee(NBA_IntegrationModels.Recommendation rec, NBA_OfferComparator_CC.Offer oferta, NBA_OfferComparator_CC.Offer produtoAtual) {
        String productType;
        Decimal valueMembershipFee = 0;
        Set<String> setPaymentMethod = new Set<String> ();
        List<NBA_OfferComparator_CC.Fee> lstMembershipFee = new List<NBA_OfferComparator_CC.Fee> ();
        Boolean hasAcquisition = false;
        if (rec.nboTv != null && !rec.nboTv.isEmpty()) {
            for (NBA_IntegrationModels.NboTv nboTv : rec.nboTv) {
                Integer indexSolicTypeTv = String.isNotBlank(nboTv.solicitationType) ? (nboTv.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
                String slTypeTv = String.isNotBlank(nboTv.solicitationType) ? nboTv.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexSolicTypeTv] : null;
                if (nboTv.fee != null && String.isNotBlank(slTypeTv) && slTypeTv == NBA_Constants.TP_SOLIC_MOVIMENTACAO && produtoAtual.tv[0].planTv.label == NBA_Constants.NAO_POSSUI) {
                    hasAcquisition = true;
                    List<NBA_OfferComparator_CC.Fee> feeList = new List<NBA_OfferComparator_CC.Fee> ();
                    valueMembershipFee = String.isNotBlank(nboTv.fee.price) ? Decimal.valueOf(nboTv.fee.price) : 0;
                    productType = NBA_Constants.TV_PACOTE;
                    if (String.isNotBlank(nboTv.fee.paymentMethod)) {
                        if (valueMembershipFee == 0) {
                            setPaymentMethod.add(NBA_Constants.ISENTO);
                        } else {
                            setPaymentMethod.addAll(nboTv.fee.paymentMethod.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO));
                        }
                    }
                    if (!setPaymentMethod.isEmpty()) {
                        oferta.vlMembershipFee = String.valueOf(valueMembershipFee);
                        for (String method : setPaymentMethod) {
                            NBA_OfferComparator_CC.Fee feeProd = new NBA_OfferComparator_CC.Fee();
                            feeProd.label = productType;
                            feeProd.paymentMethod = method;
                            feeProd.value = valueMembershipFee;
                            feeProd.technologyType = nboTv.technologyTypeName;
                            lstMembershipFee.add(feeProd);
                        }
                    }
                }
            }
        }
        // TV - PONTOS OPCIONAIS
        // if (rec.extras != null && !rec.extras.isEmpty() && false) {
        if (rec.extras != null && !rec.extras.isEmpty()) {
            for (NBA_IntegrationModels.Extras extra : rec.extras) {
                Integer indexSolicType = String.isNotBlank(extra.solicitationType) ? (extra.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0) : 0;
                String slTypeTv = String.isNotBlank(extra.solicitationType) ? extra.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexSolicType] : null;
                if (extra.fee != null && String.isNotBlank(slTypeTv) && slTypeTv == NBA_Constants.TP_SOLIC_ADESAO) {
                    valueMembershipFee = (String.isNotBlank(extra.fee.price) ? Decimal.valueOf(extra.fee.price) : 0);
                    productType = NBA_Constants.TV_PONTOS_ADICIONAIS;
                    if (String.isNotBlank(extra.fee.paymentMethod)) {
                        if (valueMembershipFee == 0) {
                            setPaymentMethod.add(NBA_Constants.ISENTO);
                        } else {
                            setPaymentMethod.addAll(extra.fee.paymentMethod.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO));
                        }
                    }
                    if (!setPaymentMethod.isEmpty()) {
                        if (oferta.vlMembershipFee != null || oferta.vlMembershipFee == '0') {
                            oferta.vlMembershipFee = valueMembershipFee > 0 ? String.valueOf(valueMembershipFee) : '0';
                        }
                        for (String method : setPaymentMethod) {
                            Boolean hasMethod = false;
                            for (NBA_OfferComparator_CC.Fee f : lstMembershipFee) {
                                if (f.paymentMethod == method) {
                                    hasMethod = true;
                                }
                            }
                            if (!hasMethod) {
                                NBA_OfferComparator_CC.Fee feeProd = new NBA_OfferComparator_CC.Fee();
                                feeProd.label = productType;
                                feeProd.paymentMethod = method;
                                feeProd.value = valueMembershipFee;
                                lstMembershipFee.add(feeProd);
                            }
                        }
                    }
                }
            }
        }
        if (lstMembershipFee.size() > 0) {
            oferta.vlMembershipFee = String.valueOf(valueMembershipFee);
            oferta.paymentMethodMembership = lstMembershipFee[0].paymentMethod;
            oferta.productFee = NBA_Constants.TV_PONTOS_ADICIONAIS;
        }
        return lstMembershipFee;
    }
    private static List<NBA_OfferComparator_CC.Fee> getUpgradeFee(NBA_IntegrationModels.Recommendation rec, NBA_OfferComparator_CC.Offer oferta, NBA_OfferComparator_CC.Offer produtoAtual) {
        String productType;
        Decimal valueUpgradeFee = 0;
        Set<String> setPaymentMethod = new Set<String> ();
        List<NBA_OfferComparator_CC.Fee> lstUpgradeFee = new List<NBA_OfferComparator_CC.Fee> ();
        // BL
        Integer indexSolicTypeBroadband;
        Integer indexSolicTypePhone;
        if (String.isNotBlank(rec.nboBroadband.solicitationType)) {
            indexSolicTypeBroadband = rec.nboBroadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0;
        } else {
            indexSolicTypeBroadband = 0;
        }
        if (String.isNotBlank(rec.nboPhone.solicitationType)) {
            indexSolicTypePhone = rec.nboPhone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0;
        } else {
            indexSolicTypePhone = 0;
        }
        String slTypeBL;
        String slTypeFN;
        if (String.isNotBlank(rec.nboBroadband.solicitationType)) {
            slTypeBL = rec.nboBroadband.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexSolicTypeBroadband];
        }
        if (String.isNotBlank(rec.nboPhone.solicitationType)) {
            slTypeFN = rec.nboPhone.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexSolicTypePhone];
        }
        if (rec.nboBroadband != null && String.isNotBlank(slTypeBL) && slTypeBL == NBA_Constants.TP_SOLIC_MOVIMENTACAO) {
            if (rec.nboBroadband.fee != null && String.isNotBlank(rec.nboBroadband.fee.price)) {
                valueUpgradeFee = Decimal.valueOf(rec.nboBroadband.fee.price);
            } else {
                valueUpgradeFee = 0;
            }
            productType = NBA_Constants.BL_ASSINATURA;
            if (String.isNotBlank(rec.nboBroadband.fee.paymentMethod)) {
                if (valueUpgradeFee == 0) {
                    setPaymentMethod.add(NBA_Constants.ISENTO);
                } else {
                    setPaymentMethod.addAll(rec.nboBroadband.fee.paymentMethod.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO));
                }
            }
            //TV
        } else if (rec.nboTv != null && !rec.nboTv.isEmpty()) {
            for (NBA_IntegrationModels.NboTv nboTv : rec.nboTv) {
                //NBA_IntegrationModels.NboTv nboTv = rec.nboTv[0];
                Integer indexSolicTypeTv;
                if (String.isNotBlank(nboTv.solicitationType)) {
                    indexSolicTypeTv = nboTv.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO).size() > 1 ? 1 : 0;
                } else {
                    indexSolicTypeTv = 0;
                }
                String slTypeTv;
                if (String.isNotBlank(nboTv.solicitationType)) {
                    slTypeTv = nboTv.solicitationType.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO) [indexSolicTypeTv];
                }
                if (nboTv.fee != null && String.isNotBlank(slTypeTv) && slTypeTv == NBA_Constants.TP_SOLIC_MOVIMENTACAO && produtoAtual.tv[0].planTv.label != NBA_Constants.NAO_POSSUI) {
                    List<NBA_OfferComparator_CC.Fee> feeList = new List<NBA_OfferComparator_CC.Fee> ();
                    valueUpgradeFee = String.isNotBlank(nboTv.fee.price) ? Decimal.valueOf(nboTv.fee.price) : 0;
                    productType = NBA_Constants.TV_PACOTE;
                    if (String.isNotBlank(nboTv.fee.paymentMethod)) {
                        if (valueUpgradeFee == 0) {
                            setPaymentMethod.add(NBA_Constants.ISENTO);
                        } else {
                            setPaymentMethod.addAll(nboTv.fee.paymentMethod.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO));
                        }
                    }
                    if (!setPaymentMethod.isEmpty()) {
                        oferta.vlUpgradeFee = String.valueOf(valueUpgradeFee);
                        for (String method : setPaymentMethod) {
                            NBA_OfferComparator_CC.Fee feeProd = new NBA_OfferComparator_CC.Fee();
                            feeProd.label = productType;
                            feeProd.paymentMethod = method;
                            feeProd.value = valueUpgradeFee;
                            feeProd.technologyType = nboTv.technologyTypeName;
                            lstUpgradeFee.add(feeProd);
                        }
                    }
                }
            }
            // Phone
        } else if (rec.nboPhone != null && String.isNotBlank(slTypeFN) && slTypeFN == NBA_Constants.TP_SOLIC_MOVIMENTACAO) {
            if (rec.nboPhone.fee != null && String.isNotBlank(rec.nboPhone.fee.price)) {
                valueUpgradeFee = Decimal.valueOf(rec.nboPhone.fee.price);
            } else {
                valueUpgradeFee = 0;
            }
            productType = NBA_Constants.NET_FONE;
            if (String.isNotBlank(rec.nboPhone.fee.paymentMethod)) {
                if (valueUpgradeFee == 0) {
                    setPaymentMethod.add(NBA_Constants.ISENTO);
                } else {
                    setPaymentMethod.addAll(rec.nboPhone.fee.paymentMethod.split(NBA_Constants.SEPARADOR_FORMA_PAGAMENTO));
                }
            }
        }
        if (!setPaymentMethod.isEmpty() && lstUpgradeFee.isEmpty()) {
            for (String method : setPaymentMethod) {
                NBA_OfferComparator_CC.Fee feeProd = new NBA_OfferComparator_CC.Fee();
                feeProd.label = productType;
                feeProd.paymentMethod = method;
                feeProd.value = valueUpgradeFee;
                lstUpgradeFee.add(feeProd);
            }
        }
        if (lstUpgradeFee.size() > 0) {
            oferta.paymentMethodUpgrade = lstUpgradeFee[0].paymentMethod;
            oferta.vlUpgradeFee = String.valueOf(valueUpgradeFee);
            oferta.productFee = productType;
        }
        return lstUpgradeFee;
    }
    private static List<NBA_OfferComparator_CC.Fee> filterLstFee(NBA_OfferComparator_CC.Offer offer, List<Fee> lstFee) {
        List<NBA_OfferComparator_CC.Fee> lstFiltered = new List<NBA_OfferComparator_CC.Fee> ();
        for (NBA_OfferComparator_CC.Fee feeProd : lstFee) {
            if (offer.tv[0].technology == feeProd.technologyType) {
                lstFiltered.add(feeProd);
            }
        }
        return lstFiltered;
    }
    
    @AuraEnabled
    public static Boolean isPerfilRentencao(id recordId) {
        Boolean perfilRetencao;
        id id1 = userinfo.getProfileId();
        List<profile> lstprofile = [select Name from profile where id = :id1];
        for (Profile profileLoop : lstprofile) {
            if (profileLoop.Name == NBA_Constants.PROFILE_USERNAME_RETENCAO) {
                perfilRetencao = false;
            } else {
                perfilRetencao = true;
            }
        }
        return perfilRetencao;
    }

    @AuraEnabled
    public static Boolean isPurple(id recordId) {
        Boolean purple = false;
        List<Case> lstCase = [SELECT id, ContractNumber__c FROM Case WHERE id = :recordId];
        if (!lstCase.isEmpty()) {
            Id idContrato = lstCase[0].ContractNumber__c;
            if (idContrato != null) {
                List<Contract> lstContract = [SELECT Id, Segment__c, Segmentation__c FROM Contract WHERE id = :idContrato];
                if (!lstContract.isEmpty()) {
                    String segment = lstContract[0].Segmentation__c ;
                    if (segment != null && segment == 'PURPLE') {
                        purple = true;
                    }
                }
            }
        }
        return purple;
    }

    public static List<NBA_Penalty_Value__mdt> searchPenaltyValues() {
        List<NBA_Penalty_Value__mdt> values = [SELECT Label, Penalty__c FROM NBA_Penalty_Value__mdt];
        return values;
    }
    public static NBA_OfferComparator_CC.AdditionalTV getAdicionaisTV(NBA_OfferComparator_CC.Offer oferta,
            NBA_IntegrationModels.Recommendation rec,
            List<NBA_IntegrationModels.Extras> extras,
            Boolean isActualProduct) {
        Map<String, NBA_OfferComparator_CC.Additional> mapAdditional = new Map<String, NBA_OfferComparator_CC.Additional> ();
        NBA_OfferComparator_CC.AdditionalTV additionalTV = new NBA_OfferComparator_CC.AdditionalTV();
        // Adicionais de TV
        if (extras != null && !extras.isEmpty()) {
            for (NBA_IntegrationModels.Extras ex : extras) {
                if (ex.type == NBA_Constants.TV_A_LA_CARTE) {
                    NBA_OfferComparator_CC.Additional additional = new NBA_OfferComparator_CC.Additional();
                    additional.id = ex.id;
                    additional.label = ex.name;
                    additional.value = decimal.valueOf(ex.price);
                    additional.totalValue = decimal.valueOf(ex.price);
                    additional.solicitationType = ex.solicitationType;
                    additional.nameLegacy = ex.detail;
                    additional.detail = ex.detail;
                    additional.catalogName = ex.catalogName;
                    additional.productName = ex.productName;
                    additional.technologyType = ex.technologyType;
                    additional.checked = ex.isAlreadyIncluded == '1';
                    additional.disabled = !additional.checked;
                    additional.familyName = ex.familyName; // Alexandre Amaro 09-07 correção bugFix
                    additional.description = String.isNotBlank(ex.promotion.name) ? ex.promotion.name : null;
					additional.pointId			= ex.pointId;
                    Integer validFor = ex.promotion.discount.validFor != null ? ex.promotion.discount.validFor : null;
                    String startDate = String.isNotBlank(ex.promotion.discount.startDate) ? ex.promotion.discount.startDate : null;
                    Boolean isValid = isActualProduct ? validFor > 0 : true;
                    if (ex.promotion.discount.value != null && ex.promotion.discount.value > 0 && isValid) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        promo.key = ex.promotion.id;
                        promo.valid = ex.promotion.discount.validFor != null ? Integer.valueOf(ex.promotion.discount.validFor) : 0;
                        promo.value = Decimal.valueOf(ex.price) - ex.promotion.discount.value;
                        promo.discount = ex.promotion.discount.value;
                        promo.label = ex.promotion.name;
                        promo.description = ex.promotion.name;
                        additional.lstPromotions.add(promo);
                        if (additional.checked) {
                            NBA_OfferComparator_CC.ProductPromo promoShow = new NBA_OfferComparator_CC.ProductPromo();
                            promoShow.key = ex.promotion.id;
                            promoShow.valid = (ex.promotion.discount.validFor != null ? Integer.valueOf(ex.promotion.discount.validFor) : 0);
                            promoShow.value = Decimal.valueOf(ex.price) - ex.promotion.discount.value;
                            promoShow.discount = ex.promotion.discount.value;
                            promoShow.label = ex.name;
                            promoShow.description = ex.promotion.name;
                            additional.promoSelected = '0';
                            oferta.tv[oferta.tv.size() - 1].additionalTv.lstPromotions.add(promoShow);
                            oferta.tv[oferta.tv.size() - 1].additionalPromoValue += promoShow.value;
                        }
                    } else {
                        if (additional.checked) {
                            oferta.tv[oferta.tv.size() - 1].additionalTv.value += additional.value;
                        }
                    }
                    additionalTV.lstAdditionals.add(additional);
                }
            }
        }
        additionalTV.lstAdditionals = sortAdditionals(additionalTV.lstAdditionals);
        // Lista todas as opções disponíveis de tecnologia de acordo com a posse da tecnologia atual
        Set<String> setTechnology = new Set<String> ();
        Set<String> setTechnologyAPI = new Set<String> ();
        // Pontos opcionais de tv
        if (extras != null && !extras.isEmpty()) {
            Integer i = 0;
            for (NBA_IntegrationModels.Extras ex : extras) {
                if (ex.type == NBA_Constants.TV_PONTOS_ADICIONAIS) {
                    if (ex.isAlreadyIncluded != null && ex.isAlreadyIncluded.equals('0')) {
                        setTechnologyAPI.add(ex.technologyType);
                    }
                    NBA_OfferComparator_CC.Optional optional = new NBA_OfferComparator_CC.Optional();
                    optional.id = ex.id;
                    optional.label = ex.name;
                    optional.productName = ex.productName;
                    optional.catalogName = ex.catalogName;
                    optional.nameLegacy = ex.detail;
                    optional.familyName = ex.familyName;
                    
                    // quando PO já está na posse, e mantém na oferta, usa-se o 'price', clonando ele no pricing devido a referencias na tela
                    if(ex.isAlreadyIncluded.equals('1') && (ex.solicitationType==null || (ex.solicitationType!=null && !ex.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO))))
                        ex.additionalPoints.pricing = ex.price;
                    // quando PO já está na posse, e migra TV na oferta, usa-se o 'pricing', clonando ele no price devido a referencias na tela
                    else if(ex.isAlreadyIncluded.equals('1') && (ex.solicitationType!=null && ex.solicitationType.containsIgnoreCase(NBA_Constants.TP_SOLIC_MOVIMENTACAO)))
                        ex.price = ex.additionalPoints.pricing;
                    
                    optional.price = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                    optional.value = ex.additionalPoints.pricing != null ? Decimal.valueOf(ex.additionalPoints.pricing) : null;

                    optional.totalValue = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                    optional.solicitationType = ex.solicitationType;
                    optional.technologyType = ex.technologyType;
                    optional.isAlreadyIncluded = ex.isAlreadyIncluded != null && ex.isAlreadyIncluded.equals('1');
                    optional.promotion = new ProductPromo();
                    optional.promotion.label = ex.promotion.name;
                    optional.promotion.description = ex.promotion.description;
                    optional.promotion.discount = ex.promotion.discount.value;
                    optional.promotion.valid = ex.promotion.discount.validFor != null ? ex.promotion.discount.validFor : 0;
                    optional.pointId			= ex.pointId;
                    
                    if (i < 4 && ex.isAlreadyIncluded != null && ex.isAlreadyIncluded.equals('1')) {
                        optional.checked = true;
                        additionalTV.lstOptionalPoints.add(optional);
                        additionalTV.lstOptionalPointsRPA.add(optional);
                        setTechnology.add(ex.technologyType);
                        if (optional.promotion.discount == null || optional.promotion.discount == 0) {
                            if (ex.price != null && Decimal.valueOf(ex.price) > 0) {
                                oferta.tv[oferta.tv.size() - 1].optionalPointsTv.quantity++;
                                oferta.tv[oferta.tv.size() - 1].optionalPointsTv.label = oferta.tv[oferta.tv.size() - 1].optionalPointsTv.quantity + NBA_Constants.PONTOS_OPCIONAIS;
                                oferta.tv[oferta.tv.size() - 1].optionalPointsTv.value += Decimal.valueOf(ex.price);
                            } else {
                                oferta.tv[oferta.tv.size() - 1].optionalPointsPromoTv.quantity++;
                                oferta.tv[oferta.tv.size() - 1].optionalPointsPromoTv.label = oferta.tv[oferta.tv.size() - 1].optionalPointsPromoTv.quantity + NBA_Constants.PONTOS_PROMOCIONAIS;
                                oferta.tv[oferta.tv.size() - 1].optionalPointsPromoTv.value = 0;
                            }
                        }
                        if (i == 0) {
                            additionalTV.firstPoint.id = ex.id;
                            additionalTV.firstPoint.checked = true;
                            additionalTV.firstPoint.disabled = false;
                            additionalTV.firstPoint.label = ex.technologyType;
                            additionalTV.firstPoint.nameLegacy = ex.detail;
                            additionalTV.firstPoint.familyName = ex.familyName;
                            additionalTV.firstPoint.solicitationType = ex.solicitationType;
                            additionalTV.firstPoint.technologyType = ex.technologyType;
                            additionalTV.firstPoint.isAlreadyIncluded = true;
                            additionalTV.firstPoint.totalValue = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                            additionalTV.firstPoint.price = additionalTV.firstPoint.value =  ex.additionalPoints.pricing != null ? Decimal.valueOf(ex.additionalPoints.pricing) : 0;
                            additionalTV.firstPoint.promotion = new NBA_OfferComparator_CC.ProductPromo();
                            additionalTV.firstPoint.promotion.label = ex.promotion.name;
                            additionalTV.firstPoint.promotion.description = ex.promotion.description;
                            additionalTV.firstPoint.promotion.discount = ex.promotion.discount.value;
                            additionalTV.firstPoint.promotion.valid = ex.promotion.discount.validFor;
                        } else if (i == 1) {
                            additionalTV.secondPoint.id = ex.id;
                            additionalTV.secondPoint.checked = true;
                            additionalTV.secondPoint.disabled = false;
                            additionalTV.secondPoint.label = ex.technologyType;
                            additionalTV.secondPoint.nameLegacy = ex.detail;
                            additionalTV.secondPoint.familyName = ex.familyName;
                            additionalTV.secondPoint.solicitationType = ex.solicitationType;
                            additionalTV.secondPoint.technologyType = ex.technologyType;
                            additionalTV.secondPoint.isAlreadyIncluded = true;
                            additionalTV.secondPoint.totalValue = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                            additionalTV.secondPoint.price = additionalTV.secondPoint.value =  ex.additionalPoints.pricing != null ? Decimal.valueOf(ex.additionalPoints.pricing) : 0;
                            additionalTV.secondPoint.promotion = new NBA_OfferComparator_CC.ProductPromo();
                            additionalTV.secondPoint.promotion.label = ex.promotion.name;
                            additionalTV.secondPoint.promotion.description = ex.promotion.description;
                            additionalTV.secondPoint.promotion.discount = ex.promotion.discount.value;
                            additionalTV.secondPoint.promotion.valid = ex.promotion.discount.validFor;
                        } else if (i == 2) {
                            additionalTV.thirdPoint.id = ex.id;
                            additionalTV.thirdPoint.checked = true;
                            additionalTV.thirdPoint.disabled = false;
                            additionalTV.thirdPoint.label = ex.technologyType;
                            additionalTV.thirdPoint.nameLegacy = ex.detail;
                            additionalTV.thirdPoint.familyName = ex.familyName;
                            additionalTV.thirdPoint.solicitationType = ex.solicitationType;
                            additionalTV.thirdPoint.technologyType = ex.technologyType;
                            additionalTV.thirdPoint.isAlreadyIncluded = true;
                            additionalTV.thirdPoint.totalValue = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                            additionalTV.thirdPoint.price = additionalTV.thirdPoint.value =  ex.additionalPoints.pricing != null ? Decimal.valueOf(ex.additionalPoints.pricing) : 0;
                            additionalTV.thirdPoint.promotion = new NBA_OfferComparator_CC.ProductPromo();
                            additionalTV.thirdPoint.promotion.label = ex.promotion.name;
                            additionalTV.thirdPoint.promotion.description = ex.promotion.description;
                            additionalTV.thirdPoint.promotion.discount = ex.promotion.discount.value;
                            additionalTV.thirdPoint.promotion.valid = ex.promotion.discount.validFor;
                        } else if (i == 3) {
                            additionalTV.fourthPoint.id = ex.id;
                            additionalTV.fourthPoint.checked = true;
                            additionalTV.fourthPoint.disabled = false;
                            additionalTV.fourthPoint.label = ex.technologyType;
                            additionalTV.fourthPoint.nameLegacy = ex.detail;
                            additionalTV.fourthPoint.familyName = ex.familyName;
                            additionalTV.fourthPoint.solicitationType = ex.solicitationType;
                            additionalTV.fourthPoint.technologyType = ex.technologyType;
                            additionalTV.fourthPoint.isAlreadyIncluded = true;
                            additionalTV.fourthPoint.totalValue = ex.price != null ? Decimal.valueOf(ex.price) : 0;
                            additionalTV.fourthPoint.price = additionalTV.fourthPoint.value =  ex.additionalPoints.pricing != null ? Decimal.valueOf(ex.additionalPoints.pricing) : 0;
                            additionalTV.fourthPoint.promotion = new NBA_OfferComparator_CC.ProductPromo();
                            additionalTV.fourthPoint.promotion.label = ex.promotion.name;
                            additionalTV.fourthPoint.promotion.description = ex.promotion.description;
                            additionalTV.fourthPoint.promotion.discount = ex.promotion.discount.value;
                            additionalTV.fourthPoint.promotion.valid = ex.promotion.discount.validFor;
                        }
                        i++;
                    } else {
                        additionalTV.lstOptionalPointsPriceAPI.add(optional);
                        additionalTV.lstOptionalPointsPriceAPIByTechnology = new List<Optional>();
                        for (NBA_OfferComparator_CC.Optional op : additionalTV.lstOptionalPointsPriceAPI) {
                            if (op.label == oferta.tv[0].technology) {
                                additionalTV.lstOptionalPointsPriceAPIByTechnology.add(op);
                            }
                        }
                    }
                }
            }
        }
        // Lista de controle da quantidade de pontos por tecnologia
        List<NBA_OfferComparator_CC.Optional> lstTechnology = new List<NBA_OfferComparator_CC.Optional> ();
        List<NBA_OfferComparator_CC.Optional> lstTechnologyAPI = new List<NBA_OfferComparator_CC.Optional> ();
        for (String tech : setTechnology) {
            NBA_OfferComparator_CC.Optional op = new NBA_OfferComparator_CC.Optional();
            op.label = tech;
            op.quantity = 0;
            lstTechnology.add(op);
        }
        for (String tech : setTechnologyAPI) {
            NBA_OfferComparator_CC.Optional op = new NBA_OfferComparator_CC.Optional();
            op.label = tech;
            op.quantity = 0;
            lstTechnologyAPI.add(op);
        }
        additionalTV.lstTechnology = lstTechnology;
        additionalTV.lstTechnologyAPI = lstTechnologyAPI;
        // Controle de tecnologia 4k e HD MAX
        additionalTV.fourKTechnology.checked = false;
        additionalTV.fourKTechnology.disabled = true;
        additionalTV.recordTechnology.checked = false;
        additionalTV.recordTechnology.disabled = true;
        if (rec != null) {
            for (NBA_IntegrationModels.NboTv tv : rec.nboTv) {
                if (tv.technologyTypeName.containsIgnoreCase(NBA_Constants.TECNOLOGIA_4K)) {
                    additionalTV.fourKTechnology.disabled = false;
                    if (rec.nboTv[0].technologyTypeName.containsIgnoreCase(NBA_Constants.TECNOLOGIA_4K)) {
                        additionalTV.fourKTechnology.checked = true;
                    }
                } else if (tv.technologyTypeName.containsIgnoreCase('MAX')) {
                    additionalTV.recordTechnology.disabled = false;
                    if (rec.nboTv[0].technologyTypeName.containsIgnoreCase('MAX')) {
                        additionalTV.recordTechnology.checked = true;
                    }
                }
            }
        }
        return additionalTV;
    }
    private static List<NBA_OfferComparator_CC.Additional> sortAdditionals(List<NBA_OfferComparator_CC.Additional> additionals) {
        List<String> addWithPromo = new List<String> ();
        List<String> addNoPromo = new List<String> ();
        List<NBA_OfferComparator_CC.Additional> allAdditionalsSorted = new List<NBA_OfferComparator_CC.Additional> ();
        List<NBA_OfferComparator_CC.Additional> lstAdditionalsWithPromo = new List<NBA_OfferComparator_CC.Additional> ();
        List<NBA_OfferComparator_CC.Additional> lstAdditionalsNoPromo = new List<NBA_OfferComparator_CC.Additional> ();
        // Divide os adicionais em listas de com ou sem promoção
        for (NBA_OfferComparator_CC.Additional add : additionals) {
            if (add.lstPromotions.isEmpty()) {
                addNoPromo.add(add.label);
                lstAdditionalsNoPromo.add(add);
            } else {
                addWithPromo.add(add.label);
                lstAdditionalsWithPromo.add(add);
            }
        }
        // Ordena pelo nome do adicional
        addNoPromo.sort();
        addWithPromo.sort();
        // Adiciona na lista de todos os adicionais ordenados, começando dos adicionais com promoção
        for (String promo : addWithPromo) {
            for (Integer i = 0; i < lstAdditionalsWithPromo.size(); i++) {
                if (lstAdditionalsWithPromo.get(i).label.equals(promo)) {
                    allAdditionalsSorted.add(lstAdditionalsWithPromo.get(i));
                    lstAdditionalsWithPromo.remove(i);
                    break;
                }
            }
        }
        for (String promo : addNoPromo) {
            for (Integer j = 0; j < lstAdditionalsNoPromo.size(); j++) {
                if (lstAdditionalsNoPromo.get(j).label.equals(promo)) {
                    allAdditionalsSorted.add(lstAdditionalsNoPromo.get(j));
                    lstAdditionalsNoPromo.remove(j);
                    break;
                }
            }
        }
        return allAdditionalsSorted;
    }
    private static NBA_IntegrationModels.Recommendation setActionsMoviment(NBA_IntegrationModels.Recommendation rec) {
        switch on rec.actionTv {
            when '1' {
                rec.actionTv = NBA_Constants.MOVIMENTO_AQUISICAO;
            }
            when '2' {
                rec.actionTv = NBA_Constants.MOVIMENTO_CANCELAMENTO;
            }
            when '3' {
                rec.actionTv = NBA_Constants.MOVIMENTO_UPGRADE;
            }
            when '4' {
                rec.actionTv = NBA_Constants.MOVIMENTO_DOWNGRADE;
            }
            when '5' {
                rec.actionTv = NBA_Constants.MOVIMENTO_LATERAL;
            }
            when else {
                rec.actionTv = NBA_Constants.MOVIMENTO_NENHUM;
            }
        }
        switch on rec.actionBroadband {
            when '1' {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_AQUISICAO;
            }
            when '2' {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_CANCELAMENTO;
            }
            when '3' {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_UPGRADE;
            }
            when '4' {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_DOWNGRADE;
            }
            when '5' {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_LATERAL;
            }
            when else {
                rec.actionBroadband = NBA_Constants.MOVIMENTO_NENHUM;
            }
        }
        switch on rec.actionPhone {
            when '1' {
                rec.actionPhone = NBA_Constants.MOVIMENTO_AQUISICAO;
            }
            when '2' {
                rec.actionPhone = NBA_Constants.MOVIMENTO_CANCELAMENTO;
            }
            when '3' {
                rec.actionPhone = NBA_Constants.MOVIMENTO_UPGRADE;
            }
            when '4' {
                rec.actionPhone = NBA_Constants.MOVIMENTO_DOWNGRADE;
            }
            when '5' {
                rec.actionPhone = NBA_Constants.MOVIMENTO_LATERAL;
            }
            when else {
                rec.actionPhone = NBA_Constants.MOVIMENTO_NENHUM;
            }
        }
        switch on rec.actionMobile {
            when '1' {
                rec.actionMobile = NBA_Constants.MOVIMENTO_AQUISICAO;
            }
            when '2' {
                rec.actionMobile = NBA_Constants.MOVIMENTO_CANCELAMENTO;
            }
            when '3' {
                rec.actionMobile = NBA_Constants.MOVIMENTO_UPGRADE;
            }
            when '4' {
                rec.actionMobile = NBA_Constants.MOVIMENTO_DOWNGRADE;
            }
            when '5' {
                rec.actionMobile = NBA_Constants.MOVIMENTO_LATERAL;
            }
            when else {
                rec.actionMobile = NBA_Constants.MOVIMENTO_NENHUM;
            }
        }
        return rec;
    }
    @TestVisible
    private static NBA_OfferComparator_CC.Offer setPenalties(NBA_OfferComparator_CC.Offer current, String caseId) {
        List<NBA_Penalty_Value__mdt> values = searchPenaltyValues();
        Map<String, Decimal> mpPenalties = new Map<String, Decimal> ();
        Decimal feeTV;
        Decimal feeBroadband;
        Decimal feePhone;
        Id recordId;
        Date dataAtendimento = [SELECT Id, CreatedDate FROM Case WHERE Id = :caseId].CreatedDate.date();
        Date today = system.today();
        for (NBA_Penalty_Value__mdt value : values) {
            mpPenalties.put(value.Label, value.Penalty__c);
        }
        if (!isPerfilRentencao(recordId)) {
            feeTv = mpPenalties.get('TV_Retencao') / 365;
            feeBroadband = mpPenalties.get('BL_Retencao') / 365;
            feePhone = mpPenalties.get('FN_Retencao') / 365;
        } else {
            feeTv = mpPenalties.get('TV_Rentabilizacao') / 365;
            feeBroadband = mpPenalties.get('BL_Rentabilizacao') / 365;
            feePhone = mpPenalties.get('FN_Rentabilizacao') / 365;
        }
        if (current.tv[0].planTv.fidelity.hasFidelity) {
            if (current.tv[0].planTv.label != NBA_Constants.NAO_POSSUI) {
                Date startDateTv;
                if (current.tv[0].planTv.fidelity.startDate != null) {
                    startDateTv = Date.valueOf(current.tv[0].planTv.fidelity.startDate);
                }
                if (startDateTv != null) {
                    //Integer pastDays = startDateTv.daysBetween(dataAtendimento);
                    Integer pastDays = startDateTv.daysBetween(today);
                    if (pastDays < 365) {
                        Integer remainingDays = 365 - pastDays;
                        current.tv[0].planTv.fidelity.remainingDays = remainingDays;
                        current.tv[0].planTv.fidelity.penalty = remainingDays * feeTV;
                        current.tv[0].planTv.fidelity.hasPenalty = true;
                    } else {
                        current.tv[0].planTv.fidelity.hasPenalty = false;
                    }
                } else {
                    current.tv[0].planTv.fidelity.hasPenalty = false;
                }
            }
        }
        if (current.broadband.planBroadband.fidelity.hasFidelity) {
            if (current.broadband.planBroadband.label != NBA_Constants.NAO_POSSUI) {
                Date startDateBL;
                if (current.broadband.planBroadband.fidelity.startDate != null) {
                    startDateBL = Date.valueOf(current.broadband.planBroadband.fidelity.startDate);
                }
                if (startDateBL != null) {
                    //Integer pastDays = startDateTv.daysBetween(dataAtendimento);
                    Integer pastDays = startDateBL.daysBetween(today);
                    if (pastDays < 365) {
                        Integer remainingDays = 365 - pastDays;
                        current.broadband.planBroadband.fidelity.remainingDays = remainingDays;
                        current.broadband.planBroadband.fidelity.penalty = remainingDays * feeBroadband;
                        current.broadband.planBroadband.fidelity.hasPenalty = true;
                    } else {
                        current.broadband.planBroadband.fidelity.hasPenalty = false;
                    }
                } else {
                    current.broadband.planBroadband.fidelity.hasPenalty = false;
                }
            }
        }
        if (current.phone.planPhone.fidelity.hasFidelity) {
            if (current.phone.planPhone.label != NBA_Constants.NAO_POSSUI) {
                Date startDateFN;
                if (current.phone.planPhone.fidelity.startDate != null) {
                    startDateFN = Date.valueOf(current.phone.planPhone.fidelity.startDate);
                }
                if (startDateFN != null) {
                    //Integer pastDays = startDateTv.daysBetween(dataAtendimento);
                    Integer pastDays = startDateFN.daysBetween(today);
                    if (pastDays < 365) {
                        Integer remainingDays = 365 - pastDays;
                        current.phone.planPhone.fidelity.remainingDays = remainingDays;
                        current.phone.planPhone.fidelity.penalty = remainingDays * feePhone;
                        current.phone.planPhone.fidelity.hasPenalty = true;
                    } else {
                        current.phone.planPhone.fidelity.hasPenalty = false;
                    }
                } else {
                    current.phone.planPhone.fidelity.hasPenalty = false;
                }
            }
        }
        current.totalPenalty = current.tv[0].planTv.fidelity.penalty +
                current.broadband.planBroadband.fidelity.penalty +
                current.phone.planPhone.fidelity.penalty;
        return current;
    }
    public static NBA_OfferComparator_CC.AdditionalBroadband getAdicionaisBandaLarga(NBA_OfferComparator_CC.Offer current,
            NBA_OfferComparator_CC.Offer rec,
            List<NBA_IntegrationModels.Extras> extras,
            Boolean isActualProduct) {
        Map<String, NBA_OfferComparator_CC.Additional> mapAdditional = new Map<String, NBA_OfferComparator_CC.Additional> ();
        NBA_OfferComparator_CC.AdditionalBroadband additionalBroadband = new NBA_OfferComparator_CC.AdditionalBroadband();
        // Adicionais de Banda larga
        if (extras != null && !extras.isEmpty()) {
            for (NBA_IntegrationModels.Extras ex : extras) {
                if (ex.type == NBA_Constants.BL_ADICIONAIS) {
                    NBA_OfferComparator_CC.Additional additional = new NBA_OfferComparator_CC.Additional();
                    //if (!mapAdditional.containsKey(ex.Id)) {
                    additional.id = ex.id;
                    additional.label = ex.name;
                    additional.nameLegacy = ex.detail;
                    additional.value = decimal.valueOf(ex.price);
                    additional.totalValue = decimal.valueOf(ex.price);
                    additional.solicitationType = ex.solicitationType;
                    additional.technologyType = ex.technologyType;
                    additional.checked = ex.isAlreadyIncluded == '1' ? true : false;
                    additional.familyName = ex.familyName; // Alexandre Amaro 09-07 correção bugFix
                    additional.description = String.isNotBlank(ex.promotion.name) ? ex.promotion.name : null;
					additional.pointId = ex.pointId;
                    //mapAdditional.put(ex.Id, additional);
                    //}
                    //additional = mapAdditional.get(ex.Id);
                    if (ex.promotion.discount.value != null && ex.promotion.discount.value > 0) {
                        //NBA_OfferComparator_CC.ProductPromo selecione = new NBA_OfferComparator_CC.ProductPromo();
                        //selecione.label = 'Selecione...';
                        //additional.lstPromotions.add(selecione);
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        if (isActualProduct) {
                            promo.valid = String.isNotBlank(ex.promotion.validFor) ? getValid(ex.promotion.discount.startDate, Integer.valueOf(ex.promotion.validFor)) : null;
                        } else {
                            promo.valid = (ex.promotion.discount.validFor != null ? Integer.valueOf(ex.promotion.discount.validFor) : 0);
                        }
                        promo.value = ex.promotion.discount.value != null ? ex.promotion.discount.value : 0;
                        promo.discount = ex.promotion.discount.value;
                        promo.label = ex.promotion.name;
                        if (additional.checked) {
                            NBA_OfferComparator_CC.ProductPromo promoShow = new NBA_OfferComparator_CC.ProductPromo();
                            promoShow.key = ex.promotion.id;
                            promoShow.valid = (ex.promotion.discount.validFor != null ? Integer.valueOf(ex.promotion.discount.validFor) : 0);
                            promoShow.value = Decimal.valueOf(ex.price) - ex.promotion.discount.value;
                            promoShow.discount = ex.promotion.discount.value;
                            promoShow.label = ex.name;
                            promoShow.description = ex.promotion.name;
                            additional.promoSelected = '0';
                            rec.broadband.additionalBroadband.lstPromotions.add(promoShow);
                            rec.broadband.additionalPromoValue += promoShow.value;
                        }
                        //if (promo.valid != null && promo.valid > 0) {
                        //promo.label = promo.label + ' - ' + promo.valid + ' meses';
                        //}
                        additional.lstPromotions.add(promo);
                    }
                    mapAdditional.put(ex.Id, additional);
                    //if (current.broadband != null && current.broadband.addOptions.lstAdditionals != null && !current.broadband.addOptions.lstAdditionals.isEmpty()) {
                    //for (NBA_OfferComparator_CC.Additional addCurrent : current.broadband.addOptions.lstAdditionals) {
                    //if (addCurrent.id == additional.id) {
                    //additional.checked = true;
                    //}
                    //}
                    //}
                }
            }
        }
        additionalBroadband.lstAdditionals.addAll(mapAdditional.values());
        additionalBroadband.lstAdditionals = sortAdditionals(additionalBroadband.lstAdditionals);
        List<NBA_OfferComparator_CC.Optional> lstProtecaoDigital = new List<NBA_OfferComparator_CC.Optional> ();
        NBA_OfferComparator_CC.Optional op1 = new NBA_OfferComparator_CC.Optional();
        op1.price = 19.9;
        op1.label = '1 por R$ ' + op1.price;
        op1.value = 0;
        op1.quantity = 1;
        lstProtecaoDigital.add(op1);
        NBA_OfferComparator_CC.Optional op2 = new NBA_OfferComparator_CC.Optional();
        op2.price = 29.9;
        op2.label = '2 por R$ ' + op2.price;
        op2.value = 1;
        op2.quantity = 2;
        lstProtecaoDigital.add(op2);
        NBA_OfferComparator_CC.Optional op3 = new NBA_OfferComparator_CC.Optional();
        op3.price = 39.9;
        op3.label = '3 por R$ ' + op3.price;
        op3.value = 2;
        op3.quantity = 3;
        lstProtecaoDigital.add(op3);
        additionalBroadband.lstProtecaoDigital = lstProtecaoDigital;
        List<NBA_OfferComparator_CC.Optional> lstSmartHomeMonitor = new List<NBA_OfferComparator_CC.Optional> ();
        NBA_OfferComparator_CC.Optional s1 = new NBA_OfferComparator_CC.Optional();
        s1.quantity = 4;
        s1.label = 'Tudo: Monitoramento + 4 Câmeras';
        s1.value = 0;
        lstSmartHomeMonitor.add(s1);
        NBA_OfferComparator_CC.Optional s2 = new NBA_OfferComparator_CC.Optional();
        s2.quantity = 1;
        s2.label = '1 Câmera';
        s2.value = 1;
        lstSmartHomeMonitor.add(s2);
        NBA_OfferComparator_CC.Optional s3 = new NBA_OfferComparator_CC.Optional();
        s3.quantity = 2;
        s3.label = '2 Câmeras';
        s3.value = 2;
        lstSmartHomeMonitor.add(s3);
        NBA_OfferComparator_CC.Optional s4 = new NBA_OfferComparator_CC.Optional();
        s4.quantity = 3;
        s4.label = '3 Câmeras';
        s4.value = 3;
        lstSmartHomeMonitor.add(s4);
        NBA_OfferComparator_CC.Optional s5 = new NBA_OfferComparator_CC.Optional();
        s5.quantity = 4;
        s5.label = '4 Câmeras';
        s5.value = 4;
        lstSmartHomeMonitor.add(s5);
        additionalBroadband.lstSmartHomeMonitor = lstSmartHomeMonitor;
        List<NBA_OfferComparator_CC.Optional> lstSmartHomeAutomacao = new List<NBA_OfferComparator_CC.Optional> ();
        NBA_OfferComparator_CC.Optional a1 = new NBA_OfferComparator_CC.Optional();
        a1.quantity = 2;
        a1.label = 'Tudo: Automação + 2 Câmeras';
        a1.value = 0;
        lstSmartHomeAutomacao.add(a1);
        NBA_OfferComparator_CC.Optional a2 = new NBA_OfferComparator_CC.Optional();
        a2.quantity = 1;
        a2.label = '1 Câmera';
        a2.value = 1;
        lstSmartHomeAutomacao.add(a2);
        NBA_OfferComparator_CC.Optional a3 = new NBA_OfferComparator_CC.Optional();
        a3.quantity = 2;
        a3.label = '2 Câmeras';
        a3.value = 2;
        lstSmartHomeAutomacao.add(a3);
        additionalBroadband.lstSmartHomeAutomacao = lstSmartHomeAutomacao;
        additionalBroadband.protecaoDigitalSelected = '';
        additionalBroadband.smartHomeMonitorSelected = '';
        additionalBroadband.smartHomeAutomacaoSelected = '';
        return additionalBroadband;
    }
    public static NBA_OfferComparator_CC.AdditionalPhone getAdicionaisPhone(NBA_OfferComparator_CC.Offer current) {
        NBA_OfferComparator_CC.AdditionalPhone additionalPhone = new NBA_OfferComparator_CC.AdditionalPhone();
        return AdditionalPhone;
    }
    public static NBA_OfferComparator_CC.AdditionalMobile getAdicionaisMovel(NBA_OfferComparator_CC.Offer current,
            NBA_OfferComparator_CC.Offer rec,
            List<NBA_IntegrationModels.Extras> extras,
            Boolean isActualProduct) {
        Map<String, NBA_OfferComparator_CC.Additional> mapAdditional = new Map<String, NBA_OfferComparator_CC.Additional> ();
        NBA_OfferComparator_CC.AdditionalMobile additionalMobile = new NBA_OfferComparator_CC.AdditionalMobile();
        // Adicionais de Móvel
        if (extras != null && !extras.isEmpty()) {
            for (NBA_IntegrationModels.Extras ex : extras) {
                if (ex.type == NBA_Constants.MOVEL_ADICIONAIS) {
                    NBA_OfferComparator_CC.Additional additional = new NBA_OfferComparator_CC.Additional();
                    if (!mapAdditional.containsKey(ex.Id)) {
                        additional.id = ex.id;
                        additional.label = ex.name;
                        additional.nameLegacy = ex.detail;
                        additional.value = decimal.valueOf(ex.price);
                        additional.solicitationType = ex.solicitationType;
                        additional.technologyType = ex.technologyType;
                        additional.familyName = ex.familyName; // Alexandre Amaro 09-07 correção bugFix
                        additional.description = String.isNotBlank(ex.promotion.name) ? ex.promotion.name : null;
						additional.pointId = ex.pointId;
                        mapAdditional.put(ex.Id, additional);
                    }
                    additional = mapAdditional.get(ex.Id);
                    if (ex.promotion.discount.value != null && ex.promotion.discount.value > 0) {
                        NBA_OfferComparator_CC.ProductPromo promo = new NBA_OfferComparator_CC.ProductPromo();
                        if (isActualProduct) {
                            promo.valid = String.isNotBlank(ex.promotion.validFor) ? getValid(ex.promotion.discount.startDate, Integer.valueOf(ex.promotion.validFor)) : null;
                        } else {
                            promo.valid = ex.promotion.validFor != null ? Integer.valueOf(ex.promotion.validFor) : null;
                        }
                        promo.value = ex.promotion.discount.value != null ? ex.promotion.discount.value : 0;
                        promo.discount = ex.promotion.discount.value;
                        promo.label = ex.promotion.name;
                        //promo.label = 'Desconto R$' + promo.discount;
                        //if (promo.valid != null && promo.valid > 0) {
                        //promo.label = promo.label + ' ' + promo.valid + ' meses';
                        //}
                        additional.lstPromotions.add(promo);
                    }
                    if (current.mobile != null && current.mobile.addOptions.lstAdditionals != null && !current.mobile.addOptions.lstAdditionals.isEmpty()) {
                        for (NBA_OfferComparator_CC.Additional addCurrent : current.mobile.addOptions.lstAdditionals) {
                            if (addCurrent.id == additional.id) {
                                additional.checked = true;
                            }
                        }
                    }
                }
            }
        }
        additionalMobile.lstAdditionals.addAll(mapAdditional.values());
        additionalMobile.lstAdditionals = sortAdditionals(additionalMobile.lstAdditionals);
        return additionalMobile;
    }
    private static NBA_IntegrationModels.CurrentProductResponse consultarProdutoAtual(Id recordId) {
        NBA_IntegrationModels.CurrentProductResponse response = new NBA_IntegrationModels.CurrentProductResponse();
        List<Case> lstCase = [SELECT ContractNumber__r.ContractNumber__c, ContractNumber__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c,ContractBillingAccount__r.CityCode__c,RecordType.DeveloperName, Movel__c FROM Case WHERE Id = :recordId];
        String operatorId = '';
        String contractNumber = '';
        if (!lstCase.isEmpty() && lstCase[0].recordType.DeveloperName != 'Financial') {
            operatorId = lstCase[0].ContractNumber__r.CityCode__c;
            contractNumber = lstCase[0].ContractNumber__r.ContractNumber__c;
        }else if(!lstCase.isEmpty() && lstCase[0].recordType.DeveloperName == 'Financial'){
            operatorId = lstCase[0].ContractBillingAccount__r.CityCode__c;
            contractNumber = lstCase[0].ContractBillingAccount__r.ContractReferenceNumber__c;
        }
        if (String.isNotBlank(contractNumber) && String.isNotBlank(operatorId)) {
            Map<String, Object> request = new Map<String, Object> ();
            request.put('operatorId', operatorId);
            request.put('contractNumber', contractNumber);
            request.put('msisdn', ''); // TODO - ainda falta definir origem
            response = NBA_IntegrationServices.getCurrentProduct(request);
            
            // tratamento da posse
			if(response!=null && response.data!=null && response.data.contractProducts!=null && !response.data.contractProducts.isEmpty()){
                
                // remove ponto add de tv do tipo 'acesso virtua'
                for(Integer index=response.data.contractProducts.size()-1; index>=0; index--)
                    if(response.data.contractProducts[index].catalogName==NBA_Constants.ACESSO_VIRTUA && response.data.contractProducts[index].productType==NBA_Constants.TV_PONTOS_ADICIONAIS)
                         response.data.contractProducts.remove(index);
                
                // remove posse móvel quando: atendimento retenção + segmento não é purple + sondagem móvel não marcada + tem posse movel 
                if(!isPerfilRentencao(recordId) && !isPurple(recordId) && !lstCase[0].Movel__c)
                    for(Integer index=response.data.contractProducts.size()-1; index>=0; index--)
                        if(response.data.contractProducts[index].productType.startsWith('MOVEL') ||  response.data.contractProducts[index].productType.startsWith('DESCONTO_AGREGADO'))
                            response.data.contractProducts.remove(index);

                // absorve no registro principal do titular movel, outros valores do proprio titular, descartando os demais
                List<NBA_IntegrationModels.ContractProduct> allMobileProducts = new List<NBA_IntegrationModels.ContractProduct>();
                for(Integer index=response.data.contractProducts.size()-1; index>=0; index--)
                    if(response.data.contractProducts[index].productType==NBA_Constants.MOVEL_ASSINATURA){
                        allMobileProducts.add(response.data.contractProducts[index]);
                        response.data.contractProducts.remove(index);
                    }
                allMobileProducts.sort();
                Map<String, NBA_IntegrationModels.ContractProduct> filteredMobileProducts = new Map<String, NBA_IntegrationModels.ContractProduct>();
                for(Integer index=allMobileProducts.size()-1; index>=0; index--)
                    if(!filteredMobileProducts.containsKey(allMobileProducts[index].msisdn))
                        filteredMobileProducts.put(allMobileProducts[index].msisdn, allMobileProducts[index]);
                    else
                        filteredMobileProducts.get(allMobileProducts[index].msisdn).pricing += allMobileProducts[index].pricing;
                response.data.contractProducts.addAll(filteredMobileProducts.values());
            }

        }
        return response;
    }

    @AuraEnabled
    public static void updateStageAndExceptionNoReturn(id recordId, String Exceptions, String mensagemSemOfertas) {
        List<Case> lstCase = [SELECT Id, Time_of_Service__c, Exceptions__c FROM Case where id = :recordId];
        if (!lstCase.isEmpty()) {
            Case a = lstCase[0];
            a.Time_of_Service__c = 'Encerramento do atendimento';
            a.CallResultIndt__c = 'Com Ação';
            a.Exceptions__c = Exceptions;
            update a;

            insertCaseComment(recordId, mensagemSemOfertas);
        }
    }

    public static Date convertDatetimeToDate(String dt) {
        Datetime dtReferencia = Datetime.valueOf(dt);
        return Date.newInstance(dtReferencia.year(), dtReferencia.month(), dtReferencia.day());
    }

    public static NBA_IntegrationModels.Extras fillAdditional(NBA_IntegrationModels.ContractProduct product) {
        NBA_IntegrationModels.Discount discount = new NBA_IntegrationModels.Discount();
        discount.value = (product.pricing != null ? product.pricing : 0) - (product.deducedPrice != null ? product.deducedPrice : 0);
        NBA_IntegrationModels.ProductPromotion promot = new NBA_IntegrationModels.ProductPromotion();
        promot.name = product.promotionName;
        promot.discount = discount;
        if (product.discount != null) {
            promot.validFor = String.valueOf(product.discount.duration != null ? product.discount.duration : 0);
            promot.experimentalFor = product.discount.startDate;
        }
        NBA_IntegrationModels.Extras ex = new NBA_IntegrationModels.Extras();
        ex.id = product.productId;
        ex.name = product.catalogName;
        ex.productName = product.productName;
        ex.catalogName = product.catalogName;
        ex.solicitationType = product.solicitationType;
        ex.detail = product.detail;
        if (product.newExtra != null && product.newExtra == false) {
            ex.isAlreadyIncluded = '0';
        } else {
            ex.isAlreadyIncluded = '1';
        }
        ex.price = String.valueOf(product.pricing != null ? product.pricing : 0);
        ex.type = product.productType;
        if (product.productDetail.containsIgnoreCase(NBA_Constants.TECNOLOGIA_4K)) {
            ex.technologyType = NBA_Constants.TECNOLOGIA_4K;
        } else if (product.productDetail.containsIgnoreCase('MAX')) {
            ex.technologyType = 'MAX';
        } else {
            ex.technologyType = 'HD';
        }
        ex.promotion = new NBA_IntegrationModels.ProductPromotion();
        ex.promotion.name = product.promotionName;
        ex.promotion.validFor = promot.validFor;
        ex.promotion.discount = new NBA_IntegrationModels.Discount();
        Integer qtdMes = 0;
        if (promot.validFor != null && String.isNotBlank(promot.validFor)) {
            qtdMes = Integer.valueOf(promot.validFor);
        }
        ex.promotion.discount.validFor = getQtdMonth(promot.experimentalFor, qtdMes);
        ex.promotion.discount.value = product.deducedPrice;
        ex.promotion.discount.startDate = promot.experimentalFor;
        ex.additionalPoints = new NBA_IntegrationModels.AdditionalPoint();



        ex.additionalPoints.pricing = String.valueOf(product.pricing != null ? product.pricing : 0);
		ex.pointId = product.pointId;
        return ex;
    }
    private static List<NBA_OfferComparator_CC.ProductPromo> sortLstPromotions(List<NBA_OfferComparator_CC.ProductPromo> lstPromotions) {
        Boolean changed;
        do {
            changed = false;
            for (NBA_OfferComparator_CC.ProductPromo promo : lstPromotions) {
                Integer indexActual = lstPromotions.indexOf(promo);
                if (indexActual < lstPromotions.size() - 1) {
                    if (Integer.valueOf(promo.valid) > Integer.valueOf(lstPromotions[indexActual + 1].valid)) {
                        NBA_OfferComparator_CC.ProductPromo temp = lstPromotions[indexActual + 1];
                        lstPromotions[indexActual + 1] = promo;
                        lstPromotions[indexActual] = temp;
                        changed = true;
                    }
                }
            }
        } while (changed);
        return lstPromotions;
    }
    @AuraEnabled
    public static string getIsencaoTaxas() {
        List<RPA_IsencaoTaxa__mdt> lstIsencoesTaxas = [SELECT TipoExibido__c, Valor__c, Tipo__c from RPA_IsencaoTaxa__mdt];
        return JSON.serialize(lstIsencoesTaxas);
    }

    @AuraEnabled
    public static String getSuspensionData() {
        List<NBA_TemporarySuspension__mdt> suspensions = [SELECT Label, Modality__c, Period__c,ProductIdPhone__c FROM NBA_TemporarySuspension__mdt ORDER BY Period__c];
        return JSON.serialize(suspensions);
    }

    @AuraEnabled
    public static String getSuspensionProducts() {
        List<NBA_ProductsTemporarySuspension__mdt> products = [SELECT ProductType__c, Sequence__c, Technology__c,ProductId__c, Label FROM NBA_ProductsTemporarySuspension__mdt ORDER BY ProductType__c, Sequence__c ];
        return JSON.serialize(products);
    }

    private static void getHoverMovel(List<NBA_IntegrationModels.ContractProduct> products, NBA_OfferComparator_CC.Offer currentProduct) {
        
        // calcula valores de totais + descontos de móveis, baseado na posse(api)
        Map<String, Decimal> mobileHover = new Map<String, Decimal>();
        mobileHover.put('Titular sem Desconto', 0);
        mobileHover.put('Titular Desconto', 0);
        mobileHover.put('Dependente sem Desconto PG', 0);
        mobileHover.put('Dependente Desconto PG', 0);
        mobileHover.put('Dependente sem Desconto BL', 0);
        mobileHover.put('Dependente Desconto BL', 0);
        mobileHover.put('Dependente sem Desconto CONTROLE', 0);
        mobileHover.put('Dependente Desconto CONTROLE', 0);

        Map<String, String> dependent = new Map<String, String>();
        for (NBA_IntegrationModels.ContractProduct product : products)
            if(product.productType=='MOVEL DEP')
                dependent.put(product.msisdn, product.productDetail);

        for (NBA_IntegrationModels.ContractProduct product : products) {
            if(product.productType=='MOVEL TITULAR')
                mobileHover.put('Titular sem Desconto', product.pricing + mobileHover.get('Titular sem Desconto'));
            else if(product.productType=='MOVEL DEP' && product.productDetail=='POS PG')
                mobileHover.put('Dependente sem Desconto PG', product.pricing + mobileHover.get('Dependente sem Desconto PG'));
            else if(product.productType=='MOVEL DEP' && product.productDetail=='POS BL')
                mobileHover.put('Dependente sem Desconto BL', product.pricing + mobileHover.get('Dependente sem Desconto BL'));
            else if(product.productType=='MOVEL DEP' && product.productDetail=='CONTROLE')
                mobileHover.put('Dependente sem Desconto CONTROLE', product.pricing + mobileHover.get('Dependente sem Desconto CONTROLE'));

            else if(product.productDetail=='DESCONTO_AGREGADO_CONTRATO' || product.productDetail=='DESCONTO_AGREGADO_NTC_TITULAR')
                mobileHover.put('Titular Desconto', product.deducedPrice + mobileHover.get('Titular Desconto'));
            else if(product.productDetail=='DESCONTO_AGREGADO_NTC_DEPENDENTE' && dependent.get(product.msisdn)=='POS PG')
                mobileHover.put('Dependente Desconto PG', product.deducedPrice + mobileHover.get('Dependente Desconto PG'));
            else if(product.productDetail=='DESCONTO_AGREGADO_NTC_DEPENDENTE' && dependent.get(product.msisdn)=='POS BL')
                mobileHover.put('Dependente Desconto BL', product.deducedPrice + mobileHover.get('Dependente Desconto BL'));
            else if(product.productDetail=='DESCONTO_AGREGADO_NTC_DEPENDENTE' && dependent.get(product.msisdn)=='CONTROLE')
                mobileHover.put('Dependente Desconto CONTROLE', product.deducedPrice + mobileHover.get('Dependente Desconto CONTROLE'));
        }

        System.Debug(json.serialize(mobileHover));

        // atualiza posse (obj) baseado nos valores calculados
        currentProduct.mobile.mouseOverValorSemDesconto =                   mobileHover.get('Titular Desconto')>0 ? 'Valor Após Desconto - ' + String.valueOf(mobileHover.get('Titular sem Desconto')) : '';
        currentProduct.mobile.mouseOverTitularSemDesconto =                 String.valueOf(mobileHover.get('Titular sem Desconto'));
        currentProduct.mobile.descontoTitular =                             mobileHover.get('Titular Desconto');
        currentProduct.mobile.planMobile.value =                            mobileHover.get('Titular sem Desconto') - mobileHover.get('Titular Desconto');
        
        currentProduct.mobile.mouseOverDependenteSemDescontoPG =            mobileHover.get('Dependente Desconto PG')>0 ? 'Valor Após Desconto - ' + String.valueOf(mobileHover.get('Dependente sem Desconto PG')) : '';
        currentProduct.mobile.descontoDependentePG =                        String.valueOf(mobileHover.get('Dependente Desconto PG'));
        currentProduct.mobile.mouseOverDependenteComDescontoPG =            String.valueOf(mobileHover.get('Dependente sem Desconto PG') - mobileHover.get('Dependente Desconto PG'));
        currentProduct.mobile.mouseOverDependenteSemDescontoBL =            mobileHover.get('Dependente Desconto BL')>0 ? 'Valor Após Desconto - ' + String.valueOf(mobileHover.get('Dependente sem Desconto BL')): '';
        currentProduct.mobile.descontoDependenteBL =                        String.valueOf(mobileHover.get('Dependente Desconto BL'));
        currentProduct.mobile.mouseOverDependenteComDescontoBL =            String.valueOf(mobileHover.get('Dependente sem Desconto BL') - mobileHover.get('Dependente Desconto BL'));
        currentProduct.mobile.mouseOverDependenteSemDescontoControle =      mobileHover.get('Dependente Desconto CONTROLE')>0 ? 'Valor Após Desconto - ' + String.valueOf(mobileHover.get('Dependente sem Desconto CONTROLE')) : '';
        currentProduct.mobile.descontoDependenteControle =                  String.valueOf(mobileHover.get('Dependente Desconto CONTROLE'));
        currentProduct.mobile.mouseOverDependenteComDescontoControle =      String.valueOf(mobileHover.get('Dependente sem Desconto CONTROLE') - mobileHover.get('Dependente Desconto CONTROLE'));
        
        // aplica descontos na posse(api) para posteriores cálculos
        for (NBA_IntegrationModels.ContractProduct discountProduct : products) {
            if(discountProduct.productDetail=='DESCONTO_AGREGADO_CONTRATO' || discountProduct.productDetail=='DESCONTO_AGREGADO_NTC_TITULAR'){
                for (NBA_IntegrationModels.ContractProduct mobileProduct : products)
                    if(mobileProduct.productType=='MOVEL TITULAR'){
                        mobileProduct.pricing -= discountProduct.deducedPrice;
                        break;
                    }
            }
            else if(discountProduct.productDetail=='DESCONTO_AGREGADO_NTC_DEPENDENTE'){
                for (NBA_IntegrationModels.ContractProduct mobileProduct : products)
                    if(mobileProduct.productType=='MOVEL DEP' && mobileProduct.pricing>0 && mobileProduct.msisdn==discountProduct.msisdn){
                        mobileProduct.pricing -= discountProduct.deducedPrice;
                        mobileProduct.possessionDiscount = discountProduct.deducedPrice;
                        break;
                    }
            }
        }
        for (NBA_IntegrationModels.ContractProduct mobileProduct : products)
            if((mobileProduct.productType=='MOVEL DEP' || mobileProduct.productType=='MOVEL TITULAR') && mobileProduct.possessionDiscount==null)
                mobileProduct.possessionDiscount = 0;

    }
   
    ///////////////////////////////////////////////  ALEXANDRE AMARO VIABILIDADE TECNICA ///////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static NBA_OfferComparator_CC.ResultViabilidade consultarViabilidade(String domicileIdNet, String operatorCodeNet) {
        NBA_OfferComparator_CC.ResultViabilidade result = new NBA_OfferComparator_CC.ResultViabilidade();
        Try {
            Map<String, Object> request = new Map<String, Object> ();
            request.put('operatorCodeNet', operatorCodeNet);
            request.put('domicileIdNet', domicileIdNet);
            request.put('clientType', 'BASE');
            System.debug('requestConsultarViablidade>>>>>' + JSON.serialize(request));
            NBA_IntegrationModels.ViabilidadeResponse response = NBA_IntegrationServices.getViabilidadeTecnica(request);
            System.debug('responseConsultarViablidade>>>>>' + JSON.serialize(response));
            if (response != null && response.data == null) {
                response.data = new NBA_IntegrationModels.ViabilidadeData();
            }
            //construção da logica
            if (response.data.domiciles != null && !response.data.domiciles.isEmpty()) {
                result.BSOD = verificarViabilidade(response.data.domiciles[0], 'BSOD');
                result.DIGITAL = verificarViabilidade(response.data.domiciles[0], 'DIGITAL') ;
                result.PTV = verificarViabilidade(response.data.domiciles[0], 'PTV');
                result.VIRTUA = verificarViabilidade(response.data.domiciles[0], 'VIRTUA');
                result.VOD = verificarViabilidade(response.data.domiciles[0], 'VOD');
                result.VOIP = verificarViabilidade(response.data.domiciles[0], 'VOIP');
            } else {
                result = null;
            }
        } catch (Exception e) {
            System.debug('[ERRO]: ' + e.getMessage() + ' [STACK]: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    @AuraEnabled
    public static Boolean verificarViabilidade(NBA_IntegrationModels.Domiciles domiciles, String tipo) {
        Boolean retorno = true;
        if (!domiciles.availability.isEmpty()) {
            for (NBA_IntegrationModels.Availability av : domiciles.availability) {
                if (av.businessLine.description == tipo) {
                    if (av.technicalSituation.contains('Não') || av.commercialSituation.contains('Não')) {
                        retorno = false;
                    }
                }
            }
        }
        return retorno;
    }
    @AuraEnabled
    public static AtualProductsBase ConsultarProdutosBase(id recordId) {
        AtualProductsBase Pds = new AtualProductsBase();
        List<Asset> ltAsset = new List<Asset> ();
        List<Case> lstCase = [SELECT Id, ContractNumber__c FROM Case WHERE Id = :recordId];
        if (!lstCase.isEmpty()) {
            String contractId = lstCase[0].ContractNumber__c;
            if (contractId != null) {
                ltAsset = [
                        SELECT Id,
                                RecordType.DeveloperName
                        FROM Asset
                        WHERE vlocity_cmt__ContractId__c = :contractId
                ];
                if (!ltAsset.isEmpty()) {
                    for (Asset a : ltAsset) {
                        if (String.isNotBlank(a.RecordType.DeveloperName)) {
                            switch on a.RecordType.DeveloperName {
                                when 'CECFixo' {
                                    Pds.hasFN = true;
                                }
                                when 'CECInternetFixa' {
                                    Pds.hasBL = true;
                                }
                                when 'CECMovel', 'CECInternetMovel', 'CECMovelPreControle' {
                                    Pds.hasMV = true;
                                }
                                when 'CECTV' {
                                    if (a.Name != 'ACESSO VIRTUA') {
                                        if (Pds.hasTV == false) {
                                            Pds.hasTV = false;
                                        } else if (Pds.hasTV == true) {
                                            Pds.hasTV = true;
                                        } else {
                                            Pds.hasTV = true;
                                        }
                                    } else {
                                        Pds.hasTV = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return Pds;
    }
    
    @AuraEnabled
    public static NBA_OfferComparator_CC.Retorno getOfertas(String recordId) {
        NBA_OfferComparator_CC.Retorno retornoTela = new NBA_OfferComparator_CC.Retorno();
        Case objCase = new Case();
        if(recordId.startsWith('500')){
            objCase  = [SELECT id, RecordType.DeveloperName FROM Case WHERE id = :recordId];
        }
        try {
            Boolean isNotRetencao = isPerfilRentencao(recordId);
            if (recordId != null && String.isNotBlank(recordId)) {
            
                System.debug('<<<GET OFERTAS>>>');
                NBA_OfferComparator_CC.Result retornoOfertaFinal = new NBA_OfferComparator_CC.Result();
                
                NBA_OfferComparator_CC.RetornoContratoResidencial retornoContratoResidencial;
                Boolean erroApiContratoResidencial=false;
                try {retornoContratoResidencial = consultarApiContratoResidencial(recordId);} 
                catch (Exception e){erroApiContratoResidencial = true;}
                 if(retornoContratoResidencial.contractPME){
                    retornoTela.contractTypePME = true;
                     
                }else if (!erroApiContratoResidencial && retornoContratoResidencial.propertyHpId!=null && retornoContratoResidencial.networkNodeCode!=null && String.isNotBlank(retornoContratoResidencial.status)) {
                    System.debug('<<<CONTRATO VIABILIDADE OK>>>');
                    retornoTela.cdBase = retornoContratoResidencial.cdBase; 
                    retornoTela.subscriberId = retornoContratoResidencial.subscriberId;
                
                    retornoTela.contratoResidencialInadimplente = obtemSituacaContratoResidencial('API', retornoContratoResidencial.status, retornoTela);
                    
                    if (!retornoTela.contratoResidencialInadimplente || (retornoTela.contratoResidencialInadimplente && !isNotRetencao)) {
                        System.debug('<<<RESIDENCIAL ADIMPLENTE>>>');
                        NBA_IntegrationModels.CurrentProductResponse retornoPosse = consultarProdutoAtual(recordId);
                        if (retornoPosse != null && retornoPosse.data != null) {
                            System.debug('<<<API DE POSSE OK>>>');
                            PosseCliente posseCliente = getPosseCliente(retornoPosse, false);
                            retornoTela.posseClienteSemAV = getPosseCliente(retornoPosse, true);
                            NBA_OfferComparator_CC.ResultViabilidade retornoViabilidade = consultarViabilidade(retornoContratoResidencial.propertyHpId, retornoContratoResidencial.networkNodeCode);
                            if (retornoViabilidade != null) {
								retornoTela.contractViabilidade = retornoViabilidade;
                                System.debug('<<<PASSOU DO FLUXO DE VIABILIDADE>>>');
                                if (posseCliente != null) {
                                    retornoTela.posseCliente = posseCliente;
                                    if(!posseCliente.movelSemTitular && !posseCliente.movelMultiplosTitulares){
                                        if (posseCliente.hasMovel) {

                                            NBA_OfferComparator_CC.RetornoContratoMovel retornoContratoMovel;
                                            Boolean erroApiContratoMovel=false;
                                            try {retornoContratoMovel = consultarApiContratoMovel(posseCliente.msisdn);} 
                                            catch (Exception e){erroApiContratoMovel = true;}
                                            
                                            if(!erroApiContratoMovel && String.isNotBlank(retornoContratoMovel.status))
                                                retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('API', retornoContratoMovel.status, retornoContratoMovel.reason, retornoTela);
                                            else
                                                retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('SALESFORCE', posseCliente.msisdn, '', retornoTela);
                                            
                                            if (retornoTela.contratoMovelInadimplente){
                                                if(!isNotRetencao) {
                                                    retornoTela.mssidn = posseCliente.msisdn;
                                                    retornoTela.result = consultarOfertas(recordId, retornoViabilidade.PTV, retornoViabilidade.VIRTUA, retornoViabilidade.DIGITAL, retornoViabilidade.VOIP, retornoPosse);
                                                    retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                                }
                                            } 
                                            else {
                                                retornoTela.result = consultarOfertas(recordId, retornoViabilidade.PTV, retornoViabilidade.VIRTUA, retornoViabilidade.DIGITAL, retornoViabilidade.VOIP, retornoPosse);
                                                retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                            }

                                        }
                                        else {
                                            System.debug('<<<TEM VIABILIDADE | NÃO TEM MOVEL>>>');
                                            retornoTela.result = consultarOfertas(recordId, retornoViabilidade.PTV, retornoViabilidade.VIRTUA, retornoViabilidade.DIGITAL, retornoViabilidade.VOIP, retornoPosse);
                                            retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                        }
                                    }
                                } else {
                                    System.debug('<<<TEM VIABILIDADE | NÃO TEM POSSE>>>');
                                    retornoTela.showModalServicoIndisponivel = true;
                                    retornoTela.apicontractproductsDisable = true;
                                }
                            }
							else {
                                System.debug('<<<NAO TEM VIABILIDADE>>>');
                                if (posseCliente != null) {
                                    retornoTela.posseCliente = posseCliente;
                                    if(!posseCliente.movelSemTitular && !posseCliente.movelMultiplosTitulares){
                                        if (posseCliente.hasMovel) {

                                            NBA_OfferComparator_CC.RetornoContratoMovel retornoContratoMovel;
                                            Boolean erroApiContratoMovel=false;
                                            try {retornoContratoMovel = consultarApiContratoMovel(posseCliente.msisdn);} 
                                            catch (Exception e){erroApiContratoMovel = true;}
                                            
                                            if(!erroApiContratoMovel && String.isNotBlank(retornoContratoMovel.status))
                                                retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('API', retornoContratoMovel.status, retornoContratoMovel.reason, retornoTela);
                                            else
                                                retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('SALESFORCE', posseCliente.msisdn, '', retornoTela);
                                            
                                            if (retornoTela.contratoMovelInadimplente){
                                                if(!isNotRetencao) {
                                                    retornoTela.mssidn = posseCliente.msisdn;
                                                    retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                                    retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                                }
                                            }
                                            else {
                                                retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                                retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                            }
                                        
                                        }
                                        else {
                                            System.debug('<<<NAO TEM MOVEL E CONSULTA APENAS PELA POSSECLIENTE >>>>');
                                            retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                            retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                        }
                                    }
                                }
                                else{
                                    System.debug('API de Posse FAIL');
                                    retornoTela.showModalServicoIndisponivel = true;
                                    retornoTela.apicontractproductsDisable = true;
                                }
                            }
                        }
						else {
                            System.debug('API de Posse FAIL');
                            retornoTela.showModalServicoIndisponivel = true;
                            retornoTela.apicontractproductsDisable = true;
                        }
                    }
                }
				else {
                    System.debug('<<<API DE CONTRATO FAILL | CONSULTANDO CONTRADO SALESFORCE>>>');
                    
                    retornoTela.contratoResidencialInadimplente = obtemSituacaContratoResidencial('SALESFORCE', recordId, retornoTela);
                    
                    if (!retornoTela.contratoResidencialInadimplente || retornoTela.contratoResidencialInadimplente && !isNotRetencao){
						System.debug('<<<CONSULTANDO CONTRADO SALESFORCE | CONECTADO>>>');
						NBA_IntegrationModels.CurrentProductResponse retornoPosse = consultarProdutoAtual(recordId);
						if (retornoPosse != null && retornoPosse.data != null) {
                            PosseCliente posseCliente = getPosseCliente(retornoPosse, false);
                            retornoTela.posseClienteSemAV = getPosseCliente(retornoPosse, true);
							if (posseCliente != null) {
                                retornoTela.posseCliente = posseCliente;
                                if(!posseCliente.movelSemTitular && !posseCliente.movelMultiplosTitulares){
                                    System.debug('<<<SF CONECTADO | POSSE OK>>>');
                                    if (posseCliente.hasMovel) {
    
                                        NBA_OfferComparator_CC.RetornoContratoMovel retornoContratoMovel;
                                        Boolean erroApiContratoMovel=false;
                                        try {retornoContratoMovel = consultarApiContratoMovel(posseCliente.msisdn);} 
                                        catch (Exception e){erroApiContratoMovel = true;}
                                        
                                        if(!erroApiContratoMovel && String.isNotBlank(retornoContratoMovel.status))
                                            retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('API', retornoContratoMovel.status, retornoContratoMovel.reason, retornoTela);
                                        else
                                            retornoTela.contratoMovelInadimplente = obtemSituacaContratoMovel('SALESFORCE', posseCliente.msisdn, '', retornoTela);
                                       
                                        if (retornoTela.contratoMovelInadimplente){
                                            if(!isNotRetencao) {
                                                retornoTela.mssidn = posseCliente.msisdn;
                                                retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                                retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                            }
                                        }
                                        else {
                                            retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                            retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                        }
    
                                    }
                                    else {
                                        System.debug('<<<SF CONECTADO | POSSE OK | SEM MOVEL>>>');
                                        retornoTela.result = consultarOfertas(recordId, posseCliente.hasTV, posseCliente.hasBroadBand, posseCliente.hasDigital, posseCliente.hasPhone, retornoPosse);
                                        retornoTela.apiOfersDisable = disabledButtonOfertas(retornoTela.result);
                                    }
                                }  
                            } 
                            else {
								System.debug('<<<SF CONECTADO | POSSE FAIL>>');
								retornoTela.showModalServicoIndisponivel = true;
								retornoTela.apicontractproductsDisable = true;
							}
						} else {
							System.debug('<<<SF CONECTADO | POSSE FAIL>>');
							retornoTela.showModalServicoIndisponivel = true;
							retornoTela.apicontractproductsDisable = true;
						}
                    }
                }
                if(String.isNotBlank(retornoTela.cdBase)){ 
                    Case caso = [SELECT CallParameterIndt__c FROM Case Where id = :recordId];
                    Parametros_NBA_Retido__mdt configuracao = [SELECT Id_Fechamento__c, identifierType__c from Parametros_NBA_Retido__mdt WHERE Label = : retornoTela.cdBase ];
                    if(caso.CallParameterIndt__c == null || caso.CallParameterIndt__c==''|| (String.isNotBlank(caso.CallParameterIndt__c) && !caso.CallParameterIndt__c.contains('Base'))){
                        caso.CallParameterIndt__c = 'Base:' + retornoTela.cdBase + ';';
                        update caso;
                     }                    
                }
          
                if (retornoTela.posseClienteSemAV != null && objCase.RecordType.DeveloperName != 'Financial') {
                    initOrder(recordId, JSON.serialize(retornoTela.posseClienteSemAV));
                }
          
            }
        }
		catch (Exception e) {
            System.debug('Erro:' + e.getMessage());
            retornoTela.showModalServicoIndisponivel = true;
            retornoTela.unhandledError = true;
        }
        return retornoTela;
    }

    @AuraEnabled
    public static NBA_OfferComparator_CC.Retorno checkInadimplencia(String contratoPhone, Id recordId, Boolean contratoResidencialInadimplente, Boolean contratoMovelInadimplente) {
        NBA_OfferComparator_CC.Retorno retorno = new NBA_OfferComparator_CC.Retorno();
        
        if(contratoResidencialInadimplente && String.isNotBlank(recordId)) {
            NBA_OfferComparator_CC.RetornoContratoResidencial retornoContratoResidencial;
            Boolean erroApiContratoResidencial=false;
            try {retornoContratoResidencial = consultarApiContratoResidencial(recordId);} 
            catch (Exception e){erroApiContratoResidencial = true;}
            
            retorno.contratoResidencialInadimplente = obtemSituacaContratoResidencial('API', (!erroApiContratoResidencial ? retornoContratoResidencial.status : ''), retorno);
        }
        
        if (contratoMovelInadimplente && String.isNotBlank(contratoPhone)) {
            NBA_OfferComparator_CC.RetornoContratoMovel retornoContratoMovel;
            Boolean erroApiContratoMovel=false;
            try {retornoContratoMovel = consultarApiContratoMovel(contratoPhone);} 
            catch (Exception e){erroApiContratoMovel = true;}
            retorno.contratoMovelInadimplente = obtemSituacaContratoMovel('API', (!erroApiContratoMovel ? retornoContratoMovel.status : ''), (!erroApiContratoMovel ? retornoContratoMovel.reason : ''), retorno);
        }

        return retorno;
    }

    //Adicionada validação para casos do tipo financeiro, pois CRM Cross utiliza uma estrutura diferente para contrato.
    @AuraEnabled
    public static NBA_OfferComparator_CC.RetornoContratoResidencial consultarApiContratoResidencial(Id parametro) {
        NBA_OfferComparator_CC.RetornoContratoResidencial retornoContratoResidencial = new NBA_OfferComparator_CC.RetornoContratoResidencial();
		String cityCode;
        String contractNumber;
        Try {
            List<Case> caso = [SELECT ContractNumber__r.CityCode__c,ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.ContractReferenceNumber__c, ContractNumber__r.ContractNumber__c,ContractNumber__r.Segmentation__c,RecordType.DeveloperName FROM Case WHERE Id = :parametro];
            System.debug('Caso: '+ caso[0].recordType.DeveloperName);
            if(caso[0].recordType.DeveloperName != 'Financial' && caso[0]?.ContractNumber__r?.Segmentation__c.containsIgnoreCase('PME')){
                retornoContratoResidencial.contractPME = true;
            }else{
                System.debug('caso[0].recordType.DeveloperName: ' + caso[0].recordType.DeveloperName);
                if(caso[0].recordType.DeveloperName =='Financial'){
                    System.debug('entrou no financial');
                    cityCode = caso[0].ContractBillingAccount__r.CityCode__c;
                    contractNumber = caso[0].ContractBillingAccount__r.ContractReferenceNumber__c;
                }else{
                    System.debug('Entrou no else');
                    cityCode = caso[0].ContractNumber__r.CityCode__c;
                    contractNumber = caso[0].ContractNumber__r.ContractNumber__c;
                }
            NBA_IntegrationModels.RespostaContratoResidencial response = NBA_IntegrationServices.consultarApiContratoResidencial(
                new Map<String, Object>{'customerAccountId' => cityCode + contractNumber}
            );

            if(response.data.contracts!=null && !response.data.contracts.isEmpty()){
                retornoContratoResidencial.networkNodeCode  = cityCode.leftPad(3,'0'); 
                retornoContratoResidencial.propertyHpId     = response.data.contracts[0].propertyHpId;
                retornoContratoResidencial.status           = response.data.contracts[0].status;
                retornoContratoResidencial.subscriberId     = response.data.contracts[0].partyRoleId;
                retornoContratoResidencial.cdBase           = response.data.contracts[0].cdBase;
            }
            }
        }

        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return retornoContratoResidencial;
    }

    @AuraEnabled
    public static Boolean obtemSituacaContratoResidencial(String consulta, String parametro, NBA_OfferComparator_CC.Retorno retorno){
        retorno.contratoResidencialConsulta = consulta;
        
        if(retorno.contratoResidencialConsulta=='API')
            retorno.contratoResidencialStatus = parametro;
        else if(retorno.contratoResidencialConsulta=='SALESFORCE')
            retorno.contratoResidencialStatus = [SELECT ContractNumber__r.LegacyStatus__c FROM Case WHERE Id = :parametro].ContractNumber__r.LegacyStatus__c;
        
        if(String.isBlank(retorno.contratoResidencialStatus))
            retorno.contratoResidencialStatus = '';

        if(retorno.contratoResidencialStatus=='CONECTADO')
            retorno.contratoResidencialSituacao = 'CONECTADO';
        else if([SELECT Id FROM NBA_Inadimplencia__mdt WHERE DESCRICAO__c = :retorno.contratoResidencialStatus].size()>0)
            retorno.contratoResidencialSituacao = 'INADIMPLENTE';
        else
            retorno.contratoResidencialSituacao = 'BLOQUEADO';

        return (retorno.contratoResidencialSituacao=='INADIMPLENTE' || retorno.contratoResidencialSituacao=='BLOQUEADO') ? true : false;
    }
    
    @TestVisible
    public static NBA_OfferComparator_CC.RetornoContratoMovel consultarApiContratoMovel(String parametro) {
        NBA_OfferComparator_CC.RetornoContratoMovel retornoContratoMovel = new NBA_OfferComparator_CC.RetornoContratoMovel();

        Try {
            NBA_IntegrationModels.RespostaContratoMovel response = NBA_IntegrationServices.consultarApiContratoMovel(
                new Map<String, Object>{'msisdn' => parametro}
            );

            if (response.data.subscribers!=null && !response.data.subscribers.isEmpty()) {
                retornoContratoMovel.status = response.data.subscribers[0].productStatus;
                retornoContratoMovel.reason = response.data.subscribers[0].reason;
            }
        }

        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return retornoContratoMovel;
    }

    @TestVisible
    public static Boolean obtemSituacaContratoMovel(String consulta, String parametro, String parametro2, NBA_OfferComparator_CC.Retorno retorno) { 
        retorno.contratoMovelConsulta = consulta;

        if(retorno.contratoMovelConsulta=='API'){
            retorno.contratoMovelStatus = parametro;
            retorno.contratoMovelReason = parametro2;
        }
        else if(retorno.contratoMovelConsulta=='SALESFORCE'){
            List<Contract> contratos = [
                SELECT Status, LegacyStatusReason__c FROM Contract WHERE Id IN 
                (SELECT vlocity_cmt__ContractId__c FROM Asset WHERE RecordType.DeveloperName IN ('CECMovel', 'CECInternetMovel', 'CECMovelPreControle') AND MSISDN__c = :parametro)
                ORDER BY LastModifiedDate DESC LIMIT 1
            ]; 
            if(contratos.size()>0){
                retorno.contratoMovelStatus = contratos[0].Status;
                retorno.contratoMovelReason = contratos[0].LegacyStatusReason__c;
            }
        }
        
        if(String.isBlank(retorno.contratoMovelStatus))
            retorno.contratoMovelStatus = '';
        if(String.isBlank(retorno.contratoMovelReason))
            retorno.contratoMovelReason = '';

        if(retorno.contratoMovelStatus.equalsIgnoreCase('ativo'))
            retorno.contratoMovelSituacao = 'CONECTADO';
        else if(retorno.contratoMovelStatus.equalsIgnoreCase('suspenso')  && retorno.contratoMovelReason.containsIgnoreCase('cobranca'))
            retorno.contratoMovelSituacao = 'INADIMPLENTE';
        else
            retorno.contratoMovelSituacao = 'BLOQUEADO';
        
        return (retorno.contratoMovelSituacao=='INADIMPLENTE' || retorno.contratoMovelSituacao=='BLOQUEADO') ? true : false;
    }

    public static Boolean disabledButtonOfertas(NBA_OfferComparator_CC.Result result) {
        Boolean retorno = true;
        if (result != null && result.lstOffers != null && !result.lstOffers.isEmpty()) {
            retorno = false;
        }
        return retorno;
    }

    public static NBA_OfferComparator_CC.PosseCliente getPosseCliente(NBA_IntegrationModels.CurrentProductResponse currentProduct, Boolean ignorarAcessoVirtua) {
        NBA_OfferComparator_CC.PosseCliente posseCliente;
        if (currentProduct != null && currentProduct.data != null && currentProduct.data.contractProducts != null && !currentProduct.data.contractProducts.isEmpty()) {
            posseCliente = new NBA_OfferComparator_CC.PosseCliente();            
            Integer qtdTitulares=0, qtdDependentes=0;
            for (NBA_IntegrationModels.ContractProduct currentProd : currentProduct.data.contractProducts) {
                if (currentProd.productType == NBA_Constants.TV_PACOTE && (!ignorarAcessoVirtua || currentProd.catalogName != 'ACESSO VIRTUA')) {
                    posseCliente.hasTV = true;
                }
                if (currentProd.productType == NBA_Constants.BL_ASSINATURA) {
                    posseCliente.hasBroadBand = true;
                }
                if (currentProd.productType == NBA_Constants.NET_FONE) {
                    posseCliente.hasPhone = true;
                }
                if (currentProd.productType == NBA_Constants.MOVEL_ASSINATURA) {
                    qtdTitulares++;
                    posseCliente.hasMovel = true;
                    posseCliente.msisdn = currentProd.msisdn;
                }
                if (currentProd.productType == NBA_Constants.MOVEL_DEPENDENTES) {
                    qtdDependentes++;
                }
                if (currentProd.productDetail != null && String.isNotBlank(currentProd.productDetail)) {
                    posseCliente.hasDigital = true;
                }
            }
            if(qtdDependentes>0 && qtdTitulares==0)
                posseCliente.movelSemTitular = true;
            else if(qtdTitulares>1)
                posseCliente.movelMultiplosTitulares = true;
        }
        return posseCliente;
    }

    @AuraEnabled
    public static void encerramentoCaso(id recordId, Boolean isRetencao, Boolean servicoIndisponivel, Boolean dadoInconsistente, String textoComentario, Boolean isContractPME) {
        List<Case> lstCase = [SELECT Id, CallResultIndt__c, ALaCarteN1Result__c, ALaCarteN2Result__c, ALaCarteN3Result__c, BLN1Result__c, BLN2Result__c, BLN3Result__c, MobileN1Result__c, MobileN2Result__c, MobileN3Result__c, PhoneN1Result__c, PhoneN2Result__c, PhoneN3Result__c, Time_of_Service__c, TVN1Result__c, TVN2Result__c, TVN3Result__c FROM Case where id = :recordId];
        Case caso = lstCase[0];
        caso.Time_of_Service__c = NBA_Constants.ENCERRAMENTO;

      	caso.CallResultIndt__c = 'Com Ação';  
      	caso = updateValuesTabulacao(caso, isRetencao, servicoIndisponivel, dadoInconsistente,isContractPME);

        Database.SaveResult sv = Database.update(caso);
        
        insertCaseComment(recordId, textoComentario);
    }

    public static void insertCaseComment(Id caseId, String message){
        if(String.isNotBlank(message)){
            List<CaseComment> lstCaseComment = [SELECT id, CommentBody, ParentId FROM CaseComment WHERE ParentId = :caseId];
            if (!lstCaseComment.isEmpty()) {
                CaseComment caseC = lstCaseComment[0];
                if (caseC.CommentBody != message) {
                    caseC.CommentBody = message;
                    update caseC;
                }
            } else {
                CaseComment newCommmand = new CaseComment();
                newCommmand.CommentBody = message;
                newCommmand.IsPublished = true;
                newCommmand.ParentId = caseId;
                insert newCommmand;
            }
        }
    }

    @TestVisible
    private static Case updateValuesTabulacao(Case caso, Boolean isRetencao, Boolean servicoIndisponivel, Boolean dadoInconsistente, Boolean isContractPME) {
        // Resultado do Atendimento
        if(dadoInconsistente)
            caso.CallResultIndt__c = 'Com Ação';
        system.debug('<<ContractPME>> ' + NBA_Constants.SEM_OFERTAS);
        // Tabulações Nível 1
        if ((isRetencao || servicoIndisponivel) && !dadoInconsistente && !isContractPME) {
            caso.TVN1Result__c = NBA_Constants.INFORMACOES;
            caso.BLN1Result__c = NBA_Constants.INFORMACOES;
            caso.PhoneN1Result__c = NBA_Constants.INFORMACOES;
            caso.MobileN1Result__c = NBA_Constants.INFORMACOES;
            caso.ALaCarteN1Result__c = NBA_Constants.INFORMACOES;
        } else {
            caso.TVN1Result__c = NBA_Constants.IMPRODUTIVO;
            caso.BLN1Result__c = NBA_Constants.IMPRODUTIVO;
            caso.PhoneN1Result__c = NBA_Constants.IMPRODUTIVO;
            caso.MobileN1Result__c = NBA_Constants.IMPRODUTIVO;
            caso.ALaCarteN1Result__c = NBA_Constants.IMPRODUTIVO;
        }

        // Tabulações Nível 2
        if(dadoInconsistente){
            caso.TVN2Result__c = NBA_Constants.DADOS_INCONSISTENTES;
            caso.BLN2Result__c = NBA_Constants.DADOS_INCONSISTENTES;
            caso.PhoneN2Result__c = NBA_Constants.DADOS_INCONSISTENTES;
            caso.MobileN2Result__c = NBA_Constants.DADOS_INCONSISTENTES;
            caso.ALaCarteN2Result__c = NBA_Constants.DADOS_INCONSISTENTES;
        } else if (servicoIndisponivel) {
            caso.TVN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.BLN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.PhoneN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.MobileN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.ALaCarteN2Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
        } else if (isContractPME){
            caso.TVN2Result__c = NBA_Constants.SEM_OFERTAS;
            caso.BLN2Result__c = NBA_Constants.SEM_OFERTAS;
            caso.PhoneN2Result__c = NBA_Constants.SEM_OFERTAS;
            caso.MobileN2Result__c = NBA_Constants.SEM_OFERTAS;
            caso.ALaCarteN2Result__c = NBA_Constants.SEM_OFERTAS;
        } else {
            caso.TVN2Result__c = NBA_Constants.MOVEL_INADIMPLENTE;
            caso.BLN2Result__c = NBA_Constants.MOVEL_INADIMPLENTE;
            caso.PhoneN2Result__c = NBA_Constants.MOVEL_INADIMPLENTE;
            caso.MobileN2Result__c = NBA_Constants.MOVEL_INADIMPLENTE;
            caso.ALaCarteN2Result__c = NBA_Constants.MOVEL_INADIMPLENTE;
        }

        // Tabulações Nível 3
        if(dadoInconsistente){
            caso.TVN3Result__c = NBA_Constants.RESULT_N3_PRODUTO_MOVEL;
            caso.BLN3Result__c = NBA_Constants.RESULT_N3_PRODUTO_MOVEL;
            caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_PRODUTO_MOVEL;
            caso.MobileN3Result__c = NBA_Constants.RESULT_N3_PRODUTO_MOVEL;
            caso.ALaCarteN3Result__c = NBA_Constants.RESULT_N3_PRODUTO_MOVEL;
        }else if(isContractPME){
			caso.TVN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.BLN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.PhoneN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.MobileN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;
            caso.ALaCarteN3Result__c = NBA_Constants.SISTEMA_INDISPONIVEL;            
        }else{
            caso.TVN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
            caso.BLN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
            caso.PhoneN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
            caso.MobileN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
            caso.ALaCarteN3Result__c = NBA_Constants.RESULT_N3_NENHUM;
        }

        return caso;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @author         Diego Silva   <diego.henrique.silva@accenture.com>
    * @created        2020-01-20
    * @description	  Calculo de dependente.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static NBA_OfferComparator_CC.Offer calculateDependenteMobile(String jsonProdutoAtual) {
        NBA_OfferComparator_CC.Offer offerReturn = (NBA_OfferComparator_CC.Offer) JSON.deserialize(jsonProdutoAtual, NBA_OfferComparator_CC.Offer.class);
        System.debug('JSON BEFORE >> ' + JSON.serialize(offerReturn));
        Decimal totalDescontoDependente = 0;
        Decimal totalValueDependente = 0;
        Decimal totalDepSemDescontoPG = 0;
        Decimal totalDepComDescontoPG = 0;
        Decimal totalDepSemDescontoBL = 0;
        Decimal totalDepComDescontoBL = 0;
        Decimal somaDescontoDep = 0;
        Decimal debiteDescontoDep = 0;
        Decimal somaSemDescontoDep = 0;
        Decimal debiteSemDescontoDep = 0;
        if (offerReturn != null) {
            if (offerReturn.mobile != null && offerReturn.mobile.PlanMobile != null && offerReturn.mobile.listaDependentesMobilePosse != null) {
                for (Dependentes dep : offerReturn.mobile.listaDependentesMobilePosse) {
                    if (dep.checked) {
                        totalDescontoDependente += dep.deducedPrice;
                        totalValueDependente += dep.valorProduto;
                        somaDescontoDep += (dep.valorProduto - dep.deducedPrice);
                        somaSemDescontoDep += dep.valorProduto;
                        if (dep.nomePlano == 'POS PG') {
                            totalDepComDescontoPG += dep.valorProduto - dep.deducedPrice;
                            totalDepSemDescontoPG += dep.valorProduto;
                        } else if (dep.nomePlano == 'POS BL') {
                            totalDepComDescontoBL += dep.valorProduto - dep.deducedPrice;
                            totalDepSemDescontoBL += dep.valorProduto;
                        }
                    } else {
                        debiteDescontoDep += (dep.valorProduto - dep.deducedPrice);
                        debiteSemDescontoDep += dep.valorProduto;
                    }
                }
            }
        }
        System.debug('VALOR COM DESCONTO ---> ' + debiteDescontoDep);
        offerReturn.totalValueOriginal = offerReturn.totalValueOriginal - debiteSemDescontoDep;
        offerReturn.totalValue = offerReturn.totalValue - debiteDescontoDep;
        offerReturn.mobile.mouseOverDependenteSemDescontoPG = String.valueof(totalDepSemDescontoPG);
        offerReturn.mobile.mouseOverDependenteComDescontoPG = String.valueof(totalDepComDescontoPG);
        offerReturn.mobile.mouseOverDependenteSemDescontoBL = String.valueof(totalDepSemDescontoBL);
        offerReturn.mobile.mouseOverDependenteComDescontoBL = String.valueof(totalDepComDescontoBL);
        System.debug('OFFER AFTER >> ' + offerReturn);
        return offerReturn;
    }

    @AuraEnabled
    public static void initOrder(String caseId, String posseCliente) {
        PosseCliente posse;
        if (String.isNotEmpty(posseCliente)) {
            posse = (PosseCliente) JSON.deserialize(posseCliente, PosseCliente.class);
        }

        Case c = [SELECT Id, Status, Order__c, ContractNumber__c, ContractNumber__r.AccountId FROM Case WHERE Id = :caseId LIMIT 1];
        if (c.Status == 'Encerrado') {
            return;
        }
        c.TVN1Result__c = null;
        c.TVN2Result__c = null;
        c.TVN3Result__c = null;
        c.BLN1Result__c = null;
        c.BLN2Result__c = null;
        c.BLN3Result__c = null;
        c.MobileN1Result__c = null;
        c.MobileN2Result__c = null;
        c.MobileN3Result__c = null;
        c.PhoneN1Result__c = null;
        c.PhoneN2Result__c = null;
        c.PhoneN3Result__c = null;
        c.ALaCarteN1Result__c = null;
        c.ALaCarteN2Result__c = null;
        c.ALaCarteN3Result__c = null;

        Order pedido = new Order();

        if (c.Order__c != null) {
            pedido.Id = c.Order__c;
            //Limpando eventuais solics anteriores
            delete [SELECT Id FROM Solic_NBA__c WHERE Order__c = :pedido.Id AND Status__c IN (null, :NBA_Constants.EM_ABERTO)];

            if (posse == null) {
                throw new DadosInvalidosException('Sem dados da possse.');
            }
        }

        pedido.AccountId = c.contractNumber__r.AccountId;
        pedido.EffectiveDate = Date.today();
        pedido.ContractId = c.ContractNumber__c;
        pedido.Status = 'Draft';
        pedido.RecordTypeId = recordTypeIdNBAOffer;
        pedido.OrderCase__c = c.Id;

        pedido.MobileMovement__c = posse.hasMovel ? null : NBA_Constants.MOVIMENTO_NENHUMA ;
        pedido.VirtuaMovement__c = posse.hasBroadBand ? null : NBA_Constants.MOVIMENTO_NENHUMA;
        pedido.TVMovement__c = posse.hasTV ? null : NBA_Constants.MOVIMENTO_NENHUMA;
        pedido.NETFoneMovement__c = posse.hasPhone ? null : NBA_Constants.MOVIMENTO_NENHUMA;
        pedido.ALaCarteMoviment__c = null;

        upsert pedido;

        c.Order__c = pedido.Id;
        update c;
    }
      @TestVisible
      private static String removeDecimalPlace(String numberValue){
          String valueReturn = numberValue;
          if(numberValue.contains('.')){
              String[] split1 = numberValue.split('\\.');
              valueReturn = split1[0];
          }
          return valueReturn;
      }

    public class PosseCliente {
        @AuraEnabled public Boolean hasTV = false;
        @AuraEnabled public Boolean hasPhone = false;
        @AuraEnabled public Boolean hasBroadBand = false;
        @AuraEnabled public Boolean hasMovel = false;
        @AuraEnabled public Boolean hasDigital = false;
        @AuraEnabled public String msisdn;
        @AuraEnabled public Boolean  movelSemTitular = false;     
        @AuraEnabled public Boolean  movelMultiplosTitulares = false;     
    }

    public class Retorno {
        @AuraEnabled public Result result = new Result();
        @AuraEnabled public String mssidn = '';
        @AuraEnabled public Boolean showModalServicoIndisponivel = false;
        @AuraEnabled public Boolean unhandledError = false;
        @AuraEnabled public Boolean apicontractproductsDisable = false;
        @AuraEnabled public Boolean apiOfersDisable = false;
        @AuraEnabled public PosseCliente posseCliente = new PosseCliente() ;
        @AuraEnabled public PosseCliente posseClienteSemAV;//Não considera Acesso virtua
		@AuraEnabled public String subscriberId;
		@AuraEnabled public String cdBase;
        @AuraEnabled public ResultViabilidade contractViabilidade;
        
        @AuraEnabled public Boolean contratoResidencialInadimplente = false;
        @AuraEnabled public String  contratoResidencialConsulta     = '';
        @AuraEnabled public String  contratoResidencialSituacao     = '';
        @AuraEnabled public String  contratoResidencialStatus       = '';
        @AuraEnabled public Boolean contratoMovelInadimplente       = false;
        @AuraEnabled public String  contratoMovelConsulta           = '';
        @AuraEnabled public String  contratoMovelSituacao           = '';
        @AuraEnabled public String  contratoMovelStatus             = '';
        @AuraEnabled public String  contratoMovelReason             = '';         
        @AuraEnabled public Boolean contractTypePME				    = false;
    }

    public class AtualProductsBase {
        @AuraEnabled public Boolean hasTV;
        @AuraEnabled public Boolean hasBL;
        @AuraEnabled public Boolean hasFN;
        @AuraEnabled public Boolean hasMV;
    }

    public class Result {
        @AuraEnabled public Boolean OffersApiCalled = false;
        @AuraEnabled public Offer currentProduct;
        @AuraEnabled public List<Offer> lstOffers;
        @AuraEnabled public String status;
        @AuraEnabled public String cityCode;
        @AuraEnabled public String subscriberIbgeCode;
        @AuraEnabled public String channelDetail;
        @AuraEnabled public String attendantProfile;
        @AuraEnabled public String mobileAttendantProfile;
        @AuraEnabled public String mobileChannelDetail;
        @AuraEnabled public String callReason; //10/09/19 - Kleverton Fortunato - CLAR179
        @AuraEnabled public NBA_IntegrationModels.SearchOffersResponse resultadoBrudoAPI;
        @AuraEnabled public string mensagemSemOfertas = '';
        @AuraEnabled public List<NBA_Pointing__mdt> pontuacao;
    }
    
    public class Offer {
        public Offer() {
        }
        public Offer(NBA_IntegrationModels.Recommendation rec) {
            this.key = rec.id;
            this.offerProfile = rec.profile;
            this.priority = rec.priority;
            this.incentive = rec.rewardPoints;
            this.movimentTv = rec.actionTv;
            this.movimentBroadband = rec.actionBroadband;
            this.movimentPhone = rec.actionPhone;
            this.movimentMobile = rec.actionMobile;
            this.hasDiscountAutomaticDebit = hasDiscountAutomaticDebit;
        }
        @AuraEnabled public String hoverTitularMovel;
        @AuraEnabled public String hoverDependenteMovel;
        @AuraEnabled public String hoverTitularMovelDesconto;
        @AuraEnabled public String hoverDependenteMovelDesconto;
        @AuraEnabled public String key;
        @AuraEnabled public String priority;
        @AuraEnabled public String oldPriority;
        @AuraEnabled public String offerType;
        @AuraEnabled public String incentive;
        @AuraEnabled public String offerProfile;
        @AuraEnabled public String movimentTv;
        @AuraEnabled public String movimentLaCarte;
        @AuraEnabled public String movimentBroadband;
        @AuraEnabled public String movimentPhone;
        @AuraEnabled public String movimentMobile;
        @AuraEnabled public List<PlanTv> tv = new List<PlanTv>();
        @AuraEnabled public PlanBroadband broadband = new PlanBroadband();
        @AuraEnabled public PlanPhone phone = new PlanPhone();
        @AuraEnabled public PlanMobile mobile = new PlanMobile();
        @AuraEnabled public Decimal totalValue = 0;
        @AuraEnabled public Decimal totalValueOriginal = 0;
        @AuraEnabled public Decimal totalPenalty = 0;
        @AuraEnabled public Decimal difTotal = 0;
        @AuraEnabled public Option difTotalStep = new Option();
        @AuraEnabled public String vlMembershipFee;
        @AuraEnabled public String vlUpgradeFee;
        @AuraEnabled public String paymentMethodUpgrade;
        @AuraEnabled public String paymentMethodMembership;
        @AuraEnabled public String productFee;
        @AuraEnabled public String technology = '';
        @AuraEnabled public List<Option> lstSteps = new List<Option> ();
        @AuraEnabled public List<Fee> lstMembershipFee = new List<Fee> ();
        @AuraEnabled public List<Fee> lstMembershipFeeFiltered = new List<Fee> ();
        @AuraEnabled public List<Fee> lstUpgradeFee = new List<Fee> ();
        @AuraEnabled public List<Fee> lstUpgradeFeeFiltered = new List<Fee> ();
        @AuraEnabled public Boolean hasDiscountAutomaticDebit = false;
        @AuraEnabled public Decimal automaticDebitDiscount = 0;
        @AuraEnabled public Boolean blindagem = false;
        @AuraEnabled public Boolean combate = false;
        @AuraEnabled public Boolean exclusivo = false;
        @AuraEnabled public Boolean free = false;
        @AuraEnabled public Integer techSelected = 0;
        @AuraEnabled public String baseId;
        @AuraEnabled public String offerReferenceId;
        @AuraEnabled public AgregadoInformativo AgregadoInformativo = new AgregadoInformativo();
        @AuraEnabled public TemporarySuspension temporarySuspension = new TemporarySuspension();
    }

    public class PlanTv {
        @AuraEnabled public Decimal difProducts = 0;
        @AuraEnabled public Decimal difAdditionals = 0;
        @AuraEnabled public Option difProductsStep = new Option();
        @AuraEnabled public Option difAdditionalsStep = new Option();
        @AuraEnabled public Decimal additionalPromoValue = 0;
        @AuraEnabled public String technology = '';
        @AuraEnabled public String technologyName = '';
        @AuraEnabled public Product planTv = new Product();
        @AuraEnabled public Product additionalTv = new Product(NBA_Constants.DEMAIS_A_LA_CARTES, 0);
        @AuraEnabled public Product optionalPointsTv = new Product(NBA_Constants.PONTOS_OPCIONAIS, 0);
        @AuraEnabled public Product optionalPointsPromoTv = new Product(NBA_Constants.PONTOS_PROMOCIONAIS, 0);
        @AuraEnabled public AdditionalTV addOptions = new AdditionalTV();
        @AuraEnabled public Decimal tempFidelity;
        @AuraEnabled public String offerType;
        @AuraEnabled public Decimal automaticDebitDiscount = 0;
        @AuraEnabled public String familyName;
        @AuraEnabled public List<Fee> feeProducts = new List<Fee> ();
        @AuraEnabled public String comboProfile = '';
        @AuraEnabled public String solicitationType;
        @AuraEnabled public Decimal totalValue;
    }

    public class PlanBroadband {
        @AuraEnabled public Decimal difProducts = 0;
        @AuraEnabled public Decimal difAdditionals = 0;
        @AuraEnabled public Option difProductsStep = new Option();
        @AuraEnabled public Option difAdditionalsStep = new Option();
        @AuraEnabled public Decimal additionalPromoValue = 0;
        @AuraEnabled public Product planBroadband = new Product();
        @AuraEnabled public Product additionalBroadband = new Product(NBA_Constants.ADICIONAIS, 0);
        @AuraEnabled public AdditionalBroadband addOptions = new AdditionalBroadband();
        @AuraEnabled public Decimal tempFidelity;
        @AuraEnabled public String offerType;
        @AuraEnabled public Decimal automaticDebitDiscount = 0;
        @AuraEnabled public String familyName;
        @AuraEnabled public String technology = '';
        @AuraEnabled public List<Fee> feeProducts = new List<Fee> ();
        @AuraEnabled public String comboProfile;
        @AuraEnabled public String solicitationType;
        @AuraEnabled public Decimal totalValue;
    }

    public class PlanPhone {
        @AuraEnabled public Decimal difProducts = 0;
        @AuraEnabled public Decimal difAdditionals = 0;
        @AuraEnabled public Option difProductsStep = new Option();
        @AuraEnabled public Option difAdditionalsStep = new Option();
        @AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
        @AuraEnabled public Product planPhone = new Product();
        @AuraEnabled public Product additionalPhone = new Product(NBA_Constants.ADICIONAIS, 0);
        @AuraEnabled public AdditionalPhone addOptions = new AdditionalPhone();
        @AuraEnabled public Decimal tempFidelity;
        @AuraEnabled public String offerType;
        @AuraEnabled public String familyName;
        @AuraEnabled public String technology = '';
        @AuraEnabled public List<Fee> feeProducts = new List<Fee> ();
        @AuraEnabled public String comboProfile;
        @AuraEnabled public String solicitationType;
        @AuraEnabled public Decimal totalValue;
    }

    public class PlanMobile {
        @AuraEnabled public String mouseOverValorSemDesconto = '';
        @AuraEnabled public String mouseOverTitularSemDesconto = '';
        @AuraEnabled public Decimal descontoTitular = 0;
        @AuraEnabled public Decimal difProducts = 0;
        @AuraEnabled public Decimal difAdditionals = 0;
        @AuraEnabled public Decimal difDependents = 0;
        @AuraEnabled public Option difProductsStep = new Option();
        @AuraEnabled public Option difAdditionalsStep = new Option();
        @AuraEnabled public Option difDependentsStep = new Option();
        @AuraEnabled public Decimal additionalPromoValue = 0;
        @AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
        @AuraEnabled public Product planMobile = new Product();
        @AuraEnabled public Product dependentslMobile = new Product();
        @AuraEnabled public Product additionalMobile = new Product(NBA_Constants.ADICIONAIS, 0);
        @AuraEnabled public AdditionalMobile addOptions = new AdditionalMobile();
        @AuraEnabled public Decimal tempFidelity;
        @AuraEnabled public String offerType;
        @AuraEnabled public Decimal automaticDebitDiscount = 0;
        @AuraEnabled public String familyName;
        @AuraEnabled public String technology = '';
        @AuraEnabled public List<Fee> feeProducts = new List<Fee> ();
        @AuraEnabled public String comboProfile;
        @AuraEnabled public String solicitationType;
        @AuraEnabled public Dependentes titularMobile = new Dependentes();
        @AuraEnabled public List<Dependentes> listaDependentesMobile = new List<Dependentes> ();
        @AuraEnabled public List<Dependentes> listaDependentesMobilePosse = new List<Dependentes> ();
        @AuraEnabled public Decimal totalDependentes = 0.0;
        @AuraEnabled public String name = '';
        @AuraEnabled public String validFor = '';
        
        // dependentes pós pago (voz + dados)
        @AuraEnabled public String descontoDependentePG = '';
        @AuraEnabled public Integer numeroDependentesVozDados = 0;
        @AuraEnabled public String mouseOverDependenteComDescontoPG = '';
        @AuraEnabled public String mouseOverDependenteSemDescontoPG = '';
        @AuraEnabled public Integer numeroDependentesVozDadosSelected = 0;
        @AuraEnabled public Decimal totalVozDadosSelected = 0.0;
        @AuraEnabled public Decimal totalVozDados = 0.0;
        @AuraEnabled public Integer numeroDependentesVozDadosOriginal = 0;
        @AuraEnabled public Decimal totalVozDadosOriginal = 0.0;

        // dependentes banda larga (dados)
        @AuraEnabled public String descontoDependenteBL = '';
        @AuraEnabled public Integer numeroDependentesDados = 0;
        @AuraEnabled public String mouseOverDependenteComDescontoBL = '';
        @AuraEnabled public String mouseOverDependenteSemDescontoBL = '';
        @AuraEnabled public Integer numeroDependentesDadosSelected = 0;
        @AuraEnabled public Decimal totalDadosSelected = 0.0;
        @AuraEnabled public Decimal totalDados = 0.0;
        @AuraEnabled public Integer numeroDependentesDadosOriginal = 0;
        @AuraEnabled public Decimal totalDadosOriginal = 0.0;

        // dependentes controle (controle)
        @AuraEnabled public String descontoDependenteControle = '';
        @AuraEnabled public Integer numeroDependentesControle = 0;
        @AuraEnabled public String mouseOverDependenteComDescontoControle = '';
        @AuraEnabled public String mouseOverDependenteSemDescontoControle = '';
        @AuraEnabled public Integer numeroDependentesControleSelected = 0;
        @AuraEnabled public Decimal totalControleSelected = 0.0;
        @AuraEnabled public Decimal totalControle = 0.0;
        @AuraEnabled public Integer numeroDependentesControleOriginal = 0;    
        @AuraEnabled public Decimal totalControleOriginal = 0.0;

        @AuraEnabled public Decimal totalDependentesSelected = 0.0;
        @AuraEnabled public Boolean isComboMulti = false;
        @AuraEnabled public String promotionName = '';
        @AuraEnabled public String msisdn = '';
        @AuraEnabled public String productDetail = '';
        @AuraEnabled public String speed = '';
        @AuraEnabled public String netsalesProductName = '';
        @AuraEnabled public Boolean posseAtual = true ; // Campo para diferenciar posse atual de oferta na tela de adicionais de movel  Alexandre Amaro 19-08-19
        @AuraEnabled public Integer numeroMaxDep = 0;
        @AuraEnabled public List<Dependentes> listaDependentesMobileSelected = new List<Dependentes>();
        @AuraEnabled public List<String> svas = new List<String>();
        @AuraEnabled public List<Dependentes> titularesOferta = new List<Dependentes>();
        @AuraEnabled public Decimal totalValue = 0;
        // Dependente
        @AuraEnabled public List<BonusDesconto> listBonusDependente = new List<BonusDesconto> ();
        @AuraEnabled public List<BonusDesconto> listDescontoDependente = new List<BonusDesconto> ();
        // TITULAR
        @AuraEnabled public List<BonusDesconto> listBonusTitular = new List<BonusDesconto> ();
        @AuraEnabled public List<BonusDesconto> listDescontoTitular = new List<BonusDesconto> ();
        @AuraEnabled public Decimal bonusTitular = 0;
        @AuraEnabled public Decimal descontTitular = 0;
        @AuraEnabled public Decimal valueTitularSemDesconto = 0;
        @AuraEnabled public String bonusTitularRPA = '';
        @AuraEnabled public String descontTitularRPA = '';
    }
    
    public class Dependentes {
        @AuraEnabled public String technologyId;
        @AuraEnabled public String mouseOverSemDescontoPG;
        @AuraEnabled public String mouseOverSemDescontoBL;
        @AuraEnabled public String origem;
        @AuraEnabled public Decimal deducedPrice = 0;
        @AuraEnabled public String operadora;
        @AuraEnabled public String numeroTelefone;
        @AuraEnabled public String nomePlano;
        @AuraEnabled public String promoSelected;
        @AuraEnabled public Decimal valorProduto;
        @AuraEnabled public Decimal possessionDiscount = 0;
        @AuraEnabled public List<String> listProdutosAdicionais = new List<String> ();
        @AuraEnabled public List<String> listBeneficiosDoPlano = new List<String> ();
        @AuraEnabled public List<BonusDesconto> listBonusDependente = new List<BonusDesconto> ();
        @AuraEnabled public List<BonusDesconto> listDescontoDependente = new List<BonusDesconto> ();
        @AuraEnabled public Decimal bonusDependente = 0;
        @AuraEnabled public Decimal descontoDependente = 0;
        @AuraEnabled public Decimal valueDependenteSemDesconto = 0;
        @AuraEnabled public String bonusDependenteRPA = '';
        @AuraEnabled public String descontoDependenteRPA = '';
        //@AuraEnabled public Decimal additionalPromoValue = 0;
        //@AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
        //@AuraEnabled public Product additionalMobile = new Product(NBA_Constants.ADICIONAIS, 0);
        //@AuraEnabled public AdditionalMobile addOptions = new AdditionalMobile();
        @AuraEnabled public Decimal tempFidelity;
        @AuraEnabled public String offerType;
        @AuraEnabled public String familyName;
        @AuraEnabled public String technology = '';
        @AuraEnabled public List<Fee> feeProducts = new List<Fee> ();
        @AuraEnabled public String comboProfile;
        @AuraEnabled public String solicitationType;
        @AuraEnabled public Boolean disabled = true;
        @AuraEnabled public Boolean disabledNew = false;
        @AuraEnabled public Boolean checked = true ;
        @AuraEnabled public Boolean previousChecked = true ;
        @AuraEnabled public String portabilityRequestType = '';
        @AuraEnabled public String key ;
        @AuraEnabled public String newId ;
        @AuraEnabled public Boolean fidelity = false;
        @AuraEnabled public String dependentType = '';
        @AuraEnabled public String nameLegacy = '';
        @AuraEnabled public String productName = '';
        @AuraEnabled public String promotionName = '';
        @AuraEnabled public String catalogName = '';
        @AuraEnabled public String netsalesProductName;
        @AuraEnabled public Integer validFor = 0;
        @AuraEnabled public Decimal discountPromo = 0;
    }
    public virtual class Option implements Comparable {
        @AuraEnabled public String label = '';
        @AuraEnabled public Decimal value = 0;
        public Integer compareTo(Object compareTo) {
            Option compareToOppy = (Option) compareTo;
            return label.compareTo(compareToOppy.label);
        }
    }
    public class Product {
        public Product() {
        }
        public Product(String label, Decimal value) {
            this.label = label;
            this.value = 0;
        }
        @AuraEnabled public String key = '';
        @AuraEnabled public String label = '';
        @AuraEnabled public String nameLegacy = '';
        @AuraEnabled public Decimal value = 0;
        @AuraEnabled public Decimal originalValue = 0;
        @AuraEnabled public Integer quantity = 0;
        @AuraEnabled public Fidelity fidelity = new Fidelity();
        @AuraEnabled public List<ProductPromo> lstPromotions = new List<ProductPromo> ();
        @AuraEnabled public String typeAcessoVirtua = '';
		@AuraEnabled public String pointId = '';
    }
    public class ProductPromo {
        @AuraEnabled public String key = '';
        @AuraEnabled public String label = '';
        @AuraEnabled public String description = '';
        @AuraEnabled public Decimal value = 0;
        @AuraEnabled public Decimal discount = 0;
        @AuraEnabled public Decimal percent = 0;
        @AuraEnabled public Integer valid = 0;
    }
    public virtual class Additional {
        public Additional() {
        }
        public Additional(String label, Decimal value) {
            this.label = label;
            this.value = value;
        }
        @AuraEnabled public String id = '';
        @AuraEnabled public String label = '';
        @AuraEnabled public String nameLegacy = '';
        @AuraEnabled public String detail = '';
        @AuraEnabled public Decimal value = 0;
        @AuraEnabled public Boolean checked = false;
        @AuraEnabled public Boolean disabled = true;
        @AuraEnabled public String promoSelected = '';
        @AuraEnabled public String solicitationType = '';
        @AuraEnabled public String technologyType = '';
        @AuraEnabled public String description = '';
        @AuraEnabled public String catalogName = '';
        @AuraEnabled public String productName = '';
        @AuraEnabled public Decimal totalValue = 0;
        @AuraEnabled public String familyName = ''; // Alexandre Amaro 09-07 correção bugFix
        @AuraEnabled public List<ProductPromo> lstPromotions = new List<ProductPromo> ();
        @AuraEnabled public String pointId = '';
        @AuraEnabled public String idSuspension = '';
    }
    public class AdditionalTV {
        @AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
        @AuraEnabled public List<Optional> lstOptionalPoints = new List<Optional> ();
        @AuraEnabled public List<Optional> lstOptionalPointsRPA = new List<Optional>();
        @AuraEnabled public List<Optional> lstOptionalPointsAPI = new List<Optional> ();
        @AuraEnabled public List<Optional> lstOptionalPointsPriceAPI = new List<Optional> ();
        @AuraEnabled public List<Optional> lstOptionalPointsPriceAPIByTechnology = new List<Optional>();
        @AuraEnabled public List<Optional> lstTechnology = new List<Optional> ();
        @AuraEnabled public List<Optional> lstTechnologyAPI = new List<Optional> ();
        @AuraEnabled public Optional firstPoint = new Optional();
        @AuraEnabled public Optional secondPoint = new Optional();
        @AuraEnabled public Optional thirdPoint = new Optional();
        @AuraEnabled public Optional fourthPoint = new Optional();
        @AuraEnabled public Additional fourKTechnology = new Additional('4K', 20);
        @AuraEnabled public Additional recordTechnology = new Additional('HD MAX - Recurso de Gravação', 20);
        @AuraEnabled public Additional fourKrecordTechnology = new Additional('4K + HD MAX - Recurso de Gravação', 40);
    }
    public class AdditionalBroadband {
        @AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
        @AuraEnabled public String protecaoDigitalSelected;
        @AuraEnabled public String smartHomeMonitorSelected;
        @AuraEnabled public String smartHomeAutomacaoSelected;
        @AuraEnabled public List<Optional> lstProtecaoDigital = new List<Optional> ();
        @AuraEnabled public List<Optional> lstSmartHomeMonitor = new List<Optional> ();
        @AuraEnabled public List<Optional> lstSmartHomeAutomacao = new List<Optional> ();
    }
    public class AdditionalPhone {
        @AuraEnabled public Additional secondLine = new Additional('Segunda Linha Grátis', 0);
        @AuraEnabled public Additional extensionPhone = new Additional('Vender Extensão do Net Fone', 20);
        @AuraEnabled public String quantityExtension;
    }
    public class AdditionalMobile {
        @AuraEnabled public List<Additional> lstAdditionals = new List<Additional> ();
    }
    public class Optional extends Additional implements Comparable {
        @AuraEnabled public Decimal price = 0;
        @AuraEnabled public Decimal quantity = 0;
        @AuraEnabled public Boolean isAlreadyIncluded = false;
        @AuraEnabled public ProductPromo promotion = new ProductPromo();
        public Integer compareTo(Object compareTo) {
            Optional compareToOppy = (Optional) compareTo;
            if (price > compareToOppy.price) {
                return 1;
            } else if (price < compareToOppy.price) {
                return -1;
            }
            return 0;
        }
    }
    public class BonusDesconto {
        @AuraEnabled public Decimal valor = 0;
        @AuraEnabled public Boolean check;
        @AuraEnabled public Boolean disabled;
        @AuraEnabled public Decimal multa = 0;
        @AuraEnabled public String valorRPA = '';
    }
    public class Fee {
        @AuraEnabled public String label = '';
        @AuraEnabled public Decimal value = 0;
        @AuraEnabled public Integer qtQuota = 0;
        @AuraEnabled public String paymentMethod = '';
        @AuraEnabled public String technologyType = '';
    }
    public class Fidelity {
        @AuraEnabled public Date startDate;
        @AuraEnabled public Integer remainingDays = 0;
        @AuraEnabled public Boolean hasFidelity = false;
        @AuraEnabled public Boolean hasPenalty = false;
        @AuraEnabled public Decimal penalty = 0;
        @AuraEnabled public Decimal totalPenaltyValue = 0; //fidelity.feeValue (multa da fidelidade)
        @AuraEnabled public Decimal loyaltMonths = 0; //fidelity.loyaltMonths (meses de fidelidade)
    }
    public class Promotion {
        @AuraEnabled public String label;
    }
    public class IsencaoTaxa {
        @AuraEnabled public String label;
        @AuraEnabled public String tipo;
        @AuraEnabled public String preco;
        @AuraEnabled public Boolean checked;
    }
    public class AgregadoInformativo {
        @AuraEnabled public String nomeDaMae = '';
        @AuraEnabled public String rg = '';
        @AuraEnabled public String orgaoEmissorRG = '';
        @AuraEnabled public String dataEmissaoDoRG = '';
        @AuraEnabled public String dataeNascimentodoTitular = '';
    }
    public class TemporarySuspension {
        @AuraEnabled public String period;
        @AuraEnabled public String modality;
        @AuraEnabled public Decimal taxValue;
    }
    
    public class RetornoContratoResidencial {
        @AuraEnabled public String propertyHpId;
        @AuraEnabled public String networkNodeCode;
        @AuraEnabled public String status;
		@AuraEnabled public String subscriberId;
		@AuraEnabled public String cdBase;        
        @AuraEnabled public Boolean contractPME = false;
    }

    public class RetornoContratoMovel {
        @AuraEnabled public String status;
        @AuraEnabled public String reason;
    }

    public class ResultViabilidade {
        @AuraEnabled public Boolean VIRTUA = false;
        @AuraEnabled public Boolean VOIP = false;
        @AuraEnabled public Boolean BSOD = false;
        @AuraEnabled public Boolean VOD = false;
        @AuraEnabled public Boolean DIGITAL = false;
        @AuraEnabled public Boolean PTV = false;
    }
    public class DadosInvalidosException extends Exception {
    }
    public class SemResultadosRetornadosException extends Exception {
    }
}