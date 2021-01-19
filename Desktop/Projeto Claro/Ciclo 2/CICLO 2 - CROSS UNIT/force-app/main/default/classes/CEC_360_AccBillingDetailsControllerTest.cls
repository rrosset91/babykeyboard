@isTest
public class CEC_360_AccBillingDetailsControllerTest {

static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();    
static Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();

    static testMethod void getBillingAccoun  (){	
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        
        
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.getBillingAccount(acc.Id);
        Test.stopTest();

    }
  @isTest  
    static void fillContracts  (){	
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract contract = new Contract(Name = 'Con', 
                                         AccountId = acc.Id);
        insert contract;
        
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.fillContracts(contract.Id);
        Test.stopTest();

    }
    
    static testMethod void getDetails  (){	
        Account acc = new Account(Name = 'Acc', ContractReferenceNumber__c ='12345678',
                                  CityCode__c='123', 
                                  BusinessUnit__c = 'NET');
        insert acc;
        
        
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.getDetails('123/12345678');
        Test.stopTest();

    }
    
    static testMethod void getBUnit  (){	
        Account acc = new Account(Name = 'Acc', ContractReferenceNumber__c ='12345678',
                                  CityCode__c='123', 
                                  BusinessUnit__c = 'NET');
        insert acc;
        
        
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.getBUnit('123/12345678');
        Test.stopTest();

    }
    
    static testMethod void getContractNumberBillingAccount  (){	
        Account acc = new Account(Name = 'Acc', ContractReferenceNumber__c ='12345678',
                                  CityCode__c='123', 
                                  BusinessUnit__c = 'NET');
        insert acc;
        
        
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.getContractNumberBillingAccount('123/12345678');
        Test.stopTest();

    }
    
    static testMethod void getObjectDataBillingAcc(){
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'CLARO',
                                  ContractReferenceNumber__c = '34933869',
                                  CityCode__c = '003');
        insert acc;

        Test.startTest();
        CEC_360_AccBillingDetailsController.getObjectDataBillingAcc('34933869', '2017-01-01', '2017-06-01');
        Test.stopTest();
    }
    
    static testMethod void getUrlPdfBillingAccTest1() {
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'CLARO',
                                  ContractReferenceNumber__c = '349338695',
                                  CityCode__c = '003');
        insert acc;

        Test.startTest();
        CEC_360_AccBillingDetailsController.getUrlPdfBillingAcc('2020-01-01','1235678');
        Test.stopTest();
    }
    
    static testMethod void getUrlPdfBillingAccTest2() {
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'NET',
                                  ContractReferenceNumber__c = '349338695',
                                  CityCode__c = '003');
        insert acc;
        
        Test.startTest();
        CEC_360_AccBillingDetailsController.getUrlPdfBillingAccRes(acc.Id,'003/349338695');
        Test.stopTest();
    }
    
   
    @IsTest
    static void getContractDataTest(){
        String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        
        Account acc = new Account(
                Name = 'Acc',
                BusinessUnit__c = 'NET',
                ContractReferenceNumber__c = '349338695',
                CityCode__c = '003');
        insert acc;
        Case caso = new Case(
            RecordTypeId = CEC_CC_Ouvidoria,
            AccountId = acc.id,
            ContractBillingAccount__c = acc.id,
            Status = 'New',
            SubStatus__c = 'Não Iniciado',
            ContactPreference__c = 'Whatsapp',
            Channel__c = 'Ouvidoria',
            InputType__c = 'Telefone',
            BusinessUnit__c = 'Claro DTH',
            Description = 'Testando Casos 2'
        );
        insert caso;

        Test.startTest();
            CEC_360_AccBillingDetailsController.SolarCaseResponseWrapper response = CEC_360_AccBillingDetailsController.SolarCaseResponseWrapper.getContractData(caso.Id);
            System.assertEquals(response.contractNumber, '003/349338695');
        Test.stopTest();
        
    }
  

}