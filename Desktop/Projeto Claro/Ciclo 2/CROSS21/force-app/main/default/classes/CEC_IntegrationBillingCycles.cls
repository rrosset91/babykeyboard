public class CEC_IntegrationBillingCycles {

    public static ServiceParameter__c param;

    public static BillingCyclesResponse consultar() {
        param = ServiceParameter__c.getInstance('BillingCycles');

        String bodyResponse, statusResponse = '-1';

        BillingCyclesResponse response;
        HttpResponse res = new HttpResponse();
        try {
            String query = '?customerType=PF&customerSubType=ASSOCIADO&enableMembershipsAccounts=true';
            HttpRequest req = CEC_HttpReq.genHttpReq(param, query);
            system.debug('REQUEST: ' + req);

            Http h = new Http();

            res = h.send(Req);
            system.debug('EXCEPTION: ' + res);

            bodyResponse = res.getBody();
            system.debug(bodyResponse);
            statusResponse = String.valueOf(res.getStatusCode());
            system.debug('STATUS: ' + statusResponse);

            response = (BillingCyclesResponse)
                    JSON.deserialize(bodyResponse, BillingCyclesResponse.class);
            system.debug('FINAL: ' + response);
        } catch (Exception ex) {
            if (param.IsActive__c) {
                system.debug('EXCEPTION: ' + res);
            }
        }
        return response;
    }

    public class BillingCyclesResponse extends CEC_RestObjects.ResponseGen {
        public BillingCycles data = new BillingCycles();
    }

    public class BillingCycles {
        public List<BillingCycle> billingcycles = new List<BillingCycle>();
    }

    public class BillingCycle {
        public String code;
        public String description;
        public String enableMembershipsAccounts;
        public String dueDay;
        public String expirationDay;
        public String customerType;
        public String customerSubtype;

        public BillingCycle() {
        }

        public BillingCycle(String code, String description, String enableMembershipsAccounts, String dueDay,
                String expirationDay, String customerType, String customerSubtype) {
            this.code = code;
            this.description = description;
            this.enableMembershipsAccounts = enableMembershipsAccounts;
            this.dueDay = dueDay;
            this.expirationDay = expirationDay;
            this.customerType = customerType;
            this.customerSubtype = customerSubtype;
        }
    }

    public static BillingCyclesResponse testResponse() {
        String responseJsonString = '{"data": {"billingcycles": [{"code": "05","description": "Data de Vencimento 15","enableMembershipsAccounts": "true","dueDay": "15","expirationDay": "12","customerType": "12","customerSubtype": "12"}]}}';

        BillingCyclesResponse response = (BillingCyclesResponse)
                JSON.deserialize(responseJsonString, BillingCyclesResponse.class);

        return response;
    }
    
	public static BillingCyclesResponse generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    public static BillingCyclesResponse generateMock(URL aURL, Integer aHttpCode)
    {
		BillingCycle bc = new BillingCycle();
        bc.code = '0001';
        bc.description = 'Teste';
        bc.enableMembershipsAccounts = '1';
        bc.dueDay = '15';
        bc.expirationDay = '20';
        bc.customerType = 'Type';
        bc.customerSubtype = 'SubType';        
        
        List<BillingCycle> lstbc = new List<BillingCycle>();
        lstbc.add(bc);
        
    	BillingCycles bcs = new BillingCycles(); 
        bcs.billingcycles = lstbc;
        
        BillingCyclesResponse response = new BillingCyclesResponse();
        response.data = bcs;
        
        return response;
    }    
}