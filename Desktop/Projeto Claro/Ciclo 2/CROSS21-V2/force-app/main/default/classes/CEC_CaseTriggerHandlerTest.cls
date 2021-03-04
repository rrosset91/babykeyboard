/*
* Autor: Squad Canais Criticos + Deloitte
* Data: 12/09/2018
* Descrição: [CEC - Release 1 ] + [Time: SQUAD Canais Criticos - Sprint 1,2,3] + [Regras de Casos]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 12/02/2019
* Autor: Squad Canais Criticos
* Alterações: Metodo de encerramento de ocorrência apagado, pois não está sendo mais usado 
* ---------------------------------------------------------------
* Data: 22/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Criação do metodo Construtor
* ---------------------------------------------------------------
* Data: 23/12/2020
* Autor: Squad Canais Criticos
* Alterações: Teste das alterações nos campos Status e Sub-Status do Caso (Melhorias Ouvidoria)
* ---------------------------------------------------------------
*/
@isTest
public class CEC_CaseTriggerHandlerTest  
{    
    
    private static final String RT_GOV_CASO_FILHO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ChildrenCases').getRecordTypeId();
    private static final String RT_GOV_CASO_APOIO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_SuporteApoio').getRecordTypeId();
    
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('OcurrencyNet', 'http://200.169.123.170:9000/corp/contactrecords', 
                                                                                         'POST','claro123','APP_TESTE');
        insert varServiceParameter;
        
