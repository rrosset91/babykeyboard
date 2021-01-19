@isTest
public class CEC_MemberMethodsTest { 
    
    @isTest static void testDeleteMember(){  
        
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('test Empresa');
        insert empresa;
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('testHierarquia', empresa.id);
        insert hierarquiaPai;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('test', empresa.id);
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        insert hierarquia;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquia.id); 
        insert mbr;
        
        test.startTest();       
        delete mbr; 
        test.stopTest();
        
    }
    
    @isTest static void testInsertMember(){  
        
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('test');
        insert empresa;
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('testHierarquia', empresa.id);
        insert hierarquiaPai;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('test', empresa.id);
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        insert hierarquia;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquia.id); 
        
        test.startTest();       
        insert mbr; 
        test.stopTest();
        
    }
    
    
}