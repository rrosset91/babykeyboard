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
global with sharing class CEC_CC_InteractionClientController{
    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
       
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
                    if(varProfile.Id == varCustomProfile.SetupOwnerId && fieldApiname.Equals('TypeInteractionGov__c') && pickListValue.getValue() == valueStrg  ) {
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
    
    //método geral para chamada quando não tem telefone nem contrato.
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
    
    //chamada de método quando contém o telefone e contrato
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

            /*Alterações feitas em 07.12.2020 - IBM - CRM CROSS - Jean Sganzerla
            Busca o registro de CustomerInteraction com mesmo protocolo do caso, que é criado pela URA no momento da criação do registro de Case
            Caso não exista esse registro, é criado um
            Em seguida é criado um Customer Interaction Topic para armazernar a interação, e este é relacionado com o Customer Interaction com mesmo protocolo do caso*/

            String lInteractionName = 'Valor selecionado em tela do tipo de interação';
            String lChannel = 'Call Center';
            String lAuthor = 'Empresa';
            createInteractionTopic(lInteractionName, statusInteraction, lChannel, lAuthor, descriptionInteraction, typeInteraction, 'Telefone', objCase);

            
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
    
    @future(callout=true)
    public static void closeOcurrencyNet(Id pCaseId){
        System.debug('CEC_CC_InteractionClientController.closeOcurrencyNet');
        System.debug('CEC_CC_InteractionClientController.closeOcurrencyNet(pCaseId): '+ pCaseId);
  
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        Case objCase = GetCaseById(pCaseId);
        String retorno = '';
        try
        {  
        //Recupera o id da ocorrencia(number no response) para enviar no fechamento da ocorrencia no NETSMS
            String contractNumber = objCase.ContractMSISDN__c.substringAfter('/').trim();
            String operatorCode   = objCase.ContractMSISDN__c.substringBefore('/').trim();  
        String idOcorrencia = CEC_GetOcurrencyNetService.getOcurrency(contractNumber, operatorCode, objCase.ProtocolNumber__c);
        
            CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
            ocurrencyInfo.caso = objCase;
            ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency'; 
            ocurrencyInfo.idOcurrency = idOcorrencia;
            
            if(! Test.isRunningTest())
            CEC_OcurrencyNetResponse responseOcurrency = CEC_OcurrencyNetService.getCloseResponse(ocurrencyInfo); 
            
            else
                throw new BaseException('This is a test');
        
        }catch( Exception ex ){

            CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();       
            
            requestLog.detailMessage = ex.getMessage();
            requestLog.errorMessage  = ex.getMessage();
            //requestLog.errorCode     = ex.errorCode;
            //requestLog.httpCode      = ex.httpCode;
            requestLog.objectId      = objCase.Id;
            requestLog.nameService   = 'CEC_OAG_NET_Ocurrency';
            
            CEC_CC_ServiceLog.ServiceLogResponse logResponse = ServiceLog.insertData(requestLog); 
        }
    }      

    @future(callout=true)
    public static void closeOcurrencyPS8(Id pCaseId){ 
   
        Case objCase = GetCaseById(pCaseId); 

        CEC_360_LGPD_InteractionPS8_WP.InteractionPS8Request request = new CEC_360_LGPD_InteractionPS8_WP.InteractionPS8Request();
            
        request.data.protocolnumber = objCase.ProtocolNumber__c;
        request.data.status         = 'FECHADO';              
        request.data.details        = objCase.Resolution__c;            
        
        String requestJSON = JSON.serialize( request );  

        System.debug('requestJSON ====> ' + requestJSON);

        try{    
            HTTPResponse response;

            if(! Test.isRunningTest() ){ 

                response = CEC_360_IntegrationConsents.closeOcurrency( requestJSON ); 
                
                CEC_360_LGPD_InteractionPS8_WP.InteractionPS8response responseOcurrency =
                            (CEC_360_LGPD_InteractionPS8_WP.InteractionPS8response)JSON.deserialize( response.getBody(), CEC_360_LGPD_InteractionPS8_WP.InteractionPS8response.class);
    
            }else{
                throw new BaseException('This is a test');
            } 
        
        }catch(Exception ex){
			
            CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
            
            CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest();
            
            requestLog.detailMessage = ex.getMessage();
            requestLog.errorMessage  = ex.getMessage();
            //requestLog.errorCode     = ex.errorCode;
            //requestLog.httpCode      = ex.httpCode;
            requestLog.objectId      = objCase.Id;
            requestLog.nameService   = 'https://test02.apigw.claro.com.br/dataprivacy/v1/customers/interactions';
            
            CEC_CC_ServiceLog.ServiceLogResponse logResponse = ServiceLog.insertData(requestLog);  
        }  
    }   
    
    public static String getOcorrenciId( String pCaseId ){ 
  
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        Case   objCase = GetCaseById(pCaseId);
        String retorno = '';
        
        try{  
            //Recupera o id da ocorrencia(number no response) para enviar no fechamento da ocorrencia no NETSMS
            String contractNumber = objCase.ContractMSISDN__c.substringAfter('/').trim();
            String operatorCode   = objCase.ContractMSISDN__c.substringBefore('/').trim(); 
            
            String idOcorrencia = '';
                
            if(! Test.isRunningTest() ){
            	 idOcorrencia = CEC_GetOcurrencyNetService.getOcurrency(contractNumber, operatorCode, objCase.ProtocolNumber__c);    
            }else{
                throw new BaseException('This is a test');
            } 
                
            if( String.isNotBlank( idOcorrencia ) ){
                return idOcorrencia;
            }
            return null;

        }catch( Exception ex ){

            CEC_CC_ServiceLog.ServiceLogRequest requestLog = new CEC_CC_ServiceLog.ServiceLogRequest(); 

            requestLog.detailMessage = ex.getMessage();
            requestLog.errorMessage  = ex.getMessage();
            //requestLog.errorCode     = ex.errorCode;
            //requestLog.httpCode      = ex.httpCode;
            requestLog.objectId      = objCase.Id;
            requestLog.nameService   = 'CEC_OAG_NET_Ocurrency';
            
            CEC_CC_ServiceLog.ServiceLogResponse logResponse = ServiceLog.insertData(requestLog);

            return null;
        }
    }      
    
    @AuraEnabled
    public static Case GetCaseById(String caseId) {

        List<Case> cs = [SELECT Id, BusinessUnit__c, CaseNumber,
                         Contract__c, CriticalChannelProtocol__c,Description,
                         InteractionNumber__c, LegacyProtocol__c, OpenDate__c, 
                         OpenDateRobot__c,OperatorCode__c, Output_Subject__c,   
                         OwnerId, Product__c, ProtocolNumber__c, Relevant__c, 
                         Resolution__c, Subject, SubStatus__c, Status, RecordtypeId,
                        ContractMSISDN__c, SituationCase__c, Priority, RecordTypeName__c, RecordType.DeveloperName,
                        ContractBillingAccount__c, AccountId, LGPD_MSISDN__c, ContractBusinessUnit__c,Account.DocumentNumber__c,
                        ContractBillingAccount__r.CityCode__c, ContractBillingAccount__r.ContractNumber__c, Account.Name,Datetime_reagendamento__c
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
    public static Boolean validateDocumentQuantity(List<String> contentDocumentIds, Case objCase) {

        Boolean result = false;   
        List<AggregateResult> lstAggResult = [ SELECT COUNT(Id) countFiles FROM ContentDocumentLink WHERE LinkedEntityId IN 
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
    public static Boolean validateDocumentlength(List<String> contentDocumentIds, Case objCase) {

        Boolean result = false;   
        List<CEC_CC_Document__mdt> lstDocumentConfig = [ SELECT FieldName__c, FieldValue__c, ObjectName__c, ContentSize__c
             FROM CEC_CC_Document__mdt 
             WHERE FieldValue__c =: objCase.RecordTypeId
             AND ObjectName__c = 'vlocity_cmt__CustomerInteractionTopic__c'];
        
        List<ContentDocument> lstContentDocument = [ SELECT Id, ContentSize FROM ContentDocument WHERE Id IN: contentDocumentIds];
        
        for(ContentDocument item : lstContentDocument) {

            for(CEC_CC_Document__mdt itemMetadata : lstDocumentConfig) {
        
                if(item.ContentSize > itemMetadata.ContentSize__c) { 
                    result = true;
                }
            }
        }
        
        return result;
    }

    /*Alterações feitas em 07.12.2020 - IBM - CRM CROSS - Jean Sganzerla
    Busca o registro de CustomerInteraction com mesmo protocolo do caso, que é criado pela URA no momento da criação do registro de Case
    Caso não exista esse registro, é criado um
    Em seguida é criado um Customer Interaction Topic para armazernar a interação, e este é relacionado com o Customer Interaction com mesmo protocolo do caso*/
    public static void createInteractionTopic(String aName, String aStatus, String aChannel, String aAuthor, String aComments, String aTypeInteraction, String aType, Case aCase){
          
        List<vlocity_cmt__CustomerInteraction__c> lCustomerInteractionLst = [SELECT Id FROM vlocity_cmt__CustomerInteraction__c WHERE ProtocolNumber__c = :aCase.LegacyProtocol__c];
        //caso não haja um registro de Customer Interaction
        if(lCustomerInteractionLst.isEmpty()){
            vlocity_cmt__CustomerInteraction__c lInteraction = new vlocity_cmt__CustomerInteraction__c();
            lInteraction.ProtocolNumber__c = aCase.LegacyProtocol__c;
            insert lInteraction;
            lCustomerInteractionLst.add(lInteraction);
            system.debug('Customer Interaction Created in the Client Interaction Controller Class');
        }
        List<User> lCommunityFieldLst = [SELECT CommunityNickname FROM User WHERE Id = : UserInfo.getUserId()];
        
        vlocity_cmt__CustomerInteractionTopic__c lInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        lInteractionTopic.Name = aName;
        lInteractionTopic.SolarCross_Status__c = aStatus;
        lInteractionTopic.SolarCross_Channel__c = aChannel;
        lInteractionTopic.SolarCross_Author__c = aAuthor;
        lInteractionTopic.Comments__c = aComments;
        lInteractionTopic.Solar_Cross_Type__c = aType;
        lInteractionTopic.SolarCross_TypeInteraction__c = aTypeInteraction;
        lInteractionTopic.vlocity_cmt__CustomerInteractionId__c = lCustomerInteractionLst[0].Id;
        lInteractionTopic.vlocity_cmt__CaseId__c = aCase.Id;
        lInteractionTopic.vlocity_cmt__AccountId__c = aCase.AccountId;
        lInteractionTopic.RecordTypeId = SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('InteractionTentative').getRecordTypeId();  
        lInteractionTopic.Solar_Cross_DoneByClaro__c = !lCommunityFieldLst.isEmpty() ? lCommunityFieldLst[0].CommunityNickname : null;
        // lInteractionTopic.vlocity_cmt__ContractId__c = aCase.ContractBillingAccount__c; //campo comentado porque o campo é um lookup para Contract e não para Account
        insert lInteractionTopic;
    }

    @RemoteAction
    global static ReturnSaveCTI createInteractionTopicByCTI(String jsonParams){
        Params deserializedJson = (Params) JSON.deserialize(jsonParams,Params.class);
        List<vlocity_cmt__CustomerInteraction__c> lCustomerInteractionLst = [SELECT Id FROM vlocity_cmt__CustomerInteraction__c WHERE ProtocolNumber__c = :deserializedJson.legacyProtocol];
        Case objCase = GetCaseById(deserializedJson.caseId);

        //caso não haja um registro de Customer Interaction
        if(lCustomerInteractionLst.isEmpty()){
            vlocity_cmt__CustomerInteraction__c lInteraction = new vlocity_cmt__CustomerInteraction__c();
            lInteraction.ProtocolNumber__c = deserializedJson.legacyProtocol;
            insert lInteraction;
            lCustomerInteractionLst.add(lInteraction);
            system.debug('Customer Interaction Created in the Client Interaction Controller Class');
        }
        List<User> lCommunityFieldLst = [SELECT CommunityNickname FROM User WHERE Id = : UserInfo.getUserId()];
        
        vlocity_cmt__CustomerInteractionTopic__c lInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        lInteractionTopic.Name = 'Tentativa Click to Dial';
        lInteractionTopic.SolarCross_Status__c = deserializedJson.status;
        lInteractionTopic.SolarCross_Channel__c = 'Call Center';
        lInteractionTopic.SolarCross_Author__c = 'Empresa';
        lInteractionTopic.Solar_Cross_Type__c = 'Telefone';
        lInteractionTopic.SolarCross_TypeInteraction__c = 'Tentativa de Contato com Cliente';
        lInteractionTopic.vlocity_cmt__CustomerInteractionId__c = lCustomerInteractionLst[0].Id;
        lInteractionTopic.vlocity_cmt__CaseId__c = deserializedJson.caseId;
        lInteractionTopic.SolarCross_CallId__c = deserializedJson.callId;
        lInteractionTopic.vlocity_cmt__AccountId__c = deserializedJson.accountId;
        lInteractionTopic.RecordTypeId = SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('InteractionTentative').getRecordTypeId();  
        lInteractionTopic.Solar_Cross_DoneByClaro__c = !lCommunityFieldLst.isEmpty() ? lCommunityFieldLst[0].CommunityNickname : null;
        lInteractionTopic.SolarCross_ContactDataUsed__c = deserializedJson.phoneNumber;
        // lInteractionTopic.vlocity_cmt__ContractId__c = aCase.ContractBillingAccount__c; //campo comentado porque o campo é um lookup para Contract e não para Account
        lInteractionTopic.Comments__c = lInteractionTopic.SolarCross_Status__c == 'Sucesso'? null:'Falha na tentativa de contato com o cliente, número discado: ' + deserializedJson.phoneNumber;
        ReturnSaveCTI ret = new ReturnSaveCTI();
        try{
            insert lInteractionTopic;
            ret.success = true;

            if(lInteractionTopic.SolarCross_Status__c.equalsIgnoreCase('Insucesso') && lInteractionTopic.SolarCross_TypeInteraction__c.equalsIgnoreCase('Tentativa de Contato com Cliente')){
                objCase.status = 'Aguardando agendamento';
                objCase.Datetime_reagendamento__c = Datetime.now().addHours(2);
                update objCase;
            }
        }catch(Exception e){
            ret.success = false;
            ret.message = e.getMessage();
        }

        return ret;
    }

    // Método chamado pelo Component para envio de push notification
    @AuraEnabled
    public static Solar_Cross_PushNotificationAPI.ComponentReturnWrapper sendPushNotification(String aTypeInteraction, String aDescriptionInteraction, String aCaseId, String aPushMessage){
        Case lCase = GetCaseById(aCaseId);
        Integer customLimitHours = Integer.valueOf(Label.Solar_Cross_PushTimeValidation); //tempo em horas que determina o intervalo mínimo entre as notificações PUSH
        DateTime lTimeLimit = System.now().addHours(-customLimitHours);

        List<vlocity_cmt__CustomerInteractionTopic__c> lLastPushNotificationLst = [SELECT Id, CreatedDate 
                                                                                FROM vlocity_cmt__CustomerInteractionTopic__c 
                                                                                WHERE vlocity_cmt__CaseId__c = :aCaseId
                                                                                AND Solar_Cross_Type__c = 'Notificação digital (push)'
                                                                                AND SolarCross_Status__c = 'Sucesso'
                                                                                ORDER BY CreatedDate DESC LIMIT 1];

        //Impede que uma nova notificação de PUSH seja enviada caso uma outra notificação tenha sido enviada recentemente;                                                                        
        if(!lLastPushNotificationLst.isEmpty() && lLastPushNotificationLst[0].CreatedDate >= lTimeLimit){            
            DateTime nextPushDate = lLastPushNotificationLst[0].CreatedDate.addHours(customLimitHours);
            String nextPushDateFormatted = nextPushDate.format();

            Solar_Cross_PushNotificationAPI.ComponentReturnWrapper lReturn = new Solar_Cross_PushNotificationAPI.ComponentReturnWrapper();
            lReturn.success = false;
            lReturn.message = 'Não é possível enviar uma nova notificação. Aguarde até ' + nextPushDateFormatted;

            system.debug('Data da última notificação enviada: ' + lLastPushNotificationLst[0].CreatedDate.format() + ' --- Próxima data disponível para envio de um novo push: ' + nextPushDateFormatted + ' --- Janela de tempo em Horas: ' + customLimitHours);
            return lReturn;
        }


        //Monta o Payload da Integração de PUSH 
        Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper lPushPayload = new Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper();
        lPushPayload.data.campaign = Label.Solar_Cross_PushNotificationCampain;
        lPushPayload.data.channel = '3'; //3 = PUSH
        lPushPayload.data.destination = lCase.ContractMSISDN__c;
        lPushPayload.data.telephoneNumber = lCase.LGPD_MSISDN__c;
        lPushPayload.data.message = aPushMessage;
        // lPushPayload.data.mobileClient = '1'; //trecho comentado pois a informação não é obrigatória
        lPushPayload.data.project = Label.Solar_Cross_PushNotificationProject;

        Solar_Cross_PushNotificationAPI.ComponentReturnWrapper lAPIResponse = Solar_Cross_PushNotificationAPI.communicationAPI(lPushPayload);

        String lInteractionName = 'Notificação digital (push)';
        String lChannel = 'Call Center';
        String lAuthor = 'Empresa';
        String lType = 'Notificação digital (push)';
        String lStatus;
        aDescriptionInteraction = aDescriptionInteraction == 'null' ? '' : aDescriptionInteraction;
        aPushMessage = aPushMessage == 'null' ? '' : aPushMessage;
        String lComments = aPushMessage + ' -- ' + aDescriptionInteraction;
        if(lAPIResponse.success){ // API recebeu com sucesso a solicitação do PUSH
            lStatus = 'Sucesso';
            createInteractionTopic(lInteractionName, lStatus, lChannel, lAuthor, lComments, aTypeInteraction, lType, lCase);
            return lAPIResponse;
        }
        else if(lAPIResponse.statusCode != null){ // API recebeu a solicitação do PUSH mas respondeu diferente de 200
            lStatus = 'Insucesso';
            createInteractionTopic(lInteractionName, lStatus, lChannel, lAuthor, lComments, aTypeInteraction, lType, lCase);
            lAPIResponse.message = Label.Solar_Cross_SendPushErrorMessage + ' ' + lAPIResponse.message;
            return lAPIResponse;
        }
        else{ // Execução quebrou em algum ponto e caiu no "cath"
            lAPIResponse.message = Label.Solar_Cross_SendPushErrorMessage + ' ' + lAPIResponse.message;
            return lAPIResponse;
        }
    }

    //Método que busca os valores de picklist para o usuário enviar uma Push Notification
    @AuraEnabled
    public static NotificationOptionsWrapper getPushNotificationRecords() {                
        Set<String> lCategorySet = new Set<String>(); 
        NotificationOptionsWrapper lReturn = new NotificationOptionsWrapper();
        
        for(QuickText lPushRecord :[SELECT Id, Category, Message FROM QuickText WHERE Channel = 'Push']){
            List<ComboboxOptionsWrapper> lValuesLst = lReturn.lMessageMap.get(lPushRecord.Category);
            
            if(lValuesLst == null){
                lValuesLst = new List<ComboboxOptionsWrapper>();
                lReturn.lMessageMap.put(lPushRecord.Category,lValuesLst);
            }
            lValuesLst.add(new ComboboxOptionsWrapper(lPushRecord.Message, lPushRecord.Message));
        
            //utilizado um SET para permitir apenas um registro de Categoria dentro da Lista. 
            if(!lCategorySet.contains(lPushRecord.Category)){
                lReturn.lCategory.add(new ComboboxOptionsWrapper(lPushRecord.Category, lPushRecord.Category));
                lCategorySet.add(lPushRecord.Category);
            }
        }
        return lReturn;
    }
    
    @AuraEnabled
    public static String getTypeProtocol(Case objCase) {

        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{objCase.BusinessUnit__c},
                                                              new Set<String>{objCase.Product__c});
        
 		if(mapClassification.containsKey(objCase.BusinessUnit__c) && mapClassification.get(objCase.BusinessUnit__c).containsKey(objCase.Product__c)) {
            return mapClassification.get(objCase.BusinessUnit__c).get(objCase.Product__c).Legacy__c;
        }          
        else return 'Manual';
    }

    @AuraEnabled
    public static Map<String,Object> getPhoneNumbers(String recordId){

        Map<String,Object> dataReturn = new Map<String, Object>();
        Case objCase = GetCaseById(recordId);
        List<ContactPhones> dataContacts = new List<ContactPhones>();
        List<ContactPhones> lstContactPhones = new List<ContactPhones>();
        System.debug('objCase.Account: ' + objCase.Account.DocumentNumber__c);
        map<String, Object> data = SolarCross_IntegrationContactPhones.getContactPhones(objCase.Account.DocumentNumber__c);
        System.debug('data: ' + data);
        System.debug('data: ' + data.get('statusCode'));
        if(data.get('statusCode') == 200){
            System.debug('Entroou aqui');
            JSONContactPhones contactPhones = (JSONContactPhones) JSON.deserialize((String) data.get('response'),JSONContactPhones.class );
            if(contactPhones.data != null){
                for(JSONContactPhones.CustomerPhones objContactPhone :contactPhones.data.customerPhones ){
                    //objContactPhone.
                    String maskedPhone = maskPhone(objContactPhone.phoneNumber,false);
                    ContactPhones cp = new ContactPhones(objContactPhone.phoneNumber,maskedPhone,objContactPhone.doNotDisturb,objContactPhone.rank,objCase);
                    lstContactPhones.add(cp);
                }
            }
            dataReturn.put('success',true);
            if(lstContactPhones.isEmpty()){
                dataReturn.put('message',Label.Solar_Cross_IntegrationNoDataContactPhones);
            }else{
                dataReturn.put('contactPhones', lstContactPhones);
            }
        }else{
            dataReturn.put('success',false);
            dataReturn.put('message',Label.Solar_Cross_IntegrationErrorMessage + 'Código do erro: ' + data.get('statusCode') + ' - ' + data.get('endPoint'));
        }
        return dataReturn;
    }

    @RemoteAction
    global static String maskPhone(String phoneNumber, Boolean isFromCTI){
        Solar_Cross_MaskConfiguration__mdt mdt  = [SELECT Id,MaskChar__c , RightCharQuantity__c, LeftCharQuantity__c,Activate__c FROM Solar_Cross_MaskConfiguration__mdt WHERE DeveloperName= 'Telefone' LIMIT 1];
        if(!mdt.Activate__c && !isFromCTI )
            return phoneNumber;
        Integer leftChar = Integer.valueOf(mdt.LeftCharQuantity__c);
        Integer rightChar = Integer.valueOf(mdt.RightCharQuantity__c);
        String maskChar = mdt.MaskChar__c;
        String areaCode = '('+ phoneNumber.substring(0,2)+')';

        String leftNum = phoneNumber.substring(2,(leftChar+2)).replaceAll('[\\d]',maskChar);
        System.debug('lefNum: ' + leftNum);
        //somar leftNum + 2 e rightNum + leftNum
        String rightNum = phoneNumber.substring((leftChar+2),(leftChar+rightChar)).replaceAll('[\\d]',maskChar);
        //somar leftNum+rightNum e leftNum+rightNum+2
        String RightNumVisible = phoneNumber.substring((leftChar+rightChar),(leftChar+rightChar+2));
        System.debug('phoneSplited: ' + areaCode + leftNum + '-'+ rightNum + RightNumVisible);

        return areaCode + leftNum + '-'+ rightNum + RightNumVisible;
    }
    
    public class WrapperClass {

        @AuraEnabled public Boolean error {get;set;}  
        @AuraEnabled public String message {get;set;}  
        @AuraEnabled public List<vlocity_cmt__CustomerInteractionTopic__c> lstCustomer {get;set;} 
    }

    public class NotificationOptionsWrapper {
        @AuraEnabled public List<ComboboxOptionsWrapper> lCategory;
        @AuraEnabled public Map<String,List<ComboboxOptionsWrapper>> lMessageMap;

        public NotificationOptionsWrapper(){
            this.lCategory = new List<ComboboxOptionsWrapper>();
            this.lMessageMap = new Map<String,List<ComboboxOptionsWrapper>>();
        }
    }

    public class ComboboxOptionsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public ComboboxOptionsWrapper(String aLabel, String aValue){
            this.label = aLabel;
            this.value = aValue;
        }
    }

    public class ContactPhones{
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String mascaredPhoneNumber;
        @AuraEnabled public Boolean doNotDisturb;
        @AuraEnabled public String params;
        

        public ContactPhones(String phoneNumber, String mascaredPhoneNumber, String doNotDisturb, String rank,Case objCase){
            this.phoneNumber = phoneNumber;
            this.mascaredPhoneNumber = mascaredPhoneNumber;
            this.doNotDisturb = Boolean.valueof(doNotDisturb);
            this.params = JSON.serialize(new Params(objCase,phoneNumber,mascaredPhoneNumber));
        }
    }

    global class ReturnSaveCTI{
        @AuraEnabled public Boolean success; 
        @AuraEnabled public String message;

    }

    public class Params{
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String customerName;
        @AuraEnabled public String legacyProtocol;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String mascaredPhoneNumber;
        @AuraEnabled public String accountId;
        @AuraEnabled public String caseId;
        @AuraEnabled public String status;
        @AuraEnabled public String callId;
        @AuraEnabled public String systemCalling;

        public Params(Case objCase, String phoneNumber, String mascaredPhoneNumber){
            this.contractNumber = objCase.ContractBillingAccount__r.CityCode__c+objCase.ContractBillingAccount__r.ContractNumber__c;
            this.customerName = objCase.Account.Name;
            this.legacyProtocol = objCase.LegacyProtocol__c;
            this.phoneNumber = phoneNumber;
            this.mascaredPhoneNumber = mascaredPhoneNumber;
            this.accountId = ObjCase.AccountId;
            this.caseId = ObjCase.Id;
            this.status = '';
            this.callId = '';
            this.systemCalling ='CRM_CROSS';
        }
    }


}