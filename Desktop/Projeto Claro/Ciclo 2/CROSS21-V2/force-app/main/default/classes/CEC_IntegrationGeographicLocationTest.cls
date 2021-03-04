@isTest
public class CEC_IntegrationGeographicLocationTest {

    @TestSetup
    static void setup(){
        ServiceParameter__c sp = new ServiceParameter__c();
        sp.Name = 'GeoLocationNew';
        sp.EndPoint__c = 'http://200.169.123.170:9000/corp/geographiclocations/viabilities';
        sp.Method__c = 'GET';
        sp.Timeout__c = 50000;
        sp.User__c = 'APP_TESTE';
        sp.Password__c = 'Claro123';
        sp.IsActive__c = true;
        insert sp;
    }

    @isTest
    static void consultarTest(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_GeographicLocationMock()); 
        ServiceParameter__c sp =  ServiceParameter__c.getInstance('GeoLocationNew');
        CEC_IntegrationGeographicLocation gLocation = new CEC_IntegrationGeographicLocation();
        list<String> args = new List<String>();
        args.add('operatorCodeNet=003');
        args.add('operatorCodeClaroTv=003');
        args.add('domicileIdNet=51531');
        args.add('domicileIdClaroTv=51531');
        CEC_IntegrationGeoLocationDTO geoLoctionResponse = gLocation.consultar(args);
        System.assertEquals('1;2019-06-06', geoLoctionResponse.apiVersion,'return consultar ok');
        Test.stopTest();

    }




}