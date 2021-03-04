/*
* Autor: RLdO
* Data: 10-dez-2018
* Descrição: CEC FASE 1 COMERCIAL: classe utilitaria para recuperar Ids de tipos de registro
*/
global with sharing class CEC_RecordTypeDAO
{
  @testVisible private static map<String, map<String, String>> lMapRT = new map<String, map<String, String>>();
  static
  {
    for (RecordType iRT: [select Id, SobjectType, DeveloperName from RecordType])
    {
      String lSObj = iRT.SobjectType.toLowerCase();
      map<String, String> lMapSobj = lMapRT.get(lSObj);
      if (lMapSobj == null)
      {
        lMapSobj = new map<String, String>();
        lMapRT.put(lSObj, lMapSobj);
      }
      lMapSobj.put(iRT.DeveloperName, iRT.Id);
    }
  }

  global static String getRecordType(String aSObject, String aDevName)
  {
    String lIdRT = null;
    if (String.isBlank(aSObject)) return lIdRT;
    map<String, String> lMapSobj = lMapRT.get(aSObject.toLowerCase());
    if (lMapSobj != null) lIdRT = lMapSobj.get(aDevName);
    return lIdRT;
  }
}