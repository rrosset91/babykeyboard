/*
* Autor: Diego Lima - Deloitte
* Data: 05/12/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para os testes da classe
CEC_CTI_SyncTransfer]
*/

@isTest
public class CEC_CTI_SyncTransferTest {

    @isTest
    public static void successUpsertTransfer() {
        
        //INSERIR NOVO SITE
        String myJSONsite = '[{'+
  				'"Name" : "Test Site",'+
  				'"Localizador" : "CSU|APOLONIO|DAC01|CTI01",'+
  				'"LigacaoExterna" : "true",'+
  				'"Tecnologia" : "Avaya",'+
  				'"Unidade" : "SP",'+
  				'"Ativo" : "true"'+
 			'}]';
        	
        RestRequest requestSite = new RestRequest();
        requestSite.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        requestSite.httpMethod = 'POST';
        requestSite.requestBody = Blob.valueof(myJSONsite);
        RestContext.request = requestSite;

        CEC_CTI_SyncSite.upsertSite();
        
        
        //INSERIR NOVA SKILL
       	String jsonSkill = '[{"Nome":"SKill Retencao","CodigoSkill":"3135","Conferencia":"TRUE","Desliga":"TRUE","Espera":"TRUE","IdPortal":"00001","Site":"CSU|APOLONIO|DAC01|CTI01","Ativo":"true"}]';
        
        RestRequest requestSkill = new RestRequest();
        requestSkill.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        requestSkill.httpMethod = 'POST';
        requestSkill.requestBody = Blob.valueof(jsonSkill);
        RestContext.request = requestSkill;

		CEC_CTI_SyncSkill.upsertSkill();
        
        
        String transferMock = '{"transfers":[{"label":"Teste 2.1 TESTE up","transferId":"1testlkp-1","nivelSuperior":"","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.2 up","transferId":"2testlkp-1","nivelSuperior":"1testlkp-1","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.3 up","transferId":"3testlkp-1","nivelSuperior":"2testlkp-1","destinoVDNTC":"1443","skillId":"3135","isActive":true}]}]}]}';
  
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(transferMock);
        RestContext.request = request;
        
        
        List<CEC_CTI_SyncObjectsWrapper> transferlObj = CEC_CTI_SyncTransfer.upsertTransfer();
		System.debug('skillObj = ' + transferlObj);
        Test.stopTest();   
        
        Boolean successRequisition;
        for(CEC_CTI_SyncObjectsWrapper resultAPI : transferlObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(true, successRequisition);
        
        
    }
    
    @isTest
    public static void errorFieldUpsertTransfer() {
       
        String mockError = '{"transfers":[{"label":"Teste 2.1 TESTE up 3123123123123231231232131231232132132132132131231231222143432423423423432423","transferId":"1testlkp-1","nivelSuperior":"","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.2 up","transferId":"2testlkp-1","nivelSuperior":"1testlkp-1","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.3 up","transferId":"3testlkp-1","nivelSuperior":"2testlkp-1","destinoVDNTC":"1443","skillId":"3135","isActive":true}]}]}]}';
        
        RestRequest request = new RestRequest();
        request.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(mockError);
        RestContext.request = request;
        
        List<CEC_CTI_SyncObjectsWrapper> transferlObj = CEC_CTI_SyncTransfer.upsertTransfer();
        
        Boolean successRequisition;
        for(CEC_CTI_SyncObjectsWrapper resultAPI : transferlObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    public static void errorJsonUpsertTransfer() {
       
        String mockError = '---';
        
        RestRequest request = new RestRequest();
        request.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(mockError);
        RestContext.request = request;
        
        List<CEC_CTI_SyncObjectsWrapper> transferlObj = CEC_CTI_SyncTransfer.upsertTransfer();
        
        Boolean successRequisition;
        for(CEC_CTI_SyncObjectsWrapper resultAPI : transferlObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
    
    @isTest
    public static void errorRequiredFieldUpsertTransfer() {

        String mockError = '{"transfers":[{"label":"","transferId":"1testlkp-1","nivelSuperior":"","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.2 up","transferId":"2testlkp-1","nivelSuperior":"1testlkp-1","destinoVDNTC":"","skillId":"3135","isActive":true,"transfers":[{"label":"Teste 2.3 up","transferId":"3testlkp-1","nivelSuperior":"2testlkp-1","destinoVDNTC":"1443","skillId":"3135","isActive":true}]}]}]}';
        
        RestRequest request = new RestRequest();
        request.requestUri = '/CEC_CTI_SyncObjects/upsertTransfer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(mockError);
        RestContext.request = request;
        
        List<CEC_CTI_SyncObjectsWrapper> transferlObj = CEC_CTI_SyncTransfer.upsertTransfer();
        
        Boolean successRequisition;
        for(CEC_CTI_SyncObjectsWrapper resultAPI : transferlObj){
            successRequisition = resultAPI.successOperation;
        }
        
        System.assertEquals(false, successRequisition);
    }
}