/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Classe de teste da CEC_360_ShowCasesController
* 
*
* ---------------------------------------------------------------
*/
@isTest
public class CEC_360_ShowCasesControllerTest
{
    static Id recordTypeCostumerAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
    static Id recordTypeContractAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); 
    static Id recordTypeAssetCECMovel = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId(); 
    static Id recordTypeCostumerGOVCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    
    @testSetup
    static void makeData()
    {
    	User userCriticalChannels = CEC_UserDataFactory.createUserWithProfileCriticalChannels();
        
        Account costumer = CEC_AccountDataFactory.createCostumer(recordTypeCostumerAccount);
        insert costumer;
        
        Account contractBusinessUnit = CEC_AccountDataFactory.createContractWithBusinessUnit(costumer.id ,recordTypeContractAccount);
        insert contractBusinessUnit;
        
        Asset assetMobile = CEC_AssetDataFactory.createAssetMobile(costumer.id, contractBusinessUnit.id, recordTypeAssetCECMovel);
        insert assetMobile; 
    }
    
    @isTest
    static void getAssetsByBillingAccountTest()
    {
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contractBusinessUnit = [SELECT id FROM Account WHERE BusinessUnit__c = 'Claro' AND parentId = : costumer.id]; 
        Asset assetMobile = [SELECT id, vlocity_cmt__BillingAccountId__r.BusinessUnit__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c =: contractBusinessUnit.id];        
        
        Test.startTest();
        	CEC_360_ShowCasesController.getAssetsByBillingAccount(contractBusinessUnit.Id);
        Test.stopTest(); 
        
        system.assertEquals(!'Net'.equalsIgnoreCase(assetMobile.vlocity_cmt__BillingAccountId__r.BusinessUnit__c), true);
    }
    
    @isTest
    static void getDatesTest()
    { 
        CEC_360_ShowCasesController.DateInfo testDateInfo = new CEC_360_ShowCasesController.DateInfo();
        Date today = System.today();
        
        testDateInfo.endDate = today; 
        testDateInfo.startDate = today.addMonths(-6);
        testDateInfo.minDate = testDateInfo.startDate;
        testDateInfo.maxDate = testDateInfo.endDate;
        
        Test.startTest();            
             testDateInfo = CEC_360_ShowCasesController.getDates();
        Test.stopTest();
        
        system.assertEquals(testDateInfo != null , true);
    }
    
    @isTest
    static void getDataRecordTestAsset()
    {
        string objectAPI = 'Asset';  
        
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id FROM Account WHERE BusinessUnit__c = 'Claro' AND parentId =: costumer.id];
        Asset assetMobile = [SELECT id FROM Asset WHERE MSISDN__c = '11954434501' AND vlocity_cmt__BillingAccountId__c =: contract.id]; 
        
        Test.startTest();            
           CEC_360_ShowCasesController.ResultWrapper  testResultWrapper = CEC_360_ShowCasesController.getDataRecord(assetMobile.id, objectAPI);
        Test.stopTest();
        
        system.assertEquals(testResultWrapper != null && 'Asset'.equalsIgnoreCase(objectAPI) , true);
    }
    
    @isTest
    static void getDataRecordTestAccount()
    {
        string objectAPI = 'Account';        
        
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id FROM Account WHERE BusinessUnit__c = 'Claro' AND parentId =: costumer.id];
        Asset assetMobile = [SELECT id FROM Asset WHERE MSISDN__c = '11954434501' AND vlocity_cmt__BillingAccountId__c =: contract.id];   
        
        Test.startTest();            
           CEC_360_ShowCasesController.ResultWrapper  testResultWrapper = CEC_360_ShowCasesController.getDataRecord(contract.id, objectAPI);
        Test.stopTest();
        
        system.assertEquals(testResultWrapper != null && 'Account'.equalsIgnoreCase(objectAPI) , true);
    }
    
    @isTest
    static void getPicklistValueByLabelTest()
    {
        String varObject = 'Case';
        String varField = 'Status';
        
        Test.startTest();
            map<String, String>  testPickListValue = CEC_360_ShowCasesController.getPicklistValueByLabel(varObject, varField);
        Test.stopTest();
        
        system.assertEquals(String.isNotEmpty(varObject) && String.isNotEmpty(varField) , true);
    }

    @isTest
    static void getCasesContractTest()
    {        
        List<CEC_360_ShowCasesController.TreeCases> casesWithContract = new List<CEC_360_ShowCasesController.TreeCases>();        
        DateTime startDate = system.now();
        DateTime endDate = Datetime.now().addDays(+45);
        
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id FROM Account WHERE BusinessUnit__c = 'Claro' AND parentId =: costumer.id ];
        
        Case costumerGOVCaseContract = new Case(); 
        List<Case> casesInsertWithContract = new List<case>();
        integer numberOfCasesWithContract = 30;
        
        for(integer i = 0; i < numberOfCasesWithContract; i++)
        {
            costumerGOVCaseContract = CEC_CaseDataFactory.createCaseCostumerGOVContract(costumer.id, contract.id, recordTypeCostumerGOVCase);
            casesInsertWithContract.add(costumerGOVCaseContract); 
        }
        
        insert costumerGOVCaseContract;
        
        Test.startTest();
             casesWithContract = CEC_360_ShowCasesController.getCasesContract(contract.id, string.valueof(startDate), string.valueof(endDate), costumerGOVCaseContract.Status);
        Test.stopTest();
        
        system.assertEquals(casesWithContract.size() > 0, true);
    }
    
    @isTest
    static void getCasesAssetTest()
    {
        List<CEC_360_ShowCasesController.TreeCases> casesWithAsset = new List<CEC_360_ShowCasesController.TreeCases>();       
        DateTime startDate = system.now();
        DateTime endDate = Datetime.now().addDays(+45);
        
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id FROM Account WHERE BusinessUnit__c = 'Claro' AND parentId =: costumer.id];
        Asset assetMobile = [SELECT id FROM Asset WHERE MSISDN__c = '11954434501' AND vlocity_cmt__BillingAccountId__c =: contract.id]; 
        
        Case costumerGOVCaseAsset = new Case(); 
        List<Case> casesInsertWithAsset = new List<case>();
        integer numberOfCasesWithAsset = 30;
        
        for(integer i = 0; i < numberOfCasesWithAsset; i++)
        {
            costumerGOVCaseAsset = CEC_CaseDataFactory.createCaseCostumerGOVAsset(costumer.id, assetMobile.id, recordTypeCostumerGOVCase);
            casesInsertWithAsset.add(costumerGOVCaseAsset); 
        }
        
        insert costumerGOVCaseAsset;    
	    
        Test.startTest();
             casesWithAsset = CEC_360_ShowCasesController.getCasesAsset(assetMobile.id, string.valueof(startDate), string.valueof(endDate), costumerGOVCaseAsset.Status);
        Test.stopTest();
        
        system.assertEquals(casesWithAsset.size() > 0, true);
    }
    
    @isTest
    static void validateDateIntervalSixMonthsTest()
    {
        DateTime startDate = DateTime.newInstance(2019, 2, 31);
        DateTime endDate = DateTime.newInstance(2020, 1, 31); 
        DateTime startDatewithSix = startDate.addMonths(6);
        
        Test.startTest();
            try
            {               
        		CEC_360_ShowCasesController.validateDate(startDate, endDate);                
            }
           catch(Exception e)
           {
               System.assertEquals(e.getMessage().equals('O período máximo permitido para consulta é de 6 meses'), true);  
           }
        Test.stopTest();
    }
    
    @isTest
    static void validateDateInvalidStartDateTest()
    {
        DateTime startDate = DateTime.newInstance(2021, 1, 31);
        DateTime endDate = DateTime.newInstance(2020, 1, 31); 
        
        Test.startTest();
            try
            {        
                CEC_360_ShowCasesController.validateDate(startDate, endDate);    
            }
        	catch(Exception e)
            {
                System.assertEquals(e.getMessage().equals('Data início não pode ser maior que a data fim'), true);  
            }
        Test.stopTest();
               
        system.assertEquals(startDate > endDate, true);       
    }
    
    @isTest
    static void getCriticalChannelsTest()
    {        
        Boolean testGetCriticalChannels;
        User userCriticalChannels = [SELECT id FROM User WHERE Email = 'doijejdjeoj23@0.teste.com.br']; 
        
        Test.startTest();
            System.runAs(userCriticalChannels)
            {
               testGetCriticalChannels = CEC_360_ShowCasesController.getCriticalChannels();
            }
        Test.stopTest();
        
        system.assertEquals(testGetCriticalChannels, true);
    }
}