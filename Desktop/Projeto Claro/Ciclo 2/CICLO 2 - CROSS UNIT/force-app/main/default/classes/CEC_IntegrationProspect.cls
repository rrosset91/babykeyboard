/*
* Autor: RLdO
* Data: 23-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar se o cliente (CPF ou CNPJ) possui contratos ativos (residencial)
*/
global without sharing class CEC_IntegrationProspect
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'ProspectResidencial', Method__c = 'GET',
      Endpoint__c = 'callout:OAGProspectResidencial', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('ProspectResidencial');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.Customer consultar(String aDocument)
  {
    list<String> lLstArg = new list<String>();
    if (String.isNotBlank(aDocument))
    {
      lLstArg.add('partyIdentificationNumber=' + aDocument.replaceAll('\\D', ''));
      lLstArg.add('partyIdentificationType=' + ((aDocument.replaceAll('\\D', '').length() == 14) ? 'CNPJ' : 'CPF'));
    }
    return consultar(lLstArg);
  }
  global static CEC_RestObjects.Customer consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.Customer lRes = new CEC_RestObjects.Customer();
    lRes.data = new CEC_RestObjects.CustomerData();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.prospect-resid.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.Customer.class);
      lRes = (CEC_RestObjects.Customer)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.Customer genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationProspect => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.Customer lRes = new CEC_RestObjects.Customer();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.Customer generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.Customer generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);

    CEC_RestObjects.CustomerPhones lPhone = new CEC_RestObjects.CustomerPhones();
    lPhone.telephoneNumber = '11111111';
    lPhone.areaCode = '11';
    lPhone.internacionalCode = null;

    CEC_RestObjects.CustomerAccounts lCustomer = new CEC_RestObjects.CustomerAccounts();
    lCustomer.firstName = 'Test';
    lCustomer.lastName = 'Prospect';
    lCustomer.salutation = 'Sr.';
    lCustomer.companyName = 'Claro';
    lCustomer.partyRoleId = null;
    lCustomer.partyIdentificationNumber = lMapArgs.get('partyIdentificationNumber');
    lCustomer.partyIdentificationType = lMapArgs.get('partyIdentificationType');
    lCustomer.customerAccountId = null;
    lCustomer.status = 'Status';
    lCustomer.customerTypeName = null;
    lCustomer.customerTypeDescription = null;
    lCustomer.customerSegmentName = null;
    lCustomer.customerSegmentDescription = null;
    lCustomer.customerComboMultiFlag = 'false';
    lCustomer.involvementIdentificationRole = null;
    lCustomer.emailAddress = 'teste.prospect@claro.com.br';
    lCustomer.phones = new list<CEC_RestObjects.CustomerPhones>{ lPhone };

    CEC_RestObjects.CustomerData lCustomerData = new CEC_RestObjects.CustomerData();
    lCustomerData.customerAccounts = new list<CEC_RestObjects.CustomerAccounts>{ lCustomer };

    CEC_RestObjects.Customer lProspect = new CEC_RestObjects.Customer();
    lProspect.apiVersion = '1';
    lProspect.transactionId = '1';
    lProspect.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lCustomerData;
    lProspect.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lProspect;
  }
}