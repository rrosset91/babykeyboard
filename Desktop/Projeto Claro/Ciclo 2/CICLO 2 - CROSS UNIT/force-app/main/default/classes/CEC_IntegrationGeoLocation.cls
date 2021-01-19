/*
* Autor: RLdO
* Data: 04-jan-2019
* Descrição: CEC FASE 1 COMERCIAL: classe para consultar viabilidade tecnica de um HP (domicile)
*/
global without sharing class CEC_IntegrationGeoLocation
{
  global static ServiceParameter__c param;
  static
  {
    ServiceParameter__c lParamAlt = new ServiceParameter__c(Name = 'GeoLocation', Method__c = 'GET',
      Endpoint__c = 'callout:OAGGeoLocation', User__c = null, Password__c = null, Timeout__c = 10000,
      IsActive__c = true);
    param = ServiceParameter__c.getInstance('GeoLocation');
    param = (param != null) ? param : lParamAlt;
  }

  global static CEC_RestObjects.GeographicLocation consultar(list<String> aArgs)
  {
    String lArgList = (aArgs == null || aArgs.isEmpty()) ? '' : ('?' + String.join(aArgs, '&'));
    String lBodyRes, lHttpRes = '-1';

    CEC_RestObjects.GeographicLocation lRes = new CEC_RestObjects.GeographicLocation();

    try
    {
      HttpRequest req = CEC_HttpReq.genHttpReq(param, lArgList);
      if (test.isRunningTest()) req.setEndpoint('https://test.geo-location.com' + lArgList);
      HTTPResponse res = CEC_HttpReq.sendReq(req, null);
      lBodyRes = res.getBody();
      map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
        '"type":' => '"typeZ":', '"number":' => '"numberZ":' };
      for (String iJsonAttr: lMapResWord.keyset())
      {
        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
      }
      lHttpRes = String.valueOf(res.getStatusCode());
      Object lObj = JSON.deserialize(lBodyRes, CEC_RestObjects.GeographicLocation.class);
      lRes = (CEC_RestObjects.GeographicLocation)lObj;
    }
    catch (Exception ex)
    {
      lRes = genResponseError(ex.getMessage(), lHttpRes);
    }

    return lRes;
  }

  private static CEC_RestObjects.GeographicLocation genResponseError(String aMsg, String aHttpCode)
  {
    system.debug('CEC_IntegrationGeoLocation => ' + aMsg);
    CEC_RestObjects.Error lError = new CEC_RestObjects.Error();
    lError.httpCode = aHttpCode;
    lError.message = aMsg;

    CEC_RestObjects.GeographicLocation lRes = new CEC_RestObjects.GeographicLocation();
    lRes.error = lError;
    return lRes;
  }

  global static CEC_RestObjects.GeographicLocation generateMock(String aURL, Integer aHttpCode)
  {
    return generateMock(new URL(aURL), aHttpCode);
  }
  global static CEC_RestObjects.GeographicLocation generateMock(URL aURL, Integer aHttpCode)
  {
    map<String, String> lMapArgs = CEC_RestObjects.splitQueryParams(aURL);
    String lDomicileId = lMapArgs.get('domicileId');

    CEC_RestObjects.ContractIdentification lContractId = new CEC_RestObjects.ContractIdentification();
    lContractId.contractNumber = '1';
    lContractId.operatorCode = '1';
    lContractId.cityId = '1';

    CEC_RestObjects.Location lLocation = new CEC_RestObjects.Location();
    lLocation.id = '1';
    lLocation.description = '1';
    lLocation.code = '1';
    lLocation.typeId = '1';
    lLocation.typeDescription = '1';
    lLocation.contractIdentification = lContractId;

    CEC_RestObjects.BusinessLineFeatures lBlf = new CEC_RestObjects.BusinessLineFeatures();
    lBlf.id = '1';
    lBlf.description = '1';

    CEC_RestObjects.BusinessLine lBLine = new CEC_RestObjects.BusinessLine();
    lBLine.id = '1';
    lBLine.description = '1';
    lBLine.businessLineFeatures = lBlf;

    CEC_RestObjects.Model lModel = new CEC_RestObjects.Model();
    lModel.id = '1';
    lModel.description = '1';
    lModel.technologyId = '1';
    lModel.technologyDescription = '1';

    CEC_RestObjects.Manufacturer lManuf = new CEC_RestObjects.Manufacturer();
    lManuf.id = '1';
    lManuf.description = '1';

    CEC_RestObjects.Equipment lEquip = new CEC_RestObjects.Equipment();
    lEquip.id = '1';
    lEquip.serialNumber = '1';
    lEquip.mainAddressable = '1';
    lEquip.ownerType = '1';
    lEquip.stateId = '1';
    lEquip.stateDescription = '1';
    lEquip.typeId = '1';
    lEquip.typeDescription = '1';
    lEquip.manufacturer = lManuf;
    lEquip.model = lModel;
    lEquip.location = lLocation;

    CEC_RestObjects.Locations lLocs = new CEC_RestObjects.Locations();
    lLocs.id = '1';
    lLocs.situation = '1';
    lLocs.operator = '1';
    lLocs.commonArea = '1';
    lLocs.typeId = '1';
    lLocs.typeZ = '1';
    lLocs.equipment = new list<CEC_RestObjects.Equipment>{ lEquip };
    lLocs.technology = lManuf;

    CEC_RestObjects.Availability lAvail = new CEC_RestObjects.Availability();
    lAvail.technicalSituation = '1';
    lAvail.commercialSituation = '1';
    lAvail.technicalSituationNote = '1';
    lAvail.commercialSituationNote = '1';
    lAvail.businessLine = lBLine;

    CEC_RestObjects.Domiciles lGLData = new CEC_RestObjects.Domiciles();
    lGLData.id = (String.isBlank(lDomicileId)) ? '1234' : lDomicileId;
    lGLData.numberZ = '1';
    lGLData.domicileType = '1';
    lGLData.tvPointsAmount = '1';
    lGLData.roomsAmount = '1';
    lGLData.installationsAmount = '1';
    lGLData.requestSituation = '1';
    lGLData.requestSituationDate = null;
    lGLData.availability = new list<CEC_RestObjects.Availability>{ lAvail };
    lGLData.locations = new list<CEC_RestObjects.Locations>{ lLocs };

    CEC_RestObjects.GeographicDomiciles lDoms = new CEC_RestObjects.GeographicDomiciles();
    lDoms.domicile = lGLData;

    CEC_RestObjects.GeographicLocation lAddrGed = new CEC_RestObjects.GeographicLocation();
    lAddrGed.apiVersion = '1';
    lAddrGed.transactionId = '1';
    lAddrGed.data = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? null : lDoms;
    lAddrGed.error = (aHttpCode != null && ((aHttpCode / 100) != 2)) ? CEC_RestObjects.mockError(aHttpCode) : null;

    return lAddrGed;
  }
}