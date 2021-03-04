/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/07/2019
* Descrição: Classe responsável por gerar log de erro de integração
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 04/03/2020  
* Autor: Squad Canais Criticos
* Alterações: Substring no campo de DetailedMessage__c para evitar erro de STRING_TOO_LONG
* ---------------------------------------------------------------
*/
public class CEC_CC_ServiceLog { 
    
    public List<ServiceLog__b> getAllRecords()
    {
        return [SELECT Id, RecordId__c, NameService__c, Type__c, DetailedMessage__c, Message__c, ErrorCode__c, HttpCode__c FROM ServiceLog__b];
    }
    
    public ServiceLogResponse insertData(ServiceLogRequest requestLog)
    {
        return processData(requestLog);
    }

    public static ServiceLogResponse processData(ServiceLogRequest requestLog)
    {
        ServiceLog__b serviceLog = new ServiceLog__b();
        
        serviceLog.DetailedMessage__c 	= (requestLog.detailMessage.length() > 255) ? requestLog.detailMessage.subString(0,254) : requestLog.detailMessage;
        serviceLog.ErrorCode__c 		= requestLog.errorCode;
        serviceLog.HttpCode__c 			= requestLog.httpCode;
        serviceLog.Message__c 			= requestLog.errorMessage;
        serviceLog.NameService__c 		= requestLog.nameService;
        serviceLog.Type__c 				= requestLog.typeOcurrency;
        serviceLog.RecordId__c 			= requestLog.objectId;
       
        return saveData(serviceLog);
    }
    
    public static ServiceLogResponse saveData(ServiceLog__b serviceLog)
    {
        ServiceLogResponse resposeLog = new ServiceLogResponse();        
        Database.SaveResult saveResult;

        if(Test.isRunningTest()){
            resposeLog.isSuccess = true;
            resposeLog.msgError = 'Teste Mock';
        }
        else {
            saveResult = database.insertImmediate(serviceLog);  
            resposeLog.isSuccess = saveResult.isSuccess();
            for(Database.Error err : saveResult.getErrors()) 
                resposeLog.msgError  =+ err.getStatusCode() + ': ' + err.getMessage()  + '|' + err.getFields();
        }
        return resposeLog;
    }

    public class ServiceLogRequest 
    {
        public String detailMessage {get;set;}
        public String errorMessage 	{get;set;}  
        public String errorCode 	{get;set;}  
        public String httpCode		{get;set;}  
        public String typeOcurrency {get;set;}  
        public String nameService 	{get;set;}  
        public Id objectId 			{get;set;}  
    }  
    
    public class ServiceLogResponse
    {
        public Boolean isSuccess {get;set;}
        public String msgError 	 {get;set;}  
    }  
}