public class CEC_PME_ScheduleLimiteExp implements Schedulable{
    
    //executar trabalho agendado
    public void execute(SchedulableContext sc) {      
        Database.executeBatch(new CEC_PME_BatchLimiteExpOpp(), 200);
        Database.executeBatch(new CEC_PME_BatchLimiteExpOrder(), 200);
        
        /*Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        if (jobCount <= 3){
            String developerName = 'LimiteExpiracao';
            //batch para simulação
            Database.executeBatch(new CEC_PME_BatchLimiteExpOpp(CEC_PME_UtilsLimiteExpiracao.getOppParams(developerName)), 200);
            //batch para pedidos
            Database.executeBatch(new CEC_PME_BatchLimiteExpOrder(), 200);
        }else{
            reScheduleLimiteExp();
        } */       
    }
    
    /*public String reScheduleLimiteExp(){
        CEC_PME_ScheduleLimiteExp sc = new CEC_PME_ScheduleLimiteExp();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        return System.Schedule('RETRY - Agendado limite expiração'+timeForScheduler, timeForScheduler, sc);
    }*/
}