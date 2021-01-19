global class CEC_IntegrationAddressCity 
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'AddressesCity', Method__c = 'GET',
                                                                Endpoint__c = 'callout:AddressesCity', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('AddressesCity');
        param = (param != null) ? param : lParamAlt; 
    }
    
    global static CEC_RestObjects.AddressesHeader consultar(list<String> aArgs)
    {
        String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
            String lBodyRes, lHttpRes = '-1';
        
        CEC_RestObjects.AddressesHeader lRes = new CEC_RestObjects.AddressesHeader();
        
        try 
        {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
            if (test.isRunningTest()) req.setEndpoint('https://test.addresses-city.com' + lArgList);
            HTTPResponse res = CEC_HttpReq.sendReq(req, null);
            lBodyRes = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":', '"number":' => '"numberZ":' };
                    for (String iJsonAttr: lMapResWord.keyset())
                {
                    lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                }
            lHttpRes = String.valueOf(res.getStatusCode());
            system.debug('endPoint: '+req.getEndpoint());
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.AddressesHeader.class);
            lRes = (CEC_RestObjects.AddressesHeader)lObj;
        }
        catch (Exception ex)
        {
            lRes = genResponseError(ex.getMessage(), lHttpRes);
        }
        system.debug('lRes: '+lRes);
        return lRes;
    }
    
    private static CEC_RestObjects.AddressesHeader genResponseError(String aMsg, String aHttpCode)
    {
        system.debug('CEC_IntegrationAddresses => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.AddressesHeader lRes = new CEC_RestObjects.AddressesHeader();
        lRes.error = lError;
        return lRes;
    }
    global static CEC_RestObjects.AddressesHeader generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
        global static CEC_RestObjects.AddressesHeader generateMock(URL aURL, Integer aHttpCode)
    {
		
        CEC_RestObjects.Addresses address = new CEC_RestObjects.Addresses();
        address.addressType = 'LOCALIDADE';
        address.prefix = 'RUA';
        address.logradouro = 'PALMEIRAS'; 
        address.numberZ = 123;
        address.addressComplement = 'APTO 13'; 
        address.neighborhood = 'HORTOLÂNDIA';
        address.mailbox = 12345678; 
        address.city = 'SAO PAULO'; 
        address.state = 'SP'; 
        address.zipCode = 12345678; 
        address.ibgeCityId = 3550308; 
        address.IbgeUfId = 35; 
        address.ddd = 11;  
        address.ruralAreaIndicator = 'true';  
        
        
        List<CEC_RestObjects.Addresses> lGedAddr = new List<CEC_RestObjects.Addresses>();
        lGedAddr.add(address);
            
        CEC_RestObjects.AddressData lGedAddrData = new CEC_RestObjects.AddressData();
        lGedAddrData.address = lGedAddr;
        
        CEC_RestObjects.AddressesHeader lAddr = new CEC_RestObjects.AddressesHeader();
        lAddr.apiVersion = '1';
        lAddr.transactionId = '1';
        lAddr.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lGedAddrData;
        lAddr.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        return lAddr;
    }
}