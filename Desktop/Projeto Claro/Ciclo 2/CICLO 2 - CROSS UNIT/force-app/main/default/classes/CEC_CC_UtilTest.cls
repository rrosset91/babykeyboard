@isTest public class CEC_CC_UtilTest {
    
    @isTest public static void testGetPicklistValueByLabel()
    {
        Test.startTest();
        map<String, String> mapStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Status');
        Test.stopTest();
        System.assertEquals(true, mapStatusPickValByLabel.values().size() > 0, 'Erro ao selecionar infos do picklist de status de caso');
    }
    
    @isTest public static void testGetRecordTypeInfoByObj()
    { 
        Test.startTest();
        	Map<String,Id> mapRTDeveloperNameId = CEC_CC_Util.getRecordTypeInfoByObj('Case');
        Test.stopTest();
        System.assertEquals(true, mapRTDeveloperNameId.values().size() > 0, 'Erro ao selecionar infos do tipo de registro de caso');
    }
    
    @isTest public static void testGetEntitlementByArea()
    { 
        List<CEC_CC_Entitlement__c> lstConfigSLA = new List<CEC_CC_Entitlement__c>();
        lstConfigSLA.add(CEC_SObjectFactory.getCSEntitlement('TESTE','TESTE','TESTE'));
        insert lstConfigSLA;
        
        Test.startTest();
        	Map<String, String> mapCSEntitlementByArea = CEC_CC_Util.getCSEntitlementByArea();
        Test.stopTest();
        
        System.assertEquals(true, mapCSEntitlementByArea.containsKey('TESTE'), 'Erro ao selecionar infos no custom setting de direitos');
    	
	}  
    
    @isTest public static void testIsSemaphored()
    { 
        Test.startTest();
        	Boolean isSemaphoredF = CEC_CC_Util.isSemaphored('343243434343', 'Case');
        	Boolean isSemaphoredT = CEC_CC_Util.isSemaphored('343243434343', 'Case');
        Test.stopTest();
        
        system.assertEquals(false, isSemaphoredF, 'Erro no método de duplicidade de execução (isSemaphored)');
        system.assertEquals(true, isSemaphoredT, 'Erro no método de duplicidade de execução (isSemaphored)');
    }
    
    @isTest public static void testGetAllCecRtByObj()
    { 
        Test.startTest();
        	Set<Id> setRecordTypeId = CEC_CC_Util.getAllCecRtByObj('Case');
        Test.stopTest();
        System.assertEquals(true, setRecordTypeId.size() > 0, 'Erro ao selecionar infos do tipo de registro de caso');
    }

}