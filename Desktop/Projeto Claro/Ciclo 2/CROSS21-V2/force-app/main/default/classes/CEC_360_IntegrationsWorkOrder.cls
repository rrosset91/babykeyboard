/* 
* @author: Diogo Braga - Deloitte 
* @date: 04/12/2019
* 
* @description: Classe de Integração para o servicos de WorkOrder
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/
public class CEC_360_IntegrationsWorkOrder extends CEC_360_IntegrationOrdersAbstract {
    
    /*@author: Diogo Braga - Deloitte 
    *@date: 04/12/2019
	*@description: método que busca por callout e retorna os workorders
	*@return lista de WorkOrder*/
    public List<WorkOrder> sendRequest(WorkOrderRequest varWorkOrderRequest) {
        
        CEC_360_serviceName__mdt serviceName = [SELECT ServiceName__c 
                                                FROM CEC_360_serviceName__mdt 
                                                WHERE MasterLabel = 'CEC_360_WorkOrder_GET'];
        
        HTTPResponse response = send(varWorkOrderRequest, serviceName.ServiceName__c, 'GET');
        
        WorkOrderResponse varWorkOrderResponse = (WorkOrderResponse) 
            JSON.deserialize(response.getBody(), WorkOrderResponse.class);
        
        if(varWorkOrderResponse.data == null || varWorkOrderResponse.data.workorders == null) {
            throw new IntegrationsOrdersException('Response data is null');
        }
        
        return varWorkOrderResponse.data.workorders;
    }
    
	/* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (request)*/
    public class WorkOrderRequest extends OrderRequestAbstract {
        public WorkOrderRequest(String operatorCode, Integer contractNumber) {
            this.operatorCode = operatorCode;
            this.contractNumber = contractNumber;
        }
        
        public Boolean isProtocolLimit {get; set;}
        public Integer limitReturn {get; set;}   
        public Integer protocolNumber {get; set;}
        public String workOrderID {get; set;}
        public String workorderTypeID {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class WorkOrderResponse {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public Data data {get; set;}
        public Error error {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class Data {
        public List<WorkOrder> workorders {get; set;}
    }
     
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados (response)*/
    public class WorkOrder extends OrderResponseAbstract {
        @AuraEnabled
        public String workOrderID {get; set;}
        @AuraEnabled
        public String workorderTypeID {get; set;}
        @AuraEnabled
        public String workorderTypeDescription {get; set;}
        @AuraEnabled
        public String note {get; set;}
        @AuraEnabled
        public String terminationDate {
            get;
			set { 
                terminationDate = convertDateFormat(value);
            }
        }
        @AuraEnabled
        public String attendanceDate {
            get;
			set { 
                attendanceDate = convertDateFormat(value);
            }
        }
        @AuraEnabled
        public String isExempt {get; set;}
        @AuraEnabled
        public String eventDate {
            get;
			set { 
                eventDate = convertDateFormat(value);
            }
        }
    }
    
}