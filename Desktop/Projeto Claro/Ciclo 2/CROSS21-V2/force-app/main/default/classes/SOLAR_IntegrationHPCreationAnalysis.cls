global class SOLAR_IntegrationHPCreationAnalysis {
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

        CreateHPAnalysis requestHP = new CreateHPAnalysis();
        DataHPAnalysis data = new DataHPAnalysis();
        DataHPAnalysisProperties properties = new DataHPAnalysisProperties();
        PropertiesAddress address = new PropertiesAddress();
        DataHPAnalysisClient client = new DataHPAnalysisClient();
        ClientContact contact = new ClientContact();
        DataHPAnalysisSalesman salesman = new DataHPAnalysisSalesman();
        SalesmanCompany company = new SalesmanCompany();
        SalesmanCompanySalesChannel salesChannel = new SalesmanCompanySalesChannel();
        SalesChannelSalesTeam salesTeam = new SalesChannelSalesTeam();
        List<Object> lstTelephoneNumbers = new List<Object>();
        List<SalesmanCompany> lstCompany = new List<SalesmanCompany>();
        List<ComplementarySubAddress> complementarySubAddress = new List<ComplementarySubAddress>();
        for(Integer i=0; i<4; i++)
        {
            complementarySubAddress.add(new ComplementarySubAddress());
        }

        System.debug('hpMap: '+json.serializePretty(hpMap));
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

            if(attribute.equalsIgnoreCase('cellphone')) {
                Map<String, String> mapTelephoneNumber = new Map<String, String>();
                String cellphone = (String)hpMap.get('cellphone');
                String areaCode = (String.isNotBlank(cellphone) ? cellphone.substring(0, 2) : '');
                String phoneNumber = (String.isNotBlank(cellphone) ? cellphone.substring(2) : '');
                
                mapTelephoneNumber.put('areaCode', areaCode);
                mapTelephoneNumber.put('number', phoneNumber);
                lstTelephoneNumbers.add(mapTelephoneNumber);
            } 
            
            if(attribute.equalsIgnoreCase('phone')) {
                Map<String, String> mapTelephoneNumber = new Map<String, String>();
                String phone = (String)hpMap.get('phone');

                if(String.isNotBlank(phone))
                {
                    String areaCode = (String.isNotBlank(phone) ? phone.substring(0, 2) : '');
                    String phoneNumber = (String.isNotBlank(phone) ? phone.substring(2) : '');

                mapTelephoneNumber.put('areaCode', areaCode);
                mapTelephoneNumber.put('number', phoneNumber);
                lstTelephoneNumbers.add(mapTelephoneNumber);
            }

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
                ComplementarySubAddress newComplement = new ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description1') != null ? (String)hpMap.get('description1') : '' ;
                newComplement.type = (String)hpMap.get('type1') != null ? (String)hpMap.get('type1') : '' ;
                newComplement.name = (String)hpMap.get('name1') != null ? (String)hpMap.get('name1') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {

                    complementarySubAddress.set(0,newComplement);

                }
                
            } else if(attribute.equalsIgnoreCase('name2')) {
                String name = (String)hpMap.get(attribute);
                ComplementarySubAddress newComplement = new ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description2') != null ? (String)hpMap.get('description2') : '' ;
                newComplement.type = (String)hpMap.get('type2') != null ? (String)hpMap.get('type2') : '' ;
                newComplement.name = (String)hpMap.get('name2') != null ? (String)hpMap.get('name2') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {

                    complementarySubAddress.set(1,newComplement);

                }
                
            } else if(attribute.equalsIgnoreCase('name3')) {
                String name = (String)hpMap.get(attribute);
                ComplementarySubAddress newComplement = new ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description3') != null ? (String)hpMap.get('description3') : '' ;
                newComplement.type = (String)hpMap.get('type3') != null ? (String)hpMap.get('type3') : '' ;
                newComplement.name = (String)hpMap.get('name3') != null ? (String)hpMap.get('name3') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {

                    complementarySubAddress.set(2,newComplement);

                }
                
            } else if(attribute.equalsIgnoreCase('name4')) {
                String name = (String)hpMap.get(attribute);
                ComplementarySubAddress newComplement = new ComplementarySubAddress();
                newComplement.description = (String)hpMap.get('description4') != null ? (String)hpMap.get('description4') : '' ;
                newComplement.type = (String)hpMap.get('type4') != null ? (String)hpMap.get('type4') : '' ;
                newComplement.name = (String)hpMap.get('name4') != null ? (String)hpMap.get('name4') : '';
                
                if(newComplement.name != '' && newComplement.description != '') {

                    complementarySubAddress.set(3,newComplement);

                }
            }
        }

        address.complementarySubAddress = complementarySubAddress;
        properties.address = address;
        data.properties = properties;

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

    private static CEC_RestObjects.ResponseGen consultar(CreateHPAnalysis aReq) {
        String lBodyRes, lHttpRes = '-1';
        CEC_RestObjects.ResponseGen lRes;
        
        try {
            //System.debug(LoggingLevel.INFO, 'HP Creation Analysis Request =>' + JSON.serializePretty(aReq, true));
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            req.setHeader('x-client-auth', 'Bearer ' + CEC_IntegrationGetToken.checktoken());
            req.setHeader('Accept', 'application/json');
            
            if (Test.isRunningTest()) {
                req.setEndpoint('https://test.createHPAnalysis.com');
            }

            HTTPResponse res = CEC_HttpReq.sendReq(req, aReq);
            lBodyRes = res.getBody();
            lHttpRes = String.valueOf(res.getStatusCode());
            
            //System.debug(LoggingLevel.INFO, 'Response Body: ' + lBodyRes);
            //System.debug(LoggingLevel.INFO, 'Status Code: ' + lHttpRes);
            
            Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.ResponseGen.class);
            lRes = (CEC_RestObjects.ResponseGen)lObj;
        
        } catch (Exception ex) {
            if(param.IsActive__c) {
                lRes = genResponseError(lRes.error.detailedMessage, lHttpRes);
            }
        }
        return lRes;
    }

    private static CEC_RestObjects.ResponseGen genResponseError(String aMsg, String aHttpCode) {
        //System.debug('CEC_IntegrationHPCreationAnalysis' + aMsg);
        
        CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
        lError.httpCode = aHttpCode;
        lError.message = aMsg;
        
        CEC_RestObjects.ResponseGen lRes = new CEC_RestObjects.ResponseGen();
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

    // Create HP Analysis
    global class CreateHPAnalysis extends CEC_RestObjects.ResponseGen {
        global DataHPAnalysis data;
    }

    global class DataHPAnalysis {
		global String buildingId;
		global String proposalId;
        global DataHPAnalysisProperties properties;
        global DataHPAnalysisClient client;
        global DataHPAnalysisSalesman salesman;
    }
    
    global class DataHPAnalysisProperties {
		global String id;
		global PropertiesAddress address;
    } 

    global class DataHPAnalysisClient {
		global String name;
		global ClientContact contact;
    } 

    global class DataHPAnalysisSalesman {
		global String name;
		global String login;
		global List<SalesmanCompany> company;
    } 

    global class PropertiesAddress {
		global String placeId;
        global String cityId;
        global String city;
        global String neighborhood;
        global String postalCode;
        global String streetName;
        global String streetNr;
        global String note;
        global String complementaryNumber;
        global List<ComplementarySubAddress> complementarySubAddress;
    } 

    global class ComplementarySubAddress {
		global String name;
		global String type;
		global String description;
    }

    global class ClientContact {
		global List<Object> telephoneNumbers;
    } 

    global class SalesmanCompany {
		global String corporateName;
		global SalesmanCompanySalesChannel salesChannel;
    } 

    global class SalesmanCompanySalesChannel {
		global String description;
		global SalesChannelSalesTeam salesTeam;
    } 

    global class SalesChannelSalesTeam {
		global String description;
    } 
}