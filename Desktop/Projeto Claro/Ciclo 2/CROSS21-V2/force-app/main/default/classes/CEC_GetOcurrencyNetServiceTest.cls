/*-----------------------------------------------------------------------------------------------------
	--- Company: Hitss do Brasil
	--- Squad: Canais Críticos 
	--- Description: Classe responsável pela integração com a API contactrecords  
	--- que chama o serviço de listagem de ocorrência do NETSMS. 
	---	Created: 08/10/2020
-------------------------------------------------------------------------------------------------------*/
@isTest
public class CEC_GetOcurrencyNetServiceTest {
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_GetOcurrency', 'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                              'POST','x1234','APP_SALESFORCE_CEC');
        insert varServiceParameter;
    }
      
    @istest 
    private static void getOcurrencyTest()
    {     
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseCloseNetSmsTest());
        try{
        	CEC_GetOcurrencyNetService.getOcurrency('0000','038','98777777'); 
        }catch(Exception ex){
            
        }        
        test.stopTest();
    }
   
    @istest 
    private static void getOcurrencyTestSucess()
    {     
      test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseCloseNetSmsSucessTest());
        try{
        	String idOcorrencia = CEC_GetOcurrencyNetService.getOcurrency('0000','038','98777777');    
        }catch(Exception ex){
            
        }
        
      test.stopTest();
    }     
}