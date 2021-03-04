/*--------------------------------------------------------------------------------------------
--- Company: Accenture Brasil
--- Creation Date: 06/03/2019
--- Author: Dylan Santos
--- Description: Classe para criar mocks para testes de serviços.
----------------------------------------------------------------------------------------------*/
@isTest
public class NBA_IntegrationServicesMock_Test implements HttpCalloutMock{
    
    private String setBody 			{get; set;}
    private String setHeaderKey 	{get; set;}
    private String setHeaderValue 	{get; set;}
    private Integer setStatusCode	{get; set;}
    
    public NBA_IntegrationServicesMock_Test(String setBody, String setHeaderKey, String setHeaderValue, Integer setStatusCode){
        this.setBody = setBody;
        this.setHeaderKey = setHeaderKey;
        this.setHeaderValue = setHeaderValue;	                                                     
        this.setStatusCode = setStatusCode;		                                                     
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader(setHeaderKey, setHeaderValue);
        res.setBody(setBody);
        res.setStatusCode(setStatusCode);
        
        return res;
    }
}