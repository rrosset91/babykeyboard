@isTest
public class CEC_OrderMethodsTest 
{
    @isTest static void test_sharingRecord() 
    {
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('test');
        insert empresa;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('test', empresa.id);
        hierarquia.TerritoryCode__c = '001_GESTOR';
        insert hierarquia;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquia.id);
        mbr.Hierarchy__c = hierarquia.Id;
        mbr.User__c = usuario.Id;
        insert mbr;
        
        Account acc = new Account();
        acc.name = 'Name acc';
        insert acc;
        
        /*Group grupo = new Group();
		grupo.DeveloperName = hierarquia.Id;
        grupo.Name = '001_GESTOR';
        insert grupo;*/
        
        Order ord = new Order();
        ord.name = 'Name Order';
        ord.OwnerId = usuario.Id;
        ord.accountid = acc.id;
        ord.EffectiveDate = Date.today();
        ord.Status = 'Em andamento';
        
        Test.startTest();
        insert ord; 
        Test.stopTest();
        
    } 
    
    
}