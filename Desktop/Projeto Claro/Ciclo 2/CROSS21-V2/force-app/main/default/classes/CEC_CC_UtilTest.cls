/*
* Data: 16/11/2020    
* Autor: Squad Canais Criticos
* Alterações: Inclusão de metodos de teste para a classe CEC_CC_Util.
* ---------------------------------------------------------------
*/
@isTest 
public class CEC_CC_UtilTest {
    
    @isTest 
    private static void testGetPicklistValueByLabel()
    {
        Test.startTest();
        map<String, String> mapStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Status');
        Test.stopTest();
        System.assertEquals(true, mapStatusPickValByLabel.values().size() > 0, 'Erro ao selecionar infos do picklist de status de caso');
    }
    
    @isTest 
    private static void testGetRecordTypeInfoByObj()
    { 
        Test.startTest();
        	Map<String,Id> mapRTDeveloperNameId = CEC_CC_Util.getRecordTypeInfoByObj('Case');
        Test.stopTest();
        System.assertEquals(true, mapRTDeveloperNameId.values().size() > 0, 'Erro ao selecionar infos do tipo de registro de caso');
    }
    
    @isTest 
    private static void testGetEntitlementByArea()
    { 
        List<CEC_CC_Entitlement__c> lstConfigSLA = new List<CEC_CC_Entitlement__c>();
        lstConfigSLA.add(CEC_SObjectFactory.getCSEntitlement('TESTE','TESTE','TESTE'));
        insert lstConfigSLA;
        
        Test.startTest();
        	Map<String, String> mapCSEntitlementByArea = CEC_CC_Util.getCSEntitlementByArea();
        Test.stopTest();
        
        System.assertEquals(true, mapCSEntitlementByArea.containsKey('TESTE'), 'Erro ao selecionar infos no custom setting de direitos');
    	
	}  
    
    @isTest 
    private static void testIsSemaphored()
    { 
        Test.startTest();
        	Boolean isSemaphoredF = CEC_CC_Util.isSemaphored('343243434343', 'Case');
        	Boolean isSemaphoredT = CEC_CC_Util.isSemaphored('343243434343', 'Case');
        Test.stopTest();
        
        system.assertEquals(false, isSemaphoredF, 'Erro no método de duplicidade de execução (isSemaphored)');
        system.assertEquals(true, isSemaphoredT, 'Erro no método de duplicidade de execução (isSemaphored)');
    }
    
    @isTest 
    private static void testGetAllCecRtByObj()
    { 
        Test.startTest();
        	Set<Id> setRecordTypeId = CEC_CC_Util.getAllCecRtByObj('Case');
        Test.stopTest();
        System.assertEquals(true, setRecordTypeId.size() > 0, 'Erro ao selecionar infos do tipo de registro de caso');
    }

    @isTest 
    private static void testGetUnifiedChannels()
    { 
        Test.startTest();
            List<CEC_CC_Util.UnifiedChannel> unifiedChannels = CEC_CC_Util.getUnifiedChannels();
        Test.stopTest();
        System.assertEquals(true, unifiedChannels != null && unifiedChannels.size() > 0, 'Erro ao buscar a lista de canais unificados');
    }    

    @isTest 
    private static void testGetUnifiedChannelByCase()
    { 
        Test.startTest();
            Case caseItem = new Case(Channel__c = 'CIP', Grouping__c = 'Procon', BusinessUnit__c = 'Claro DTH', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId());
            System.debug('testGetUnifiedChannelByCase');
            System.debug(caseItem);
            CEC_CC_Util.UnifiedChannel unifiedChannel = CEC_CC_Util.getUnifiedChannelByCase(caseItem);
        Test.stopTest();
        System.assertEquals(true, unifiedChannel != null, 'Erro ao buscar a configuracao de canal unificado para o CIP');
    }        
    
    @isTest 
    private static void testGetQueue()
    { 
        Test.startTest();
            Map<String, Id> queue = CEC_CC_Util.getQueue(new Set<String> {'ATENDIMENTO_COLABORADOR_ADESAO'});
        Test.stopTest();
        System.assertEquals(true, queue != null, 'Erro ao buscar de filas a partir de um nome');
    }     

    @isTest 
    private static void testSortSet()
    { 
        Test.startTest();
            Set<String> values = new Set<String> {'C','B','A'};
            values = CEC_CC_Util.sortSet(values);
        Test.stopTest();
        System.assertEquals(true, values.iterator().next() == 'A', 'O set não foi ordenado corretamente');
    }         
}