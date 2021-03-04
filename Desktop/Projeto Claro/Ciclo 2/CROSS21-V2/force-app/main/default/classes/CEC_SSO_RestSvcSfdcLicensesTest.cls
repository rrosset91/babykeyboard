@isTest
private class CEC_SSO_RestSvcSfdcLicensesTest
{
  @isTest static void testRestLicense()
  {
    RestRequest lRequest = new RestRequest();
    lRequest.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/SfdcLicenses/';
    lRequest.httpMethod = 'GET';

    RestContext.request = lRequest;

    // Call the method to test
    test.startTest();
    CEC_RestObjects.ResponseTotalLicenses lGotLic = CEC_SSO_RestSvcSfdcLicenses.getLicense();
    test.stopTest();

    // Verify results
    system.assert(lGotLic != null);
  }
}