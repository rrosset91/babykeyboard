/*
* Autor: RLdO
* Data: 29-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar dados cadastrais a partir de um documento,
     para enriquecimento de cadastro
*/
global without sharing class CEC_IntegrationDadosPessoa
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'DadosPessoa', Method__c = 'GET',
      Endpoint__c = 'callout:OAGDadosPessoa', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('DadosPessoa');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.DadosPessoa consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.DadosPessoa lRes = new CEC_RestObjects.DadosPessoa();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.dados-pessoa.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.DadosPessoa.class);
      lRes = (CEC_RestObjects.DadosPessoa)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.DadosPessoa genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationDadosPessoa => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.DadosPessoa lRes = new CEC_RestObjects.DadosPessoa();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.DadosPessoa generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.DadosPessoa generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);

    CEC_RestObjects.PersonComplementAddress lComplAddr = new CEC_RestObjects.PersonComplementAddress();
    lComplAddr.premisesId = 'Rua';
    lComplAddr.streetAddress = 'Test';
    lComplAddr.streetAddressNumber = '10';
    lComplAddr.complementAddress = 'Casa';
    lComplAddr.neighborhood = 'Vila Teste';
    lComplAddr.cityName = 'Sao Paulo';
    lComplAddr.placeId = 'SP';
    lComplAddr.postalCode = '01234-567';
    lComplAddr.areaCode = '11';

    CEC_RestObjects.PersonComplementAddresses lAllComplAddr = new CEC_RestObjects.PersonComplementAddresses();
    lAllComplAddr.complementAddress = new list<CEC_RestObjects.PersonComplementAddress>{ lComplAddr };

    CEC_RestObjects.CustomerPhones lPhone = new CEC_RestObjects.CustomerPhones();
    lPhone.telephoneType = null;
    lPhone.phoneLineNumber = '11998765432';

    CEC_RestObjects.PersonContact lPersonContact = new CEC_RestObjects.PersonContact();
    lPersonContact.telephoneNumber = lPhone;
    lPersonContact.emailAddress = 'teste@claro.com.br';

    CEC_RestObjects.PersonContacts lAllContacts = new CEC_RestObjects.PersonContacts();
    lAllContacts.contact = new list<CEC_RestObjects.PersonContact>{ lPersonContact };

    CEC_RestObjects.CustomerAccounts lPersonData = new CEC_RestObjects.CustomerAccounts();
    lPersonData.personType = 'PF';
    lPersonData.fullName = 'Test Person';
    lPersonData.dateOfBirth = system.now().addYears(-30).format('yyyy-MM-dd');
    lPersonData.mothersName = 'Mother of Test Person';
    lPersonData.documentNumberCPF = lMapArgs.get('documentNumberCPF');
    lPersonData.deceasedIndicator = 'false';
    lPersonData.contacts = lAllContacts;
    lPersonData.complementAddresses = lAllComplAddr;

    CEC_RestObjects.DadosPessoa lDadosPessoa = new CEC_RestObjects.DadosPessoa();
    lDadosPessoa.apiVersion = '1';
    lDadosPessoa.transactionId = '1';
    lDadosPessoa.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lPersonData;
    lDadosPessoa.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lDadosPessoa;
  }
}