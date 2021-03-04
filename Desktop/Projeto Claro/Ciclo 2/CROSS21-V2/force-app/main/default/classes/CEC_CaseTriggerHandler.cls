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
* Data: 10/10/2020  
* Autor: Squad LGPD - Hitts do Brasil
* Alterações: Fechamento de ocorrências no NETSMS 
* ---------------------------------------------------------------
* Data: 11/10/2020  
* Autor: Squad Canais Criticos
* Alterações: Refactoring para redução do número de SOQL feitas e recorrência de processamento
* ---------------------------------------------------------------
* Data: 23/12/2020   
* Autor: Squad Canais Criticos
* Alterações: Alterações nos campos Status e Sub-Status do Caso (Melhorias Ouvidoria)
* ---------------------------------------------------------------
*/

public class CEC_CaseTriggerHandler extends TriggerHandler  
{
    public static Boolean byPassValidation = false;
    
    public static Boolean byPassCloseCaseLGPD = false; 
    
    /**
     * Prefixo que identifica um owner como fila
     */
    private static final String QUEUE_PREFIX = '00G';

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
    @testVisible 
    private static final String LGPD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId();

    private static final Set<String> recordTypesIdsUpdateStatus = new Set<String>{CEC_CC_Anatel, CEC_CC_CanaisInternos, CEC_CC_JEC, CEC_CC_Ouvidoria,CEC_CC_Pre_JEC, CEC_CC_Procon};
    
    public override void beforeInsert() {
        updateFiedsRPA(Trigger.new);
        //Na inserção nao é necessário validar a data de corte, pois será sempre um novo caso 
        validationMask(Trigger.new, false);

        //REFACTORING_TRIGGER - Antes estava no afterInsert
        setOpenDate(Trigger.new);
    }	
    
    public override void beforeUpdate() {
        system.debug('CEC_CaseTriggerHandler.beforeUpdate');
        
        updateFiedsRPA(Trigger.new);
        //Na atualização do caso, é necessário validar pois pode ser de um caso anterior a data de corte
        validationMask(Trigger.new, true);
        
        if(!byPassValidation)             
            validateAlteracaoStatusSubStatus(Trigger.new, (Map<Id, Case>)Trigger.oldMap);
        
        if(!byPassCloseCaseLGPD){
          //System.debug('Teste byPassCloseOcurrencyNETSMS: '+ byPassCloseOcurrencyNETSMS );
        	closeCaseLGPD(Trigger.new);    
        }

        //Atualiza campo Status e SubStatus
        if(UserInfo.getName()!='RPA Canais Críticos')updateStatus(Trigger.new);
    }
    
    public override void afterInsert() {

        //REFACTORING_TRIGGER - Movido para o beforeInsert - setOpenDate(Trigger.new);

        CEC_CC_CaseAssignmentRules.enableCaseAssignmentRulesSubArea(Trigger.new);
    }
    
    public override void afterUpdate() {
        system.debug('CEC_CaseTriggerHandler.afterUpdate');

        //REFACTORING_TRIGGER - esses itens precisam ficar no afterUpdate mesmo.
        setGoals(Trigger.new);
        resolutionForChannel(Trigger.new, (Map<Id, Case>)Trigger.oldMap);

        //Atualizar status do caso pai no encerramento do caso filho
        updateParentStatus(Trigger.new);        	
    }
    
