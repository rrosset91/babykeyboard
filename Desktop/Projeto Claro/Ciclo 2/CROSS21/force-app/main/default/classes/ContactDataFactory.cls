/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Contact)
* @date: 16-09-2020
*/
@isTest
public with sharing class ContactDataFactory {

    //********** Este metodo recebe como parametro o nome do tipo de registro e Id da conta associada e gera um contato**********
    public static Contact getSingleContact(String recordTypeName, String accId){
        Contact ct = new Contact();
            ct.AccountId = accId;    
            ct.FirstName =  StringDataFactory.getMockString('Name');
            ct.LastName = StringDataFactory.getMockString('Name');
            ct.Email =  StringDataFactory.getMockString('Email');
        system.debug('@@SingleContact -->'+ct);
        return ct;
    }
   
    //********** Este metodo recebe como parametro o nome do tipo de registro o Id da conta associada e quantidade desejada e gera uma lista com a quantidade de contatos informada**********
    public static List<Contact> getMultipleContacts(String recordTypeName, String accId, Integer amount){
        Integer x = 1;
        List<Contact> contactList = new List<Contact>();
        while (x <= amount){
        Contact ct = new Contact();
            ct.AccountId = accId;    
            ct.FirstName =  StringDataFactory.getMockString('Name')+String.valueOf(x);
            ct.LastName =  StringDataFactory.getMockString('Name')+String.valueOf(x);
            ct.Email =  StringDataFactory.getMockString('Email');
            contactList.add(ct);
            x++;
        }
        system.debug('@@@ContactList -->'+contactList);
        return contactList;
    }
}