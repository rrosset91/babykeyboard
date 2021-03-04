@istest
public class OcurrencyNet_RequestTest {

  @isTest public static void OcurrencyNetTest()
  {
    test.startTest();
      OcurrencyNet_Request lOcurrency = new OcurrencyNet_Request();
      lOcurrency.transactionId = 'transactionId';
      lOcurrency.application = 'application';
      
      lOcurrency.Data = new OcurrencyNet_Request.Data();
      lOcurrency.data.login = 'login';
      lOcurrency.data.note = 'note';
      lOcurrency.data.sourceEvent = 'sourceEvent';
      lOcurrency.data.identifier = 'identifier';
      lOcurrency.data.identifierType = 'identifierType';
      lOcurrency.data.description = 'description';
      lOcurrency.data.name = 'name';
      lOcurrency.data.areaCode = 'areaCode';
      lOcurrency.data.telephoneNumber = 'telephoneNumber';
      lOcurrency.data.extensionNumber = 'extensionNumber';
      lOcurrency.data.telephoneType = 'telephoneType';
      lOcurrency.data.contractNumber = 'contractNumber';
      lOcurrency.data.operatorCode = 'operatorCode';
      lOcurrency.data.cityId = 'cityId';
      lOcurrency.data.MACAddress = 'MACAddress';
      lOcurrency.data.AliasDatabase = 'AliasDatabase';
      lOcurrency.data.protocol = 'protocol';
      lOcurrency.data.interactionNumber = 'interactionNumber';
      lOcurrency.data.contractName = 'contractName';
      
    test.stopTest();     
  }
}