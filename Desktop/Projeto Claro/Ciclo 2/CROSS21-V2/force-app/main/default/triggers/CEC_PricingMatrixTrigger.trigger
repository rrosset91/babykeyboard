trigger CEC_PricingMatrixTrigger on Pricing_Matrix__c (before insert) {
    if (CEC_CatalogUtilities.isRunningInSandbox() || test.isRunningTest()){
        String currentDate = CEC_CatalogUtilities.getCurrentDate();
        String sandboxName = CEC_CatalogUtilities.getSandboxName();
        
        for(Pricing_Matrix__c pm : Trigger.new){
            if(pm.Chave__c == null){
                pm.Chave__c = CEC_CatalogUtilities.generateKey(currentDate, SandboxName);
                System.debug(pm.Chave__c);
            }
        }
	}
}