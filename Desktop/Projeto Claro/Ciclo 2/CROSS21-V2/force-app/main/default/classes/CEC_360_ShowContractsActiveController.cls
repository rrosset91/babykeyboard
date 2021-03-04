/*
* Author: Renan S. de Freitas - Squad visão 360 - Sprint 5
* Company: Deloitte Brasil 
* Date: 04/02/2020 
* Description: Apex controller para trazer as informações de contrato  e Asset Ativas 
* 
*
* ---------------------------------------------------------------
*/
public with sharing class CEC_360_ShowContractsActiveController
{
    public static Id recTypeContract = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    public static final List<String> RECORD_TYPES_ASSET = new List<String>{'CECMovel','CECMovelControle','CECMovelPreControle'};
    
    @AuraEnabled
    public static Boolean getCriticalChannels()
    {
        return FeatureManagement.checkPermission('Perfil_Canais_Criticos');
    }
    
    @AuraEnabled
    public static Contact getContactPrimary(string parentId)
    {
        List<Contact> contacts =
            [
              SELECT id, 
              DocumentNumber__c
              FROM Contact 
              WHERE AccountId =: parentId
            ];
        
       return (contacts.size() > 0) ?  contacts[0] : null;
    }

    @AuraEnabled
    public static List<Contracts> getContractsActive(string parentId)
    {
        List<Account> contracts =
        [
            SELECT id,            
            ContractNumber__c,
            vlocity_cmt__Status__c,
            InstalledPremises__r.Name,
            InstalledPremises__r.vlocity_cmt__StreetAddress__c,
            ContractType__c,
            (SELECT Id, CaseNumber, CriticalChannelProtocol__c, Subject, Status, SubStatus__c, RecordType.Name FROM Casos__r WHERE IsClosed = false)
            FROM Account
            WHERE ParentId  =: parentId
            AND RecordTypeId =:  recTypeContract
            AND vlocity_cmt__Status__c != 'Cancelado' 
            AND ContractNumber__c != null
            AND BusinessUnit__c = 'Net'
        ];
        
        return (contracts.size() > 0) ? formatWrapperContractsActive(contracts) : null;
    }
    
    @AuraEnabled
    public static List<Assets> getAssetsActive(String accountId)
    {
        List<Asset> assets =
        [
            SELECT id,
            MSISDN__c,
            Status,
            Name,
            (SELECT Id, CaseNumber, CriticalChannelProtocol__c, Subject, Status, SubStatus__c, RecordType.Name FROM Cases__r WHERE IsClosed = false)
            FROM Asset
            WHERE AccountId =: accountId
            AND RecordType.DeveloperName IN: RECORD_TYPES_ASSET
            AND Status != 'Cancelado'           
            AND MSISDN__c != null  
        ];

        return (assets.size() > 0) ? formatWrapperAssetsActive(assets) : null;
    }    

    public static List<Contracts> formatWrapperContractsActive(List<Account> contracts)
    {
        List<Contracts> objectsContracts = new List<Contracts>();

        for(Account contract: contracts)
        {
            List<Cases> openCases = new List<Cases>();
            for(Case currentCase: contract.casos__r){
                Cases objectCase = new Cases();
                objectCase.id = currentCase.Id;
                objectCase.caseNumber = currentCase.CaseNumber;
                objectCase.criticalChannelProtocol = currentCase.CriticalChannelProtocol__c;
                objectCase.subject = currentCase.subject;
                objectCase.status = currentCase.Status;
                objectCase.subStatus = currentCase.SubStatus__c;
                objectCase.recordTypeName = currentCase.RecordType.Name;
                openCases.add(objectCase);
            }

            Contracts objectContract = new Contracts();
            objectContract.id = contract.id;
            objectContract.contractNumber = contract.ContractNumber__c;
            objectContract.status = contract.vlocity_cmt__Status__c;
            objectContract.contractAddress = contract.InstalledPremises__r.vlocity_cmt__StreetAddress__c;
            objectContract.contractType = contract.ContractType__c;      
            objectContract.openCases = openCases;
            objectsContracts.add(objectContract);
        }

        return objectsContracts;
    }

    public static List<Assets> formatWrapperAssetsActive(List<Asset> assets)
    {
        List<Assets> objectAssets = new List<Assets>();

        for(Asset asset: assets)
        {
            List<Cases> openCases = new List<Cases>();
            for(Case currentCase: asset.Cases__r){
                Cases objectCase = new Cases();
                objectCase.id = currentCase.Id;
                objectCase.caseNumber = currentCase.CaseNumber;
                objectCase.criticalChannelProtocol = currentCase.CriticalChannelProtocol__c;
                objectCase.subject = currentCase.subject;
                objectCase.status = currentCase.Status;
                objectCase.subStatus = currentCase.SubStatus__c;
                objectCase.recordTypeName = currentCase.RecordType.Name;
                openCases.add(objectCase);
            }

            Assets objectAsset = new  Assets();
            objectAsset.id = asset.id; 
            objectAsset.msisdn = asset.MSISDN__c ;
            objectAsset.status = asset.Status;
            objectAsset.plan = asset.Name;
            objectAsset.openCases = openCases;
            objectAssets.add(objectAsset);
        }

        return objectAssets;
    }

    @AuraEnabled
    public static string getAvailableRecordTypeCase(string objectApiName)
    {        
        List<RecordTypes> recordTypes = new List<RecordTypes>(); 
        List<RecordType> recordTypesDescription = new List<RecordType>();
        string returnString = '';

        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();       
         
        for(RecordType recDescription : [SELECT id,
                                        Description
                                        FROM RecordType
                                        WHERE SobjectType =: objectApiName])
        {
            recordTypesDescription.add(recDescription);
        }

        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            if(info.isAvailable() &&  info.getName() != 'Master')
            {  
                for(RecordType rList: recordTypesDescription)
                {   
                    if(rList.Id == info.getRecordTypeId())
                    {                      
                        RecordTypes recordType = new RecordTypes();  
                        recordType.recordTypeLabel = info.getName();
                        recordType.recordTypeId = info.getRecordTypeId();
                        recordType.description = rList.Description;
                        recordTypes.add(recordType); 
                    }
                }
            }             
        }

        returnString = JSON.serialize(recordTypes);          
        return returnString;
    }

    @AuraEnabled
    public static Id getRecordTypeLabel(String recordTypeLabel)
    {
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }

    @AuraEnabled
    public static String getProfileSupervisorOrRepresentatives()
    {
        Id profileId = UserInfo.getProfileId();
                
        String profileName =
        [
            SELECT Id,
            Name
            FROM Profile
            WHERE Id=:profileId
        ].Name; 

        return profileName;
    }

    public class Contracts
    {
        @AuraEnabled public String id;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String contractAddress;
        @AuraEnabled public String contractType; 
        @AuraEnabled public List<Cases> openCases = new List<Cases>();
    }

    public class Assets
    {
        @AuraEnabled public String id;
        @AuraEnabled public String msisdn;
        @AuraEnabled public String status;
        @AuraEnabled public String plan;       
        @AuraEnabled public List<Cases> openCases = new List<Cases>(); 
    }
    
    public class RecordTypes
    {
        @AuraEnabled  public string recordTypeLabel; 
        @AuraEnabled  public string recordTypeId;
        @AuraEnabled  public string description; 
    }
    
    public Class Contacts
    {
        @AuraEnabled  public string contactId; 
        
    }

    public class Cases{
        @AuraEnabled public String id;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String criticalChannelProtocol;
        @AuraEnabled public String subject;
        @AuraEnabled public String status;
        @AuraEnabled public String subStatus;
        @AuraEnabled public String recordTypeName;
    }
}