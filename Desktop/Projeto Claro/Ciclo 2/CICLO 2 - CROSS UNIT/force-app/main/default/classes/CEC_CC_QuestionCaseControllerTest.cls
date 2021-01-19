/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Questionario Controller Case Test]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 22/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Criação do metodo Construtor
*/
@isTest
public class CEC_CC_QuestionCaseControllerTest {
    
    @testSetup
    public static void testSetup()
    {
        Test.startTest();
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.LegacyProtocol__c = null;
        varCase.OperatorCode__c = '003';
        varCase.Contract__c = '382580248';   
        varCase.Company__c = 'NET';
        varCase.RequestSupport__c = 'Request Support Description';        
        Database.insert(varCase);   
        
        Test.stopTest();
    }
    
    @isTest public static void unitTest()
    {
        Case varCase = [SELECT Id, BusinessUnit__c FROM Case LIMIT 1];
        
        System.assertEquals(true, CEC_CC_QuestionCaseController.getCase(varCase.Id) <> null, 'Erro ao resgatar caso');
        
        Map<String,Id> mapRTDetail = CEC_CC_QuestionCaseController.getRecordTypeDetail('Case');
        
        System.assertEquals(true, mapRTDetail.values().size() > 0, 'Erro ao selecionar os tipos de registro do caso');
    }
    
