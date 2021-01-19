@isTest
private class CEC_SSO_RestSvcInactiveUserLogTest
{
  @isTest static void testRestLog()
  {
    User usuario1 = CEC_SobjectFactory.getUser();
    database.insert(usuario1);

    LogUser__c lLogUsr = new LogUser__c(User__c = usuario1.Id);
    User lThisUsr = new User(Id = UserInfo.getUserId());
    system.runAs(lThisUsr)
    {
      database.insert(lLogUsr);
    }

    RestRequest lRequest = new RestRequest();
    lRequest.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/InactiveUserLog/';
    lRequest.httpMethod = 'GET';

    RestContext.request = lRequest;

    // Call the method to test
    test.startTest();
    //list<CEC_RestObjects.ResponseUser> lGotLog;
    Integer lGotLog;
    system.runAs(lThisUsr)
    {
      lGotLog = CEC_SSO_RestSvcInactiveUserLog.getLog();
    }
    test.stopTest();

    // Verify results
    //system.assert(lGotLog != null && !lGotLog.isEmpty());
    system.assert(lGotLog != 0);
  }
}