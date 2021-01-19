/*
* Autor: RLdO
* Data: 30-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe de integracao com vlocity para simulacao:
- checagem de prospect;
- enriquecimento de cadastro na RF;
- analise de credito;
- viabilidade tecnica;
- portabilidade;

> Henrique Almeida
- check expired orders;
- updateDadosVendedor
- getCity 
- trativa no getIbge para que quando houuver mais de dois operatorCodes eliminar o operatorCode 21 - 17/12/2020 - linha 155
*/
global without sharing class CEC_CheckCustomer implements vlocity_cmt.VlocityOpenInterface
{
    private static final Set<String> SET_STATUS_PROSPECT = new Set<String>{ 'CANCELLED', 'CANCELADO' };
        
        global Boolean invokeMethod(String methodName, Map<String, Object> inputMap,
                                    Map<String, Object> outMap, Map<String, Object> options)
    {
        //system.debug('teste invoke');
        if (String.isBlank(methodName))
        {
            return false;
        }
        if (methodName.equalsIgnoreCase('getCreditAnalysis'))
        {
            return getCreditAnalysis(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('criptoCartId'))
        {
            return criptoCartId(inputMap, outMap, options);
        }
        
        if (methodName.equalsIgnoreCase('getPortabilityWindows'))
        {
            return getPortabilityWindows(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getPortabilityOperator'))
        {
            return getPortabilityOperator(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getAddressList'))
        {
            return getAddressList(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getDomiciles'))
        {
            return getDomiciles(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getTechViability'))
        {
            return getTechViabilityNew(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getExpiredOrderItens'))
        {
            return getExpiredOrderItens(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('updateDadosVendedor'))
        {
            return updateDadosVendedor(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getCity'))
        {
            return getCity(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getHistoryProposal'))
        {
            return getHistoryProposal(inputMap, outMap, options); // OK
        }
        if (methodName.equalsIgnoreCase('getDomicileHistory'))
        {
            return getDomicileHistory(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('deleteCartItens'))
        {
            return deleteCartItens(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getInstallments'))
        {
            return getInstallments(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getObjectToRobot'))
        {
            return getObjectToRobot(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('createNewHP'))
        {
            return createNewHP(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('createNewHPAnalysis'))
        {
            return createNewHPAnalysis(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('portabilitiesPreAnalysis'))
        {
            return portabilitiesPreAnalysis(inputMap, outMap, options);
        }        
        if (methodName.equalsIgnoreCase('sendProposal'))
        {
            return sendProposal(inputMap, outMap, options);
        }
        if (methodName.equalsIgnoreCase('getBillingCycles'))
        {
            return getBillingCycles(inputMap, outMap, options);
        }
        else
        {
            String lCPF = (options != null) ? (String)options.get('CPF') : '';
            checkProspect(inputMap, outMap, options);
            checkDadosPessoa(inputMap, outMap, options);
            
            Account lAccRes = (Account)outMap.get('account');
            if (lAccRes != null)
            {
                lAccRes.put('DocumentNumber__c', lCPF);
                lAccRes.put('vlocity_cmt__Status__c', 'Prospect Grupo');
                lAccRes.put('DocumentType__c', (lCPF.length() == 14) ? 'CNPJ' : 'CPF');
            }
            return String.isNotBlank(lCPF);
        }
    }
    
    private static Boolean setError(Map<String, Object> outMap, String aMsg)
    {
        if (outMap != null && String.isNotBlank(aMsg)) outMap.put('error', aMsg);
        return false;
    }
    
    public static list<IBGE__c> getIbge(Map<String, Object> inputMap, Map<String, Object> outMap,
                                         Map<String, Object> options)
    {
        String lUF = String.valueOf(inputMap.get('uf')), lCidade = String.valueOf(inputMap.get('cidade'));
        lCidade = lCidade.replaceAll('\'','');
        
        lCidade = lCidade.replaceAll('\'','');
        
        list<String> lLstWhereClause = new list<String>();
        if (String.isNotBlank(lUF)) lLstWhereClause.add('UF__c = :lUF');
        if (String.isNotBlank(lCidade)) lLstWhereClause.add('CityName__c =:lCidade');
        String lQuery = 'select Id, UF__c, CityName__c, OperatorCode__c, CityCode__c from IBGE__c';
        lQuery += (lLstWhereClause.isEmpty()) ? '' : (' WHERE ' + String.join(lLstWhereClause, ' AND '));
            lQuery += ' order by UF__c, CityName__c';
        
        List<IBGE__c> lstIbge = database.query(lQuery);
        
        //Tratativa para que caso tenha mais de 1 operatorCode, eliminar qualquer operatorCode 21
        if(lstIbge.size()>1)
        {
            for(Integer i = 0; i < lstIbge.size(); i++)
            {
                if(lstIbge[i].OperatorCode__c == 21)
                {
                    lstIbge.remove(i);
                }
            }  
        }
        return lstIbge;
    }
    
    private static Boolean getPortabilityWindows(Map<String, Object> inputMap, Map<String, Object> outMap,
                                                 Map<String, Object> options)
    {
        list<CEC_RestObjects.WindowPortabilityType> lLstPtWin = new list<CEC_RestObjects.WindowPortabilityType>();
        outMap.put('portabilityWindows', lLstPtWin);
        CEC_RestObjects.WindowsPortability lPortWindow;
        
        lPortWindow = CEC_IntegrationPortWindows.consultar(new list<String>());
        if (lPortWindow == null || lPortWindow.data == null || lPortWindow.data.windowsPortability == null || lPortWindow.data.windowsPortability.windowPortability == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lPortWindow == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lPortWindow.error != null) lMessage = Label.CEC_ServIndisponivel;//lPortWindow.error.message;
            return setError(outMap, lMessage);
        }
        lLstPtWin.addAll(lPortWindow.data.windowsPortability.windowPortability);
        return true;
    }
    
    private static Boolean getPortabilityOperator(Map<String, Object> inputMap, Map<String, Object> outMap,
                                                  Map<String, Object> options)
    {
        list<CEC_RestObjects.PortabilityPhoneType> lLstPtOp = new list<CEC_RestObjects.PortabilityPhoneType>();
        outMap.put('portabilityOperator', lLstPtOp);
        CEC_RestObjects.Portability lPortOperator;
        
        String lTelefone = String.valueOf(inputMap.get('number'));
        if (String.isBlank(lTelefone)) return setError(outMap, 'Telefone inválido');
        list<String> lLstArgs = new list<String>{ 'phoneLineNumber=' + lTelefone.replaceAll('\\D', '') };
            
            lPortOperator = CEC_IntegrationPortability.consultar(lLstArgs);
        if (lPortOperator == null || lPortOperator.data == null || lPortOperator.data.phoneType == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lPortOperator == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lPortOperator.error != null) lMessage = Label.CEC_ServIndisponivel;//lPortOperator.error.message;
            return setError(outMap, lMessage);
        }
        PortabilitiesPreAnalysisDTO.TelephoneNumber telephoneNumber = new PortabilitiesPreAnalysisDTO.TelephoneNumber();
        telephoneNumber.number_Z = String.valueOf(inputMap.get('number'));
        
        PortabilitiesPreAnalysisDTO.Tickets tickets = new PortabilitiesPreAnalysisDTO.Tickets();
        tickets.id = '';
        tickets.telephoneNumber = telephoneNumber;
        
        PortabilitiesPreAnalysisDTO.Availables availables = new PortabilitiesPreAnalysisDTO.Availables();
        availables.portabilityIndicatorSource = lPortOperator.data.phoneType[0].portabilityIndicator;
        availables.name = lPortOperator.data.phoneType[0].actualMobileCarrier.carrierName;
        availables.spidCode = lPortOperator.data.phoneType[0].actualMobileCarrier.spidCode;
        availables.tickets = new list <PortabilitiesPreAnalysisDTO.Tickets>{tickets};
        availables.tickets.add(tickets);
        
        PortabilitiesPreAnalysisDTO.Vailables portability = new PortabilitiesPreAnalysisDTO.Vailables();
        portability.Availables = availables;
        
        PortabilitiesPreAnalysisDTO.PortabilityPre portabilityPre = new PortabilitiesPreAnalysisDTO.PortabilityPre();
        portabilityPre.portabilty = portability;
        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portErro = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis();
        portErro.data = portabilityPre;
        
        outMap.put('Portabilities', portErro);
        lLstPtOp.addAll(lPortOperator.data.phoneType);
        return true;
    }
    
    private static Boolean getCreditAnalysis(Map<String, Object> inputMap, Map<String, Object> outMap,
                                             Map<String, Object> options)
    {
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lResp;
        
        outMap.put('creditAnalysis', new IntegrationCreditAnalysisMobileDTO.CreditSituation());
        
        String lServico = String.valueOf(inputMap.get('servico')), lNroProtocolo = String.valueOf(inputMap.get('nroprotocolo'));
        map<String, Object> lMapAccount = (map<String, Object>)inputMap.get('conta');
        String lUF = (String)lMapAccount.get('BillingState'), lCidade = (String)lMapAccount.get('BillingCity'),
            lDocNumber = (String)lMapAccount.get('DocumentNumber__c'), lNome = (String)lMapAccount.get('Name'),
            lDataNasc = (String)lMapAccount.get('BirthDate__c'), lCEP = (String)lMapAccount.get('BillingPostalCode'),
            lEmail = (String)lMapAccount.get('Email__c'), lTelRes = (String)lMapAccount.get('Phone'),
            lOrigem = (String)lMapAccount.get('Origin__c'), lRG = (String)lMapAccount.get('RG__c'),
            lNomeMae = (String)lMapAccount.get('MothersName__c');
        


        list<IBGE__c> lLstIBGE = getIbge(new map<String, Object>{'uf' => lUF, 'cidade' => lCidade }, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        Id lUserId = (Id)inputMap.get('userId');
        lUserId = (lUserId == null) ? UserInfo.getUserId() : lUserId;
        User lCurrUser = [select Id, FirstName, LastName, Channel__c, CEC_SalesAgent__c, CEC_Seller__c, FederationIdentifier,
                          CEC_Regional__c, CEC_PointSale__c, Claro__c, NetServicos__c, SalesTeamNET__c from User where Id = :lUserId];
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c), lCityCode = String.valueOf(lLstIBGE[0].CityCode__c);
        lDocNumber = (String.isBlank(lDocNumber)) ? null : lDocNumber.replaceAll('\\D', '');
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        lCityCode = '0'.repeat(5 - lCityCode.length()) + lCityCode;
        
        map<String, String> lMapArgs = new map<String, String>{
            /* campos fixos analise de credito residencial */
            'DI_ORIGEM' => Label.CEC_Cred_DIORIGEM,
                'DSP_PARCEIRO' => Label.CEC_Cred_DSP_PARCEIRO,
                'DS_PROMOCAO' => Label.CEC_Cred_idApp,
                'DSP_PRECO_MENSAL' => Label.CEC_Cred_DSP_PRECO_MENSAL,
                'DSP_PRODUTO' => Label.CEC_Cred_DSP_PRODUTO,
                'DSP_PROMOCAO' => Label.CEC_Cred_idApp,
                'DSP_PRECO_ADESAO' => Label.CEC_Cred_DSP_PRECO_ADESAO,
                /* campos analise de credito residencial */
                'COD_OPERADORA' => lOperatorCode,
                'DI_CPF_CNPJ' => lDocNumber,
                'DA_TIPO_PESSOA' => ((lDocNumber.length() == 14) ? 'JURIDICA' : 'FISICA'),
                'DI_NOME' => lNome,
                'DE_CIDADE_OPERADORA' => lCityCode,
                //'DA_DATA_NASCIMENTO' => lDtBirthDate.format('dd/MM/yyyy'),
                'DP_NUMERO_PROPOSTA' => lNroProtocolo.right(10),
                'DEC_CEP' => lCEP,
                'DE_CEP' => lCEP,
                'DEC_CIDADE' => lCidade,
                'DEC_ESTADO' => lUF,
                'DI_EMAIL' => lEmail,
                'DIG_EMAIL' => lEmail,
                'DI_TELEFONE_PRINCIPAL' => lTelRes,
                'DI_TELEFONE_RESIDENCIAL' => lTelRes,
                'DIG_TELEFONE_RESIDENCIAL' => lTelRes,
                'DI_RG' => lRG,
                'DIG_NOME_MAE' => lNomeMae,
                'DCB_EXCLIENTE' => ((lOrigem == 'EX-ASSINANTE') ? 'SIM' : 'NAO'),
                'DV_ATENDENTE' => lCurrUser.NetServicos__c != null ? lCurrUser.NetServicos__c : lCurrUser.FederationIdentifier,//'MCIDA',                        // usar campos do objeto User
                    'DV_EQUIPE_VENDA' => lCurrUser.SalesTeamNET__c,//'AGENTE AUTORIZADO-NET CAM', // usar campos do objeto User
                    'DV_VENDEDOR' => String.join(new String[]{ lCurrUser.FirstName, lCurrUser.LastName }, ' ').toUpperCase(),
                    /* campos analise de credito movel */
                    'type' => Label.CEC_cred_type,
                    'operation' => Label.CEC_Cred_operation,
                    'IdRelated' => '',
                    'typeCredRelated' => '',
                    'typeApp' => Label.CEC_Cred_typeApp,
                    'idApp' => Label.CEC_Cred_idApp,
                    'userIdApp' => lCurrUser.Claro__c != null ? lCurrUser.Claro__c : lCurrUser.FederationIdentifier ,//'92035776',
                        'channelId' => lCurrUser.Channel__c,//'AGENTE_AUTORIZADO',
                        'pointSaleId' => lCurrUser.CEC_PointSale__c,
                        'sellerId' => lCurrUser.CEC_Seller__c,
                        'salesAgentId' => lCurrUser.CEC_SalesAgent__c,
                        'regionalId' => lCurrUser.CEC_Regional__c,
                        'genderClient' => (String)lMapAccount.get('Gender__c')
                        };
                            if (lDataNasc != null)
                        {
                            lMapArgs.put('DA_DATA_NASCIMENTO', lDataNasc);
                            lMapArgs.put('dateOfBirthClient', lDataNasc);
                        }
        lResp = (lServico != null && lServico.equalsIgnoreCase('MOVEL')) ? CEC_IntegrationCreditAnalysisMobile.consultar(lMapArgs) : CEC_IntegrationCreditAnalysis.consultar(lMapArgs);
        if (lResp == null || lResp.data == null || lResp.data.creditSituation == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lResp == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lResp.error != null) lMessage = Label.CEC_ServIndisponivel;//lResp.error.message;
            return setError(outMap, lMessage);
        }
        //system.debug('creditAnalysis =>' + JSON.serializePretty(lResp));
        outMap.put('creditAnalysis', lResp.data.creditSituation);
        outMap.put('SalesCreditAnalysis', lResp);
        
        return true;
    }
    
    private static Boolean getAddressList(Map<String, Object> inputMap, Map<String, Object> outMap,
                                          Map<String, Object> options)
    {
        list<CEC_RestObjects.AddressGED> lLstAddr = new list<CEC_RestObjects.AddressGED>();
        outMap.put('addressList', lLstAddr);
        
        String lUF = String.valueOf(inputMap.get('uf')), lCidade = String.valueOf(inputMap.get('cidade')),
            lCEP = String.valueOf(inputMap.get('cep')), lLogradouro = String.valueOf(inputMap.get('logradouro')),
            nPage = String.valueOf(inputMap.get('page')), nLimit = String.valueOf(inputMap.get('limit')),
        	searchType = String.valueOf(inputMap.get('searchType'));
        
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        
        list<String> lLstArgs = new list<String>{ 'operatorCode=' + lOperatorCode };
            if (String.isNotBlank(lCEP)) lLstArgs.add('postalCode=' + lCEP.replaceAll('\\D', ''));
            if (String.isNotBlank(lLogradouro)) lLstArgs.add('streetName=' + EncodingUtil.urlEncode(lLogradouro, 'UTF-8'));
        	if(String.isNotBlank(nPage)) lLstArgs.add('page=' + EncodingUtil.urlEncode(nPage, 'UTF-8'));
            if(String.isNotBlank(nLimit)) lLstArgs.add('limit=' + EncodingUtil.urlEncode(nLimit, 'UTF-8'));
            if(String.isNotBlank(searchType)) lLstArgs.add('searchType=' + EncodingUtil.urlEncode(searchType, 'UTF-8'));
               
        CEC_RestObjects.AddressesGED lAddrGED = CEC_IntegrationAddressesGED.consultar(lLstArgs);
        if (lAddrGED == null || lAddrGED.data == null || lAddrGED.data.addresses == null || lAddrGED.data.addresses.address == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lAddrGED == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lAddrGED.error != null) lMessage = Label.CEC_ServIndisponivel;//lAddrGED.error.message;
            return setError(outMap, lMessage);
        }
        
        outMap.put('operatorCode', lOperatorCode);
        outMap.put('totalListCount', lAddrGED.data.totalListCount);
        
        lLstAddr.addAll(lAddrGED.data.addresses.address);
        return true;
    }
    
    private static Boolean getDomiciles(Map<String, Object> inputMap, Map<String, Object> outMap,
                                        Map<String, Object> options)
    {
        list<CEC_RestObjects.buldings> lLstEdif = new list<CEC_RestObjects.buldings>();
        outMap.put('domiciles', lLstEdif);
        //system.debug(inputMap);
        String lUF = String.valueOf(inputMap.get('uf')), lCidade = String.valueOf(inputMap.get('cidade')),
            lCEP = String.valueOf(inputMap.get('cep')), lPage = String.valueOf(inputMap.get('page')),
            lLimit = String.valueOf(inputMap.get('limit')), lStreetId = String.valueOf(inputMap.get('streetId'));
        //lStreetIdClaro = String.valueOf(inputMap.get('streetidClaro')), lStreetIdNet = String.valueOf(inputMap.get('streetidNet'));
        
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options); 
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        list<String> lLstArgs = new list<String>{ 'operatorCode=' + lOperatorCode };
            
            if (String.isNotBlank(lCEP)) lLstArgs.add('postalCode=' + lCEP.replaceAll('\\D', ''));
        //if (String.isNotBlank(lStreetId)) lLstArgs.add('streetId=' + lStreetId);
        //if (String.isNotBlank(lStreetId)) lLstArgs.add('streetidClaro=' + lStreetIdClaro);
        if (String.isNotBlank(lStreetId)) lLstArgs.add('streetIdNet=' + lStreetId);
        if (String.isNotBlank(lPage)) lLstArgs.add('page=' + lPage);
        if (String.isNotBlank(lLimit)) lLstArgs.add('limit=' + lLimit);
        
        CEC_RestObjects.AddressesGEDDom lDomAddrGED = CEC_IntegrationDomAddressesGED.consultar(lLstArgs);
        if (lDomAddrGED == null || lDomAddrGED.data == null || lDomAddrGED.data.buldings == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lDomAddrGED == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lDomAddrGED.error != null) lMessage = Label.CEC_ServIndisponivel;//lDomAddrGED.error.message;
            return setError(outMap, lMessage);
        }
        
        outMap.put('operatorCode', lOperatorCode);
        lLstEdif.addAll(lDomAddrGED.data.buldings);
        return true;
    }
    
    private static Boolean getTechViability(Map<String, Object> inputMap, Map<String, Object> outMap,
                                            Map<String, Object> options)
    {
        CEC_RestObjects.Domiciles lDomicile = new CEC_RestObjects.Domiciles();
        lDomicile.availability = new list<CEC_RestObjects.Availability>();
        outMap.put('techViability', lDomicile);
        
        String lUF = String.valueOf(inputMap.get('uf')), lCidade = String.valueOf(inputMap.get('cidade')),
            lDomId = String.valueOf(inputMap.get('domicileid'));
        
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        list<String> lLstArgs = new list<String>{ 'operatorCode=' + lOperatorCode };
            
            if (String.isNotBlank(lDomId)) lLstArgs.add('domicileId=' + lDomId);
        
        CEC_RestObjects.GeographicLocation lGeoAddrGED = CEC_IntegrationGeoLocation.consultar(lLstArgs);
        if (lGeoAddrGED == null || lGeoAddrGED.data == null || lGeoAddrGED.data.domicile == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lGeoAddrGED == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lGeoAddrGED.error != null) lMessage = Label.CEC_ServIndisponivel;
            return setError(outMap, lMessage);
        }
        
        outMap.put('techViability', lGeoAddrGED.data.domicile);
        outMap.put('operatorCode', lGeoAddrGED.data.domicile);
        return true;
    }
    private static Boolean getTechViabilityNew(Map<String, Object> inputMap,Map<String, Object>  outMap, Map<String, Object>  options){
        CEC_RestObjects.Domiciles lDomicile = new CEC_RestObjects.Domiciles();
        lDomicile.availability = new list<CEC_RestObjects.Availability>();
        outMap.put('techViability', lDomicile);
        
        String lUF = String.valueOf(inputMap.get('uf')), lCidade = String.valueOf(inputMap.get('cidade')),
            lDomId = String.valueOf(inputMap.get('domicileid'));
        
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        list<String> lLstArgs = new list<String>{ 'operatorCodeNet=' + lOperatorCode /*, 'operatorCodeClaroTv=' + lOperatorCode*/};
            
            if (String.isNotBlank(lDomId)){ 
                lLstArgs.add('domicileIdNet=' + lDomId);
                //lLstArgs.add('domicileIdClaroTv=' + lDomId );
            }
        
        CEC_IntegrationGeoLocationDTO lGeoAddrGED = new CEC_IntegrationGeographicLocation().consultar(lLstArgs);
        if (lGeoAddrGED == null || lGeoAddrGED.data == null || lGeoAddrGED.data.domiciles == null)
        {
            // integration error
            String lMessage = Label.CEC_SemResultados;
            if (lGeoAddrGED == null) return setError(outMap, Label.CEC_ServIndisponivel);
            //if (lGeoAddrGED.error != null) lMessage = Label.CEC_ServIndisponivel;
            return setError(outMap, lMessage);
        }
        
        outMap.put('techViability', lGeoAddrGED.data.domiciles);
        outMap.put('operatorCode', lGeoAddrGED.data.domiciles);
        return true;
    }
    
    private static void checkProspect(Map<String, Object> inputMap, Map<String, Object> outMap,
                                      Map<String, Object> options)
    {
        if (outMap == null) return;
        outMap.put('CPF', null);
        
        String lCPF = (inputMap != null) ? (String)options.get('CPF') : null;
        if (String.isNotBlank(lCPF)) lCPF = lCPF.replaceAll('\\D', '');
        
        Boolean lCheckCPF = String.isNotBlank(lCPF), lIsBase = false, lIsBaseMovel = false, lIsBaseRes = false;
        lCheckCPF &= ((lCPF.length() == 11) ? CEC_Utils.validateCPF(lCPF) : true);
        lCheckCPF &= ((lCPF.length() == 14) ? CEC_Utils.validateCNPJ(lCPF) : true);
        
        Account lAcc = null;
        CEC_RestObjects.CustomerAccounts lCustAccAux, lCustAcc = new CEC_RestObjects.CustomerAccounts(lAcc);
        
        // constroi um customer para o retorno de documento invalido
        CEC_RestObjects.Customer lCustomer = new CEC_RestObjects.Customer();
        lCustomer.data = new CEC_RestObjects.CustomerData();
        lCustomer.data.customerAccounts = new list<CEC_RestObjects.CustomerAccounts>{ lCustAcc };
            
            CEC_RestObjects.Subscribers lSubscribers = new CEC_RestObjects.Subscribers();
        lSubscribers.customer = lCustAcc;
        
        CEC_RestObjects.AllSubscribers lAllSubscribers = new CEC_RestObjects.AllSubscribers();
        lAllSubscribers.data = new CEC_RestObjects.SubscribersData();
        lAllSubscribers.data.subscribers = new list<CEC_RestObjects.Subscribers>{ lSubscribers };
            
            outMap.put('isBaseMovel', false);
        outMap.put('isBaseResidencial', false);
        
        // faz o callout movel se o documento foi validado e a conta não foi encontrada
        lAllSubscribers = (lCheckCPF && CEC_IntegrationProspectMovel.param.IsActive__c)
            ? CEC_IntegrationProspectMovel.consultar(lCPF) : lAllSubscribers;
        //system.debug(JSON.serializePretty(lAllSubscribers, true));
        if (lAllSubscribers != null && lAllSubscribers.Error != null) setError(outMap, lAllSubscribers.Error.message);
        
        if (lAllSubscribers != null && lAllSubscribers.data != null && lAllSubscribers.data.subscribers != null)
        {
            for (CEC_RestObjects.Subscribers iCustAcc: lAllSubscribers.data.subscribers)
            {
                if (iCustAcc.customer != null && String.isBlank(iCustAcc.status)) continue;
                Boolean lFound = (iCustAcc.customer != null && String.isNotBlank(iCustAcc.status) && SET_STATUS_PROSPECT.contains(iCustAcc.status.toUpperCase())); // vai estar ativo, logo aqui recebe false
                lIsBase |= !lFound; //se estiver cancelado o is propect lá no final fica como true se não o is prospect fica como false e o is base fica como true
                lIsBaseMovel |= !lFound; //
                if (lFound) lCustAccAux = iCustAcc.customer;
                if (lIsBase) break;
            }
            if (lCustAccAux != null) lCustAcc = lCustAccAux;
        }
        
        
        Boolean lConsultRes = (lCheckCPF && !lIsBase && lCustAccAux == null && CEC_IntegrationProspect.param.IsActive__c);
        lConsultRes |= Test.isRunningTest();
        
        // faz o callout (residencial) se o documento foi validado e a conta não foi encontrada no SF e eh prospect na movel
        
        lCustomer = CEC_IntegrationProspect.param.IsActive__c ? CEC_IntegrationProspect.consultar(lCPF) : lCustomer;
        //system.debug(JSON.serializePretty(lCustomer, true));
        if (lCustomer != null && lCustomer.Error != null) setError(outMap, lCustomer.Error.message);
        
        if (lCustomer != null && lCustomer.data != null && lCustomer.data.customerAccounts != null)
        {
            for (CEC_RestObjects.CustomerAccounts iCustAcc: lCustomer.data.customerAccounts)
            {
                if (String.isBlank(iCustAcc.status)) continue;
                Boolean lFound = (SET_STATUS_PROSPECT.contains(iCustAcc.status.toUpperCase()));
                lIsBase |= !lFound;
                lIsBaseRes |= !lFound;
                if (lFound) lCustAccAux = iCustAcc;
                if (lIsBase) break;
            }
            if (lCustAccAux != null) lCustAcc = lCustAccAux;
            
        }
        lIsBase = FeatureManagement.checkPermission('CRM_Cross') ? false : lIsBase;
        outMap.put('isBaseMovel', lIsBaseMovel);
        outMap.put('isBaseResidencial', lIsBaseRes);
        outMap.put('doctoValidado', lCheckCPF);
        outMap.put('CPF', lCPF);
        outMap.put('isProspect', !lIsBase);
        outMap.put('account', lCustAcc.getAccount());
       // System.debug('')
        outMap.put('checkRF', (lAcc == null));
    }
    
    private static void checkDadosPessoa(Map<String, Object> inputMap, Map<String, Object> outMap,
                                         Map<String, Object> options)
    {
        if (outMap == null) return;
        
        String lCPF = (options != null) ? (String)options.get('CPF') : null;
        if (String.isNotBlank(lCPF)) lCPF = lCPF.replaceAll('\\D', '');
        
        Boolean lCheckCPF = (String.isNotBlank(lCPF)), lCheckRF = (Boolean)outMap.get('checkRF');
        lCheckCPF &= ((lCPF.length() == 11) ? CEC_Utils.validateCPF(lCPF) : true);
        lCheckCPF &= ((lCPF.length() == 14) ? CEC_Utils.validateCNPJ(lCPF) : true);
        
        CEC_RestObjects.CustomerAccounts lCustAcc = new CEC_RestObjects.CustomerAccounts();
        CEC_RestObjects.DadosPessoa lDadosPessoa = new CEC_RestObjects.DadosPessoa();
        lDadosPessoa.data = lCustAcc;
        
        list<String> lLstArgs = new list<String>{ 'documentNumberCPF=' + lCPF, 'segmentationId=CLAR', 'reasonId=PROSPECCAO' };
            lDadosPessoa = (lCheckRF && CEC_IntegrationDadosPessoa.param.IsActive__c) ? CEC_IntegrationDadosPessoa.consultar(lLstArgs) : lDadosPessoa;
        
        lCustAcc = (lDadosPessoa != null && lDadosPessoa.data != null) ? lDadosPessoa.data : lCustAcc;
        
        outMap.put('CPF', lCPF);
        outMap.put('account', lCustAcc.getAccount());
    }
    
    private static Boolean getExpiredOrderItens(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        Order varOrder = [SELECT Id, OwnerId, Owner.Name, Status FROM Order WHERE Id = :(String)inputMap.get('cartId')];
        List<OrderItem> lstItens = [SELECT Id, Product2.isActive, Product2.Name FROM OrderItem WHERE OrderId = :varOrder.Id];
        
        if(varOrder.OwnerId != userInfo.getUserId())
        {
            setError(outMap,'O pedido pertence á: '+varOrder.Owner.Name);
            return true;
        }
        if(varOrder.Status != 'Em Andamento')
        {
            setError(outMap, 'Pedido já processado!');
            return true;
        }
        
        for(OrderItem item : lstItens)
        {
            if(!item.Product2.isActive)
            {
                setError(outMap,'O seguinte produto foi desativado: '+item.Product2.Name);
                return true;
            }
        }
        return false;
    }


    /*
	* Autor: João Torres - OSF DIGITAL
	* Descrição: Solar FASE 1 - Squad Evolutivas - Sprint FASE 1 
	* Método com o objetivo de realizar as integrações e atualizar as informações do vendedor 
	*/

    public static Boolean updateDadosVendedor(Map<String, Object> inputMap, Map<String, Object> outMap,
            Map<String, Object> options)
    {
        Boolean bClaro = false;
        Boolean bNet = false;


        //system.debug('OptionsMap: '+Json.serializePretty(options));
        //system.debug('DadosdeEndereço: '+(Object)inputMap.get('CEC_ASClienteSelectCidade'));


        String lUF = String.valueOf(options.get('uf')),
               lCidade = String.valueOf(options.get('cidade'));

        // na variavel lCidade remover o apóstrofo usando o replace;
        //system.debug('USER - ' +lCidade);
        // usar regular expression para montar o lLstIBGE através de um SELECT, na clausula WHERE, removendo os accentos da coluna Cidade via SOQL 
        
        list<IBGE__c> lLstIBGE = getIbge(new map<String, Object>{'uf' => lUF, 'cidade' => lCidade }, outMap, options);

        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);

        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;

        User varUser = [SELECT Id, Channel__c, CEC_PointSale__c, CEC_Regional__c, CEC_SalesAgent__c, CEC_Seller__c, Claro__c,
                NetServicos__c, SalesTeamNET__c, FederationIdentifier FROM User WHERE Id = :userInfo.getUserId()];

        SalesManDTO.SalesMan integration;
        CEC_RestObjects.SalesManRes lSalesMan;

        if (varUser.Claro__c != null)
        {
            bClaro = true;
            integration = CEC_IntegrationSales.consultar(varUser.Claro__c);

            //system.debug('flash integration>>>>'+integration);
            //system.debug('RESPONSE: '+Json.serializePretty(integration, true));

        }
        if (varUser.NetServicos__c != null && (!String.isBlank(lUF) && !String.isBlank(lCidade))) {
            bNet = true;

            List<String> lstArgs = new List<String>{'operatorCode='+lOperatorCode,'login='+varUser.NetServicos__c};

            lSalesMan = CEC_IntegrationSalesResidencial.consultar(lstArgs);
            //system.debug('lSALESMAN vloster>>'+lSalesMan);
        }
        if ((varUser.Claro__c == null) && (varUser.NetServicos__c == null) && (varUser.FederationIdentifier != null)) {
            bClaro = true;
            bNet = true;

            // Claro
            integration = CEC_IntegrationSales.consultar(varUser.FederationIdentifier);

            //system.debug('integration flash>>>'+integration);

            // NET
            List<String> lstArgs = new List<String>{'login='+varUser.FederationIdentifier,'operatorCode='+lOperatorCode};
            if(!String.isBlank(lUF) && !String.isBlank(lCidade))
            {
                lSalesMan = CEC_IntegrationSalesResidencial.consultar(lstArgs);
            }
        }
        if (bClaro && (integration != null && integration.data != null)) {

            varUser.Channel__c          = integration.data.salesman.salesAgent.channelId;
            varUser.CEC_PointSale__c    = integration.data.salesman.salesAgent.pointSale.isEmpty() ? '': integration.data.salesman.salesAgent.pointSale[0].businessName;
            varUser.CEC_Regional__c     = integration.data.salesman.salesAgent.regionalId;
            varUser.CEC_SalesAgent__c   = integration.data.salesman.id;
            varUser.CEC_Seller__c       = integration.data.salesman.id;
            
            outMap.put('SalesMan', integration);
        }

       if (bNet && (lSalesMan!= null && lSalesMan.data != null && lSalesMan.data.company != null)) {

            varUser.SalesTeamNET__c = lSalesMan.data.company.get(0).salesChannel.get(0).salesTeam.get(0).description;
        }
        if (bClaro || bNet) {
            update varUser;
            return true;
        }
        return false;
    }
    private static Boolean criptoCartId(Map<String, Object> inputMap, Map<String, Object> outMap,
                                        Map<String, Object> options)
    {
        List<Account> objRobot = [SELECT Id, Name, Email__c FROM Account Limit 1];
        outMap.put('objRobot',objRobot);// (Object)encrypted);
        outMap.put('cartIdCripto', UserInfo.getUserId().left(10) + (String)inputMap.get('OrderId'));// (Object)encrypted);
        return false;
    }
    
    private static Boolean getCity(Map<String, Object> inputMap, Map<String, Object> outMap,
                                   Map<String, Object> options)
    {
        CEC_RestObjects.AddressesHeader integration;
        
        List<String> lstArgs = new List<String>{'zipCode='+(String)inputMap.get('zipCode'),
            'pageSize='+(String)inputMap.get('pageSize'), 
            'pageNumber='+(String)inputMap.get('pageNumber')};
                
                integration = CEC_IntegrationAddressCity.consultar(lstArgs);
        //system.debug('XXXXX: '+integration);
        
        if (integration == null || integration.data == null)
        {
            String lMessage = Label.CEC_SemResultados;
            if (integration == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (integration.error != null) lMessage = Label.CEC_ServIndisponivel;
            return setError(outMap, lMessage);
        }
        
        inputMap.put('uf', (Object)integration.data.address[0].state);
        inputMap.put('cidade', (Object)integration.data.address[0].city);
        inputMap.put('ddd', (Object)integration.data.address[0].ddd);
        
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        
        outMap.put('uf', (Object)integration.data.address[0].state);
        outMap.put('cidade', (Object)integration.data.address[0].city);
        outMap.put('ddd', String.valueOf((Object)integration.data.address[0].ddd));
        outMap.put('operatorCode', lOperatorCode); 
        
        return true;
    }
    private static Boolean getHistoryProposal(Map<String, Object> inputMap, Map<String, Object> outMap,
                                              Map<String, Object> options)
    {
        
        CEC_RestObjects.HistoryHeader lHistProposal;
        List<String> lstArgs = new List<String>{'operatorCode='     +(String)inputMap.get('operatorCode'),
            'idProposal='       +(String)inputMap.get('idProposal')};
                
                lHistProposal = CEC_IntegrationHistoryProposal.consultar(lstArgs);
        
        
        if (lHistProposal == null || lHistProposal.data == null)
        {
            String lMessage = Label.CEC_SemResultados;
            if (lHistProposal == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lHistProposal.error != null) lMessage = Label.CEC_ServIndisponivel;
            return setError(outMap, lMessage);
        }
        outMap.put('ProposalHistory', lHistProposal.data);
        return true;
    }
    private static Boolean getDomicileHistory(Map<String, Object> inputMap, Map<String, Object> outMap,
                                              Map<String, Object> options)
    {
        
        CEC_RestObjects.DomicileHeader lDomHistory;
        List<String> lstArgs = new List<String>{'operatorCode='     +(String)inputMap.get('operatorCode'),
            'idDomicile='       +(String)inputMap.get('idDomicile')};
                
                lDomHistory = CEC_IntegrationDomicileHistory.consultar(lstArgs);
        
        outMap.put('DomicileHistory', lDomHistory);
        
        if (lDomHistory == null || lDomHistory.data == null)
        {
            String lMessage = Label.CEC_SemResultados;
            if (lDomHistory == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (lDomHistory.error != null) lMessage = Label.CEC_ServIndisponivel;
            return setError(outMap, lMessage);
        }
        
        return true;
    }
    
    private static Boolean deleteCartItens (Map<String, Object> inputMap, Map<String, Object> outMap,
                                            Map<String, Object> options)
    {
        
        //system.debug('deleteCart: '+inputMap);
        String orderId = (String)inputMap.get('OrderId');
        if(String.isBlank(orderId))
        {
            return false;
        }
        else
        {
            List<OrderItem> lstItens = [SELECT Id FROM OrderItem WHERE OrderId = :orderId];
            delete lstItens;
            return true;
        }
    }
    
    private static Boolean getInstallments (Map<String, Object> inputMap, Map<String, Object> outMap,
                                            Map<String, Object> options)   
    {
        String recTypePriMatId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Politica_Commercial').getRecordTypeId();
        String recTypePricingMatId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Pricing').getRecordTypeId();
        Set<Id> setProductId = new Set<Id>();
        Integer fidelidade = 0;
        map<id,OrderItem> mapOrdItem = new map <id,OrderItem>();
        String prodMovel='', prodTv='', prodFone='', prodInternet='';
        
        List<OrderItem> lstOrderItem = [SELECT Id, Product2.Id, Product2.Family, Order.Cart_State__c, Order.Movel_Grupo__c, Meses_de_Fidelidade__c, Product2.vlocity_cmt__type__c, Product2.DescricaoFidelidade__c, Product2.Name, Fidelidade__c, Order.TV_Grupo__c, Order.Fone_Grupo__c, Order.Internet_Grupo__c, Grupo__c, DescricaoMulta__c 
                                        FROM OrderItem 
                                        WHERE OrderId = :(String)inputMap.get('cartId')];

        if(!lstOrderItem.isEmpty())
        {
            for(OrderItem item : lstOrderItem)
            {
                if(item.Product2.vlocity_cmt__type__c == 'Plano' || item.Product2.vlocity_cmt__type__c == 'Dependente')
                {  
                    setProductId.add(item.Product2.id);  
                } 
            }
        }
        else
        {
            return false;
        }
        
        List<Pricing_Matrix__c> lstPricingMatrix = [SELECT Id, Source_Product__c, Group__c, No_of_Installments__c,Description__c, Duration__c 
                                                    FROM Pricing_Matrix__c 
                                                    WHERE Source_Product__c IN :setProductId
                                                    AND RecordTypeId = :recTypePriMatId
                                                    AND PricingValue__c > 0
                                                    AND Modalidade__c = :lstOrderItem[0].Order.Cart_State__c
                                                    AND (Group__c = :lstOrderItem[0].Order.TV_Grupo__c 
                                                         OR Group__c = :lstOrderItem[0].Order.Fone_Grupo__c 
                                                         OR Group__c = :lstOrderItem[0].Order.Internet_Grupo__c
                                                         OR Group__c = :lstOrderItem[0].Order.Movel_Grupo__c)];
        
        List<Pricing_Matrix__c> lstDurationsMatrix = [SELECT Id, Source_Product__c, Group__c, No_of_Installments__c,Description__c, Duration__c 
                                                        FROM Pricing_Matrix__c 
                                                        WHERE Source_Product__c IN :setProductId
                                                        AND RecordTypeId = :recTypePricingMatId
                                                        AND Active__c = true
                                                        AND Modalidade__c = :lstOrderItem[0].Order.Cart_State__c
                                                        AND (Group__c = :lstOrderItem[0].Order.TV_Grupo__c 
                                                             OR Group__c = :lstOrderItem[0].Order.Fone_Grupo__c 
                                                             OR Group__c = :lstOrderItem[0].Order.Internet_Grupo__c
                                                             OR Group__c = :lstOrderItem[0].Order.Movel_Grupo__c)
            											AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))];
        
        List<TaxaAdesao> lstTax = new List<TaxaAdesao>(); 
        
        for (OrderItem oItem : lstOrderItem) 
        {
            Integer fidelidadeValue = oItem.Fidelidade__c == true ? 12 : 0;
            if(oItem.Product2.vlocity_cmt__type__c == 'Plano' || oItem.Product2.vlocity_cmt__type__c == 'Dependente'){  
                TaxaAdesao txAdd        = new TaxaAdesao();
                txAdd.description       = '';
                txAdd.installments      = '0';
                txAdd.pricingId         = '';
                txAdd.sourceProd        = new Product2();
                txAdd.sourceProd.Name   = oItem.Product2.Name;
                txAdd.sourceProd.Id     = oItem.Product2.Id;
                txAdd.sourceProd.Family = oItem.Product2.Family;
                txAdd.sourceProd.DescricaoFidelidade__c = oItem.Product2.DescricaoFidelidade__c;
                txAdd.OrderItemID       = oItem.Id;
                txAdd.grupo       		= oItem.Grupo__c;
                txAdd.isFedelity       	= oItem.Fidelidade__c;
                txAdd.durations       	= new List<Map<String,Object>>();
                txAdd.multa			 	= oItem.DescricaoMulta__c;
                
                if(!lstPricingMatrix.isEmpty()){        
                    for (Pricing_Matrix__c pc : lstPricingMatrix){
                        if(pc.Source_Product__c == oItem.Product2.Id){
                            if((pc.Group__c == oItem.Order.TV_Grupo__c 			|| 
                                pc.Group__c == oItem.Order.Fone_Grupo__c 		|| 
                                pc.Group__c == oItem.Order.Internet_Grupo__c 	||  
                                pc.Group__c == oItem.Order.Movel_Grupo__c		)&& pc.Duration__c == fidelidadeValue){
                                txAdd.installments = pc.No_of_Installments__c;
                                txAdd.description  = pc.Description__c;
                                txAdd.pricingId  = pc.Id;
                                break;
                            }else if(pc.Duration__c == fidelidadeValue){
                                txAdd.installments = pc.No_of_Installments__c;
                                txAdd.description  = pc.Description__c;   
                                txAdd.pricingId  = pc.Id;                     
                            }
                        }         
                    }
                }
                
                if(!lstDurationsMatrix.isEmpty()){        
                    for (Pricing_Matrix__c pc : lstDurationsMatrix){
                        if(pc.Source_Product__c == oItem.Product2.Id && pc.Group__c == oItem.Grupo__c){
                            Map<String,Object> durationMap = new Map<String,Object>();
                            durationMap.put('Duration__c', pc.Duration__c);
                            txAdd.durations.add(durationMap);
                        }         
                    }
                }
                
                lstTax.add(txAdd);
            }
        }
        outMap.put('recordsInstallments', lstTax);

        return true;
    }
    public class TaxaAdesao{
        String description;
        String installments;
        String pricingId;
        String OrderItemID;
        Product2 sourceProd;
        String grupo;
        Boolean isFedelity;
        List<Map<String,Object>> durations;
        String multa;
    }
    
    @TestVisible
    private static Boolean cartValidated (Map<String, Object> inputMap, Map<String, Object> outMap,
                                          Map<String, Object> options) 
    {
        outMap.put('cartValidated', true);
        List<OrderItem> lstOrderItem = [SELECT Id, Product2.Id, Order.Cart_State__c, Product2.Family, Meses_de_Fidelidade__c, Product2.vlocity_cmt__type__c, Product2.DescricaoFidelidade__c, Product2.Name, Fidelidade__c, Order.TV_Grupo__c, Order.Fone_Grupo__c, Order.Internet_Grupo__c 
                                        FROM OrderItem 
                                        WHERE OrderId = :(String)inputMap.get('cartId')];
        for (OrderItem oI : lstOrderItem){
            if((oI.Order.Cart_State__c=='Combo Multi' || oI.Order.Cart_State__c=='Single')&&(oI.Product2.Name == 'Ilimitado Brasil' || oI.Product2.Name == 'Ilimitado Mundo Total')){
                outMap.put('cartValidated', false);
                outMap.put('msgCartValidated', 'O produto'+ oI.Product2.Name +'não está disponivel na combinação Combo Multi');
            }
        }
        
        return false;                                          
    }
    private static Boolean getObjectToRobot (Map<String, Object> inputMap, Map<String, Object> outMap,
                                             Map<String, Object> options) 
    {
        String orderId = (String)inputMap.get('OrderId');
        if(String.isBlank(orderId))
        {
            return false;
        }
        else
        {
            list<Order> lLstObj = [select Id, Account.Name,  Account.MothersName__c, Account.Phone, Account.DocumentNumber__c, Account.BirthDate__c, 
                                   Account.MaritalStatus__c, Account.Occupation__c, Account.SalaryRange__c, Account.Gender__c, Account.Origin__c, Account.Email__c,
                                   Account.CellPhone__c, Account.Media__c, Account.CNPJFormula__c, Account.DocumentType__c, Account.RG__c,  Account.RGEmitter__c,
                                   Account.StateSubscription__c, Account.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c, Account.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                   BillingPostalCode, Forma_de_Pagamento__c, TipoFatura__c, DiaVencimento__c, Banco__c, Agencia__c, DvAgencia__c, NumeroConta__c, DvConta__c,
                                   BillingNumber__c, BillingStreet, TipoComplemento1__c, Complemento1__c, TipoComplemento2__c, Complemento2__c,TipoComplemento3__c,
                                   Complemento3__c, TipoComplemento4__c, Complemento4__c, NovoEndereco__c,NumeroHP__c, ShippingNumber__c, Unidade__c,
                                   Premises__r.vlocity_cmt__PostalCode__c
                                   from Order 
                                   where Id = : orderId];
            
            list<OrderItem> lstOrderItem = [Select Id, NumeroProvisorio__c, DDD__c, MSISDN__c, Product2.vlocity_cmt__SubType__c, Product2.Unidade__c,
                                            Product2.vlocity_cmt__type__c, Product2.Family, vlocity_cmt__SerialNumber__c
                                            from orderItem 
                                            where OrderId = : orderId
                                            ORDER BY vlocity_cmt__LineNumber__c, CreatedDate ASC];
            
            map<String, Object> mapObj = new map<String,object>();
            
            if(!lLstObj.isEmpty()){
                mapObj.put('sTipoProduto', lLstObj[0].Unidade__c);            
                mapObj.put('sIdVenda', lLstObj[0].Id);
                mapObj.put('sStatus', 'Ativa');
                mapObj.put('sNomeProspect', lLstObj[0].Account.Name);
                mapObj.put('sCEP', lLstObj[0].BillingPostalCode);
                //mapObj.put('sGenero', lLstObj[0].Account.Gender__c);
                mapObj.put('sGenero', 'Masculino');
                //mapObj.put('sEstadoCivil', lLstObj[0].Account.MaritalStatus__c);
                mapObj.put('sEstadoCivil', 'Outros');
                //mapObj.put('sProfissao', lLstObj[0].Account.Occupation__c);
                mapObj.put('sProfissao', 'Não informado');
                //mapObj.put('sFaixaSalarial', lLstObj[0].Account.SalaryRange__c);
                mapObj.put('sFaixaSalarial', 'Não possui');
                mapObj.put('sEscolaridade', 'Não informado');
                mapObj.put('sNomeDaMae', lLstObj[0].Account.MothersName__c == null ? '' : lLstObj[0].Account.MothersName__c);
                //mapObj.put('sOrigemCliente', lLstObj[0].Account.Origin__c);
                mapObj.put('sOrigemCliente', 'Novo Comprador');
                mapObj.put('sEmail', lLstObj[0].Account.Email__c == null ? '' : lLstObj[0].Account.Email__c);
                //mapObj.put('sDDD', String.isNotEmpty(lLstObj[0].Account.Phone) ? lLstObj[0].Account.Phone.substring(0, 2) : '');
                mapObj.put('sTelefoneFixo', lLstObj[0].Account.Phone == null ? '' : lLstObj[0].Account.Phone);
                //mapObj.put('sDDDCel', String.isNotEmpty(lLstObj[0].Account.CellPhone__c) ? lLstObj[0].Account.CellPhone__c.substring(0, 2) : '');
                mapObj.put('sCelular', lLstObj[0].Account.CellPhone__c);     
                mapObj.put('sMidia', lLstObj[0].Account.Media__c == null ? '' : lLstObj[0].Account.Media__c); 
                mapObj.put('sEstado', lLstObj[0].Account.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c);
                mapObj.put('sCidade', lLstObj[0].Account.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c);
                mapObj.put('sBairro', 'Bairro Teste');           
                mapObj.put('sTipoDocumento', lLstObj[0].Account.DocumentType__c);            
                
                if(lLstObj[0].Account.DocumentType__c.equals('CPF'))
                {
                    mapObj.put('sOrgaoExpedidor', 'NAO INF.');
                    mapObj.put('sRG', lLstObj[0].Account.RG__c == null ? '' : lLstObj[0].Account.RG__c);
                    mapObj.put('sCPF', lLstObj[0].Account.DocumentNumber__c);
                    String dt = Datetime.newInstance(lLstObj[0].Account.BirthDate__c, Time.newInstance(0,0,0,0)).format('dd-MM-yyyy');
                    dt = dt.replaceAll('-', '/');
                    mapObj.put('sDataNasc', dt);
                }
                else
                {
                    mapObj.put('sCNPJ', lLstObj[0].Account.DocumentNumber__c);
                    mapObj.put('sIE', lLstObj[0].Account.StateSubscription__c);
                }
                
                // Novos Dados Residencial
                mapObj.put('sTipoCobranca', lLstObj[0].Forma_de_Pagamento__c == null ? '' : lLstObj[0].Forma_de_Pagamento__c);
                mapObj.put('sFormaEnvio', lLstObj[0].TipoFatura__c == null ? '' : lLstObj[0].TipoFatura__c);    
                mapObj.put('sDiaVencimento', lLstObj[0].DiaVencimento__c == null ? '' : lLstObj[0].DiaVencimento__c);
                mapObj.put('sBanco', lLstObj[0].Banco__c == null ? '' : lLstObj[0].Banco__c);
                mapObj.put('sAgencia', lLstObj[0].Agencia__c == null ? '' : lLstObj[0].Agencia__c);
                mapObj.put('sDVAgencia', lLstObj[0].DvAgencia__c == null ? '' : lLstObj[0].DvAgencia__c);
                mapObj.put('sConta', lLstObj[0].NumeroConta__c == null ? '' : lLstObj[0].NumeroConta__c);
                mapObj.put('sDVConta', lLstObj[0].DvConta__c == null ? '' : lLstObj[0].DvConta__c);
                //mapObj.put('sOrgaoExpedidor', lLstObj[0].Account.RGEmitter__c);
                mapObj.put('sNovo', lLstObj[0].NovoEndereco__c);
                //cadastro endereço
                if(lLstObj[0].NovoEndereco__c == true)
                {
                    mapObj.put('sHP', lLstObj[0].NumeroHP__c);
                    mapObj.put('sNumEndereco', lLstObj[0].ShippingNumber__c );
                    mapObj.put('sLogradouro', lLstObj[0].BillingStreet);
                    mapObj.put('sCEP', lLstObj[0].BillingPostalCode);
                    mapObj.put('sTipoComplemento1', lLstObj[0].TipoComplemento1__c == null ? '' :lLstObj[0].TipoComplemento1__c);
                    mapObj.put('sValorComplemento1', lLstObj[0].Complemento1__c == null ? '' :lLstObj[0].Complemento1__c);
                    mapObj.put('sTipoComplemento2', lLstObj[0].TipoComplemento2__c == null ? '' :lLstObj[0].TipoComplemento2__c);
                    mapObj.put('sValorComplemento2', lLstObj[0].Complemento2__c == null ? '' :lLstObj[0].Complemento2__c);
                    mapObj.put('sTipoComplemento3', lLstObj[0].TipoComplemento3__c == null ? '' :lLstObj[0].TipoComplemento3__c);
                    mapObj.put('sValorComplemento3', lLstObj[0].Complemento3__c == null ? '' :lLstObj[0].Complemento3__c);
                    mapObj.put('sTipoComplemento4', lLstObj[0].TipoComplemento4__c == null ? '' :lLstObj[0].TipoComplemento4__c);
                    mapObj.put('sValorComplemento4', lLstObj[0].Complemento4__c == null ? '' : lLstObj[0].Complemento4__c); 
                }else
                {
                    mapObj.put('sHP', lLstObj[0].NumeroHP__c);
                }
                
                for(OrderItem od : lstOrderItem){
                    if(od.Product2.vlocity_cmt__type__c == 'Plano'){
                        if(od.Product2.Family != 'Movel'){
                            mapObj.put('sTipoProduto', lLstObj[0].Unidade__c);   
                            break;
                        }
                        mapObj.put('sTipoProduto', 'Móvel');                      
                    }    
                }           
                
            }else{return setError(outMap, 'O Pedido não foi encontrado');}
            
            if(!lstOrderItem.isEmpty()){
                mapObj.put('sTipoPlano', lstOrderItem[0].Product2.vlocity_cmt__SubType__c == 'Pós-Pago' ? 'Claro Conta' : 'Claro Controle');
                mapObj.put('sMSISDNPortabilidade', lstOrderItem[0].vlocity_cmt__SerialNumber__c != null ? lstOrderItem[0].DDD__c + lstOrderItem[0].vlocity_cmt__SerialNumber__c : '');  
                mapObj.put('bNumeroProvisorio', lstOrderItem[0].NumeroProvisorio__c);
                mapObj.put('sDDD', lstOrderItem[0].DDD__c != null ? lstOrderItem[0].DDD__c : '');    
            }else{return setError(outMap, 'O Pedido não contem produtos');}
            
            lLstObj[0].Status = 'Enviado ao Legado';
            update lLstObj;
            //system.debug('RoboParams: '+json.serializePretty(mapObj));
            outMap.put('objectToRobot',mapObj);
            return true;
            
        }
    }
    public static List<Map<String, Object>> getProducts (String groupValue, String familyValue) 
    {
        /* Specify DataRaptor extract or transform to call */
        String DRName = 'CEC_GetProductsWithPricingByFamily'; 
        Map<String, Object> myTransformData = new Map<String, Object>{'groupCode'=> groupValue,'family'=> familyValue};
            String dataJson = Json.serialize(myTransformData);
        
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, DRName); 
        
        List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>)result.toJsonList();
        //system.debug('myTransformResult: '+json.serializePretty(myTransformResult));
        return myTransformResult;
    }
    private static Boolean createNewHP(Map<String, Object> inputMap, Map<String, Object> outMap,
                                       Map<String, Object> options)
    {
        list<IBGE__c> lLstIBGE = getIbge(inputMap, outMap, options);
        if (lLstIBGE.isEmpty()) return setError(outMap, Label.CEC_CidadeNaoEncontrada);
        
        String lOperatorCode = String.valueOf(lLstIBGE[0].OperatorCode__c);
        lOperatorCode = '0'.repeat(3 - lOperatorCode.length()) + lOperatorCode;
        inputMap.put('operatorCode', lOperatorCode);
        
        User varUser = [SELECT Id, CEC_SalesAgent__c FROM User WHERE Id = :UserInfo.getUserId()];
        inputMap.put('user', varUser.CEC_SalesAgent__c);
        
        CEC_RestObjects.createHP createHP;
        createHP = CEC_IntegrationHPCreation.consultar(inputMap);
        if (createHP == null || createHP.data == null)
        {
            String lMessage = Label.CEC_SemResultados;
            String lErrorCode = '';
            if (createHP == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (createHP.error != null){
                createHP.error.detailedMessage = createHP.error.detailedMessage == 'NETSMSFacade: Erro ao executar solicitação de endereço: ENDERECO ja existente. - ENDERECO ja existente.' ?'Endereço já existente' : createHP.error.detailedMessage ;
               	lErrorCode = createHP.error.errorCode;
                outMap.put('errorCodeAPI', lErrorCode);
                lMessage = createHP.error.detailedMessage; 
            }
                return setError(outMap, lMessage);
        }
        outMap.put('propertyId', createHP.data.propertyId);
        return true;
    }

    private static Boolean createNewHPAnalysis(
            Map<String, Object> inputMap, 
            Map<String, Object> outMap,
            Map<String, Object> options) {
        
        User varUser = [SELECT  Id, Name, CompanyName, FederationIdentifier, Channel__c, SalesTeamNET__c 
                        FROM    User 
                        WHERE   Id = :UserInfo.getUserId()];
        inputMap.put('salesmanName', varUser.Name);
        inputMap.put('salesmanLogin', varUser.FederationIdentifier);
        inputMap.put('corporateName', varUser.CompanyName);
        inputMap.put('channelDescription', varUser.Channel__c);
        inputMap.put('teamDescription', varUser.SalesTeamNET__c);

        CEC_RestObjects.ResponseGen response;
        response = SOLAR_IntegrationHPCreationAnalysis.consultar(inputMap);
        
        if (response == null || response.error != null){
            String lMessage = Label.CEC_SemResultados;
            String lErrorCode = '';
            if (response == null) {
                return setError(outMap, Label.CEC_ServIndisponivel);
            }

            if (response.error != null){
                lErrorCode = response.error.errorCode;
                outMap.put('errorCodeAPI', lErrorCode);
                lMessage = response.error.detailedMessage; 
            }
            return setError(outMap, lMessage);
        }

        return true;
    }

    private static Boolean portabilitiesPreAnalysis(Map<String, Object> inputMap, Map<String, Object> outMap,
                                       Map<String, Object> options)
    {        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis response = CEC_IntegrationPortabilitiesPreAnalysis.consultar(String.valueOf(inputMap.get('number')));
        
        if (response == null || response.data == null || response.error !=null)
        {
            String lMessage = Label.CEC_SemResultados;
            
           
                PortabilitiesPreAnalysisDTO.TelephoneNumber telephoneNumber = new PortabilitiesPreAnalysisDTO.TelephoneNumber();
                telephoneNumber.number_Z = '11976967696';
                
                PortabilitiesPreAnalysisDTO.Tickets tickets = new PortabilitiesPreAnalysisDTO.Tickets();
                tickets.id = '';
                tickets.telephoneNumber = telephoneNumber;
                    
                PortabilitiesPreAnalysisDTO.Unavailables unavailables = new PortabilitiesPreAnalysisDTO.Unavailables();
                unavailables.detail = 'Erro: Serviço temporariamente indisponível ';
                unavailables.reasonId = 'NUMERO_NA_CLARO';
                unavailables.tickets = new list <PortabilitiesPreAnalysisDTO.Tickets>();
                
                unavailables.tickets.add(tickets);
                
                PortabilitiesPreAnalysisDTO.Vailables vailables = new PortabilitiesPreAnalysisDTO.Vailables();
                vailables.Unavailables = unavailables;
                
                PortabilitiesPreAnalysisDTO.PortabilityPre portabilityPre = new PortabilitiesPreAnalysisDTO.PortabilityPre();
                portabilityPre.portabilty = vailables;
                
                PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portErro = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis();
                portErro.data = portabilityPre;
                
                response = portErro;                

            outMap.put('Portabilities', response);
        }else{
            outMap.put('Portabilities', response);    
        }        
        
        return true;        
    }
    private static Boolean sendProposal(Map<String, Object> inputMap, Map<String, Object> outMap,
                                       Map<String, Object> options)
    {  
        Id lUserId = (Id)inputMap.get('userId');
        lUserId = (lUserId == null) ? UserInfo.getUserId() : lUserId;
        
	
        User lCurrUser = [select Id, FirstName, LastName, Channel__c, CEC_SalesAgent__c, CEC_Seller__c, FederationIdentifier,
                          CEC_Regional__c, CEC_PointSale__c, Claro__c, NetServicos__c, SalesTeamNET__c from User where Id = :lUserId];
        
        Order sObjOrder = [Select id, AccountId, NumeroHP__c, City__c, UF__c, CodigoOperadora__c,  ShippingStreet, ShippingCity, Status, 
                           ShippingState, ShippingPostalCode, ShippingCountry, ShippingNeighborhood__c, ShippingComplement__c,
                           ShippingNumber__c, CreatedDate, Agencia__c, Banco__c,NumPropostaNetSales__c, DiaVencimento__c, DvAgencia__c, DvConta__c, 
                           NumeroConta__c, Forma_de_Pagamento__c 
                           from Order 
                           where Id =: String.valueOf(inputMap.get('OrderId'))];
        
        
        inputMap.put('cidade', sObjOrder.City__c);
        inputMap.put('uf', sObjOrder.UF__c);
        
		Account sObjAccount = [SELECT Id, Name, DocumentNumber__c, BirthDate__c, RG__c, CellPhone__c, 
                       Phone, Email__c, MothersName__c, Gender__c, MaritalStatus__c 
                       from Account 
                       where id =: sObjOrder.AccountId]; 
        
        CEC_RestObjects.ProspectProposal objProspect = new CEC_RestObjects.ProspectProposal();
        
        objProspect.name           = sObjAccount.Name;
    	objProspect.cpf 		   = sObjAccount.DocumentNumber__c; 
    	objProspect.rg 			   = sObjAccount.RG__c; 
    	objProspect.mobileAreaCode = sObjAccount.CellPhone__c == null ? null : sObjAccount.CellPhone__c.substring(0,2); 
    	objProspect.mobileNumber   = sObjAccount.CellPhone__c == null ? null : sObjAccount.CellPhone__c.substring(2,11); 
    	objProspect.phoneAreaCode  = sObjAccount.Phone == null ? sObjAccount.CellPhone__c.substring(0,2) : sObjAccount.Phone.substring(0,2); 
    	objProspect.phoneNumber    = sObjAccount.Phone == null ? sObjAccount.CellPhone__c.substring(2,11): sObjAccount.Phone.substring(2,10); 
    	objProspect.email          = sObjAccount.Email__c; 
    	objProspect.motherName     = sObjAccount.MothersName__c; 
    	objProspect.gender 		   = 3; 
    	objProspect.maritalStatus  = 5;
		objProspect.birthday       = String.valueOf(sObjAccount.BirthDate__c);
            
		CEC_RestObjects.HpProposal objHP = new CEC_RestObjects.HpProposal();
		objHP.id = Integer.valueOf(sObjOrder.NumeroHP__c);
	
        Map<String,String> objBillingAddress = new Map<String,String>();
        objBillingAddress.put('neighborhood', sObjOrder.ShippingNeighborhood__c);
        objBillingAddress.put('postalCode',sObjOrder.ShippingPostalCode);
        objBillingAddress.put('street',sObjOrder.ShippingStreet);
        objBillingAddress.put('complements',sObjOrder.ShippingComplement__c);
        objBillingAddress.put('number',sObjOrder.ShippingNumber__c);
		
        Map<String,Object> objCharge = new Map<String,Object>();
        
        objCharge.put('type', sObjOrder.Forma_de_Pagamento__c == 'Boleto' || sObjOrder.Forma_de_Pagamento__c =='Cartão de crédito'  ? 'BOLETO':'DCC');
        objCharge.put('invoiceShippingEmail', sObjAccount.Email__c);
        objCharge.put('invoiceDay', sObjOrder.DiaVencimento__c);
        
        if(sObjOrder.Forma_de_Pagamento__c != 'Boleto' && sObjOrder.Forma_de_Pagamento__c != 'Cartão de crédito'){
        	
            CEC_RestObjects.BankAccountProposal objBank = new CEC_RestObjects.BankAccountProposal();
        	objBank.bank 	= Integer.valueOf(sObjOrder.Banco__c); 
    		objBank.agency 	= sObjOrder.Agencia__c; 
    		objBank.account = sObjOrder.NumeroConta__c; 
    		objBank.digit 	= sObjOrder.DvConta__c; 
	
        	objCharge.put('bankAccount',objBank);
        } 
        
        Map<String, Object> objOffer = new Map<String, Object>();
        objOffer.put('type','single');
        
        CEC_COM_OfferNetSales__mdt offerNetSales = [Select MasterLabel, Adhesion__c, AdhesionPeriod__c, PriceInvoice__c, PriceCard__c, ValidityDiscount__c from CEC_COM_OfferNetSales__mdt LIMIT 1];
        
        CEC_RestObjects.InternetProposal objInternet = new CEC_RestObjects.InternetProposal();
        objInternet.name  = offerNetSales.MasterLabel; //'FÁCIL DIGITAL';
        //objInternet.price = sObjOrder.Forma_de_Pagamento__c == 'Boleto' || sObjOrder.Forma_de_Pagamento__c == 'Cartão de crédito' ? 73.9: 69.9;
        objInternet.price = sObjOrder.Forma_de_Pagamento__c == 'Boleto' || sObjOrder.Forma_de_Pagamento__c == 'Cartão de crédito' ? offerNetSales.PriceInvoice__c : offerNetSales.PriceCard__c;
        
        CEC_RestObjects.AdhesionProposal objAdhesion = new CEC_RestObjects.AdhesionProposal();
        objAdhesion.price  = (Integer)offerNetSales.Adhesion__c; //60;
        objAdhesion.period = (Integer)offerNetSales.AdhesionPeriod__c;//1;
        
		CEC_RestObjects.DiscountProposal objDiscount = new CEC_RestObjects.DiscountProposal();
        objDiscount.validity = (Integer)offerNetSales.ValidityDiscount__c; //0;
        
        objInternet.adhesion = objAdhesion;
        objInternet.discount = objDiscount;
            
        CEC_RestObjects.ProductsProposal objProducts = new CEC_RestObjects.ProductsProposal();
        objProducts.paytv = objInternet; 
        
        objOffer.put('Products',objProducts);
        
        Map<String,String> objScheduling = new Map<String,String>();
        DateTime todayMinusOne = sObjOrder.CreatedDate - (1);
        objScheduling.put('date', todayMinusOne.format('yyyy-MM-dd\'T\'HH:mm:ss')+'Z');
        objScheduling.put('alternativeDate', todayMinusOne.format('yyyy-MM-dd\'T\'HH:mm:ss')+'Z');
                
        CEC_RestObjects.DataProposal objData = new CEC_RestObjects.DataProposal();
    	objData.prospect = objProspect ; 
    	objData.charge = objCharge; 
    	objData.scheduling = objScheduling; 
    	objData.offer = objOffer ; 
    	objData.hp = objHp ;
    	//objData.billingAddress = objBillingAddress ; 
    	objData.seller = lCurrUser.NetServicos__c != null ? lCurrUser.NetServicos__c : lCurrUser.FederationIdentifier;
    	objData.salesForceID = String.valueOf(inputMap.get('OrderId'));        
        
        CEC_RestObjects.ProposalData response = new CEC_RestObjects.ProposalData();
        
        response = CEC_IntegrationProposal.consultar(objData, sObjOrder.CodigoOperadora__c);

        if (response == null || response.data == null || response.error !=null)
        {
            String lMessage = Label.CEC_SemResultados;
            if (response == null) return setError(outMap, Label.CEC_ServIndisponivel);
            if (response.error != null){
                response.error.detailedMessage = Label.CEC_ServIndisponivel +' - '+ response.error.detailedMessage ;
                lMessage = response.error.detailedMessage; 
            }
                return setError(outMap, lMessage);
        }else{
            sObjOrder.Status = 'Enviado ao Legado';
            sObjOrder.NumPropostaNetSales__c = String.valueOf(response.data.Proposal.id);
    	    update sObjOrder;
        }                
        outMap.put('Proposal', response);
        return true;
    }
    private static Boolean getBillingCycles(Map<String, Object> inputMap, Map<String, Object> outMap,
                                       Map<String, Object> options)
    {
		outMap.put('BillingCycles',CEC_IntegrationBillingCycles.consultar());
        
        return true;
    }
}