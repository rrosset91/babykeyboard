global class CEC_IntegrationPortabilitiesPreAnalysis {
    
    public static PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis consultar(string celNumber) {

        Map<String,Object> numberList = new Map<String,Object>();
        numberList.put('number', celNumber);

        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest Portability
            = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest();

        PortabilitiesPreAnalysisDTO.ListOfPhoneNumber listPhones = new PortabilitiesPreAnalysisDTO.ListOfPhoneNumber();
        listPhones.telephoneNumbers = new List<Map<String,Object>>();
        listPhones.telephoneNumbers.add(numberList);

        Portability.data = listPhones;

        return consultar(Portability);
    }

    public static ServiceParameter__c param;
    
    public static PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis consultar(PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest request)
    {
        param  = ServiceParameter__c.getInstance('PreAnalysisPortability');
        
        String bodyResponse, statusResponse = '-1';
        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest lrequest = request;
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis response;
        
        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            HTTPResponse res = CEC_HttpReq.sendReq(req, request);
            system.debug('REQUEST'+Json.serialize(request));
            bodyResponse = res.getBody();
            system.debug('RESPONSE'+bodyResponse);
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":', '"number":' => '"number_z":' };
                    for (String iJsonAttr: lMapResWord.keyset())
                {
                    bodyResponse = bodyResponse.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                }
            
            statusResponse = String.valueOf(res.getStatusCode());

            response = (PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis) 
                JSON.deserialize(bodyResponse, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis.class);
            system.debug('FINAL: ' +response);
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                system.debug('EXCEPTION: ' +ex.getMessage());
            }
        }
        return response;
    }


    public PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis consultar(string celNumber,Boolean remover)
    {

        Map<String,Object> numberList = new Map<String,Object>();
        numberList.put('number', celNumber);

        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest Portability
                = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest();

        PortabilitiesPreAnalysisDTO.ListOfPhoneNumber listPhones = new PortabilitiesPreAnalysisDTO.ListOfPhoneNumber();
        listPhones.telephoneNumbers = new List<Map<String,Object>>();
        listPhones.telephoneNumbers.add(numberList);

        Portability.data = listPhones;

        param  = ServiceParameter__c.getInstance('PreAnalysisPortability');

        String bodyResponse, statusResponse = '-1';

        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysisRequest lrequest = Portability;
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis response;

        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            HTTPResponse res = CEC_HttpReq.sendReq(req, Portability);
            bodyResponse = res.getBody();

            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":', '"number":' => '"number_z":' };
            for (String iJsonAttr: lMapResWord.keyset())
            {
                bodyResponse = bodyResponse.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
            }

            statusResponse = String.valueOf(res.getStatusCode());

            response = (PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis)
                    JSON.deserialize(bodyResponse, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis.class);
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                system.debug('EXCEPTION: ' +ex.getMessage());
            }
        }
        return response;
    }

    public static PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    public static PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis generateMock(URL aURL, Integer aHttpCode)
    {
        
        PortabilitiesPreAnalysisDTO.TelephoneNumber tel = new PortabilitiesPreAnalysisDTO.TelephoneNumber();
        tel.number_Z = '19999000000';
        
        PortabilitiesPreAnalysisDTO.Tickets tickets = new PortabilitiesPreAnalysisDTO.Tickets();
        tickets.id= '0001';
        tickets.telephoneNumber = tel;

        List<PortabilitiesPreAnalysisDTO.Tickets> lstTickets = new List<PortabilitiesPreAnalysisDTO.Tickets>();
        lstTickets.add(tickets);
        
        PortabilitiesPreAnalysisDTO.Availables oAvailables = new PortabilitiesPreAnalysisDTO.Availables();
        oAvailables.portabilityIndicatorSource = 'Source';
        oAvailables.detail = 'Detail';
        oAvailables.name = 'Name';
        oAvailables.spidCode = 'Spid Code';
        oAvailables.tickets = lstTickets;

        PortabilitiesPreAnalysisDTO.Unavailables oUnavailables= new PortabilitiesPreAnalysisDTO.Unavailables();
        oUnavailables.detail = 'Detail';
        oUnavailables.reasonId = '01';
        oUnavailables.tickets = lstTickets; 
            
        PortabilitiesPreAnalysisDTO.Vailables vailables = new PortabilitiesPreAnalysisDTO.Vailables();
        vailables.unavailables = oUnavailables;
        vailables.availables = oAvailables;
        
        PortabilitiesPreAnalysisDTO.PortabilityPre portabilityPre = new PortabilitiesPreAnalysisDTO.PortabilityPre();
        portabilityPre.portabilty = vailables; 
    	
        PortabilitiesPreAnalysisDTO.PortabilityPre data = new PortabilitiesPreAnalysisDTO.PortabilityPre();
        data = portabilityPre;
        
        PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis preAnalysis = new PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis(); 
        preAnalysis.data = data;
            
        return preAnalysis;
    }
}