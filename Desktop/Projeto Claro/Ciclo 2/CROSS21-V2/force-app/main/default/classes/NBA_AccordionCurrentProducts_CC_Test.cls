@isTest
private class NBA_AccordionCurrentProducts_CC_Test {

    static {
        NBA_DataFactory_Test.loadData();
    }
    
    
    @isTest public static void returnAccordion() {
        
        List<Case> lstCase = [SELECT Id FROM Case];

		System.debug(lstCase);

		List<Contract> lstContract = [SELECT Id FROM Contract];

		System.debug('lstContract: ' + lstContract);

		lstCase[0].ContractNumber__c = lstContract[0].Id;

        Test.startTest();
        List<Asset> lstRetorno = NBA_AccordionCurrentProducts_CC.lista(lstCase[0].Id);
        System.assertNotEquals(0, lstRetorno.size());
        Test.stopTest();
    }
    
    @isTest public static void returnHeader(){
        List<Case> lstCase = [SELECT Id FROM Case];

        Test.startTest();
        NBA_AccordionCurrentProducts_CC.HeaderContrato header = NBA_AccordionCurrentProducts_CC.initContract(lstCase[0].Id);
        System.assertEquals(true, header.hasTV);
        System.assertEquals('Account A', header.nameAccount);
        Test.stopTest();
    }
    
}