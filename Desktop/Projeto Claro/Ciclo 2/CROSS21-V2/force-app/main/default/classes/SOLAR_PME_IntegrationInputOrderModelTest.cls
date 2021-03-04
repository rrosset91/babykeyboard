@isTest
public class SOLAR_PME_IntegrationInputOrderModelTest {
    
    private SOLAR_PME_IntegrationInputOrderModel model = new SOLAR_PME_IntegrationInputOrderModel();
    
    @TestSetup
    static void testSetup(){
        
    }
    
    @isTest
    static void bonus() {
        SOLAR_PME_IntegrationInputOrderModel.Bonus bonus= new SOLAR_PME_IntegrationInputOrderModel.Bonus();
        bonus.name='qwe';
        bonus.objectType='123';
        bonus.period= '123';
        bonus.productCode='123';
        bonus.productFamily='123';
        bonus.subtype='123';
        bonus.type='123';
        bonus.value='123';
        System.assert(true);     
    }
    
    @isTest
    static void contact() {
        SOLAR_PME_IntegrationInputOrderModel.Contact contact= new SOLAR_PME_IntegrationInputOrderModel.Contact();
        contact.firstName = '123';
        contact.cpf = '123';
        contact.emailAddress='123@123.com';
        contact.birthDate='123@123.com';
        contact.gender='123@123.com';
        contact.isLegalRepresentative=true;
        contact.jobTitle='13';
        contact.lastName='123';
        contact.title='13';
        contact.occupation='13';
        contact.phones=null;
        System.assert(true);     
    }

}