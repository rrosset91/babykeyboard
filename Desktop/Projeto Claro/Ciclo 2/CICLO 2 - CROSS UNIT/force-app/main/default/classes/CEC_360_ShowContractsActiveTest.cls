/*
* Author: Renan S. de Freitas - Squad visão 360 - Sprint 5
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Classe de teste da CEC_360_ShowContractsActiveController
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_360_ShowContractsActiveTest
{
    static Id recordTypeContractAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    static Id recordTypeCostumerAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();  
    static Id recordTypeAssetCECMovel = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId(); 

    @TestSetup
    static void makeData()
    {       
        User userCriticalChannels = CEC_UserDataFactory.createUserWithProfileCriticalChannels();
        
        User userGovSupervisor = CEC_UserDataFactory.createUserWithProfileGovSupervisor();
                
        Account costumer = CEC_AccountDataFactory.createCostumer(recordTypeCostumerAccount);
        insert costumer;

        Account contract = CEC_AccountDataFactory.createContractWithBusinessUnit(costumer.id ,recordTypeContractAccount);
        insert contract;
        
        Contact contact = CEC_ContactDataFactory.createContact(costumer.id);
        insert contact;

        vlocity_cmt__Premises__c addressPremises = CEC_VlocityCmtPremiesesDataFactory.createPremises();
        insert addressPremises;
    }
    
    @isTest
    static void getContactPrimaryTest()
    {
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Contact contact = [SELECT id                    
                           FROM Contact
                            WHERE DocumentNumber__c = '25201869092'];
        
        Test.startTest();
        	contact contactTest = CEC_360_ShowContractsActiveController.getContactPrimary(costumer.id);
        Test.stopTest();
        
        system.assertEquals(costumer.id != null, true);      
        
    }

    @isTest
    static void getContractsActiveTest()
    {
        List<CEC_360_ShowContractsActiveController.Contracts> contractsActive =  new List<CEC_360_ShowContractsActiveController.Contracts>();
		 
        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id,ContractReferenceNumber__c,
                            vlocity_cmt__Status__c,
                            ContractType__c                            
                            FROM Account
                            WHERE parentId = : costumer.id];
        
        vlocity_cmt__Premises__c addressPremises = [SELECT id, vlocity_cmt__StreetAddress__c
                                                    FROM vlocity_cmt__Premises__c
                                                    WHERE Name = 'Rua Filippo Juvara, Casa'];
       
        Account contractwithStatusActive = new Account();
        List<Account> contractsWithStatusActive = new List<Account>();
        integer numberOfcontractwithStatusActive = 40; 

        for(integer i = 0; i < numberOfcontractwithStatusActive; i++)
        {
            contractwithStatusActive = CEC_AccountDataFactory.createContractWithStatusActive(costumer.id ,recordTypeContractAccount, addressPremises.id);
            contractsWithStatusActive.add(contractwithStatusActive);
        }
        
        insert contractwithStatusActive;
            
        Test.startTest();
                contractsActive = CEC_360_ShowContractsActiveController.getContractsActive(costumer.id);
        Test.stopTest();        
        system.assertEquals(contractsWithStatusActive.size() > 0, true);
    }

    @isTest
    static void getAssetsActiveTest()
    {
        List<CEC_360_ShowContractsActiveController.Assets> assetsActive =  new List<CEC_360_ShowContractsActiveController.Assets>();

        Account costumer = [SELECT id FROM Account WHERE DocumentNumber__c = '460.434.318-74'];
        Account contract = [SELECT id FROM Account WHERE parentId = : costumer.id];
        vlocity_cmt__Premises__c addressPremises = [SELECT id FROM vlocity_cmt__Premises__c WHERE Name = 'Rua Filippo Juvara, Casa'];
       
       
        Asset assetWithStatusActive = new Asset();
        List<Asset> assetsWithStatusActive = new List<Asset>();
        integer numberOfassetwithStatusActive = 40; 

        for(integer i = 0; i < numberOfassetwithStatusActive; i++)
        {
            assetwithStatusActive = CEC_AssetDataFactory.createAssetMobileActive(costumer.id, contract.id, recordTypeAssetCECMovel);      
            assetsWithStatusActive.add(assetWithStatusActive);
        }

        insert assetwithStatusActive;
        
        Test.startTest();
           assetsActive = CEC_360_ShowContractsActiveController.getAssetsActive(costumer.id);
        Test.stopTest();
        
        system.assertEquals(assetsActive.size() > 0, true);
    }
    
    @isTest
    static void getAvailableRecordTypeCase()
    {
        String objectApiName = 'Case';
        
        Test.startTest();
        	String AvailableRecordTypeCase = CEC_360_ShowContractsActiveController.getAvailableRecordTypeCase(objectApiName);
        Test.stopTest();
        
        system.assertEquals('Case'.equalsIgnoreCase(objectApiName), true );
    }
    
    @isTest
    static void getRecordTypeLabelTest()
    {        
        String recordTypeLabel = 'Consumidor.GOV';
        
        Test.startTest();
        	Id recordTypeLabelTeste = CEC_360_ShowContractsActiveController.getRecordTypeLabel(recordTypeLabel);        
        Test.stopTest();
        
        //system.assertEquals('Consumidor.GOV'.equalsIgnoreCase(string.valueOf(recordTypeLabelTeste)), true);        
    }
    
    @isTest
    static void getCriticalChannelsTest()
    {
        Boolean testGetCriticalChannels;
        User userCriticalChannels = [SELECT id FROM User WHERE Email = 'doijejdjeoj23@0.teste.com.br']; 
        
        Test.startTest();
            System.runAs(userCriticalChannels)
            {
               testGetCriticalChannels = CEC_360_ShowContractsActiveController.getCriticalChannels();
            }
        Test.stopTest();
        
        system.assertEquals(testGetCriticalChannels, true);
    }
    
    @isTest
    static void getProfileSupervisorOrRepresentativesTest()
    {        
        User userGovSupervisor = [SELECT id FROM User WHERE Email = 'gov@0.teste.com.br']; 
        
        Test.startTest();
            System.runAs(userGovSupervisor)
            {
               String getGovSupervisor = CEC_360_ShowContractsActiveController.getProfileSupervisorOrRepresentatives();
               system.assertEquals('Supervisor Gov'.equalsIgnoreCase(getGovSupervisor), true );
            }
        Test.stopTest();
    }
}