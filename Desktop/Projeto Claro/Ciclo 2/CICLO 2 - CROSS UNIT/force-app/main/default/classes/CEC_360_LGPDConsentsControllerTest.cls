/* 	Autor: Rodolfo Rodrigo - Sysmap
   	Criação: 30/04/2020
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
@isTest(SeeAllData=true)
public class CEC_360_LGPDConsentsControllerTest {
    
    @isTest
    static  void testPutCallout() {
        
        CEC_RestObjects.PutConsents ObjectsPut = new  CEC_RestObjects.PutConsents();
        List<CEC_RestObjects.Consent> consents = new List<CEC_RestObjects.Consent>();
        ObjectsPut.origin = 'CEC';
        ObjectsPut.agreements = consents;
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationConsentsTest());
        
        Account acc = [SELECT Id FROM Account limit 1];
             
        ObjectsPut = CEC_360_LGPDConsentsController.saveConsents(acc.id,'JSON','purposeId');
     
    }
    @isTest
    static void testGetCallout() {
        list<string> selectedDelList;
        CEC_RestObjects.GetConsents ObjectsGet = new  CEC_RestObjects.GetConsents();
        List<CEC_RestObjects.Purpose> lstCharacReq = new List<CEC_RestObjects.Purpose>();
        ObjectsGet.preferenceCenterId = 'id12356';
        ObjectsGet.protocolNumber = 'protocolo1235125';
        ObjectsGet.Purposes = lstCharacReq;
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