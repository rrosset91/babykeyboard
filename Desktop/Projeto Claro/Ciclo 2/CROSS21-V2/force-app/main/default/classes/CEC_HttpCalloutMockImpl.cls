@isTest
global class CEC_HttpCalloutMockImpl implements HttpCalloutMock
{
    global Integer httpCode { get; set; }
    
    global CEC_HttpCalloutMockImpl() { this(200); }
    global CEC_HttpCalloutMockImpl(Integer aHttpCode) { this.httpCode = (aHttpCode == null) ? 200 : aHttpCode; }
    
    global HTTPResponse respond(HTTPRequest req)
    {
        String lBody = req.getBody(), lResult;
        String lURI = req.getEndpoint();
        system.debug('lURI>>>: '+lURI);
        HTTPResponse lRes = new HTTPResponse();
        lRes.setStatusCode(this.httpCode);
        
        if (lURI.contains('balances'))
        {
            lResult = JSON.serialize(CEC_360_IntegrationBalances.generateMock(), true);
        }
        if (lURI.contains('inactive-user'))
        {
            lResult = JSON.serialize(CEC_SSO_IntegrationInactiveUser.generateMock(lURI, (this.httpCode != 200)), true);
        }
        if (lURI.contains('prospect-resid'))
        {
            lResult = JSON.serialize(CEC_IntegrationProspect.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('prospect-movel'))
        {
            lResult = JSON.serialize(CEC_IntegrationProspectMovel.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('dados-pessoa'))
        {
            lResult = JSON.serialize(CEC_IntegrationDadosPessoa.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('portability'))
        {
            lResult = JSON.serialize(CEC_IntegrationPortability.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('port-windows'))
        {
            lResult = JSON.serialize(CEC_IntegrationPortWindows.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('resid-credit-analysis'))
        {
            lResult = JSON.serialize(CEC_IntegrationCreditAnalysis.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('mobile-credit-analysis'))
        {
            lResult = JSON.serialize(CEC_IntegrationCreditAnalysisMobile.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('addresses-ged'))
        {
            lResult = JSON.serialize(CEC_IntegrationAddressesGED.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('dom-addresses-ged'))
        {
            lResult = JSON.serialize(CEC_IntegrationDomAddressesGED.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('geo-location'))
        {
            lResult = JSON.serialize(CEC_IntegrationGeoLocation.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('prospect-resid') && lURI.contains('userId'))
        {
            lResult = JSON.serialize(CEC_IntegrationSales.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('addresses-city'))
        {
            lResult = JSON.serialize(CEC_IntegrationAddressCity.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('domicile-history'))
        {
            lResult = JSON.serialize(CEC_IntegrationDomicileHistory.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('history-proposal'))
        {
            lResult = JSON.serialize(CEC_IntegrationHistoryProposal.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('vendedor-residencial')) 
        {
            lResult = JSON.serialize(CEC_IntegrationSalesResidencial.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('createHP')) 
        {
            lResult = JSON.serialize(CEC_IntegrationHPCreation.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('createHPAnalysis')) 
        {
            lResult = JSON.serialize(SOLAR_IntegrationHPCreationAnalysis.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('getToken')) 
        {
            lResult = JSON.serialize(CEC_IntegrationGetToken.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('TokenOPDK')) 
        {
            lResult = JSON.serialize(SOLAR_IntegrationGetTokenOPDK.generateMock(lURI, this.httpCode), true);
        }
		if (lURI.contains('banks/accounts/validations')) 
        {  
            lResult = JSON.serialize(CEC_IntegrationBanksAccountsValidation.generateMock(lURI, this.httpCode), true);
        } 
		if (lURI.contains('billingcycles')) 
        {  
            lResult = JSON.serialize(CEC_IntegrationBillingCycles.generateMock(lURI, this.httpCode), true);
        }   
		if (lURI.contains('preanalysis')) 
        {  
            lResult = JSON.serialize(CEC_IntegrationPortabilitiesPreAnalysis.generateMock(lURI, this.httpCode), true);
        } 
		if (lURI.contains('salesmen')) 
        {  
            lResult = JSON.serialize(CEC_IntegrationSales.generateMock(lURI, this.httpCode), true);
        }
        if (lURI.contains('teste.com')) 
        {  
            lResult = JSON.serialize(CEC_IntegrationInteractionsTest.generateMock(lURI, this.httpCode),true);
        }
        if (lURI.contains('GeoLocationNew')) 
        {  
            lResult = JSON.serialize(new CEC_IntegrationGeoLocationDTO());
        }     
        if (this.httpCode > 0) lRes.setBody(lResult);
        
        return lRes;
    }
}