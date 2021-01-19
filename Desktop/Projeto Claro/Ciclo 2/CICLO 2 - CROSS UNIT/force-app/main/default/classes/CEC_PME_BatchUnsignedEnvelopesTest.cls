@isTest
public class CEC_PME_BatchUnsignedEnvelopesTest {
    
    @isTest
    public static void mainTest() {
        Database.executeBatch(new CEC_PME_BatchUnsignedEnvelopes(), 200); 
        new CEC_PME_BatchUnsignedEnvelopes().execute(null, new List<Order>());
    }
}