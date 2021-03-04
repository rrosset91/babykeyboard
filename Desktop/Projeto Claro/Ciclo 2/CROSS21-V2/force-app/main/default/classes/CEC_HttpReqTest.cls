/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Description: Classe responsável por chamada rest API
--- Date: 24/06/2019
-------------------------------------------------------------------------------------------------------*/
@IsTest
public class CEC_HttpReqTest {
    
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                              			 'POST','x1234','APP_SALESFORCE_CEC');
        insert varServiceParameter;
        
        ServiceParameter__c varServiceParameter1 = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_CloseOcurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                              			 'POST','x1234','APP_SALESFORCE_CEC');
        insert varServiceParameter1;
    }
    
    @istest 
    private static void requestTest()
    {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
            HttpRequest request = new HttpRequest();
        	CEC_OcurrencyNetRequest cec_request = new CEC_OcurrencyNetRequest();
        
        	CEC_HttpReq httpReq = new CEC_HttpReq();
        
        	HttpResponse response = CEC_HttpReq.sendReq('CEC_OAG_NET_Ocurrency', cec_request);   
            system.assertEquals(200, response.getStatusCode(), 'Erro ao requisitar serviço');
        
        	HttpResponse response2 = CEC_HttpReq.sendReq(request, cec_request);   
            system.assertEquals(200, response2.getStatusCode(), 'Erro ao requisitar serviço');
        
            HttpResponse response3 = CEC_HttpReq.sendReq('CEC_OAG_NET_Ocurrency', 'POST', cec_request);   
            system.assertEquals(200, response3.getStatusCode(), 'Erro ao requisitar serviço');
        
            HttpResponse response4 = CEC_HttpReq.sendReq('', null, cec_request);   
            system.assertEquals(200, response4.getStatusCode(), 'Erro ao requisitar serviço');
        
        	CEC_CloseOcurrencyNetRequest cec_closeRequest = new CEC_CloseOcurrencyNetRequest();
        
            HttpResponse closeResponse = CEC_HttpReq.sendReqPatch('CEC_OAG_NET_CloseOcurrency', cec_closeRequest, 'operatorCode=004&occurrenceId=1111112');   
            system.assertEquals(200, closeResponse.getStatusCode(), 'Erro ao requisitar serviço');
        
        Test.stopTest();
    } 
        
    @istest 
    private static void sendReq() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_HttpReq.sendReq(new HttpRequest(), '',false);
        
        Test.stopTest();
    }
    
    @istest 
    private static void sendReqByJson() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_HttpReq.sendReqByJson(new HttpRequest());
        
        Test.stopTest();
    }
    
    @istest 
    private static void sendReqSandbox() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_HttpReq.sendReqSandbox('CEC_OAG_NET_Ocurrency','');
        
        Test.stopTest();
    }
    
        @istest
    private static void sendReqPatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_HttpReq.sendReqPatch('CEC_OAG_NET_Ocurrency','','');
        
        Test.stopTest();
    }
            @istest
    private static void sendReqGet() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        CEC_HttpReq.sendReqGet('CEC_OAG_NET_Ocurrency','');
        
        Test.stopTest();
    }
    
}