    @isTest public static void getFieldTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, BusinessUnit__c FROM Case LIMIT 1];
        
        varCase.BusinessUnit__c = 'Claro'; 
        database.update(varCase);
        
        List<Quiz__c> lstQuiz = CEC_SobjectFactory.getListQuiz(2);
        Database.insert(lstQuiz);
        
        Test.startTest();
        Map<String, List<String>> mapQuizBusiness = CEC_CC_QuestionCaseController.getField(varCase.Id);
        Test.stopTest();
        
        System.assert(mapQuizBusiness <> null, 'Erro ao selecionar respectivas respostas');
        System.assertEquals(2, mapQuizBusiness.values().size(), 'Get incorreto de quiz para business unit: ' + varCase.BusinessUnit__c);
    }
    
    
    @isTest public static void getFieldIfTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, BusinessUnit__c FROM Case LIMIT 1];
        
        varCase.BusinessUnit__c = 'Claro';
        database.update(varCase);
        
        Quiz__c varQuizClaro = CEC_SobjectFactory.getQuiz(); 
        varQuizClaro.Name = 'QuizClaro';
        Database.insert(varQuizClaro); 
        
        Quiz__c varSubQuizClaro = CEC_SobjectFactory.getQuiz();
        varSubQuizClaro.Name = 'QuizClaro';
        Database.insert(varSubQuizClaro);
        
        test.startTest();
        Map<String, List<String>> mapQuizBusiness = CEC_CC_QuestionCaseController.getField(varCase.Id);  
        test.stopTest();
        
        System.assert(mapQuizBusiness <> null, 'Erro ao selecionar respectivas respostas');        
    }
    
    
    @isTest public static void getQuestionTest()
    {
        Quiz__c varQuizClaro = CEC_SobjectFactory.getQuiz();
        Database.insert(varQuizClaro);
        
        List<ParamQuestion__c> lstParamQuestion = CEC_SobjectFactory.getListParamQuestion(4, varQuizClaro);
        Database.insert(lstParamQuestion);
        
        Test.startTest();
        List<ParamQuestion__c> lstGetParamQuestion = CEC_CC_QuestionCaseController.getQuestion(varQuizClaro.Name, varQuizClaro.SubArea__c);
        Test.stopTest();     
        
        System.assert(true, !lstGetParamQuestion.isEmpty()); 
    }
    
    @isTest public static void CreateCaseChildTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, BusinessUnit__c, SupportArea__c, SupportAreaSub__c, RequestSupport__c FROM Case LIMIT 1];
        
        varCase.BusinessUnit__c = 'NET';
        varCase.SupportArea__c = 'Support Area Description';
        varCase.SupportAreaSub__c = 'Support Area Sub Description';
        database.update(varCase);
        
        Quiz__c varQuiz = CEC_SobjectFactory.getQuiz();
        Database.insert(varQuiz);
        
        List<ParamQuestion__c> lstParamQuestion = CEC_SobjectFactory.getListParamQuestion(1,varQuiz);
        Database.insert(lstParamQuestion);
        
        Test.startTest();
        String varReturn = CEC_CC_QuestionCaseController.CreateCaseChild(varCase);
        Test.stopTest();
        
        System.assert(varReturn.contains('Cadastro realizado com sucesso!'), 'Erro ao criar caso filho: ' + varReturn);
        
    }
    
    @isTest public static void CreateCaseSupportTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, Contract__c, Company__c, BusinessUnit__c, SupportArea__c,
                        AdditionalInformation__c, SupportAreaSub__c, RequestSupport__c
                        FROM Case LIMIT 1];
        
        varCase.BusinessUnit__c = 'Embratel';
        varCase.Product__c = 'TUP';       
        database.update(varCase);
        
        Quiz__c varQuiz = CEC_SobjectFactory.getQuiz();
        Database.insert(varQuiz);
        
        List<ParamQuestion__c> lstParamQuestion = CEC_SobjectFactory.getListParamQuestion(1,varQuiz);
        Database.insert(lstParamQuestion);     
        
        Test.startTest();
        String varReturn = CEC_CC_QuestionCaseController.CreateCaseSupport(varCase);
        Test.stopTest();
        
        System.assert(varReturn.contains('Cadastro realizado com sucesso!'), 'Erro ao criar caso de apoio: ' + varReturn);
    }  
    
    @isTest public static void CreateCaseReopenTest()
    {
        
        SubjectAdministration__c atendimento = new SubjectAdministration__c();
        atendimento.Name = 'REABERTURA';
        atendimento.Reason__c = 'REABERTURA';
        atendimento.BusinessUnit__c = 'Claro;Claro DTH;Embratel;NET';
        atendimento.ReopeningSubject__c = true;
        Atendimento.Classification__c = 'TUP;Banda Larga;Claro Fone;Claro TV Livre;Controle;Corp;Claro Fixo;Claro Flex;' +
            						    'Grandes Empresas;Claro Internet Casa;Claro NET Fone;Claro NET TV;Claro NET Vírtua;' +
            						    'Claro TV;Controle Fácil;Corp TB;LD;Claro PME;Pós;Pré;TUP;Sem produto';
        atendimento.SubReason__c = 'FECHADO SEM RESOLUÇÃO';
        database.insert(atendimento);        
        
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, Contract__c, Company__c, BusinessUnit__c, SupportArea__c, SupportAreaSub__c, RequestSupport__c, CriticalChannelOpenDate__c FROM Case LIMIT 1];
        
        varCase.Input_Subject__c = atendimento.Id;
        
        database.update(varCase);         
        
        Test.startTest();
        
        List<Map<String, String>> lstReopenSubjects = CEC_CC_QuestionCaseController.getReopenSubject();
        
        String varReturn = CEC_CC_QuestionCaseController.CreateCaseReopen(varCase);
        Test.stopTest();
        
        System.assert(lstReopenSubjects.size() > 0, 'Erro ao cadastrar motivos de reabertura');
        System.assert(varReturn.contains('Cadastro realizado com sucesso!'), 'Erro ao criar caso de reabertura: ' + varReturn);
    }      
    
    @isTest public static void CreateCaseChildErroTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, AccountId, ContactId FROM Case LIMIT 1];
        
        varCase.AccountId = null;    
        varCase.ContactId = null;
        
        Test.startTest();
        String varReturn = CEC_CC_QuestionCaseController.CreateCaseChild(varCase);
        Test.stopTest();
        
        System.assert(varReturn.contains('Erro'), 'Erro ao acionar try/catch na inserção de caso filho.');  
    }
    
    @isTest public static void CreateCaseSupportErroTest()
    {
        Account varAccount = [SELECT Id FROM Account LIMIT 1];
        Case varCase = [SELECT Id, AccountId, ContactId FROM Case LIMIT 1];
        
        varCase.AccountId = null;    
        varCase.ContactId = null;
        
        Test.startTest();
        String varReturn = CEC_CC_QuestionCaseController.CreateCaseSupport(varCase);
        Test.stopTest();
        
        System.assert(varReturn.contains('Erro'), 'Erro ao acionar try/catch na inserção de caso filho.');        
    }
}