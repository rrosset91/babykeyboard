global without sharing class CEC_ObjectFactory {
	
	
	  global class ResponseInactiveUser
    {
        global String apiVersion;
        global String transactionId;
        //global String data;
        global Data data;
        //global list<ResponseUser> user;
    }
    
    global class Data
    {
    	global list<ResponseUser> user;
    }
    global class ResponseUser
    {
        global String CompanyName;
        global String Email;
        global String FirstName;
        global String LastName;
        global String ProfileId;
        global String UserName;
        global String documentNumberCPF;
        global String federationId;
        global String log;
    }
    
    global class ResponseTotalLicenses
    {
        global Integer TotalLicenses;
        global Integer UsedLicenses;
    } 
	
    public static User getUser (){
        
        list<Profile> lLstProf = [SELECT Id FROM Profile WHERE PermissionsAuthorApex = true limit 1];
        system.assert(!lLstProf.isEmpty(), 'Erro perfil');
        Id profileTest = lLstProf[0].Id;
        
        user usuario1 = new user(firstName = 'test', lastName = 'test1', Alias = 'alias', Email = 'teste@claro.com.br',
                                 Username = 'teste@claro.com.br', Profileid = profileTest, LanguageLocaleKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1',
                                 LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        usuario1.CommunityNickname = usuario1.lastName;
        return usuario1;
    }
    
    public static Company__c getCompany(String name){
        
        Company__c Company = new Company__c(Name = name);
        return Company;
    }
    
    public static Hierarchy__c getHierarchy(String name, id companyId ){
        
        Hierarchy__c hierarchy = new Hierarchy__c(Name = name, Company__c = companyId);
        return hierarchy;
    }
    
    public static Member__c getMember(Id userId, Id companyId, Id hierarchyId) {
        
        Member__c mbr = new Member__c( 
        	
            User__c = userId, 
            Company__c = companyId, 
            Hierarchy__c = hierarchyId,
            HierarchySource__c = 'text',
            IdExterno__c = '0001'
        );
        
        return mbr;
    }
    
}