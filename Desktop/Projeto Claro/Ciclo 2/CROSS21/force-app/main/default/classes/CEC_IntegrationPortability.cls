/*
* Autor: RLdO
* Data: 22-nov-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar operadora doadora de um numero para portabilidade
*/
global without sharing class CEC_IntegrationPortability
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'Portabilidade', Method__c = 'GET',
      Endpoint__c = 'callout:OAGPortabilidade', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('Portabilidade');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.Portability consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.Portability lRes = new CEC_RestObjects.Portability();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.portability.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.Portability.class);
      lRes = (CEC_RestObjects.Portability)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.Portability genResponseError(String aMsg, String aHttpCode)
  {
    system.debug(aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.Portability lRes = new CEC_RestObjects.Portability();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.Portability generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.Portability generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);
    CEC_RestObjects.CustomerPhones lTelefone = new CEC_RestObjects.CustomerPhones();
    lTelefone.phoneLineNumber = lMapArgs.get('phoneLineNumber');

    CEC_RestObjects.PortReqTickets lTickets = new CEC_RestObjects.PortReqTickets();
    lTickets.phoneLineNumberType = lTelefone;

    CEC_RestObjects.MobileCarrier lOperadora = new CEC_RestObjects.MobileCarrier();
    lOperadora.carrierName = 'OutraOperadora';
    //lOperadora.name = 'OutraOperadora';
    lOperadora.routingNumber1Code = '1';
    lOperadora.spidCode = '1';

    CEC_RestObjects.PortabilityPhoneType lPtType = new CEC_RestObjects.PortabilityPhoneType();
    lPtType.sourcePortabilityIndicator = 'false';
    lPtType.detail = '';
    lPtType.actualMobileCarrier = lOperadora;
    //lPtType.donorOperator = lOperadora;
    lPtType.requestedTickets = lTickets;

    CEC_RestObjects.PortabilityData lPtData = new CEC_RestObjects.PortabilityData();
    lPtData.phoneType = new list<CEC_RestObjects.PortabilityPhoneType>{ lPtType };
    lPtData.validRequests = lPtData.validRequests;

    CEC_RestObjects.Portability lPortabilidade = new CEC_RestObjects.Portability();
    lPortabilidade.apiVersion = '1';
    lPortabilidade.transactionId = '1';
    lPortabilidade.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lPtData;
    lPortabilidade.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lPortabilidade;
  }
}