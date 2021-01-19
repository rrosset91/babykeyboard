@isTest
private class CEC_SkillsBasedRoutingTest {
    
    @isTest public static void routeUsingSkillsTest() {
       
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        Contact lContact = CEC_SobjectFactory.getContact();
        insert lContact;
        
        Case lCase = CEC_SobjectFactory.getCase(lContact);
        insert lCase;
        
        test.startTest();
        	Database.SaveResult lSavRes = database.update(lCase);
        test.stopTest();
        system.assert(lSavRes.isSuccess());
    }
    
}