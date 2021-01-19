/*
* Autor: Otávio Fonseca - Deloitte
* Data: 07/11/2019
* Classe para processamento da fila da carga aparelhos
*  ---------------------------------------------------------------
*/ 
public class CEC_PME_AttributeAssignment implements Schedulable {
    public class CEC_PME_AttributeAssignmentException extends Exception{}
    
    public static final String ATTRIBUTE_ASSIGNMENT = 'Attribute Assignment';
    
    private String jobName; 
    private Integer Days = 0;
    private Integer hours = 1; //Default value 1h
    private Integer minutes = 0;
    private Integer execHour = 0;
    private Integer execMinute = 0;
    private Boolean isStartHour = false;
    private Boolean isReschebulable = false;    
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Executa a validação dos dados informados no construtor
	*/      
    public CEC_PME_AttributeAssignment(Integer days, Integer hours, Integer minutes, Integer execHour, Integer execMinute, Boolean isStartHour, Boolean isReschebulable) {
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.execHour = execHour;
        this.execMinute = execMinute;
        this.isStartHour = isStartHour;
        this.isReschebulable = isReschebulable;
        this.jobName = ATTRIBUTE_ASSIGNMENT;
        validateConstructor();
    }    
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Execução do processo
	*/     
    public void execute(SchedulableContext schedulableContext) {
        runAssignment();
        
        abortJobs();
        if(isReschebulable) {
            schedule();
        }        
    }
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Como o processamento do método productAssignment é 50 registros, este método realiza a chamada
	* do método até que a fila não tenha mais nenhum aparelho para ser processado.
	*/      
    public static void runAssignment() {
        List<ProductIO__c> lstPrdIO = [SELECT Id
                                       FROM ProductIO__c
                                       WHERE Process_Completed__c = false];
        
        if(!lstPrdIO.isEmpty()) {
            CEC_PME_AttributeAssignmentJOB.productAssignment();
        } 
    }
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Valida se os dados para agendamento estão válidos
	*/      
    private void validateConstructor() {
        if(days + hours + minutes <= 0 && !(isStartHour)) {
            throw new CEC_PME_AttributeAssignmentException(Label.CEC_PME_AttributeAssignment_Erro);
        }
    }   
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Executa o agendamento do processo
	*/      
    public void schedule() {
        String cronExp = buildCronExp(); 
        CEC_PME_AttributeAssignment attAssgn = new CEC_PME_AttributeAssignment(days, hours, minutes, execHour, execMinute, isStartHour, isReschebulable);
        System.schedule(jobName + ' ' + cronExp, cronExp, attAssgn);
    }     
    
	/*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Converte a data informada em uma expressão Cron
	*/      
    private String buildCronExp() {
        DateTime nextExecution = System.now().addDays(days).addHours(hours).addMinutes(minutes);
       
        String cronExp = '0';
        if (isStartHour) {
        	cronExp = cronExp + ' ' + execMinute;         
        	cronExp = cronExp + ' ' + execHour;   
            isStartHour = false;           
        } else {
        	cronExp = cronExp + ' ' + nextExecution.minute();
        	cronExp = cronExp + ' ' + nextExecution.hour();                        
        }

        cronExp = cronExp + ' ' + nextExecution.day() + ' ' + nextExecution.month() + ' ? ' + nextExecution.year();

        return cronExp;
    } 
    
    /*
	* Autor: Otávio Fonseca - Deloitte
	* Descrição: Aborta processos agendados para execução
	*/      
    public void abortJobs() {
        String likeJobName = jobName + ' ' + '%';
        List<CronTrigger> listCronTriggers = [SELECT Id
                                              FROM CronTrigger
                                              WHERE CronJobDetail.Name LIKE :likeJobName];
        
        for(CronTrigger cronTrigger : listCronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }    
}