/*
* Autor:Thamires Siman - Deloitte
* Data: 26/09/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Classe de teste utilizada para expurgo dos lembretes de ligação concluídos]
*/
@isTest
public class CEC_CTI_BatchDeleteCompletedTaskTest {
	
    /*
    * Autor: Thamires Siman - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [O método para testar o delete
    * dos lembretes de ligação concluídos]
    */
    static testmethod void testeDelete()
    {
        RecordType rctLembrete = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao'];
        
        Task tarefaAberta = new Task();
        tarefaAberta.RecordTypeId = rctLembrete.Id;
        insert tarefaAberta;
        
        List<TaskStatus> lstStatusFechado = [SELECT ApiName FROM TaskStatus WHERE isClosed = true];
        
        Task tarefaFechada = new Task();
        tarefaFechada.RecordTypeId = rctLembrete.Id;
        tarefaFechada.Status = lstStatusFechado[0].ApiName;
        insert tarefaFechada;
        
        System.debug(lstStatusFechado[0].ApiName);
        System.debug([SELECT Id, Subject, RecordTypeId, IsClosed, Status FROM Task]);
        
        test.startTest();
            Database.executeBatch(new CEC_CTI_BatchDeleteCompletedTask());
        test.stopTest();
        
        List<task> lstValidacao = [SELECT Id FROM Task];
        	System.assertEquals(lstValidacao.size(), 1);
    }
    
}