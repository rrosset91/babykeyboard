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
public class CEC_360_IntegrationsOrderRequest extends CEC_360_IntegrationOrdersAbstract  {
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 06/12/2019
	* @description: Método que monta e envia a requisição*/
    public List<OrderReq> sendRequest(OrderReqRequest varOrderReqRequest) {
        CEC_360_serviceName__mdt serviceName = [SELECT ServiceName__c 
                                                FROM CEC_360_serviceName__mdt 
                                                WHERE MasterLabel = 'CEC_360_OrderRequest_GET'];
        
        HTTPResponse response = send(varOrderReqRequest, serviceName.ServiceName__c, 'GET');

        OrderReqResponse varOrderReqResponse = (OrderReqResponse) 
            JSON.deserialize(response.getBody(), OrderReqResponse.class);
        
        if(varOrderReqResponse.data == null || varOrderReqResponse.data.requests == null) {
            throw new IntegrationsOrdersException('Response data is null');
        }
        
        return varOrderReqResponse.data.requests;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (request)*/
    public class OrderReqRequest extends OrderRequestAbstract {
        public OrderReqRequest(String operatorCode, Integer contractNumber) {
            this.operatorCode = operatorCode;
            this.contractNumber = contractNumber;
        }
        
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String requestTypeID {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class OrderReqResponse {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public Data data {get; set;}
        public Error error {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class Data {
        public List<OrderReq> requests {get; set;}
    }
     
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class OrderReq extends OrderResponseAbstract {
        @AuraEnabled
        public String requestTypeID {get; set;}
        @AuraEnabled
        public String requestTypeDescription {get; set;}
        @AuraEnabled
        public String closeDate {
            get;
			set { 
                closeDate = convertDateFormat(value);
            }
        }
        @AuraEnabled
        public String openUser {get; set;}
        @AuraEnabled
        public String obs {get; set;}
        @AuraEnabled
        public String cancelReasonID {get; set;}
        @AuraEnabled
        public String cancelReasonDescription {get; set;}
    }
    
}