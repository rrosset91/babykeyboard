@isTest
public class CEC_HierarchyMethodsTest { 
    @isTest static void testDeletetHierarchy(){  
        
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa;       
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('Test Hierarquia Pai', empresa.id);
        insert hierarquiaPai;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('Test Hierarquia', empresa.id);
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquiaPai.id); 
        insert mbr;
        
        insert hierarquia;
        
        test.startTest();       
        Delete hierarquia;
        test.stopTest();       
        
    }
    
    @isTest static void testInsertHierarchy(){  
        
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
       
        Company__c empresa = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa;       
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('Test Hierarquia Pai', empresa.id);
       
        insert hierarquiaPai;
                
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('Test Hierarquia', empresa.id);
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquiaPai.id); 
        insert mbr;
               
        test.startTest();       
        insert hierarquia;
        test.stopTest();       
        
    }
    
    @isTest static void testUpdateHierarchy(){  
        
        User usuario =  CEC_ObjectFactory.getUser();  
        insert usuario;
        
        Company__c empresa = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa;
        
        Company__c empresa2 = CEC_ObjectFactory.getCompany('Test Empresa');
        insert empresa2;
        
        Hierarchy__c hierarquia = CEC_ObjectFactory.getHierarchy('Test Hierarquia', empresa.id);
        insert hierarquia;
        
        Hierarchy__c hierarquiaPai = CEC_ObjectFactory.getHierarchy('Test Hierarquia Pai', empresa.id);
        insert hierarquiaPai;               
        
        Member__c mbr = CEC_ObjectFactory.getMember(usuario.id, empresa.id, hierarquiaPai.id); 
        insert mbr;
        
        hierarquia.Company__c = empresa2.id;
        hierarquia.ParentHierarchy__c = hierarquiaPai.id;
        
        test.startTest();       
        update hierarquia;
        test.stopTest();
        
    }  
    
}