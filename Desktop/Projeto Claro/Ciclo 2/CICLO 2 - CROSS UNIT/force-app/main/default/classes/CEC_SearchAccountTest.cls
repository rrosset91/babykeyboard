/* Autor: Letícia Freitas - Deloitte 
Criação: 22/03/2019
Descrição: Classe de Teste para a classe CEC_SearchAccount.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360

* Controle de Versão
* ---------------------------------------------------------------
* Data: 06/05/2019  
* Autor: Danilo Fucuhara
* Alterações: Métodos refatorados.
* ---------------------------------------------------------------
* Data: 26/07/2019
* Autor: Letícia Freitas.
* Aletrações: Refatoração de métodos.
*-----------------------------------------------------------------
* Data: 03/09/2019.
* Autor: Letícia Freitas.
* Alterações : NBO/NBA.
*-----------------------------------------------------------------
* Data: 03/09/2019.
* Autor: Lucas Sodré.
* Alterações : Inclusão de novos metodos testes: getDocument
*-----------------------------------------------------------------*/

@isTest
public class CEC_SearchAccountTest {
    
    
    static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    static Id recTypeBusinessAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    static Id recTypeConsumerAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId(); 
    
    @isTest static void testListDescribe(){
        List<String> options = CEC_SearchAccount.getDocumentType();
         
    }
    
    
    @isTest static void testGetProfileNBONBA(){
        Boolean test = CEC_SearchAccount.getProfileNBONBA();
    }
    
    @isTest static void testgetProfileCanaisCriticos(){
        Boolean test = CEC_SearchAccount.getProfileCanaisCriticos();
    }
    
     
    @isTest static void testgetProfileComercialUsers(){
        Boolean test = CEC_SearchAccount.getProfileComercialUsers();
    }
    @isTest static void getValidKeyDocumentCPF (){
        Account a = new Account ();
        a.name = 'Test Account';
        a.DocumentType__c = 'CPF';
        a.DocumentNumber__c = '334.609.708-04';
        a.RecordTypeId = recTypeConsumerAccount;
        insert a;
        
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
        mapTest = CEC_SearchAccount.getvalidKeyDocument('334.609.708-04','CPF');
        Test.stopTest();
    }
    
     @isTest static void getInvalidKeyDocumentCPF (){
        Account a = new Account ();
        a.name = 'Test Account';
        a.DocumentType__c = 'CPF';
        a.DocumentNumber__c = '334.609.708-0411';
        a.RecordTypeId = recTypeConsumerAccount;
        insert a;
        
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
        mapTest = CEC_SearchAccount.getvalidKeyDocument('334.609.708-04','CPF');
        Test.stopTest();
    }
    
     @isTest static void getValidKeyDocumentRne (){
        Account a = new Account ();
        a.name = 'Test Account';
        a.DocumentType__c = 'RNE';
        a.DocumentNumber__c = '1234568976';
        a.RecordTypeId = recTypeConsumerAccount;
        insert a;
        
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
        mapTest = CEC_SearchAccount.getvalidKeyDocument('1234568976','RNE');
        Test.stopTest();
    }
    
     @isTest static void getValidKeyDocumentCNPJ (){
        Account a = new Account ();
        a.name = 'Test Account';
        a.DocumentType__c = 'CNPJ';
        a.DocumentNumber__c = '39.683.359/0001-46';
        a.RecordTypeId = recTypeBusinessAccount;
        insert a;
        
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
        mapTest = CEC_SearchAccount.getvalidKeyDocument('39.683.359/0001-46','CNPJ');
        Test.stopTest();
    }
    
      @isTest static void getInvalidKeyDocumentCNPJ (){
        Account a = new Account ();
        a.name = 'Test Account';
        a.DocumentType__c = 'CPF';
        a.DocumentNumber__c = '123.617.124-42';
        a.RecordTypeId = recTypeConsumerAccount;
        insert a;
        
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
          try{
                mapTest = CEC_SearchAccount.getvalidKeyDocument('11.111.111/0001-11','CNPJ');
          }catch(Exception e){
             System.Assert(e.getMessage().contains('Documento Inválido'));    
          }
          Test.stopTest();
    }
    
    @isTest static void getInvalidNumberDocument(){
        map<String, Object> mapTest  = new map<String, Object>();
        Test.startTest();
          try{
                mapTest = CEC_SearchAccount.getvalidKeyDocument('111111111','CNPJ');
          }catch(Exception e){
             System.Assert(e.getMessage().contains('Documento Inválido'));    
          }
          Test.stopTest();
    }
    
    
     @isTest static void getByAdress(){
         vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c();
         prem.vlocity_cmt__PostalCode__c = '13480-120'; 
         prem.vlocity_cmt__StreetAddress__c = 'Rua Manuel Correia';
         prem.number__c = '230';
         prem.vlocity_cmt__City__c = 'São Paulo';
         prem.vlocity_cmt__State__c = 'SP';
         insert prem;
          
          Account a = new Account ();
          a.name = 'Test Account';
          a.RecordTypeId = recTypeConsumerAccount;
          a.vlocity_cmt__PremisesId__c = prem.id;
          insert a; 
        
         test.startTest();
         CEC_SearchAccount.getByAddress('13480-120','Rua Manuel Correia','230', null, 'São Paulo','SP');
         test.stopTest();
        
    }
    
