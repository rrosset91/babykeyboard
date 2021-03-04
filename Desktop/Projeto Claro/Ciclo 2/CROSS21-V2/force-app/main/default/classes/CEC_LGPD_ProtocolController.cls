/*
 * ---------------------------------------------------------------
 * Data: 23/07/2020
 * Autor: Squad LGPD - Sysmap Solutions
 * Descrição: [SOLAR] - [Time: SQUAD LGPD - Sprint 4] -
 * Criação de Protocolo NETSMS/PS8 / Caso / Customer Interaction
 * ---------------------------------------------------------------
--- Controle de Versão
---------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: Criação de protocolo de Ocorrênccia (NETSMS), customer interaction topic, Task
--- Date: 20/08/2020
---------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: Melhoria no fluxo de createCustomerInteractionTopic para atender ProcessoBuilder de CC
--- Date: 14/09/2020
--- Alterado por : Guilherme Cuencas/Ello Serafim
-------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: atribuição para as filas LGPD
--- Date: 22/09/2020
--- Alterado por : Rodolfo Rodrigo
-------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: Desvio de fluxo para direitos roteados via omni-channel baseado em habilidade.
--- Date: 06/01/2021
--- Alterado por : Fabio Sato Suenaga
-------------------------------------------------------------------------------------------------------*/

