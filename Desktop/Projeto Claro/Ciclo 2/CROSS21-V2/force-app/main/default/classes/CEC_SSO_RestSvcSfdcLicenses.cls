@RestResource(urlMapping='/SfdcLicenses/*')
global class CEC_SSO_RestSvcSfdcLicenses
{
  @HttpGet
  global static CEC_RestObjects.ResponseTotalLicenses getLicense()
  {
    map<String, CEC_RestObjects.ResponseTotalLicenses> lMapLic = new map<String, CEC_RestObjects.ResponseTotalLicenses>();
    for (UserLicense iLic: [SELECT LicenseDefinitionKey, TotalLicenses, UsedLicenses FROM UserLicense WHERE LicenseDefinitionKey = 'SFDC'])
    {
      CEC_RestObjects.ResponseTotalLicenses lObj = new CEC_RestObjects.ResponseTotalLicenses();
      lObj.UsedLicenses = iLic.UsedLicenses;
      lObj.TotalLicenses = iLic.TotalLicenses;
      lMapLic.put(iLic.LicenseDefinitionKey, lObj);
    }
    return lMapLic.get('SFDC');
  }
}