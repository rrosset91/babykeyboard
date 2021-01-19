/**
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe para gerar dados fake para utilizacao em classes de teste (Custom Setting - ServiceParameter__c)
* @date: 16-09-2020
*/
@isTest
public with sharing class ServiceParameterDataFactory {

       //********** Este metodo recebe como parametro uma lista com o nome dos ServiceParameters__c desejados (Campo Name) e retorna uma lista completa com os ServiceParameters encontrados****************
       public static List<ServiceParameter__c> getMockServiceParameters( List<String> requiredServices){
        system.debug('@@@RequiredServices -->'+requiredServices);
        List<ServiceParameter__c> servicesList = [SELECT Id, name, EndPoint__c, Method__c, Timeout__c, ReturnMock__c, User__c, NamedCredential__c FROM ServiceParameter__c WHERE Name IN :requiredServices];
        system.debug('@@@ReturnedServiceParametersList -->'+servicesList);
        return servicesList;
    }
}