public class CEC_LGPD_ProtocolController {
    private enum Legacy {
        NETSMS, PS8
    }
    public static LGPDProtocolControllerResponse integrateLGPDProtocol(
        Account acc,
        String RequestType,
        String channel
    ) {

        
        system.debug('CEC_LGPD_ProtocolController.integrateLGPDProtocol');

        String protocolNumber = '';

        // Objeto que será retornado
        LGPDProtocolControllerResponse returnData = new LGPDProtocolControllerResponse();
        String[] personas = new String[]{'ASSINANTE_CLARO', 'ASSINANTE_NEXTEL', 'ASSINANTE_CLARO_FIXO', 'ASSINANTE_LD21', 'EX_CLIENTE_ATE6MESES', 'EX_CLIENTE_APOS6MESES', 'PROSPECT'};
        
        try {
            Boolean is_createCustomerInteractionTopic = false;
            // Se o Id do account foi passado, buscamos os campos para garantir 
            // que o  objeto será montado
            // Se não foi passado o Id, assumimos que os campos estão populados e não faremos o select
            if(acc.Id != null){ 
 


                Account[] accList = [
                    SELECT
                        Id,
                        Name,
                        DocumentType__c,
                        DocumentNumber__c,
                        Phone,
                        CellPhone__c,
                        (
                            SELECT Id, Email, Phone, MobilePhone, DocumentType__c, DocumentNumber__c
                            FROM Contacts
                        ),
                        Email__c,
                        CustomerTypeList__c,
                        vlocity_cmt__BillingEmailAddress__c
                    FROM Account
                    WHERE Id = :acc.Id
                ];
                if(accList.size() > 0)
            acc = accList[0];
            }
            

            String persona = 'ASSINANTE_CLARO';
            // Validação persona
            // Se a persona não estiver no account ou estive com valor desconhecido, considerar o default
            if (string.isNotBlank(acc.CustomerTypeList__c)) {
                System.debug('acc.CustomerTypeList__c >>> ' + acc.CustomerTypeList__c);
                persona = acc.CustomerTypeList__c;
            }

            // Metadata sobre Solicitações LGPD
            CEC_LGPDdsar__mdt[] metadataList = [
                SELECT
                    DeveloperName,
                    rightName__c,
                    caseStatus__c,
                    PS8status__c,
                    NETSMSstatus__c,
                    reasonCode1__c,
                    reasonCode2__c,
                    reasonCode3__c,
                    reasonCode4__c,
                    reasonCode5__c
                FROM CEC_LGPDdsar__mdt
                WHERE DeveloperName = :RequestType
                LIMIT 1
            ];

            if ( metadataList.size() == 0 ) {
                throw new CEC_IntegrationException(
                    'Não foram encontradas configurações referentes à solicitação: ' +
                    RequestType
                );
            }

            // Metadata sobre ocorrências
            CEC_ME_OccurrenceSettings__mdt[] ocurrencySettings = [SELECT DeveloperName, Group__c, TypeId__c, Type__c, Status__c, ObservationPattern__c
            FROM CEC_ME_OccurrenceSettings__mdt
            WHERE DeveloperName = :RequestType];
            
            if ( ocurrencySettings.size() == 0 ) {
                throw new CEC_IntegrationException(
                    'Não foram encontradas configurações de ocorrência referentes à solicitação: ' +
                    RequestType
                );
            }
            CEC_ME_OccurrenceSettings__mdt occurrenceSetting = ocurrencySettings[0];
            
            CEC_LGPDdsar__mdt metadata = metadataList[0];


            List<Account> contractsResidencial = new List<Account>();
            List<Asset> assetMovel = new List<Asset>();
            Contact ctt = null;

            /**
             *  Se o Id do Account for null, assumimos que: 
             *  1. O account não foi encontrado no salesforce na etapa anterior e precisa ser criado ao final do fluxo;
             *  2. O account é um prospect.
             *  Assim, para o account.ID null, pulamos a etapa de busca por contratos e assets, e no final teremos que
             *  inserir o account antes da inserção do Case.
             * */
            if(acc.Id != null){
                system.debug( 'SOLAR_LGPDProtocolController: acc.Id =' + acc.Id + ' RecordTypeId =' + CEC_360_ShowContractsActiveController.recTypeContract );
                
                try{
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
                        ParentId = :acc.Id
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
                        AccountId = :acc.Id
                        AND RecordType.DeveloperName IN :CEC_360_ShowContractsActiveController.RECORD_TYPES_ASSET
                        AND MSISDN__c != NULL
                    LIMIT 1
                ];
                }catch(Exception ex){
                    System.debug('Erro ao buscar informações do contato: ' + ex.getMessage() );
                }
            }
            else {
                // Se o account ainda vai ser inserido, precisamos também criar o contact relacionado
                ctt = new Contact ();
                if(acc.Name.contains(' ')){
                    ctt.FirstName  = acc.Name.substringBefore(' ');
                    ctt.LastName = acc.Name.substringAfter(' ');
                }
                else{
                    ctt.FirstName  = acc.Name;
                    ctt.LastName = '.';
                }

                if( string.isNotBlank(acc.DocumentNumber__c)){
                ctt.DocumentNumber__c = acc.DocumentNumber__c;
                }
                ctt.DocumentType__c = 'CPF';

                if( string.isNotBlank(acc.vlocity_cmt__BillingEmailAddress__c) ){
                    ctt.Email = acc.vlocity_cmt__BillingEmailAddress__c;
                
                } else if( string.isNotBlank(acc.Email__c) ){
                    ctt.Email = acc.Email__c;
                }
                
                if( string.isNotBlank(acc.Phone) )
                ctt.MobilePhone = acc.Phone;
            }

            Case newCase = mountCase(acc, metadata, contractsResidencial, channel);
            // ctt é o contact que precisa ser inserido
            // Ele só existe se o Account ainda vai ser inserido
            Contact[] contacts = null;
            if(acc.Id == null){
                contacts = new Contact[] { ctt };
            }else{
                // Account já existe
                contacts = acc.Contacts;
            }

            //Poe o email do contato no case
            if(contacts.size() > 0){
                if( String.isNotBlank( contacts[0].Email ) )
                newCase.SuppliedEmail = contacts[0].Email;
            }

            system.debug('Inserir Protocolo nos legados');

            String interactionNumber = '';
            // Se houver um contrato móvel, ou caso não haja, se não houver também nenhum residencial
            Legacy legado;

            if (assetMovel.size() > 0 || contractsResidencial.size() == 0) {
                system.debug(
                    'A criar protocolo PS8, complementando campos do Case...'
                );
                legado = Legacy.PS8;
                CEC_ProtocolNetResponse responsePS8 = PS8Protocol(
                    newCase,
                    acc,
                    assetMovel,
                    channel,
                    persona,
                    metadata,
                    contacts
                );

                //Completando alguns campos do case
                protocolNumber = newCase.ProtocolNumber__c = responsePS8.data.protocolNumber;

                interactionNumber = responsePS8.data.interactionNumber;
            } else {
                system.debug(
                    'A criar protocolo NETSMS, complementando campos do Case...'
                );
                legado = Legacy.NETSMS;
                CEC_ProtocolNetResponse responseNETSMS = NETSMSProtocol(
                    newCase,
                    acc,
                    contractsResidencial[0],
                    channel,
                    persona,
                    metadata
                );
                
                system.debug('responseNETSMS '+responseNETSMS);
                
                protocolNumber = newCase.ProtocolNumber__c = responseNETSMS.data.protocolNumber;
                CEC_OcurrencyNetResponse occurrencyResponse = createOccurrency(newCase, occurrenceSetting, responseNETSMS.data.interactionNumber, acc);

                is_createCustomerInteractionTopic = true;
                interactionNumber = responseNETSMS.data.interactionNumber;
            }

            if (String.isBlank(protocolNumber)) {
                throw new CEC_IntegrationException(
                    'Protocolo não pôde ser criado'
                );
            }
            newCase.InteractionNumber__c = interactionNumber;
             
            // Criar novo Account e contact
            if( acc.Id == null ){
                insert acc;
                if(ctt != null){
                    //Se temos que inserir o contact e vincular ao novo Case
                    ctt.AccountId = acc.Id;
                    insert ctt;
                    newCase.ContactId = ctt.Id;
                }
                
            }
            // Agora que temos certeza que o account já existe, vinculamos ao caso que vamos inserir
            // parte da atribuição a fila
            CEC_LGPDdsar__mdt[] LGPDdsar = [SELECT PerfilOuvidoria__c, HasOmniChannel__c FROM CEC_LGPDdsar__mdt WHERE DeveloperName = :RequestType];

            String lgpdQueueStr = UserInfo.getUserId();
            List<Group> lgpdQueue = new List<Group>();

            if (!LGPDdsar[0].HasOmniChannel__c) {

                Profile[] profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            
                Boolean result =  !LGPDdsar.isEmpty() && String.isNotBlank(LGPDdsar[0].PerfilOuvidoria__c) && LGPDdsar[0].PerfilOuvidoria__c.contains(profile[0].name + ';');
                String queueName = result ? 'LGPD_OUV_ROTEAMENTO_AUTOMATICO':'LGPD_SF_AUTOMATIZADO';
                
                lgpdQueue = [select Id from Group where Type = 'Queue' AND DeveloperNAME = : queueName ];
                lgpdQueueStr = !lgpdQueue.isEmpty() ? lgpdQueue[0].id : UserInfo.getUserId();
    
            }

            newCase.AccountId = acc.Id;
            newCase.OwnerId = lgpdQueueStr;

            Savepoint sp = Database.setSavepoint();

            try{
                insert newCase;

                vlocity_cmt__CustomerInteraction__c customerInteraction = createCustomerInteraction(
                    acc,
                    protocolNumber
                );

                Case insertedCase = [SELECT
                Id,
                CaseNumber,
                RecordTypeId,
                Status,
                Subject,
                SuppliedEmail,
                PreferencialContact__c,
                ContactId,
                Channel__c,
                Origin,
                InputType__c,
                AccountId,
                OwnerId
                FROM Case WHERE Id = :newCase.Id
                LIMIT 1];

                //*
                // Customer Interaction Topic
                vlocity_cmt__CustomerInteractionTopic__c interactionTopic = null;

                if (is_createCustomerInteractionTopic) {
                    interactionTopic = createCustomerInteractionTopic(
                        insertedCase,
                        customerInteraction,
                        occurrenceSetting
                    );
                }
                //*/
                
                // Criar TASK para a fila LGPD
              
                if(lgpdQueue.size() > 0){
                    Task varTask = new Task(Priority = 'Alta', Status = 'Completed'); 
                    varTask.Description =  '++++++'+'Foi criada uma solicitação ' + insertedCase.Subject + ' para ' +  acc.Name + '  vinculada ao caso número ' + insertedCase.CaseNumber + ' e ao protocolo ' + legado.name() + ' ' + protocolNumber;
                    varTask.ActivityDate = System.today(); 
                    varTask.WhatId = newCase.Id;
                    varTask.OwnerId = lgpdQueueStr; 
                    varTask.DocumentoCliente__c = acc.DocumentNumber__c;
                    varTask.NomeCliente__c = acc.Name;
                    varTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                    .get('LGPD')
                    .getRecordTypeId();
                    
                    

                    if(contacts != null && contacts.size() > 0){
                        varTask.WhoId = contacts[0].Id;
                    }
                    varTask.Subject = 'Call';

                    insert varTask; 
                    system.debug('Inserted task  >> ' + varTask);
                }

                returnData.data.caseId = newCase.Id;
                returnData.data.protocol = protocolNumber;
                returnData.data.interaction = interactionNumber;
            }catch (Exception ex){
                Database.rollback(sp);
                throw ex;
            }
        } catch (Exception ex) {
            returnData = new LGPDProtocolControllerResponse();
            returnData.data = null;
            returnData.error = new LGPDProtocolControllerError(
                'LGPD Error: ' + ex.getMessage(),
                ex
            );
            return returnData;
           
        }

