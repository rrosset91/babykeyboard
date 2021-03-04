/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto Account, com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_AccountDataFactory 
{
    public static Account createCostumer(id recordTypeCostumerAccount)
    {
        return new Account
        (
            Name = 'Renan Freitas',
            DocumentType__c = 'CPF',
            DocumentNumber__c = '460.434.318-74',
            RecordTypeId = recordTypeCostumerAccount
        );
    }

    public static Account createContractWithBusinessUnit(string accountId, id recordTypeContractAccount)
    {
        return new Account
        (        
            BusinessUnit__c = 'Claro',
            Name = 'Renan Freitas',
            RecordTypeId = recordTypeContractAccount,
            ContractReferenceNumber__c = '00001111',
            parentId = accountId     
        );        
    }

    public static Account createContractWithStatusActive(string accountId, id recordTypeContractAccount, string addressPremisesId)
    {
        return new Account
        (
            vlocity_cmt__Status__c = 'Ativo',
            RecordTypeId = recordTypeContractAccount,
            ContractReferenceNumber__c = '00001111',
            InstalledPremises__c = addressPremisesId,
            Name = 'Renan Freitas',
            BusinessUnit__c = 'Net',
            parentId = accountId,
            ContractType__c = 'INDIVIDUAL'
        );
    }
}