@isTest
public class CEC_PME_FromToUtilTest {

    @isTest
    public static void mainTest() {
        CEC_PME_FromToUtil fromTo = new CEC_PME_FromToUtil('SignatureType');
        System.assert(!fromTo.hasTo(''));
        
        
        try {
            fromTo.getTo('');
        } catch (CEC_PME_FromToUtil.CEC_PME_FromToException e) {
            System.assert(e != null);
        }
        
    }
}