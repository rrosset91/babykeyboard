/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto vlocity_cmt__Premises__c(Premises), com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_VlocityCmtPremiesesDataFactory
{
    public static vlocity_cmt__Premises__c createPremises()
    {
        return new vlocity_cmt__Premises__c
        (
            Name = 'Rua Filippo Juvara, Casa',
            vlocity_cmt__StreetAddress__c = 'Rua Filippo Juvara',
            Complement__c = 'Casa',
            vlocity_cmt__PostalCode__c = '93020-020',
            Number__c = '81',
            Neighborhood__c = 'Jardim Ipanema',
            vlocity_cmt__State__c = 'SP',
            vlocity_cmt__Country__c = 'Brasil'
        );
    }
    
}