        system.debug(' >> data ' + returnData);
        return returnData;
    }

    private static CEC_ProtocolNetResponse PS8Protocol(
        Case newCase,
        Account acc,
        Asset[] assetMovel,
        String channel,
        String persona,
        CEC_LGPDdsar__mdt metadata,
        Contact[] contacts
    ) {
        String msisdn = '';
        if (assetMovel.size() > 0) {
            // CLIENTE
            system.debug(' >> Cliente Móvel');
            newCase.LineNumber__c = assetMovel[0].Id;
            // Setar MSISDN com o número do contato móvel
            msisdn = assetMovel[0].MSISDN__c;

        } else {
            system.debug(' >> Cliente Prospect');
            // NÃO CLIENTE (PROSPECT)
            if(String.isNotBlank(acc.Email__c)){
                newCase.SuppliedEmail = acc.Email__c;
            }
            else if(String.isNotBlank(acc.vlocity_cmt__BillingEmailAddress__c)){
                newCase.SuppliedEmail = acc.vlocity_cmt__BillingEmailAddress__c;
            }
            // Preciso encontrar um número de telefone para mandar no campo msisdn. 
            // Procuro nos campos Telefone e Celular, e se não encontrar busco nos contatos relacionados
            if(String.isBlank(acc.Phone)){

                if(String.isBlank(acc.CellPhone__c)) {

                    for(Contact cont : contacts) {
                        
                        if(String.isNotBlank(cont.Phone)) {
                            msisdn = cont.Phone;
                            break;
                        
                        }else if(String.isNotBlank(cont.MobilePhone)) {
                            msisdn = cont.MobilePhone;
                            break;
                            
                        }else if(String.isNotBlank(acc.Phone)){
                            msisdn = acc.Phone;
                        }
                    }
                    
                } else {
                    msisdn = acc.CellPhone__c;
                }
                
            } else {
                msisdn = acc.Phone;
            }

            if(string.isBlank(msisdn)){
                throw new CEC_IntegrationException(
                        'Erro ao criar protocolo PS8 : Nenhum número de contato foi encontrado para o cliente'
                    );
            }
        }
        system.debug('Criar protocolo PS8');
        
        //Inserir PS8
        CEC_ProtocolNetResponse responsePS8 = createProtocolPS8(
            acc,
            channel,
            persona,
            metadata,
            msisdn
        );
        System.debug('RESPONSE PS8 >> ' + responsePS8);
        if (responsePS8.error <> null) {
            throw new CEC_IntegrationException(
                'Erro ao criar protocolo PS8 : ' + responsePS8.error.message
            );
        }
        return responsePS8;
    }

    private static CEC_ProtocolNetResponse NETSMSProtocol(
        Case newCase,
        Account acc,
        Account contractResidencial,
        String channel,
        String persona,
        CEC_LGPDdsar__mdt metadata
    ) {
        // se não houver móvel mas houver residencial:
        // Este campo será utilizado para exibir o ContractMSISDN__c
        newCase.ContractBillingAccount__c = contractResidencial.Id;
        newCase.SuppliedEmail = contractResidencial
            .vlocity_cmt__BillingEmailAddress__c;
        newCase.Contract__c = contractResidencial.ContractNumber__c;
        newCase.BusinessUnit__c = contractResidencial.BusinessUnit__c;

        // Inserir NETSMS
        CEC_ProtocolNetResponse responseNETSMS = createProtocolNETSMS(
            newCase
        );
        system.debug('response NETSMS >> ' + responseNETSMS);
        if (
            responseNETSMS.error != null ||
            responseNETSMS.data == null ||
            responseNETSMS.data.protocolNumber == ''
        ) {
            throw new CEC_IntegrationException(
                'Erro ao criar protocolo NETSMS : ' +
                responseNETSMS.error.message
            );
        }
        system.debug(
            'Criado protocolo NETSMS >>>' + responseNETSMS.data.protocolNumber
        );

        return responseNETSMS;
    }

    /**
     * Monta o objeto Case a partir das informações disponíveis
     */
    private static Case mountCase(
        Account acc,
        CEC_LGPDdsar__mdt metadata,
        Account[] contractsResidencial,
        String channel
    )
    {
        Case newCase = null;
        newCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('LGPD')
                .getRecordTypeId(),
            Status = metadata.caseStatus__c,
            Subject = metadata.rightName__c,
            SuppliedEmail = acc.Email__c,
            PreferencialContact__c = 'Telefone',
            Reason1__c = metadata.reasonCode1__c,
            Reason2__c = metadata.reasonCode2__c,
            Reason3__c = metadata.reasonCode3__c,
            Reason4__c = metadata.reasonCode4__c,
            Reason5__c = metadata.reasonCode5__c 
            //OwnerId = UserInfo.getUserId()
        );
        if (contractsResidencial.size() > 0) {
            newCase.ContractBillingAccount__c = contractsResidencial[0].Id;
            newCase.SuppliedEmail = contractsResidencial[0]
                .vlocity_cmt__BillingEmailAddress__c;
        }

        if(acc.Contacts.size() > 0){
            // Busca um contato para relacionar no caso.
            newCase.ContactId = acc.Contacts[0].Id;
        }

        if(channel == 'Salesforce'){
            // Se channel vier salesforce, significa que o controller foi chamado a partir da tela de privacidade
            newCase.Channel__c = 'Privacidade';
            newCase.Origin = 'Phone';
            newCase.InputType__c = 'Outros';
        }else{
            // No caso de vir da Digital
            newCase.Channel__c = channel;
            newCase.Origin = 'Portal';
            newCase.InputType__c = 'Portal';
        }

        return newCase;
    }

    /**
     * Cria um protocolo no PS8
     * @return CEC_ProtocolNetResponse 
     */
    private static CEC_ProtocolNetResponse createProtocolPS8(
        Account acc,
        String channel,
        String persona,
        CEC_LGPDdsar__mdt metadata,
        String msisdn
    ) {

        ProtocolMovelServiceRequest request = buildPS8Request(
            acc,
            channel,
            persona,
            metadata,
            msisdn
        );
               
        // Versão Callout
        CEC_ProtocolNetResponse CEC_Response = null;
        String protocol;

        HttpResponse response = CEC_HttpReq.sendReq(
            'CEC_OAG_Claro_Protocol',
            request
        );

        try {
            CEC_Response = parseResponse(response);
        } catch (Exception ex) {
            CEC_Response = new CEC_ProtocolNetResponse();
            CEC_Response.data = null;
            CEC_Response.error = new CEC_ProtocolNetResponse.Error();
            CEC_Response.error.message = ex.getMessage();
        }
        //*/
        return CEC_Response;
    }


    /**
     * Cria um request ps8
     */
    private static ProtocolMovelServiceRequest buildPS8Request(
        Account acc,
        String channel,
        String persona,
        CEC_LGPDdsar__mdt metadata,
        String msisdn
    ) {
        ProtocolMovelServiceRequest request = new ProtocolMovelServiceRequest();
        DataRequest data = new DataRequest();
        
        if(channel == 'Salesforce'){
            // Se vir do Salesforce
            data.contactTypeId = 'SOLA';
        }else{
            // Se vir da digital
            data.contactTypeId = 'STCL';
        }
        
        data.companyId = 'Movel';
        data.contactName = acc.Name;
        data.contactEmail = acc.Email__c; 
        //-------| para criação de protocolo PS8 o campo account.Phone é obrigatorio, caso esteja null enviar msisdn |------------
        data.contactTelephoneNumber = acc.Phone != null ? acc.Phone : msisdn;
        
        data.contactReturnType = 'TELEFONE';
        data.channelRequestId = 'INTERNET';
        data.reasonCode1 = metadata.reasonCode1__c;
        data.reasonCode2 = metadata.reasonCode2__c;
        data.reasonCode3 = metadata.reasonCode3__c;
        data.reasonCode4 = metadata.reasonCode4__c;
        data.reasonCode5 = metadata.reasonCode5__c;
system.debug(data);
        data.summary =  metadata.rightName__c;
        data.description = persona;
        data.situation = metadata.PS8status__c.touppercase();
system.debug(data.situation);
        data.result = 'ATENDIDO';

        data.customer = new Customer();
        data.customer.msisdn = msisdn;

        request.data = data;
        
        System.debug('buildPS8Request >>> request >>> ' + request );
        return request;
    }

    private static CEC_ProtocolNetResponse parseResponse(
        HttpResponse varResponse
    ) {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_ProtocolNetResponse response = (CEC_ProtocolNetResponse) parser.readValueAs(
            CEC_ProtocolNetResponse.class
        );

        if (varResponse.getStatusCode() == 200) {
            return response;
        } else {
            if (response.error <> null){
                system.debug('response.error.detailedMessage: '+response.error.detailedMessage);
                throw new CEC_IntegrationException(                    
                    response.error.detailedMessage
                );
            }
            else{
                system.debug('StatusCode: ' + varResponse.getStatusCode() + '| MessageError: ' + varResponse.getBody());
                throw new CEC_IntegrationException(                    
                    'StatusCode: ' + varResponse.getStatusCode() + '| MessageError: ' + varResponse.getBody());
            }
        }
    }

    private static CEC_ProtocolNetResponse createProtocolNETSMS(Case newCase) {

        //Versão callout
        CEC_ProtocolNetRequest request = new CEC_ProtocolNetRequest();
        CEC_ProtocolNetRequest.Data data = new CEC_ProtocolNetRequest.Data();
        data.contractNumber = newCase.Contract__c.substringAfter('/').trim();
        data.operatorCode = newCase.Contract__c.substringBefore('/').trim();
        data.reasonId = '1';
        request.data = data;
        HttpResponse res = CEC_HttpReq.sendReq(
            'CEC_OAG_NET_Protocol',
            request
        );
        CEC_ProtocolNetResponse CEC_Response = parseResponse(res);
        return CEC_Response;
    }


    /**
     * Cria um protocolo de ocorrência
     */
    private static CEC_OcurrencyNetResponse createOccurrency(Case objCase, CEC_ME_OccurrenceSettings__mdt ocurrenceSetting, String interactionNumber, Account acc) {
        CEC_LGPD_OccurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_LGPD_OccurrencyNetService.OcurrencyWrapper();
        ocurrencyInfo.caso = objCase;
        ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
        ocurrencyInfo.ocurrenceSetting = ocurrenceSetting;
        ocurrencyInfo.interactionNumber = interactionNumber;
        ocurrencyInfo.name = acc.Name;

        HttpResponse res = new HttpResponse();
        CEC_OcurrencyNetResponse ocurrencyResponse;
        ocurrencyResponse = CEC_LGPD_OccurrencyNetService.getResponse(ocurrencyInfo);
        System.debug('>> occurrencyResponse >> ' + ocurrencyResponse);
        
        return ocurrencyResponse;
    }

    private static vlocity_cmt__CustomerInteraction__c createCustomerInteraction(
        Account acc,
        String protocolo
    ) {
        vlocity_cmt__CustomerInteraction__c newCustomerInteraction = new vlocity_cmt__CustomerInteraction__c(
            Document_Number__c = acc.documentNumber__c,
            Document_Type__c = acc.DocumentType__c,
            ProtocolNumber__c = protocolo,
            vlocity_cmt__AccountId__c = acc.Id,
            //TypeInteractionGov__c
            vlocity_cmt__Status__c = 'Completed',
            Description__c = '',
            TypeInteractionGov__c = 'Interação com o Cliente',
           
            RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName()
                .get('LGPD')
                .getRecordTypeId()
        );
        insert newCustomerInteraction;
        System.debug(
            'Criado customer interaction >> ' + newCustomerInteraction.Id
        );
        return newCustomerInteraction;
    }

    //*
    private static vlocity_cmt__CustomerInteractionTopic__c createCustomerInteractionTopic(
        Case newCase,
        vlocity_cmt__CustomerInteraction__c interaction, 
        CEC_ME_OccurrenceSettings__mdt occurrenceSetting
    ) {
        vlocity_cmt__CustomerInteractionTopic__c interactionTopic = new vlocity_cmt__CustomerInteractionTopic__c(
            vlocity_cmt__AccountId__c = newCase.AccountId,
            vlocity_cmt__CaseId__c = newCase.Id,
            vlocity_cmt__CustomerInteractionId__c = interaction.Id,
            GroupOccurrence__c = occurrenceSetting.Group__c,
            RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName()
            .get('LGPD')
            .getRecordTypeId(),
            TypeOccurrence__c =  occurrenceSetting.Type__c
        );
        insert interactionTopic;
        System.debug(
            'Criado customer interaction topic >> ' + interactionTopic.Id
        );
        return interactionTopic;
    }
    //*/

    /*
     *  ------------------------------------------------------------
     * Classes responsáveis pela estrutura do retorno do controller
     */
    public class LGPDProtocolControllerResponse {
        public LGPDProtocolControllerResponse() {
            this.data = new LGPDProtocolControllerData();
        }
        public LGPDProtocolControllerError error { get; set; }
        public LGPDProtocolControllerData data { get; set; }
    }
    public class LGPDProtocolControllerError {
        public String message { get; set; }
        public Exception innerException { get; set; }
        public LGPDProtocolControllerError(String message, Exception ex) {
            this.message = message;
            this.innerException = ex;
        }
    }
    public class LGPDProtocolControllerData {
        public String protocol { get; set; }
        public String interaction { get; set; }
        public String caseId { get; set; }
    }

    // -----------------------------------------------------------

    /**
     * Esta classe extende o data request original com mais parâmetros
     */
    public class DataRequest {
        public String contactReturnType { get; set; }
        public String contactTelephoneNumber { get; set; }
        public Customer customer { get; set; }
        
        public String companyId { get; set; }
        public String channelRequestId { get; set; }
        public String situation { get; set; }
        public String reasonCode1 { get; set; }
        public String reasonCode2 { get; set; }
        public String reasonCode3 { get; set; }
        public String reasonCode4 { get; set; }
        public String reasonCode5 { get; set; }
        public String summary { get; set; }
        public String description { get; set; }
        public String contactTypeId { get; set; }
        public String contactName { get; set; }        
        public String contactEmail { get; set; }
        public String result { get; set; }
        
    }


    public class ProtocolMovelServiceRequest
    {
        public DataRequest data { get; set; }
    }

    
    public class Customer {
        public string msisdn { get; set; }
    }
}