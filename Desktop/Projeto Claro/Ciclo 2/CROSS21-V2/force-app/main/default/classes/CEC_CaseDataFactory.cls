/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto Case, com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_CaseDataFactory
{
    public static case createCaseCostumerGOVAsset(String accountId, String assetId, id recordTypeCostumerGOVCase)
    {
        return new case
        (
            Status = 'New',
            Description = 'Teste Asset',
            SubStatus__c = 'Não Iniciado',
            Channel__c = 'Consumidor.gov',
            RecordTypeId = recordTypeCostumerGOVCase,
            OpenDateRobot__c = system.now(),
            AccountId = accountId,            
            LineNumber__c = assetId 
        );        
    }
    
    public static case createCaseCostumerGOVContract(String accountId, String contractId, id recordTypeCostumerGOVCase)
    {
        return new case
        (
            Status = 'New',
            Description = 'Teste Asset',
            SubStatus__c = 'Não Iniciado',
            Channel__c = 'Consumidor.gov',
            RecordTypeId = recordTypeCostumerGOVCase,
            OpenDateRobot__c = system.now(),
            AccountId = accountId,
            ContractBillingAccount__c  = contractId  
        );        
    }
}