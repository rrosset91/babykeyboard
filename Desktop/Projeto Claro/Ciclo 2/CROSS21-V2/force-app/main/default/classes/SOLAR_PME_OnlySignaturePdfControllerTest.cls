@isTest
public class SOLAR_PME_OnlySignaturePdfControllerTest {

    @testSetup
    public static void testSetup() {
        CEC_PME_OrderTestMethods.generateAllData();
        Order order = [SELECT Id, AccountId FROM Order];
        
        Contact newContact = new Contact();
        newContact.FirstName = 'test';
        newContact.LastName = 'test';
        newContact.AccountId = order.AccountId;
        insert newContact;
        
        AccountContactRelation accountContactRelation = [SELECT Id,
                                                         ResponsibleForTheSignature__c
                                                         FROM AccountContactRelation 
                                                         WHERE AccountId = :order.AccountId 
                                                         AND ContactId = :newContact.Id];
        accountContactRelation.ResponsibleForTheSignature__c = true;
        update accountContactRelation;
        
        order.Related_Contacts__c = accountContactRelation.Id + ';';
        update order;
    }
    
    @isTest
    public static void mainTest() {
        System.currentPageReference().getParameters().put('id', [SELECT Id FROM Order LIMIT 1].Id);
        SOLAR_PME_OnlySignaturePdfController controller = new SOLAR_PME_OnlySignaturePdfController();
        SOLAR_PME_OnlySignaturePdfController.SigniturePdfModel model = controller.signiturePdfModel;
    }
    
}