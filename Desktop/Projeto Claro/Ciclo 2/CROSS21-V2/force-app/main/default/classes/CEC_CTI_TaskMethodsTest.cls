/*
* Autor:Thamires Siman - Deloitte
* Data: 09/10/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Classe de teste utilizada para 
* validação de data de lembrete da tarefa
*/
@isTest
public class CEC_CTI_TaskMethodsTest {
    
    static testmethod void testeInsertUpdade()
    {
    	String rctLembrete = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao'].Id;    
        
        //Cria a tarefa com data/hora de lembrete futura
        Task valida = new Task();
        valida.ReminderDateTime = (System.now()).addDays(1);
        valida.RecordTypeId = rctLembrete;
        insert valida;
        
        //Atualiza a tarefa colocando data/hora passada, forçando a exceção
        valida.ReminderDateTime = (System.now()).addDays(-1);
        
        Test.startTest();
        	try
            {
        		update valida;
            }
        	catch(Exception ex)
            {
                System.assert(ex.getMessage().contains('Selecione um horário'));
            }
        
        System.debug(valida);
    }
}