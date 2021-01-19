/*
* Autor: Marcos Aurélio - Deloitte
* Data: 28/02/2019
* Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
				[Time: SQUAD PME - Sprint 8]
				[Scheduler criado para o JOB CEC_PME_AttributeAssignmentJOB.]
****Script para configuração****

CEC_PME_AttributeAssignmentSCH className = new CEC_PME_AttributeAssignmentSCH();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String sch = '0 0 * * * ?';
String jobID = System.schedule('Attribute Assignment Schedule', sch, className);

Documentação dos parâmetros: https://developer.salesforce.com/docs/atlas.en-us.218.0.apexcode.meta/apexcode/apex_scheduler.htm
********************************
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

global class CEC_PME_AttributeAssignmentSCH implements Schedulable{
	global void execute(SchedulableContext SC) {
        CEC_PME_AttributeAssignmentJOB.productAssignment();
    }
}