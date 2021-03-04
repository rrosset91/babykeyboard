/*
* Autor: RLdO
* Data: 11-dez-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar analise de credito de um cliente no legado (residencial)
*/
global without sharing class CEC_IntegrationCreditAnalysis
{
    // valor para campos nao preenchidos
    private static final String NULL_VALUE = null;//'';
    // lista de campos para analise de credito residencial ordenados pelo indice do legado (1..n)
    private static final list<String> LIST_FIELD_IDS = new list<String>{
        'DI_CPF_CNPJ', 'DI_NOME', 'DI_EMAIL', 'DI_NETFONE', 'DI_ORIGEM', 'DI_RG', 'DI_TELEFONE_CELULAR',
            'DI_TELEFONE_COMERCIAL', 'DI_TELEFONE_OUTROS', 'DI_TELEFONE_PRINCIPAL', 'DI_TELEFONE_RESIDENCIAL',
            'DE_CIDADE_OPERADORA', 'DE_LOGRADOURO', 'DE_NUMERO', 'DE_COMPLEMENTO', 'DE_BAIRRO',
            'DE_CEP', 'DE_HP', 'DE_NODE', 'DA_DATA_NASCIMENTO', 'DA_ESTRANGEIRO', 'DA_TIPO_PESSOA',
            'DC_CODIGO_EMBRATEL', 'DC_DATA_INSTALACAO', 'DC_DATA_VENDA', 'DC_NIVEL_RELACIONAMENTO',
            'DC_NUMERO_CONTRATO', 'DC_PACOTE_SERVICO', 'DC_PLANO_PRINCIPAL', 'DC_STATUS',
            'DC_TIPO_ASSINANTE', 'DC_TIPO_CONTRATO', 'DV_ATENDENTE', 'DV_EQUIPE_VENDA',
            'DV_VENDEDOR', 'DP_NUMERO_PROPOSTA', 'DP_SISTEMA_SINAL', 'DP_TIPO_ASSINANTE',
            'DP_TIPO_CONTRATO', 'DCB_CARTAO_CREDITO_NUMERO', 'DCB_CARTAO_CREDITO_OPERADORA',
            'DCB_CARTAO_CREDITO_TITULAR', 'DCB_CARTAO_CREDITO_VALIDADE', 'DCB_DCC_BANCO',
            'DCB_DCC_DV_AGENCIA', 'DCB_DCC_DV_CONTA_CORRENTE', 'DCB_DCC_NUMERO_AGENCIA',
            'DCB_DCC_NUMERO_CONTA_CORRENTE', 'DCB_DIA_VENCIMENTO', 'DCB_FORMA_PAGAMENTO',
            'DCB_POSICAO_FINANCEIRA', 'DCB_EXCLIENTE', 'DCB_TIPO_COBRANCA', 'DCB_TIPO_COBRANCA_ATUAL',
            'DDCC_CPF_CNPJ', 'DDCC_NOME_TITULAR', 'DEC_CEP', 'DEC_CIDADE', 'DEC_ESTADO',
            'DSP_PERFIL_CLIENTE', 'DSP_PRECO_ADESAO', 'DSP_PRECO_MENSAL', 'DSP_PRODUTO',
            'DSP_PARCEIRO', 'DSP_PROMOCAO', 'DSP_TECNOLOGIA', 'DIG_EMAIL', 'DIG_NOME_MAE',
            'DIG_TELEFONE_OUTROS', 'DIG_TELEFONE_CELULAR', 'DIG_TELEFONE_COMERCIAL',
            'DIG_TELEFONE_FAX', 'DIG_TELEFONE_RESIDENCIAL', 'DPORT_OPERADORA'
            };
                global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'CreditAnalysis', Method__c = 'POST',
                                                                Endpoint__c = 'callout:OAGCreditAnalysis', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('CreditAnalysis');
        param = (param != null) ? param : lParamAlt;
    }
    
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp consultar(map<String, String> aMapArgs)
    {
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lErrNoParam = genResponseError('parametros nao especificados!', '-1');
        if (aMapArgs == null || aMapArgs.isEmpty()) return lErrNoParam;
        
        String lOperatorCode = aMapArgs.remove('COD_OPERADORA');
        
        map<String, IntegrationCreditAnalysisMobileDTO.CredAnalysisItens> lAllItems = new map<String, IntegrationCreditAnalysisMobileDTO.CredAnalysisItens>();
        
        set<String> lSetCamposChave = new set<String>{ 'DI_CPF_CNPJ', 'DI_NOME', 'DI_ORIGEM',
            'DA_DATA_NASCIMENTO', 'DCB_POSICAO_FINANCEIRA', 'DCB_EXCLIENTE', 'DSP_PARCEIRO' };
                for (Integer i = 0; i < LIST_FIELD_IDS.size(); i++)
            {
                String iArg = LIST_FIELD_IDS[i];
                String lFieldVal = aMapArgs.get(iArg);
                
                IntegrationCreditAnalysisMobileDTO.CredAnalysisItem lItem = new IntegrationCreditAnalysisMobileDTO.CredAnalysisItem();
                lItem.fieldId = String.valueOf(i + 1);
                lItem.fieldName = iArg;
                lItem.value = (String.isBlank(lFieldVal)) ? NULL_VALUE : lFieldVal;
                lItem.key = String.valueOf(lSetCamposChave.contains(iArg));
                
                IntegrationCreditAnalysisMobileDTO.CredAnalysisItens lItens = new IntegrationCreditAnalysisMobileDTO.CredAnalysisItens();
                lItens.item = lItem;
                
                lAllItems.put(iArg, lItens);
            }
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisData lData = new IntegrationCreditAnalysisMobileDTO.CredAnalysisData();
        lData.operatorCode = lOperatorCode;
        lData.itens = lAllItems.values();
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisReq lCredAnalysis = new IntegrationCreditAnalysisMobileDTO.CredAnalysisReq();
        lCredAnalysis.data = lData;
        
        return (lAllItems.isEmpty()) ? lErrNoParam : consultar(lCredAnalysis);
    }
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp consultar(IntegrationCreditAnalysisMobileDTO.CredAnalysisReq aReq)
    {
        String lBodyRes, lHttpRes = '-1';
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lRes = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        
        try
        {
            system.debug(LoggingLevel.ERROR, 'Cred Request =>' + JSON.serializePretty(aReq, true));
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            if (test.isRunningTest()) req.setEndpoint('https://test.resid-credit-analysis.com');
            HTTPResponse res = CEC_HttpReq.sendReq(req, aReq);
            lBodyRes = res.getBody();
            system.debug(LoggingLevel.ERROR, 'Cred Response =>\n' + lBodyRes);
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
                '"date":' => '"resultDate":', '"report":' => '"reportZ":', '"limit":' => '"creditLimit":' };
                    for (String iJsonAttr: lMapResWord.keyset())
                {
                    lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                }
            lHttpRes = String.valueOf(res.getStatusCode());
            Object lObj = JSON.deserialize(lBodyRes, IntegrationCreditAnalysisMobileDTO.CredAnalysisResp.class);
            lRes = (IntegrationCreditAnalysisMobileDTO.CredAnalysisResp)lObj;
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                lRes = genResponseError(ex.getMessage(), lHttpRes);
            }
        }
        lRes.formatMsg(false);
        if(!param.IsActive__c)
        {
            lRes = generateMock('https://www.teste.com.br', 200);
        }
        
        return lRes;
    }
    
    private static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp genResponseError(String aMsg, String aHttpCode)
    {
        system.debug('CEC_IntegrationCreditAnalysis => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lRes = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        lRes.error = lError;
        return lRes;
    }
    
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp generateMock(URL aURL, Integer aHttpCode)
    {
        IntegrationCreditAnalysisMobileDTO.CreditMessage lCredMessage = new IntegrationCreditAnalysisMobileDTO.CreditMessage();
        lCredMessage.identifier = '0';
        lCredMessage.note = 'APROVADO - CONFORME POLITICA DE CREDITO EM VIGOR   LIMITE SUGERIDO: R$ 1000,00';
        
        IntegrationCreditAnalysisMobileDTO.CreditSituation lCredSit = new IntegrationCreditAnalysisMobileDTO.CreditSituation();
        lCredSit.status = 'APROVADO';
        lCredSit.resultDate = '';
        lCredSit.policy = 'PF_SCORE_ALC_C2';
        lCredSit.reportZ = '';
        lCredSit.typeDecision = '';
        lCredSit.creditLimit = '1000.0';
        lCredSit.dataPolicy = '';
        lCredSit.messages = new list<IntegrationCreditAnalysisMobileDTO.CreditMessage>{ lCredMessage };
            
            IntegrationCreditAnalysisMobileDTO.CredAnalysisRespData lCredData = new IntegrationCreditAnalysisMobileDTO.CredAnalysisRespData();
        lCredData.creditSituation = lCredSit;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lCredito = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        lCredito.apiVersion = '1';
        lCredito.transactionId = '1';
        lCredito.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lCredData;
        lCredito.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        return lCredito;
    }
}