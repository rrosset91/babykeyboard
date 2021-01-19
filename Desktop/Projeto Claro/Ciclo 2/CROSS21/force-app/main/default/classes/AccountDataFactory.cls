/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Account)
* @date: 16-09-2020
*/
@isTest
public with sharing class AccountDataFactory {

 //********** Este metodo recebe como parametro o nome do tipo de registro e gera uma conta**********
 public static Account getSingleAccount(String recordTypeName){
    Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        acc.Name = StringDataFactory.getMockString('Name');
        acc.vlocity_cmt__CustomerValue__c = 'Black';
        acc.Email__c = StringDataFactory.getMockString('Email');
    system.debug('@@SingleAccount -->'+acc);
    return acc;
}

//********** Este metodo recebe como parametro o nome do tipo de registro e quantidade desejada e gera uma lista com a quantidade de contas informada**********
public static List<Account> getMultipleAccounts(String recordTypeName, Integer amount){
    Integer x = 1;
    List<Account> accList = new List<Account>();
    while (x <= amount) {
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        acc.Name = StringDataFactory.getMockString('Name')+String.valueOf(x);
        acc.ContractReferenceNumber__c = String.valueOf(IntegerDataFactory.getMockInteger());
        acc.Email__c = StringDataFactory.getMockString('Email');
        accList.add(acc);
        x++;
    }
    system.debug('@@AccountList -->'+accList);
    return accList;
}
}