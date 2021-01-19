@isTest
public class CEC_PME_UtilsLimiteExpiracaoTest {
    @isTest static void testGetOppParams(){
        Map<String, Object> params = CEC_PME_UtilsLimiteExpiracao.getOppParams('LimiteExpiracao');
        System.assert(params != null, 'Metadado customizado não encontrado no pacote ou organização: ConfigLimiteExpiracao__mdt');
        List<String> lstStatus = (List<String>)params.get('status');
        System.assert(lstStatus.size() > 0);
        List<String> lstProfiles = (List<String>)params.get('profiles');
        System.assert(lstProfiles.size() > 0);
        Integer days = (Integer)params.get('days');
        System.assert(days != null);
        Date expDate = (Date)params.get('expDate');
        System.assert(expDate != null);
        Date expDateProfile = (Date)params.get('expDateProfile');
        System.assert(expDateProfile != null);
    }
    
    @isTest static void testGetOrderParams(){
        Map<String, Object> params = CEC_PME_UtilsLimiteExpiracao.getOrderParams('LimiteExpiracao');
        System.assert(params != null, 'Metadado customizado não encontrado no pacote ou organização: ConfigLimiteExpiracao__mdt');
        List<String> lstStatus = (List<String>)params.get('status');
        System.assert(lstStatus.size() > 0);
        List<String> lstProfiles = (List<String>)params.get('profiles');
        System.assert(lstProfiles.size() > 0);
        Integer days = (Integer)params.get('days');
        System.assert(days != null);
        Date expDate = (Date)params.get('expDate');
        System.assert(expDate != null);
        Date expDateProfile = (Date)params.get('expDateProfile');
        System.assert(expDateProfile != null);
    }
    
    @isTest static void getLimiteExpTest() {
        Test.startTest();
        List<Limite_Expiracao__mdt> lstExpiracao = CEC_PME_UtilsLimiteExpiracao.getLimiteExp();
        Test.stopTest();
        System.assert(lstExpiracao.size() > 0);
    }
    
    @isTest static void getLimiteStatusTest() {
        Test.startTest();
        Set<String> setStatus = CEC_PME_UtilsLimiteExpiracao.getLimiteStatus('Pedido');
        Test.stopTest();
        System.assert(setStatus.size() > 0);        
    }
    
    @isTest static void ultimoDia() {
        Test.startTest();
        Date data = CEC_PME_UtilsLimiteExpiracao.ultimoDiaMes();
        Test.stopTest();
        System.assertNotEquals(null, data);        
    }    
    
    @isTest static void getLimiteExpSegTest() {
        Test.startTest();
        List<Limite_Expiracao__mdt> lstExpiracao = CEC_PME_UtilsLimiteExpiracao.getLimiteExpSeg();
        Test.stopTest();
        System.assert(lstExpiracao.size() > 0);        
    }
}