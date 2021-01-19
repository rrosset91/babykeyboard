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
public class CEC_360_IntegrationsWorkOrderTest {

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
        CEC_360_IntegrationsWorkOrder.WorkOrderRequest newWorkOrderRequest = 
            new CEC_360_IntegrationsWorkOrder.WorkOrderRequest('003', 386923328);
        
    	newWorkOrderRequest.isProtocolLimit = true;
        newWorkOrderRequest.limitReturn = 1;
        newWorkOrderRequest.startDate = System.today();
        newWorkOrderRequest.endDate = System.today();
        newWorkOrderRequest.cityId = 'test';
        newWorkOrderRequest.protocolNumber = 1;
        newWorkOrderRequest.requestID = 'test';
        newWorkOrderRequest.workOrderID = 'test';
        newWorkOrderRequest.status = 'test';
        newWorkOrderRequest.workorderTypeID = 'test';
		
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationsWorkOrderMock());
        
        List<CEC_360_IntegrationsWorkOrder.WorkOrder> listWorkOrders = 
            new CEC_360_IntegrationsWorkOrder().sendRequest(newWorkOrderRequest);
        
        System.assert(!listWorkOrders.isEmpty(), 'Retorno inválido');
        Test.stopTest();
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa a instancia dos modelos*/
    @isTest
    public static void instanceObjectModels() {
        CEC_360_IntegrationsWorkOrder.WorkOrder newWorkOrder = new CEC_360_IntegrationsWorkOrder.WorkOrder();
        newWorkOrder.cityId = 'test';
        newWorkOrder.operatorCode = 'test';
        newWorkOrder.contractNumber = 'test';
        newWorkOrder.requestID = 'test';
        newWorkOrder.workOrderID = 'test';
        newWorkOrder.workorderTypeID = 'test';
        newWorkOrder.workorderTypeDescription = 'test';
        newWorkOrder.status = 'test';
        newWorkOrder.statusDescription = 'test';
        newWorkOrder.note = 'test';
        newWorkOrder.terminationDate = 'test';
        newWorkOrder.attendanceDate = 'test';
        newWorkOrder.isExempt = 'test';
        newWorkOrder.eventDate = 'test';
        newWorkOrder.closeUser = 'test';
        
        CEC_360_IntegrationOrdersAbstract.Link link = new CEC_360_IntegrationOrdersAbstract.Link();
        link.rel = 'test';
        link.href = 'test';
        
        CEC_360_IntegrationOrdersAbstract.Error error = new CEC_360_IntegrationOrdersAbstract.Error();
        error.httpCode = 'test';
        error.errorCode = 'test';
        error.message = 'test';
        error.detailedMessage = 'test';
        error.link = link;
        
        CEC_360_IntegrationsWorkOrder.WorkOrderResponse workOrderResponse = 
            new CEC_360_IntegrationsWorkOrder.WorkOrderResponse();
        workOrderResponse.apiVersion = 'test';
        workOrderResponse.transactionId = 'test';
        workOrderResponse.error = error;
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: classe mock da integração*/
    public class IntegrationsWorkOrderMock implements HttpCalloutMock {
        /*@author: Diogo Braga - Deloitte 
		* @date: 04/12/2019
		* @description: método de implementação implementa a interface HttpCalloutMock*/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '{"apiVersion": "1;2019-11-19","transactionId": "Id-bf14e85d5cf73a093fdb592d","data": {"workorders": [{"cityId": "88412","operatorCode": "003","contractNumber": "386923328","requestID": 368249067,"workOrderID": 1725475729,"workorderTypeID": 51,"workorderTypeDescription": "ADESAO - INSTALACAO DE ASSINATURA DIGITAL","status": "E","statusDescription": "EXECUTADA","note": "","terminationDate": "Tue Jun 13 12:55:49 BRT 2017","attendanceDate": "Fri Jun 09 13:57:48 BRT 2017","isExempt": false,"eventDate": "Tue Jun 13 12:55:41 BRT 2017","closeUser": "OPS$OSWAP"},{"cityId": "88412","operatorCode": "003","contractNumber": "386923328","requestID": 368249070,"workOrderID": 1725475730,"workorderTypeID": 52,"workorderTypeDescription": "ADESAO - INSTALAR SERVICO CONEXAO ADICIONAL DIGITAL","status": "E","statusDescription": "EXECUTADA","note": "","terminationDate": "Tue Jun 13 12:56:02 BRT 2017","attendanceDate": "Fri Jun 09 13:57:48 BRT 2017","isExempt": false,"eventDate": "Tue Jun 13 12:55:41 BRT 2017","closeUser": "OPS$OSWAP"}]}}';
            response.setBody(body);
            response.setStatus('OK');
            response.setStatusCode(200);
            return response;
        }
    }
}