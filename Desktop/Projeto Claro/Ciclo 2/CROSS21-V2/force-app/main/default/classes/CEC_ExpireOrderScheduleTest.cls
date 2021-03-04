/*
* Autor: Henrique Almeida
* Data: 11-mar-2018
* Descrição: Classe de teste responsável por testar a CEC_ExpireOrderSchedule
*/
@isTest
public class CEC_ExpireOrderScheduleTest 
{
	@isTest
    public static void unitTest()
    {
        CEC_ExpireOrderSchedule m = new CEC_ExpireOrderSchedule();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Expiration Job', sch, m);
    }
}