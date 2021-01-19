public class CEC_ME_ProtocolController {
    
    public PageReference callRedirect() {
        
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        system.debug(ApexPages.currentPage().getParameters());
        String protocolo = parameters.get('protocolnumber');
        String numeroContrato = parameters.get('contractnumber');
		String codigoCidade = parameters.get('cityCode');
		String unidadeNegocio = parameters.get('BusinessUnit');

        Id accountTypeConsumer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();  
        Id accountTypeBilling = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); 
        PageReference pageReference;
        Account conta = new Account ();
        
        if(String.isNotBlank(numeroContrato)){
             //numeroContrato = this.formatarNumContrato(numeroContrato);
            try{
                conta = [SELECT ParentId
                         FROM Account
                         WHERE contractReferenceNumber__c =: numeroContrato
                         AND RecordTypeId =: accountTypeBilling
                         AND Parent.RecordTypeId =: accountTypeConsumer
						 AND cityCode__c =: codigoCidade
						 AND BusinessUnit__c =: unidadeNegocio
                         LIMIT 1];
            }catch(queryException e){
                this.createCustomerInteraction(null, protocolo);            
                pageReference = new PageReference('/lightning/n/Buscar_Cliente');
                pageReference.setRedirect(true);
            }
            
        }
     
        if(conta.parentId != null){
            this.createCustomerInteraction(conta.parentId, protocolo); 
            pageReference = new PageReference('/lightning/r/Account/' + conta.parentId + '/view');
            pageReference.setRedirect(true);        
        }else{
            this.createCustomerInteraction(null, protocolo);            
            pageReference = new PageReference('/lightning/n/Buscar_Cliente');
            pageReference.setRedirect(true);
        }
        return pageReference;
    }
    
    public void createCustomerInteraction(Id accountId, String protocolo) {
        vlocity_cmt__CustomerInteraction__c newCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
        newCustomerInteraction.ProtocolNumber__c = protocolo;
        newCustomerInteraction.vlocity_cmt__AccountId__c = accountId;
        insert newCustomerInteraction;
        system.debug('newCustomerInteraction ' + newCustomerInteraction);
    }
   
    public String formatarNumContrato (String numContrato){
        List<String> strings = numContrato.split('/');
        //se houver barra
        if(strings.size() > 1){
            return strings[0] + strings [1];
        }else{
            return strings[0];
        }
    }
}