/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Controller Component Protocol]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 08/04/2019  
* Autor: Squad Canais Criticos
* Alterações: Refresh na tela de protocolos
*/
@isTest
public class CEC_CC_CaseProtocolControllerTest 
{   
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varCEC_OAG_NET_Ocurrency = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         	  'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                              			 	  'POST','x1234','APP_SALESFORCE_CEC');
        insert varCEC_OAG_NET_Ocurrency;
        
        ServiceParameter__c varCEC_OAG_NET_Protocol = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Protocol', 
                                                                                              'https://apiuat.net.com.br:7443/sdp/interactions', 
                                                                                              'POST','x1234','APP_SALESFORCE_CEC');
        insert varCEC_OAG_NET_Protocol;
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
        
        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        
        varCase.LegacyProtocol__c    = '42432';
        varCase.OperatorCode__c 	 = '003';
        varCase.Contract__c 		 = '038/382580248';
        varCase.BusinessUnit__c 	 = 'Claro DTH';
        varCase.Product__c 			 = 'Claro Fone';
        varCase.InteractionNumber__c = '1234567890';
        
        Database.insert(varCase);   
    }
    
    @isTest 
    public static void getPicklistvaluesTest()
    {       
        Test.startTest();
        List<String> lstOutput = CEC_CC_CaseProtocolController.getPicklistvalues('Case', 'BusinessUnit__c');
        Test.stopTest();   
        system.assert(lstOutput.contains('Claro'));
    }
    
    @isTest 
    public static void getProtocolGenerateTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c, Product__c FROM Case LIMIT 1];
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
            List<Object> lstOutput = CEC_CC_CaseProtocolController.GetProtocol(varCase);
        Test.stopTest();      
        
        List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = new List<CEC_CC_CaseProtocolController.EntidadeProtocol>(); 
        for(Object obj : lstOutput){
            CEC_CC_CaseProtocolController.EntidadeProtocol varEntidade = (CEC_CC_CaseProtocolController.EntidadeProtocol)obj;
            //System.assert(varEntidade.msgStatus.contains('success'), 'Erro ao gerar protocolo: ' + varEntidade.msgProtocol);  
        }
    }
    
    @isTest 
    public static void getProtocolGenerateErrorTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c, Product__c FROM Case LIMIT 1];
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseErrorTest());
        	List<Object> lstOutput = CEC_CC_CaseProtocolController.GetProtocol(varCase);  
        Test.stopTest();
        
        List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = new List<CEC_CC_CaseProtocolController.EntidadeProtocol>(); 
        for(Object obj : lstOutput){
            CEC_CC_CaseProtocolController.EntidadeProtocol varEntidade = (CEC_CC_CaseProtocolController.EntidadeProtocol)obj;
            System.assert(varEntidade.msgStatus.contains('error'), 'Falha ao simular erro sistêmico: ' + varEntidade.msgProtocol);  
        }
    }
    
    @isTest 
    public static void getUpdateProtocolTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
        
        Test.startTest();
            CEC_CC_CaseProtocolController.getCase(varCase.Id);
            List<Object> lstOutput = CEC_CC_CaseProtocolController.updateProtocol(varCase);
        Test.stopTest();
        
        List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = new List<CEC_CC_CaseProtocolController.EntidadeProtocol>(); 
        for(Object obj : lstOutput){
            CEC_CC_CaseProtocolController.EntidadeProtocol varEntidade = (CEC_CC_CaseProtocolController.EntidadeProtocol)obj;
            system.debug('varEntidade: ' + varEntidade);
            //System.assert(varEntidade.msgStatus.contains('success'), 'Erro ao atualizar o protocolo: ' + varEntidade.msgProtocol);  
        }
    }
    
    @isTest 
    public static void getUpdateProtocolTestNull()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
        varCase.LegacyProtocol__c = null;
        Database.update(varCase);
        
        varCase.LegacyProtocol__c = '382580248';

        Test.startTest();
            CEC_CC_CaseProtocolController.getCase(varCase.Id);
            List<Object> lstOutput = CEC_CC_CaseProtocolController.updateProtocol(varCase);
        Test.stopTest();
        
        List<CEC_CC_CaseProtocolController.EntidadeProtocol> lstProtocol = new List<CEC_CC_CaseProtocolController.EntidadeProtocol>(); 
        for(Object obj : lstOutput){
            CEC_CC_CaseProtocolController.EntidadeProtocol varEntidade = (CEC_CC_CaseProtocolController.EntidadeProtocol)obj;
            system.debug('varEntidade: ' + varEntidade);
            //System.assert(varEntidade.msgStatus.contains('success'), 'Erro ao atualizar o protocolo: ' + varEntidade.msgProtocol);  
        }
    }
    
	
    @isTest 
    public static void getUpdateCaseLegacyTest()
    {       
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
        
        Case varCase2 = [SELECT Id, LegacyProtocol__c FROM Case WHERE Id =: varCase.Id LIMIT 1];
        varCase2.LegacyProtocol__c 	= null;
        Database.update(varCase2);
        
        Test.startTest();
        CEC_CC_CaseProtocolController.getCase(varCase.Id);
            String output = CEC_CC_CaseProtocolController.updateCaseLegacy(varCase);
        Test.stopTest();
        system.debug('output: ' + output);
        //system.assert(output.contains('Protocolo'), JSON.serialize(output));     
    }
    
    
    @isTest 
    public static void getProtocolSaveProcolCaseTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
   
        Case varCase2 = [SELECT Id, LegacyProtocol__c FROM Case WHERE Id =: varCase.Id LIMIT 1];
        varCase2.LegacyProtocol__c 	= null;
        Database.update(varCase2);
        
        Test.startTest();
        List<Object> lstOutput = CEC_CC_CaseProtocolController.getProtocolSaveProcolCase(varCase);     
        Test.stopTest();
        system.debug('lstOutput: ' + lstOutput);
        //system.assert(lstOutput.size() != 0);   
    }
    
    
    @isTest 
    public static void getProtocolExistTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
        
        Test.startTest();
            List<Object> lstOutput = CEC_CC_CaseProtocolController.getProtocolSaveProcolCase(varCase);      
            String output = CEC_CC_CaseProtocolController.updateCaseLegacy(varCase);              
        Test.stopTest();      
        
        system.assert(lstOutput.size() != 0, lstOutput.contains('382580248')); 
        system.assert(output.contains('Protocolo'), JSON.serialize(output));
    }
    
    @isTest public static void getProtocolCaseTest()
    {
        Case varCase = [SELECT Id, Contract__c, LegacyProtocol__c FROM Case LIMIT 1];
        
        Test.startTest();
        	CEC_CC_CaseProtocolController outputConstructor = new CEC_CC_CaseProtocolController();  
       	 List<Object> output = CEC_CC_CaseProtocolController.getProtocolCase(varCase.Id);      
        Test.stopTest();
        
        system.assert(output.size() != 0);
    }
    
    @isTest public static void getProtocolByCaseTest()
    {
        Case varCase = [SELECT Id, BusinessUnit__c, LegacyProtocol__c, CriticalChannelProtocol__c,DateGenerationProtocolLegacy__c, Grouping__c,CreatedDate, LastModifiedDate, InteractionNumber__c FROM Case LIMIT 1];

        Case varCase2 = [SELECT Id, OperatorCode__c, Contract__c, BusinessUnit__c, LegacyProtocol__c, InteractionNumber__c FROM Case WHERE Id =: varCase.Id LIMIT 1];
        varCase2.LegacyProtocol__c 	= null;
        Database.update(varCase2);
        
        Test.startTest();
            CEC_CC_CaseProtocolController outputConstructor = new CEC_CC_CaseProtocolController();  
            List<Object> output = CEC_CC_CaseProtocolController.getProtocolByCase(varCase);      
        Test.stopTest();
        system.debug('output:  ' + output);
        //system.assert(output.size() != 0);
    }
    
    @isTest public static void getTypeProtocolTest()
    { 
        String protocolType;
        Case varCase = [SELECT Id, BusinessUnit__c, Product__c, AccountId FROM Case LIMIT 1];
        
        varCase.BusinessUnit__c = 'Claro';
        varCase.Product__c = 'Controle';
        protocolType = CEC_CC_CaseProtocolController.getTypeProtocol(varCase);
        system.assertEquals('PS8', protocolType, 'Erro na parametrização de protocolos para PS8');
        
        varCase.BusinessUnit__c = 'Claro DTH';
        varCase.Product__c = 'Controle';
        protocolType = CEC_CC_CaseProtocolController.getTypeProtocol(varCase);
        system.assertEquals('NETSMS', protocolType, 'Erro na parametrização de protocolos NETSMS');
        
        varCase.BusinessUnit__c = 'Embratel';
        varCase.Product__c = 'TUP';
        protocolType = CEC_CC_CaseProtocolController.getTypeProtocol(varCase);
        system.assertEquals('Manual', protocolType, 'Erro na parametrização de protocolos Manuais');
    }
}