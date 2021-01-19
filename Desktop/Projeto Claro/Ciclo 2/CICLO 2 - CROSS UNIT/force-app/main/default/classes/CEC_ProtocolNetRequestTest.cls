/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 18/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] - [Integração Protocolo Service Test ]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Canais Criticos
* Alterações: Alteração de Nomenclatura da Classe 
*/
@istest
public class CEC_ProtocolNetRequestTest {

  @isTest public static void CEC_ProtocolNetTest()
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
}