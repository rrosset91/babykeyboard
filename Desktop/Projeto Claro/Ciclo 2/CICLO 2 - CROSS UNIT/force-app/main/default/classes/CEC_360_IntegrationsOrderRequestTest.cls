/* 
* @author: Diogo Braga - Deloitte 
* @date: 04/12/2019
*
* @description: classe de teste
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/ 
@isTest 
public class CEC_360_IntegrationsOrderRequestTest {

    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: método de teste setup (prepara o banco de teste)*/
    @testSetup 
    public static void testSetup() {

    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa o fluxo principal*/
    @isTest
    public static void mainTest() {
        CEC_360_IntegrationsOrderRequest.OrderReqRequest newRequest = 
            new CEC_360_IntegrationsOrderRequest.OrderReqRequest('003', 386923328);
        
        Date startDate = System.today();
        Date endDate = System.today();
        newRequest.startDate = startDate.year() + '-' + startDate.day() + '-' + startDate.month(); 
        newRequest.endDate = endDate.year() + '-' + endDate.day() + '-' +  endDate.month(); 
        newRequest.cityId = 'test';
        newRequest.requestID = 'test';
        newRequest.status = 'test';
		
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationsOrderRequestMock());
        
        List<CEC_360_IntegrationsOrderRequest.OrderReq> listObjResponse = 
            new CEC_360_IntegrationsOrderRequest().sendRequest(newRequest);
        
        System.assert(!listObjResponse.isEmpty(), 'Retorno inválido');
        Test.stopTest();
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa a instancia dos modelos*/
    @isTest
    public static void instanceObjectModels() {
        
        CEC_360_IntegrationsOrderRequest.OrderReqResponse newOrderReqResponse = new CEC_360_IntegrationsOrderRequest.OrderReqResponse();
        newOrderReqResponse.apiVersion = 'test';
        newOrderReqResponse.transactionId = 'Test';
        newOrderReqResponse.error = null;
        
        CEC_360_IntegrationsOrderRequest.OrderReq newOrderReq = new CEC_360_IntegrationsOrderRequest.OrderReq();
        newOrderReq.requestTypeID = 'teste';
        newOrderReq.requestTypeDescription = 'teste';
            newOrderReq.openUser = 'teste';
            newOrderReq.obs = 'teste';
            newOrderReq.cancelReasonID = 'teste';
            newOrderReq.cancelReasonDescription = 'teste';
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: classe mock da integração*/
    public class IntegrationsOrderRequestMock implements HttpCalloutMock {
        /*@author: Diogo Braga - Deloitte 
		* @date: 04/12/2019
		* @description: método de implementação implementa a interface HttpCalloutMock*/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '{ "apiVersion": "1;2019-11-19", "transactionId": "Id-8798ee5d8b71c8857a71701d", "data": { "requests": [ { "cityId": "88412", "operatorCode": "003", "contractNumber": "386923328", "requestID": 368249067, "requestTypeID": 1, "requestTypeDescription": "ADESAO - INSTALACAO DE ASSINATURA", "status": 1, "statusDescription": "EXECUTADA", "closeDate": "Tue Jun 13 00:00:00 BRT 2017", "closeUser": "OPS$OSWAP", "openUser": "T6805581", "obs": "", "cancelReasonID": null, "cancelReasonDescription": null } ] } }';
            
            response.setBody(body);
            response.setStatus('OK');
            response.setStatusCode(200);
            return response;
        }
    }
}