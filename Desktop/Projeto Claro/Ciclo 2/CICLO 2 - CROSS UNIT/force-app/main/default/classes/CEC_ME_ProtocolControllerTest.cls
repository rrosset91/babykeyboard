@isTest
public class CEC_ME_ProtocolControllerTest {
    
    @isTest
    public static void paginaBuscaTeste(){
        Test.setCurrentPageReference(new PageReference('CEC_URA_Protocol')); 
        System.currentPageReference().getParameters().put('protocolnumber', 'test');
        System.currentPageReference().getParameters().put('contractnumber', 'test');
        CEC_ME_ProtocolController protocolController = new CEC_ME_ProtocolController();
        PageReference pageTest = protocolController.callRedirect();
        System.assertEquals('/lightning/n/Buscar_Cliente', pageTest.getUrl());
        
    }    
    
}