    @isTest static void getPermissionComTest(){
        Test.startTest();
        CEC_SearchAccount.getPermissionCom();
        Test.stopTest(); 
    }
    
    @isTest static void getCityByCarrierCodeTest(){
        Test.startTest();
        CEC_SearchAccount.getCityByCarrierCode('323');
        Test.stopTest(); 
    }
    
    @isTest static void getAccountNameTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        acc.DocumentNumber__c = '428.617.028.42';
        insert acc;
        Test.startTest();
        CEC_SearchAccount.getAccountName(acc.Name);
        System.assertEquals(acc.Name, 'Teste');
        Test.stopTest(); 
    }
        
     @isTest static void testGetContractMovel(){
        Account acc = new Account();
         acc.Name = 'Teste';
         acc.ContractReferenceNumber__c = '123457908';
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
         insert acc;
         Test.startTest();
         List<Object> lstAcc = CEC_searchAccount.getContract('123457908',null);
         Test.stopTest();
    } 

    @isTest static void testGetContractResidencial(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.ContractReferenceNumber__c = '123457908';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert acc;
         Test.startTest();
        List<Object> lstAcc = CEC_searchAccount.getContract('12345790','523');
         Test.stopTest();
    }     
          
    @isTest static void testGetContractId(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert acc;
        Contract ctc = new Contract();
        ctc.name = 'teste1';
        ctc.AccountId = acc.id;
        ctc.vlocity_cmt__ContractReferenceNumber__c = '1234567';
        insert ctc;
        Id testId = CEC_searchAccount.getContractId('1234567');
    }
    
    @isTest static void testGetContractNBONBA(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert acc;
        Contract ctc = new Contract();
        ctc.name = 'teste1';
        ctc.AccountId = acc.id;
        ctc.vlocity_cmt__ContractReferenceNumber__c= '1234567';
        List<CEC_SearchAccount.SearchAccount> Conta = CEC_searchAccount.getContractNBONBA(ctc.vlocity_cmt__ContractReferenceNumber__c, '12');
    }
    
      @isTest static void testGetContractNBONBAMovel(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert acc;
        Contract ctc = new Contract();
        ctc.name = 'teste1';
        ctc.AccountId = acc.id;
        ctc.vlocity_cmt__ContractReferenceNumber__c= '1234567';
        List<CEC_SearchAccount.SearchAccount> Conta = CEC_searchAccount.getContractNBONBA(ctc.vlocity_cmt__ContractReferenceNumber__c, null);
    }
    
      @isTest static void testGetMsisdn(){
          Account acc = new Account();
          acc.Name = 'Teste';
          insert acc;
          Asset ast = new Asset();
          ast.name ='ativo';
          ast.msisdn__c = '11 981234-5577';
          ast.AccountId = acc.Id;
          insert ast;
          List<CEC_SearchAccount.SearchAccount> Conta = CEC_searchAccount.getMSISDN('11 981234-5577');
          
    }
    
    @isTest static void testGetContract(){
       
        Account acc = new Account();
        acc.name = 'teste';
        insert acc;
        Contract ct = new Contract();
        ct.vlocity_cmt__ContractReferenceNumber__c= '1234567';
        ct.AccountId = acc.Id;
        insert ct;
        
        List<String> lstString = CEC_SearchAccount.getContractNumber(acc.Id);
    }
    
      @isTest static void testGetContractList(){
       
        Account acc = new Account();
        acc.name = 'teste';
        insert acc;
        Contract ct = new Contract();
        ct.vlocity_cmt__ContractReferenceNumber__c= '1234567';
        ct.AccountId = acc.Id;
        insert ct;
        
        List<Contract> lstObj = CEC_SearchAccount.getContractList(acc.Id);
    }
    
    @isTest static void getDocument(){
        string doc = '029382982-00';
        string type = 'RNE';
        List<CEC_SearchAccount.searchAccount> documents = CEC_SearchAccount.getDocument(doc, type);
        
    }
    
    @isTest static void getCityByName(){
        CEC_SearchAccount.getCityByName('Rio de Janeiro');
    }
    
    @isTest static void getParametersByOmniscriptName(){
        CEC_SearchAccount.getParametersByOmniscriptName('Test script');
    }

}