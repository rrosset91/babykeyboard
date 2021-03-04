trigger CEC_GroupSetTrigger on Group_Set__c (before insert) {
    if (CEC_CatalogUtilities.isRunningInSandbox() || test.isRunningTest()){
        String currentDate = CEC_CatalogUtilities.getCurrentDate();
        String sandboxName = CEC_CatalogUtilities.getSandboxName();
        
        for(Group_Set__c pm : Trigger.new){
            if(pm.Chave__c == null){
                pm.Chave__c = CEC_CatalogUtilities.generateKey(currentDate, SandboxName);
                System.debug(pm.Chave__c);
            }
        }
	}
}