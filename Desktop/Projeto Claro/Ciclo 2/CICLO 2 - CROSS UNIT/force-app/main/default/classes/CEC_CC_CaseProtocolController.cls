/*-----------------------------------------------------------------------------------------------------
	--- Company: Deloitte Brazil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela geração e exibição de protocolo. 
	---	Created: 12/09/2018
	-------------------------------------------------------------------------------------------------------*/
public with sharing class CEC_CC_CaseProtocolController 
{       
    public void CEC_CC_CaseProtocolController() {}
    
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectType, String selectedField)
    {
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectType).getDescribe().fields.getMap(); 
        List<Schema.PicklistEntry> picklistValues = field_map.get(selectedField).getDescribe().getPickListValues();     
        List<String> lstoption = new List<String>(); 
        
        for (Schema.PicklistEntry pickListValue : picklistValues) {
            lstoption.add(pickListValue.getValue());
        }
        return lstoption;
    }
    
    @AuraEnabled
    public static List<Object> updateProtocol(Case objCaseParameter)
    {
        //-----Msg e status alert componet
        String msg = '';//'O campo protocolo precisa ser preenchido!';
        String msgStatus = '';//error';
        
        List<Object> lstProtocols   = new List<Object>();
        List<Case>   lstCase        = new List<Case>();
        List<Case>   lstSelectCase  = [SELECT Id,CriticalChannelProtocol__c, DateGenerationProtocolLegacy__c, 
                                       LegacyProtocol__c, Grouping__c,CreatedDate, BusinessUnit__c,LastModifiedDate,
                                       RecordTypeId, ParentId, Parent.CriticalChannelProtocol__c, Parent.Grouping__c, Parent.CreatedDate, Parent.LegacyProtocol__c
                                       FROM Case  
                                       WHERE id =: objCaseParameter.Id];
        
        //-----Verificação dos parametros
        if(!String.isBlank(objCaseParameter.LegacyProtocol__c))
        {         
            for(Case varCase : lstSelectCase) 
            {
                if(varCase.LegacyProtocol__c == null)
                {
                    varCase.BusinessUnit__c = lstSelectCase[0].BusinessUnit__c;
                    varCase.LegacyProtocol__c = objCaseParameter.LegacyProtocol__c;
                    
                    if(varCase.DateGenerationProtocolLegacy__c == null)
                    {
                        varCase.DateGenerationProtocolLegacy__c = System.now();
                    }
                    
                    lstCase.add(varCase);  
                }
            }    
            
            if(!lstCase.isEmpty())
            {                
                Database.update(lstCase); 
                msg = 'Protocolo gerado com sucesso!';
                msgStatus = 'success'; 
            }
            else{
                msg = 'Protocolo já existe';
                msgStatus = 'warning'; 
            }
        }        
        
        Map<String, Id> mapDevNameRecType = CEC_CC_Util.getRecordTypeInfoByObj('Case');
        
        //-----Foreach da tela de protocol
        for(Case lCase : lstSelectCase)
        {            
            EntidadeProtocol caseProtocolChannel = new EntidadeProtocol();
            
            if(mapDevNameRecType.get('CEC_CC_SuporteApoio') == lCase.RecordTypeId ||
               mapDevNameRecType.get('CEC_CC_ReaberturaAnatel') == lCase.RecordTypeId 
               && lCase.ParentId <> null){
                caseProtocolChannel.protocolo = lCase.Parent.CriticalChannelProtocol__c;
                caseProtocolChannel.sistema = lCase.Parent.Grouping__c;           
                caseProtocolChannel.dataProtocol =  lCase.Parent.CreatedDate;
            }
            else{
                caseProtocolChannel.protocolo = lCase.CriticalChannelProtocol__c;
                caseProtocolChannel.sistema = lCase.Grouping__c;           
                caseProtocolChannel.dataProtocol =  lCase.CreatedDate;
            }
            
            caseProtocolChannel.msgProtocol = msg;
            caseProtocolChannel.msgStatus = msgStatus;
            
            lstProtocols.add(caseProtocolChannel);
            
            if(lCase.LegacyProtocol__c != null)
            {
                EntidadeProtocol caseProtocolLegado = new EntidadeProtocol();
                caseProtocolLegado.protocolo = lCase.LegacyProtocol__c;
                caseProtocolLegado.sistema = lCase.BusinessUnit__c;
                caseProtocolLegado.dataProtocol = lCase.DateGenerationProtocolLegacy__c;
                caseProtocolLegado.msgProtocol = '';   
                caseProtocolLegado.msgStatus = '';
                lstProtocols.add(caseProtocolLegado);                
            }                           
        }      
        
        return lstProtocols;
    }
    
    @AuraEnabled
    public static String updateCaseLegacy(Case objCaseParameter)
    {
        if(String.isBlank(objCaseParameter.LegacyProtocol__c) || String.isEmpty(objCaseParameter.LegacyProtocol__c))
        {
            return 'O campo protocolo precisa ser preenchido!';
        }
        
        List<Case> lstCase = new List<Case>();
        for(Case varCase : [SELECT Id, LegacyProtocol__c, BusinessUnit__c FROM Case WHERE Id = : objCaseParameter.Id]) 
        {
            varCase.LegacyProtocol__c   = objCaseParameter.LegacyProtocol__c;
            lstCase.add(varCase);
        }
        
        if(!lstCase.isEmpty())
        {
            Database.update(lstCase);
            return 'Protocolo ' + lstCase[0].LegacyProtocol__c + ' gerado com sucesso!';
        }
        else
        {
            return 'Protocolo já existe!';
        }
    }
    
    @AuraEnabled
    public static List<Object> getProtocolSaveProcolCase(Case objCaseParameter){
        return updateProtocol(objCaseParameter);  
    }
    
    @AuraEnabled
    public static List<Object> getProtocolCase(Id arecordId)  
    {
        Map<String, Id> mapDevNameRecType = CEC_CC_Util.getRecordTypeInfoByObj('Case');
        List<Object> lstProtocols = new List<Object>();
        List<Case> lstCase =  [SELECT Id, DateGenerationProtocolLegacy__c, CriticalChannelProtocol__c, Grouping__c, CreatedDate, LegacyProtocol__c, BusinessUnit__c, LastModifiedDate,
                               RecordTypeId, ParentId, Parent.CriticalChannelProtocol__c, Parent.Grouping__c, Parent.CreatedDate, Parent.LegacyProtocol__c                               
                               FROM Case  WHERE id =:arecordId];
        
        for(Case varCase : lstCase)
        {
            EntidadeProtocol caseProtocolChannel = new EntidadeProtocol();
            caseProtocolChannel.protocolo = varCase.CriticalChannelProtocol__c;
            caseProtocolChannel.sistema = varCase.Grouping__c;           
            caseProtocolChannel.dataProtocol =  varCase.CreatedDate;   
            
            if(mapDevNameRecType.get('CEC_CC_SuporteApoio') == varCase.RecordTypeId ||
               mapDevNameRecType.get('CEC_CC_ReaberturaAnatel') == varCase.RecordTypeId 
               && varCase.ParentId <> null){
                caseProtocolChannel.protocolo = varCase.Parent.CriticalChannelProtocol__c;
                caseProtocolChannel.sistema = varCase.Parent.Grouping__c;           
                caseProtocolChannel.dataProtocol =  varCase.Parent.CreatedDate;
            }
            
            if(varCase.LegacyProtocol__c != null)
            {
                EntidadeProtocol caseProtocolLegado = new EntidadeProtocol();                
                caseProtocolLegado.protocolo = varCase.LegacyProtocol__c;
                caseProtocolLegado.sistema = varCase.BusinessUnit__c;
                caseProtocolLegado.dataProtocol = varCase.DateGenerationProtocolLegacy__c;
                lstProtocols.add(caseProtocolLegado);
            }
            lstProtocols.add(caseProtocolChannel);
        }
        
        return lstProtocols; 
    }
    
    @AuraEnabled
    public static Case GetCase(String varCaseParameterId) 
    {
        return [SELECT Id, CaseNumber, Contract__c,  LineNumber__c, ContractBillingAccount__c, ContractMSISDN__c, 
                Channel__c, LegacyProtocol__c, BusinessUnit__c, CriticalChannelProtocol__c,
                ProtocolNumber__c, Product__c, OperatorCode__c, Subject, Description, Status, SubStatus__c
                FROM Case 
                WHERE Id = : varCaseParameterId LIMIT 1];
    }
    
    @AuraEnabled
    public static String getTypeProtocol(Case objCase)
    {
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{objCase.BusinessUnit__c}, new Set<String>{objCase.Product__c});
        
 		if(mapClassification.containsKey(objCase.BusinessUnit__c) && 
                mapClassification.get(objCase.BusinessUnit__c).containsKey(objCase.Product__c)) {
            return mapClassification.get(objCase.BusinessUnit__c).get(objCase.Product__c).Legacy__c;
        }          
        else return 'Não Parametrizado';
    }
    
    @AuraEnabled
    public static List<Object> GetProtocol(Case objCase)
    {
        System.debug('GetProtocol' + objCase);
        List<Object> ret = new List<Object>();
        CEC_ProtocolNetResponse responseProtocol = new CEC_ProtocolNetResponse();
        System.debug('objCase.Product__c' + objCase.Product__c);
        if(objCase.Product__c != null && !objCase.Product__c.equalsIgnoreCase('Sem produto'))
        {
            try {                
                responseProtocol = CEC_ProtocolNetService.getResponse(objCase);  
            }
            catch(Exception ex){
                return GetProtocolByError(ex.getMessage());
            }
            
            if(responseProtocol.data <> null && String.isNotBlank(responseProtocol.data.protocolNumber))  
            { 
                try 
                {    
                    objCase.LegacyProtocol__c = responseProtocol.data.protocolNumber;
                    objCase.DateGenerationProtocolLegacy__c = Datetime.now();
                    objCase.InteractionNumber__c = responseProtocol.data.interactionNumber;
                    
                    CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
                    ocurrencyInfo.caso = objCase;
                    ocurrencyInfo.typeOcurrency = 'Open';
                    ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
                    
                    CEC_OcurrencyNetResponse responseOcurrency = CEC_OcurrencyNetService.getResponse(ocurrencyInfo);                
                }
                catch(CEC_IntegrationException ex){
                    
                    CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();
                    
                    requestLog.detailMessage = ex.getMessage();
                    requestLog.typeOcurrency = 'Open';
                    requestLog.errorMessage  = ex.errorMessage;
                    requestLog.errorCode     = ex.errorCode;
                    requestLog.httpCode      = ex.httpCode;
                    requestLog.objectId      = objCase.Id;
                    requestLog.nameService   = 'OcurrencyNetService';
                    
                    CEC_CC_ServiceLog.ServiceLogResponse logResponse = new CEC_CC_ServiceLog().insertData(requestLog); 
                }  
                
                //Ainda se houver erro da ocorrência deve retornar o protocolo pois ela será reprocessada no schedule
                return GetProtocolByCase(objCase);
            }
            else{
                return GetProtocolByError(responseProtocol.Error.message);
            }   
        }
        else
        {
            /* 11-02-2020
             * Regra alterada de acordo a US493 para copiar o número do caso ao invés do protocolo do canal crítico. 
             * O novo protocolo deve ser o número do caso
			 */
            objCase.LegacyProtocol__c = objCase.CaseNumber;
            objCase.DateGenerationProtocolLegacy__c = Datetime.now();
            System.debug('CaseNumber' + objCase.CaseNumber);
            System.debug('LegacyProtocol__c' + objCase.LegacyProtocol__c);
            return GetProtocolByCase(objCase);
        }   
        
    }
    
    @AuraEnabled
    public static List<Object> GetProtocolByCase(Case objCase)
    {
        Map<String, Id> mapDevNameRecType = CEC_CC_Util.getRecordTypeInfoByObj('Case');
        
        List<Object> lstProtocols   = new List<Object>();
        List<Case> cases  = [SELECT Id, Channel__c, CriticalChannelProtocol__c, DateGenerationProtocolLegacy__c, RecordTypeId,
                             ParentId, LegacyProtocol__c, Grouping__c,CreatedDate, BusinessUnit__c,LastModifiedDate,
                             InteractionNumber__c, Parent.CriticalChannelProtocol__c, Parent.Grouping__c, Parent.CreatedDate
                             FROM Case  
                             WHERE id = : objCase.Id];
        
        for(Case varCase : cases)
        {            
            EntidadeProtocol caseProtocolChannel = new EntidadeProtocol();
            
            if(mapDevNameRecType.get('CEC_CC_SuporteApoio') == varCase.RecordTypeId ||
               mapDevNameRecType.get('CEC_CC_ReaberturaAnatel') == varCase.RecordTypeId 
               && varCase.ParentId <> null){
                caseProtocolChannel.protocolo = varCase.Parent.CriticalChannelProtocol__c;
                caseProtocolChannel.sistema = varCase.Parent.Grouping__c;           
                caseProtocolChannel.dataProtocol =  varCase.Parent.CreatedDate;
            }
            else{
                caseProtocolChannel.protocolo = varCase.CriticalChannelProtocol__c;
                caseProtocolChannel.sistema = varCase.Grouping__c;           
                caseProtocolChannel.dataProtocol =  varCase.CreatedDate;
            }
            
            caseProtocolChannel.msgProtocol = 'Protocolo '+objCase.LegacyProtocol__c+' gerado com sucesso!';
            caseProtocolChannel.msgStatus = 'success';
            caseProtocolChannel.msgTitle = 'Geração de Protocolo';
            
            lstProtocols.add(caseProtocolChannel);
            
            if(varCase.LegacyProtocol__c == null)
            {
                EntidadeProtocol caseProtocolLegado = new EntidadeProtocol();
                caseProtocolLegado.protocolo = objCase.LegacyProtocol__c;
                caseProtocolLegado.sistema = varCase.BusinessUnit__c;
                caseProtocolLegado.dataProtocol = objCase.DateGenerationProtocolLegacy__c;
                caseProtocolLegado.msgProtocol = 'Protocolo '+objCase.LegacyProtocol__c+' gerado com sucesso!';
                caseProtocolLegado.msgStatus = 'success';
                caseProtocolLegado.msgTitle = 'Geração de Protocolo';
                
                lstProtocols.add(caseProtocolLegado);     
                
                varCase.LegacyProtocol__c = objCase.LegacyProtocol__c;
                varCase.DateGenerationProtocolLegacy__c = objCase.DateGenerationProtocolLegacy__c;
                varCase.InteractionNumber__c = objCase.InteractionNumber__c;
            }                           
        }      
        
        Database.update(cases);
        
        return lstProtocols;
    }
    
    @AuraEnabled
    public static List<Object> GetProtocolByError(String msgError)
    {
        List<Object> lstRet = new List<Object>();
        EntidadeProtocol protocol = new EntidadeProtocol();
        protocol.msgProtocol = 'Erro sistêmico, por favor gerar o protocolo manualmente';
        protocol.msgStatus = 'error';
        protocol.msgTitle = 'Geração de Protocolo';
        protocol.typeProtocol = 'Manual';
        
        //US 06 - Criar Ocorrência de Resolução [Solicitação de alteração de mensagem]
        if(String.isNotBlank(msgError) && 
           (msgError.contains('ESB-GERAL-0005') || msgError.contains('ESB-GERAL-0002'))) {          
               protocol.msgProtocol = 'Contrato incorreto. Revise os dados cadastrais.';
               protocol.typeProtocol = 'Automatic';
           }
        
        lstRet.add(protocol);         
        
        return lstRet;
    }   
    
    public class EntidadeProtocol
    {
        @AuraEnabled public String   protocolo            {get; set;}
        @AuraEnabled public String   sistema              {get; set;}
        @AuraEnabled public Datetime dataProtocol         {get; set;}
        @AuraEnabled public String   msgProtocol          {get; set;}
        @AuraEnabled public String   msgStatus            {get; set;}
        
        @AuraEnabled public String   msgTitle	          {get; set;}
        @AuraEnabled public String   typeProtocol         {get; set;}
    }    
}