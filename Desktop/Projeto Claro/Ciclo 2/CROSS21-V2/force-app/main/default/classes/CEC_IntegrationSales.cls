global without sharing class CEC_IntegrationSales {
    global static ServiceParameter__c param;
    
    static {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'ProspectResidencial', Method__c = 'GET',
                Endpoint__c = 'callout:OAGProspectResidencial', User__c = null, Password__c = null, Timeout__c = 10000,
                IsActive__c = true);
        param = ServiceParameter__c.getInstance('SalesMan');
        param = (param != null) ? param : lParamAlt;
    }
   
    global static SalesManDTO.SalesMan consultar(String aDocument) {
        list<String> lLstArg = new list<String>();
        lLstArg.add('userId=' + aDocument);
        return consultar(lLstArg);
    }

    global static SalesManDTO.SalesMan consultar(list<String> aArgs) {
        String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
        String lBodyRes, lHttpRes = '-1';

        SalesManDTO.SalesMan lRes = new SalesManDTO.SalesMan();
        lRes.data = new SalesManDTO.SalesManData();

        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
            if (test.isRunningTest()) req.setEndpoint('https://test.prospect-resid.com' + lArgList);
            HTTPResponse res = CEC_HttpReq.sendReq(req, null);
            lBodyRes = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{
                    '" :' => '":', '"number":' => '"numberZ":'
            };
            for (String iJsonAttr : lMapResWord.keyset()) {
                lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
            }
            lHttpRes = String.valueOf(res.getStatusCode());
            Object lObj = JSON.deserialize(lBodyRes, SalesManDTO.SalesMan.class);
            lRes = (SalesManDTO.SalesMan) lObj;
        } catch (Exception ex) {
            if (param.IsActive__c) {
                lRes = genResponseError(ex.getMessage(), lHttpRes);
            }
        }
        if (!param.IsActive__c) {
            lRes = generateMock('https://www.teste.com.br', 200);
        }
        system.debug(lRes);
        return lRes;
    }
    private static SalesManDTO.SalesMan genResponseError(String aMsg, String aHttpCode) {
        system.debug('CEC_IntegrationSalesMan => ' + aMsg);
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;

        SalesManDTO.SalesMan lRes = new SalesManDTO.SalesMan();
        lRes.error = lError;
        return lRes;
    }

    global static SalesManDTO.SalesMan generateMock(String aURL, Integer aHttpCode) {
        return (new CEC_IntegrationSales()).generateMock(new URL(aURL), aHttpCode);
    }
    
    global SalesManDTO.SalesMan generateMock(URL aURL, Integer aHttpCode) {
        SalesManDTO.Partyidentification identification = new SalesManDTO.Partyidentification();
        identification.numberZ = '2';
        identification.type = '23';

        SalesManDTO.Address address = new SalesManDTO.Address();
        address.boxNr = '2';
        address.city = 'SP';
        address.neighborhood = 'Morumbi';
        address.placeId = '4341';
        address.postalCode = '06783-342';
        address.streetName = 'Rua Henri Dunant';
        address.streetNumber = '800';
        address.streetType = 'Rua';
        address.type = 'normal';
        address.urbanPropertySubAddress = 'teste';

        SalesManDTO.SalesManAgent salesAgent = new SalesManDTO.SalesManAgent();
        salesAgent.channelId = 'LOJA_PROPRIA';
        salesAgent.pointSale = new List<SalesManDTO.PointSale>();
        salesAgent.regionalId = 'CLARO_SP1';
        salesAgent.iwTypeId = '1234';
        salesAgent.description = 'Teste de verdade';
        salesAgent.businessName = 'Claro';
        salesAgent.iwRegionalId = 'CLARO_SP1';
        salesAgent.iwSalesAgentId = '65632';
        salesAgent.address = address;

        SalesManDTO.ContactSalesMan contact = new SalesManDTO.ContactSalesMan();
        contact.emailAddress = 'teste@deloitte.com';
        contact.telephoneNumber = '5186-6000';
        contact.telephoneNumbertype = 'FIXO';

        SalesManDTO.Salesmen salesman = new SalesManDTO.Salesmen();
        salesman.id = 'XXXXX';
        salesman.name = 'TESTE1';
        salesman.registration = 'TESTE1';
        salesman.situation = 'TESTE1';
        salesman.situationDate = 'teste';
        salesman.salesAgent = salesAgent;
        salesman.partyidentification = identification;
        salesman.contact = new List<SalesManDTO.ContactSalesMan>();
        salesman.contact.add(contact);

        SalesManDTO.SalesManData data = new SalesManDTO.SalesManData();
        data.salesman = salesman;

        SalesManDTO.SalesMan integration = new SalesManDTO.SalesMan();
        integration.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : data;

        return integration;
    }

    global SalesManDTO.SalesMan generateMock() {
        SalesManDTO.Partyidentification identification = new SalesManDTO.Partyidentification();
        identification.numberZ = '2';
        identification.type = '23';

        SalesManDTO.Address address = new SalesManDTO.Address();
        address.boxNr = '2';
        address.city = 'SP';
        address.neighborhood = 'Morumbi';
        address.placeId = '4341';
        address.postalCode = '06783-342';
        address.streetName = 'Rua Henri Dunant';
        address.streetNumber = '800';
        address.streetType = 'Rua';
        address.type = 'normal';
        address.urbanPropertySubAddress = 'teste';

        SalesManDTO.SalesManAgent salesAgent = new SalesManDTO.SalesManAgent();
        salesAgent.channelId = 'LOJA_PROPRIA';
        salesAgent.pointSale = new List<SalesManDTO.PointSale>();
        salesAgent.regionalId = 'CLARO_SP1';
        salesAgent.iwTypeId = '1234';
        salesAgent.description = 'Teste de verdade';
        salesAgent.businessName = 'Claro';
        salesAgent.iwRegionalId = 'CLARO_SP1';
        salesAgent.iwSalesAgentId = '65632';
        salesAgent.address = address;

        SalesManDTO.ContactSalesMan contact = new SalesManDTO.ContactSalesMan();
        contact.emailAddress = 'teste@deloitte.com';
        contact.telephoneNumber = '5186-6000';
        contact.telephoneNumbertype = 'FIXO';

        SalesManDTO.Salesmen salesman = new SalesManDTO.Salesmen();
        salesman.id = 'XXXXX';
        salesman.name = 'TESTE1';
        salesman.registration = 'TESTE1';
        salesman.situation = 'TESTE1';
        salesman.situationDate = 'teste';
        salesman.salesAgent = salesAgent;
        salesman.partyidentification = identification;
        salesman.contact = new List<SalesManDTO.ContactSalesMan>();
        salesman.contact.add(contact);

        SalesManDTO.SalesManData data = new SalesManDTO.SalesManData();
        data.salesman = salesman;

        SalesManDTO.SalesMan integration = new SalesManDTO.SalesMan();
        integration.data =  data;

        return integration;
    }
}