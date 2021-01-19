/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Controller Component Protocol ]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 08/04/2019   
* Autor: Squad Canais Criticos
* Alterações: Inclusão de chamada da integração de ocorrência para enviar situção de resolução, e método para criar registro no caso de erro sistêmico na integração
* ---------------------------------------------------------------
* Data: 19/11/2019   
* Autor: Squad Canais Criticos
* Alterações: Remoção do tipo 'Redirecionamento da Reclamação' para interações GOV
* ---------------------------------------------------------------
* Data: 27/11/2019   
* Autor: Squad Canais Criticos
* Alterações: Notificar o proprietário do caso quando uma ação interna for registrada por outra pessoa diferente do dono do caso 
* ---------------------------------------------------------------
* Data: 06/02/2019   
* Autor: Squad Canais Criticos
* Alterações: Informar o tipo do protocolo para definir quais validações realizar na criação da interação
* ---------------------------------------------------------------
*/
public with sharing class CEC_CC_InteractionClientController 
{
       
    /* ------------------------------------------------------------ RecordType Info ------------------------------------------------------------ */
    @AuraEnabled
    public static List<String> getPicklistValuesByProfile(String ObjectName, String fieldApiname, String filterInteraction)
    {
        return getPicklistValues(ObjectName, fieldApiname, filterInteraction, true);
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectName, String fieldApiname)
    {        
        return getPicklistValues(ObjectName, fieldApiname, '', false);
    }
    
    @AuraEnabled
    public static String getCaseType(String recordId){        
        List<String> crossRecordTypes = getCrossRecordTypes();
        String caseRectTypeId = [SELECT RecordTypeId FROM Case WHERE Id =: recordId].RecordTypeId;
        if(crossRecordTypes.contains(caseRectTypeId)){
            return 'Cross';
        }else{
            return 'Others';
        }
    }
    
    private static List<String> getPicklistValues(String ObjectName, String fieldApiname, String filterInteraction, Boolean isFilterByProfile)
    {
        List<String> lstOption = new List<String>(); 
        Map<String,Schema.SObjectType> mapObjecDesc = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> mapFields = mapObjecDesc.get(ObjectName).getDescribe().fields.getMap(); 
        List<Schema.PicklistEntry> lstPicklistValues = mapFields.get(fieldApiname).getDescribe().getPickListValues(); 
        
        Profile varProfile = [SELECT Id, Name FROM Profile WHERE Id =: Userinfo.getProfileid()];   
        CEC_CC_Profile_Interaction__c varCustomProfile =  CEC_CC_Profile_Interaction__c.getInstance(varProfile.Id);
        
        String[] lstTypeInteractionGov;
        String[] lstTypeInternalAction;
        
        if(varCustomProfile.TypeInteractionGov__c <> '' && varCustomProfile.TypeInteractionGov__c <> null)
            lstTypeInteractionGov = varCustomProfile.TypeInteractionGov__c.split(';');
        if(varCustomProfile.TypeInternalAction__c <> '' && varCustomProfile.TypeInternalAction__c <> null)
            lstTypeInternalAction = varCustomProfile.TypeInternalAction__c.split(';');
        
        for (Schema.PicklistEntry pickListValue : lstPicklistValues) 
        {
            if(isFilterByProfile) {
                for(String valueStrg : (filterInteraction.equals('Cliente')) ? lstTypeInteractionGov : lstTypeInternalAction) {
                    if(varProfile.Id == varCustomProfile.SetupOwnerId && fieldApiname.Equals('TypeInteractionGov__c') && pickListValue.getValue() == valueStrg	) {
                        lstOption.add(pickListValue.getValue());
                    }
                } 
            }
            else 
                lstOption.add(pickListValue.getValue());
        }        
        
        lstOption.Sort();
        return lstOption;
    }
    
    /* ------------------------------------------------------------ Interaction ------------------------------------------------------------ */
    @AuraEnabled
    public static CEC_CC_InteractionClientController.WrapperClass getInteractionVelocity(String caseId, String filterInteraction)
    {
        CEC_CC_InteractionClientController.WrapperClass wrapperInteraction = new CEC_CC_InteractionClientController.WrapperClass();
        list<vlocity_cmt__CustomerInteractionTopic__c> lstInteractionTopic = new list<vlocity_cmt__CustomerInteractionTopic__c>(); 
        
        for(vlocity_cmt__CustomerInteractionTopic__c interaction : [SELECT Id, 
                                                                    vlocity_cmt__CaseId__c, 
                                                                    vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.Description__c, 
                                                                    vlocity_cmt__CustomerInteractionId__r.NewCompany__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__StartDateTime__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.Attachment__c, 
                                                                    vlocity_cmt__CustomerInteractionId__r.Author__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Status__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.ContactEmail__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.ContactPhone__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.LastModifiedDate, 
                                                                    vlocity_cmt__CustomerInteractionId__r.Owner.Name,
                                                                    vlocity_cmt__CustomerInteractionId__r.LoginClaro__c,
                                                                    vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Type__c,
                                                                    vlocity_cmt__CaseId__r.SubStatus__c
                                                                    FROM vlocity_cmt__CustomerInteractionTopic__c 
                                                                    WHERE vlocity_cmt__CaseId__c = :caseId 
                                                                    ORDER BY CreatedDate DESC])
        {            
            //Se as interações filtradas foram internas, o campo Type deve estar preenchido como other
            if(filterInteraction == 'Interna' &&
               interaction.vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Type__c <> 'other') continue;
            
            //Se as interações filtradas foram cliente, o campo Type deve estar preenchido com Consumidor.gov ou branco
            if(filterInteraction == 'Cliente' &&
               interaction.vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Type__c == 'other')continue;
            
            //As demais interações são listadas normente para interações de cliente 
            lstInteractionTopic.add(interaction);   
        }

        wrapperInteraction.message = '';
        wrapperInteraction.error = false;
        wrapperInteraction.lstCustomer = lstInteractionTopic;
        return wrapperInteraction; 
    }
    
    @AuraEnabled
    public static CEC_CC_InteractionClientController.WrapperClass createInteration(String filterInteraction,
                                                                                   String typeInteraction, 
                                                                                   String statusInteraction,
                                                                                   String descriptionInteraction, 
                                                                                   String caseId, 
                                                                                   List<String> lstDocumentId)
    {
       return createInteration(filterInteraction, typeInteraction, statusInteraction, descriptionInteraction, caseId, lstDocumentId , null, null);
    }
    
    @AuraEnabled
    public static CEC_CC_InteractionClientController.WrapperClass createInteration(String filterInteraction,
                                                                                   String typeInteraction, 
                                                                                   String statusInteraction,
                                                                                   String descriptionInteraction, 
                                                                                   String caseId, 
                                                                                   List<String> lstDocumentId,
                                                                                   String emailContato,
                                                                                   String telefoneContato)
    {
        CEC_CC_InteractionClientController.WrapperClass wrapperInteraction = new CEC_CC_InteractionClientController.WrapperClass();
        List<String> crossRecordTypes = getCrossRecordTypes();
        Case objCase = GetCaseById(caseId);
        if(objCase != null){
            if(crossRecordTypes.contains(objCase.RecordTypeId)){
                wrapperInteraction = createForCRMCross(filterInteraction,
                                                       typeInteraction, 
                                                       statusInteraction,
                                                       descriptionInteraction, 
                                                       objCase);
                
            }else{
                wrapperInteraction = createForConsumidorGOV(filterInteraction,
                                                            typeInteraction, 
                                                            statusInteraction,
                                                            descriptionInteraction, 
                                                            objCase, 
                                                            lstDocumentId,
                                                            emailContato,
                                                            telefoneContato);
            }
        }
        
        return wrapperInteraction;
    }
    
    private static CEC_CC_InteractionClientController.WrapperClass createForConsumidorGOV(String filterInteraction,
                                                                                          String typeInteraction, 
                                                                                          String statusInteraction,
                                                                                          String descriptionInteraction, 
                                                                                          Case objCase, 
                                                                                          List<String> lstDocumentId,
                                                                                          String emailContato,
                                                                                          String telefoneContato)
    {
        CEC_CC_InteractionClientController.WrapperClass wrapperInteraction = new CEC_CC_InteractionClientController.WrapperClass();
        try{
            Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{objCase.BusinessUnit__c}, 
                                                              new Set<String>{objCase.Product__c}); 
            if(validateDocumentQuantity(lstDocumentId, objCase)){
                wrapperInteraction.error = true;
                wrapperInteraction.message = 'Não é possível enviar mais de 5 anexos para o Consumidor.gov';
                //Clear all attachment created 
                clearAllAttachmentInserted(lstDocumentId);
            }
            else if(!validateDocumentlength(lstDocumentId, objCase))
            {
                //Atualizar informações no caso com base no tipo da interação
                updateInfosOnCase(typeInteraction, descriptionInteraction, objCase);  
                vlocity_cmt__CustomerInteraction__c objCustomerInteraction = new vlocity_cmt__CustomerInteraction__c(Name = 'Interação Consumidor.gov', 
                                                                                                                     vlocity_cmt__Status__c = 'Completed',
                                                                                                                     vlocity_cmt__Type__c = 'Consumidor.gov', 
                                                                                                                     vlocity_cmt__Channel__c = 'Contact',
                                                                                                                     Author__c = 'Empresa');
                objCustomerInteraction.RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('ConsumerInteractionGov').getRecordTypeId();
                objCustomerInteraction.Description__c = descriptionInteraction;
                objCustomerInteraction.vlocity_cmt__EndDateTime__c = System.now();
                objCustomerInteraction.vlocity_cmt__StartDateTime__c = System.now();
                objCustomerInteraction.TypeInteractionGov__c = typeInteraction;
                objCustomerInteraction.vlocity_cmt__Status__c = (typeInteraction == 'Cobra Retorno' || typeInteraction == 'Tentativa de Contato') ? statusInteraction : 'Pendente de sincronismo';
                objCustomerInteraction.vlocity_cmt__Type__c = (filterInteraction == 'Interna') ? 'Other' : 'Consumidor.gov';
                objCustomerInteraction.Attachment__c = !lstDocumentId.isEmpty() ? true : false;
                if(emailContato != null){
                    objCustomerInteraction.ContactEmail__c  = emailContato;
                }
                if(telefoneContato != null){
                    objCustomerInteraction.ContactPhone__c  = telefoneContato;
                }

                insert objCustomerInteraction;
                
                vlocity_cmt__CustomerInteractionTopic__c objInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
                objInteractionTopic.vlocity_cmt__CustomerInteractionId__c =  objCustomerInteraction.Id;
                objInteractionTopic.vlocity_cmt__CaseId__c = objCase.Id;
                insert objInteractionTopic;
                //Atrelar anexos a interação
                if(!lstDocumentId.isEmpty()) 
                    saveTheFile(lstDocumentId, objInteractionTopic.Id);
                //Notificar o proprietário do caso quando uma ação interna for registrada por outra pessoa diferente do dono do caso 
                if(filterInteraction == 'Interna' && objCase.OwnerId <> UserInfo.getUserId() &&
                   objCase.RecordTypeId <> Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId() &&
                   objCase.RecordTypeId <> Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId()){
                    Task varTask = new Task(Priority = 'Alta', Status = 'Open');
                    varTask.Subject = 'Informação complementar (Caso: ' + objCase.CaseNumber + ')';
                    varTask.Description = 'Foi inserida uma ação interna no seu caso. Favor verificar.';
                    varTask.ActivityDate = System.today();
                    varTask.WhatId = objCase.Id;
                    varTask.OwnerId = objCase.OwnerId;
                    insert varTask;
                }
                //Criar ocorrência de resolução no sistema legado @future somente quando os protocolos forem diferentes 
                //01-08-2019 - Quando os protocolos forem iguais trata-se de um caso 'Sem Produto'
                //06-02-2020 - Somente gerará ocorrência de saída quando o legado for netsms
                if(typeInteraction.equalsIgnoreCase('Resposta da Reclamação') && 
                   objCase.LegacyProtocol__c <> objCase.CriticalChannelProtocol__c && 
                   mapClassification.containsKey(objCase.BusinessUnit__c) && 
                   mapClassification.get(objCase.BusinessUnit__c).containsKey(objCase.Product__c) && 
                   mapClassification.get(objCase.BusinessUnit__c).get(objCase.Product__c).Legacy__c == 'NETSMS' ){
                    newOcurrencyNet(objCase.Id, 'Resolution');   
                }
                //Resgatar informações da interação para retornar ao componente
                wrapperInteraction = getInteractionVelocity(objCase.Id, filterInteraction);
            }else{
                wrapperInteraction.message = 'O anexo deve ter no máximo 1MB.';
                wrapperInteraction.error = true;
                //Clear all attachment created 
                clearAllAttachmentInserted(lstDocumentId);
            }
        }
        catch(Exception ex) {
            wrapperInteraction.error = true;
            wrapperInteraction.message = 'Erro ao inserir interação de "' + typeInteraction +  '" : ' + ex.getMessage();
        }
        return wrapperInteraction;
    }
    
    private static CEC_CC_InteractionClientController.WrapperClass createForCRMCross(String filterInteraction,
                                                                                     String typeInteraction, 
                                                                                     String statusInteraction,
                                                                                     String descriptionInteraction, 
                                                                                     Case objCase)
    {
        CEC_CC_InteractionClientController.WrapperClass wrapperInteraction = new CEC_CC_InteractionClientController.WrapperClass();
        try{
            Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
                CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{objCase.BusinessUnit__c}, 
                                                                  new Set<String>{objCase.Product__c}); 
            //Atualizar informações no caso com base no tipo da interação
            updateInfosOnCaseCrmCross(statusInteraction, objCase);  
            vlocity_cmt__CustomerInteraction__c objCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
            objCustomerInteraction.Name = 'Tentativa de Contato com o Cliente';
            objCustomerInteraction.vlocity_cmt__Status__c = statusInteraction;//'Completed';
            objCustomerInteraction.vlocity_cmt__Type__c = 'Call';
            objCustomerInteraction.vlocity_cmt__Channel__c = 'Contact Center';
            objCustomerInteraction.Author__c = 'Empresa';
            objCustomerInteraction.RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('CallTentative').getRecordTypeId();
            objCustomerInteraction.Description__c = descriptionInteraction;
            objCustomerInteraction.TypeInteractionGov__c = typeInteraction;
            objCustomerInteraction.vlocity_cmt__EndDateTime__c = System.now();
            objCustomerInteraction.vlocity_cmt__StartDateTime__c = System.now();
            insert objCustomerInteraction;
            
            vlocity_cmt__CustomerInteractionTopic__c objInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
            objInteractionTopic.vlocity_cmt__CustomerInteractionId__c =  objCustomerInteraction.Id;
            objInteractionTopic.vlocity_cmt__CaseId__c = objCase.Id;
            insert objInteractionTopic;
            
            //Notificar o proprietário do caso quando uma ação interna for registrada por outra pessoa diferente do dono do caso 
            if(filterInteraction == 'Interna' && objCase.OwnerId <> UserInfo.getUserId() &&
               objCase.RecordTypeId <> Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId() &&
               objCase.RecordTypeId <> Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId()){
                   Task varTask = new Task(Priority = 'Alta', Status = 'Open');
                   varTask.Subject = 'Informação complementar (Caso: ' + objCase.CaseNumber + ')';
                   varTask.Description = 'Foi inserida uma ação interna no seu caso. Favor verificar.';
                   varTask.ActivityDate = System.today();
                   varTask.WhatId = objCase.Id;
                   varTask.OwnerId = objCase.OwnerId;
                   insert varTask;
               }
            //Criar ocorrência de resolução no sistema legado @future somente quando os protocolos forem diferentes 
            //01-08-2019 - Quando os protocolos forem iguais trata-se de um caso 'Sem Produto'
            //06-02-2020 - Somente gerará ocorrência de saída quando o legado for netsms
            if(typeInteraction.equalsIgnoreCase('Resposta da Reclamação') && 
               objCase.LegacyProtocol__c <> objCase.CriticalChannelProtocol__c && 
               mapClassification.containsKey(objCase.BusinessUnit__c) && 
               mapClassification.get(objCase.BusinessUnit__c).containsKey(objCase.Product__c) && 
               mapClassification.get(objCase.BusinessUnit__c).get(objCase.Product__c).Legacy__c == 'NETSMS' ){
                   newOcurrencyNet(objCase.Id, 'Resolution');   
               }

            if(statusInteraction.equalsIgnoreCase('Insucesso') && typeInteraction.equalsIgnoreCase('Tentativa de Contato com Cliente')){
                objCase.status = 'Aguardando agendamento';
                objCase.Datetime_reagendamento__c = Datetime.now().addHours(2);
                update objCase;
            }
            //Resgatar informações da interação para retornar ao componente
            wrapperInteraction = getInteractionVelocity(objCase.Id, filterInteraction);
        }
        catch(Exception ex) {
            wrapperInteraction.error = true;
            wrapperInteraction.message = 'Erro ao inserir interação de "' + typeInteraction +  '" : ' + ex.getMessage();
        }
        return wrapperInteraction;
    }
    
    @AuraEnabled
    public static void clearAllAttachmentInserted(List<String> lstDocumentId) 
    {
        //Clear all attachment created 
        List<ContentDocument> lstContentDocument = [SELECT Id FROM ContentDocument WHERE Id IN: lstDocumentId];
        Database.delete(lstContentDocument);   
    }
    
    @TestVisible
    private static void updateInfosOnCase(String typeInteraction, String descriptionInteraction, Case objCase)
    {    
        Boolean isToUpdateCase = false;
        
        if(typeInteraction.equalsIgnoreCase('Recusa da Reclamação')) {
            objCase.SubStatus__c = 'Recusa Solicitada';                
            isToUpdateCase = true;
        }
        if(typeInteraction.equalsIgnoreCase('Resposta da Reclamação')) {
            objCase.SubStatus__c = 'Respondido e Aguardando Avaliação';
            isToUpdateCase = true;
        }         
        if(isToUpdateCase) { 
            CEC_CaseTriggerHandler.byPassValidation = true;
            update objCase; 
        }
    }
    
     @TestVisible
    private static void updateInfosOnCaseCrmCross(String statusInteraction, Case objCase)
    {    
        CEC_CaseTriggerHandler.byPassValidation = true;
        objCase.SubStatus__c = (statusInteraction == 'Sucesso') ? 'Concluído' : 'Pendente de Retorno para o Cliente';
        update objCase; //fix CaseTrigger Related Class
    }
    
    private static void saveTheFile(list<String> pDocumentId, String pInteractionId) 
    {
        list<ContentDocumentLink> lstContentDocument = new list<ContentDocumentLink>();
        
        for(String iDocument : pDocumentId)
        {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = iDocument;
            contentDocumentLink.LinkedEntityId = pInteractionId; 
            contentDocumentLink.ShareType = 'V';
            contentDocumentLink.Visibility = 'AllUsers';
            lstContentDocument.add(contentDocumentLink);
        }
        
        List<Database.SaveResult> lstSr = Database.insert(lstContentDocument);
        //Treat DatabaseResult Errors
    }
    
    @AuraEnabled
    public static list<ContentDocumentLink> getOpenFile(String aId) 
    {
        list<ContentDocumentLink> lLstDocument = new list<ContentDocumentLink>();
        
        for(ContentDocumentLink lContentDocument : [SELECT Id, 
                                                    ContentDocumentId,
                                                    ContentDocument.LatestPublishedVersionId, 
                                                    ContentDocument.Title,                                                     	   
                                                    ContentDocument.FileExtension, 
                                                    ContentDocument.CreatedDate, 
                                                    LinkedEntityId 
                                                    FROM ContentDocumentLink WHERE LinkedEntityId = :aId])
        {
            lLstDocument.add(lContentDocument);  
        }
        
        return lLstDocument;
    }
    
    private static List<String> getCrossRecordTypes(){
        List<String> recTypeIds = new List<String>();
        for(RecordType rt: [SELECT Id FROM RecordType WHERE DeveloperName IN ('Backoffice', 'Financial', 'General')]){
            recTypeIds.add(rt.Id);
        }
        return recTypeIds;
    }
    
    @future(callout=true)
    public static void newOcurrencyNet(Id pCaseId, String pTypeOcurrency)
    {
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        Case objCase = GetCaseById(pCaseId);
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        
        try
        {              
            CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
            ocurrencyInfo.caso = objCase;
            ocurrencyInfo.typeOcurrency = pTypeOcurrency;
            ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
            
            CEC_OcurrencyNetResponse responseOcurrency = CEC_OcurrencyNetService.getResponse(ocurrencyInfo); 
        }
        catch(CEC_IntegrationException ex){
            
            CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();
            
            requestLog.detailMessage = ex.getMessage();
            requestLog.typeOcurrency = pTypeOcurrency;
            requestLog.errorMessage  = ex.errorMessage;
            requestLog.errorCode     = ex.errorCode;
            requestLog.httpCode      = ex.httpCode;
            requestLog.objectId      = objCase.Id;
            requestLog.nameService   = 'OcurrencyNetService';
            
            CEC_CC_ServiceLog.ServiceLogResponse logResponse = ServiceLog.insertData(requestLog); 
        }
    }    
    
    @AuraEnabled
    public static Case GetCaseById(String caseId) 
    {
        List<Case> cs = [SELECT Id, BusinessUnit__c, CaseNumber,
                         Contract__c, CriticalChannelProtocol__c,Description,
                         InteractionNumber__c, LegacyProtocol__c, OpenDate__c, 
                         OpenDateRobot__c,OperatorCode__c, Output_Subject__c,   
                         OwnerId, Product__c, ProtocolNumber__c, Relevant__c, 
                         Resolution__c, Subject, SubStatus__c, Status, RecordtypeId,
                         ContractMSISDN__c
                         FROM Case 
                         WHERE Id = : caseId 
                         LIMIT 1];
        if(!cs.isEmpty()){
            return cs[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean validateDocumentQuantity(List<String> contentDocumentIds, Case objCase)
    {
        Boolean result = false;   
        List<AggregateResult> lstAggResult = [SELECT COUNT(Id) countFiles FROM ContentDocumentLink 
                                              WHERE LinkedEntityId IN 
                                              (SELECT Id FROM vlocity_cmt__CustomerInteractionTopic__c 
                                               WHERE vlocity_cmt__CaseId__c =: objCase.Id
                                               AND vlocity_cmt__CustomerInteractionId__r.Author__c = 'Empresa')];
        
        if(lstAggResult.size() > 0){
            Integer documentQuantity = Integer.valueOf(lstAggResult[0].get('countFiles')); 
            system.debug('Quantidade de Anexos relacionados a Interação: ' + documentQuantity);
            if(documentQuantity + contentDocumentIds.size() > Integer.valueOf(Label.CEC_CC_QtdInteracao))
                result = true;
        }
      
        return result;        
    }
    
    @AuraEnabled
    public static Boolean validateDocumentlength(List<String> contentDocumentIds, Case objCase)
    {
        Boolean result = false;   
        List<CEC_CC_Document__mdt> lstDocumentConfig =
            [SELECT FieldName__c, FieldValue__c, ObjectName__c, ContentSize__c
             FROM CEC_CC_Document__mdt 
             WHERE FieldValue__c =: objCase.RecordTypeId
             AND ObjectName__c = 'vlocity_cmt__CustomerInteractionTopic__c'];
        
        List<ContentDocument> lstContentDocument =
            [SELECT Id, ContentSize 
             FROM ContentDocument WHERE Id IN: contentDocumentIds];
        
        for(ContentDocument item : lstContentDocument)
        {
            for(CEC_CC_Document__mdt itemMetadata : lstDocumentConfig)
            {
                if(item.ContentSize > itemMetadata.ContentSize__c) {
                    result = true;
                }
            }
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String getTypeProtocol(Case objCase)
    {
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{objCase.BusinessUnit__c},
                                                              new Set<String>{objCase.Product__c});
        
 		 if(mapClassification.containsKey(objCase.BusinessUnit__c) && 
                mapClassification.get(objCase.BusinessUnit__c).containsKey(objCase.Product__c)) {
            return mapClassification.get(objCase.BusinessUnit__c).get(objCase.Product__c).Legacy__c;
        }          
        else return 'Manual';
    }
    
    public class WrapperClass
    {
        @AuraEnabled public Boolean error {get;set;}  
        @AuraEnabled public String message {get;set;}  
        @AuraEnabled public List<vlocity_cmt__CustomerInteractionTopic__c> lstCustomer {get;set;} 
    }
}