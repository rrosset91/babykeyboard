/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto Contact, com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
public with sharing class CEC_ContactDataFactory
{
    public static Contact createContact(string accountId)
    {
      return new Contact
      (
      	LastName = 'Freitas',
        DocumentNumber__c = '25201869092',
        AccountId = accountId
      );  
    }
}