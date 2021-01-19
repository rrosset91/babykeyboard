/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Description: Classe responsável por testar a geração de log de erro de integração 
-------------------------------------------------------------------------------------------------------*/
@isTest
public class CEC_CC_ServiceLogTest {
 
    @testSetup
    public static void setup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        Database.insert(varCase);           
    }    
    
    @isTest
    public static void testServiceLogRequest()
    {
       Case varCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest(); 
        
            CEC_CC_ServiceLog.ServiceLogRequest varServiceLog = new  CEC_CC_ServiceLog.ServiceLogRequest();
            varServiceLog.detailMessage = 'teste';
            varServiceLog.errorMessage = 'teste';
            varServiceLog.errorCode = 'teste';
            varServiceLog.httpCode = 'teste';
            varServiceLog.NameService = 'teste';
        	varServiceLog.typeOcurrency = 'teste';        
            varServiceLog.objectId = varCase.id;    
        
            CEC_CC_ServiceLog.ServiceLogResponse logResponse = new CEC_CC_ServiceLog().insertData(varServiceLog); 
        
        Test.stopTest();
        
        system.assertEquals(true, logResponse.isSuccess, 'Erro ao inserir log de serviço pelo mock');
    }  

    
    @isTest 
    public static void testGetAllRecords()
    {
        CEC_CC_ServiceLog mockServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        system.assert(mockServiceLog.getAllRecords().size() > 0, 'Erro na chamada mockada para getAllRecords');

		CEC_CC_ServiceLog cecServiceLog = new CEC_CC_ServiceLog();
        system.assert(cecServiceLog.getAllRecords().size() == 0, 'Erro na chamada sem mock para getAllRecords');
    }
    
    
    /******** Util **********/
    public static ServiceLog__b getNewRecord()
    {
        Case varCase = [SELECT Id FROM Case LIMIT 1];
        ServiceLog__b serviceLog = new ServiceLog__b();
        serviceLog.DetailedMessage__c = 'Erro Mensagem Teste';
        serviceLog.Message__c = 'Erro Mensagem Teste';
        serviceLog.ErrorCode__c = '999-999999';
        serviceLog.HttpCode__c = '500';
        serviceLog.NameService__c = 'CEC_OAG_NET_Ocurrency';
        serviceLog.Type__c = 'Open';        
        serviceLog.RecordId__c = varCase.id;   
        return serviceLog;
    }
}