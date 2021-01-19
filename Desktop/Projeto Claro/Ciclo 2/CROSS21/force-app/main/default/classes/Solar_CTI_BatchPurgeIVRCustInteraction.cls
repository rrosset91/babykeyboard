/*
    * Autor: Wanderson Viena - Deloitte
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI - Semana 3] + [92254 - CTI - 
    * CRM CROSS - PROTOCOLO URA RESIDENCIAL + 92255 CTI - CRM CROSS - PROTOCOLO URA MÓVEL + 
    * 92248 CTI - CRM CROSS - SCRIPT POINT NAVEGAÇÃO URA RESIDENCIAL]
    * Classe Batch que deleta todos os registros de Customer Interaction com Recordtype DadosURA que foram criados no dia
    * anterior e não possuem um Customer Interaction Topic como filho.
*/
     
global without sharing class Solar_CTI_BatchPurgeIVRCustInteraction implements Schedulable, Database.Stateful, Database.Batchable<SObject>
//public class Solar_CTI_BatchPurgeIVRCustInteraction 
{
    //global static Boolean isTestingError = false;
    //global list<LogUser__c> lLstLogUsr;
    
    public static final String NOME_AGENDAMENTO = 'Deletar Customer Interaction';
    public static final String EXPRESSAO = '0 00 03 ? * MON,TUE,WED,THU,FRI,SAT,SUN *'; //Diariamente as 03h e 00m
    
    public Datetime startDate;
    public Datetime endDate;  
	 //AGENDAMENTO DIARIO:
    /*
        Solar_CTI_BatchPurgeIVRCustInteraction.startJob();
    */ 
    
    //EXECUCAO COM DATA ESPECIFICA
    /*
     	Passando como parametro data inicial e final no formato YYYY-MM-DD, como exemplo abaixo;
      	Database.executeBatch(new Solar_CTI_BatchPurgeIVRCustInteraction('2020-07-31', '2020-12-31'));
    */ 
   public Solar_CTI_BatchPurgeIVRCustInteraction(String startDate, String endDate)
    {
        Datetime lToday = Datetime.newInstance(system.today(), Time.newInstance(0, 0, 0, 0)),
      	lYesterday = lToday.addDays(-2);
        //if ()
        if (String.isNotBlank(startDate)){
            Datetime dt = (DateTime)JSON.deserialize('"' + startDate + '"', DateTime.class);
        	this.startDate = dt;
            system.debug('startDate =>' + this.startDate);
        }else {
            this.startDate = lYesterday;
            system.debug('startDate =>' + this.startDate);
        }
        //
        if (String.isNotBlank(endDate)){
            Datetime dt = (DateTime)JSON.deserialize('"' + endDate + '"', DateTime.class);
            this.endDate = dt;
            system.debug('endDate =>' + this.endDate);
         }else {
            this.endDate = lToday;
           	system.debug('endDate =>' + this.endDate);
        }       	
    }
    //Metodo que faz o agendamento da classe no SF
    public static void startJob()
    {
        system.debug('*** startJob()');
        system.schedule(NOME_AGENDAMENTO, EXPRESSAO, new Solar_CTI_BatchPurgeIVRCustInteraction(null, null));
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        
        String query = 'SELECT Id, Name, RecordTypeId, CreatedDate FROM vlocity_cmt__CustomerInteraction__c WHERE RecordTypeId = \'' + idRecordId + '\' AND (CreatedDate >=: startDate AND CreatedDate <=: endDate)';
           query = query + ' AND Id NOT IN (SELECT vlocity_cmt__CustomerInteractionId__c FROM vlocity_cmt__CustomerInteractionTopic__c)'; 
             
       System.debug('query:' + query);
       
       return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext sc)
    {
        database.executeBatch(new Solar_CTI_BatchPurgeIVRCustInteraction(null, null));
    }
    
    global void execute(Database.BatchableContext BC, List<vlocity_cmt__CustomerInteraction__c> lstCustomerInteraction){
       
       System.debug('Excluir: ' + lstCustomerInteraction);
        
       delete lstCustomerInteraction;
       DataBase.emptyRecycleBin(lstCustomerInteraction);
        
       
   }
   global void finish(Database.BatchableContext BC){
   }  
    //*/
    /*public void Solar_CTI_BatchPurgeIVRCustInteraction(){
     system.debug('startJob');   
    }*/
     
}