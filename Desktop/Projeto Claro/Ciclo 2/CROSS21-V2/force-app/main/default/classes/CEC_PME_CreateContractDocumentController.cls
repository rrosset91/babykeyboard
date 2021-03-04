public class CEC_PME_CreateContractDocumentController {

    public class CEC_PME_CreateContractDocumentControllerException extends Exception{}
    
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
    private final String STATUS_AGUARD_CRIAC_CONT= 'Aguardando criação contrato';
    
    
    public CEC_PME_CreateContractDocumentController(ApexPages.StandardController standardController) {
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
            //message = 'ERRO(' + e.getLineNumber() + '): ' + e.getMessage() + ' - ' + e.getStackTraceString();
            message = 'ERRO: ' + e.getMessage();
        }
    }
    
    public void init() {
        try {
            validateRequest();
            String jsonResponse = CEC_PME_SalesDocumentsService.getDocuments(varOrder.Id);
            validateResponse(jsonResponse);
            
            varOrder.Status = 'Contrato Criado';
            update varOrder;
            
            cssClassMessage = CSS_CLASS_SUCCESS;
            message = 'Contrato criado com sucesso';

        } catch(Exception e) {
            cssClassMessage = CSS_CLASS_ERROR;
            //message = '(' + e.getLineNumber() + '): ' + e.getMessage() + ' - ' + e.getTypeName();
            //message = 'ERRO(' + e.getLineNumber() + '): ' + e.getMessage() + ' - ' + e.getStackTraceString();
            message = 'ERRO: ' + e.getMessage();
        }
    }
    
    private void validateResponse(String jsonResponse) {
        if(String.isBlank(jsonResponse)) {
            throw new CEC_PME_CreateContractDocumentControllerException('Erro na integração: retorno vazio');
        }
        
        system.debug('jsonResponse ' + jsonResponse);
            
        
        if(jsonResponse.contains('Erro na integração:')) {
            throw new CEC_PME_CreateContractDocumentControllerException(jsonResponse);
        }
       
        if(jsonResponse.contains('Erro na integração:')) {
            throw new CEC_PME_CreateContractDocumentControllerException(jsonResponse);
        }
        
        Map<String, Object> mapJsonResponse = (Map<String, Object>) Json.deserializeUntyped(jsonResponse);
        if(mapJsonResponse.containsKey('error') 
           && ((Map<String, Object>) mapJsonResponse.get('error')).containsKey('message') 
           && String.isNotBlank((String) ((Map<String, Object>) mapJsonResponse.get('error')).get('message'))) {
            throw new CEC_PME_CreateContractDocumentControllerException('Erro na integração:' + ((Map<String, Object>) mapJsonResponse.get('error')).get('message'));
        }
        
        if(mapJsonResponse.containsKey('data')) {
            Map<String, Object> mapData = (Map<String, Object>) mapJsonResponse.get('data');
            if(mapData.containsKey('salesDocuments')) {
                List<Object> listsalesDocuments = (List<Object>) mapData.get('salesDocuments');
                if(listsalesDocuments.isEmpty()) {
                    throw new CEC_PME_CreateContractDocumentControllerException('Erro na integração: salesDocuments está vazio');
                } else {
                    for(Object objSalesDocument :  listsalesDocuments) {
                        Map<String, Object> mapSalesDocument = (Map<String, Object>) objSalesDocument;
                        if(!mapSalesDocument.containsKey('content') || String.isBlank((String) mapSalesDocument.get('content'))) {
                            throw new CEC_PME_CreateContractDocumentControllerException('Erro na criação do contrato (conteúdo vazio). Contate o Administrador do Sistema!');
                        } 
                    }
                }
            } else {
                throw new CEC_PME_CreateContractDocumentControllerException('Erro na integração: salesDocuments está vazio');
            }
        } else {
            throw new CEC_PME_CreateContractDocumentControllerException('Erro na integração: data está vazio ');
        }
        
    }
    
    private void validateRequest() {
        if(String.isBlank(varOrder.Id)) {
            throw new CEC_PME_CreateContractDocumentControllerException('Id inválido');
        }
        
        if(!STATUS_AGUARD_CRIAC_CONT.equalsIgnoreCase(varOrder.Status)) {
            throw new CEC_PME_CreateContractDocumentControllerException('Para criar contrato o status do Pedido deve ser ' + STATUS_AGUARD_CRIAC_CONT);
        }
        
    }
}