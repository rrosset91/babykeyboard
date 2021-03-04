/*
 * ---------------------------------------------------------------
 * Data: 29/07/2020
 * Company: Sysmap Solutions
 * Autor: Squad LGPD - Sysmap Solutions [Ello Serafim/Guilherme Cuencas]
 * Descrição: Teste da classe CEC_LGPD_ProtocolController
 * Criação de Protocolo NETSMS/PS8 / Caso / Customer Interaction / Customer Interaction Topic
 * ---------------------------------------------------------------
 * --- Controle de Versão
 * ---------------------------------------------------------------------------------------------------------
 *  Author: Squad LGPD - Sysmap Solutions
 *  Description: Criação de protocolo de Ocorrênccia (NETSMS), customer interaction topic, Task
 *  Date: 20/08/2020
 * ---------------------------------------------------------------------------------------------------------
 *  Author: Squad LGPD - Sysmap Solutions
 *  Description: Criação de protocolo de Ocorrênccia (NETSMS), customer interaction topic, Task
 *  Date: 14/09/2020
 * ---------------------------------------------------------------------------------------------------------
 *  Author: Squad LGPD - Sysmap Solutions
 *  Description: rename da classe de CEC_LGPD_ProtocolControllerTest para CEC_LGPD_ProtocolControllerTest
 *  Date: 21/01/2021
-------------------------------------------------------------------------------------------------------*/

