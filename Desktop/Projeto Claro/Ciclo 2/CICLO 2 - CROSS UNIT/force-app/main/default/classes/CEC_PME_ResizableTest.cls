@isTest
public class CEC_PME_ResizableTest {
	
    @isTest
    public static void mainTest() {
        CEC_PME_Resizable resizableTest = new CEC_PME_Resizable(CEC_PME_Resizable.UNSIGNED_ENVELOPE);
        resizableTest.schedule();
        
        String filter = CEC_PME_Resizable.UNSIGNED_ENVELOPE + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :filter];
        System.assert(!listCronTriggers.isEmpty(), 'Não agendou');
        
        
        resizableTest.abortJobs();
        listCronTriggers = [SELECT Id
                            FROM CronTrigger
                            WHERE CronJobDetail.Name LIKE :filter];
        System.assert(listCronTriggers.isEmpty(), 'Não abortou agenda');
        
        resizableTest.execute(null);
    }
    
    
}