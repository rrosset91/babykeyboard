public class CEC_IntegrationProducts {

    public static ServiceParameter__c param;

    public ProductsIntegrationDTO.ProductsResponses consultar(ProductsIntegrationDTO.ProductsRequests request) {
        param = ServiceParameter__c.getInstance('CEC_Products');
        system.debug('REQUEST Consultar>>'+request);
        String bodyResponse, statusResponse = '-1';
        ProductsIntegrationDTO.ProductsResponses response;

        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            system.debug('HH param>>'+req);
            HTTPResponse res = CEC_HttpReq.sendReq(req, request,true);
           // HTTPResponse res = CEC_HttpReq.sendReqByJson(req);

            bodyResponse = res.getBody();
            system.debug('hh bodyResponse>>'+res);
            system.debug('hh bodyResponse>>'+res.getBody());
            statusResponse = String.valueOf(res.getStatusCode());
            system.debug('BODY: ' + bodyResponse);

            response = (ProductsIntegrationDTO.ProductsResponses)
                    JSON.deserialize(bodyResponse, ProductsIntegrationDTO.ProductsResponses.class);
            system.debug('STATUS: '+res.toString()+res.getBody());

        } catch (Exception ex) {
            if (param.IsActive__c) {
                system.debug('EXCEPTION: ' + ex.getMessage());
            }
        }
        return response;
    }

    public static ProductsIntegrationDTO.ProductsResponses testResponse() {
        String responseJsonString = '{"data":{"product":{"type":"VOZ","subType":"MOVEL","sharedProductIndicator":true,"offer":{"id":"1111","name":"DEP.COMPART.TOTALR$49,99","price":"49.99"},"customer":{"customerAcceptances":{"flagAcceptMarketingMessages":""}},"promotion":{"id":"1164-2","name":"PROMOCAODIADASMAES2011","description":"PROMOCAOFALEMUITOGASTEPOUCO","discount":"300.00","expirationDate":"2010-03-11T08:00:00-03:00","category":{"id":"ATIVACAO"},"offer":{"id":"1111"}},"service":[{"id":"1234","name":"PacoteInternet100-Novo","contractedService":true,"category":{"id":"12345","name":"Internet","description":"PacotededadosdeInternet.","priority":"1","loyalty":{"flagValidity":true}}}],"productOffering":{"type":"POS_PAGO","id":"12345","name":"ClaroOnline2GB","nickname":"2GB","description":"PlanoClaroOnlinecom2GBdedados,100minutosdevoz,IlimitadoClaroparaClaro","startDate":"2009-01-01T00:00:00-03:00","expirationDate":"2017-07-26T19:30:20-03:00","price":"200.00","limitAmount":"5","service":[{"id":"1234","name":"PacoteInternet100-Novo","category":{"id":"12345","name":"Passaporte"}}]}}}}';

        responseJsonString = responseJsonString.replaceAll('type', 'type_Z');

        ProductsIntegrationDTO.ProductsResponses response = (ProductsIntegrationDTO.ProductsResponses)
                JSON.deserialize(responseJsonString, ProductsIntegrationDTO.ProductsResponses.class);

        return response;
    }
}