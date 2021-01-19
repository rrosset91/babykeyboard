/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Data: 03/06/2019  [Sprint 8]
--- Description: Classe responsável por resgatar ocorrências com erro e reprocessá-las 
-------------------------------------------------------------------------------------------------------*/
global class CEC_CC_ServiceLogSchedule implements Schedulable, Database.AllowsCallouts 
{  
    global void execute(SchedulableContext ctx){     
        requestOcurrency();        
        requestCreateProtocolMovel();
    }
    
    @future(callout=true)
    public static void requestOcurrency()
    {
        CEC_CC_ServiceLog ServiceLog;
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        else
            ServiceLog = new CEC_CC_ServiceLog();
        
        Set<Id> setCaseWithOcurrencyId = new Set<Id>();
        Set<Id> setLogsToDeleteWithRecordId = new Set<Id>();    
        List<ServiceLog__b> lstLogsToCreate = new List<ServiceLog__b>();
        List<ServiceLog__b> lstLogs = ServiceLog.getAllRecords(); 
        
        system.debug('Schedule >> lstLogs: ' + lstLogs);
        
        //Selecionar apenas ocorrências de entrada e saída para reprocessamento
        for(ServiceLog__b log : lstLogs){
            if(String.isNotBlank(log.NameService__c) && log.NameService__c.contains('Ocurrency'))
                setCaseWithOcurrencyId.add(log.RecordId__c);            
        }
        
        if(setCaseWithOcurrencyId.size() > 0){
            Map<Id, Case> mapPendingIntegCase = new Map<Id, Case>([SELECT Id, 
                                                                   LegacyProtocol__c, 
                                                                   Resolution__c,
                                                                   Description,
                                                                   Channel__c,
                                                                   Contract__c,
                                                                   RecordTypeId, 
                                                                   InteractionNumber__c,
                                                                   ProtocolNumber__c,
                                                                   ContractMSISDN__c
                                                                   FROM Case WHERE Id IN: setCaseWithOcurrencyId]);
            
            for(ServiceLog__b log : lstLogs){
                
                if(mapPendingIntegCase.containsKey(log.RecordId__c)){
                    Case objCase = mapPendingIntegCase.get(log.RecordId__c);
                    
                    try
                    {              
                        CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
                        ocurrencyInfo.caso = objCase;
                        ocurrencyInfo.typeOcurrency = log.Type__c;
                        ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
                        
                        CEC_OcurrencyNetResponse responseOcurrency = CEC_OcurrencyNetService.getResponse(ocurrencyInfo); 
                        setLogsToDeleteWithRecordId.add(log.RecordId__c);
                    }
                    catch(CEC_IntegrationException ex) //Treat Error Return
                    { 
                        CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();
                        
                        requestLog.detailMessage = ex.getMessage();
                        requestLog.errorMessage  = ex.errorMessage;
                        requestLog.errorCode     = ex.errorCode;
                        requestLog.httpCode      = ex.httpCode;
                        
                        //Index Detail
                        requestLog.objectId      = objCase.Id;
                        requestLog.nameService   = log.NameService__c;
                        requestLog.typeOcurrency = log.Type__c;
                        
                        CEC_CC_ServiceLog.ServiceLogResponse logResponse = new CEC_CC_ServiceLog().insertData(requestLog); 
                    }
                }
            }
            
            database.deleteImmediate([SELECT RecordId__c, Type__c FROM ServiceLog__b 
                                      WHERE RecordId__c IN: setLogsToDeleteWithRecordId ]);
        }
        
        scheduleNext();
    } 
    
    @future(callout=true)
    public static void requestCreateProtocolMovel ()
    {
        CEC_CC_ServiceLog ServiceLog;
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        else
            ServiceLog = new CEC_CC_ServiceLog();
        
        Set<Id> setCaseWithProtocolMovelId = new Set<Id>();
        Set<Id> setLogsToDeleteWithRecordId = new Set<Id>();    
        List<ServiceLog__b> lstLogsToCreate = new List<ServiceLog__b>();
        List<ServiceLog__b> lstLogs = ServiceLog.getAllRecords(); 
        
        system.debug('Schedule >> lstLogs: ' + lstLogs);
        
        //Selecionar apenas ocorrências de entrada e saída para reprocessamento
        for(ServiceLog__b log : lstLogs){
            if(String.isNotBlank(log.NameService__c) && log.NameService__c.contains('ProtocolMovelService'))
                setCaseWithProtocolMovelId.add(log.RecordId__c);            
        }
        
        if(setCaseWithProtocolMovelId.size() > 0){
            
            try
            {   
                createProtocolMovel(setCaseWithProtocolMovelId);
            }
            catch(CEC_IntegrationException ex) //Treat Error Return
            { 
            }
            
            
        }
        
        scheduleNext();
        
    }
    
    public static void scheduleNext()
    {
        if(!Test.isRunningTest()){
            List<CronTrigger> lstCronTrigger = [Select Id, CronJobDetail.Name From CronTrigger 
                                                WHERE CronJobDetail.Name LIKE 'CEC_CC_ServiceLogSchedule%'];
            for(CronTrigger cronTrigger : lstCronTrigger)
                system.abortJob(cronTrigger.Id);
        }
        
        Datetime newDate = Datetime.newInstanceGmt(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), System.now().minute(), System.now().second());         
        //newDate = newDate.addDays(1);
        newDate = newDate.addMinutes(30);
        
        String CRON_EXP =  '0 '+ newDate.minuteGmt() + ' ' + newDate.hourGmt() + ' ' + newDate.dayGmt() + ' ' + newDate.monthGmt() + ' ? ' + newDate.yearGmt();
        
        if(!Test.isRunningTest()){
            CEC_CC_ServiceLogSchedule newServiceLogSchedule = new CEC_CC_ServiceLogSchedule();
            System.schedule('CEC_CC_ServiceLogSchedule', CRON_EXP, newServiceLogSchedule);
        }
    }
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Squad: Canais Críticos 
--- Description: Geração de ocorrência na API do PS8 
---	Created: 05/02/2019
-------------------------------------------------------------------------------------------------------*/
    public static void createProtocolMovel(Set<Id> setCasesId) 
    {
        List<Case> lstCasesToUpdate = new List<Case>();
        Set<Id> setLogsToDeleteWithRecordId = new Set<Id>();
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        
        Map<Id, CEC_ProtocolNetResponse> mapResponseAPI = CEC_ProtocolMovelService.create(setCasesId); 
        
        for(Id caseId : setCasesId)
        {
            if(mapResponseAPI.containsKey(caseId)){
                CEC_ProtocolNetResponse responseAPI = mapResponseAPI.get(caseId);
                system.debug('CEC_CC_ServiceLogSchedule ## createProtocolMovel >> Response:  ' + responseAPI);
                
                if(responseAPI.error <> null){
                    CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();
                    requestLog.typeOcurrency = 'Resolution';
                    requestLog.detailMessage = responseAPI.error.detailedMessage;
                    requestLog.errorMessage  = responseAPI.error.message;
                    requestLog.errorCode     = responseAPI.error.errorCode;
                    requestLog.httpCode      = responseAPI.error.httpCode;
                    requestLog.objectId      = caseId;
                    requestLog.nameService   = 'ProtocolMovelService';
                    
                    CEC_CC_ServiceLog.ServiceLogResponse logResponse = ServiceLog.insertData(requestLog); 
                }
                else
                {
                    setLogsToDeleteWithRecordId.add(caseId);
                     lstCasesToUpdate.add(new Case(Id = caseId, 
                                                  LegacyProtocol__c = responseAPI.data.protocolNumber, 
                                                  InteractionNumber__c = responseAPI.data.interactionNumber, 
                                                  DateGenerationProtocolLegacy__c = Datetime.now()));
                }
            }
        } 
        // Apaga os registros de log que já foram reprocessados com sucesso.
        database.deleteImmediate([SELECT RecordId__c, Type__c 
                                  FROM ServiceLog__b 
                                  WHERE RecordId__c IN: setLogsToDeleteWithRecordId ]);
        
        // Atualiza casos com o protocolo do legado.
         if(lstCasesToUpdate.size() > 0){
            //CEC_CaseTriggerHandler.byPassValidation = true;
            update(lstCasesToUpdate);   
        } 
    }
    
}