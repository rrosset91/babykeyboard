/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Protocolo Service Test]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 22/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Criação do metodo Construtor
*/
@istest
private class CEC_ProtocolNetServiceTest 
{
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Protocol', 'https://apiuat.net.com.br:7443/sdp/interactions', 
                                                                              'POST','x1234','APP_SALESFORCE_CEC');
        insert varServiceParameter;
        
        Contact varContact = CEC_SobjectFactory.getContact();
        insert varContact;
        
        Case varCase = CEC_SobjectFactory.getCase(varContact);
        insert varCase;

        insert new ServiceParameter__c(
            Name = 'ProtocolNet',
            EndPoint__c = '	https://dev.net.com/oag/sdp/interactions',
            IsActive__c = false,
            Method__c ='POST'
            );
    }
    
    @istest 
    private static void getResponseTest()
    {     
      Case varCase = [SELECT Id, ContractMSISDN__c FROM Case LIMIT 1];
      
      test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_ProtocolNetResponse lReq = CEC_ProtocolNetService.getResponse(varCase);        
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));
      system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));
    }
    
    @istest 
    private static void getResponseErrorTest()
    {          
       Case varCase = [SELECT Id, ContractMSISDN__c FROM Case LIMIT 1];
    		varCase.Contract__c = 'ssdsdsd'; 
        	varCase.BusinessUnit__c = 'NET';
         update varCase;
      test.startTest();
          Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
          CEC_ProtocolNetService TesteConstrutor = new CEC_ProtocolNetService(); //Teste Construtor
          CEC_ProtocolNetResponse lReq = CEC_ProtocolNetService.getResponse(varCase);
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));
      system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));
    }    
    
    @isTest 
    private static void ProtocolNetTest()
    {
        test.startTest();
        
        CEC_ProtocolNetRequest lProtocol = new CEC_ProtocolNetRequest();
        lProtocol.Data = new CEC_ProtocolNetRequest.Data();
        lProtocol.transactionId = 'transactionId';
        lProtocol.data.contractNumber = 'contractNumber';
        lProtocol.data.operatorCode = 'operatorCode';
        lProtocol.data.protocolNumber = 'protocolNumber';
        lProtocol.data.reasonId = 'reasonId';
      test.stopTest();
      system.assert(lProtocol.transactionId.contains('transactionId'));
    }

        @istest 
    private static void getResponseLGPD()
    {     
      Case varCase = [SELECT Id, ContractMSISDN__c FROM Case LIMIT 1];
      
      test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_ProtocolNetResponse lReq = CEC_ProtocolNetService.getResponseLGPD(varCase);        
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));
      system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));
    }
    
           @istest 
    private static void getResponse()
    {     
      Case varCase = [SELECT Id, ContractMSISDN__c FROM Case LIMIT 1];
      
      test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_ProtocolNetResponse lReq = CEC_ProtocolNetService.getResponse(varCase);        
      test.stopTest();
      //system.assert(lReq.apiVersion.contains('1'), JSON.serialize(lReq));
      system.assert(String.isNotBlank(lReq.apiVersion), JSON.serialize(lReq));
    }
    
        
    private static CEC_ProtocolNetResponse parseResponseL(HttpResponse varResponse)
    {
        JSONParser parser = JSON.createParser(varResponse.getBody());
        CEC_ProtocolNetResponse response = (CEC_ProtocolNetResponse) parser.readValueAs(CEC_ProtocolNetResponse.class);
        if(varResponse.getStatusCode() == 200)
        {            
            return response;
        }else
        {
            throw new CEC_IntegrationException(response.error.detailedMessage);
        }
    }
    @IsTest
    private static void getResponseContract(){
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        Test.startTest();
        CEC_ProtocolNetResponse response = CEC_ProtocolNetService.getResponse('013', '123456789');
        system.assertNotEquals(null, response.data);
        system.assertEquals('076123123123123', response.data.protocolNumber);
        Test.stopTest();
        
    }
}