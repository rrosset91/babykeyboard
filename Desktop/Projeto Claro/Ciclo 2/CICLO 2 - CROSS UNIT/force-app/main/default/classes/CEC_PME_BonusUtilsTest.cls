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
    
    
}