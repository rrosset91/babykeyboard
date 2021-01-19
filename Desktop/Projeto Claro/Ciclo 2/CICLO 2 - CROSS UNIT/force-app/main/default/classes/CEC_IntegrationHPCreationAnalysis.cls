global class CEC_IntegrationHPCreationAnalysis {
    global static ServiceParameter__c param;
    static {
        ServiceParameter__c lParamAlt = new ServiceParameter__c(
            Name = 'CreateHPAnalysis', Method__c = 'POST',
            Endpoint__c = 'callout:APIClaroResidential', User__c = null, Password__c = null, 
            Timeout__c = 40000, IsActive__c = true);

        param = ServiceParameter__c.getInstance('CreateHPAnalysis');
        param = (param != null) ? param : lParamAlt; 
    }
    
    global static CEC_RestObjects.ResponseGen consultar(map<String, Object> hpMap){

        CEC_RestObjects.CreateHPAnalysis requestHP = new CEC_RestObjects.CreateHPAnalysis();
        CEC_RestObjects.DataHPAnalysis data = new CEC_RestObjects.DataHPAnalysis();
        CEC_RestObjects.DataHPAnalysisProperties properties = new CEC_RestObjects.DataHPAnalysisProperties();
        CEC_RestObjects.PropertiesAddress address = new CEC_RestObjects.PropertiesAddress();
        CEC_RestObjects.DataHPAnalysisClient client = new CEC_RestObjects.DataHPAnalysisClient();
        CEC_RestObjects.ClientContact contact = new CEC_RestObjects.ClientContact();
        CEC_RestObjects.DataHPAnalysisSalesman salesman = new CEC_RestObjects.DataHPAnalysisSalesman();
        CEC_RestObjects.SalesmanCompany company = new CEC_RestObjects.SalesmanCompany();
        CEC_RestObjects.SalesmanCompanySalesChannel salesChannel = new CEC_RestObjects.SalesmanCompanySalesChannel();
        CEC_RestObjects.SalesChannelSalesTeam salesTeam = new CEC_RestObjects.SalesChannelSalesTeam();
        List<Object> lstTelephoneNumbers = new List<Object>();
        Map<String, String> mapTelephoneNumber = new Map<String, String>();
        List<CEC_RestObjects.SalesmanCompany> lstCompany = new List<CEC_RestObjects.SalesmanCompany>();
        List<CEC_RestObjects.ComplementarySubAddress> complementarySubAddress = new List<CEC_RestObjects.ComplementarySubAddress>();

        System.debug('hpMap: '+hpMap);
        for (String attribute : hpMap.keySet()){
            if(attribute.equalsIgnoreCase('buildingId')){
                data.buildingId = (String)hpMap.get('buildingId');
            } 

            if(attribute.equalsIgnoreCase('proposalId')) {
                data.proposalId = (String)hpMap.get('proposalId');
            } 
            
            // PROPERTIES
            if(attribute.equalsIgnoreCase('id')) {
                properties.id = (String)hpMap.get('id');
            } 
            
            if(attribute.equalsIgnoreCase('placeId')) {
                address.placeId = (String)hpMap.get('placeId');
            } 
            
            if(attribute.equalsIgnoreCase('cityId')) {
                address.cityId = (String)hpMap.get('cityId');
            }

            if(attribute.equalsIgnoreCase('city')) {
                address.city = (String)hpMap.get('city');
            }
            
            if(attribute.equalsIgnoreCase('neighborhood')) {
                address.neighborhood = (String)hpMap.get('neighborhood');
            } 
            
            if(attribute.equalsIgnoreCase('postalCode')) {
                address.postalCode = (String)hpMap.get('postalCode');
            }

            if(attribute.equalsIgnoreCase('streetName')) {
                address.streetName = (String)hpMap.get('streetName');
            }

            if(attribute.equalsIgnoreCase('streetNr')) {
                address.streetNr = (String)hpMap.get('streetNr');
            }

            if(attribute.equalsIgnoreCase('note')) {
                address.note = (String)hpMap.get('note');
            }

            // CLIENT
            if(attribute.equalsIgnoreCase('clientName')) {
                client.name = (String)hpMap.get('clientName');
            }

            if(attribute.equalsIgnoreCase('areaCode')) {
                mapTelephoneNumber.put('areaCode', (String)hpMap.get('areaCode'));
            } 
            
            if(attribute.equalsIgnoreCase('number')) {
                mapTelephoneNumber.put('number', (String)hpMap.get('number'));
            }

            // SALESMAN
            if(attribute.equalsIgnoreCase('salesmanName')) {
                salesman.name = (String)hpMap.get('salesmanName');
            } 
            
            if(attribute.equalsIgnoreCase('salesmanLogin')) {
                salesman.login = (String)hpMap.get('salesmanLogin');
            }

            if(attribute.equalsIgnoreCase('corporateName')) {
                company.corporateName = (String)hpMap.get('corporateName');
            }

            if(attribute.equalsIgnoreCase('channelDescription')) {
                salesChannel.description = (String)hpMap.get('channelDescription');
            }

            if(attribute.equalsIgnoreCase('teamDescription')) {
                salesTeam.description = (String)hpMap.get('teamDescription');
            }

            if(attribute.equalsIgnoreCase('name1')) {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description1') != null ? (String)hpMap.get('description1') : '' ;
                newComplement.name = (String)hpMap.get('name1') != null ? (String)hpMap.get('name1') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {
                    complementarySubAddress.add(newComplement);
                }
            
            } else if(attribute.equalsIgnoreCase('name2')) {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description2') != null ? (String)hpMap.get('description2') : '' ;
                newComplement.name = (String)hpMap.get('name2') != null ? (String)hpMap.get('name2') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {
                    complementarySubAddress.add(newComplement);
                }

            } else if(attribute.equalsIgnoreCase('name3')) {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description3') != null ? (String)hpMap.get('description3') : '' ;
                newComplement.name = (String)hpMap.get('name3') != null ? (String)hpMap.get('name3') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {
                    complementarySubAddress.add(newComplement);
                }
            
            } else if(attribute.equalsIgnoreCase('name4')) {
                String name = (String)hpMap.get(attribute);
                CEC_RestObjects.ComplementarySubAddress newComplement = new CEC_RestObjects.ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description4') != null ? (String)hpMap.get('description4') : '' ;
                newComplement.name = (String)hpMap.get('name4') != null ? (String)hpMap.get('name4') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {
                    complementarySubAddress.add(newComplement);
                }
            }
        }

        address.complementarySubAddress = complementarySubAddress;
        properties.address = address;
        data.properties = properties;

        lstTelephoneNumbers.add(mapTelephoneNumber);
        contact.telephoneNumbers = lstTelephoneNumbers;
        client.contact = contact;
        data.client = client;

        salesChannel.salesTeam = salesTeam;
        company.salesChannel = salesChannel;
        lstCompany.add(company);
        salesman.company = lstCompany;
        data.salesman = salesman;

        requestHP.data = data;
        return consultar(requestHP);
    }

    private static CEC_RestObjects.ResponseGen consultar(CEC_RestObjects.CreateHPAnalysis aReq) {
        String lBodyRes, lHttpRes = '-1';
        CEC_RestObjects.ResponseGen lRes;
        
        try {
            System.debug(LoggingLevel.INFO, 'HP Creation Analysis Request =>' + JSON.serializePretty(aReq, true));
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            req.setHeader('x-client-auth', 'Bearer ' + CEC_IntegrationGetToken.checktoken());
            req.setHeader('Accept', 'application/json');
            
            if (Test.isRunningTest()) {
                req.setEndpoint('https://test.createHPAnalysis.com');
            }

            HTTPResponse res = CEC_HttpReq.sendReq(req, aReq);
            lBodyRes = res.getBody();
            lHttpRes = String.valueOf(res.getStatusCode());
            
            System.debug(LoggingLevel.INFO, 'Response Body: ' + lBodyRes);
            System.debug(LoggingLevel.INFO, 'Status Code: ' + lHttpRes);
            
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.createHP.class);
            lRes = (CEC_RestObjects.ResponseGen)lObj;
        
        } catch (Exception ex) {
            if(param.IsActive__c) {
                lRes = genResponseError(lRes.error.detailedMessage, lHttpRes);
            }
        }
        return lRes;
    }

    private static CEC_RestObjects.ResponseGen genResponseError(String aMsg, String aHttpCode) {
        System.debug('CEC_IntegrationHPCreationAnalysis' + aMsg);
        
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.createHP lRes = new CEC_RestObjects.createHP();
        lRes.error = lError;
        return lRes;
    }
    
    global static CEC_RestObjects.ResponseGen generateMock(String aURL, Integer aHttpCode){
        return generateMock(new URL(aURL), aHttpCode);
    }

    global static CEC_RestObjects.ResponseGen generateMock(URL aURL, Integer aHttpCode){
        CEC_RestObjects.ResponseGen HP = new CEC_RestObjects.ResponseGen();
        HP.apiVersion = '1';
        HP.transactionId = '1';        
        return HP;
    }
}