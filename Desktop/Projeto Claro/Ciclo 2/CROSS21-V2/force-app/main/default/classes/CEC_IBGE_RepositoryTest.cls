@isTest
public class CEC_IBGE_RepositoryTest {

    @isTest
    public static void mainTest() {
        try {
           new CEC_IBGE_Repository().getIBGEByCityNameAndDD(null, null); 
        } catch(Exception e) {
            
        }
    }
}