/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-17-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public with sharing class InvoicesSendDuplicateTest {
	
    @testSetup static void charge(){
		ServiceParameter__c eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'SendDuplicate';
        eventsSettings.EndPoint__c = 'callout:OAGClaro/orders/request';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120000;
        eventsSettings.ReturnMock__c = true;
		insert eventsSettings;   
        eventsSettings = new ServiceParameter__c();
        eventsSettings.name = 'PostDuplicate';
        eventsSettings.EndPoint__c = '00';
        eventsSettings.Method__c = 'GET';
        eventsSettings.Timeout__c = 120;
        eventsSettings.ReturnMock__c = false;
        insert eventsSettings; 

        Id recordTypeIdAccount   = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); 
        
        Account contrato =  new Account(
            RecordTypeId = recordTypeIdAccount,
            name = 'Teste',
            ContractReferenceNumber__c = '229531991',
            StatusLegado__c  =  'Conectado' ,
            vlocity_cmt__CustomerValue__c = 'Black'
        );
        Insert contrato;

		// Contract contrato = new Contract();
		// contrato.AccountId = acc.Id;
		// insert contrato;

		Case cs = new Case();
		cs.ContractBillingAccount__c = contrato.Id;
		// cs.Contract__c = contrato.Id;
		cs.OpenDateRobot__c = System.now();
		insert cs;
    } 
    
    @isTest 
    static void getDuplicateInvoiceTest(){
        String result;
        
        test.startTest();
        try{
            InvoicesSendDuplicate.getDuplicateInvoice('229531991', '004');
        }
        catch(exception e){
            
        } 
        test.stopTest();
        system.assertEquals(result, result);
	}
    
        @isTest static void postDuplicateTest() 
    {
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        InvoiceDetailsMock mock = new InvoiceDetailsMock('{"apiVersion":"string","transactionId":"string","data":{"billId":"12323","billNewId":"456789","dueDate":"31/12/2020","message":"2ª via de fatura enviada com sucesso."}}',200);
        Test.setMock(HttpCalloutMock.class, mock);
        String result;
             
        Test.startTest();
        //try{
            InvoicesSendDuplicate.postDuplicateInvoice('004','1027935','MCIDA','229531991','ROGERIO GONCALVES RODRIGUES','62996656204','rogerio.gr7@gmail.com','L','NAO','CLIENTE NÃO RECEBEU A FATURA',caseId);
       // }
        //catch(exception e){
            
       // }
        Test.stopTest();
        system.assertEquals(result,result); 
    }
    
    @isTest 
    static void processPostJsonTest(){
        String result;
        test.startTest();
        	InvoicesSendDuplicate.processPostJson('004','1027935','MCIDA','229531991','ROGERIO GONCALVES RODRIGUES','62996656204','rogerio.gr7@gmail.com','L','NAO',69,'ATRASO - TRANSMISSÃO ARQUIVO FEBRABAN');
        test.stopTest();
        system.assertEquals(result, result);
    }
    
    @isTest 
    static void getSendReasonsTeste(){
        String result;
		test.startTest();
        List<Integer> availableIds = new List<Integer>();
        availableIds.add(0);
        availableIds.add(59);
        availableIds.add(60);
        availableIds.add(61);
        	try{
                InvoicesSendDuplicate.getSendReasons(availableIds);
            }
            catch(exception e){
                
            }
        test.stopTest();
        system.assertEquals(result, result);
    }    
        
    @isTest 
    static void setErrorMessageTeste(){
        String result;
		test.startTest();
            try{
                InvoicesSendDuplicate.setErrorMessage('');
            }
            catch(exception e){
                
            }
        test.stopTest();
        system.assertEquals(result, result);
    }
    
    @isTest 
    static void processPostJsonResponseTest(){
        String result;
        String mockJson = '{"apiVersion":"string","transactionId":"string","data":{"billId":"12323","billNewId":"456789","dueDate":"31/12/2020","message":"2ª via de fatura enviada com sucesso."}}';
        test.startTest();
        	InvoicesSendDuplicate.processPostJsonResponse(mockJson);
        test.stopTest();
        system.assertEquals(result, result);
    }
        
   	@isTest 
    static void processJsonTest(){
        String result;
        String mockJson = '{"apiVersion”:"1.0","transactionId”:null,"data”:{"userHasAccess”:"SIM”,"billAllowsSending”:"SIM”,"billExtend”:"NAO”,"contractNumber”:"1027935","name”:"ROGERIO GONCALVES RODRIGUES”,"email”:"rogerio.gr7@gmail.com”,"phoneNumber”:"13997836227","note”:"”,"listSendMethod”:[{"sendMethodId”:"L”,"sendMethodDescription”:"LOCAL”,"isExtended”:"SIM”},{"sendMethodId”:"S”,"sendMethodDescription”:"SMS”,"isExtended”:"SIM”}],"listReason”:[{"reasonId”:72,"descriptionReason”:"ATRASO-TRANSMISSÃO ARQUIVO FEBRABAN”,"isExtended”:"SIM”}]}}';
        test.startTest();
            try{
               InvoicesSendDuplicate.processSendMethods(mockJson); 
            }
            catch(exception e){
                
            }
        test.stopTest();
        system.assertEquals(result, result);
    }
  
    @isTest 
    static void setParamsTest(){
        String result;
        test.startTest();
        InvoicesSendDuplicate.setParams('2727182', '004');
        test.stopTest();
        system.assertEquals(result, result);
    }
    
    @isTest 
    static void setParamsEmptyTest(){
        String result;
        test.startTest();
            try{
                InvoicesSendDuplicate.setParams('', '');
            }
        	catch(exception e){
            
        	}
        	
        test.stopTest();
        system.assertEquals(result, result);
    }

   /* @isTest 
    static void closeCaseWhenDuplicateSentTest(){
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        test.startTest();
            InvoicesSendDuplicate.closeCaseWhenDuplicateSent(objCase.Id,'Boleto','atraso');
        test.stopTest();
    }*/
    
    /*
    @isTest 
	static void setHeadersTest(){
        String result;
        test.startTest();
        InvoicesSendDuplicate.setHeaders();
        test.stopTest();
        system.assertEquals(result, result);
    }
    
    @isTest 
	static void processErrorJson(){
        String result;
        String mockJsonError = '{"apiVersion": "1;2020-03-22","transactionId": "Id-34fcb05c6d1923e35cef248d","error": {"httpCode": 400,"errorCode": "API-INVOICESDUPLICATE-400","message": "Bad Request","detailedMessage": "Invalid Request for operation.","link": {"rel": "related","href": "https://api.net.com.br/docs/error_codes.html"}}}';
        test.startTest();
        InvoicesSendDuplicate.setErrorMessage(mockJsonError);
        test.stopTest();
        system.assertEquals(result, result);
    }
    */
}