/*
* Autor: Henrique Almeida
* Data: 15-abr-2019
* Descrição: Classe responsável por realizar integração com o serviço de dados do vendedor da residencial.
*/

global class CEC_IntegrationSalesResidencial 
{
    global static ServiceParameter__c param;
    static
    {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'VendedorResidencial', Method__c = 'GET',
                                                                Endpoint__c = 'callout:OAGVendedorResidencial', User__c = null, Password__c = null, Timeout__c = 10000,
                                                                IsActive__c = true);
        param = ServiceParameter__c.getInstance('VendedorResidencial');
        param = (param != null) ? param : lParamAlt;
    }
    global static CEC_RestObjects.SalesManRes consultar(list<String> aArgs)
    {
        String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
            String lBodyRes, lHttpRes = '-1';
        
        CEC_RestObjects.SalesManRes lRes = new CEC_RestObjects.SalesManRes();
        lRes = new CEC_RestObjects.SalesManRes();  
        
        try
        {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
system.debug(req.getEndpoint());            
            if (test.isRunningTest()) req.setEndpoint('https://test.vendedor-residencial.com' + lArgList);
            HTTPResponse res = CEC_HttpReq.sendReq(req, null);
            lBodyRes = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
                '"number":' => '"numberZ":'};
      for (String iJsonAttr: lMapResWord.keyset())
      {
        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
      }
            lHttpRes = String.valueOf(res.getStatusCode());
            system.debug('lBodyRes: '+lBodyRes);

            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.SalesManRes.class); 
            lRes = (CEC_RestObjects.SalesManRes)lObj;
            system.debug('lRes: '+JSON.serializePretty(lRes, true));
            return lRes;
        }
        catch (Exception ex)
        {
            lRes = genResponseError(ex.getMessage(), lHttpRes);
        }
        return lRes;
    }
    private static CEC_RestObjects.SalesManRes genResponseError(String aMsg, String aHttpCode)
    {
        system.debug('CEC_IntegrationSalesManResidential => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.SalesManRes lRes = new CEC_RestObjects.SalesManRes();
        lRes.error = lError;
        return lRes;
    }
    
    global static CEC_RestObjects.SalesManRes generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    global static CEC_RestObjects.SalesManRes generateMock(URL aURL, Integer aHttpCode)
    {        
        CEC_RestObjects.Partyidentification identification = new CEC_RestObjects.Partyidentification();
        identification.numberZ = '60160063434';
        identification.type = 'CPF';
        
        CEC_RestObjects.SalesTeam salesTeam = new CEC_RestObjects.SalesTeam();
        salesTeam.id = '17393';
        salesTeam.description = 'RECEP FLEX - T0131615';
        
        CEC_RestObjects.SalesChannel channel = new CEC_RestObjects.SalesChannel();
        channel.id = '1234';
        channel.description = 'TLV NACIONAL - RECEPTIVO';
        channel.salesTeam = new List<CEC_RestObjects.SalesTeam>();
        channel.salesTeam.add(salesTeam);
        
        CEC_RestObjects.Company company = new CEC_RestObjects.Company();
        company.id = '1234';
        company.corporateName = 'CSU';
        company.salesChannel = new List<CEC_RestObjects.SalesChannel>();
        company.salesChannel.add(channel);
        
        List<CEC_RestObjects.company> lstCompany = new List<CEC_RestObjects.company>();
        //salesman.company = new List<CEC_RestObjects.Company>();
        lstCompany.add(company);        
        
        CEC_RestObjects.SalesmanResidential salesman = new CEC_RestObjects.SalesmanResidential();
        salesman.id = '1234';
        salesman.login = 'T1037793';
        salesman.name = 'José da Silva';
        salesman.partyidentification = identification;
        
        CEC_RestObjects.ResData data = new CEC_RestObjects.ResData();
        data.salesman = salesman;
        data.company = lstCompany;
        
        CEC_RestObjects.SalesManRes integration = new CEC_RestObjects.SalesManRes();        
        integration.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : data;
        integration.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;
        
        
        return integration;
    }
}