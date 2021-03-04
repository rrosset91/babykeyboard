/*
* Autor: Henrique Almeida
* Data: 16-abr-2019
* Descrição: Classe responsável por realizar integração com o serviço de retorno de histórico de propostas
*/
global class CEC_IntegrationHistoryProposal 
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'HistoryProposal', Method__c = 'GET',
                                                                Endpoint__c = 'callout:OAGHistoryProposal', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('HistoryProposal');
        param = (param != null) ? param : lParamAlt;
    }
    global static CEC_RestObjects.HistoryHeader consultar(list<String> aArgs)
    {
        String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
            String lBodyRes, lHttpRes = '-1';
        
        CEC_RestObjects.HistoryHeader lRes = new CEC_RestObjects.HistoryHeader();
        lRes = new CEC_RestObjects.HistoryHeader();
        
        try
        {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
            if (test.isRunningTest()) req.setEndpoint('https://test.history-proposal.com' + lArgList);
            HTTPResponse res = CEC_HttpReq.sendReq(req, null);
            lBodyRes = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
                '"dateTime":' => '"dateTimeZ":'};
                    for (String iJsonAttr: lMapResWord.keyset())
                {
                    lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                }
            lHttpRes = String.valueOf(res.getStatusCode());
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.HistoryHeader.class);
            system.debug('lBodyRes: '+lBodyRes);
            lRes = (CEC_RestObjects.HistoryHeader)lObj;
            system.debug(Json.serializePretty(lRes));
            return lRes;
        } 
        catch (Exception ex)
        {
            lRes = genResponseError(ex.getMessage(), lHttpRes);
        }
        return lRes;
    }
    private static CEC_RestObjects.HistoryHeader genResponseError(String aMsg, String aHttpCode)
    {
        system.debug('CEC_IntegrationHistoryProposal => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.HistoryHeader lRes = new CEC_RestObjects.HistoryHeader();
        lRes.error = lError;
        return lRes;
    }
    global static CEC_RestObjects.HistoryHeader generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    global static CEC_RestObjects.HistoryHeader generateMock(URL aURL, Integer aHttpCode)
    {        
        CEC_RestObjects.HistoryChangesStatusProposal historyChangesStatusProposal = new CEC_RestObjects.HistoryChangesStatusProposal();
        historyChangesStatusProposal.idProposal = '1234';
        historyChangesStatusProposal.userName = 'Maria';
        historyChangesStatusProposal.salesman = 'João';
        historyChangesStatusProposal.status = 'Aberta';
        historyChangesStatusProposal.changeDate = '';
        historyChangesStatusProposal.changeTime = '';
        historyChangesStatusProposal.description = '2';
        historyChangesStatusProposal.userNewProposal ='N123456';
        
        CEC_RestObjects.HistoryChangesSalesman historyChangesSalesman = new CEC_RestObjects.HistoryChangesSalesman();
        historyChangesSalesman.userName = 'João';
        historyChangesSalesman.login = 'N123456';
        historyChangesSalesman.salesmanOldProposal = 'N123456';
        historyChangesSalesman.salesmanNew = '';
        historyChangesSalesman.changeDate = '';
        historyChangesSalesman.changeTime = '';
        
        CEC_RestObjects.HistoryChangesAddress historyChangesAddress = new CEC_RestObjects.HistoryChangesAddress();
        historyChangesAddress.idProposal = '1234';
        historyChangesAddress.userName = 'Maria';
        historyChangesAddress.login = 'N123456';
        historyChangesAddress.salesman = 'João';
        historyChangesAddress.changeDate = '';
        historyChangesAddress.changeTime = '';
        historyChangesAddress.description = '';
        
        CEC_RestObjects.HistoryProtocol historyProtocol = new CEC_RestObjects.HistoryProtocol();
        historyProtocol.protocolNumber = '1234';
        historyProtocol.dateTimeZ = '';
        
        CEC_RestObjects.HistoryProposal data = new CEC_RestObjects.HistoryProposal();
        data.historyChangesStatusProposal = new List<CEC_RestObjects.HistoryChangesStatusProposal>{historyChangesStatusProposal};
        data.historyChangesSalesman = new List<CEC_RestObjects.HistoryChangesSalesman>{historyChangesSalesman};
        data.historyChangesAddress = new List<CEC_RestObjects.HistoryChangesAddress>{historyChangesAddress};
        data.historyProtocol = null;
        
        CEC_RestObjects.HistoryHeader integration = new CEC_RestObjects.HistoryHeader();        
       //integration.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : data;
       // integration.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        
        return integration;
    }
}