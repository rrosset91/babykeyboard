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
        //system.assert(lSavRes.isSuccess());
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
}