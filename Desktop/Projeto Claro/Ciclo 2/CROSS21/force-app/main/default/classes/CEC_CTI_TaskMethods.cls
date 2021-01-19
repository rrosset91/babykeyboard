public class CEC_CTI_TaskMethods {
	
    /*
    * Autor: Thamires Siman - Deloitte
    * Data: 08/10/2019
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Método que impede insert/update de ligações 
    * de agendamento de ligação, onde o horário do lembrete é passado.]
    */
    public static void validaHorarioRetroativo(List<Task> lstNewTask)
    {
        String rctLembrete = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao' AND sObjectType = 'Task'].Id;
        for(Task sObjTask : lstNewTask)
        {
            if(sObjTask.ReminderDateTime < System.now() && sObjTask.RecordTypeId == rctLembrete)
                sObjTask.addError('Erro: Selecione um horário de lembrete futuro.');
        }
    }
    
}