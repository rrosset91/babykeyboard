/*
* Autor: Diogo Braga - Deloitte
* Data: 29/10/19
* Descrição: CEC extesão + SQUAD PME: Classe controller back da solução de status assinatura docusign 
*/
public class CEC_PME_StatusRecipDocusignController {
    public class StatusRecipDocusignControllerException extends Exception{}
    
    private final String TRANSLATE_STATUS = 'translateStatusRecipientDocusign';
    
    private Order varOrder;
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: Contrutor busca no banco e valida scopo de execução
	*/
    public CEC_PME_StatusRecipDocusignController(String recordId) {
        if(String.isBlank(recordId)) {
            throw new StatusRecipDocusignControllerException(Label.CEC_PME_StatusRecipDocusignController_1);
        }
        
        List<Order> listOrders = [SELECT Id,
                                  Status
                                  FROM Order
                                  WHERE Id = :recordId];
        
        if(listOrders.isEmpty()) {
            throw new StatusRecipDocusignControllerException(Label.CEC_PME_StatusRecipDocusignController_2);
        }
        
        varOrder = listOrders.get(0);
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: método disponível para acesso no front, pega o path pelo id do registro
	*/
    @AuraEnabled
    public static String getEnvelop(String recordId) {
        CEC_PME_StatusRecipDocusignController controller = new CEC_PME_StatusRecipDocusignController(recordId);
        
        List<dsfs__DocuSign_Status__c> listEnvelops = [SELECT Id,
                                                       dsfs__Envelope_Status__c,
                                                       Name,
                                                       dsfs__Sent_Date_Time__c,
                                                       dsfs__DocuSign_Envelope_ID__c,
                                                       (SELECT Id,
                                                        AssinaturaObrigatoria__c,
                                                        dsfs__DocuSign_Recipient_Email__c,
                                                        Name,
                                                        dsfs__DocuSign_Routing_Order__c,
                                                        dsfs__Recipient_Status__c
                                                        FROM R00NS0000000WUO2MAO__r
                                                        WHERE Name != 'Fake User'
                                                        ORDER BY dsfs__DocuSign_Routing_Order__c ASC)
                                                       FROM dsfs__DocuSign_Status__c
                                                       WHERE Order__c = :recordId
                                                       ORDER BY CreatedDate DESC 
                                                       LIMIT 1];

        if(listEnvelops.isEmpty()) {
            return JSON.serialize(new dsfs__DocuSign_Status__c());
        } else {
            controller.translateStatus(listEnvelops.get(0));
            return JSON.serialize(listEnvelops.get(0));
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: aplica tradução do status 
	*/
    private void translateStatus(dsfs__DocuSign_Status__c envelop) {
        CEC_PME_FromToUtil fromTo = new CEC_PME_FromToUtil(TRANSLATE_STATUS);
        
        envelop.dsfs__Envelope_Status__c = getTranslatedStatus(envelop.dsfs__Envelope_Status__c, fromTo);
        
        if(envelop.R00NS0000000WUO2MAO__r != null) {
            for(dsfs__DocuSign_Recipient_Status__c recipient : envelop.R00NS0000000WUO2MAO__r) {
                recipient.dsfs__Recipient_Status__c = getTranslatedStatus(recipient.dsfs__Recipient_Status__c, fromTo);
            }
        }
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC extesão + SQUAD PME: busca tradução do status 
	*/
    private String getTranslatedStatus(String status, CEC_PME_FromToUtil fromTo) {
        Boolean isStatusNotBlank = String.isNotBlank(status);
        Boolean isContainsFromTo = isStatusNotBlank && fromTo.hasTo(status.toUpperCase());
        
        if(isContainsFromTo) {
            return fromTo.getTo(status.toUpperCase());
        } else {
            return status;
        }
    }
}