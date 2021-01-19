@isTest
public class ProtocolNet_ResponseTest {
    
  @isTest public static void ProtocolNetTest()
  {
    test.startTest();
         
      ProtocolNet_Response lProtocol = new ProtocolNet_Response();
      lProtocol.Data = new ProtocolNet_Response.Data();
      //lProtocol.Data.interaction = new ProtocolNet_Response.Interaction();
      lProtocol.Error = new ProtocolNet_Response.Error();
      //lProtocol.Interaction = new ProtocolNet_Response.Interaction();
      //lProtocol.interaction.protocol = 'protocol';
      //lProtocol.interaction.interactionNumber = 'interactionNumber';
              
      lProtocol.apiVersion = 'apiVersion';
      lProtocol.transactionId = 'transactionId';
        
      //lProtocol.data.protocolNumber = 'protocolNumber';
      //lProtocol.data.interactionNumber = 'interactionNumber';
      
      lProtocol.error.httpCode = 'httpCode';
      lProtocol.error.errorCode = 'errorCode';
      lProtocol.error.message = 'message';
      lProtocol.error.detailedMessage = 'detailedMessage';
      lProtocol.error.Link = new ProtocolNet_Response.Link();
      lProtocol.error.link.rel = 'rel';
      lProtocol.error.link.href = 'href';
    test.stopTest();      
  }


}