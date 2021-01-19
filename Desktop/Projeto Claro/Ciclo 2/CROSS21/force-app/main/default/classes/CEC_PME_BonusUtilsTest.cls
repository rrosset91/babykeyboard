@isTest
public class CEC_PME_BonusUtilsTest {

    @isTest
    static void getBonusByType() {
        
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        options.put('Convergencia',false);
        options.put('Type','Portabilidade');
        options.put('ProductId','01t2C000001T0CRQA0');
        CEC_PME_BonusUtils testedClass = new CEC_PME_BonusUtils();
        Test.startTest();
        testedClass.invokeMethod('getBonusByType',inputMap,outMap, options);
        Test.stopTest();
        
    }
    
    @isTest
    static void getBonusKit() {
        Map<String,Object> options = new Map<String, Object>();
        List<Object> listFranquias = new List<Object>();
		Map<String, Object> franquia = new Map<String, Object>();
        franquia.put('ProductId', 'ProductId');
        listFranquias.add(franquia);
        options.put('Franquias', listFranquias);
        new CEC_PME_BonusUtils().invokeMethod('getBonusKit', new Map<String, Object>(), new Map<String, Object>(), options);        
        new CEC_PME_BonusUtils().getBonusByAttributeDefaultValues('{\"ATT_PME_BonusValue\":\"4GB\"}');
        new CEC_PME_BonusUtils().getBonusByAttributeDefaultValues('');
    }
    
    
}