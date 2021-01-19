global class CEC_ME_CallIntegrationProtocol implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            switch on methodName {
                when 'CreateProtocolNetService' {
                    String contractNumber = String.valueOf(options.get('NumeroContrato'));
                    String operatorCode = String.valueOf(options.get('CodigoOperadora'));
                    String accountId = String.valueOf(options.get('ContextId'));
                    Map<String, Object> auxMap = new Map<String, Object>();
                    Account conta = [SELECT ParentId FROM Account WHERE Id =: accountId];
                    List<vlocity_cmt__CustomerInteraction__c> interactions = [SELECT Id, ProtocolNumber__c, Document_Number__c
                                                                              FROM vlocity_cmt__CustomerInteraction__c
                                                                              WHERE vlocity_cmt__AccountId__c =: conta.ParentId
                                                                              ORDER BY CreatedDate DESC limit 1000];
                    if(interactions.size() > 0){
                        outMap.put('ProtocolNumber', interactions[0].ProtocolNumber__c);
                        outMap.put('CustomerInteractionId', interactions[0].Id);
                        outMap.put('InteractionNumber', interactions[0].Document_Number__c);
                    }else{
                        CEC_ProtocolNetResponse protocol = CEC_ProtocolNetService.getResponse(contractNumber, operatorCode);
                        String customerId = createCustomerInteraction(protocol.data.protocolNumber, protocol.data.interactionNumber, conta.ParentId);
                        outMap.put('ProtocolNumber', protocol.data.protocolNumber);
                        outMap.put('CustomerInteractionId', customerId);
                        outMap.put('InteractionNumber', protocol.data.interactionNumber);
                    }
                }
            }
            return true;
        }
        catch (Exception ex) {
            throw ex;
        }
    }
    
    public static String createCustomerInteraction(String protocolNumber, String interactionNumber, String accountId){
        vlocity_cmt__CustomerInteraction__c custInt = new vlocity_cmt__CustomerInteraction__c(ProtocolNumber__c = protocolNumber, 
                                                                                              Document_Number__c = interactionNumber,
                                                                                              vlocity_cmt__AccountId__c = accountId);
        insert custInt;
        return custInt.Id;
    }
}