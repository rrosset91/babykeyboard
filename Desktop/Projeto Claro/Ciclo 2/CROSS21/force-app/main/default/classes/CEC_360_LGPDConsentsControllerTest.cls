/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 30/04/2020
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest(SeeAllData=true)
public class CEC_360_LGPDConsentsControllerTest {
    
    @isTest
    static  void testPutCallout() {
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest());
        
        Account acc = [SELECT Id FROM Account limit 1];

        String jsonRequest = '{ '
                +  '  \"protocolNumber\": 123456789, '
                +  '  \"channel\": \"SOLAR\", '
                +  '  \"collectionPointId\": \"da3e61bc-e285-4fc8-abc3-f98d0e1bb800\", '
                +  '  \"purposes\": [ '
                +  '      { '
                +  '          \"agreements\": [ '
                +  '             { '
                +  '                  \"id\": \"089b5e8b-74c9-449a-a109-5027091ba278\", '
                +  '                  \"options\": [ '
                +  '                      { '
                +  '                          \"id\": \"17ab2ae0-4dd3-4949-bc01-0465a67d1c30\" '
                +  '                     } '
                +  '                    ] '
                +  '                } '
                +  '            ], '
                +  '            \"id\": \"f78107d6-8ac2-4615-87df-dfc1ce5f84e5\" '
                +  '        } '
                +  '    ] '
                +  ' }';
             
        String response = CEC_360_LGPDConsentsController.saveConsents(acc.id, jsonRequest);
     
    }

    @isTest
    static void testGetCallout() {
        list<string> selectedDelList;
        CEC_360_IntegrationConsents.ConsentsData ObjectsGet = new CEC_360_IntegrationConsents.ConsentsData();
        
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest());
        Account acc = [SELECT Id FROM Account limit 1];

        ObjectsGet = CEC_360_LGPDConsentsController.getConsents(acc.id);
        
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
        String Protocol = CEC_360_LGPDConsentsController.getProtocolNumber(acc.Id);
        System.Test.stopTest();
        
        system.debug('Protocol: ' + Protocol);
        
        System.assertEquals('076123123123123', Protocol);
    }
    
}