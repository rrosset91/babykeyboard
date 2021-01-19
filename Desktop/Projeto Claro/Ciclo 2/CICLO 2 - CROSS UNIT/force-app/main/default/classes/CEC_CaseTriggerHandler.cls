/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/07/2019
* Descrição: [CEC - Release 3] - [Time: SQUAD Canais Criticos - Sprint 10] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 24/07/2019  
* Autor: Squad Canais Criticos
* Alterações: Utilização de TriggerHandler e segregação da lógica de SLA
* ---------------------------------------------------------------
* Data: 03/02/2020  
* Autor: Squad Canais Criticos
* Alterações: Lógica de encerramento para casos com classificação no PS8
Chamada da API de geração de protocolo móvel
Processamento de log de erro para criação do bigObject
* ---------------------------------------------------------------
* Data: 11/03/2020  
* Autor: Squad Canais Criticos
* Alterações: Zerar campo de abertura do canal crítico (SLA) para nãp interferir na contagem 
* ---------------------------------------------------------------
*/
public class CEC_CaseTriggerHandler extends TriggerHandler  
{
    public static Boolean byPassValidation = false;
    
    @testVisible 
    private static final String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Anatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_AtendimentoPessoal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_AtendimentoPessoal').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CanaisInternos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Canais_Eletronicos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Canais_Eletronicos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_ReaberturaAnatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_ReaberturaAnatel').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CasoFilho = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CasoApoio = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId();
    
    public override void beforeInsert() {
        updateFiedsRPA(Trigger.new);
        //Na inserção nao é necessário validar a data de corte, pois será sempre um novo caso 
        validationMask(Trigger.new, false);
    }	
    
    public override void beforeUpdate() {
        updateFiedsRPA(Trigger.new);
        //Na atualização do caso, é necessário validar pois pode ser de um caso anterior a data de corte
        validationMask(Trigger.new, true);
        
        if(!byPassValidation)             
            validateAlteracaoStatusSubStatus(Trigger.new, (Map<Id, Case>)Trigger.oldMap);
    }
    
    public override void afterInsert() {
        setOpenDate(Trigger.new);
    }
    
    public override void afterUpdate() {
        setGoals(Trigger.new);
        resolutionForChannel(Trigger.new, (Map<Id, Case>)Trigger.oldMap);
    }
    
    /*-------------------------------------------------------------------------------------------------------
--- MÉTODOS PRIVADOS
-------------------------------------------------------------------------------------------------------*/    
    @testVisible private static void setGoals(List<Case> lstCases)
    {
        Date dateToday = Date.today();
        
        List<goal__c> lstGoals = [SELECT Value_Calculation__c, StartDate__c, EndDate__c
                                  FROM Goal__c WHERE User__c = :UserInfo.getUserId()];
        
        for (Case varCase : lstCases)
        {
            if (varCase.Status == 'Answered' && !CEC_CC_Util.isSemaphored(varCase.Id, 'setGoals')) {
                for (goal__c goal : lstGoals) {
                    if (DateToday >= goal.StartDate__c && DateToday <= goal.EndDate__c) {
                        goal.Value_Calculation__c = (goal.Value_Calculation__c == null) ? 1 : goal.Value_Calculation__c + 1;
                    }
                }
            }
        }
        
        update lstGoals;
    }
    
    @testVisible private static void setOpenDate(list<Case> lstCases)
    {
        List<Case> lstCasesToUpdate = new List<Case>();
        
        for (Case varCase : [SELECT Id, RecordTypeId , OpenDateRobot__c, CriticalChannelOpenDate__c  FROM Case WHERE Id = :lstCases]) 
        {
            if (varCase.RecordTypeId == RT_CONSUMIDOR_GOV && varCase.OpenDateRobot__c != null) 
            {
                Date newDate = date.newinstance(varCase.OpenDateRobot__c.year(), varCase.OpenDateRobot__c.month(), varCase.OpenDateRobot__c.day());
                DateTime newDatetime = DateTime.newInstanceGmt(newDate, Time.newInstance(3, 0, 0, 0));
                varCase.OpenDateRobot__c = newDatetime;
                lstCasesToUpdate.add(varCase);
            } else if(varCase.CriticalChannelOpenDate__c <> null){
                Date newDate = date.newinstance(varCase.CriticalChannelOpenDate__c.year(), varCase.CriticalChannelOpenDate__c.month(), varCase.CriticalChannelOpenDate__c.day());
                DateTime newDatetime = DateTime.newInstanceGmt(newDate, Time.newInstance(3, 0, 0, 0));
                varCase.CriticalChannelOpenDate__c = newDatetime;
                lstCasesToUpdate.add(varCase);                
            }
        }
        
        if (!lstCasesToUpdate.isEmpty()) { Database.update(lstCasesToUpdate); }
    }
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Description: Update fields from RPA
-------------------------------------------------------------------------------------------------------*/ 
    @testVisible private static void updateFiedsRPA(List<Case> lstCases)
    {
        for(Case varCase : lstCases)
        {
            if(varCase.AdditionalInformation__c != null) {
                varCase.AdditionalInformation__c = varCase.AdditionalInformation__c.replaceAll(';', '\r\n');
            }
        }
    } 
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Squad: Canais Críticos 
--- Description: Resolução de um atendimento para os canais 
---	Created: 28/08/2019
-------------------------------------------------------------------------------------------------------*/
    @testVisible
    private static void resolutionForChannel(List<Case> lstCases, Map<Id, Case> mapCaseOld)
    {
        Set<String> setCECId = new Set<String>{ CEC_CC_Anatel, CEC_CC_AtendimentoPessoal, CEC_CC_JEC, CEC_CC_Ouvidoria, CEC_CC_Pre_JEC, 
            CEC_CC_Procon, CEC_CC_CanaisInternos, CEC_CC_Canais_Eletronicos, CEC_CC_ReaberturaAnatel,
            RT_CONSUMIDOR_GOV, CEC_CC_CasoApoio };
                
                Set<Id> setProtocolMovelId = new Set<Id>();
        Set<String> setProducts = new Set<String>();
        Set<String> setBU = new Set<String>();    
        
        for(Case varCase: lstCases) {
            setProducts.add(varCase.Product__c);
            setBU.add(varCase.BusinessUnit__c);
        }
        
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(setBU, setProducts);
        
        for(Case varCase : lstCases)
        {
            //Encerrar o atendimento no legado
            if(setCECId.contains(varCase.RecordTypeId) && 
               varCase.Status <>  mapCaseOld.get(varCase.Id).Status  && varCase.Status == 'Closed' && 
               mapClassification.containsKey(varCase.BusinessUnit__c) && 
               mapClassification.get(varCase.BusinessUnit__c).containsKey(varCase.Product__c))  
            {
                if(mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Legacy__c == 'NETSMS' && 
                   varCase.RecordTypeId <> RT_CONSUMIDOR_GOV && varCase.RecordTypeId <> CEC_CC_CasoApoio) {
                       //Casos do consumidor GOV não devem ser encerrados aqui, pois precisam de uma interação com o GOV de resposta de resolução
                       CEC_CC_InteractionClientController.newOcurrencyNet(varCase.Id, 'Resolution');  
                   }
                else if(mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Legacy__c == 'PS8') {
                    setProtocolMovelId.add(varCase.Id);
                }
                //otherwise manual protocol
            }
        }
        
        //Protocolos Móveis para processar encerramento no PS8
        system.debug('CaseTrigger ## resolutionForChannel >> PS8 Process List:  ' + setProtocolMovelId.size());
        if(setProtocolMovelId.size() > 0) createProtocolMovel(setProtocolMovelId);   
    }    
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Squad: Canais Críticos 
--- Description: Geração de ocorrência na API do PS8 
---	Created: 28/08/2019
-------------------------------------------------------------------------------------------------------*/
    @future(callout=true)
    public static void createProtocolMovel(Set<Id> setCasesId) 
    {
        List<Case> lstCasesToUpdate = new List<Case>();
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        
        Map<Id, CEC_ProtocolNetResponse> mapResponseAPI = CEC_ProtocolMovelService.create(setCasesId); 
        
        for(Id caseId : setCasesId)
        {
            if(mapResponseAPI.containsKey(caseId)){
                CEC_ProtocolNetResponse responseAPI = mapResponseAPI.get(caseId);
                system.debug('CaseTrigger ## createProtocolMovel >> Response:  ' + responseAPI);
                
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
                else {
                    lstCasesToUpdate.add(new Case(Id = caseId, 
                                                  LegacyProtocol__c = responseAPI.data.protocolNumber, 
                                                  InteractionNumber__c = responseAPI.data.interactionNumber, 
                                                  DateGenerationProtocolLegacy__c = Datetime.now()));
                }
            }
        }
        
        //Protocolos Móveis para processar encerramento no PS8
        system.debug('CaseTrigger ## createProtocolMovel >> Cases to Update:  ' + lstCasesToUpdate.size());
        if(lstCasesToUpdate.size() > 0){
            TriggerHandler.bypass('CEC_CaseSLATriggerHandler');
            TriggerHandler.bypass('CEC_CaseTriggerHandler');
            CEC_CaseTriggerHandler.byPassValidation = true;
            update(lstCasesToUpdate);   
            TriggerHandler.clearAllBypasses();
        } 
    }
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Squad: Canais Críticos 
---	Created: 23/09/2019
-------------------------------------------------------------------------------------------------------*/
    @testVisible
    private static void validateAlteracaoStatusSubStatus(List<Case> lstCases, Map<Id, Case> mapCaseOld)
    {
        Map<Id, Case> mapCaseNew = new Map<Id, Case>([SELECT Id, CreatedBy.UserName, CreatedBy.Profile.Name  FROM Case WHERE Id = :lstCases]);
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];        
        for(Case varCase : lstCases)
        {            
            //Valida se houve alteração de status para casos do consumidor GOV e não houve alteração de owner
            if(varCase.RecordTypeId == RT_CONSUMIDOR_GOV &&        
               varCase.OwnerId ==  mapCaseOld.get(varCase.Id).OwnerId &&
               (mapCaseNew.get(varCase.Id).CreatedBy.Profile.Name == 'ZSF_CANAIS_CRITICOS_RPA' ||
                mapCaseNew.get(varCase.Id).CreatedBy.UserName.contains('rpacc@claro.com.br')) &&
               profileInfo.Name <> 'ZSF_CANAIS_CRITICOS_RPA' && profileInfo.Name <> 'Staff Canais Criticos' &&
               profileInfo.Name <> 'System Administrator' && profileInfo.Name <> 'Administrador do sistema' &&
               profileInfo.Name <> 'Gerente Canais Criticos' && profileInfo.Name <> 'Suporte Claro' && profileInfo.Name <> 'Supervisor Gov' &&
               (varCase.Status <>  mapCaseOld.get(varCase.Id).Status || varCase.SubStatus__c <>  mapCaseOld.get(varCase.Id).SubStatus__c))  
            {
                varCase.addError('Você não tem permissão para alterar este caso.');
            }
        }
    }
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Squad: Canais Críticos 
--- Description: Validação para contrato e telefone 
---	Created: 07/02/2020
-------------------------------------------------------------------------------------------------------*/
    private static void validationMask(List<Case> lstCases, Boolean isToValid)
    {        
        //Data de corte para validar o formato das máscaras de contrato residencial e móvel
        Date dataCorteValidacaoCasoCEC = Date.valueOf(Label.CEC_CC_DataCorteValidacaoCaso);
        
        Set<String> setProduct = new Set<String>();
        Set<String> setBusinessUnit = new Set<String>();
        
        for(Case varCase : lstCases) {
            setProduct.add(varCase.Product__c);
            setBusinessUnit.add(varCase.BusinessUnit__c);
        } 
        
        // Obtem classificação dos produtos por unidade de negócio
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(setBusinessUnit, setProduct);
        
        if(!mapClassification.isEmpty())
        {
            for(Case varCase : lstCases)
            {
                
                if(!isToValid || (isToValid && varCase.CreatedDate >= Datetime.newInstanceGMT(dataCorteValidacaoCasoCEC, Time.newInstance(3, 0, 0, 0))))
                {
                    //Avalia se a deve ser validado o contrato ou o telefone
                    if(String.isNotBlank(varCase.Contract__c) &&
                       mapClassification.containsKey(varCase.BusinessUnit__c) &&
                       mapClassification.get(varCase.BusinessUnit__c).containsKey(varCase.Product__c) && 
                       mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Mask__c)
                    {
                        CEC_CC_PS8Classification__mdt classification_mdt = mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c);
                        
                        //Substituir espaços em branco
                        if(varCase.Contract__c.containsWhitespace())
                            varCase.Contract__c = varCase.Contract__c.deleteWhitespace();
                        
                        String contractOnlyNumbers = varCase.Contract__c;
                        
                        //Validar máscara de contrato XXX/XXXXXXXXX
                        if(Integer.valueOf(classification_mdt.LengthField__c) == 13){
                            if(varCase.Contract__c.containsAny('/')){
                                String [] contractDetail = varCase.Contract__c.split('/');
                                if(contractDetail[0].length() <> 3 || contractDetail[1].length() <> 9)
                                    varCase.addError(classification_mdt.MaskMessage__c);
                                contractOnlyNumbers = varCase.Contract__c.replaceAll('/', '');
                            }
                            else varCase.addError(classification_mdt.MaskMessage__c);
                        }
                        
                        //Validar somente números e tamanho
                        if((contractOnlyNumbers.isNumeric() == false) || 
                           (varCase.Contract__c.length() <> Integer.valueOf(classification_mdt.LengthField__c)))
                        {
                            varCase.addError(classification_mdt.MaskMessage__c);
                            
                        } else {
                            
                            // 21-02-2020 Validar 0s e caracter especial no número de telefone celular ou fixo 
                            if(Integer.valueOf(classification_mdt.LengthField__c) <> 13 ) 
                            { 
                                if(varCase.Contract__c.containsAny('/'))
                                    varCase.addError(classification_mdt.MaskMessage__c);
                                else { 
                                    Decimal contractOnlyNumbersDecimal = Decimal.valueOf(varCase.Contract__c.trim());
                                    if(contractOnlyNumbersDecimal == 0)
                                        varCase.addError(classification_mdt.MaskMessage__c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}