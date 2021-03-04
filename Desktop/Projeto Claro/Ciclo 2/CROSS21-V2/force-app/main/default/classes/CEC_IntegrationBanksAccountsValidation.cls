/**
 * Created by 93668256 on 12/11/2019.
 */

global with sharing class CEC_IntegrationBanksAccountsValidation {

    public static ServiceParameter__c param;

    public Boolean isAccountValid(String bic, String branchNumber, String accountNumber) {
        param = ServiceParameter__c.getInstance('CEC_IntegrationBanksAccountsValidation');

        String bodyResponse, statusResponse = '-1';
        HttpResponse res = new HttpResponse();

        try {
            String query = '?BIC=' + bic + '&branchNumber=' + branchNumber + '&accountNumber=' + accountNumber;
            HttpRequest req = CEC_HttpReq.genHttpReq(param, query);
            system.debug('REQUEST: ' + req);

            Http h = new Http();

            res = h.send(Req);
            statusResponse = String.valueOf(res.getStatusCode());

            BanksAccountsValidationResponse data = ((BanksAccountsValidationResponse)
                    JSON.deserialize(res.getBody(), BanksAccountsValidationResponse.class));

            system.debug('RESPONSE: ' +res.getBody());
            return data.getValue();
        } catch (Exception ex) {
            system.debug('EXCEPTION: ' + ex.getMessage());
        }
        return false;
    }

    public class BanksAccountsValidationResponse {
        public IsValid data = new IsValid();
        public Boolean getValue() {
            if (this.data.isValid.equals('true'))
                return true;
            return false;
        }
    }

    public class Isvalid {
        public String isValid;
    }

	public static BanksAccountsValidationResponse generateMock(String aURL, Integer aHttpCode)
    {
        return generateMock(new URL(aURL), aHttpCode);
    }
    public static BanksAccountsValidationResponse generateMock(URL aURL, Integer aHttpCode)
    {
        IsValid oData = new IsValid();
        oData.isValid = 'true';
        
        BanksAccountsValidationResponse response = new BanksAccountsValidationResponse();
        response.data = oData;
        
        return response;
    }    
}