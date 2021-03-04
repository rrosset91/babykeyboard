public with sharing class CEC_SalesOrder_Integration {

    private final ServiceParameter__c param = ServiceParameter__c.getInstance('SalesOrdersMobile');

    public SalesOrderIntegrationDTO.SalesOrderMobileResponse executeSalesOrderMobile(
            Order order, User user, Profile profile, IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp credAnalisys,
            PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis portabilty, List<ProductsIntegrationDTO.ProductsResponses> prod,
            SalesManDTO.SalesMen salesMen, map<Id,PhoneNumberReservationDTO.IntegrationTestTelephoneInfo> numberReservation,IBGE__c ibge, boolean thab) {
        SalesOrderIntegrationDTO dto = new SalesOrderIntegrationDTO(); 
		system.debug('numberReservation kk>>'+JSON.serializepretty( numberReservation));
        SalesOrderIntegrationDTO.SalesOrderMobileRequest request = dto.builderRequest(order, user,
                profile, credAnalisys, portabilty, prod, salesMen,numberReservation,ibge,thab);
                
        system.debug('executeSalesOrderMobile.request: '+json.serialize(request));
		system.debug('massa enviada para frente: '+order+user+profile+credAnalisys+portabilty+prod+salesMen+numberReservation+ibge);
                
        return consultar(request);
    }

    public static SalesOrderIntegrationDTO.SalesOrderMobileResponse consultar() {
        String bodyResponse, statusResponse = '-1';

        SalesOrderIntegrationDTO.SalesOrderMobileResponse response;

        HttpRequest req = CEC_HttpReq.genHttpReq(ServiceParameter__c.getInstance('SalesOrdersMobile'), '');
        try {

            HTTPResponse res = CEC_HttpReq.sendReq(req,response,true);
            //HTTPResponse res = CEC_HttpReq.sendReqByJson(req);

            bodyResponse = res.getBody();
            statusResponse = String.valueOf(res.getStatusCode());
            system.debug('STATUS: ' + statusResponse + ' | FINAL: ' + res.getBody());
            response = (SalesOrderIntegrationDTO.SalesOrderMobileResponse)
                    JSON.deserialize(bodyResponse, SalesOrderIntegrationDTO.SalesOrderMobileResponse.class);
        } catch (Exception ex) {
            if (ServiceParameter__c.getInstance('SalesOrdersMobile').IsActive__c) {
                system.debug('EXCEPTION: ' + ex.getMessage());
            }
        }
        return response;
    }

    private SalesOrderIntegrationDTO.SalesOrderMobileResponse consultar(SalesOrderIntegrationDTO.SalesOrderMobileRequest request) {
        String bodyResponse, statusResponse = '-1';

        SalesOrderIntegrationDTO.SalesOrderMobileResponse response;

        HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
        try {
            HTTPResponse res = CEC_HttpReq.sendReq(req, request, true);

            bodyResponse = res.getBody();
            statusResponse = String.valueOf(res.getStatusCode());
            system.debug('STATUS: ' + statusResponse + ' | FINAL: ' + res.getBody());
            response = (SalesOrderIntegrationDTO.SalesOrderMobileResponse)
                    JSON.deserialize(bodyResponse, SalesOrderIntegrationDTO.SalesOrderMobileResponse.class);
        } catch (Exception ex) {
            if (param.IsActive__c) {
                system.debug('EXCEPTION: ' + ex.getMessage());
            }
        }
        return response;
    }

}