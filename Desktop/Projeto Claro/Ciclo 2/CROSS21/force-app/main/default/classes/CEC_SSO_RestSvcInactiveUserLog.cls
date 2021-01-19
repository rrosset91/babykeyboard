@RestResource(urlMapping='/InactiveUserLog/*')
global class CEC_SSO_RestSvcInactiveUserLog
{
  /*@HttpGet
  global static list<CEC_ObjectFactory.ResponseUser> getLog()
  {
    list<LogUser__c> lLstLogUsr = [select Id, Log__c, User__r.CompanyName, User__r.Email, User__r.FirstName,
      User__r.LastName, User__r.ProfileId, User__r.UserName, User__r.CPF__c, User__r.FederationIdentifier from LogUser__c
      where Read__c = false];
    list<CEC_ObjectFactory.ResponseUser> lLstRes = new list<CEC_ObjectFactory.ResponseUser>();

    for (LogUser__c iLog: lLstLogUsr)
    {
      iLog.Read__c = true;

      CEC_ObjectFactory.ResponseUser lObj = new CEC_ObjectFactory.ResponseUser();
      lObj.CompanyName = iLog.User__r.CompanyName;
      lObj.Email = iLog.User__r.Email;
      lObj.FirstName = iLog.User__r.FirstName;
      lObj.LastName = iLog.User__r.LastName;
      lObj.ProfileId = iLog.User__r.ProfileId;
      lObj.UserName = iLog.User__r.UserName;
      lObj.cpf = iLog.User__r.CPF__c;
      lObj.federationId = iLog.User__r.FederationIdentifier;
      lObj.log = iLog.Log__c;
      lLstRes.add(lObj);
    }

    if (!lLstLogUsr.isEmpty()) database.update(lLstLogUsr);
    return lLstRes;
  }*/
  
  @HttpGet
  global static Integer getLog()
  {
    list<LogUser__c> lLstLogUsr = [select Id, Log__c, User__r.CompanyName, User__r.Email, User__r.FirstName,
      User__r.LastName, User__r.ProfileId, User__r.UserName, User__r.CPF__c, User__r.FederationIdentifier from LogUser__c
      where Read__c = false];
    list<CEC_ObjectFactory.ResponseUser> lLstRes = new list<CEC_ObjectFactory.ResponseUser>();

    for (LogUser__c iLog: lLstLogUsr)
    {
      iLog.Read__c = true;

      CEC_ObjectFactory.ResponseUser lObj = new CEC_ObjectFactory.ResponseUser();
      lObj.CompanyName = iLog.User__r.CompanyName;
      lObj.Email = iLog.User__r.Email;
      lObj.FirstName = iLog.User__r.FirstName;
      lObj.LastName = iLog.User__r.LastName;
      lObj.ProfileId = iLog.User__r.ProfileId;
      lObj.UserName = iLog.User__r.UserName;
      lObj.documentNumberCPF = iLog.User__r.CPF__c;
      lObj.federationId = iLog.User__r.FederationIdentifier;
      lObj.log = iLog.Log__c;
      lLstRes.add(lObj);
    }

    if (!lLstLogUsr.isEmpty()) database.update(lLstLogUsr);
    
    if(lLstLogUsr.isEmpty())
        return 0;
    else
        return lLstLogUsr.size();
    
  }
  
}