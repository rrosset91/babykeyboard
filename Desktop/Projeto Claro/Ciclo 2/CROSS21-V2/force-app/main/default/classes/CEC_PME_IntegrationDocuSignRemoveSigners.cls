/* 
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* classe contendo as regras de negocio para consumo das integrações de fechar envelope da docusign
*  ---------------------------------------------------------------
*/ 
public class CEC_PME_IntegrationDocuSignRemoveSigners {
    
    public class SaveResult {
        public SaveResult() {}
        
        public SaveResult(Boolean isError, String message) {
            this.isError = isError;
            this.message = message;
        }
        
        @AuraEnabled
        public Boolean isError {get; set;}
        @AuraEnabled
        public String message {get; set;}      
    }
    
    private Order order;
    
    private dsfs__DocuSign_Status__c envelopeStatus;
    
    public CEC_PME_IntegrationDocuSignRemoveSigners(String orderId) {
        order = [SELECT Id,
                 DocuSignEnvelopeID__c
                 FROM Order
                 WHERE Id = :orderId];
        
        List<dsfs__DocuSign_Status__c> status = [SELECT Id, dsfs__Envelope_Status__c	
                                                 FROM dsfs__DocuSign_Status__c
                                                 WHERE dsfs__DocuSign_Envelope_ID__c = :order.DocuSignEnvelopeID__c];
        
        if(status != null && !status.isEmpty()) {
            envelopeStatus = status.get(0);
        }
    }
    
    public SaveResult removeAllStatusSent() {
        if(envelopeStatus == null || 'Completed'.equalsIgnoreCase(envelopeStatus.dsfs__Envelope_Status__c)) {
            return new SaveResult(false, '');
        }
        
        String accountId = Integration_Flow__c.getInstance(UserInfo.getProfileId()).AccountId__c;
        CEC_PME_IntegrationDocuSignRecipient integrationDocuSignRecipient = new CEC_PME_IntegrationDocuSignRecipient(accountId, order.DocuSignEnvelopeID__c); 
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients listRecipients = getOpenSigner(integrationDocuSignRecipient.listRecipients());
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients recipients;
        
        
        if(listRecipients.signers != null && listRecipients.signers.size() > 0) {    
           	recipients = integrationDocuSignRecipient.deleteRecipients(listRecipients);
        }
        
        if(recipients == null) {
            return new SaveResult(false, ''); 
        } else {
            if(String.isBlank(recipients.errorCode)) { 
                return new SaveResult(false, '');     
            } else { 
                return new SaveResult(true, 'Error: ' + recipients.errorCode + '; ' + recipients.message); 
            }
        }
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients getOpenSigner(CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients recipients) {
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients recipientsOpen = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients();
        recipientsOpen.signers = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        for(CEC_PME_IntegrationDocuSignObjectFactory.Signer signer : recipients.signers) {
            if(String.isNotBlank(signer.status) && !signer.status.equalsIgnoreCase('completed')) {
                recipientsOpen.signers.add(signer);
            }
        }
        
        return recipientsOpen;
    }
}