    /*-------------------------------------------------------------------------------------------------------
--- MÉTODOS PRIVADOS
-------------------------------------------------------------------------------------------------------*/    
/*----------------------------------------------------------------------------------------------------- 
--- Squad: LGPD
--- Description: Fechamento de ocorrências no NETSMS, de solicitaçoes de diretos na One trush
---	Created: 10/10/2020
-------------------------------------------------------------------------------------------------------*/
    @testVisible
    private static string closeCaseLGPD(List<Case> lstCases){
        system.debug('CEC_CaseTriggerHandler.closeOcurrencyNETSMS');
    	Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = getClassification(lstCases);
        String retorno = '';
        
	/*
        Boolean haveCaseId = false;

        for( case casoToClose : lstCases ){
            if( String.isNotBlank( casoToClose.Id ) )
                haveCaseId = true;
        }
        
        Set<Id> caseIds = new Set<Id>();
        
        List<vlocity_cmt__CustomerInteractionTopic__c> interactionTopics = new List<vlocity_cmt__CustomerInteractionTopic__c>();
        
        if( haveCaseId ){
        	caseIds = (new Map<Id,SObject>(lstCases)).keySet();
        
        	interactionTopics = [SELECT Id, vlocity_cmt__CaseId__c, LGPD_ID__c FROM vlocity_cmt__CustomerInteractionTopic__c WHERE vlocity_cmt__CaseId__c IN: caseIds];
        }
        
        Map<Id, String> lgpdIdByCaseId = new Map<Id, String>();
        for (vlocity_cmt__CustomerInteractionTopic__c interactionTopic : interactionTopics) {
            lgpdIdByCaseId.put(interactionTopic.vlocity_cmt__CaseId__c, interactionTopic.LGPD_ID__c);
        }
	*/
        for (Case varCase : lstCases){ 
            //fechar na One Trush
            if (varCase.RecordTypeId  == LGPD && varCase.Status      == 'Closed' &&
                varCase.Resolution__c != '' && varCase.Resolution__c != null &&
		varCase.LGPD_ID__c    != '' && varCase.LGPD_ID__c    != null ){
              //lgpdIdByCaseId.get(varCase.Id) != '' && lgpdIdByCaseId.get(varCase.Id) != null ){
                
                try{
                    //CEC_LGPDCloseCaseController.ControllerManagement(lgpdIdByCaseId.get(varCase.Id), varCase.Resolution__c);
		      CEC_LGPDCloseCaseController.ControllerManagement(varCase.LGPD_ID__c , varCase.Resolution__c);
		      
                }catch(CEC_IntegrationException ex){
                    system.debug('retornoCatch: ' + retorno); 
                    
                } 
            }

            List<Account> contractsResidencial = new List<Account>();
            List<Asset> assetMovel = new List<Asset>(); 

            if ( varCase.RecordTypeId == LGPD && varCase.Status == 'Closed' ){

                System.debug('varCase.AccountId: '+varCase.AccountId);
                contractsResidencial = [
                    SELECT
                        id,
                        ContractNumber__c,
                        vlocity_cmt__Status__c,
                        InstalledPremises__r.Name,
                        vlocity_cmt__BillingEmailAddress__c,
                        InstalledPremises__r.vlocity_cmt__StreetAddress__c,
                        ContractType__c,
                        BusinessUnit__c,
                        (
                            SELECT Id, Email, Phone, MobilePhone, DocumentNumber__c
                            FROM Contacts
                        )
                    FROM Account
                    WHERE
                        ParentId = :varCase.AccountId
                        AND RecordTypeId = :CEC_360_ShowContractsActiveController.recTypeContract
                        AND ContractNumber__c != NULL
                        AND BusinessUnit__c = 'Net'
                ];
                // Procurar no account customer se encontrar um contato móvel ativo
                assetMovel = [
                    SELECT
                        id,
                        MSISDN__c,
                        Status,
                        Name,
                        BusinessUnit__c,
                        Product2Id,
                        vlocity_cmt__ContractId__c
                    FROM Asset
                    WHERE
                        AccountId = :varCase.AccountId
                        AND RecordType.DeveloperName IN :CEC_360_ShowContractsActiveController.RECORD_TYPES_ASSET
                        AND MSISDN__c != NULL
                    LIMIT 1
                ];
                
                if (assetMovel.size() > 0 || contractsResidencial.size() == 0) { //Fechamento do PS8 - Feito por Lucas Salles
                    try{
                        retorno = 'OK'; 

                        ServiceParameter__c sp = [ SELECT Id, Name, clientAuth__c, clientAuth2__c, closeInPS8__c, 
                                                          collectionPointId__c, preferenceId__c 
                                                     FROM ServiceParameter__c 
                                                    WHERE Name = 'Consents_Parameters' LIMIT 1 ]; 
                        
                        System.debug( 'closeInPS8 ====> ' + sp.closeInPS8__c );

                        if( sp.closeInPS8__c && !Test.isRunningTest())
                            CEC_CC_InteractionClientController.closeOcurrencyPS8( varCase.Id );
                        
                    }catch( CEC_IntegrationException ex ){
                        retorno = 'Error'; 
                        system.debug('Retorno PS8 Catch: ' + ex.errorMessage );
                    }
                }else{ //Fechamento do NETSMS - Feito por jose.silva                    
                    try{
                        retorno = 'OK'; 
                        CEC_CC_InteractionClientController.closeOcurrencyNet( varCase.Id );
                        
                    }catch(CEC_IntegrationException ex){
                        retorno = 'Error'; 
                        system.debug('Retorno NETSMS Catch: ' + ex.errorMessage );
                    }
                }
        	}
        }
        byPassCloseCaseLGPD = true;
        return retorno;        
    }
    
