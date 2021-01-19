@isTest
public class CEC_360_ShowProductsControllerTest { 

static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();    
static Id recordTypeAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();
@isTest    
    public static void getgetBillingAccountTest  (){
        
        vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c(Name='Teste', 
                                                                    vlocity_cmt__StreetAddress__c = 'Rua das flores',
                                                                    Complement__c = 'Apto 46',
                                                                    Number__c = '125');
        insert prem;
       
        Account acc = new Account(Name = 'AccPrincipal',vlocity_cmt__PremisesId__c=prem.id);
        insert acc;
        Account accSub = new Account(Name = 'AccSub', ParentId=acc.Id);
        insert accSub;
        
        
        
        
        Test.startTest();
        CEC_360_ShowProductsController.getBillingAccount(acc.Id);
        Test.stopTest();

    }
    
@isTest
    public static void getSubAssetsResTest(){
       Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id, SpotId__c='123456',Status='Ativo');
        Asset ass2 = new Asset(Name = 'Ass', AccountId = acc.Id, SpotId__c='123456',Status='Ativo');
        insert ass;  
        
        Test.startTest();
        CEC_360_ShowProductsController.getSubAssetsRes(acc.Id,'123456');
        Test.stopTest();
        
    }
    @isTest
    public static void getAssetsTest  (){
        
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id,RecordTypeId =recordTypeAsset);
        Asset ass2 = new Asset(Name = 'Ass', AccountId = acc.Id,RecordTypeId =recordTypeAsset,Status='Ativo',
                               vlocity_cmt__BillingAccountId__c=acc.Id);
        insert ass;
        insert ass2;
        
        Test.startTest();
        CEC_360_ShowProductsController.getAssets(acc.Id, new List<String>{'CECMovelPreControle'});
        Test.stopTest();
    }
    
    @isTest
    public static void getSubAssetsMovTest  (){
        
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id,msisdn__c='1199999999');
        Asset ass2 = new Asset(Name = 'Ass', AccountId = acc.Id,msisdn__c='1199999999',ServiceType__c='Assinante',
                               SpotType__c='ADICIONAL');
        insert ass;
        
        Test.startTest();
        CEC_360_ShowProductsController.getSubAssetsMov('1199999999');
        Test.stopTest();
    }
    @isTest
    public static void getPreAssetsTest(){
          Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id, RecordTypeId = recordTypeAsset);
        insert ass;  
        
         Test.startTest();
        CEC_360_ShowProductsController.getPreAssets(acc.Id,'CECMovelPreControle');
        Test.stopTest();
        
    }
    
    @isTest
    public static void getCaAssetsTest(){
          Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Account accBilling = new Account(Name='AccBill',ContractReferenceNumber__c='123456798');
        insert accBilling;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id,vlocity_cmt__BillingAccountId__c = accBilling.Id,
                             Status = 'Cancelado');
        insert ass;  
         string datahoje =String.valueOf(Date.today()); 
         Test.startTest();
        CEC_360_ShowProductsController.getCaAssets(acc.Id,'2019-01-01','2019-12-31',datahoje,'123456798');
        Test.stopTest();
        
    }
    
     @isTest
    public static void getCaAssetsTest2(){
          Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Account accBilling = new Account(Name='AccBill',ContractReferenceNumber__c='123456798',BusinessUnit__c = 'Claro');
        insert accBilling;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id,vlocity_cmt__BillingAccountId__c = accBilling.Id,
                             Status = 'Cancelado');
        insert ass;  
        string datahoje =String.valueOf(Date.today()); 
         Test.startTest();
        CEC_360_ShowProductsController.getCaAssets(acc.Id,'2019-01-01','2019-12-31',datahoje,'123456798');
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void fillContractsTest(){
          Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Account accBilling = new Account(ParentId=acc.id,
                                         Name='AccBill',ContractReferenceNumber__c='123456798',
                                         BusinessUnit__c = 'Claro',
                                        RecordTypeId=recTypeBillingAccount);
        insert accBilling;
        
          
        
         Test.startTest();
        CEC_360_ShowProductsController.fillContracts(acc.Id);
        Test.stopTest();
        
    }
   
    
    
}