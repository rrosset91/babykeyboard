/*-----------------------------------------------------------------------------------------------------
	--- Company: Deloitte Brazil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela integração com a API contactrecords  
	--- que chama o serviço de geração de ocorrência do NETSMS. 
	---	Created: 18/09/2018
-------------------------------------------------------------------------------------------------------*/
@istest
public class CEC_OcurrencyNetServiceTest {
    
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                              'POST','x1234','APP_SALESFORCE_CEC');
        insert varServiceParameter;
        
        Contact varContact = CEC_SobjectFactory.getContact();
        insert varContact;
        
        Case varCase = CEC_SobjectFactory.getCase(varContact);
        varCase.Subject = 'teste';  
        varCase.LegacyOcurrencyType__c = '794';
        varCase.LegacyProtocol__c = '076123123123123';
        varCase.LegacyOcurrencyDesc__c = 'OV1 - OV5 - OUVIDORIA NIVEL I';
        
        System.debug('varCase >>>>>> '+varCase);
        //Util.insertObjectTriggerDisabled(varCase);
        insert varCase;
    }
      
    @istest 
    private static void getResponseTest()
    {     
      Case varCase = [SELECT Id, Contract__c, ContractMSISDN__c, CaseNumber, Subject, Description, 
                      LegacyOcurrencyType__c, InteractionNumber__c, LegacyOcurrencyDesc__c, LegacyProtocol__c FROM Case LIMIT 1];
      
      test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        
        varCase.InteractionNumber__c = '1234565';
        varCase.LegacyProtocol__c = '004193256376756';
        
        CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
        ocurrencyInfo.caso = varCase;
        ocurrencyInfo.typeOcurrency = 'Open';
        ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
        
        CEC_OcurrencyNetResponse lReq = CEC_OcurrencyNetService.getResponse(ocurrencyInfo);
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));   
      //system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));
    } 
    
    
    @istest 
    private static void getResponseErrorTest()
    {
       Case varCase = [SELECT Id, Contract__c, ContractMSISDN__c, CaseNumber, Subject, Description, 
                       LegacyOcurrencyType__c, InteractionNumber__c, LegacyOcurrencyDesc__c, LegacyProtocol__c FROM Case LIMIT 1];
                  
      test.startTest();
          Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
       	  CEC_OcurrencyNetService	testeContrutor = new CEC_OcurrencyNetService(); //Testando metodo construtor
          
          varCase.InteractionNumber__c = '1234565';
          varCase.LegacyProtocol__c = '004193256376756';
        
          CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
          ocurrencyInfo.caso = varCase;
          ocurrencyInfo.typeOcurrency = 'Open';
          ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
        
          CEC_OcurrencyNetResponse lReq = CEC_OcurrencyNetService.getResponse(ocurrencyInfo);
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));  
      system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));   
    }    
    
    @isTest 
    private static void OcurrencyNetTest()
    {
        test.startTest();
        
        CEC_OcurrencyNetRequest lProtocol = new CEC_OcurrencyNetRequest();
        lProtocol.Data = new CEC_OcurrencyNetRequest.Data();
        lProtocol.transactionId = 'transactionId';
        lProtocol.application = 'application';
        
        lProtocol.data.login = 'MCIDA';
        lProtocol.data.note = 'caso.Subject';
        lProtocol.data.sourceEvent = 'INTERNET';
        lProtocol.data.identifier = '1';
        lProtocol.data.identifierType = '349';
        lProtocol.data.description = 'caso.description';
        lProtocol.data.contractName = 'Teste01';
        lProtocol.data.areaCode = '052';
        lProtocol.data.telephoneNumber = '988881122';
        lProtocol.data.extensionNumber = '';
        lProtocol.data.telephoneType = '';
        lProtocol.data.contractNumber = 'caso.Contract__c.substringAfter(/).trim()';
        lProtocol.data.operatorCode = 'caso.Contract__c.substringBefore(/).trim()';
        lProtocol.data.cityId = '05509';
        lProtocol.data.MACAddress = '';
        lProtocol.data.AliasDatabase 	= '';
        lProtocol.data.protocol = '';	
        lProtocol.data.interactionNumber = ''; 
        
      test.stopTest();
      system.assert(lProtocol.application.contains('application'));
    }
    
    @istest public static void setOcurrencyContactErrorTest()
    {
        
        Contact lContact = CEC_SobjectFactory.getContact();
        Case lCase = CEC_SobjectFactory.getCase(lContact);
        lCase.Contract__c = '577/123456';
        lCase.Subject = 'teste';
        lCase.InteractionNumber__c = '1234565';
        lCase.LegacyProtocol__c = '004193256376756';
        
        test.startTest();
          try{
             
              CEC_OcurrencyNetService.OcurrencyWrapper ocurrencyInfo = new CEC_OcurrencyNetService.OcurrencyWrapper();
              ocurrencyInfo.caso = lCase;
              ocurrencyInfo.typeOcurrency = 'Resolution';
              ocurrencyInfo.serviceName = 'CEC_OAG_NET_Ocurrency';
              
              Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseErrorTest());
              
              CEC_OcurrencyNetResponse lReq = CEC_OcurrencyNetService.getResponse(ocurrencyInfo);
          } catch(Exception ex) {
            //system.assert(ex.getMessage().contains('Error'));  
          }
        test.stopTest();        
    }
   
}