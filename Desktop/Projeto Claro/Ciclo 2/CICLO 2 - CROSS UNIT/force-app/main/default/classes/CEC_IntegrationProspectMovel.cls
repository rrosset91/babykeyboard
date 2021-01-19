/*
* Autor: RLdO
* Data: 05-nov-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar se o cliente (CPF ou CNPJ) possui contratos ativos (movel)
*/
global without sharing class CEC_IntegrationProspectMovel
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'ProspectMovel', Method__c = 'GET',
      Endpoint__c = 'callout:OAGProspectMovel', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('ProspectMovel');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.AllSubscribers consultar(String aDocument)
  {
    list<String> lLstArg = new list<String>{ 'page=1', 'limit=50' };
    if (String.isNotBlank(aDocument))
    {
      lLstArg.add(((aDocument.length() == 14) ? 'cnpj=' : 'cpf=') + aDocument);
    }
    return consultar(lLstArg);
  }
  global static CEC_RestObjects.AllSubscribers consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.AllSubscribers lRes = new CEC_RestObjects.AllSubscribers();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.prospect-movel.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      map<String, String> lMapResWord = new map<String, String>{ '" :' => '":', '"type:"' => '"typeZ:"' };
      for (String iJsonAttr: lMapResWord.keyset())
      {
        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
      }
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.AllSubscribers.class);
      lRes = (CEC_RestObjects.AllSubscribers)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.AllSubscribers genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationProspectMovel => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.AllSubscribers lRes = new CEC_RestObjects.AllSubscribers();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.AllSubscribers generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.AllSubscribers generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);

    CEC_RestObjects.CustomerAccounts lCustomer = new CEC_RestObjects.CustomerAccounts();
    lCustomer.name = 'Test Prospect';
    lCustomer.companyName = 'Claro';
    lCustomer.personType = null;
    lCustomer.typeZ = null;
    lCustomer.subType = null;
    lCustomer.segment = null;
    lCustomer.mobileId = null;
    lCustomer.mobileType = null;
    lCustomer.mobileSubType = null;
    lCustomer.mobileBan = null;
    lCustomer.faId = null;
    lCustomer.businessName = null;
    lCustomer.acrmCustomerId = null;
    lCustomer.crmCustomerId = null;
    lCustomer.crmCustomerSubType = null;
    lCustomer.status = 'STATUS';

    lCustomer.documents = new CEC_RestObjects.Documents();
    lCustomer.documents.cpf = lMapArgs.get('cpf');
    lCustomer.documents.cnpj = lMapArgs.get('cnpj');
    lCustomer.documents.rg = '';
    lCustomer.documents.passport = '';
    lCustomer.documents.ie = '';

    CEC_RestObjects.Subscribers lSubscriber = new CEC_RestObjects.Subscribers();
    lSubscriber.mobileSubscriberId = null;
    lSubscriber.name = null;
    lSubscriber.serviceType = null;
    lSubscriber.typeZ = null;
    lSubscriber.subType = null;
    lSubscriber.comboType = null;
    lSubscriber.effectiveSinceDate = null;
    lSubscriber.cancellationDate = null;
    lSubscriber.status = 'STATUS';
    lSubscriber.statusDate = null;
    lSubscriber.documentationStatus = null;
    lSubscriber.msisdn = null;
    lSubscriber.ticketAttendance = null;
    lSubscriber.productFamily = null;
    lSubscriber.omsSubscriberId = null;
    lSubscriber.crmSubscriberId = null;
    lSubscriber.titularId = null;
    lSubscriber.customer = lCustomer;

    CEC_RestObjects.SubscribersData lSubscriberData = new CEC_RestObjects.SubscribersData();
    lSubscriberData.subscribers = new list<CEC_RestObjects.Subscribers>{ lSubscriber };

    CEC_RestObjects.AllSubscribers lAllSubscriber = new CEC_RestObjects.AllSubscribers();
    lAllSubscriber.apiVersion = '1';
    lAllSubscriber.transactionId = '1';
    lAllSubscriber.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lSubscriberData;
    lAllSubscriber.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lAllSubscriber;
  }
}