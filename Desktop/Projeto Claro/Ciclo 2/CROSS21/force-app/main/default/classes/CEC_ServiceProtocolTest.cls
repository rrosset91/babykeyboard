/*
* Autor: RLdO
* Data: 31-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe de teste e cobertura da classe CEC_ServiceProtocol
*/
@isTest
private class CEC_ServiceProtocolTest
{
  @isTest static void myUnitTest()
  {
    map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
     lOptions = new map<String, Object>();

    test.startTest();
    CEC_ServiceProtocol lInteg = new CEC_ServiceProtocol();
    lInteg.invokeMethod('generateProtocol', lInputMap, lOutMap, lOptions);
    test.stopTest();

    vlocity_cmt__CustomerInteraction__c lSvc = (vlocity_cmt__CustomerInteraction__c)lOutMap.get('protocol');
    system.assert(lSvc != null && String.isNotBlank(lSvc.Id), 'Protocolo nao gerado!');
  }
}