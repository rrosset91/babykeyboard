@istest
public class ProtocolNet_RequestTest {

  @isTest public static void ProtocolNetTest()
  {
    test.startTest();
         
      ProtocolNet_Request lProtocol = new ProtocolNet_Request();
      lProtocol.Data = new ProtocolNet_Request.Data();
      lProtocol.transactionId = 'transactionId';
      lProtocol.data.contractNumber = 'contractNumber';
      lProtocol.data.operatorCode = 'operatorCode';
      lProtocol.data.protocolNumber = 'protocolNumber';
      lProtocol.data.reasonId = 'reasonId';
    test.stopTest();
  }
}