/* 	Autor: Rennê Silva - Sysmap
   	Criação: 08/07/2020
   	Nome do projeto/ID: LGPD - Direito do Titular 
    Time: SQUAD LGPD 
* ---------------------------------------------------------------
--- Controle de Versão
-------------------------------------------------------------------------------------------------------
--- Author: Squad LGPD - Sysmap Solutions
--- Description: rename da classe de CEC_360_LGPDdsarController para CEC_360_LGPDdsarController
--- Date: 21/01/2021
--- Alterado por : Fabio Sato Suenaga
*/

    @isTest
    global class CEC_360_LGPDdsarControllerTest implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response saveDsar
            HttpResponse response = new HttpResponse();
            response.setHeader('Accept-Encoding', 'keep-alive');
            response.setHeader('Connection', 'gzip, deflate, br');
            response.setHeader('Accept','*/*');
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"apiVersion": "1;2020-07-01","transactionId":"9811cc4e-3b5e-4e36-aeb3-c48879f51686","data":{"requestQueueRefId":"9G52T9LV2F"}}');
            response.setStatusCode(201);
            return response; 
        }
        
        @TestSetup
        static void setup() {
            //Custom settings
            insert new ServiceParameter__c(
                Name = 'CEC_OAG_Claro_Protocol',
                EndPoint__c = '/interactions',
                IsActive__c = true,
                Method__c ='POST',
                NamedCredential__c = 'OAGClaro',
                Timeout__c = 10000
            );
    
            insert new ServiceParameter__c(
                Name = 'CEC_OAG_NET_Protocol',
                EndPoint__c = '/interactions',
                IsActive__c = true,
                Method__c ='POST',
                NamedCredential__c = 'OAGNet',
                Timeout__c = 10000
            );
        }
        
        @isTest
        static void testPostCallout() {
            CEC_360_LGPDIntegrationObjects.PostDsar responsePostDsar = new  CEC_360_LGPDIntegrationObjects.PostDsar();
            
            System.Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_360_LGPDdsarControllerTest());
            responsePostDsar = CEC_360_LGPDdsarController.saveDsar('{"data": {"language":"en-us","subjectTypes": ["Cliente"],"cpf":"11111111111","email": "teste@teste.com","requestTypes": ["Info_Compartilhadas_Terceiros"],"webFormData": {"channel":"Salesforce","requestDetails":""}}}');
            System.Test.stopTest();
            
            system.debug('responsePostDsar: ' + responsePostDsar);
            System.assertEquals(responsePostDsar.data.requestQueueRefId, '9G52T9LV2F');
        }
        
        @isTest
        static void testGetCallout() {
            // create test account 
            Account acc = new Account();
            acc.Name = 'Teste Get dsar';
            acc.DocumentNumber__c = '11111111111';
            insert acc;
            
            
            System.Test.startTest();
            CEC_360_LGPDIntegrationObjects.GetDsarByStatus responseGetDsar = new CEC_360_LGPDIntegrationObjects.GetDsarByStatus();
               
            Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationdsarTest());
         
            responseGetDsar = CEC_360_LGPDdsarController.getDsarByType(acc.id,'Info_Compartilhadas_Terceiros');
              
            System.Test.stopTest();
            
            system.debug('responseGetDsar: ' + responseGetDsar);
            System.assertEquals(responseGetDsar.customerOrders[0].Id, 'SL244HWD6D'); 
              
        }
        
        @isTest
        public static void testGetCustomMetadatadsar() {
                      
            System.Test.startTest();
            // find metadata using controller method
            List<CEC_LGPDdsar__mdt> getMetadataDsar = CEC_360_LGPDdsarController.getCustomMetadatadsar();
            System.Test.stopTest();
            
            //the metadata must have request types created
            System.assert(getMetadataDsar.size() > 0, 'Tela de direitos do Titular precisa ter tipos de direito cadastrados neste metadado.');
    
        }
        
        @isTest
        public static void testGetCustomMetadataDsarAdditionalFields() {
                      
            System.Test.startTest();
            // find metadata using controller method
            List<CEC_LGPDdsar_AdditionalFields__mdt> getMetadataDsarAdditionalFields = CEC_360_LGPDdsarController.getCustomMetadataDsarAdditionalFields();
            System.Test.stopTest();
            
            //the metadata must have additional fields created
            //System.assert(getMetadataDsarAdditionalFields.size() > 0, 'Tela de direitos do Titular precisa ter campos adicionais cadastrados para enviar na integração com OneTrust.');
    
        }
        
        @isTest
        public static void testGetCustomerData() {
                 
            // create Test account
            Account acc = new Account();
            acc.Name = 'Metadata Test';
            acc.DocumentNumber__c = '11111111111';
            acc.vlocity_cmt__BillingEmailAddress__c = 'emailtest@metadata.com';
            insert acc;
            
            System.Test.startTest();
            // find metadata using controller method
            Account customerData = CEC_360_LGPDdsarController.getCustomerData(acc.Id);
            System.Test.stopTest();
            
            //the metadata must have request types created
            System.assertEquals(customerData.DocumentNumber__c,'11111111111');
            System.assertEquals(customerData.vlocity_cmt__BillingEmailAddress__c,'emailtest@metadata.com');
        }
    
        @isTest
        public static void testGetDadosConta() {
                 
            // create Test account
            Account acc = new Account();
            acc.Name = 'Metadata Test';
            acc.DocumentNumber__c = '11111111111';
            acc.vlocity_cmt__BillingEmailAddress__c = 'emailtest@metadata.com';
            insert acc;
            
            System.Test.startTest();
            // find metadata using controller method
            Account customerData = CEC_360_LGPDdsarController.getDadosConta(acc.Id);
            System.Test.stopTest();
            
            //the metadata must have request types created
            System.assertEquals(customerData.DocumentNumber__c,'11111111111');
            System.assertEquals(customerData.vlocity_cmt__BillingEmailAddress__c,'emailtest@metadata.com');
        } 
        
        @isTest
        public static void testGetUserName() {
                      
            System.Test.startTest();
            // find metadata using controller method
            User user = CEC_360_LGPDdsarController.getUserName();
            System.Test.stopTest();
            
            system.debug('Username: ' + user.UserName + ' - FederationId: ' + user.FederationIdentifier);
            
            //the metadata must have additional fields created
            System.assert(user != null, 'Encontrou user que chamou o método.');
    
        }
    
        
        @isTest
        public static void testGetProtocol() {
                 
            // create Test account
            Account acc = new Account();
            acc.Name = 'Create Account Name';
            acc.DocumentNumber__c = '11111111111';
            acc.vlocity_cmt__BillingEmailAddress__c = 'emailtest@metadata.com';
            acc.Phone = '11111111111';
            acc.CustomerTypeList__c = 'ASSINANTE_CLARO';
            insert acc;
            
            Test.setMock(
                HttpCalloutMock.class,
                new CEC_LGPD_ProtocolControllerTest.CEC_LGPD_NETSMSProtocolResponseMock()
            );
            
            System.Test.startTest();
            // find metadata using controller method
            map<string,string> Protocol = CEC_360_LGPDdsarController.getProtocolNumber(acc.Id,'Tratamento_Dados');
            System.Test.stopTest();
            
            system.debug('Protocol: ' + Protocol);
            
           
        }
        
 @isTest
    public static void testUpdateIdCase() {
        String idDsar = 'XXXX00001';
        
        // create Test account
        Account acc = new Account();
        acc.Name = 'Create Account Name';
        acc.DocumentNumber__c = '11111111111';
        acc.vlocity_cmt__BillingEmailAddress__c = 'emailtest@metadata.com';
        acc.Phone = '11111111111';
        acc.CustomerTypeList__c = 'ASSINANTE_CLARO';
        insert acc; 
        
        Case lCase = new Case();
        lCase.BusinessUnit__c = 'Claro';
        lCase.Subject = 'Confirmação de tratamento';
        lCase.Grouping__c = 'Consumidor.gov';
        lCase.Channel__c = 'Consumidor.gov';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.Status = 'Novo';
        lCase.SubStatus__c = 'Não Iniciado';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.CriticalChannelProtocol__c = '1234567';
        lCase.LGPD_ID__c = '';
        lCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId();
        lCase.OpenDateRobot__c = system.now();
        
        Insert lCase;
        
        CEC_360_LGPDdsarController.updateIdCase(idDsar,lCase.Id);
        
        
    }                
        
    }