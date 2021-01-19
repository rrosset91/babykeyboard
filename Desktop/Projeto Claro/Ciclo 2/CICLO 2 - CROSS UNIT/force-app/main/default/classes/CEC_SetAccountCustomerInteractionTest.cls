@isTest
private class CEC_SetAccountCustomerInteractionTest

{ 
	static testMethod void createCustomerInterationTest() 
	{
		Account clientAccount	= new Account();
        clientAccount.Name		='Test Account';
        insert clientAccount;

		Test.StartTest(); 

		PageReference pageRef 	= Page.CEC_OmniScriptPage; 
		String accountId       	= pageRef.getParameters().put('accountId', String.valueOf(clientAccount.Id));
		String documentType     = pageRef.getParameters().put('accountDocNumber', '1111111111');
		String documentNumber   = pageRef.getParameters().put('accountDocType', '');
		String CEP         		= pageRef.getParameters().put('premisesCEP','04709110');
		String protocolNumber	= pageRef.getParameters().put('numProtocolo','111111111');
		
		Test.setCurrentPage(pageRef);
	
		CEC_SetAccountCustomerInteraction 	c = new CEC_SetAccountCustomerInteraction();
		c.initOmniscript();
	
		Test.StopTest();
	 }

	
}