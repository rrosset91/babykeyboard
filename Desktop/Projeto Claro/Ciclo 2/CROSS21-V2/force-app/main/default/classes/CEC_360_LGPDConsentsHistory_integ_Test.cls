/* 	Autor: Rennê Silva - Sysmap
   	Criação: 21/08/2020
   	Descrição: Classe controller para o componente Aura CEC_360_LGPDConsentsHistory.
   	Nome do projeto/ID: LGPD - Direito do Titular / Consentimento
    Alterado por: Guilherme Cuencas 02/09/2020 - 15:11pm
	Time: SQUAD CEC */

@isTest
global class CEC_360_LGPDConsentsHistory_integ_Test  implements HttpCalloutMock {
  
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response to getDsar
        HttpResponse response = new HttpResponse();
        response.setHeader('Accept-Encoding', 'keep-alive');
        response.setHeader('Connection', 'gzip, deflate, br');
        response.setHeader('Accept','*/*');
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"apiversion":"1; 2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","customerOrders":[{"id":"SL244HWD6D","orderDate":"2019-08-09T12:49:47.983Z","completionDate":"2019-08-09T12:49:47.983Z","orderType":"Atualização de dados","status":"Aberto","email": "teste@test.com.br"}]}]}}');
        response.setStatusCode(200);
        return response; 
    } 
    
    @isTest
     public static  void testGetCallout() {
         
        Test.StartTest();
        CEC_360_LGPDIntegrationObjects.GetConsentsHistory consentsHistory = new  CEC_360_LGPDIntegrationObjects.GetConsentsHistory();
        //Test.setMock(HttpCalloutMock.class, new CEC_360_LGPDIntegrationObjects());
        //consentsHistory.customerOrders[0].orderType = 'Acesso_Dados_Cadastrais';
        //consentsHistory = CEC_360_LGPDIntegrationObjects.consentsHistory(' ');
        Test.StopTest();
       // System.debug('Id response get: ' + consentsHistory.customerOrders[0].Id);
        //System.assertEquals(consentsHistory.customerOrders[0].Id, 'SL244HWD6D');
    }



    @IsTest
    static void methodName(){
        Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            Phone = '2192372119',
            DocumentNumber__c = '44080794720',
            Email__c = 'ello.oliveira@sysmap.com.br',
            vlocity_cmt__BillingEmailAddress__c = 'ello.oliveira@sysmap.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );

        insert customer;
        
        Test.setMock(HttpCalloutMock.class, new ProtocolResponseMock());
        
        Test.startTest();
        CEC_360_LGPDConsentsHistoryController.getConsentsHistory(customer.Id);
        CEC_360_LGPDIntegrationObjects.Purpose p = new CEC_360_LGPDIntegrationObjects.Purpose();
        p.id	 = ''; 
        p.status = '';
        p.agreements = new List<CEC_360_LGPDIntegrationObjects.Consent>();
        CEC_360_LGPDIntegrationObjects.GetConsentsHistory his = new CEC_360_LGPDIntegrationObjects.GetConsentsHistory();
        his.data = new List<CEC_360_LGPDIntegrationObjects.Purpose>();
        his.data.add(p);
        
        Test.stopTest();
        
    }


    /*
     public class GetConsentsHistory {
        @AuraEnabled public List<Purpose> data;       
    }
   
    global class Purpose{
        @AuraEnabled public String id;
        @AuraEnabled public String description;
        @AuraEnabled public String notes;
        @AuraEnabled public String consentCreationDate;
        @AuraEnabled public string purposeType;
        @AuraEnabled public String status;
        @AuraEnabled public List<Agreement> agreements;
    }
    */
    global class ProtocolResponseMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                '"apiVersion": "string",' +
                '"transactionId": "string",' +
                '"data": [{' +
                '"id":"id", "description":"desc"' +
                '}]' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    } 
}