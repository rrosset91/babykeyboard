global class CEC_IntegrationHPCreation 
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'CreateHP', Method__c = 'GET',
                                                                Endpoint__c = 'callout:CreateHP', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('CreateHP');
        param = (param != null) ? param : lParamAlt; 
    }
    
    global static CEC_RestObjects.createHP consultar(map<String, Object> hpMap)
    {
        CEC_RestObjects.createHP newHP = new CEC_RestObjects.createHP();
        CEC_RestObjects.DataHP newHpData = new CEC_RestObjects.DataHP();
        List<CEC_RestObjects.ComplementarySubAddress> complementarySubAddress = new List<CEC_RestObjects.ComplementarySubAddress>();

        for(Integer i=0; i<4; i++)
        {
            complementarySubAddress.add(new CEC_RestObjects.ComplementarySubAddress());
        }
        
        system.debug('hpMap: '+json.serializePretty(hpMap));
        for (String attribute : hpMap.keySet())
        {
            if(attribute.equalsIgnoreCase('operatorCode'))
            {
                newHpData.operatorCode = (String)hpMap.get('operatorCode');
            }
            else if(attribute.equalsIgnoreCase('user'))
            {
                newHpData.user = (String)hpMap.get('user');
            }
            else if(attribute.equalsIgnoreCase('neighborhoodId'))
            {
                newHpData.neighborhoodId = (String)hpMap.get('neighborhoodId');
            }
            else if(attribute.equalsIgnoreCase('streetId'))
            {
                newHpData.streetId = (String)hpMap.get('streetId');
            }
            else if(attribute.equalsIgnoreCase('streetNr'))
            {
                newHpData.streetNr = (String)hpMap.get('streetNr');
            }
            else if(attribute.equalsIgnoreCase('cityId'))
            {
                newHpData.cityId = (String)hpMap.get('cityId');
            }
            else if(attribute.equalsIgnoreCase('buildingType'))
            {
                newHpData.buildingType = (String)hpMap.get('buildingType');
            }
            else if(attribute.equalsIgnoreCase('buildingId'))
            {
                newHpData.buildingId = (String)hpMap.get('buildingId');
            }
            if(attribute.equalsIgnoreCase('name1'))
            {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description1') != null ? (String)hpMap.get('description1') : '' ;
                newComplement.name = (String)hpMap.get('name1') != null ? (String)hpMap.get('name1') : '';
                if(newComplement.name != '' && newComplement.description != '')
                {
                    complementarySubAddress.set(0,newComplement);
                }
            }
            else if(attribute.equalsIgnoreCase('name2'))
            {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description2') != null ? (String)hpMap.get('description2') : '' ;
                newComplement.name = (String)hpMap.get('name2') != null ? (String)hpMap.get('name2') : '';
                if(newComplement.name != '' && newComplement.description != '')
                {
                    complementarySubAddress.set(1,newComplement);
                }
            }
            else if(attribute.equalsIgnoreCase('name3'))
            {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description3') != null ? (String)hpMap.get('description3') : '' ;
                newComplement.name = (String)hpMap.get('name3') != null ? (String)hpMap.get('name3') : '';
                if(newComplement.name != '' && newComplement.description != '')
                {
                    complementarySubAddress.set(2,newComplement);
                }
            }
            else if(attribute.equalsIgnoreCase('name4'))
            {
                system.debug('name4');
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description4') != null ? (String)hpMap.get('description4') : '' ;
                newComplement.name = (String)hpMap.get('name4') != null ? (String)hpMap.get('name4') : '';
                if(newComplement.name != '' && newComplement.description != '')
                {
                    complementarySubAddress.set(3, newComplement);
                }
            }
            newHpData.complementarySubAddress = complementarySubAddress;
        }
        newHP.data = newHpData;
        return consultar(newHP);
    }
    global static CEC_RestObjects.createHP consultar(CEC_RestObjects.createHP aReq)
    {
        String lBodyRes, lHttpRes = '-1';
        
        CEC_RestObjects.createHP lReq = aReq;
        CEC_RestObjects.createHP lRes;
        try
        {
            system.debug(LoggingLevel.INFO, 'HP Creation Request =>' + JSON.serializePretty(aReq, true));
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            system.debug(LoggingLevel.INFO, 'Endpoint: ' + req.getEndpoint());
            if (test.isRunningTest()) req.setEndpoint('https://test.createHP.com');
            HTTPResponse res = CEC_HttpReq.sendReq(req, aReq);
            lBodyRes = res.getBody();
            lHttpRes = String.valueOf(res.getStatusCode());
            system.debug(LoggingLevel.INFO, 'Response Body: ' + lBodyRes);
            system.debug(LoggingLevel.INFO, 'Status Code: ' + lHttpRes);
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.createHP.class);
            lRes = (CEC_RestObjects.createHP)lObj;
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                lRes = genResponseError(lRes.error.detailedMessage, lHttpRes, lRes.error.errorCode);
            }
        }
        if(!param.IsActive__c)
        {
            lRes = generateMock('https://www.teste.com.br', 200);
        }
        return lRes;
    }
    private static CEC_RestObjects.createHP genResponseError(String aMsg, String aHttpCode, String aErrorCode)
    {
        system.debug('CEC_IntegrationHPCreation' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        lError.errorCode = aErrorCode;
        
        CEC_RestObjects.createHP lRes = new CEC_RestObjects.createHP();
        lRes.error = lError;
        return lRes;
    }
    
    global static CEC_RestObjects.createHP generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    global static CEC_RestObjects.createHP generateMock(URL aURL, Integer aHttpCode)
    {
        CEC_RestObjects.DataHP data = new CEC_RestObjects.DataHP();
        data.propertyId = '12345678'; 
        
        CEC_RestObjects.createHP HP = new CEC_RestObjects.createHP();
        HP.apiVersion = '1';
        HP.transactionId = '1';
        HP.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : data;
        
        return HP;
    }
}