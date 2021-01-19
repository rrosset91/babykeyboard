/*
* Autor: Diogo Braga - Deloitte
* Data: 23/05/2019
* Schedulable auto agendável para eventos recorrentes
*  ---------------------------------------------------------------
*/ 
public class CEC_PME_ResizableHierarchy implements Schedulable {
    public class CEC_PME_ResizableException extends Exception{}
    
    public static final String HIERARCHY_ASSOCIATION = 'Hierarchy Association';
    
    private String jobName; 
    private Integer days = 0;
    private Integer hours = 1; //Default value 1h
    private Integer minutes = 0;
    private Boolean isReschebulable = false;

    
    public CEC_PME_ResizableHierarchy(Integer days, Integer hours, Integer minutes, Boolean isReschebulable) {
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.isReschebulable = isReschebulable;
        this.jobName = HIERARCHY_ASSOCIATION;
        validateConstructor();
    }
    
    public CEC_PME_ResizableHierarchy() {
        this.jobName = HIERARCHY_ASSOCIATION;
        validateConstructor();
    }
    
    private void validateConstructor() {
        if(days + hours + minutes <= 0) {
            throw new CEC_PME_ResizableException('Tempo de agendamento deve ser maior que 0');
        }
    }
    
    public void schedule() {
        String cronExp = buildCronExp(); 
        CEC_PME_ResizableHierarchy resizable = new CEC_PME_ResizableHierarchy(days, hours, minutes, isReschebulable);
        System.schedule(jobName + ' ' + isReschebulable + ' ' + cronExp, cronExp, resizable);
    } 
    
    private String buildCronExp() {
        DateTime nextExecution = System.now().addDays(days).addHours(hours).addMinutes(minutes);
        String cronExp = '' + nextExecution.second() + ' ' + nextExecution.minute();
        cronExp = cronExp + ' ' + nextExecution.hour() + ' ' + nextExecution.day();
        cronExp = cronExp + ' ' + nextExecution.month() + ' ? ' + nextExecution.year();

        return cronExp;
    }
    
    public void abortJobs() {
        String likeJobName = jobName + ' ' + isReschebulable + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :likeJobName];
        
        for(CronTrigger cronTrigger : listCronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }
    
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new CEC_PME_BatchHierarchy(), 1000);
        
        abortJobs();
        if(isReschebulable) {
            schedule();
        }
    }
    
    public static Boolean isScheduledLessNMinutes(Integer minutes) {
        String likeJobName = HIERARCHY_ASSOCIATION + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id, NextFireTime
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :likeJobName
                                              AND NextFireTime <= : System.now().addminutes(minutes)];
        
        return listCronTriggers != null && !listCronTriggers.isEmpty();
    }
}