/*
* Autor: Diego Lima - Deloitte
* Data: 18/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para os testes da classe
CEC_CTI_SyncSite]
*/

@isTest
public class CEC_CTI_SyncSiteTest {

    @isTest
    static void syncSiteSuccess(){ 
        
        String myJSON = '[{'+
  				'"Name" : "Test Site",'+
  				'"Localizador" : "LocTeste",'+
  				'"LigacaoExterna" : "true",'+
  				'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();

        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : siteObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(true, successRequisition);
    }
    
    @isTest
    static void syncSiteErrorFieldSize(){ 
        
        String myJSON = '[{'+
  				'"Name" : "Test Site 11111111111111111111111111111111111111111111111111111111111111111111111",'+
  				'"Localizador" : "LocTeste",'+
  				'"LigacaoExterna" : "true",'+
  				'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();

        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : siteObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
   
    @isTest
    static void syncSiteErrorExternalIDMissing(){ 
        
        String myJSON = '[{'+
  				'"Name" : "Test Site",'+
  				'"Localizador" : "teste1",'+
  				'"LigacaoExterna" : "true",'+
  				//'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();
		System.debug('siteObj = ' + siteObj);
        
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : siteObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    @isTest
    static void syncSiteGenericError(){ 
        
        String myJSON = '[{'+
  				'"Name" : "Test Site",'+
  				'"Localizador" : "",'+
  				'"LigacaoExterna" : "true",'+
  				'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();
		System.debug('siteObj = ' + siteObj);
        
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : siteObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncSiteErrorException(){ 
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request.httpMethod = 'POST';
        request.requestBody = null;
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();
		System.debug('siteObj = ' + siteObj);
        
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : siteObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.debug('successRequisition = ' + successRequisition);
        System.assertEquals(false, successRequisition);
    }
}