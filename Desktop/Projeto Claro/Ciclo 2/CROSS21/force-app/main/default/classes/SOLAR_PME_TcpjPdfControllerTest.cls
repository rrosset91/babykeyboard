@isTest
public class SOLAR_PME_TcpjPdfControllerTest {

    @testSetup
    public static void testSetup() {
        CEC_PME_OrderTestMethods.generateAllData();
        
        insert buildUser();
    }
    
    private static User buildUser() {
        User varUser = new User();
        varUser.ProfileId = [SELECT Id FROM Profile WHERE name = 'AACE PME'].Id;
        varUser.FirstName = 'Teste';
        varUser.LastName = 'Test';
        varUser.Alias = 'Test';
        varUser.Email = 'usertest@teste.com';
        varUser.Username = 'usertest@teste.com';
        varUser.CommunityNickname = 'UserTest';
        varUser.LocaleSidKey = 'pt_BR';
        varUser.LanguageLocaleKey = 'pt_BR';
        varUser.EmailEncodingKey = 'UTF-8';
        varUser.TimeZoneSidKey = 'America/Sao_Paulo';
        return varUser;
    }
    
    @isTest
    public static void mainTest() {
        System.currentPageReference().getParameters().put('id', [SELECT Id FROM Order LIMIT 1].Id);
        SOLAR_PME_TcpjPdfController tcpjPdfcontroller = new SOLAR_PME_TcpjPdfController();
        
        tcpjPdfcontroller.getCNPJResale();
        tcpjPdfcontroller.getReceiverMobile1();
        tcpjPdfcontroller.getReceiverMobile2();
        tcpjPdfcontroller.getReceiverMobile3();
        tcpjPdfcontroller.getReceiverRG1();
        tcpjPdfcontroller.getReceiverRG2();
        tcpjPdfcontroller.getReceiverRG3();
        tcpjPdfcontroller.getListPlans();
        tcpjPdfcontroller.getListOrderItemWithDonor();
        tcpjPdfcontroller.getHasDonor();
        tcpjPdfcontroller.getIsLd21();
        tcpjPdfcontroller.getListAdministrators();
        tcpjPdfcontroller.getListDonorsAnchor();
        tcpjPdfcontroller.getDeviceTotalizer();
        tcpjPdfcontroller.getFormattedAccountShipPostcode();
        tcpjPdfcontroller.getFormattedBillingPostalCode();
        tcpjPdfcontroller.getShippingAddressType();
        tcpjPdfcontroller.getShippingComplement();
        tcpjPdfcontroller.getBillingAddressType();
        tcpjPdfcontroller.getBillingComplement();
        
        for(CEC_PME_SalesDocumentsRequest.Plans plan : tcpjPdfcontroller.salesDocuments.plans) {
            plan.groups = new List<CEC_PME_SalesDocumentsRequest.Groups>();
            CEC_PME_SalesDocumentsRequest.Groups groups = new CEC_PME_SalesDocumentsRequest.Groups();
            groups.franchise = '1GB';
            plan.groups.add(groups);            
        }
        
        tcpjPdfcontroller.buildAnxContPermModel();
        
        for(CEC_PME_SalesDocumentsRequest.Plans plan : tcpjPdfcontroller.salesDocuments.plans) {
            plan.groups = new List<CEC_PME_SalesDocumentsRequest.Groups>();
            plan.name = 'Plano Claro Total Compartilhado';
            CEC_PME_SalesDocumentsRequest.Groups groups = new CEC_PME_SalesDocumentsRequest.Groups();
            groups.franchise = '5GB';
            plan.groups.add(groups);          
        }
        
        tcpjPdfcontroller.buildAnxContPermModel();
        
        System.assertEquals(tcpjPdfcontroller.getAccountCNPJ(), '---', 'sem cnpj');
    }
    
    @isTest
    public static void buildAdministrator() {
        SOLAR_PME_TcpjPdfController.Administrator administrator = new SOLAR_PME_TcpjPdfController.Administrator(1, new CEC_PME_SalesDocumentsRequest.Administrators());
        String mobilePhone = administrator.mobilePhone;
        String phone = administrator.phone;
    }
    
}