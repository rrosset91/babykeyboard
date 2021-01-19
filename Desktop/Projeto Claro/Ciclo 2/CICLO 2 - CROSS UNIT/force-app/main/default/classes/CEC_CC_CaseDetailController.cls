public class CEC_CC_CaseDetailController 
{
    public CEC_CC_CaseDetailController(){}
    
    @AuraEnabled
    public static Case GetCase(String caseId) 
    {
        return [SELECT Id, RejectAmount__c, RejectDescription__c, RecordTypeId,
                Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c , 
                Status, SubStatus__c
                FROM Case 
                WHERE Id = : caseId 
                LIMIT 1];
    }
    
     @AuraEnabled
    public static Map<String,Id>  getRecordTypeDetail(String varObj) 
    {
        Map<String,Id> mapRecordTypeDeveloperNameId = CEC_CC_Util.getRecordTypeInfoByObj(varObj); 
        return mapRecordTypeDeveloperNameId;
    }
    
    @AuraEnabled
    public static CEC_CC_CaseDetailController.Wrapperclass RequestReject(Case varCase) 
    {
        Wrapperclass ret = new Wrapperclass();
        Database.SaveResult saveResult;
        Approval.ProcessResult processResult;
        
        Date dateNow = Date.today();
        Datetime validateDate = Datetime.now();
        
        validateDate = varCase.OpenDateRobot__c.addDays(7);
        
        if(validateDate < dateNow)
        {
            System.debug('Prazo para solicitar recusa expirado!');
            ret.message = 'Prazo expirado para pedido de Recusa!';
            ret.status = 'warning';
            ret.title = 'RECUSA';
            return ret;
        }
        
        List<ProcessInstance> obj =	[SELECT Status, CreatedDate, CompletedDate, TargetObjectId 
                                     FROM ProcessInstance 
                                     WHERE TargetObjectId =: varCase.Id
                                     AND Status = 'Pending'	];
        
        System.debug('ProcessInstance: '+ obj);
        System.debug('obj.isEmpty(): '+ obj.isEmpty());
        
        if(obj.isEmpty())
        {
            System.debug('UpdateCase: '+ saveResult);
            
            saveResult = UpdateCase(varCase);
            
            System.debug('saveResult: '+ saveResult);
            
            if(saveResult.isSuccess())
            {
                processResult = RejectApprovalsSubimt(varCase);
                
                System.debug('processResult: '+ processResult);
                
                if(processResult.isSuccess())
                {
                    ret.message = 'Recusa Solicitada com sucesso';
                    ret.status = 'success';
                    ret.title = 'RECUSA';    
                }
                else
                {
                    ret.message = 'Erro na solicitação de aprovação da recusa';
                    ret.status = 'error';
                    ret.title = 'RECUSA';
                }
            }
            else
            {
                ret.message = 'Erro na atualização do caso';
                ret.status = 'error';
                ret.title = 'RECUSA';
            }
            
        }else
        {
            ret.message = 'Já existe uma solicitação de recusa para aprovação';
            ret.status = 'warning';
            ret.title = 'RECUSA';
        }
        
        return ret;
    }
    
    private static Database.SaveResult UpdateCase(Case varCase)
    {
        Database.SaveResult result = Database.update(varCase);
        return result;
    }
    
    private static Approval.ProcessResult RejectApprovalsSubimt(Case varCase)
    {
        System.debug('>> RejectApprovalsSubimt');
        Approval.ProcessResult result;
        
        try
        {
            Approval.ProcessSubmitRequest requestProcess = new Approval.ProcessSubmitRequest();
            requestProcess.setComments(varCase.RejectDescription__c);
            requestProcess.setObjectId(varCase.id);
            requestProcess.setProcessDefinitionNameOrId('CEC_CC_RequestReject');
            result = Approval.process(requestProcess);
        }
        catch(Exception ex)
        {
            System.debug('>> ex: '+ex);
            throw ex;
        }
        
        return result;
    }
    
    public class Wrapperclass{
        @AuraEnabled public String title	{get;set;}
        @AuraEnabled public String status	{get;set;}
        @AuraEnabled public String message	{get;set;}  
    }
}