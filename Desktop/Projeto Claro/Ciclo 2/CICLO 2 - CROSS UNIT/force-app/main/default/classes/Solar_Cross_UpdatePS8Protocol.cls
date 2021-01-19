/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-29-2020   lucas.soldi@ibm.com   Initial Version
**/
public class Solar_Cross_UpdatePS8Protocol {
    @InvocableMethod(   label='Atualizar PS8 com pedido cliente e fechamento' 
                        description='Atualizar o protocolo do PS8 com o pedido do cliente e o fechamento com o tratamento dado (resolução) quando o protocolo for encerrado no SOLAR' 
                        )
    public static void updateProtocol(List<Case> objCase) {
        System.debug('Entrou no update Protocol');
        Data objData = new Data();
        CustomerInteraction objCustomerInteraction = new CustomerInteraction();
        objCustomerInteraction.protocolnumber = objCase[0].LegacyProtocol__c;
        objCustomerInteraction.status = 'FECHADO';
        objCustomerInteraction.details = String.isBlank(objCase[0].RequestSupport__c) ? Label.Solar_Cross_PS8StandardDescription : objCase[0].RequestSupport__c;
        objCustomerInteraction.notes = String.isBlank(objCase[0].Description) ? Label.Solar_Cross_PS8StandardDescription : objCase[0].Description;
        objCustomerInteraction.severity =  'MINIMA';
        objCustomerInteraction.situation = 'NOVO';
        objCustomerInteraction.slaDueDate = objCase[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        System.debug('objCustomerInteraction.slaDueDate: ' +objCustomerInteraction.slaDueDate);
        objCustomerInteraction.priority = 'MEDIA';
        objCustomerInteraction.caseTypeId = objCase[0].Id;
        objCustomerInteraction.systemRelatedCaseId = 'SalesForce';

        objData.data = objCustomerInteraction;

        String body = JSON.serialize(objData);

    if(!Test.isRunningTest())
        callIntegration(body);

    }

    @future(callout=true)
    public static void callIntegration(String body){
        ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('customersInteractionsUpdate');
        Map<String, String> headers = new Map<String, String>();
        headers.put('x-client-auth', metaParameter.Token__c);
        headers.put('Authorization', metaParameter.Token__c);
        headers.put('Content-Type', 'application/json');

        Map<String,String> mapReturn = OutboundCalloutHandler.sendRequest(body,new Map<String,String>(),headers,'customersInteractionsUpdate');
        System.debug('mapReturn' +mapReturn);
    }

    public class Data{
        @AuraEnabled
        public CustomerInteraction data;
    }
    public class CustomerInteraction{
        @AuraEnabled
        public String protocolnumber;
        @AuraEnabled
        public String status;
        @AuraEnabled    
        public String details;
        @AuraEnabled
        public String situation;
        @AuraEnabled
        public String notes ;
        @AuraEnabled
        public String slaDueDate;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String caseTypeId;
        @AuraEnabled
        public String severity;
        @AuraEnabled
        public String systemRelatedCaseId;
    }
}