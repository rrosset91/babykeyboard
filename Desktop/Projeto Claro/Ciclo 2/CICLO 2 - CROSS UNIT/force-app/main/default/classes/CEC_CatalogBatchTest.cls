@isTest
public class CEC_CatalogBatchTest {   
    static testMethod void batchDelete(){
        Test.startTest();
        
        Bonus__c bonusBatch = new Bonus__c(
            Name = 'BatchTestName', 
            Chave__c = 'BatchTestChave',
        	Start_Date__c = date.today(),
        	End_Date__c = date.today());
    	insert bonusBatch;
        
        CEC_CatalogBatch d = new CEC_CatalogBatch('select id from Bonus__c', null, null, null, null, 'delete');
    	Database.executeBatch(d, 2000);
        Test.stopTest();
        
        List<Bonus__c> result = [select id from Bonus__c];
        System.assert(result.size() == 0, 'delete unsuccessfully');
    }
    
    static testMethod void batchUpdate(){
        Test.startTest();
        
        Bonus__c bonusBatch = new Bonus__c(
            Name = 'BatchTestName', 
            Chave__c = 'BatchTestChave',
        	Start_Date__c = date.today(),
        	End_Date__c = date.today());
    	insert bonusBatch;
        
        CEC_CatalogBatch u = new CEC_CatalogBatch('select id, Chave__c from Bonus__c', 'Bonus__c', 'Chave__c', 'Test', null, 'update');
    	Database.executeBatch(u, 2000);
        Test.stopTest();
        
        Bonus__c result = [select id, Chave__c from Bonus__c where id =: bonusBatch.id];
        System.assert(result.Chave__c == 'Test', 'update unsuccessfully');
    }
    
    static testMethod void batchUpdateCreateKey(){
        
        Bonus__c bonusBatch = new Bonus__c(
            Name = 'BatchTestName', 
            Chave__c = null,
        	Start_Date__c = date.today(),
        	End_Date__c = date.today());
    	insert bonusBatch;
        
        bonusBatch.Chave__c = null;
        update bonusBatch;
        
        Test.startTest();
        CEC_CatalogBatch uck = new CEC_CatalogBatch('select id, Chave__c from Bonus__c where Chave__c = null', 'Bonus__c', 'Chave__c', null, null, 'updateCreateKey');
        Database.executeBatch(uck, 2000);
        Test.stopTest();
        
        Bonus__c result = [select id, Chave__c from Bonus__c where id =: bonusBatch.id];
        System.assert(result.Chave__c != null, 'updateCreateKey unsuccessfully');
    }
    
    static testMethod void bathcUpdateReplace(){
        Bonus__c bonusBatch = new Bonus__c(
            Name = 'BatchTestName', 
            Chave__c = 'ChaveTestCEC',
        	Start_Date__c = date.today(),
        	End_Date__c = date.today());
    	insert bonusBatch;
        
        Test.startTest();
        CEC_CatalogBatch uck = new CEC_CatalogBatch('select id, Chave__c from Bonus__c where chave__c = \'ChaveTestCEC\'', 'Bonus__c', 'Chave__c', 'CEC', 'Solar', 'updateReplace');
        Database.executeBatch(uck, 2000);        
        Test.stopTest();
        
        System.debug(bonusBatch.Chave__c);
        Bonus__c result = [select id, Chave__c from Bonus__c where id =: bonusBatch.id];
        System.assert(result.Chave__c != null, 'updateReplace unsuccessfully');
    }
}