    private static Map<String, Map<String, CEC_CC_PS8Classification__mdt>> getClassification(List<Case> lstCases){
        system.debug('CEC_CaseTriggerHandler.getClassification');
        Set<String> setProducts = new Set<String>();
        Set<String> setBU = new Set<String>();    
        
        for(Case varCase: lstCases) {
            setProducts.add(varCase.Product__c);
            setBU.add(varCase.BusinessUnit__c);
        }
        
        return CEC_CC_ClassificationMdtDAO.getClassificationType(setBU, setProducts);
    }
     
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
    

    @testVisible private static void setOpenDate(List<Case> lstCases)
    {
        //REFACTORING_TRIGGER
        for (Case varCase : lstCases) 

        {
            if (varCase.RecordTypeId == RT_CONSUMIDOR_GOV && varCase.OpenDateRobot__c != null) 
            {
                Date newDate = date.newinstance(varCase.OpenDateRobot__c.year(), varCase.OpenDateRobot__c.month(), varCase.OpenDateRobot__c.day());
                DateTime newDatetime = DateTime.newInstanceGmt(newDate, Time.newInstance(3, 0, 0, 0));
                varCase.OpenDateRobot__c = newDatetime;
            } else if(varCase.CriticalChannelOpenDate__c <> null){
                Date newDate = date.newinstance(varCase.CriticalChannelOpenDate__c.year(), varCase.CriticalChannelOpenDate__c.month(), varCase.CriticalChannelOpenDate__c.day());
                DateTime newDatetime = DateTime.newInstanceGmt(newDate, Time.newInstance(3, 0, 0, 0));
                varCase.CriticalChannelOpenDate__c = newDatetime;
            }
        }
    }
    
