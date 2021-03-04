/* 
* @author: Diogo Braga - Deloitte 
* @date: 04/12/2019
*
* @description: Classe de Integração para o servicos de Orders
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/
public class CEC_360_IntegrationsConfiguration extends CEC_360_IntegrationOrdersAbstract  {
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 06/12/2019
	* @description: Método que monta e envia a requisição*/
    public List<ConfigOrder> sendRequest(OrderConfigRequest varOrderConfigRequest) {
        CEC_360_serviceName__mdt serviceName = [SELECT ServiceName__c 
                                                FROM CEC_360_serviceName__mdt 
                                                WHERE MasterLabel = 'CEC_360_OrderConfiguration_GET'];
        
        HTTPResponse response = send(varOrderConfigRequest, serviceName.ServiceName__c, 'GET');
        
        OrderConfigResponse varOrderConfigResponse = (OrderConfigResponse) 
            JSON.deserialize(response.getBody(), OrderConfigResponse.class);
        
        if(varOrderConfigResponse.data == null) {
            throw new IntegrationsOrdersException('Response data is null');
        }
        
        return varOrderConfigResponse.data.configurationorders;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (request)*/
    public class OrderConfigRequest extends OrderRequestAbstract {
        public OrderConfigRequest(String operatorCode, Integer contractNumber) {
            this.operatorCode = operatorCode;
            this.contractNumber = contractNumber;
        }
        
        public String configurationOrderID {get; set;}
        public String configurationorderTypeID {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class OrderConfigResponse {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public Data data {get; set;}
        public Error error {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class Data {
        public List<ConfigOrder> configurationorders {get; set;}
    }
     
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class ConfigOrder extends OrderResponseAbstract {
        @AuraEnabled
        public String configurationOrderID {get; set;}
        @AuraEnabled
        public String configurationorderTypeID {get; set;}
        @AuraEnabled
        public String configurationorderTypeDescription {get; set;}
        @AuraEnabled
        public String productID {get; set;}
        @AuraEnabled
        public String productDescription {get; set;}
        @AuraEnabled
        public String terminationDate {
            get;
			set { 
                terminationDate = convertDateFormat(value);
            }
        }
        @AuraEnabled
        public String pointID {get; set;}
    }
}