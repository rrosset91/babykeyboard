/*
* Autor: RLdO
* Data: 10-dez-2018
* Descrição: CEC FASE 1 COMERCIAL: classe de teste e cobertura da classe CEC_RecordTypeDAO
*/
@isTest
private class CEC_RecordTypeDAOTest
{
  @isTest static void getRecordTypeTest()
  {
    map<String, map<String, String>> lMapRT = CEC_RecordTypeDAO.lMapRT;
    for (String iSObj: lMapRT.keyset())
    {
      map<String, String> lRT = CEC_RecordTypeDAO.lMapRT.get(iSObj);
      for (String iDevName: lRT.keyset())
      {
        Id varIdResult = CEC_RecordTypeDAO.getRecordType(iSobj, iDevName);
        system.assert(varIdResult != null);
      }
    }
  }
}