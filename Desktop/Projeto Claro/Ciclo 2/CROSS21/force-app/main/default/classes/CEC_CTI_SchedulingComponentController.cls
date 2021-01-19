/*
* Autor: Thamires Siman - Deloitte
* Data: 25/09/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Classe utilizada como controller da 
* VisualForce Component CEC_CTI_Scheduling]
*/


global class CEC_CTI_SchedulingComponentController {

    public Task dummyCustomObjectRecord
    {
        get
        {
            RecordType rctLembrete = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao'];
            if(dummyCustomObjectRecord==null)
                dummyCustomObjectRecord = new Task(RecordTypeId = rctLembrete.Id);
            return dummyCustomObjectRecord;
        }
        set;
    }
	
}