    /*-----------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Description: Update fields from RPA
-------------------------------------------------------------------------------------------------------*/ 
    @testVisible private static void updateFiedsRPA(List<Case> lstCases) {
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
    private static void resolutionForChannel(List<Case> lstCases, Map<Id, Case> mapCaseOld){

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
        
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = CEC_CC_ClassificationMdtDAO.getClassificationType(setBU, setProducts);
        
        for(Case varCase : lstCases){
        
            //Encerrar o atendimento no legado
            if(setCECId.contains(varCase.RecordTypeId) && 
               varCase.Status <>  mapCaseOld.get(varCase.Id).Status  && varCase.Status == 'Closed' && 
               mapClassification.containsKey(varCase.BusinessUnit__c) && 
               mapClassification.get(varCase.BusinessUnit__c).containsKey(varCase.Product__c)) {

                if(mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Legacy__c == 'NETSMS' && 
                   varCase.RecordTypeId <> RT_CONSUMIDOR_GOV && varCase.RecordTypeId <> CEC_CC_CasoApoio) {

                       //Casos do consumidor GOV não devem ser encerrados aqui, pois precisam de uma interação com o GOV de resposta de resolução
                       CEC_CC_InteractionClientController.newOcurrencyNet(varCase.Id, 'Resolution');  
                
                }else if(mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Legacy__c == 'PS8') {
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
    public static void createProtocolMovel(Set<Id> setCasesId) {

        List<Case> lstCasesToUpdate = new List<Case>();
        CEC_CC_ServiceLog ServiceLog = new CEC_CC_ServiceLog();
        
        if(Test.isRunningTest())
            ServiceLog = (CEC_CC_ServiceLog)CEC_MockUtil.createMock(CEC_CC_ServiceLog.class);
        
        Map<Id, CEC_ProtocolNetResponse> mapResponseAPI = CEC_ProtocolMovelService.create(setCasesId); 
        
        for(Id caseId : setCasesId){

            if(mapResponseAPI.containsKey(caseId)){

                CEC_ProtocolNetResponse responseAPI = mapResponseAPI.get(caseId);
                
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
                
                }else{
                    lstCasesToUpdate.add(new Case(Id = caseId, 
                                                  LegacyProtocol__c = responseAPI.data.protocolNumber, 
                                                  InteractionNumber__c = responseAPI.data.interactionNumber, 
                                                  DateGenerationProtocolLegacy__c = Datetime.now()));
                }
            }
        }
        
        //Protocolos Móveis para processar encerramento no PS8
        if(lstCasesToUpdate.size() > 0 || Test.isRunningTest() ){
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
    private static void validateAlteracaoStatusSubStatus(List<Case> lstCases, Map<Id, Case> mapCaseOld) {

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
    private static void validationMask(List<Case> lstCases, Boolean isToValid) {

    //Data de corte para validar o formato das máscaras de contrato residencial e móvel
    Date dataCorteValidacaoCasoCEC = Date.valueOf(Label.CEC_CC_DataCorteValidacaoCaso);

    Set<String> setProduct = new Set<String>();
    Set<String> setBusinessUnit = new Set<String>();
    boolean tirouTraco = false;

    for(Case varCase : lstCases) {
        setProduct.add(varCase.Product__c);
        setBusinessUnit.add(varCase.BusinessUnit__c);
    }

    // Obtem classificação dos produtos por unidade de negócio
    Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification =
        CEC_CC_ClassificationMdtDAO.getClassificationTypeRecordTypeNull(setBusinessUnit, setProduct);

    if(!mapClassification.isEmpty())
    {
        for(Case varCase : lstCases)
        {

            if(!isToValid || (isToValid && (varCase.CreatedDate >= Datetime.newInstanceGMT(dataCorteValidacaoCasoCEC, Time.newInstance(3, 0, 0, 0)))))
            {

                System.debug('isToValid >>>>' + isToValid);
                System.debug('varCase.CreatedDate >>>>> ' +varCase.CreatedDate);
                System.debug('Datetime >>>>>' +  Datetime.newInstanceGMT(dataCorteValidacaoCasoCEC, Time.newInstance(3, 0, 0, 0)));
                System.debug('dataCorteValidacaoCasoCEC >>>>>' +  dataCorteValidacaoCasoCEC);



                System.debug('dataCorteValidacaoCasoCEC >>>>>' +  mapClassification.containsKey(varCase.BusinessUnit__c));
                System.debug('dataCorteValidacaoCasoCEC >>>>>' +  mapClassification.get(varCase.BusinessUnit__c).containsKey(varCase.Product__c));
                System.debug('dataCorteValidacaoCasoCEC >>>>>' +  mapClassification.get(varCase.BusinessUnit__c).get(varCase.Product__c).Mask__c);
                System.debug('dataCorteValidacaoCasoCEC >>>>>' +  mapClassification);

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


                    if(Integer.valueOf(classification_mdt.LengthField__c) == 14){
                        //Validar máscara de contrato XXX/XXXXXXXX-X ou XXX/XXXXXXXXX
                        if(varCase.Contract__c.containsAny('/')){
                            varCase.Contract__c = varCase.Contract__c.replaceAll('-', '');
                            tirouTraco = true;
                            String [] contractDetail = varCase.Contract__c.split('/');
                            if(contractDetail[0].length() <> 3 || contractDetail[1].length() <> 9)
                                varCase.addError(classification_mdt.MaskMessage__c);
                            contractOnlyNumbers = varCase.Contract__c.replaceAll('/', '');
                        }
                        else varCase.addError(classification_mdt.MaskMessage__c);
                    }
                    //Validar somente números e tamanho
                    if(contractOnlyNumbers.isNumeric() == true){
                        if(varCase.Contract__c.length() <> Integer.valueOf(classification_mdt.LengthField__c)){
                            if (tirouTraco = true){
                                if (varCase.Contract__c.length() + 1 <> Integer.valueOf(classification_mdt.LengthField__c)){
                                    varCase.addError(classification_mdt.MaskMessage__c);
                                }
                            }
                            else{
                                varCase.addError(classification_mdt.MaskMessage__c);
                            }
                        }
                    } else {

                        // 21-02-2020 Validar 0s e caracter especial no número de telefone celular ou fixo
                            if(Integer.valueOf(classification_mdt.LengthField__c) <> 14 || Test.isRunningTest() )
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

    /*-----------------------------------------------------------------------------------------------------
    --- Company: Sysmap Solutions
    --- Squad: Canais Críticos
    --- Description: Alteração do campo Status e Sub-Status
    ---	Created: 21/12/2020
    -------------------------------------------------------------------------------------------------------*/
    private static void updateStatus(List<Case> lstCases){
        for (Case varCase : lstCases)
        {
            //Nao pode ser processado para filas
            if(recordTypesIdsUpdateStatus.contains(varCase.RecordTypeId) && varCase.OwnerId != null && !String.valueOf(varCase.OwnerId).startsWith(QUEUE_PREFIX))
            {
                //Fluxo apenas para tipo de entrada portal para o teste de novo e não iniciado
                if((varCase.InputType__c == 'Portal') && 
                (varCase.Status == 'New' || varCase.SubStatus__c == 'Não Iniciado') && 
                (String.isNotBlank(varCase.Product__c) || String.isNotBlank(varCase.EntryReason__c) || String.isNotBlank(varCase.Origin)))
                {
                    varCase.Status = 'In Progress';
                    varCase.SubStatus__c = 'Em tratamento';
                }
                
                if (((varCase.Status == 'New' || varCase.Status == 'In Progress')) &&
                    varCase.SubStatus__c != 'Encerrado' &&
                    (String.isNotBlank(varCase.Output_Subject__c) && String.isNotBlank(varCase.Relevant__c) &&
                    String.isNotBlank(varCase.LegacyProtocol__c) && String.isNotBlank(varCase.Resolution__c) && String.isNotBlank(varCase.PriorAgreement__c)))
                {
                    varCase.Status = 'Closed';
                    varCase.SubStatus__c = 'Encerrado';
                }
            }
        }
    }

    /*-----------------------------------------------------------------------------------------------------
    --- Company: Sysmap Solutions
    --- Squad: Canais Críticos
    --- Description: Realiza a atualização dos casos pais no cenário onde todos os casos filho foram encerrados, alterando o 'SubStatus de Pendente com Área' para 'Em tratamento'. Processa de forma async porque quem sera alterado seram os casos pai
    ---	Created: 22/01/2021
    -------------------------------------------------------------------------------------------------------*/
    private static void updateParentStatus(List<Case> lstCases) {

        //Fluxo apenas para casos filho sendo encerrados
        Set<String> parentIdCasosFilhosEncerrados = new Set<String>();
        for (Case varCase : lstCases) {            
            if(varCase.RecordTypeId == CEC_CC_CasoFilho && varCase.IsClosed && varCase.ParentId != null) {
                parentIdCasosFilhosEncerrados.add(varCase.ParentId);
            }
        }
        if(!parentIdCasosFilhosEncerrados.isEmpty()) {
            runUpdateParentStatus(parentIdCasosFilhosEncerrados);                  
        }
    }
    
    /**
     * Execução da atualização dos casos pais - não pode ser executado de forma asincrona porque existe um PB com chamada apex que já tem Future
     */
    private static void runUpdateParentStatus(Set<String> parentIdCasosFilhosEncerrados) {
       
        //Utilizando a lista de ids de casos pai, verifica os status dos que estao pendende com area para atualizar novamente para em tratamento
        List<Case> casosPai = [Select Id, SubStatus__c, (Select Id, IsClosed from Cases) 
                                From Case 
                                Where Id IN :parentIdCasosFilhosEncerrados AND 
                                RecordTypeId IN :recordTypesIdsUpdateStatus AND
                                Status = 'In Progress' AND
                                SubStatus__c = 'Pendente com Área'];
        
        if(casosPai != null && casosPai.size() > 0) {
            List<Case> casosPaiUpdate = new List<Case>();
            for(Case casoPai : casosPai) {
                if(casoPai.Cases != null && casoPai.Cases.size() > 0) {
                    Boolean atualizarCasoPai = true;
                    for(Case casoFilho : casoPai.Cases) {
                        //Se o status desse caso filho retorndo estiver diferente de encerrado, esse caso pai nao pode ter o status atualizado
                        if(!casoFilho.IsClosed) {
                            atualizarCasoPai = false;
                            break;
                        }
                    }   
                    
                    //Se chegou ate quer dizer que esse caso pai tem todos os casos filho com status encerrado, logo, ele pode atualizar o status para Em Tratamento
                    if(atualizarCasoPai) {
                        casoPai.SubStatus__c = 'Em tratamento';
                        casosPaiUpdate.add(casoPai);
                    }
                }                            
            }

            if(casosPaiUpdate.size() > 0) {
                update casosPaiUpdate;
            }
        }                    
    }
}