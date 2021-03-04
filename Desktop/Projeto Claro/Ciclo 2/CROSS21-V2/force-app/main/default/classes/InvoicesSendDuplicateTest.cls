/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-02-2021
 * @last modified by  : Felipe Ducheiko
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-17-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public with sharing class InvoicesSendDuplicateTest {
	
	@testSetup 
	static void makeData(){

		ServiceParameter__c eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'SendDuplicate';
        eventsSettings.EndPoint__c = 'SendDuplicate';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
		insert eventsSettings;   

        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'PostDuplicate';
        eventsSettings.EndPoint__c = 'PostDuplicate';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120;
        insert eventsSettings; 

		Account contract = AccountDataFactory.getSingleAccount('Billing');
		contract.ContractReferenceNumber__c = '229531991';
        contract.StatusLegado__c = 'Conectado';
		Insert contract;
		
		Case cs = CaseDataFactory.getSingleCase('Billing', contract.Id);
		insert cs;
    } 
    
    @isTest 
    static void getDuplicateInvoiceTest(){

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        Map<String,Object> response = InvoicesSendDuplicate.getDuplicateInvoice('229531991', '004');
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals(true, response.get('success'));
	}
    
	@isTest 
	static void postDuplicateTest(){
        
        Case cs = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new Mock());
             
        Test.startTest();
        Map<String, Object> response = (Map<String, Object>) InvoicesSendDuplicate.postDuplicateInvoice('004','1027935','MCIDA','229531991','ROGERIO GONCALVES RODRIGUES','62996656204','rogerio.gr7@gmail.com','L','NAO','CLIENTE NÃO RECEBEU A FATURA', cs.id);
		Test.stopTest();
		
		System.assertNotEquals(null, response);
		System.assertEquals(true, response.get('success'));
    }
    
    @isTest 
    static void processPostJsonTest(){

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        String response = InvoicesSendDuplicate.processPostJson('004','1027935','MCIDA','229531991','ROGERIO GONCALVES RODRIGUES','62996656204','rogerio.gr7@gmail.com','L','NAO',69,'ATRASO - TRANSMISSÃO ARQUIVO FEBRABAN');
		Test.stopTest();
		
		System.assertNotEquals(null, response);
    }
    
    @isTest 
    static void getSendReasonsTest(){
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
    	List<Integer> availableIds = new List<Integer>{0, 59, 60, 61};
        List<Object> response = InvoicesSendDuplicate.getSendReasons(availableIds);
		Test.stopTest();
		
		System.assertNotEquals(null, response);
    }    
        
    @isTest 
    static void setErrorMessageTest(){

		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        String response = InvoicesSendDuplicate.setErrorMessage('{}');
		Test.stopTest();
		
		System.assertEquals('Unknown error', response);
    }
    
    @isTest 
    static void processPostJsonResponseTest(){
        String mockJson = '{"apiVersion":"string","transactionId":"string","data":{"billId":"12323","billNewId":"456789","dueDate":"31/12/2020","message":"2ª via de fatura enviada com sucesso."}}';

		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        JSONPostDuplicateResponse response = InvoicesSendDuplicate.processPostJsonResponse(mockJson);
		Test.stopTest();
		
		System.assertNotEquals(null, response);
		System.assertEquals('2ª via de fatura enviada com sucesso.', response.message);
    }
        
   	@isTest 
    static void processJsonTest(){
        String mockJson = '{"apiVersion":"1.0","transactionId":null,"data":{"userHasAccess":"SIM","billAllowsSending":"SIM","billExtend":"NAO","contractNumber":"1027935","name":"ROGERIO GONCALVES RODRIGUES","email":"rogerio.gr7@gmail.com","phoneNumber":"13997836227","note":"","listSendMethod":[{"sendMethodId":"L","sendMethodDescription":"LOCAL","isExtended":"SIM"},{"sendMethodId":"S","sendMethodDescription":"SMS","isExtended":"SIM"}],"listReason":[{"reasonId":72,"descriptionReason":"ATRASO-TRANSMISSÃO ARQUIVO FEBRABAN","isExtended":"SIM"}]}}';
		
		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
        InvoicesDuplicateWrapper response = InvoicesSendDuplicate.processSendMethods(mockJson); 
		Test.stopTest();
		
		System.assertNotEquals(null, response);
		System.assertEquals('1027935', response.contractNumber);
    }
  
    @isTest 
    static void setParamsTest(){

		Test.setMock(HttpCalloutMock.class, new Mock());

        Test.startTest();
        Map<String, String> response = InvoicesSendDuplicate.setParams('2727182', '004');
		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals('004', response.get('operatorCode'));
    }
    
    @isTest 
    static void setParamsEmptyTest(){

		Test.setMock(HttpCalloutMock.class, new Mock());

		Test.startTest();
		try {
			InvoicesSendDuplicate.setParams('', '');	
		} catch (Exception e) {
			System.assertEquals('Todos os parâmetros para realizar a busca devem ser preenchidos - , billId, operatorCode', e.getMessage());
		} finally {
			Test.stopTest();
		}    
	}
	
	private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('SendDuplicate')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1.0","transactionId":null,"data":{"userHasAccess":"SIM","billAllowsSending":"SIM","billExtend":"NAO","contractNumber":"1027935","name":"ROGERIO GONCALVES RODRIGUES","email":"rogerio.gr7@gmail.com","phoneNumber":"13997836227","note":"","listSendMethod":[{"sendMethodId":"L","sendMethodDescription":"LOCAL","isExtended":"SIM"},{"sendMethodId":"C","sendMethodDescription":"CORREIO","isExtended":"SIM"},{"sendMethodId":"E","sendMethodDescription":"E-MAIL","isExtended":"SIM"},{"sendMethodId":"F","sendMethodDescription":"FAX","isExtended":"SIM"},{"sendMethodId":"S","sendMethodDescription":"SMS","isExtended":"SIM"}],"listReason":[{"reasonId":72,"descriptionReason":"ATRASO-TRANSMISSÃO ARQUIVO FEBRABAN","isExtended":"SIM"},{"reasonId":69,"descriptionReason":"DEMORA NO ESCLAREC FATURA PELA ÁREA DE PÓSVENDA","isExtended":"SIM"},{"reasonId":51,"descriptionReason":"DEMORA NO ESCLAREC FATURA PELA AREA FATURAMENTO","isExtended":"SIM"},{"reasonId":52,"descriptionReason":"DEMORA NO ESCLAREC FATURA PELA FORCA DE VENDAS","isExtended":"SIM"},{"reasonId":53,"descriptionReason":"ERRO CADAST DO VCTO NO SISTEMA DE EMIS DE FATURA","isExtended":"SIM"},{"reasonId":60,"descriptionReason":"ERRO DE CADASTRAMENTO DE DOMICILIO BANCARIO","isExtended":"SIM"},{"reasonId":55,"descriptionReason":"ERRO ENCAMINHAMENTO DO VCTO P AREA DE FATURAMENTO","isExtended":"SIM"},{"reasonId":67,"descriptionReason":"ERRO POR DEFINIÇÃO DE MARKETING","isExtended":"SIM"},{"reasonId":65,"descriptionReason":"ERRO PROVOC POR FALHA SISTEMA DE PRE-FATURAMENTO","isExtended":"SIM"},{"reasonId":66,"descriptionReason":"FALHA DE ORIGEM TECNICO/OPERACIONAL","isExtended":"SIM"},{"reasonId":59,"descriptionReason":"FALHA NO CADASTRAMENTO DE DEBITO AUTOMATICO","isExtended":"SIM"},{"reasonId":62,"descriptionReason":"FATURA EM PROCESSO JURIDICO","isExtended":"SIM"},{"reasonId":70,"descriptionReason":"GREVE NA ECT","isExtended":"SIM"},{"reasonId":58,"descriptionReason":"NAO ATUALIZ DADOS CADAS CLIENTE P FORCA D VENDAS","isExtended":"SIM"},{"reasonId":48,"descriptionReason":"NAO RECEB.DA NOTA FISCAL DE ICMS PELO CLIENTE","isExtended":"SIM"},{"reasonId":49,"descriptionReason":"NAO RECEB.DA NOTA FISCAL DE ISS PELO CLIENTE","isExtended":"SIM"},{"reasonId":47,"descriptionReason":"NAO RECEBIMENTO DA FATURA PELO CLIENTE","isExtended":"SIM"},{"reasonId":56,"descriptionReason":"NEGOCIACAO COMERCIAL PELA FORCA DE VENDAS","isExtended":"SIM"},{"reasonId":57,"descriptionReason":"NEGOCIACAO FINANCEIRA PELA AREA DE COBRANCA","isExtended":"SIM"},{"reasonId":61,"descriptionReason":"PROBLEMAS NO CD COM DETALHAMENTO DA FATURA","isExtended":"SIM"},{"reasonId":50,"descriptionReason":"RECEB.DA FATURA COM MENOS DE CINCO DIAS DO VCTO","isExtended":"SIM"}]}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('PostDuplicate')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"string","transactionId":"string","data":{"billId":"12323","billNewId":"456789","dueDate":"31/12/2020","message":"2ª via de fatura enviada com sucesso."}}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}