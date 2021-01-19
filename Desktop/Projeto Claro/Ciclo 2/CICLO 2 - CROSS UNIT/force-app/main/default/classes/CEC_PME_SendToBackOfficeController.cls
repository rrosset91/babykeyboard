public class CEC_PME_SendToBackOfficeController {
    
    public class CEC_PME_SendToBackOfficeControllerException extends Exception{}
    
    private Order varOrder;
    
    public String message {
        get {
            return message;
        }
        set { 
            if(String.isBlank(value)) {
                message = ''; 
            } else {
                message = value.abbreviate(160);
            }
            
        }
    }
    
    public String cssClassMessage {get;set;}
    private final String CSS_CLASS_ERROR = 'slds-theme_error';
    private final String CSS_CLASS_SUCCESS = 'slds-theme_success';
    private final String STATUS_CONTRATO_ASSINADO = 'Contrato Assinado';
    private final String STATUS_TERRITORIO_ASSOCIADO = 'Território Associado';
    
    public CEC_PME_SendToBackOfficeController(ApexPages.StandardController standardController) {
        try {
            this.varOrder = (Order) standardController.getRecord();
            varOrder = [SELECT Id,
                        Status
                        FROM Order 
                        WHERE Id = :varOrder.Id];
            message = '';
            cssClassMessage = '';
        } catch(Exception e) {
            cssClassMessage = CSS_CLASS_ERROR;
            message = 'ERRO: ' + e.getMessage();
        }
    }
    
    public void init() {
        try {
            validate();
            
            varOrder.Status = 'Pré Analise da Documentação';
            update varOrder;
            
            cssClassMessage = CSS_CLASS_SUCCESS;
            message = 'Contrato enviado para o Backoffice sucesso';
            
        } catch(Exception e) {
            cssClassMessage = CSS_CLASS_ERROR;
            message = 'ERRO: ' + e.getMessage();
        }
    }
    
    private void validate() {
        if(String.isBlank(varOrder.Id)) {
            throw new CEC_PME_SendToBackOfficeControllerException('Id inválido');
        }
        
        if(!STATUS_TERRITORIO_ASSOCIADO.equalsIgnoreCase(varOrder.Status)) {
            throw new CEC_PME_SendToBackOfficeControllerException('Para enviar para o Backoffice a status de pedido deve ser ' + STATUS_TERRITORIO_ASSOCIADO);
        }
    }
}