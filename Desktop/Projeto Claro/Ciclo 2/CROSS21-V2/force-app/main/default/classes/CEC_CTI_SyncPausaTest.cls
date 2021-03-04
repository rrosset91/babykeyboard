/*
* Autor: Diego Lima - Deloitte
* Data: 25/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para os testes da classe
CEC_CTI_SyncPausa]
*/

@isTest
public class CEC_CTI_SyncPausaTest {

    @isTest
    static void syncPausaSuccess(){
        
        String myJSONsite = '[{'+
  				'"Name" : "Test Site",'+
  				'"Localizador" : "CSU|APOLONIO|DAC01|CTI01",'+
  				'"LigacaoExterna" : "true",'+
  				'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl2 = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
        
        Test.startTest();
        RestRequest request2 = new RestRequest();
        request2.requestUri = orgUrl2+'/services/apexrest/CEC_CTI_SyncObjects/upsertSite';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueof(myJSONsite);
        RestContext.request = request2;

        List<CEC_CTI_SyncObjectsWrapper> siteObj = CEC_CTI_SyncSite.upsertSite();
        
        String myJSON = '[{'+
  				'"Nome" : "Pausa 10",'+
  				'"CodPausa" : "42342",'+
  				'"IdPausaDAC" : "1",'+
  				'"TempoMin" : "0",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertPause';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> PausaObj = CEC_CTI_SyncPausa.upsertPausa();

        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : PausaObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(true, successRequisition);
        
    }
    
    @isTest
    static void syncPausaErrorFieldSize(){
        String myJSON = '[{'+
  				'"Nome" : "Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911Pausa 012345678911",'+
  				'"CodPausa" : "42342",'+
  				'"IdPausaDAC" : "1",'+
  				'"TempoMin" : "0",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertPause';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> PausaObj = CEC_CTI_SyncPausa.upsertPausa();
		System.debug('PausaObj = ' + PausaObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : PausaObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
        
    }
    
    @isTest
    static void syncPausaErrorExternalIDMissing(){
        String myJSON = '[{'+
  				'"Nome" : "Pausa 10",'+
  				//'"CodPausa" : "42342",'+
  				'"IdPausaDAC" : "1",'+
  				'"TempoMin" : "0",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertPause';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> PausaObj = CEC_CTI_SyncPausa.upsertPausa();
		System.debug('PausaObj = ' + PausaObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : PausaObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncPausaGenericError(){
         String myJSON = '[{'+
  				'"Nome" : "Pausa 10",'+
  				'"CodPausa" : " ",'+
  				'"IdPausaDAC" : "1",'+
  				'"TempoMin" : "0",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertPause';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> PausaObj = CEC_CTI_SyncPausa.upsertPausa();
		System.debug('PausaObj = ' + PausaObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : PausaObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncPausaErrorException(){
        String myJSON = '[{'+
  				'"Nome" : "Pausa 10",'+
           		'"Nome" : "Pausa 10",'+
  				//'"CodPausa" : "42342",'+
  				'"IdPausaDAC" : "1",'+
  				'"TempoMin" : "0",'+
            	//'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertPause';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> PausaObj = CEC_CTI_SyncPausa.upsertPausa();
		System.debug('PausaObj = ' + PausaObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : PausaObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
}