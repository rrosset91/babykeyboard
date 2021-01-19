/*
* Autor: RLdO
* Data: 23-nov-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar datas disponiveis para portabilidade
*/
global without sharing class CEC_IntegrationPortWindows
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'JanelaPortabilidade', Method__c = 'GET',
      Endpoint__c = 'callout:OAGJanelaPortabilidade', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('JanelaPortabilidade');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.WindowsPortability consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.WindowsPortability lRes = new CEC_RestObjects.WindowsPortability();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.port-windows.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.WindowsPortability.class);
      lRes = (CEC_RestObjects.WindowsPortability)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.WindowsPortability genResponseError(String aMsg, String aHttpCode)
  {
    system.debug(aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.WindowsPortability lRes = new CEC_RestObjects.WindowsPortability();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.WindowsPortability generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.WindowsPortability generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);

    CEC_RestObjects.WindowPortabilityType lTipo = new CEC_RestObjects.WindowPortabilityType();
    lTipo.startDate = system.now().addDays(1).format('yyyy-MM-dd HH:mm:ss').replace(' ', 'T');
    lTipo.availableMobileIndicator = 'true';
    lTipo.availableLandlineindicator = 'true';

    CEC_RestObjects.WindowsPortabilityObj lPortObj = new CEC_RestObjects.WindowsPortabilityObj();
    lPortObj.windowPortability = new list<CEC_RestObjects.WindowPortabilityType>{ lTipo };

    CEC_RestObjects.WindowsPortabilityData lPortData = new CEC_RestObjects.WindowsPortabilityData();
    lPortData.windowsPortability = lPortObj;

    CEC_RestObjects.WindowsPortability lPortabilidade = new CEC_RestObjects.WindowsPortability();
    lPortabilidade.apiVersion = '1';
    lPortabilidade.transactionId = '1';
    lPortabilidade.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lPortData;
    lPortabilidade.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lPortabilidade;
  }
}