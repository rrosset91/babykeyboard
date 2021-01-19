/* 
* @author: Diogo Braga - Deloitte 
* @date: 17/12/2019
*
* @description: Classe controller de busca de order request
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/
public class CEC_360_ShowRequisitionsController {
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe de exception*/
    public class ShowRequisitionsControllerException extends Exception {}
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: pega as configurações de busca*/
    @AuraEnabled
    public static SearchConfig  getSearchConfig() {
        SearchConfig searchConfig = new SearchConfig();
        
        DateInputConfig startDate = new DateInputConfig();
        startDate.label = 'Data início';
        startDate.value = System.today().addMonths(-6);
        startDate.maxDate = System.today();
        startDate.messageWhenBadInput = 'Data inválida';
        startDate.disabled = false;
        
        DateInputConfig endDate = new DateInputConfig();
        endDate.label = 'Data fim';
        endDate.value = System.today();
        endDate.maxDate = System.today();
        endDate.messageWhenBadInput = 'Data inválida';
        endDate.disabled = false;
        
        ButtonConfig searchButton = new ButtonConfig();
        searchButton.Label = 'Buscar';
        searchButton.disabled = false;
        
        PickListInputConfig typeInput = new PickListInputConfig();
        typeInput.options = new List<PickListInputOption> {
           		new PickListInputOption('--Selecionar--',''),
                new PickListInputOption('EXECUTADA','1'),
                new PickListInputOption('ABERTA','2'),
                new PickListInputOption('CANCELADA','3')};
                    
        searchConfig.startDate = startDate;
        searchConfig.endDate = endDate;
        searchConfig.searchButton = searchButton;
        searchConfig.typeInput = typeInput;
        return searchConfig;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: pega a tabela*/
    @AuraEnabled
    public static Table getTable(Date startDate, Date endDate, String searchTypeId, String recordId) {
        if(startDate.addMonths(6) < endDate) {
            throw new ShowRequisitionsControllerException('O período máximo permitido para consulta é de 6 meses');
        }
        
        if(startDate > endDate) {
            throw new ShowRequisitionsControllerException('Data início não pode ser maior que a data fim');
        }
        
        Table newTable = new Table();
        newTable.listRequisitions = new List<Requisition>();
        
        system.debug('recordId ' + recordId);
        List<Account> listAccount = [SELECT Id,
                                     ContractReferenceNumber__c,
                                     CityCode__c
                                     FROM Account 
                                     WHERE Id = :recordId];
        
        if(listAccount.isEmpty()) {
            throw new ShowRequisitionsControllerException('Erro na busca da conta');
        }
        
        String operatorCode = listAccount.get(0).CityCode__c;
        Integer contractNumber = Integer.valueOf(listAccount.get(0).ContractReferenceNumber__c);
        
        CEC_360_IntegrationsOrderRequest.OrderReqRequest newOrderReqRequest =
            new CEC_360_IntegrationsOrderRequest.OrderReqRequest(operatorCode, contractNumber);
        
        
        newOrderReqRequest.startDate = startDate.year() + '-' + startDate.day() + '-' + startDate.month();
        newOrderReqRequest.endDate = endDate.year() + '-' + endDate.day() + '-' +  endDate.month();
        newOrderReqRequest.status = searchTypeId;
        
        system.debug('newOrderReqRequest.startDate ' + newOrderReqRequest.startDate);
        system.debug('newOrderReqRequest.endDate ' + newOrderReqRequest.endDate);
        
        List<CEC_360_IntegrationsOrderRequest.OrderReq> listOrderReq = 
            new CEC_360_IntegrationsOrderRequest().sendRequest(newOrderReqRequest);
        
        if(listOrderReq.isEmpty()) {
            throw new ShowRequisitionsControllerException('Não foram encontradas solicitações para o contrato selecionado no período em questão');
        }
        
        for(Integer i = 0; i < listOrderReq.size() ; i++) {
            CEC_360_IntegrationsOrderRequest.OrderReq varOrderReq = listOrderReq.get(i);
            Requisition newRequisition = new Requisition(String.valueOf(i));
            newRequisition.orderRequest = varOrderReq;
            newTable.listRequisitions.add(newRequisition);
        }
        
        return newTable;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: pega as OSs*/
    @AuraEnabled
    public static Requisition getOSs(String strRequisition) {
        Requisition varRequisition = (Requisition) JSON.deserialize(strRequisition, Requisition.class);
        String operatorCode = varRequisition.orderRequest.operatorCode;
        Integer contractNumber = Integer.valueOf(varRequisition.orderRequest.contractNumber);
        
        CEC_360_IntegrationsWorkOrder.WorkOrderRequest newWorkOrderRequest = 
            new CEC_360_IntegrationsWorkOrder.WorkOrderRequest(operatorCode, contractNumber);
        
        newWorkOrderRequest.requestID = varRequisition.orderRequest.requestID;
        
        varRequisition.listWorkOrder = new CEC_360_IntegrationsWorkOrder().sendRequest(newWorkOrderRequest);
        
        return varRequisition;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: pega as OCs*/
    @AuraEnabled
    public static Requisition getOCs(String strRequisition) {
        Requisition varRequisition = (Requisition) JSON.deserialize(strRequisition, Requisition.class);
        String operatorCode = varRequisition.orderRequest.operatorCode;
        Integer contractNumber = Integer.valueOf(varRequisition.orderRequest.contractNumber);
        CEC_360_IntegrationsConfiguration.OrderConfigRequest newOrderConfigRequest = 
            new CEC_360_IntegrationsConfiguration.OrderConfigRequest(operatorCode, contractNumber);
        
        newOrderConfigRequest.requestID = varRequisition.orderRequest.requestID;
            
        varRequisition.listConfigOrder = new CEC_360_IntegrationsConfiguration().sendRequest(newOrderConfigRequest);
        
        return varRequisition;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class Table {
        @AuraEnabled
        public List<Requisition> listRequisitions {get;set;}
    }

    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class Requisition {
        public Requisition(String id) {
            this.id = id;
            this.isSelected = false;
        }
        @AuraEnabled
        public Boolean isSelected {get; set;} 
        @AuraEnabled
        public String id {get; set;} 
        @AuraEnabled
        public CEC_360_IntegrationsOrderRequest.OrderReq orderRequest {get; set;}
        @AuraEnabled
        public List<CEC_360_IntegrationsWorkOrder.WorkOrder> listWorkOrder {get; set;}
        @AuraEnabled
        public List<CEC_360_IntegrationsConfiguration.ConfigOrder> listConfigOrder {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class SearchConfig {
        @AuraEnabled
        public DateInputConfig startDate {get; set;}
        @AuraEnabled
        public DateInputConfig endDate {get; set;}
        @AuraEnabled
        public PickListInputConfig typeInput {get; set;}
        @AuraEnabled
        public ButtonConfig searchButton {get; set;}
    }    
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class PickListInputConfig {
        @AuraEnabled
        public List<PickListInputOption> options {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class PickListInputOption {
        public PickListInputOption(String label, String value) {
            this.value = value;
            this.label = label;
        }
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class ButtonConfig {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public Boolean disabled {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: classe modelo*/
    public class DateInputConfig {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public Date value {get; set;}
        @AuraEnabled
        public Date maxDate {get; set;}
        @AuraEnabled
        public Date minDate {get; set;}
        @AuraEnabled
        public String messageWhenBadInput {get; set;}
        @AuraEnabled
        public Boolean disabled {get; set;}
    }
}