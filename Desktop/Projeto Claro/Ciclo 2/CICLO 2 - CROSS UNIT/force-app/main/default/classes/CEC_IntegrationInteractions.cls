public class CEC_IntegrationInteractions {
 public static ServiceParameter__c param;
    
    public void testIntegration(){
        InteractionsDTO.Request request = (new InteractionsDTO()).builderRequestForControle('11945477785');
        consultar(request);
        request = (new InteractionsDTO()).builderRequestForPos('11945477785');
        consultar(request);
    }
    
    public InteractionsDTO.Response consultar(String msisdn, boolean isPosPago){
        InteractionsDTO dto = (new InteractionsDTO());
        InteractionsDTO.Request request = isPospago ? dto.builderRequestForPos(msisdn)
            : dto.builderRequestForControle(msisdn);
        return consultar(request);
    }

    private InteractionsDTO.Response consultar(InteractionsDTO.Request request) {
        param = ServiceParameter__c.getInstance('Interactions');
        
        String bodyResponse, statusResponse = '-1';
        InteractionsDTO.Response response;

        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            system.debug('REQUEST: '+req);
            HTTPResponse res = CEC_HttpReq.sendReq(req, request,true);
			system.debug('RESPONSE: '+res);

            bodyResponse = res.getBody();

            statusResponse = String.valueOf(res.getStatusCode());

            response = (InteractionsDTO.Response)
                    JSON.deserialize(bodyResponse, InteractionsDTO.Response.class);
            system.debug('STATUS: '+res.toString()+res.getBody());

        } catch (Exception ex) {
            if (param.IsActive__c) {
                system.debug('EXCEPTION: ' + ex.getMessage());
            }
        }
        system.debug('RETORNO: '+response);
        return response;
    }
}