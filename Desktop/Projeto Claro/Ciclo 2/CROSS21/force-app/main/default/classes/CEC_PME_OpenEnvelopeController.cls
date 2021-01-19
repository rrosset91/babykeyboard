public class CEC_PME_OpenEnvelopeController {
    public class CEC_PME_OpenEnvelopeControllerException extends Exception{}
    
    private Order varOrder;
    
    public String message {get;set;}
    public String cssClassMessage {get;set;}
    public String urlEmbedded {get;set;}
    private final String CSS_CLASS_ERROR = 'slds-theme_error';
    private final String CSS_CLASS_SUCCESS = 'slds-theme_success';
    
    
    public CEC_PME_OpenEnvelopeController(ApexPages.StandardController standardController) {
        this.varOrder = (Order) standardController.getRecord();
        varOrder = [SELECT Id,
                    Status
                    FROM Order 
                    WHERE Id = :varOrder.Id];
        message = '';
        cssClassMessage = '';

    }
    
    public void open() {
        try {
            validate();
            
            message = 'test';
            Integration_Flow__c integrationFlow = Integration_Flow__c.getInstance(UserInfo.getProfileId());
            CEC_PME_ServiceEnvelope.SaveResult saveResult = new CEC_PME_ServiceEnvelope().open(varOrder.Id, integrationFlow.isSigningRequired__c,
                                                                                         integrationFlow.isEmbedded__c, integrationFlow.AccountId__c, 
                                                                                         integrationFlow.TemplateId__c);
            
            message = saveResult.message;
            
            if(saveResult.isError) { 
                cssClassMessage = CSS_CLASS_ERROR;
            } else {
                cssClassMessage = CSS_CLASS_SUCCESS;
            }
            
            urlEmbedded = saveResult.urlEmbedded;
            
            system.debug('urlEmbedded ' + urlEmbedded);
        } catch(Exception e) {
            cssClassMessage = CSS_CLASS_ERROR;
            //message = 'ERRO(' + e.getLineNumber() + '): ' + e.getMessage() + ' - ' + e.getStackTraceString();
            message = 'ERRO: ' + e.getMessage();
        }
    }
    
    private void validate() {
        if(String.isBlank(varOrder.Id)) {
            throw new CEC_PME_OpenEnvelopeControllerException('Id inválido');
        }
        
        if(String.isBlank(varOrder.Status) || !varOrder.Status.equalsIgnoreCase('Contrato criado')) {
            throw new CEC_PME_OpenEnvelopeControllerException('Para enviar para assinatura o contrato deve estar no status contrato criado');
        }
        
    }
}