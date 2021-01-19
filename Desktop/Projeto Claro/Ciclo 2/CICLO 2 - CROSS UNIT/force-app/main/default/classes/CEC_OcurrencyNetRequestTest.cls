/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Ocorrência Request Test]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe  
*/


@istest
public class CEC_OcurrencyNetRequestTest {

  @isTest public static void OcurrencyNetTest()
  {
    test.startTest();
      CEC_OcurrencyNetRequest lOcurrency = new CEC_OcurrencyNetRequest();
      lOcurrency.transactionId = 'transactionId';
      lOcurrency.application = 'application';
      
      lOcurrency.Data = new CEC_OcurrencyNetRequest.Data();
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
    system.assert(lOcurrency.application.contains('application'));
  }
}