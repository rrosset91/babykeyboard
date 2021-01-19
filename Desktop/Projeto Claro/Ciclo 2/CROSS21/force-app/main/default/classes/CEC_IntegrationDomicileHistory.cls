global class CEC_IntegrationDomicileHistory 
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'DomicileHistory', Method__c = 'GET',
                                                                Endpoint__c = 'callout:OAGDomicileHistory', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('DomicileHistory');
        param = (param != null) ? param : lParamAlt;
    }
    
    global static CEC_RestObjects.DomicileHeader consultar(list<String> aArgs)
    {
        String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
            String lBodyRes, lHttpRes = '-1';
        
        CEC_RestObjects.DomicileHeader lRes = new CEC_RestObjects.DomicileHeader();
        lRes = new CEC_RestObjects.DomicileHeader();
        
        try
        {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
            system.debug('EndPoint: '+req.getEndpoint());
            if (test.isRunningTest()) req.setEndpoint('https://test.domicile-history.com' + lArgList);
            HTTPResponse res = CEC_HttpReq.sendReq(req, null);
            lBodyRes = res.getBody();
            system.debug('lBodyRes: '+lBodyRes);
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":','"type":' => '"type_Z":' };
                for (String iJsonAttr: lMapResWord.keyset())
            {
                lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
            } 
            lHttpRes = String.valueOf(res.getStatusCode());
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.DomicileHeader.class);
            system.debug('body: '+Json.serializePretty(lObj));
            system.debug('status: '+res.getStatusCode());
            lRes = (CEC_RestObjects.DomicileHeader)lObj;
        }
        catch (Exception ex)
        {
            lRes = genResponseError(ex.getMessage(), lHttpRes);
        }
		system.debug('RESPONSE: '+JSON.serializePretty(lRes, true));
        return lRes;
    }
    
    private static CEC_RestObjects.DomicileHeader genResponseError(String aMsg, String aHttpCode)
    {
        system.debug(aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.DomicileHeader lRes = new CEC_RestObjects.DomicileHeader();
        lRes.error = lError;
        return lRes;
    }
    
    global static CEC_RestObjects.DomicileHeader generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    global static CEC_RestObjects.DomicileHeader generateMock(URL aURL, Integer aHttpCode)
    {
        CEC_RestObjects.DomicileHistory data = new CEC_RestObjects.DomicileHistory();
        data.city = 'São Paulo';
        data.id = '5438120';
        data.type_Z = '5438120';
        data.status = 'Aberta, Conectado';
        data.name = 'Maria do Carmo';
        data.telephoneNumber = '11978654567';
        data.installationAddress = 'Rua Verbo Divino, 1344 - APto 12';
        data.partyIdentificationType = 'CPF';
        data.partyIdentificationNumber = '12356789034';
     
        
        CEC_RestObjects.DomicileHeader integration = new CEC_RestObjects.DomicileHeader();
        integration.apiVersion = '1';
        integration.transactionId = '1';
        //integration.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : data;
        integration.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        return integration;
    }
}