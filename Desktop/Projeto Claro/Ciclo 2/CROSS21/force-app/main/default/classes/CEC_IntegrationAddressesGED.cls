/*
* Autor: RLdO
* Data: 02-jan-2019
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar lista de enderecos a partir do CEP ou do logradouro
*/
global without sharing class CEC_IntegrationAddressesGED
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'AddressesGED', Method__c = 'GET',
      Endpoint__c = 'callout:OAGAddressesGED', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('AddressNew');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.AddressesGED consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.AddressesGED lRes = new CEC_RestObjects.AddressesGED();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.addresses-ged.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      system.debug('lBodyRes'+lBodyRes);  
      map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
        '"streetNumber":' => '"streetAddressNumber":',
        '"city":' => '"cityName":', '"complementarySubAddress":' => '"complementAddress":',
        '"number":' => '"numberZ":' };
      for (String iJsonAttr: lMapResWord.keyset())
      {
        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
      }
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.AddressesGED.class);
      lRes = (CEC_RestObjects.AddressesGED)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.AddressesGED genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationAddressesGED => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.AddressesGED lRes = new CEC_RestObjects.AddressesGED();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.AddressesGED generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.AddressesGED generateMock(URL aURL, Integer aHttpCode)
  {

    CEC_RestObjects.AddressesGED lAddrGed = new CEC_RestObjects.AddressesGED();

    return lAddrGed;
  }
}