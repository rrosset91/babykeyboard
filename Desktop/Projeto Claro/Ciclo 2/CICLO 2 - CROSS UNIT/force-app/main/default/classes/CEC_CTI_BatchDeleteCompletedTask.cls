/*
* Autor:Thamires Siman - Deloitte
* Data: 26/09/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Classe utilizada para expurgo dos lembretes de ligação concluídos]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 26/09/2019
* Autor: Thamires Siman - Deloitte
* Alterações: Criação da classe
*/
global class CEC_CTI_BatchDeleteCompletedTask implements Schedulable, Database.Batchable<sObject>{
    
    //AGENDAMENTO:
    /*
        CEC_CTI_BatchDeleteCompletedTask.startJob();
    */ 
    
   public static final String NOME_AGENDAMENTO = 'Expurgo de lembrete de ligação';
   public static final String EXPRESSAO = '0 0 0/1 1/1 * ? *'; //De hora em hora
    
   global void execute(SchedulableContext sc)
   {
       database.executeBatch(new CEC_CTI_BatchDeleteCompletedTask());
   } 
    
    // Método que faz o schedule desta classe no Salesforce
    public static void startJob()
    {
        system.debug('*** startJob()');
        system.schedule(NOME_AGENDAMENTO, EXPRESSAO, new CEC_CTI_BatchDeleteCompletedTask());
    }
    
   global Database.QueryLocator start(Database.BatchableContext BC){
      
       RecordType rctLembrete = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao'];
       
       String query = 'SELECT Id, Subject, RecordTypeId, IsClosed FROM Task WHERE IsClosed = true AND RecordTypeId = \'' + rctLembrete.Id + '\'';
       
       System.debug('query:' + query);
       
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Task> lstTask){

       System.debug('Excluir: ' + lstTask);
       
       delete lstTask;
       
    }

   global void finish(Database.BatchableContext BC){
   }    
    
}