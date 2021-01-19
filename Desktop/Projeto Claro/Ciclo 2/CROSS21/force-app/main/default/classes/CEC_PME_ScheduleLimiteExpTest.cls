@isTest
public class CEC_PME_ScheduleLimiteExpTest {
    @isTest static void testExecute(){
        
        Test.startTest();
        CEC_PME_ScheduleLimiteExp sc = new CEC_PME_ScheduleLimiteExp();
        Datetime dt = Datetime.now().addMinutes(5);  // i.e. 5 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        String jobId = System.Schedule('Trabalho Agendado limite expiração'+timeForScheduler, timeForScheduler, sc);
        
        //deve retorntar o id do job
        System.assert(String.isNotEmpty(jobId), 'Falha ao agendar a classe CEC_PME_ScheduleLimiteExp');
        
        CronTrigger ct = [SELECT Id, CronExpression
                          FROM CronTrigger WHERE id = :jobId];
        
        //trabalho agendado
        System.assert(ct != null, 'Não foi encontrado o trabalho agendado CEC_PME_ScheduleLimiteExp');     
        System.assert(timeForScheduler == ct.CronExpression);
        Test.stopTest();
    }
    
    /*@isTest static void testReSchedule(){
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        CEC_PME_ScheduleLimiteExp sc = new CEC_PME_ScheduleLimiteExp();
        String jobId  = sc.reScheduleLimiteExp();
        //deve retorntar o id do job
        System.assert(String.isNotEmpty(jobId), 'Falha ao reagendar a classe CEC_PME_ScheduleLimiteExp');
        CronTrigger ct = [SELECT Id, CronExpression
                          FROM CronTrigger WHERE id = :jobId];
        //trabalho agendado
        System.assert(ct != null, 'Não foi encontrado o reagendamento CEC_PME_ScheduleLimiteExp');
        System.assert(timeForScheduler == ct.CronExpression);
        Test.stopTest();
    }*/
}