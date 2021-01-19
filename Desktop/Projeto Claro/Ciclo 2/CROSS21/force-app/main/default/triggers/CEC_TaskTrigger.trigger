/*
* Autor: Thamires Siman - Deloitte
* Data: 08/10/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Trigger para validação de tarefa]
*/
trigger CEC_TaskTrigger on Task (before insert, before update) {

    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
    		CEC_CTI_TaskMethods.validaHorarioRetroativo(trigger.new);        
        }
        else if(trigger.isUpdate)
        {
            CEC_CTI_TaskMethods.validaHorarioRetroativo(trigger.new);
        }
    }
    
    
}