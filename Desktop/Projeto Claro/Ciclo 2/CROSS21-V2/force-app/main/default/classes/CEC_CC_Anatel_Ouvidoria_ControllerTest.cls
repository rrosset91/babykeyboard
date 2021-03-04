/**
 * ---------------------------------------------------------------
 * Data: 13/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions [Ello Serafim/Guilherme Cuencas]
 * Descrição: ANATEL - Validação de protocolo - Teste da Fachada e Controller para consulta do Caso
*/

@isTest
public class CEC_CC_Anatel_Ouvidoria_ControllerTest {
    
    @testSetup
    public static void setup(){
            Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            Phone = '2192372119',
            DocumentNumber__c = '44080794720',
            Email__c = 'teste@sysmap.com.br',
            vlocity_cmt__BillingEmailAddress__c = 'teste@sysmap.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );
        insert customer;
        Case newCase = null;
        newCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('CEC_CC_Ouvidoria')
                .getRecordTypeId(),
            Status = 'New',
            Subject = 'TesteOuvidoria',
            SuppliedEmail = customer.Email__c,
            PreferencialContact__c = 'Telefone'

        );
        insert newCase;
        
        Case newCase2 = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('CEC_CC_Ouvidoria')
                .getRecordTypeId(),
            Status = 'New',
            Subject = 'TesteOuvidoria2',
            SuppliedEmail = customer.Email__c,
            PreferencialContact__c = 'Telefone'

        );
        insert newCase2;
        
    }
    
    @isTest
    public static void validProtocolTest(){
       
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'TesteOuvidoria' LIMIT 1][0];
        Case insertedCase2 = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'TesteOuvidoria2' LIMIT 1][0];
        Date dt12Days = system.today() - 12;
        Date dt179Days = system.today() - 179;
        Test.setCreatedDate(insertedCase.Id, dt12Days);
        Test.setCreatedDate(insertedCase2.Id, dt179Days);
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "'+ insertedCase.CaseNumber+ '"}');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
		CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo(insertedCase.CaseNumber);
        system.debug(resp);
        
        
        req = new RestRequest(); 
        res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "'+ insertedCase2.CaseNumber+ '"}');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
            
        CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp2 = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo(insertedCase2.CaseNumber);
        system.debug(resp2);
        Test.stopTest();

        System.assertEquals('10', resp.statusWS);
        System.assertEquals('10', resp.statusProtocolo);
        System.assertEquals('10', resp2.statusWS);
        System.assertEquals('10', resp2.statusProtocolo);
        
    }
    
    
    //TODO Tirar os comentários quando tirar os mocks da classe controller
    //*
    @isTest
    public static void closedProtocolTest(){
       
        
        Case insertedCase2 = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'TesteOuvidoria2' LIMIT 1][0];
        Date dt12Days = system.today() - 12;
        Date dt179Days = system.today() - 179;
        Test.setCreatedDate(insertedCase2.Id, dt179Days);
        
        insertedCase2.Status = 'Closed';
        insertedCase2.SubStatus__c = 'Encerrado';
        insertedCase2.Contract__c = '69981114569';
        update insertedCase2;
        Test.startTest();
		
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "'+ insertedCase2.CaseNumber+ '"}');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
            
        CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp2 = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo(insertedCase2.CaseNumber);
        system.debug(resp2);
        Test.stopTest();
        
        System.assertEquals('10', resp2.statusWS);
        System.assertEquals('10', resp2.statusProtocolo);
        
    }
    
    /*
    @isTest
    public static void closedInvalidProtocolTest(){
       
        
        Case insertedCase2 = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'TesteOuvidoria2' LIMIT 1][0];
        //Date dtMaxDays = system.today() - 180;
        Date dtMaxDays = system.today() - 9;
        Test.setCreatedDate(insertedCase2.Id, dtMaxDays);
        
        insertedCase2.Status = 'Closed';
        insertedCase2.SubStatus__c = 'Encerrado';
        insertedCase2.Contract__c = '69981114569';
        update insertedCase2;
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "'+ insertedCase2.CaseNumber+ '"}');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
            
        CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp2 = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo(insertedCase2.CaseNumber);
        system.debug(resp2);
        Test.stopTest();
        
        System.assertEquals('10', resp2.statusWS);
        System.assertEquals('20', resp2.statusProtocolo);
        
    }
	*/
    
    @isTest
    public static void notFoundProtocolTest(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "00112233"}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        
		CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo('00112233');
		system.debug(resp);
        system.debug(res);
        Test.stopTest();

        System.assertEquals('10', resp.statusWS);
        System.assertEquals('21', resp.statusProtocolo);
        System.assertEquals(200, RestContext.response.statusCode);
        
    }

//*/
    
    @isTest
    public static void blankProtocolTest(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        //req.requestBody = Blob.valueOf('{"numero": "'+ insertedCase2.CaseNumber+ '"}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        
		CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo('');
		system.debug(resp);
        system.debug(res);
        Test.stopTest();
        
        System.assertEquals('20', resp.statusWS);
        System.assertNotEquals(null, resp.atendimento);
        
    }
    
    @isTest
    public static void invalidFormatProtocolTest(){

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/validarprotocoloatendimento';
        req.requestBody = Blob.valueOf('{"numero": "0990055"}'); //O mínimo deveria ser 8 dígitos
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        
		CEC_CC_Anatel_Ouvidoria_ProtocolResponse resp = CEC_CC_Api_Anatel_Ouvidoria.validarProtocolo('0990055');
		system.debug(resp);
        system.debug(res);
        Test.stopTest();
        
        System.assertEquals('10', resp.statusWS);
        System.assertEquals('20', resp.statusProtocolo);
        System.assertNotEquals(null, resp.atendimento);
        
    }

    
}