@isTest
global class CEC_LGPD_ProtocolControllerTest {

    public static String occurrenceMockResponse = '{' +
        '"apiVersion": "1;2019-09-24",' +
        '"transactionId": "Id-ffca3b5f94d001a8a879d798",' +
        '"data": {' +
            '"user": {' +
                '"login": "PROD_JD",' +
                '"userName": null,' +
                '"partyId": {' +
                    '"number": null,' +
                    '"type": "CPF"' +
                '},' +
                '"emailcontact": {' +
                    '"emailAddress": null' +
                '},' +
                '"telephoneNumber": {' +
                    '"areaCode": null,' +
                    '"telephoneN    umber": null,' +
                    '"extensionNumber": null' +
                '}' +
            '},' +
            '"eventDate": null,' +
            '"note": "note",' +
            '"sourceEvent": "INTERNET",' +
            '"eventType": {' +
                '"identifier": "861482246",' +
                '"description": null' +
            '},' +
            '"type": {' +
                '"identifier": "717",' +
                '"description": "FECHADA"' +
            '},' +
            '"contact": {' +
                '"user": {' +
                    '"login": null,' +
                    '"userName": null,' +
                    '"partyId": {' +
                        '"number": null,' +
                        '"type": "CPF"' +
                    '},' +
                    '"emailContact": {' +
                        '"emailAddress": null' +
                    '},' +
                    '"telephoneNumber": {' +
                        '"areaCode": null,' +
                        '"number": null,' +
                        '"extensionNumber": null' +
                    '}' +
                '},' +
                '"contactType": {' +
                    '"identifier": null,' +
                    '"description": null' +
                '},' +
                '"name": null,' +
                '"interactionNumber": null,' +
                '"protocol": null,' +
                '"contactMedium": {' +
                    '"telephoneNumber": {' +
                        '"areaCode": null,' +
                        '"number": null,' +
                        '"extensionNumber": null,' +
                        '"type": null' +
                    '},' +
                    '"contactMedium": {' +
                        '"emailContact": {' +
                            '"emailAddress": null' +
                        '},' +
                        '"urbanPropertyAddress": {' +
                            '"addressId": null,' +
                            '"country": null,' +
                            '"placeId": null,' +
                            '"cityId": null,' +
                            '"cityName": null,' +
                            '"postCode": null,' +
                            '"neighborhood": null,' +
                            '"streetType": null,' +
                            '"streetTypeId": null,' +
                            '"streetName": null,' +
                            '"streetNrFirst": null,' +
                            '"urbanPropertySubAddress": null,' +
                            '"complementarySubAddress": null,' +
                            '"boxNr": null' +
                        '}' +
                    '}' +
                '}' +
            '},' +
            '"message": "Sucess"' +
        '}' +
    '}';

    @TestSetup
    static void setup() {
        //Custom settings
        insert new ServiceParameter__c(
            Name = 'CEC_OAG_Claro_Protocol',
            EndPoint__c = '/interactions',
            IsActive__c = true,
            Method__c ='POST',
            NamedCredential__c = 'OAGClaro',
            Timeout__c = 10000
            );

        insert new ServiceParameter__c(
            Name = 'CEC_OAG_NET_Protocol',
            EndPoint__c = '/interactions',
            IsActive__c = true,
            Method__c ='POST',
            NamedCredential__c = 'OAGNet',
            Timeout__c = 10000
            );

        insert new ServiceParameter__c(
            Name = 'CEC_OAG_NET_Ocurrency',
            EndPoint__c = '/contactrecords',
            IsActive__c = true,
            Method__c ='POST',
            NamedCredential__c = 'OAGNet',
            Timeout__c = 10000
            );
    }


    /**
    * Testes NETSMS
    * Teste protocolo NETSMS
    * Conta consumer + contrato residencial
     */
    @isTest
    global static void CEC_LGPD_NetSMSProtocolTest() {
        // Consumer account
        Account consumer = insertConsumerAccount();

        //Billing account
        Account billing = insertBillingAccount(consumer);

        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_NETSMSOccurrenceProtocolMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Bloquear_Dado_Desnecessario',
            'Salesforce'
        );
        Test.stopTest();

        //System.assertEquals(null, prot.error);
        //System.assertEquals('076123123123123', prot.data.protocol);
        //System.assertNotEquals(null, prot.data.interaction);

        // Busca case

        case[] cases = validateCaseCreated(prot, consumer);
        Case c = cases[0];



        //Interaction foi criado
        vlocity_cmt__CustomerInteraction__c[] interactions = validateInteractionCreated(prot, consumer);
        vlocity_cmt__CustomerInteraction__c interaction = interactions[0];

        //Interaction Topic foi criado
        validateInteractionTopicCreated(interaction, c, consumer);

        Contact cc = [SELECT Id, FirstName FROM Contact WHERE AccountId = :consumer.Id][0];
        // Task foi criada
        Task[] tasks = [SELECT Subject, WhatId, WhoId, NomeCliente__c, OwnerId FROM Task WHERE WhatId = :c.Id];
     /*
        System.assert(tasks.size() > 0);
        System.assertEquals(consumer.Name, tasks[0].NomeCliente__c);
        System.assertEquals( cc.Id, tasks[0].WhoId);
        System.assertEquals('Call', tasks[0].Subject);
 */
    }

    @isTest
    global static void CEC_LGPD_NetSMSOccurrencyFailProtocolTest() {
        // Consumer account
        Account consumer = insertConsumerAccount();

        //Billing account
        Account billing = insertBillingAccount(consumer);

        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_NETSMSOccurrenceError500ProtocolMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Bloquear_Dado_Desnecessario',
            'Salesforce'
        );
        Test.stopTest();
       /* System.debug('protocolo gerado >> ');
        System.debug(prot);
        System.assertEquals(null, prot.data);
        System.assert(prot.error.message.contains('detailedMessage'));
        System.assertEquals('500', ((CEC_IntegrationException)prot.error.innerException).httpCode);
        System.assertEquals('API-CONTACTRECORDS-011', ((CEC_IntegrationException)prot.error.innerException).errorCode);
   */
    } 

    /*
    * Teste Protocolo PS8
    * Conta prospect (apenas consumer account, sem contrato móvel nem residencial)
    */
    @IsTest
    global static void CEC_LGPD_ProspectProtocolTest() {
        // Consumer account
        Account customer = insertConsumerAccount();
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            customer,
            'Anonimizar_Dado_Desnecessario',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);
                
        //Interaction foi criado
        vlocity_cmt__CustomerInteraction__c[] interactions = validateInteractionCreated(prot, customer);

        Case[] c = validateCaseCreated(prot, customer);

        validateTaskCreated(c[0], customer);
    }

    /**
     * Parecido com o anterior, mas o telefone não está em nenhum lugar da consumer e sim no Contact associado
     */
    @IsTest
    global static void CEC_LGPD_ProspectPhoneInContactTest() {
        // Consumer account
        Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            DocumentNumber__c = '44080794720',
            vlocity_cmt__BillingEmailAddress__c = 'ello.oliveira@sysmap.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );

        insert customer;

        Contact ctt = new Contact ();
        ctt.FirstName  = customer.Name;
        ctt.LastName = '.';
        ctt.AccountId = customer.Id;
        ctt.DocumentNumber__c =  customer.DocumentNumber__c;
        ctt.DocumentType__c = 'CPF';
        ctt.Email= customer.Email__c;
        ctt.Phone = '81999881122';
        insert ctt;


        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            customer,
            'Consentimento',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);

        Case[] c = validateCaseCreated(prot, customer); 
        System.assertEquals('ello.oliveira@sysmap.com.br', c[0].SuppliedEmail);


        validateInteractionCreated(prot, customer);
        validateTaskCreated(c[0], customer);
    }

    @IsTest
    global static void CEC_LGPD_ProspectPhoneInAccountTest() {
        // Consumer account
        Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            DocumentNumber__c = '44080794720',
            Email__c = 'ello.oliveira@sysmap.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );

        insert customer;

        Contact ctt = new Contact ();
        ctt.FirstName  = customer.Name;
        ctt.LastName = '.';
        ctt.AccountId = customer.Id;
        ctt.DocumentNumber__c =  customer.DocumentNumber__c;
        ctt.DocumentType__c = 'CPF';
        ctt.Email= customer.Email__c;
        ctt.MobilePhone = '81999881122';
        insert ctt;
        
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            customer,
            'Revisao_Decisoes_Automatizadas',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);

        Case[] c = validateCaseCreated(prot, customer);

        System.assertEquals('ello.oliveira@sysmap.com.br', c[0].SuppliedEmail);


        validateInteractionCreated(prot, customer);
        validateTaskCreated(c[0], customer);
    }

    /*
    * Teste vindo da Digital
    * Conta prospect (apenas consumer account, sem contrato móvel nem residencial)
    */
    @IsTest
    global static void CEC_LGPD_ProspectDigitalProtocolTest() {
        // Consumer account
        Account consumer = new Account(
        name = 'Angela Maria da Silva',
        DocumentType__c = 'CPF',
        Phone = '2192372119',
        CellPhone__c = '2192372119',
        DocumentNumber__c = '44080794720',
        Email__c = 'ello.oliveira@sysmap.com.br',
        vlocity_cmt__BillingEmailAddress__c = 'ello.oliveira@sysmap.com.br',
        ExternalID_DL__c = 'CPF44080794720',
        CustomerTypeList__c = 'EX_CLIENTE_ATE6MESES',
        RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
            .get('Consumer')
            .getRecordTypeId()
        );

        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Eliminar_Dado_Desnecessario',
            'MCM-CLUBE'
        );
        Test.stopTest();

        //Customer foi criado
        System.assertNotEquals(null, consumer.Id);

        //Protocolo foi inserido
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);
        
        Case[] c = validateCaseCreated(prot, consumer);

        System.assertEquals('ello.oliveira@sysmap.com.br', c[0].SuppliedEmail);

        Contact[] ctts = [SELECT FirstName, LastName, DocumentNumber__c, DocumentType__c, Email
            FROM Contact 
            WHERE AccountId = :consumer.Id];

        System.assert(ctts.size() > 0);
        System.assertEquals('44080794720', ctts[0].DocumentNumber__c);
        System.assertEquals('Angela', ctts[0].FirstName);
        System.assertEquals('Maria da Silva', ctts[0].LastName);

        validateInteractionCreated(prot, consumer);
        validateTaskCreated(c[0], consumer);
    }
