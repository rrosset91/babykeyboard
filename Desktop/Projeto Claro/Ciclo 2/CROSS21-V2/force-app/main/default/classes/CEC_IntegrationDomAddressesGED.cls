/*
* Autor: RLdO
* Data: 02-jan-2019
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar lista de HPs (domiciles) de um endereco
*/
global without sharing class CEC_IntegrationDomAddressesGED
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'DomAddressesGED', Method__c = 'GET',
      Endpoint__c = 'callout:OAGDomAddressesGED', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('DomAddressesGEDNew');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.AddressesGEDDom consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.AddressesGEDDom lRes = new CEC_RestObjects.AddressesGEDDom();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.dom-addresses-ged.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
        system.debug('req: '+lBodyRes);
 /*     map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
        '"streetNumber":' => '"streetAddressNumber":', '"city":' => '"cityName":',
        '"complementarySubAddress":' => '"complementAddress":', '"number":' => '"numberZ":' };
      for (String iJsonAttr: lMapResWord.keyset())
      {
        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
      }*/
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.AddressesGEDDom.class);
      lRes = (CEC_RestObjects.AddressesGEDDom)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }
	//lRes = generateMock('https://www.test.com.br', 200);
    return lRes;
  }

  private static CEC_RestObjects.AddressesGEDDom genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationAddressesGED => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.AddressesGEDDom lRes = new CEC_RestObjects.AddressesGEDDom();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.AddressesGEDDom generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.AddressesGEDDom generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);
 /*   String lCEP = lMapArgs.get('postalCode'), lStreetAddress = lMapArgs.get('streetName');

    CEC_RestObjects.PersonComplementAddress lComplAddr = new CEC_RestObjects.PersonComplementAddress();
    lComplAddr.premisesId = 'R';
    lComplAddr.streetType = lComplAddr.premisesId;
    lComplAddr.streetAddress = (String.isBlank(lStreetAddress)) ? 'Test' : lStreetAddress;
    lComplAddr.streetName = lComplAddr.streetAddress;
    lComplAddr.streetAddressNumber = '10';
    lComplAddr.complementAddress = 'Casa';
    lComplAddr.neighborhood = 'Vila Teste';
    lComplAddr.cityName = 'Sao Paulo';
    lComplAddr.placeId = 'SP';
    lComplAddr.postalCode = (String.isBlank(lCEP)) ? '01234-567' : lCEP;
    lComplAddr.areaCode = '11';
    lComplAddr.streetId = '13';

    CEC_RestObjects.Domiciles lDomicile = new CEC_RestObjects.Domiciles();
    lDomicile.id = '1234';
    lDomicile.numberZ = '1';
    lDomicile.domicileType = '1';
    lDomicile.tvPointsAmount = '1';
    lDomicile.roomsAmount = '1';
    lDomicile.installationsAmount = '1';
    lDomicile.requestSituation = '1';
    lDomicile.requestSituationDate = null;

    CEC_RestObjects.Edifications lEdif = new CEC_RestObjects.Edifications();
    lEdif.edificationId = '1';
    lEdif.description = '1';
    lEdif.numberOfDomicilesPreview = '1';
    lEdif.numberOfDomicilesRealized = '1';
    lEdif.numberOfInstallPreview = '1';
    lEdif.numberOfInstallRealized = '1';
    lEdif.node = '1';
    lEdif.edificationType = '1';
    lEdif.cablingType = '1';
    lEdif.address = lComplAddr;
    lEdif.domiciles = new list<CEC_RestObjects.Domiciles>{ lDomicile };

    CEC_RestObjects.EdificationsZ lEdifZ = new CEC_RestObjects.EdificationsZ();
    lEdifZ.edifications = new list<CEC_RestObjects.Edifications>{ lEdif };
*/
    CEC_RestObjects.AddressNew lAddress = new CEC_RestObjects.AddressNew();
    lAddress.addressIdNet = 2;
    lAddress.addressIdClaroTv = 2;
	lAddress.country ='Brasil';
	lAddress.placeId ='SP';
	lAddress.cityId ='88412';
	lAddress.city ='SAO PAULO';
	lAddress.postalCode='000000';
	lAddress.neighborhood='CIDADE MONCOES';
	lAddress.streetType='R';
	lAddress.streetIdNet='8252';
	lAddress.streetIdClaroTv='8259';
	lAddress.streetName='Verbo Divino';
	lAddress.neighborhoodIdNet='19034';
	lAddress.neighborhoodIdClaroTv='19034';

	lAddress.ibgeCode='098767';
    
    CEC_RestObjects.Properties lProperties = new CEC_RestObjects.Properties();
    lProperties.idClaroTv='360587566';
    lProperties.idNet = '360587566';
    lProperties.address = lAddress;       
    
    CEC_RestObjects.Edification lEdification = new CEC_RestObjects.Edification();  
	lEdification.edificationIdNet=2;
	lEdification.edificationIdClaroTv=2;
	lEdification.description='';
	lEdification.buildingIdNet='501334408';
	lEdification.buildingIdClaroTv='501334408';
	lEdification.buildingTypeNet='E';
	lEdification.buildingTypeClaroTv='';
       
    lEdification.properties = new List<CEC_RestObjects.Properties> {lProperties};
    
    CEC_RestObjects.EdificationsZ lEdif = new CEC_RestObjects.EdificationsZ();
    lEdif.edification = new List<CEC_RestObjects.Edification> {lEdification};  
      
    CEC_RestObjects.AddressesGEDDomData lAddrGedData = new CEC_RestObjects.AddressesGEDDomData();
    //lAddrGedData.edifications = lEdifZ;
	lAddrGedData.edifications = lEdif;
    
    CEC_RestObjects.AddressesGEDDom lAddrGed = new CEC_RestObjects.AddressesGEDDom();
    lAddrGed.apiVersion = '1';
    lAddrGed.transactionId = '1';
    lAddrGed.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lAddrGedData;
    lAddrGed.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lAddrGed;
  }
}