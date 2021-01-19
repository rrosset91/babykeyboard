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
public class CEC_360_IntegrationOrdersAbstractTest {
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: método de teste setup (prepara o banco de teste)*/
    @testSetup
    public static void testSetup() {
        
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: método de teste principal, como a classe é abstrata foi ustilizado o teste pela classe filha,
	* para não ficar replicando código foi utilizada somente a chamada do metódo de teste da classe filha */
    @isTest
    public static void mainTest() {
        CEC_360_IntegrationsWorkOrderTest.mainTest();
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa se o parâmetro é nulo*/
    @isTest
    public static void errorNullParameter() {
        Boolean hasError = false;
        try {
            new CEC_360_IntegrationsWorkOrder.WorkOrderRequest(null, null);
        } catch(CEC_360_IntegrationOrdersAbstract.IntegrationsOrdersException e) {
            hasError = true;
        }
		System.assert(hasError, 'Erro não disparado');   
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa se o parâmetro é branco*/
    @isTest
    public static void errorBlankParameter() {
        Boolean hasError = false;
        try {
            new CEC_360_IntegrationsWorkOrder.WorkOrderRequest('', 1);
        } catch(CEC_360_IntegrationOrdersAbstract.IntegrationsOrdersException e) {
            hasError = true;
        }
		System.assert(hasError, 'Erro não disparado');   
    }
    
    /*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: testa a instancia dos modelos*/
    @isTest
    public static void instanceObjectModels() {
        CEC_360_IntegrationOrdersAbstract.Link link = new CEC_360_IntegrationOrdersAbstract.Link();
        link.rel = 'test';
        link.href = 'test';
        
        CEC_360_IntegrationOrdersAbstract.Error error = new CEC_360_IntegrationOrdersAbstract.Error();
        error.httpCode = 'test';
        error.errorCode = 'test';
        error.message = 'test';
        error.detailedMessage = 'test';
        error.link = link;
        
        CEC_360_IntegrationsWorkOrder.WorkOrder workOrder = new CEC_360_IntegrationsWorkOrder.WorkOrder();
        workOrder.cityId = 'test';
        workOrder.operatorCode = 'test';
        workOrder.contractNumber = 'test';
        workOrder.requestID = 'test';
        workOrder.status = 'test';
        workOrder.statusDescription = 'test';
        workOrder.closeUser = 'test';
    }
}