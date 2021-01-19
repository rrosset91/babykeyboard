@isTest
public class SOLAR_IntegrationMessageDAOTest {
    @isTest 
    public static void mainTest(){
       SOLAR_IntegrationMessageDAO integrationMessageDAO = new SOLAR_IntegrationMessageDAO('CEC_PME_SalesDocuments');
       integrationMessageDAO.doSelect();
       String codeMessage = integrationMessageDAO.getCodeMessageByStatusCode(400);
       String codeMessageTest = [SELECT MasterLabel 
                                   FROM Solar_IntegrationMessage__mdt
                                  WHERE ServiceParameter__c = 'CEC_PME_SalesDocuments'
                                    AND IntegrationStatusCode__c = 400
                                  LIMIT 1].MasterLabel;
      System.assertEquals(codeMessageTest, codeMessage, 'O código da mensagem não é o esperado para este teste');
    }
    @isTest 
    public static void exceptionServiceNameNullTest(){
        Boolean hasError = false;
        try{
       		SOLAR_IntegrationMessageDAO integrationMessageDAO = new SOLAR_IntegrationMessageDAO(null);
        } catch(SOLAR_IntegrationMessageDAO.IntegrationMessageDAOException e){
            hasError = true;    
        }
        System.assert(hasError, 'Falha no tratamento de exception');
    }
    @isTest 
    public static void StatusCodeInvalidTest(){
       SOLAR_IntegrationMessageDAO integrationMessageDAO = new SOLAR_IntegrationMessageDAO('CEC_PME_SalesDocuments');
       integrationMessageDAO.doSelect();
       String codeMessage = integrationMessageDAO.getCodeMessageByStatusCode(999);
       System.assert(codeMessage!=null, 'O código da mensagem não é o esperado para este teste');
    }
}