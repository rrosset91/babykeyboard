/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto Asset, com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_AssetDataFactory
{
    public static Asset createAssetMobile(string accountId, string contractId, id recordTypeAssetCECMovel)
    {
        return new Asset
        (
            Name = 'Netflix ilimitado',
            RecordTypeId = recordTypeAssetCECMovel,
            AccountId = accountId,
            vlocity_cmt__BillingAccountId__c = contractId,
            MSISDN__c = '11954434501',
            BusinessUnit__c = 'Claro'
        );
    } 

    public static Asset createAssetMobileActive(string accountId, string contractId, id recordTypeAssetCECMovel)
    {
        return new Asset
        (
            Name = 'Netflix ilimitado',
            RecordTypeId = recordTypeAssetCECMovel,
            AccountId = accountId,
            Status = 'Ativo',
            vlocity_cmt__BillingAccountId__c = contractId,
            MSISDN__c = '11954434501',
            BusinessUnit__c = 'Claro'
        );

    }
}