@isTest
public class CEC_PME_AttributeAssignmentTest {
	@isTest
    public static void mainTest() {
        CEC_PME_AttributeAssignment attribAssignTest = new CEC_PME_AttributeAssignment(1, 0, 0, 0, 0, false, false);
        attribAssignTest.schedule();
        
        String filter = CEC_PME_AttributeAssignment.ATTRIBUTE_ASSIGNMENT + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :filter];
        System.assert(!listCronTriggers.isEmpty(), 'Não agendou');
        
        
        attribAssignTest.abortJobs();
        listCronTriggers = [SELECT Id
                            FROM CronTrigger
                            WHERE CronJobDetail.Name LIKE :filter];
        System.assert(listCronTriggers.isEmpty(), 'Não abortou agenda');
        
        attribAssignTest.execute(null);
    }
}