/**
    @IsTest
    static void CEC_LGPD_QueueExists(){
        Test.startTest();
        Group[] lgpdQueue = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'LGPD'];
        Test.stopTest();
        System.assert(lgpdQueue.size() > 0);
    }
    
     * Quando o campo de Billing email não estiver preenchido, e sim EMAIL__c
     */
    
    @IsTest
    global static void CEC_LGPD_ProspectDigitalProtocolNoBillingEmailTest() {
        // Consumer account
        Account consumer = new Account(
        name = 'Angela',
        DocumentType__c = 'CPF',
        Phone = '2192372119',
        DocumentNumber__c = '44080794720',
        Email__c = 'ello.oliveira@sysmap.com.br',
        ExternalID_DL__c = 'CPF44080794720',
        CustomerTypeList__c = 'EX_CLIENTE_ATE6MESES',
        RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
            .get('Consumer')
            .getRecordTypeId()
        );

        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Bloquear_Dado_Desnecessario',
            'MCM-CLUBE'
        );
        Test.stopTest();

        //Customer foi criado
        System.assertNotEquals(null, consumer.Id);

        //Protocolo foi inserido
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);
        
        Case[] c = validateCaseCreated(prot, consumer);

        System.assertEquals('ello.oliveira@sysmap.com.br', c[0].SuppliedEmail);


        Contact[] ctts = [SELECT FirstName, LastName, DocumentNumber__c, DocumentType__c, Email
            FROM Contact 
            WHERE AccountId = :consumer.Id];

        System.assert(ctts.size() > 0);
        System.assertEquals('44080794720', ctts[0].DocumentNumber__c);
        System.assertEquals('Angela', ctts[0].FirstName);
        System.assertEquals('.', ctts[0].LastName);

        validateInteractionCreated(prot, consumer);
        validateTaskCreated(c[0], consumer);
    }

    private static Case[] validateCaseCreated(CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot, Account consumer) {
        Case[] c = [
            SELECT ProtocolNumber__c, ContactPhone, LGPD_MSISDN__c, AccountId, ContactId, Channel__c, Origin, InputType__c, SuppliedEmail
            FROM Case
            WHERE ProtocolNumber__c = :prot.data.protocol
            AND AccountId = :consumer.Id
            ];
        System.assert(c.size()>0);
        return c;
    }

    private static vlocity_cmt__CustomerInteraction__c[] validateInteractionCreated(CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot, Account consumer) {
        vlocity_cmt__CustomerInteraction__c[] interaction = [
            SELECT Document_Number__c, ProtocolNumber__c, vlocity_cmt__AccountId__c 
            FROM vlocity_cmt__CustomerInteraction__c
            WHERE ProtocolNumber__c = :prot.data.protocol 
            AND Document_Number__c = :consumer.DocumentNumber__c
            AND vlocity_cmt__AccountId__c = :consumer.Id];
        System.assert(interaction.size() > 0);
        return interaction;
    }

    private static vlocity_cmt__CustomerInteractionTopic__c[] validateInteractionTopicCreated(vlocity_cmt__CustomerInteraction__c interaction, Case c, Account consumer) {
        vlocity_cmt__CustomerInteractionTopic__c[] topics = [
            SELECT vlocity_cmt__AccountId__c, vlocity_cmt__CaseId__c, vlocity_cmt__CustomerInteractionId__c, GroupOccurrence__c, TypeOccurrence__c, RecordTypeId
            FROM vlocity_cmt__CustomerInteractionTopic__c
            WHERE vlocity_cmt__CaseId__c = :c.Id
            AND vlocity_cmt__CustomerInteractionId__c = :interaction.Id
            AND RecordTypeId = :Schema.SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName()
            .get('LGPD')
            .getRecordTypeId()
            AND vlocity_cmt__AccountId__c = :consumer.Id];
        System.assert(topics.size() > 0);
        return topics;
    }

    private static void validateTaskCreated(Case c, Account consumer) {
        Contact[] cc = [SELECT Id, FirstName FROM Contact WHERE AccountId = :consumer.Id];
        Task[] tasks = [SELECT Subject, WhatId, WhoId, NomeCliente__c, OwnerId FROM Task WHERE WhatId = :c.Id];
        //System.assert(tasks.size() > 0);
        //System.assertEquals(consumer.Name, tasks[0].NomeCliente__c);
       // if(cc.size() > 0){
        //    System.assertEquals( cc[0].Id, tasks[0].WhoId);
        //}
       // System.assertEquals('Call', tasks[0].Subject);
    }

    /**
     * Teste Protocolo PS8
     * Cliente possui apenas contrato móvel
     */
    @IsTest
    global static void CEC_LGPD_MobileProtocolTest(){
        Account consumer = insertConsumerAccount();
        Asset mobileAsset = insertMobileContract(consumer);
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
        );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Acesso_Dados_Consentimento',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.error);
        System.assertNotEquals(null, prot.data);
        System.assertEquals('202010101010', prot.data.protocol);
        //testar caso criado
        System.assertNotEquals(null, prot.data.caseId);
        Case newCase = [SELECT Id, LineNumber__c FROM Case WHERE Id = :prot.data.caseId];
        System.assertEquals(mobileAsset.Id, newCase.LineNumber__c);
        validateTaskCreated(newCase, consumer);
    }



    /**
     * Fail Test
     * Tentar criar protocolo para um tipo de solicitação inválido
     */
    @IsTest
    global static void CEC_LGPD_RequestTypeNotFoundTest() {
        Account consumer = insertConsumerAccount();
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
            );
        Test.startTest();
            CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Request_Type_Invalido',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.data);
        System.assertNotEquals(null, prot.error);
        System.assert(prot.error.message.contains('Não foram encontradas configurações referentes à solicitação'));
    }

    /**
     * Tipo de ocorrrência inválido
     
    @IsTest
    global static void CEC_LGPD_OccurrenceRequestTypeNotFoundTest() {
        Account consumer = insertConsumerAccount();
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_PS8ProtocolResponseMock()
            );
        Test.startTest();
            CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Revogacao_Consentimento',
            'Salesforce'
        );
        Test.stopTest();
        System.assertEquals(null, prot.data);
        System.assertNotEquals(null, prot.error);
        System.assert(prot.error.message.contains('Não foram encontradas configurações de ocorrência referentes à solicitação'));
    }
    */
    @IsTest
    global static void CEC_LGPD_Error500Test() {
        Account consumer = insertConsumerAccount();
        Asset mobileAsset = insertMobileContract(consumer);
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_Error500CalloutMock()
            );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Acesso_Dados_Consentimento',
            'Salesforce'
        );
        Test.stopTest();
        System.assertNotEquals(null, prot.error);
    }

    @IsTest
    global static void CEC_LGPD_Error400Test() {
        Account consumer = insertConsumerAccount();
        Test.setMock(
            HttpCalloutMock.class,
            new CEC_LGPD_Error400CalloutMock()
            );
        Test.startTest();
        CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse prot = CEC_LGPD_ProtocolController.integrateLGPDProtocol(
            consumer,
            'Acesso_Dados_Cadastrais',
            'Salesforce'
        );
        Test.stopTest();
        System.assertNotEquals(null, prot.error);
    }

    /**
     * Mock para erro 500
     */
    global class CEC_LGPD_Error500CalloutMock  implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                // res.setBody('{' +
                // '"apiVersion": "string",'+
                // '  "transactionId": "string",'+
                // '  "error": {'+
                // '    "httpCode": "500",'+
                // '    "errorCode": "string",'+
                // '    "message": "message",'+
                // '    "detailedMessage": "detailedMessage",'+
                // '    "link": {'+
                // '      "rel": "related",'+
                // '      "href": "string"'+
                // '    }'+
                // '  }}');
            
            res.setStatusCode(500);
            return res;
        }
    }

    /**
    * Mock para erro 400
    */
    global class CEC_LGPD_Error400CalloutMock  implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{' +
                '"apiVersion": "string",'+
                '  "transactionId": "string",'+
                '  "error": {'+
                '    "httpCode": "500",'+
                '    "errorCode": "string",'+
                '    "message": "message",'+
                '    "detailedMessage": "detailedMessage",'+
                '    "link": {'+
                '      "rel": "related",'+
                '      "href": "string"'+
                '    }'+
                '  }}');
            
            res.setStatusCode(400);
            return res;
        }
    }

    /**
     * Mock de response de sucesso para ps8
     */
    global class CEC_LGPD_PS8ProtocolResponseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "string",' +
                '"transactionId": "string",' +
                '"data": {' +
                '"protocolNumber": "202010101010",'+
                '"interactionNumber": "123123123"' +
                '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }


    /**
     * 
     */
    private class CEC_LGPD_NETSMSOccurrenceProtocolMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().endsWith('interactions')) {
                res.setBody(
                    '{' +
                    '"apiVersion": "string",' +
                    '"transactionId": "string",' +
                    '"data": {' +
                    '"protocolNumber": "076123123123123",' +
                    '"interactionNumber": "123123123"' +
                    '}' +
                    '}'
                );
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('contactrecords')) {
                res.setBody(CEC_LGPD_ProtocolControllerTest.occurrenceMockResponse);
                res.setStatusCode(200);
                return res;
            }
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
            
        }
    }

    private class CEC_LGPD_NETSMSOccurrenceError500ProtocolMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().endsWith('interactions')) {
                res.setBody(
                    '{' +
                    '"apiVersion": "string",' +
                    '"transactionId": "string",' +
                    '"data": {' +
                    '"protocolNumber": "076123123123123",' +
                    '"interactionNumber": "123123123"' +
                    '}' +
                    '}'
                );
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('contactrecords')) {
                res.setBody('{' +
                '"apiVersion": "string",'+
                '  "transactionId": "string",'+
                '  "error": {'+
                '    "httpCode": "500",'+
                '    "errorCode": "API-CONTACTRECORDS-011",'+
                '    "message": "Internal Server Error",'+
                '    "detailedMessage": "detailedMessage",'+
                '    "link": {'+
                '      "rel": "related",'+
                '      "href": "string"'+
                '    }'+
                '  }}');
            res.setStatusCode(500);
            return res;
            }
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
            
        }
    }

    /**
     * Mock de response de sucesso para NETSMS
     */
    global class CEC_LGPD_NETSMSProtocolResponseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "string",' +
                '"transactionId": "string",' +
                '"data": {' +
                '"protocolNumber": "076123123123123",' +
                '"interactionNumber": "123123123"' +
                '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock de response de sucesso de ocorrência
     */
    global class CEC_LGPD_OccurrenceResponseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{' +
                    '"apiVersion": "1;2019-09-24",' +
                    '"transactionId": "Id-ffca3b5f94d001a8a879d798",' +
                    '"data": {' +
                        '"user": {' +
                            '"login": "PROD_JD",' +
                            '"userName": null,' +
                            '"partyId": {' +
                                '"number": null,' +
                                '"type": "CPF"' +
                            '},' +
                            '"emailcontact": {' +
                                '"emailAddress": null' +
                            '},' +
                            '"telephoneNumber": {' +
                                '"areaCode": null,' +
                                '"telephoneNumber": null,' +
                                '"extensionNumber": null' +
                            '}' +
                        '},' +
                        '"eventDate": null,' +
                        '"note": "note",' +
                        '"sourceEvent": "INTERNET",' +
                        '"eventType": {' +
                            '"identifier": "861482246",' +
                            '"description": null' +
                        '},' +
                        '"type": {' +
                            '"identifier": "717",' +
                            '"description": "FECHADA"' +
                        '},' +
                        '"contact": {' +
                            '"user": {' +
                                '"login": null,' +
                                '"userName": null,' +
                                '"partyId": {' +
                                    '"number": null,' +
                                    '"type": "CPF"' +
                                '},' +
                                '"emailContact": {' +
                                    '"emailAddress": null' +
                                '},' +
                                '"telephoneNumber": {' +
                                    '"areaCode": null,' +
                                    '"number": null,' +
                                    '"extensionNumber": null' +
                                '}' +
                            '},' +
                            '"contactType": {' +
                                '"identifier": null,' +
                                '"description": null' +
                            '},' +
                            '"name": null,' +
                            '"interactionNumber": null,' +
                            '"protocol": null,' +
                            '"contactMedium": {' +
                                '"telephoneNumber": {' +
                                    '"areaCode": null,' +
                                    '"number": null,' +
                                    '"extensionNumber": null,' +
                                    '"type": null' +
                                '},' +
                                '"contactMedium": {' +
                                    '"emailContact": {' +
                                        '"emailAddress": null' +
                                    '},' +
                                    '"urbanPropertyAddress": {' +
                                        '"addressId": null,' +
                                        '"country": null,' +
                                        '"placeId": null,' +
                                        '"cityId": null,' +
                                        '"cityName": null,' +
                                        '"postCode": null,' +
                                        '"neighborhood": null,' +
                                        '"streetType": null,' +
                                        '"streetTypeId": null,' +
                                        '"streetName": null,' +
                                        '"streetNrFirst": null,' +
                                        '"urbanPropertySubAddress": null,' +
                                        '"complementarySubAddress": null,' +
                                        '"boxNr": null' +
                                    '}' +
                                '}' +
                            '}' +
                        '},' +
                        '"message": "Sucess"' +
                    '}' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }



    private static Account insertConsumerAccount(){
        Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            Phone = '2192372119',
            CellPhone__c = '2192372119',
            DocumentNumber__c = '44080794720',
            Email__c = 'ello.oliveira@sysmap.com.br',
            vlocity_cmt__BillingEmailAddress__c = 'ello.oliveira@sysmap.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );

        insert customer;

        Contact ctt = new Contact ();
        ctt.FirstName  = customer.Name;
        ctt.LastName = '.';
        ctt.AccountId = customer.Id;
        ctt.DocumentNumber__c =  customer.DocumentNumber__c;
        ctt.DocumentType__c = 'CPF';
        ctt.Email= customer.Email__c;
        ctt.MobilePhone = customer.Phone;
        insert ctt;

        return customer;
    }

    private static Account insertBillingAccount(Account consumerAccount){
        Account billing = new Account(
            name = 'Angela Maria',
            Type = 'Customer',
            BusinessUnit__c = 'Net',
            CityCode__c = '003',
            ContractReferenceNumber__c = '14358339',
            vlocity_cmt__RootAccountId__c = consumerAccount.Id,
            vlocity_cmt__Status__c = 'Ativo',
            ParentId = consumerAccount.Id,
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Billing')
                .getRecordTypeId()
        );
        insert billing;
        return billing;
    }

    private static Asset insertMobileContract(Account consumerAccount){
        Asset ass = new Asset(
            Status='Ativo',
            Name='Móvel',
            AccountId = consumerAccount.Id,
            RecordTypeId = Schema.Sobjecttype.Asset.getRecordTypeInfosByDeveloperName()
                .get('CECMovelPreControle')
                .getRecordTypeId(),
            MSISDN__c = '81981407803'

        );
        insert ass;
        system.debug(ass.Id);
        return ass;
    }
}