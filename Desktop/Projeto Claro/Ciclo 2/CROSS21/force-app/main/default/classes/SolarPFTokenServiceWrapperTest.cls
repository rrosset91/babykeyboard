@isTest
public with sharing class SolarPFTokenServiceWrapperTest {

    @isTest
    private static  void SolarPFTokenServiceWrapperTest() {
        SolarPFTokenServiceWrapper.Request request = new SolarPFTokenServiceWrapper.Request();
        SolarPFTokenServiceWrapper.RequestData data = new SolarPFTokenServiceWrapper.RequestData();
        request.data = data;
        SolarPFTokenServiceWrapper.RequestData wrapper = new SolarPFTokenServiceWrapper.RequestData();
        wrapper.user = 'user';
        wrapper.name = 'name';
        wrapper.sourceSystem = 'ipaddress';
        wrapper.destinySystem = 'destiny';
        wrapper.applicationContext = 'application';
        wrapper.IpAddress = 'ipaddress';
        wrapper.indicatorSession = 'indicator';
        wrapper.properties = new List<SolarPFTokenServiceWrapper.Properties>();
        SolarPFTokenServiceWrapper.Properties prop =  new SolarPFTokenServiceWrapper.Properties();
        prop.name = 'name';
        prop.value = 'value';
        wrapper.properties.add(prop);
        SolarPFTokenServiceWrapper.RequestData resp = SolarPFTokenServiceWrapper.parse(JSON.serialize(wrapper));
        SolarPFTokenServiceWrapper.Response response = new SolarPFTokenServiceWrapper.Response();
        SolarPFTokenServiceWrapper.ResponseData dataresponse = new SolarPFTokenServiceWrapper.ResponseData();
        SolarPFTokenServiceWrapper.Token token = new SolarPFTokenServiceWrapper.Token();
        SolarPFTokenServiceWrapper.ResponseError error = new SolarPFTokenServiceWrapper.ResponseError();
        error.errorCode = 'API-TOKEN-001';
        token.tokenId = '12123ewd';
        dataresponse.token = token;
        response.apiVersion = '1.0';
        response.transactionId = '1.0';
        response.data = dataresponse;
        response.error = error;
        System.assertEquals('name', resp.name, 'token wrapper');
    }
}