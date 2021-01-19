/*---------------------------------------------------------------------------------------------------------------
--- Company: Sysmap Solutions
--- Author: Squad Evolutiva = Alexandre Augusto da Costa Farias
--- Update for: Alexandre Augusto da Costa Farias / Bruno Wedderhoff Tissi / David Samerson Sousa Castilho
--- Description: Teste da classe responsável por por controlar protocolos e InteractionId recebidos pela URA "CTI".
--- CreateDate: 01/06/2019
--- UpdateDate: 21/10/2020 - Demanda CTI - Ajuste de duplicidade no CustomerInteractionId.
--- Version: 1.1
---------------------------------------------------------------------------------------------------------------*/

@isTest
public class CEC_ME_ProtocolControllerTest {
    
    @TestSetup
    static void makeData(){
        
        // Pega Id dos RecordTypes para criar massa de dados
        Id accountTypeConsumer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Id accountTypeBilling = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

        // Cria conta pai como massa de teste
        Account contaPai = new Account();
        contaPai.Name = 'CEC_ME_ProtocolControllerTest_Pai';
        contaPai.RecordTypeId = accountTypeConsumer;
        insert contaPai;

        // Cria conta como massa de teste
        Account conta = new Account();
        conta.Name = 'CEC_ME_ProtocolControllerTest';
        conta.ParentId = contaPai.Id;
        conta.BusinessUnit__c = 'Net';
        conta.CityCode__c = '003';
        conta.RecordTypeId = accountTypeBilling;
        conta.ContractReferenceNumber__c = '382574116';
        insert conta;

        // Cria um registro de Customer Interaction como massa de teste
        vlocity_cmt__CustomerInteraction__c newCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
        newCustomerInteraction.ProtocolNumber__c = '202033783';
        newCustomerInteraction.vlocity_cmt__AccountId__c = conta.Id;
        insert newCustomerInteraction;

    }

    @isTest
    public static void paginaBuscaTeste(){
        // Testa o caminho com dados faltantes na URL que deve encaminhar para a pagina de busca de clientes
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol'));
        System.currentPageReference().getParameters().put('contractnumber', '382574116');
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/n/Buscar_Cliente', pageTest.getUrl());
    }

    @isTest
    public static void paginaBuscaTesteQueryError(){
        // Testa o caminho com dados na URL que resultem em QueryError pois a consulta nao retornara nenhum dado
        // deve resultar no redirecionamento tambem para a pagina de busca de clientes
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol'));
        System.currentPageReference().getParameters().put('contractnumber', 'testQueryError');
        System.currentPageReference().getParameters().put('cityCode', 'testQueryError');
        System.currentPageReference().getParameters().put('BusinessUnit', 'testQueryError');
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/n/Buscar_Cliente', pageTest.getUrl());
    }

    @isTest
    public static void paginaDadosContaPai(){
        // Testa o caminho com todos dados corretos na URL e verifica o redirecionamento para a pagina
        // de dados da conta pai criada na massa de teste apos a criacao de um protocolo e um customer interaction
        Account contaPai = new Account();
        contaPai = [SELECT Id FROM Account WHERE Name='CEC_ME_ProtocolControllerTest_Pai' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol'));
        System.currentPageReference().getParameters().put('contractnumber', '382574116');
        System.currentPageReference().getParameters().put('cityCode', '003');
        System.currentPageReference().getParameters().put('BusinessUnit', 'Net');
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/r/Account/'+ contaPai.Id + '/view', pageTest.getUrl());
    }

    @isTest
    public static void paginaDadosContaPaiSemCustomerId(){
        // Testa o caminho sem o customerInteractionId na URL e verifica o redirecionamento para a pagina
        // de dados da conta pai criada na massa de teste apos a criacao apenas de um protocolo (sem criar customer interaction)
        Account contaPai = new Account();
        contaPai = [SELECT Id FROM Account WHERE Name='CEC_ME_ProtocolControllerTest_Pai' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol'));
        System.currentPageReference().getParameters().put('contractnumber', '382574116');
        System.currentPageReference().getParameters().put('cityCode', '003');
        System.currentPageReference().getParameters().put('BusinessUnit', 'Net');
        System.currentPageReference().getParameters().put('protocolnumber', '202033783');
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/r/Account/'+ contaPai.Id + '/view', pageTest.getUrl());
    }

    @isTest
    public static void paginaDadosContaPaiSemProtocolo(){
        // Testa o caminho sem o protocolo na URL e verifica o redirecionamento para a pagina
        // de dados da conta pai criada na massa de teste apos a criacao apenas de um customer interaction (sem criar um protocolo)
        Account contaPai = new Account();
        contaPai = [SELECT Id FROM Account WHERE Name='CEC_ME_ProtocolControllerTest_Pai' LIMIT 1];
        vlocity_cmt__CustomerInteraction__c customerInteraction = new vlocity_cmt__CustomerInteraction__c();
        customerInteraction = [SELECT Id FROM vlocity_cmt__CustomerInteraction__c WHERE ProtocolNumber__c = '202033783' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol'));
        System.currentPageReference().getParameters().put('contractnumber', '382574116');
        System.currentPageReference().getParameters().put('cityCode', '003');
        System.currentPageReference().getParameters().put('BusinessUnit', 'Net');
        System.currentPageReference().getParameters().put('c__customerinteraction', customerInteraction.Id);
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/r/Account/'+ contaPai.Id + '/view', pageTest.getUrl());
    }

}