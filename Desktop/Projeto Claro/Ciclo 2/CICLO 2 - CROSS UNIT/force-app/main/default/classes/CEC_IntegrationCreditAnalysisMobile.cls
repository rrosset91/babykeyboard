/*
* Autor: LBS
* Data: 17-jan-2019
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar analise de credito de um cliente no legado (movel)
*/
global without sharing class CEC_IntegrationCreditAnalysisMobile
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'CreditAnalysisMobile', Method__c = 'POST',
                                                                Endpoint__c = 'callout:OAGCreditAnalysisMobile', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('CreditAnalysisMobile');
        param = (param != null) ? param : lParamAlt;
    }
    
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp consultar(map<String, String> aMapArgs)
    {
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lErrNoParam = genResponseError('parametros nao especificados!', '-1');
        if (aMapArgs == null || aMapArgs.isEmpty()) return lErrNoParam;
        
        IntegrationCreditAnalysisMobileDTO.SalesUser lSalesUser = new IntegrationCreditAnalysisMobileDTO.SalesUser();
        lSalesUser.id = aMapArgs.get('userIdApp');
        
        IntegrationCreditAnalysisMobileDTO.SalesUser lSalesUser2 = new IntegrationCreditAnalysisMobileDTO.SalesUser();
        lSalesUser2.id = aMapArgs.get('regionalId');
        
        IntegrationCreditAnalysisMobileDTO.SalesUser lSalesUser3 = new IntegrationCreditAnalysisMobileDTO.SalesUser();
        lSalesUser3.id = aMapArgs.get('pointSaleId');
        
        IntegrationCreditAnalysisMobileDTO.Aplication lAplication =  new IntegrationCreditAnalysisMobileDTO.Aplication();
        lAplication.type = 'WEB';
        lAplication.id   = 'CEC';
        lAplication.user =  lSalesUser;
        
        IntegrationCreditAnalysisMobileDTO.Channel lChannel = new IntegrationCreditAnalysisMobileDTO.Channel();
        lChannel.id         = aMapArgs.get('channelId');
        lChannel.regional   = lSalesUser2;
        
        IntegrationCreditAnalysisMobileDTO.SalesAgent lSalesAgent = new IntegrationCreditAnalysisMobileDTO.SalesAgent();
        lSalesAgent.id      = aMapArgs.get('salesAgentId');
        lSalesAgent.Channel = lChannel;
        
        IntegrationCreditAnalysisMobileDTO.Seller lSeller = new IntegrationCreditAnalysisMobileDTO.Seller();
        lSeller.id         = aMapArgs.get('sellerId');
        lSeller.salesAgent = lSalesAgent;
        
        IntegrationCreditAnalysisMobileDTO.CredAddress lCredAddress = new IntegrationCreditAnalysisMobileDTO.CredAddress();
        lCredAddress.postalCode = aMapArgs.remove('DE_CEP');//'04836250';
        
        String lDocNr = aMapArgs.remove('DI_CPF_CNPJ'), lNome = aMapArgs.remove('DI_NOME');
        String lPersonType = (String.isNotBlank(lDocNr) && lDocNr.replaceAll('\\D', '').length() == 14) ? 'PJ' : 'PF';
        
        IntegrationCreditAnalysisMobileDTO.Client lClient = new IntegrationCreditAnalysisMobileDTO.Client();
        lClient.documentNumberCPF = lDocNr;
        lClient.name              = lNome;
        lClient.typePerson        = lPersonType;//aMapArgs.get('typePerson');
        lClient.dateOfBirth       = aMapArgs.get('dateOfBirthClient');
        lClient.motherName        = aMapArgs.get('DIG_NOME_MAE');
        lClient.gender            = aMapArgs.get('genderClient');
        lClient.address           =  lCredAddress;
        
        IntegrationCreditAnalysisMobileDTO.CredOrder lOrder = new IntegrationCreditAnalysisMobileDTO.CredOrder();
        lOrder.client    = lClient;
        lOrder.pointSale = lSalesUser3;
        lOrder.seller    =  lSeller;
        
        IntegrationCreditAnalysisMobileDTO.RelatedAssessment lRelatedAssessment = new IntegrationCreditAnalysisMobileDTO.RelatedAssessment();
        lRelatedAssessment.id   = null;
        lRelatedAssessment.type = null;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData lCredData = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData();
        lCredData.aplication        = lAplication;
        lCredData.order             = lOrder;
        lCredData.operation         = aMapArgs.get('operation');
        lCredData.type              = aMapArgs.get('type');
        lCredData.relatedAssessment = lRelatedAssessment;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileReq lCredAnalysis = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileReq();
        lCredAnalysis.data = lCredData;
        
        return consultar(lCredAnalysis);
    }
    
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp consultar(IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileReq aReq)
    {
        String lBodyRes, lHttpRes = '-1';
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lCreditoResp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp lRes = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp();
        
        try
        {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            if (test.isRunningTest()) req.setEndpoint('https://test.mobile-credit-analysis.com');
            HTTPResponse res = CEC_HttpReq.sendReq(req, aReq);
            system.debug(LoggingLevel.INFO, 'Cred Request =>' + JSON.serializePretty(aReq, true));

            lBodyRes = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
                '"date":' => '"dateZ":', '"report":' => '"reportZ":', '"limit":' => '"limitZ":' };
                    for (String iJsonAttr: lMapResWord.keyset())
                {
                    lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                }
            lHttpRes = String.valueOf(res.getStatusCode());
            Object lObj = JSON.deserialize(lBodyRes, IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp.class);
            
            lRes = (IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp)lObj;
            
            lCreditoResp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp(lRes);
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                lCreditoResp = genResponseError(ex.getMessage(), lHttpRes);
            }
        }
        if(!param.IsActive__c)
        {
            lCreditoResp = generateMock('https://www.teste.com.br', 200);
        }
        return lCreditoResp;
    }
    
    private static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp genResponseError(String aMsg, String aHttpCode)
    {
        system.debug('CEC_IntegrationCreditAnalysisMobile => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lRes = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        lRes.error = lError;
        return lRes;
    }
    
    global static IntegrationCreditAnalysisMobileDTO.CredAnalysisResp generateMock(String aURL, Integer aHttpCode)
    {
        return (new CEC_IntegrationCreditAnalysisMobile()).generateMock(new URL(aURL), aHttpCode);
    }
    global IntegrationCreditAnalysisMobileDTO.CredAnalysisResp generateMock(URL aURL, Integer aHttpCode)
    {
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData lCreditoData = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData();
        
        lCreditoData.resultDate           = '2009-01-12T12:10:30-03:00';
        lCreditoData.creditLimit          = '500.00';
        lCreditoData.result               = 'APROVADO';
        lCreditoData.reasonResult         = 'ID001';
        lCreditoData.reasonResultDescription  = 'Restrições de crédito encontradas';
        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp lCredito = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp();
        lCredito.apiVersion = '1';
        lCredito.transactionId = '12345';
        lCredito.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lCreditoData;
        lCredito.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lCreditoResp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp(lCredito);
        return lCreditoResp;
    }
    global IntegrationCreditAnalysisMobileDTO.CredAnalysisResp generateMock()
    {
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData lCreditoData = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData();

        lCreditoData.resultDate           = '2009-01-12T12:10:30-03:00';
        lCreditoData.creditLimit          = '500.00';
        lCreditoData.result               = 'APROVADO';
        lCreditoData.reasonResult         = 'ID001';
        lCreditoData.reasonResultDescription  = 'Restrições de crédito encontradas';

        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp lCredito = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp();
        lCredito.apiVersion = '1';
        lCredito.transactionId = '12345';
        lCredito.data = lCreditoData;

        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp lCreditoResp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp(lCredito);
        return lCreditoResp;
    }
}