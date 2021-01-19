/*
* Autor: Diego Lima - Deloitte
* Data: 25/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para os testes da classe
CEC_CTI_SyncSkill]
*/

@isTest
public class CEC_CTI_SyncSkillTest {
	
    @isTest
    static void syncSKillSuccess(){ 
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
  				'"Nome":"SKill Retencao",'+
  				'"CodigoSkill":"3135",'+
  				'"Conferencia":"TRUE",'+
  				'"Desliga":"TRUE",'+
  				'"Espera":"TRUE",'+
            	'"IdPortal":"00001",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSkill';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> skillObj = CEC_CTI_SyncSkill.upsertSkill();

        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : skillObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(true, successRequisition);
    }
    
    @isTest
    static void syncSKillErrorFieldSize(){
        
         String myJSON = '[{'+
  				'"Nome":"SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911SKill Retencao 012345678911",'+
  				'"CodigoSkill":"3135",'+
  				'"Conferencia":"TRUE",'+
  				'"Desliga":"TRUE",'+
  				'"Espera":"TRUE",'+
            	'"IdPortal":"00001",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSkill';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> skillObj = CEC_CTI_SyncSkill.upsertSkill();

        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : skillObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncSKillErrorExternalIDMissing(){
        
        String myJSON = '[{'+
  				'"Nome":"SKill Retencao",'+
  				'"CodigoSkill":"3135",'+
  				'"Conferencia":"TRUE",'+
  				'"Desliga":"TRUE",'+
  				'"Espera":"TRUE",'+
            	//'"IdPortal":"00001",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSkill';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> skillObj = CEC_CTI_SyncSkill.upsertSkill();
		System.debug('skillObj = ' + skillObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : skillObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncSKillGenericError(){
        String myJSON = '[{'+
  				'"Nome":"SKill Retencao",'+
  				'"CodigoSkill":"3135",'+
  				'"Conferencia":"TRUE",'+
  				'"Desliga":"TRUE",'+
  				'"Espera":"TRUE",'+
            	'"IdPortal":" ",'+
            	'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSkill';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> skillObj = CEC_CTI_SyncSkill.upsertSkill();
		System.debug('skillObj = ' + skillObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : skillObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    static void syncSkillErrorException(){
        String myJSON = '[{'+
  				//'"Nome":"SKill Retencao",'+
  				'"CodigoSkill":"3135",'+
  				'"Conferencia":"TRUE",'+
  				'"Desliga":"3135",'+
  				'"Espera":" ",'+
            	'"Espera":" ",'+
            	'"IdPortal":" ",'+
            	//'"Site":"CSU|APOLONIO|DAC01|CTI01",'+
  				'"Ativo" : "true"'+
 			'}]';
        
        String orgUrl = String.valueOf(System.URL.getSalesforceBaseURL().toExternalForm());
		Boolean successRequisition;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = orgUrl+'/services/apexrest/CEC_CTI_SyncObjects/upsertSkill';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;

        List<CEC_CTI_SyncObjectsWrapper> skillObj = CEC_CTI_SyncSkill.upsertSkill();
		System.debug('skillObj = ' + skillObj);
        Test.stopTest();   
        
        for(CEC_CTI_SyncObjectsWrapper resultAPI : skillObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
}