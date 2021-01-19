/*
* Autor: Diogo Braga - Deloitte
* Data: 23/05/2019
* Schedulable auto agendável para eventos recorrentes
*  ---------------------------------------------------------------
*/
public class CEC_PME_Resizable implements Schedulable {
    public class CEC_PME_ResizableException extends Exception{}
    
    public static final String UNSIGNED_ENVELOPE = 'Unsigned envelope';
    public static final String SHARING_DOCUMENT = 'Sharing document';
    
    private String jobName; 
    private Integer days = 0;
    private Integer hours = 1; //Default value 1h
    private Integer minutes = 0;
    private Boolean isReschebulable = false;

    
    public CEC_PME_Resizable(Integer days, Integer hours, Integer minutes, Boolean isReschebulable, String jobName) {
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.isReschebulable = isReschebulable;
        this.jobName = jobName;
        validateConstructor();
    }
    
    public CEC_PME_Resizable(String jobName) {
        this.jobName = jobName;
        validateConstructor();
    }
    
    private void validateConstructor() {
        if(String.isBlank(jobName)) {
            throw new CEC_PME_ResizableException('jobName é um parâmetro obrigatório');
        }
        
        if(days + hours + minutes <= 0) {
            throw new CEC_PME_ResizableException('Tempo de agendamento deve ser maior que 0');
        }
    }
    
    public void schedule() {
        String cronExp = buildCronExp(); 
        CEC_PME_Resizable resizable = new CEC_PME_Resizable(days, hours, minutes, isReschebulable, jobName);
        System.schedule(jobName + ' ' + cronExp, cronExp, resizable);
    }
    
    private String buildCronExp() {
        DateTime nextExecution = System.now().addDays(days).addHours(hours).addMinutes(minutes);
        String cronExp = '' + nextExecution.second() + ' ' + nextExecution.minute();
        cronExp = cronExp + ' ' + nextExecution.hour() + ' ' + nextExecution.day();
        cronExp = cronExp + ' ' + nextExecution.month() + ' ? ' + nextExecution.year();

        return cronExp;
    }
    
    public void abortJobs() {
        String likeJobName = jobName + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :likeJobName];
        
        for(CronTrigger cronTrigger : listCronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
    
    public void execute(SchedulableContext schedulableContext) {
        if(jobName.equalsIgnoreCase(UNSIGNED_ENVELOPE)) {
            Database.executeBatch(new CEC_PME_BatchUnsignedEnvelopes(), 200); 
        } else if(jobName.equalsIgnoreCase(SHARING_DOCUMENT)){
            //Database.executeBatch(new CEC_PME_BatchShareDocument(), 50);
        }
        
        abortJobs();
        if(isReschebulable) {
            schedule();
        }
    }
}