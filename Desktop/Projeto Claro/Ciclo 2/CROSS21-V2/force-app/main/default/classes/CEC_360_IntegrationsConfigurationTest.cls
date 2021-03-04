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
public class CEC_360_IntegrationsConfigurationTest {

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
        CEC_360_IntegrationsConfiguration.OrderConfigRequest newRequest = new 
            CEC_360_IntegrationsConfiguration.OrderConfigRequest('003', 386923328);
        newRequest.cityId = 'test';
        newRequest.requestID = 'test';
        newRequest.status = 'test';
		
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationsConfigurationMock());
        
        List<CEC_360_IntegrationsConfiguration.ConfigOrder> listObjResponse = 
            new CEC_360_IntegrationsConfiguration().sendRequest(newRequest);
        
        System.assert(!listObjResponse.isEmpty(), 'Retorno inválido');
        Test.stopTest();
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 06/12/2019
	* @description: testa a instancia dos modelos*/
    @isTest
    public static void instanceObjectModels() {
        CEC_360_IntegrationsConfiguration.OrderConfigRequest newOrderConfigRequest = new CEC_360_IntegrationsConfiguration.OrderConfigRequest('teste',123);
        newOrderConfigRequest.configurationOrderID = 'test';
        newOrderConfigRequest.configurationorderTypeID = 'Test';
        
        CEC_360_IntegrationsConfiguration.OrderConfigResponse newOrderConfigResponse = new CEC_360_IntegrationsConfiguration.OrderConfigResponse();
        newOrderConfigResponse.apiVersion = 'test';
        newOrderConfigResponse.transactionId = 'test';
        newOrderConfigResponse.error = null;
        
        CEC_360_IntegrationsConfiguration.ConfigOrder newConfigOrder = new CEC_360_IntegrationsConfiguration.ConfigOrder();
        newConfigOrder.configurationOrderID = 'test';
        newConfigOrder.configurationorderTypeID = 'test';
        newConfigOrder.configurationorderTypeDescription = 'test';
        newConfigOrder.productID = 'test';
        newConfigOrder.productDescription = 'test';
        newConfigOrder.pointID = 'test';
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 06/12/2019
	* @description: classe mock da integração*/
    public class IntegrationsConfigurationMock implements HttpCalloutMock {
       	/*@author: Diogo Braga - Deloitte 
		* @date: 04/12/2019
		* @description: método de implementação implementa a interface HttpCalloutMock*/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '{"apiVersion": "1;2019-11-19","transactionId": "Id-bf14e85d5cf73a093fdb592d","Data":{"configurationorders":[{"configurationOrderID":"test"}]}}';
            response.setBody(body);
            response.setStatus('OK');
            response.setStatusCode(200);
            return response;
        }
    }
}