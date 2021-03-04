/*
* Autor: RLdO
* Data: 31-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para geracao de numeros de protocolo
*/
global without sharing class CEC_ServiceProtocol implements vlocity_cmt.VlocityOpenInterface
{
  private static Integer TRIES = 10, NBR_OF_DIGITS = 8;
  static Id rtComercial = CEC_RecordTypeDAO.getRecordType('vlocity_cmt__CustomerInteraction__c', 'ProtocoloComercial');

  private static vlocity_cmt__GlobalAutoNumberSetting__c getSeed()
  {
    String lYear = String.valueOf(system.today().year());
    vlocity_cmt__GlobalAutoNumberSetting__c lSeed = vlocity_cmt__GlobalAutoNumberSetting__c.getAll().get(lYear),
      lNewSeed = new vlocity_cmt__GlobalAutoNumberSetting__c(Name = lYear, vlocity_cmt__LastGeneratedNumber__c = 0,
      vlocity_cmt__Increment__c = 1, vlocity_cmt__LeftPadDigit__c = '0', vlocity_cmt__MinimumLength__c = NBR_OF_DIGITS);
    lSeed = (lSeed == null) ? lNewSeed : lSeed;
    lSeed.vlocity_cmt__LastGeneratedNumber__c++;
    return lSeed;
  }

  private static String fmtPNSeed(vlocity_cmt__GlobalAutoNumberSetting__c aSeed)
  {
    String lNumber = String.valueOf(Integer.valueOf(aSeed.vlocity_cmt__LastGeneratedNumber__c));
    lNumber = '0'.repeat(NBR_OF_DIGITS - lNumber.length()) + lNumber;
    return String.join(new String[]{ aSeed.Name, lNumber }, '');
  }

  global Boolean invokeMethod(String methodName, Map<String, Object> inputMap,
    Map<String, Object> outMap, Map<String, Object> options)
  {
    generateProtocol(inputMap, outMap, options);
    return true;
  }

  private void generateProtocol(Map<String, Object> input, Map<String, Object> outMap,
    Map<String, Object> options)
  {
    Boolean isSuccess = false;
    vlocity_cmt__GlobalAutoNumberSetting__c lSeed = getSeed();
    vlocity_cmt__CustomerInteraction__c lSvc;

    for (Integer i = 0; i < TRIES; i++)
    {
      lSvc = new vlocity_cmt__CustomerInteraction__c(Name = fmtPNSeed(lSeed));
      if (rtComercial != null) lSvc.RecordTypeId = rtComercial;
      Database.UpsertResult lRes = createProtocol(lSvc);
      if (lRes.isSuccess())
      {
        isSuccess = true;
        break;
      }
      lSeed.vlocity_cmt__LastGeneratedNumber__c++;
    }
    outMap.put('isSuccess', isSuccess);
    if (!isSuccess) return;
    outMap.put('protocol', lSvc);
    database.upsert(lSeed);
  }

  private static Database.UpsertResult createProtocol(vlocity_cmt__CustomerInteraction__c aSvc)
  {
    Database.UpsertResult lRes = database.upsert(aSvc, vlocity_cmt__CustomerInteraction__c.Name, false);
    return lRes;
  }
}