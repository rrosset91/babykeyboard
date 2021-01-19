global without sharing class CEC_SSO_IntegrationInactiveUser
{
  public static CEC_ObjectFactory.ResponseInactiveUser consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : String.join(aArgs, '&');
    CEC_ObjectFactory.ResponseInactiveUser lRes = new CEC_ObjectFactory.ResponseInactiveUser();

    try
    {
      HttpRequest req = new HttpRequest();
      req.setMethod('GET');
      req.setEndpoint('callout:OAG_CorpCEC' + CEC_ServiceName__c.getValues('InactiveUser').ServiceName__c + lArgList);
      // req.setEndpoint('http://200.169.123.170:9000/corp/servicesusers/inactives?' + lArgList);
      //## req.setEndpoint('http://200.169.123.170:9000/corp/servicesusers/inactives?startDate=2018-01-01&endDate=2019-09-16&resourceName=CEC+Salesforce');
      if (test.isRunningTest()) req.setEndpoint('https://test.inactive-user.com?' + lArgList);
      req.setTimeout(120000);
      System.debug(req.getEndpoint());      
    
      //Blob headerValue = Blob.valueOf('{!$OAG_CorpCEC.Username}' + ':' + '{!$OAG_CorpCEC.Password}');
      Blob headerValue = Blob.valueOf('APP_TESTE' + ':' + 'claro123');
      String authorizationHeader = 'Basic ' +
      EncodingUtil.base64Encode(headerValue); 
      req.setHeader('Authorization', authorizationHeader);
    
      Http http = new Http();
      HTTPResponse res = http.send(req);
        
      System.debug('## Inicio ## ');
      System.debug(res.getBody());
      System.debug('## FIM ## ');
        
      //##String lBodyRes = res.getBody().replaceAll('cpf__c', 'cpf');

        //lBodyRes = '{"user": [ { "UserName" : "teste.inativar.usuario@claro.com.br.devsso", "ProfileId" : "00e1H000001SkRMQA0", "log" : "Required fields are missing: [LastName]", "LastName" : "Inativar Usuario", "FirstName" : "Teste", "federationId" : "00000000", "Email" : "rafaelloliveira@deloitte.com", "cpf" : null, "CompanyName" : null } ]}';  
        
      System.debug('#Body: ' + res.getBody());  
      Object lObj = JSON.deserialize(res.getBody(), CEC_ObjectFactory.ResponseInactiveUser.class);
      System.debug('#lObj: ' + lObj);
      lRes = (CEC_ObjectFactory.ResponseInactiveUser)lObj;
    }
    catch (Exception ex)
    {
      System.debug('Entrou no erro!' + ex.getMessage());
      lRes = genResponseError(ex.getMessage());
    }

    return lRes;
  }

  private static CEC_ObjectFactory.ResponseInactiveUser genResponseError(String aMsg)
  {
    system.debug(aMsg);
    CEC_ObjectFactory.ResponseInactiveUser lRes = new CEC_ObjectFactory.ResponseInactiveUser();
    return lRes;
  }
  
  global static CEC_RestObjects.ResponseInactiveUser generateMock(String aURL, Boolean aErro)
  {
    return generateMock(new URL(aURL), aErro);
  }
  
  global static CEC_RestObjects.ResponseInactiveUser generateMock(URL aURL, Boolean aErro)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);

    CEC_RestObjects.ResponseUser lUsr = new CEC_RestObjects.ResponseUser();
    lUsr.CompanyName = 'Claro';
    lUsr.Email = 'teste@claro.com.br';
    lUsr.FirstName = 'Teste';
    lUsr.LastName = 'Teste';
    lUsr.ProfileId = null;
    lUsr.UserName = 'teste@claro.com.br';
    lUsr.cpf = null;
    lUsr.federationId = '123456';

    CEC_RestObjects.ResponseInactiveUser lObj = new CEC_RestObjects.ResponseInactiveUser();
    lObj.user = new list<CEC_RestObjects.ResponseUser>{ lUsr };

    return lObj;
  }
}