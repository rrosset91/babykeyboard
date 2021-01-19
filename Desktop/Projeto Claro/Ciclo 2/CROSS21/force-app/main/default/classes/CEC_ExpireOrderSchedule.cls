/*
* Autor: Henrique Almeida
* Data: 11-mar-2018
* Descrição: Classe responsável por habilitar interface de agendamento para o batch CEC_ExpireOrderBatch.
*/
global class CEC_ExpireOrderSchedule implements Schedulable 
{
   global void execute(SchedulableContext sc) 
   {
      CEC_ExpireOrderBatch batch = new CEC_ExpireOrderBatch(); 
      database.executebatch(batch);
   }
}