        ServiceParameter__c varServiceParameter2 = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         '/contactrecords', 
                                                                                         'POST',
                                                                                         'x1234',
                                                                                         'APP_TESTE');
        varServiceParameter2.NamedCredential__c ='CEC_OAG_NET_Ocurrency';
        insert varServiceParameter2; 
        
        ServiceParameter__c varServiceParameter1 = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_GetOcurrency', 
                                                                                         '/contactrecords', 
                                                                                         'GET',
                                                                                         'x1234',
                                                                                         'APP_TESTE');
        varServiceParameter1.NamedCredential__c ='CEC_OAG_NET_GetOcurrency';
        insert varServiceParameter1;         
        
        List<CEC_CC_Entitlement__c> lstCS_SLA = CEC_SObjectFactory.getAllCSEntitlement();
        insert lstCS_SLA;
    } 
    
    @isTest static void isSemaphoredTest()
    {
        Test.startTest();
            system.assert(!CEC_CC_Util.isSemaphored('someid', 'somefunctionality'), 'provavel erro na semaforizacao');
            system.assert(CEC_CC_Util.isSemaphored('someid', 'somefunctionality'), 'semaforizacao falhou');
        Test.stopTest();
    }
    
    @isTest static void setEntitlementCasoGOVTest()
    {        
        List<SlaProcess> lstSLAProcess = [SELECT Id, Name, Description  FROM SlaProcess
                                          WHERE Name = 'Consumidor_GOV' AND IsActive = TRUE ORDER BY Name LIMIT 1];
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
        
        Entitlement varEntitlement = CEC_SobjectFactory.getEntitlement();
        varEntitlement.Name = 'Consumidor.GOV';
        varEntitlement.SlaProcessId = lstSLAProcess[0].id;
        varEntitlement.AccountId = varAccount.Id;
        Database.insert(varEntitlement);
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.RecordTypeId = CEC_CaseTriggerHandler.RT_CONSUMIDOR_GOV;
        varCase.EntitlementId = varEntitlement.Id;
        varCase.SupportArea__c = null;
        Database.insert(varCase); 
        
        Test.startTest();
            varCase.SubStatus__c = 'Recusa Negada';
            varCase.DatePauseSla__c = System.NOW();
            varCase.MilestoneTime__c = System.NOW() + 1;
            Database.saveResult varResult = Database.update(varCase);
        Test.stopTest();        
        
        System.assertEquals(true, varResult.isSuccess(), 'Erro ao criar caso pai do tipo consumidor gov. ' + varResult.getErrors());
    } 
    
    @isTest public static void setEntitlementCasoFilho2Test()
    {        
        List<SlaProcess> lstSLAProcess = [SELECT Id, Name, Description  FROM SlaProcess
                                          WHERE Name = 'CEC-CC-Suporte-Financeiro' AND IsActive = TRUE ORDER BY Name LIMIT 1];
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
                
        Entitlement varEntitlement = CEC_SobjectFactory.getEntitlement();
        varEntitlement.Name = 'CEC-CC-Suporte-Financeiro';
        varEntitlement.SlaProcessId = lstSLAProcess[0].id;
        varEntitlement.AccountId = varAccount.Id;
        database.insert(varEntitlement);
        
        Test.startTest();
            Case varCase = CEC_SobjectFactory.getCase(varAccount);
            varCase.SupportArea__c = 'FINANCEIRO';
            varCase.RecordTypeId = RT_GOV_CASO_FILHO;
        	Database.saveresult varResult = database.insert(varCase);
        Test.stopTest(); 
        
        System.assertEquals(true, varResult.isSuccess(), 'Erro ao criar caso filho para a área do financeiro. ' + varResult.getErrors());
        
    }    
    @isTest public static void setEntitlementCasoApoioTest()
    {
        List<SlaProcess> lstSLAProcess = [SELECT Id, Name, Description FROM SlaProcess
                                       WHERE Name = 'CEC_CC_SuporteApoio' AND IsActive = TRUE ORDER BY Name LIMIT 1];
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
                
        Entitlement varEntitlement = CEC_SobjectFactory.getEntitlement();
        varEntitlement.Name = 'CEC_CC_SuporteApoio';
        varEntitlement.SlaProcessId = lstSLAProcess[0].id;
        varEntitlement.AccountId = varAccount.Id;
        database.insert(varEntitlement);
        
        Test.startTest();
            Case varCase = CEC_SobjectFactory.getCase(varAccount);
            varCase.RecordTypeId = RT_GOV_CASO_APOIO;
            varCase.SupportArea__c = null;
            Database.saveResult varResult = Database.insert(varCase);
        Test.stopTest();   
        
        System.assertEquals(true, varResult.isSuccess(), 'Erro ao criar caso de apoio. ' + varResult.getErrors());

    }
    
    
    /***************************************************************************************************************/
    @isTest public static void updateOwnerTest()
    {
        
        list<SlaProcess> lstProcess = [SELECT Id,Name, Description,isactive
                                       FROM SlaProcess
                                       WHERE Name = 'Consumidor_GOV' AND isactive =true  ORDER BY Name limit 1];
        
        Account lAccount = CEC_SobjectFactory.getAccount();
        
        database.insert(lAccount);
        
        Entitlement lEnt = CEC_SobjectFactory.getEntitlement();
        lEnt.Name = 'Consumidor.GOV';
        lEnt.SlaProcessId = lstProcess[0].id;
        lEnt.AccountId = lAccount.Id;
        database.insert(lEnt);
        
        list<Profile> lLstProf = [SELECT Id FROM Profile WHERE PermissionsAuthorApex = true limit 1];
        system.assert(!lLstProf.isEmpty(), 'Erro perfil');
        Id profileTest = lLstProf[0].Id;
        
        user lUser = new user(firstName = 'Teste', lastName = 'Dev Canais', Alias = 'alias', Email = 'teste@claro.com.br', Username = 'rpacc@teste.com.br.devcanais', Profileid = profileTest, LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        lUser.CommunityNickname = lUser.lastName;
        
        database.insert(lUser);
        
        Case lCase = CEC_SobjectFactory.getCase(lAccount);
        lCase.EntitlementId = lEnt.Id;
        lCase.OwnerId = lUser.Id;
        database.insert(lCase);
        
        test.startTest();
        lCase.SubStatus__c = 'Recusa Negada';
        lCase.DatePauseSla__c = system.now();
        database.saveresult lSavRes = database.update(lCase);
        test.stopTest();  
        
        system.debug('lSavRes: ' + lSavRes);
        system.assert(lSavRes.isSuccess());
    }
    
    @isTest public static void getGoalTest()
    {        
        list<SlaProcess> lstProcess = [SELECT Id,Name, Description
                                       FROM SlaProcess                                  
                                       WHERE Name = 'Consumidor_GOV' ORDER BY Name limit 1];
        
        Account lAccount = CEC_SobjectFactory.getAccount();
        
        database.insert(lAccount);
        
        Entitlement lEnt = CEC_SobjectFactory.getEntitlement();
        lEnt.Name = 'Consumidor.GOV';
        lEnt.SlaProcessId = lstProcess[0].id;
        lEnt.AccountId = lAccount.Id;
        database.insert(lEnt);
        
        Case lCase = CEC_SobjectFactory.getCase(lAccount);
        lCase.RecordTypeId = CEC_CaseTriggerHandler.RT_CONSUMIDOR_GOV;
        database.insert(lCase);
        
        Goal__C lGoal = CEC_SobjectFactory.getGoal(UserInfo.getUserId());
        database.insert(lGoal);
        
        test.startTest();
        lCase.Status = 'Answered';
        database.saveresult lSavRes = database.update(lCase);
        test.stopTest();        
        system.assert(lSavRes.isSuccess());        
    }  

    @isTest static void closeCaseLGPDTest()
    {        
        ServiceParameter__c sp = new ServiceParameter__c();

        sp.Name                     = 'Consents_Parameters';
        sp.clientAuth2__c			= 'test';
        sp.clientAuth__c			= 'test';
        sp.closeInPS8__c			= true;
        sp.collectionPointId__c	    = '4dcae922-4597-4860-96e1-0a627844cefa';
        sp.preferenceId__c		    = '670bd34e-701f-4794-8040-55fcfabc5774';
        sp.EndPoint__c              = 'test';
        sp.Method__c                = 'test';

        insert sp; 

        Account varAccount = CEC_SobjectFactory.getAccount();

        Product2 produto = CEC_SobjectFactory.getProduct();
        produto.name = 'Claro NET TV';
        insert produto;

        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.RecordTypeId = CEC_CaseTriggerHandler.LGPD;
        varCase.Status = 'Closed';
        varCase.BusinessUnit__c = 'NET';
        varCase.Product__c = 'Claro NET TV';
        varCase.Contract__c = '038/00120940-7';
        varCase.Resolution__c = 'Teste';
        varCase.ProtocolNumber__c = '000000000000000';
        
        try{
        	insert varCase ;
        }catch(Exception ex){
            System.debug('E rror ====>' + Ex.getMessage());
        }

        vlocity_cmt__CustomerInteraction__c interaction = new vlocity_cmt__CustomerInteraction__c();
        interaction.TypeInteractionGov__c = 'Interação com o Cliente';
        interaction.vlocity_cmt__Status__c = 'In Progress';
        insert interaction; 

        vlocity_cmt__CustomerInteractionTopic__c topic = new vlocity_cmt__CustomerInteractionTopic__c();
        topic.vlocity_cmt__CustomerInteractionId__c = interaction.Id;
        topic.vlocity_cmt__CaseId__c = varCase.Id;
        //topic.LGPD_ID__c = 'QSL74AYZCM';
        topic.RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId(); 
        //insert topic;

        String varResult = '';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseCloseNetSmsTest());
            List<Case> lista = new List<Case>();
        	lista.add(varCase);
         	varResult = CEC_CaseTriggerHandler.closeCaseLGPD(lista);
        Test.stopTest();      
        system.debug('varResult: '+varResult);
        System.assertEquals(true, varResult == 'OK' , 'Fechado com sucesso no NETSMS. ');
    }
 
 
    
    @isTest static void closeCaseLGPDOneTrushTest(){   

        ServiceParameter__c sp = new ServiceParameter__c(); 

        sp.Name                     = 'Consents_Parameters';
        sp.clientAuth2__c	    = 'test';
        sp.clientAuth__c	    = 'test';
        sp.closeInPS8__c	    = true;
        sp.collectionPointId__c	    = '4dcae922-4597-4860-96e1-0a627844cefa';
        sp.preferenceId__c          = '670bd34e-701f-4794-8040-55fcfabc5774';
        sp.EndPoint__c              = 'test';
        sp.Method__c                = 'test';
        
        insert sp; 
        
        Account varAccount = CEC_SobjectFactory.getAccount();

        Product2 produto = CEC_SobjectFactory.getProduct();
        produto.name = 'Claro NET TV';
        insert produto;
        
      
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.RecordTypeId = CEC_CaseTriggerHandler.LGPD;
        varCase.Status = 'Open';
        varCase.BusinessUnit__c = 'NET';
        varCase.Product__c = 'Claro NET TV';
        varCase.Contract__c = '038/001209407';
        varCase.Resolution__c = 'Teste';
        varCase.LGPD_ID__c = 'QSL74AYZCM';
        varCase.Resolution__c = 'Comentario do caso';
        try{
        	insert varCase ;
        }catch(Exception ex){
            System.debug('E rror ====>' + Ex.getMessage());
        }
        
        vlocity_cmt__CustomerInteraction__c interaction = new vlocity_cmt__CustomerInteraction__c();
        interaction.TypeInteractionGov__c = 'Interação com o Cliente';
        interaction.vlocity_cmt__Status__c = 'In Progress';
        insert interaction; 

        vlocity_cmt__CustomerInteractionTopic__c topic = new vlocity_cmt__CustomerInteractionTopic__c();
        topic.vlocity_cmt__CustomerInteractionId__c = interaction.Id;
        topic.vlocity_cmt__CaseId__c = varCase.Id;
        //topic.LGPD_ID__c = 'QSL74AYZCM';
        topic.RecordTypeId = Schema.SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId(); 
        insert topic;

        String varResult = '';

        Test.StartTest();

        CEC_360_LGPDIntegrationObjects.PutOrdersStage objectGet = new CEC_360_LGPDIntegrationObjects.PutOrdersStage(); 
        //objectGet.data.currentStage = 'FECHADO';
       
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationManagementTst());
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationOrdersStagesTst()); 
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseCloseNetSmsTest());
        List<Case> lista = new List<Case>();
        lista.add(varCase);
        varResult = CEC_CaseTriggerHandler.closeCaseLGPD(lista);
    
        Test.stopTest();   
    } 
    
    

    @isTest 
    static void createProtocolMovelTest(){
        Account varAccount = CEC_SobjectFactory.getAccount();

        Product2 produto = CEC_SobjectFactory.getProduct();
        produto.name = 'Claro NET TV';
        insert produto;
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.RecordTypeId = CEC_CaseTriggerHandler.LGPD;
        varCase.Status = 'Closed';
        varCase.BusinessUnit__c = 'NET';
        varCase.Product__c = 'Claro NET TV';
        varCase.Contract__c = '038/001209407';
        varCase.Resolution__c = 'Teste';
        try{
        	insert varCase ;
        }catch(Exception ex){
            System.debug('E rror ====>' + Ex.getMessage());
        }

        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseCloseNetSmsTest());
            Set<Id> setCase = new Set<Id>(); 
        	setCase.add(varCase.id);
         	CEC_CaseTriggerHandler.createProtocolMovel(setCase);
        Test.stopTest();         
        
    }

    @isTest 
    static void testupdateStatus(){

        Case varCase = new Case();
        varCase.RecordTypeId = CEC_CaseTriggerHandler.CEC_CC_Ouvidoria;
        varCase.Grouping__c = 'Ouvidoria';
        varCase.Channel__c = 'Ouvidoria';
        varCase.BusinessUnit__c = 'Claro';
        varCase.BusinessUnitGroup__c = 'Claro-Internet Móvel';
        varCase.Product__c = 'Banda Larga';
        varCase.ProductFamily__c = 'Claro Móvel';
        varCase.Contract__c = '11999999999';
        varCase.Status = 'New';
        varCase.SubStatus__c = 'Não Iniciado';
        insert varCase;

        Test.startTest();
        
            varCase.Origin = 'Portal';
            varCase.InputType__c = 'Portal';
            varCase.EntryReason__c = 'Test';
            update varCase;

            Case varCaseAfterUpdate = [SELECT id, Status, SubStatus__c FROM Case WHERE Id =: varCase.Id LIMIT 1]; 

            SubjectAdministration__c admAssunto = new SubjectAdministration__c();
            admAssunto.Product__c = 'Test';
            admAssunto.BusinessUnit__c = 'Claro';
            admAssunto.Classification__c = 'Banda Larga';
            insert admAssunto;

            varCase.Output_Subject__c = admAssunto.Id;
            varCase.Relevant__c = 'Sim';
            varCase.Resolution__c = 'Test';
            varCase.PriorAgreement__c = 'Não sem contato com o cliente';
            update varCase;

            Case varCaseAfterSecondUpdate = [SELECT id, Status, SubStatus__c FROM Case WHERE Id =: varCase.Id LIMIT 1]; 

        Test.stopTest();
        
    } 

    @isTest
    static void testUpdateParentStatus(){

        String caseChildMessage;

        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;

        Case parentCase = CEC_SobjectFactory.getCase(varAccount);
        parentCase.RecordTypeId = CEC_CaseTriggerHandler.CEC_CC_Procon;
        parentCase.Grouping__c = 'Procon';
        parentCase.Channel__c = 'Expressinho';
        parentCase.BusinessUnit__c = 'Claro';
        parentCase.BusinessUnitGroup__c = 'Claro-Internet Móvel';
        parentCase.Product__c = 'Banda Larga';
        parentCase.ProductFamily__c = 'Claro Móvel';
        parentCase.Contract__c = '11999999999';
        parentCase.Status = 'New';
        parentCase.SubStatus__c = 'Não Iniciado';
        parentCase.InputType__c = 'PAA';
        parentCase.SupportArea__c = 'ANATEL';
        parentCase.SupportAreaSub__c = 'NÃO ME PERTURBE';
        parentCase.RequestSupport__c = 'testtesttest';
        parentCase.CriticalChannelProtocol__c = '123456';
        insert parentCase;

        caseChildMessage = CEC_CC_QuestionCaseController.CreateCaseChild(parentCase);

        Test.startTest();

            Case parentCaseAfterFirstUpdate = [SELECT id, Status, SubStatus__c FROM Case WHERE Id =: parentCase.Id LIMIT 1];

            List <Case> childCasesList = [SELECT id, Status, SituationCase__c, ParentId FROM Case WHERE ParentId =:parentCase.Id];

            System.assertEquals('In Progress', parentCaseAfterFirstUpdate.Status);
            System.assertEquals('Pendente com Área', parentCaseAfterFirstUpdate.SubStatus__c);
            System.assertEquals('Cadastro realizado com sucesso!', caseChildMessage);

            for (Case varChildCase : childCasesList) {
                varChildCase.Status = 'Closed';
                varChildCase.SituationCase__c = 'Done - Rejected';
            }
            update childCasesList;

            Case parentCaseAfterSecondUpdate = [SELECT id, Status, SubStatus__c FROM Case WHERE Id =: parentCase.Id LIMIT 1];

            System.assertEquals('In Progress', parentCaseAfterSecondUpdate.Status);
            System.assertEquals('Em tratamento', parentCaseAfterSecondUpdate.SubStatus__c); 

        Test.stopTest();

    }
}