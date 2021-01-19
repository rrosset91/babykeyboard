/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Protocolo Response Test]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: Squad Canais Criticos
* Alterações: UST - 07 
*/

@isTest
public class CEC_ProtocolNetResponseTest {
    
  @isTest public static void CEC_ProtocolNetTest()
  {
    test.startTest();
         
      CEC_ProtocolNetResponse lProtocol = new CEC_ProtocolNetResponse();
      lProtocol.Data = new CEC_ProtocolNetResponse.Data();
      lProtocol.Error = new CEC_ProtocolNetResponse.Error();      
      lProtocol.Data.protocolNumber = 'protocol';
      lProtocol.Data.interactionNumber = 'interactionNumber';
      //lProtocol.Data.interaction = new ProtocolNet_Response.Interaction();
      //lProtocol.Interaction = new ProtocolNet_Response.Interaction();
      //lProtocol.interaction.interactionNumber = 'interactionNumber';
              
      lProtocol.apiVersion = 'apiVersion';
      lProtocol.transactionId = 'transactionId';
        
      //lProtocol.data.protocolNumber = 'protocolNumber';
      //lProtocol.data.interactionNumber = 'interactionNumber';
      
      lProtocol.error.httpCode = 'httpCode';
      lProtocol.error.errorCode = 'errorCode';
      lProtocol.error.message = 'message';
      lProtocol.error.detailedMessage = 'detailedMessage';
      lProtocol.error.Link = new CEC_ProtocolNetResponse.Link();
      lProtocol.error.link.rel = 'rel';
      lProtocol.error.link.href = 'href';
    test.stopTest();    
    system.assert(lProtocol.error.detailedMessage.contains('detailedMessage'));
  }
}