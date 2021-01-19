@isTest
public class CEC_CC_CaseDetailControllerTest { 
    
    @testSetup
    public static void setup()
    {        
        Account lAccount = CEC_SobjectFactory.getAccount();
        database.insert(lAccount);
        
        Case lCase = CEC_SobjectFactory.getCase(lAccount);
        lCase.OperatorCode__c = '003';
        lCase.BusinessUnit__c = 'Claro';
        lCase.Product__c = 'Banda Larga';
        lCase.ProtocolNumber__c = '2233';
        lCase.Subject = 'teste';
        lCase.Contract__c = '11999999999';
        lCase.BusinessUnit__c = 'Claro';
        lCase.LegacyProtocol__c = '23323';
        database.insert(lCase);
    }
    
    @isTest 
    public static void testGetCase()
    {        
        Case varCase = [SELECT Id, RejectAmount__c, RejectDescription__c,
                        Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                        BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c FROM Case  LIMIT 1];
        
        test.startTest();        
        CEC_CC_CaseDetailController TesteContrutor = new CEC_CC_CaseDetailController(); 
        Case ReturnCase = CEC_CC_CaseDetailController.GetCase(varCase.Id);
        test.stopTest();
        
        //system.debug('varCase: '+varCase);
        //system.debug('ReturnCase: '+ReturnCase);
        //system.assertEquals(varCase, ReturnCase);
    }
    
    @isTest 
    public static void TesteRequestReject()
    {
        Case varCase = [SELECT Id, RejectAmount__c, RejectDescription__c,
                        Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                        BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c  FROM Case  LIMIT 1];
        
        test.startTest();    
        CEC_CC_CaseDetailController.Wrapperclass testerecusa = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        test.stopTest();
        
        //system.debug('varCase: '+varCase);
        //system.debug('ReturnCase: '+ReturnCase);
        //system.assertEquals(varCase, ReturnCase);
    }
    
    @isTest 
    public static void TesteRequestRejectExpiredDate()
    {
        
        Case varCase = [SELECT Id, RejectAmount__c, RejectDescription__c,
                        Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                        BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c  FROM Case  LIMIT 1];
        varCase.OpenDateRobot__c = Date.valueOf('2009-10-10 00:00:00');        
        update varCase;
        system.debug('varCase: '+ varCase);
        
        test.startTest();    
        CEC_CC_CaseDetailController.Wrapperclass testeRecusa = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        test.stopTest();
        
        System.debug('Prazo para solicitar recusa expirado!');        
        //system.debug('varCase: '+varCase);
        //system.debug('ReturnCase: '+ReturnCase);
        //system.assertEquals(varCase, ReturnCase);
    }
    
    @isTest 
    public static void TesteRequestRejectERRORExisteRecusa()
    {
        Case varCase = [SELECT Id, RejectAmount__c, RejectDescription__c,
                        Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                        BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c  FROM Case  LIMIT 1];      
        // CEC_CC_CaseDetailController.Wrapperclass testerecusa = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        
        test.startTest();
        CEC_CC_CaseDetailController.Wrapperclass testerecusa2 = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        test.stopTest();
    }   
    
    @isTest 
    public static void TesteRequestRejectErrorTryCath()
    {
        Case varCase = new case(); 
        varCase.Contract__c = '382580248';
        varCase.RejectDescription__c=null;
        varCase.OpenDateRobot__c = Date.today(); 
        varCase.ContactPreference__c = 'Telefone';
        varCase.CriticalChannelOpenDate__c = System.now();
        varCase.Status = 'New';
        varCase.SubStatus__c = 'Não Iniciado';
        varCase.SituationCase__c = 'Open';
        insert varCase;
        
        test.startTest();
        CEC_CC_CaseDetailController.Wrapperclass testerecusa = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        test.stopTest();
    }    
    
    @isTest
    public static void TestGetRecordTypeDetail()
    {
        test.startTest();
        Map<String,Id> mapDeveloperRecTypeId = CEC_CC_CaseDetailController.getRecordTypeDetail('Case'); 
        test.stopTest();
    }
    
    @isTest 
    public static void Teste222()
    {
        
        Case varCase = [SELECT Id, RejectAmount__c, RejectDescription__c,
                        Subject, OpenDateRobot__c, Contract__c, LegacyProtocol__c, 
                        BusinessUnit__c, ProtocolNumber__c, Product__c, OperatorCode__c FROM Case  LIMIT 1];
        varCase.RejectDescription__c = null;
        varCase.BusinessUnit__c = null;
        varCase.RejectAmount__c = 0;
        varCase.ProtocolNumber__c = null;
        update varCase;
        
        test.startTest();
        CEC_CC_CaseDetailController.Wrapperclass testerecusa2 = CEC_CC_CaseDetailController.Wrapperclass.RequestReject(varCase);
        test.stopTest();
        
    }    
}