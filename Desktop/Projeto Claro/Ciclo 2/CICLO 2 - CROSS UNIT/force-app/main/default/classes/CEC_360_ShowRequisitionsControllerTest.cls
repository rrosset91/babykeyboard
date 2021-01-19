/* 
* @author: Diogo Braga - Deloitte 
* @date: 17/12/2019
*
* @description: Classe de teste
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/
@isTest
public class CEC_360_ShowRequisitionsControllerTest {
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: test setup*/
    @testSetup 
    public static void testSetup() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.CityCode__c = '000';
        newAccount.ContractReferenceNumber__c  = '0000000';
        insert newAccount;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: testa a integração de OC*/
    @isTest
    public static void getOCs() {
        String strRequisition ='{"orderRequest": {"statusDescription": "EXECUTADA","status": "1","requestID": "368249067","operatorCode": "003","contractNumber": "386923328","closeUser": "OPS$OSWAP","cityId": "88412","requestTypeID": "1","requestTypeDescription": "ADESAO - INSTALACAO DE ASSINATURA","openUser": "T6805581","obs": "","closeDate": "13/06/2017","cancelReasonID": null,"cancelReasonDescription": null},"listWorkOrder": null,"listConfigOrder": null,"isSelected": false,"id": "0"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationsConfigurationTest.IntegrationsConfigurationMock());
        
        CEC_360_ShowRequisitionsController.Requisition varRequisition = CEC_360_ShowRequisitionsController.getOCs(strRequisition);
        
        system.assert(varRequisition != null, 'OCs não retornadas');
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: testa a integração de OS*/
    @isTest
    public static void getOSs() {
        String strRequisition ='{"orderRequest": {"statusDescription": "EXECUTADA","status": "1","requestID": "368249067","operatorCode": "003","contractNumber": "386923328","closeUser": "OPS$OSWAP","cityId": "88412","requestTypeID": "1","requestTypeDescription": "ADESAO - INSTALACAO DE ASSINATURA","openUser": "T6805581","obs": "","closeDate": "13/06/2017","cancelReasonID": null,"cancelReasonDescription": null},"listWorkOrder": null,"listConfigOrder": null,"isSelected": false,"id": "0"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationsWorkOrderTest.IntegrationsWorkOrderMock());
        
        CEC_360_ShowRequisitionsController.Requisition varRequisition = CEC_360_ShowRequisitionsController.getOSs(strRequisition);
        
        system.assert(varRequisition != null, 'não retornadas');
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: testa a integração de Request*/
    @isTest
    public static void getTable() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_360_IntegrationsOrderRequestTest.IntegrationsOrderRequestMock());
        
        CEC_360_ShowRequisitionsController.Table varTable = 
            CEC_360_ShowRequisitionsController.getTable(system.today().addMonths(-5), system.today(), '', [SELECT Id FROM Account].Id);
        Test.stopTest();
        
        system.assert(varTable != null, 'Tabela não retornada');
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 17/12/2019
	* @description: testa a configuração de busca*/
    @isTest
    public static void getSearchConfig() {
        CEC_360_ShowRequisitionsController.SearchConfig varSearchConfig = CEC_360_ShowRequisitionsController.getSearchConfig();
        
        system.assert(varSearchConfig != null, 'configurações de pesquisa não retornadas');
    }
    
    
}